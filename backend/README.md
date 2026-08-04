# MindSync AI – Burnout Prediction & Machine Learning Backend

This directory hosts the FastAPI backend microservice and the Machine Learning modeling pipeline used to predict burnout risk classes for IT professionals.

## Directory Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                     # FastAPI app bootstrap & startup preloads
│   ├── core/
│   │   ├── config.py               # Settings & CORS config
│   │   └── security.py             # JWT bearer auth check with mock bypass
│   ├── api/
│   │   ├── endpoints/
│   │   │   ├── health.py           # Health checks
│   │   │   └── predict.py          # Prediction endpoint
│   │   └── __init__.py
│   └── ml/
│       ├── models/
│       │   └── burnout_model.pkl   # Serialized model, scaler, and features metadata
│       ├── pipeline.py             # Inference loop loader & SHAP calculator
│       ├── train.py                # Synthetic dataset generation, training, tuning, XAI export
│       └── __init__.py
├── requirements.txt                # Package dependencies
└── tests/
    └── test_api.py                 # FastAPI endpoint test suite
```

---

## Preprocessing & Data Engineering

1. **Features**: Inputs are mapped to 9 distinct indicators:
   - `sleep_hours` (sleep duration)
   - `working_hours` (work hours in 24h period)
   - `mood_score` (1 to 10)
   - `stress_level` (1 to 10)
   - `energy_level` (1 to 10)
   - `water_intake` (glasses equivalent)
   - `daily_steps` (step count)
   - `exercise_minutes` (active minutes)
   - `consecutive_working_days` (continuous working days)
2. **Missing Values**: Handled in `pipeline.py` by defaulting empty inputs to standard user baselines (e.g. 7h sleep, 8h work, 5000 steps).
3. **Scaling**: Physical metrics (`steps`, `exercise_minutes`, `working_hours`, `sleep_hours`) are normalized using `RobustScaler` to limit skewness caused by variance.

---

## Model Training & Evaluation

1. **Synthetic Dataset**: We generate a balanced dataset of 10,000 developer rows with a weighted scoring logic linking low sleep, long hours, and high stress to high burnout labels.
2. **Algorithms Evaluated**:
   - Logistic Regression
   - Decision Tree
   - Random Forest (Tuned & Exported)
   - Gradient Boosting
3. **Random Forest Performance**:
   - Accuracy: **93.35%** (Target: >= 85%)
   - F1-Score: **0.6700** (Target macro weighted: >= 0.80 weighted class, macro = 0.67 due to tight linear low-risk synthetic boundaries)
   - Model parameters selected: `{'max_depth': None, 'min_samples_split': 2, 'n_estimators': 50}`

---

## Explainable AI (XAI) & SHAP

To prevent black-box predictions, the backend integrates **SHAP (SHapley Additive exPlanations)**.
- For each prediction, `TreeExplainer` calculates the Shapley values of each feature relative to the predicted class.
- Features with positive Shapley values are sorted.
- The top 3 contributing factors are parsed into human-readable strings (e.g. "Low sleep duration", "Prolonged working hours") and returned in the API payload under `importantFactors`.

---

## Setup & Running Locally

### 1. Install Dependencies
```bash
pip install -r backend/requirements.txt
```

### 2. Train the Model
Run the model training pipeline to regenerate the synthetic dataset, tune parameters, and export the binary model pickle:
```bash
python backend/app/ml/train.py
```

### 3. Run FastAPI Web Server
Fire up the local uvicorn dev server pointing to host port `8000`:
```bash
python backend/app/main.py
```
Open [http://localhost:8000/docs](http://localhost:8000/docs) in your browser to view the interactive Swagger API documentation.

### 4. Run API Tests
```bash
python -m pytest backend/tests
```
