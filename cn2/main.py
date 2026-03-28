import pandas as pd

DATASET_PATH = './cn2/dataset.csv'

def get_classes(dataset):
    return dataset['Play'].unique()

def get_selectors(dataset):
    columns = ['Outlook','Temperature','Humidity','Wind']

    res = []

    for column in columns:
        uniqueInColumn = dataset[column].unique()

        for unique in uniqueInColumn:
            res.append((column, unique))
    
    return res

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


def count_classes(covered_examples, target_attr='Play'):
    return {
        "Yes": (covered_examples[target_attr] == "Yes").sum(),
        "No": (covered_examples[target_attr] == "No").sum()
    }

def majority_class(counts):
    return "Yes" if counts["Yes"] > counts["No"] else "No"

def laplace_score(n, n_c, k):
    return (n_c + 1) / (n + k)


def evaluate_complex(dataset, complex_, classes, target_attr):
    covered_examples = get_covered_examples(dataset, complex_)
    counts = count_classes(covered_examples, target_attr)

    if len(covered_examples) == 0:
        return None

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
        attribute, value = selector

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

def predict_one(rule_list, row):
    default_prediction = None

    for rule in rule_list:
        if rule.get("default", False):
            default_prediction = rule["prediction"]
            continue

        if row_matches_complex(row, rule["complex"]):
            return rule["prediction"]

    return default_prediction

def predict_all(rule_list, dataset):
    predictions = []

    for _, row in dataset.iterrows():
        prediction = predict_one(rule_list, row)
        predictions.append(prediction)

    return predictions

def accuracy_score(y_true, y_pred):
    correct = 0

    for real, pred in zip(y_true, y_pred):
        if real == pred:
            correct += 1

    return correct / len(y_true)

def main():
    df = pd.read_csv(DATASET_PATH)
    classes = get_classes(df)
    selectors = get_selectors(df)

    rules = cn2_train(df, selectors, classes, "Play", beam_width=3)

    for rule in rules:
        print(rule)

    predictions = predict_all(rules, df)
    print(predictions)
    
    acc = accuracy_score(df["Play"].tolist(), predictions)
    print(acc)

main()