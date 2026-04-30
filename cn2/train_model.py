from pathlib import Path
import json
import pandas as pd

# find_best_complex
# train
# main

BASE_DIR = Path(__file__).resolve().parent
DATASET_PATH = BASE_DIR / "dataset.csv"
RULES_PATH = BASE_DIR / "rules.json"

## ZISKANIE VSETKYCH TRIED
'''
dataset - nacitany dataset z CSV suboru
target_attr - nazov cieloveho stlpca, podla ktoreho sa klasifikuje
Vrati zoznam vsetkych moznych tried, napr. ["Yes", "No"]
'''
def get_classes(dataset, target_attr="Play"):
    return dataset[target_attr].unique().tolist()

## VYTVORENIE SELEKTOROV
'''
dataset - nacitany dataset
target_attr - cielovy stlpec, ktory sa nema pouzit ako podmienka
ignored_columns - stlpce, ktore sa maju ignorovat, napr. ID a Play
Vrati zoznam jednoduchych podmienok typu ("Outlook", "Sunny")
'''
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

## KONTROLA JEDNEJ PODMIENKY
'''
row - jeden riadok datasetu
selector - jedna podmienka vo forme (atribut, hodnota)
Vrati True, ak riadok splna podmienku, inak False
'''
def row_matches_selector(row, selector):
    attribute, value = selector
    return row[attribute] == value

## KONTROLA CELEHO PRAVIDLA
'''
row - jeden riadok datasetu
complex_ - zoznam podmienok, ktore spolu tvoria pravidlo
Vrati True, ak riadok splna vsetky podmienky pravidla
'''
def row_matches_complex(row, complex_):
    for selector in complex_:
        attribute, value = selector

        if row[attribute] != value:
            return False

    return True

## ZISKANIE POKRYTYCH PRIKLADOV
'''
dataset - nacitany dataset
complex_ - pravidlo tvorene zoznamom podmienok
Vrati iba tie riadky datasetu, ktore splnaju dane pravidlo
'''
def get_covered_examples(dataset, complex_):
    mask = []

    for _, row in dataset.iterrows():
        mask.append(row_matches_complex(row, complex_))

    return dataset[mask]

## SPOCITANIE TRIED
'''
covered_examples - riadky, ktore boli pokryte pravidlom
target_attr - cielovy stlpec, napr. Play
Vrati slovnik s poctom jednotlivych tried, napr. {"Yes": 4, "No": 1}
'''
def count_classes(covered_examples, target_attr="Play"):
    return covered_examples[target_attr].value_counts().to_dict()

## NAJDENIE VACSINOVEJ TRIEDY
'''
counts - slovnik s poctami tried
Vrati triedu, ktora ma najvacsi pocet vyskytov
'''
def majority_class(counts):
    if not counts:
        return None

    return max(counts, key=counts.get)

## VYPOCET LAPLACEOVHO SKORE
'''
n - pocet vsetkych prikladov pokrytych pravidlom
n_c - pocet prikladov konkretnej triedy
k - pocet vsetkych moznych tried
Vrati kvalitu pravidla pomocou Laplaceovho vzorca
'''
def laplace_score(n, n_c, k):
    return (n_c + 1) / (n + k)

## OHODNOTENIE PRAVIDLA
'''
dataset - dataset, na ktorom sa pravidlo hodnoti
complex_ - pravidlo tvorene podmienkami
classes - zoznam vsetkych moznych tried
target_attr - cielovy stlpec
Vrati slovnik s pravidlom, skore, predikciou, pokrytim a poctami tried
'''
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

## ROZSIRENIE PRAVIDLA
'''
complex_ - aktualne pravidlo
selectors - zoznam vsetkych jednoduchych podmienok
Vrati nove pravidla, ktore vzniknu pridanim jednej dalsiej podmienky
'''
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

## HLADANIE NAJLEPSIEHO PRAVIDLA
'''
dataset - aktualne zostavajuce priklady
selectors - vsetky mozne jednoduche podmienky
classes - zoznam moznych tried
target_attr - cielovy stlpec
beam_width - pocet najlepsich pravidiel, ktore sa ponechaju v kazdom kroku
Vrati najlepsie najdene pravidlo
'''
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

## ODSTRANENIE POKRYTYCH PRIKLADOV
'''
dataset - aktualny dataset
complex_ - pravidlo, podla ktoreho sa maju riadky odstranit
Vrati dataset bez riadkov, ktore boli pokryte pravidlom
'''
def remove_covered_examples(dataset, complex_):
    mask = []

    for _, row in dataset.iterrows():
        mask.append(not row_matches_complex(row, complex_))

    return dataset[mask]

## TRENOVANIE CN2 ALGORITMU
'''
dataset - cely nacitany dataset
selectors - vsetky mozne jednoduche podmienky
classes - zoznam moznych tried yes/no
target_attr - cielovy stlpec
beam_width - pocet najlepsich kandidatov ponechanych pri hladani pravidla
Vrati zoznam naucenych pravidiel
'''
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

## ULOZENIE PRAVIDIEL
'''
rules - zoznam naucenych pravidiel
path - cesta k suboru, kam sa pravidla ulozia
Ulozi pravidla do JSON suboru
'''
def save_rules(rules, path=RULES_PATH):
    serializable_rules = []

    for rule in rules:
        serialized_rule = dict(rule)
        serialized_rule["complex"] = [list(selector) for selector in rule["complex"]]
        serializable_rules.append(serialized_rule)

    with open(path, "w", encoding="utf-8") as file:
        json.dump(serializable_rules, file, indent=2, ensure_ascii=False)

## HLAVNA FUNKCIA PROGRAMU
'''
Nacita dataset, ziska triedy a selektory, natrenuje CN2 pravidla,
vypise ich a ulozi do suboru rules.json
'''
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