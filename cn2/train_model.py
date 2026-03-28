from pathlib import Path
import json
import pandas as pd

BASE_DIR = Path(__file__).resolve().parent
DATASET_PATH = BASE_DIR / "dataset.csv"
RULES_PATH = BASE_DIR / "rules.json"


def get_classes(dataset, target_attr="Play"):
    return dataset[target_attr].unique().tolist()


def get_selectors(dataset, target_attr="Play", ignored_columns=None):
    if ignored_columns is None:
        ignored_columns = ["ID", target_attr]

    selectors = []

    for column in dataset.columns:
        if column in ignored_columns:
            continue

        unique_values = dataset[column].unique()

        for value in unique_values:
            selectors.append((column, value))

    return selectors


def row_matches_selector(row, selector):
    attribute, value = selector
    return row[attribute] == value


def row_matches_complex(row, complex_):
    for selector in complex_:
        attribute, value = selector

        if row[attribute] != value:
            return False

    return True


def get_covered_examples(dataset, complex_):
    mask = []

    for _, row in dataset.iterrows():
        mask.append(row_matches_complex(row, complex_))

    return dataset[mask]


def count_classes(covered_examples, target_attr="Play"):
    return covered_examples[target_attr].value_counts().to_dict()


def majority_class(counts):
    if not counts:
        return None

    return max(counts, key=counts.get)


def laplace_score(n, n_c, k):
    return (n_c + 1) / (n + k)


def evaluate_complex(dataset, complex_, classes, target_attr="Play"):
    covered_examples = get_covered_examples(dataset, complex_)

    if len(covered_examples) == 0:
        return None

    counts = count_classes(covered_examples, target_attr)
    n = len(covered_examples)
    k = len(classes)

    best_score = -1
    best_class = None

    for class_name in classes:
        n_c = counts.get(class_name, 0)
        score = laplace_score(n, n_c, k)

        if score > best_score:
            best_score = score
            best_class = class_name

    return {
        "complex": complex_,
        "score": best_score,
        "prediction": best_class,
        "coverage": n,
        "counts": counts
    }


def specialize_complex(complex_, selectors):
    specializations = []
    used_attributes = {attribute for attribute, _ in complex_}

    for selector in selectors:
        attribute, _ = selector

        if selector in complex_:
            continue

        if attribute in used_attributes:
            continue

        new_complex = complex_ + [selector]
        specializations.append(new_complex)

    return specializations


def find_best_complex(dataset, selectors, classes, target_attr="Play", beam_width=3):
    star = [[]]
    best_complex = None

    while True:
        candidates = []

        for complex_ in star:
            specializations = specialize_complex(complex_, selectors)

            for spec in specializations:
                evaluated = evaluate_complex(dataset, spec, classes, target_attr)

                if evaluated is not None:
                    candidates.append(evaluated)

        if not candidates:
            break

        candidates.sort(key=lambda x: x["score"], reverse=True)
        top_candidates = candidates[:beam_width]

        if best_complex is None or top_candidates[0]["score"] > best_complex["score"]:
            best_complex = top_candidates[0]

        star = [candidate["complex"] for candidate in top_candidates]

    return best_complex


def remove_covered_examples(dataset, complex_):
    mask = []

    for _, row in dataset.iterrows():
        mask.append(not row_matches_complex(row, complex_))

    return dataset[mask]


def cn2_train(dataset, selectors, classes, target_attr="Play", beam_width=3):
    remaining_examples = dataset.copy()
    rule_list = []

    while len(remaining_examples) > 0:
        best_complex = find_best_complex(
            remaining_examples,
            selectors,
            classes,
            target_attr,
            beam_width
        )

        if best_complex is None:
            break

        rule_list.append(best_complex)

        remaining_examples = remove_covered_examples(
            remaining_examples,
            best_complex["complex"]
        )

        if len(remaining_examples) == 0:
            break

    if len(remaining_examples) > 0:
        counts = count_classes(remaining_examples, target_attr)
        default_prediction = majority_class(counts)

        rule_list.append({
            "complex": [],
            "prediction": default_prediction,
            "default": True
        })

    return rule_list


def save_rules(rules, path=RULES_PATH):
    serializable_rules = []

    for rule in rules:
        serialized_rule = dict(rule)
        serialized_rule["complex"] = [list(selector) for selector in rule["complex"]]
        serializable_rules.append(serialized_rule)

    with open(path, "w", encoding="utf-8") as file:
        json.dump(serializable_rules, file, indent=2, ensure_ascii=False)


def main():
    df = pd.read_csv(DATASET_PATH)

    classes = get_classes(df, "Play")
    selectors = get_selectors(df, "Play")

    rules = cn2_train(df, selectors, classes, "Play", beam_width=3)

    print("Naučené pravidlá:")
    for rule in rules:
        print(rule)

    save_rules(rules, RULES_PATH)
    print(f"\nPravidlá boli uložené do: {RULES_PATH}")


if __name__ == "__main__":
    main()