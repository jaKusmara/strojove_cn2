from pathlib import Path
from typing import Literal
from cn2.predict_model import load_rules, predict_one

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

BASE_DIR = Path(__file__).resolve().parent
RULES_PATH = BASE_DIR / "rules.json"

app = FastAPI(title="CN2 Predictor API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://127.0.0.1:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class PredictionInput(BaseModel):
    Outlook: Literal["Sunny", "Overcast", "Rain"]
    Temperature: Literal["Hot", "Mild", "Cool"]
    Humidity: Literal["High", "Normal"]
    Wind: Literal["Weak", "Strong"]

rules = load_rules()


@app.get("/")
def root():
    return {"message": "CN2 API beží"}


@app.post("/predict")
def predict(data: PredictionInput):
    sample = data.model_dump()

    result = predict_one(rules, sample, return_matched_rule=True)

    return {
        "input": sample,
        "prediction": result["prediction"],
        "matched_rule": result["matched_rule"]
    }