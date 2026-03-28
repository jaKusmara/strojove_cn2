from pathlib import Path
import json

BASE_DIR = Path(__file__).resolve().parent
RULES_PATH = BASE_DIR / "rules.json"


def load_rules(path=RULES_PATH):
    with open(path, "r", encoding="utf-8") as file:
        return json.load(file)


def row_matches_selector(row, selector):
    attribute, value = selector
    return row[attribute] == value


def row_matches_complex(row, complex_):
    for selector in complex_:
        if not row_matches_selector(row, selector):
            return False
    return True


def predict_one(rule_list, row, return_matched_rule=False):
    default_rule = None

    for rule in rule_list:
        if rule.get("default", False):
            default_rule = rule
            continue

        if row_matches_complex(row, rule["complex"]):
            if return_matched_rule:
                return {
                    "prediction": rule["prediction"],
                    "matched_rule": rule
                }
            return rule["prediction"]

    if default_rule is not None:
        if return_matched_rule:
            return {
                "prediction": default_rule["prediction"],
                "matched_rule": default_rule
            }
        return default_rule["prediction"]

    if return_matched_rule:
        return {
            "prediction": None,
            "matched_rule": None
        }
    return None


def main():
    rules = load_rules()

    sample = {
        "Outlook": "Sunny",
        "Temperature": "Hot",
        "Humidity": "High",
        "Wind": "Weak"
    }

    result = predict_one(rules, sample, return_matched_rule=True)

    print("Výsledok predikcie:")
    print(result)


if __name__ == "__main__":
    main()