# MindSync AI – Machine Learning Pipeline Spec

This document details the Machine Learning pipeline implemented in MindSync AI for predicting burnout risk among IT professionals.

---

## 1. Input Features

The predictive model consumes tabular inputs logged by the client app or aggregated from user context:

| Feature Name | Input Domain | Type | Description |
| :--- | :--- | :--- | :--- |
| `sleep_hours` | `[0.0, 24.0]` | Float | Hours of sleep tracked |
| `working_hours` | `[0.0, 24.0]` | Float | Working hours logged in a 24h period |
| `mood_score` | `[1, 10]` | Integer | Logged mood score rating |
| `stress_level` | `[1, 10]` | Integer | Logged stress level rating |
| `energy_level` | `[1, 10]` | Integer | Logged energy level rating |
| `water_intake` | `[0, 30]` | Integer | Tracked water glasses |
| `daily_steps` | `[0, 100000]` | Integer | Total pedometer step count |
| `exercise_minutes` | `[0, 1440]` | Integer | Total active minutes |

---

## 2. Pipeline Execution Flow

The ML flow is divided into **data preparation**, **training**, **evaluation**, and **deployment** phases:

```mermaid
graph LR
    Dataset[Synthetic Dataset] --> Preprocess[Clean, Scale & Encode]
    Preprocess --> Split[Train/Test Split]
    Split --> Train[Model Comparison: RF, LR, DT]
    Train --> HyperTune[Grid Search Tuning]
    HyperTune --> Select[Best Model Selection]
    Select --> SHAP[SHAP Explainability]
    SHAP --> Export[Joblib Model Export]
    Export --> Service[FastAPI Inference Service]
```

---

## 3. Data Preparation & Engineering
1.  **Imputation:** Missing sensor coordinates or values default to historical user averages.
2.  **Outlier Processing:** Clamps physical values outside standard distributions (e.g. sleep > 18 hours or steps > 40k).
3.  **Target Encoding:** The prediction output classes are mapped:
    *   `0` $\rightarrow$ **Low Burnout Risk**
    *   `1` $\rightarrow$ **Medium Burnout Risk**
    *   `2` $\rightarrow$ **High Burnout Risk**
4.  **Scaling:** Robust scaling is applied to steps and exercise minutes to avoid variance bias.

---

## 4. Model Training & Comparison

We evaluate three algorithms using cross-validation to select the primary predictor:

1.  **Logistic Regression (Baseline):** Interpretable, linear model. Serves as a baseline.
2.  **Decision Tree Classifier:** Captures non-linear feature splits, prone to overfitting.
3.  **Random Forest Classifier (Selected):** Ensemble model combining multiple trees. Outputs high accuracy and generalization robustness on small tables.

*Evaluation Metrics Criteria:*
*   **Primary Metric:** F1-score (macro-averaged) to balance precision and recall on class distributions.
*   **Threshold:** Target Accuracy $\ge 85\%$; F1-score $\ge 0.80$.

---

## 5. Explainable AI (XAI) & SHAP

To avoid black-box model pitfalls and build user trust, the backend integrates feature importance reporting:

*   **SHAP (SHapley Additive exPlanations):** Computes individual feature contributions to the final risk output class.
*   **Contributing Factors Output:** If the model flags a **High Risk**, the backend extracts the top three positive SHAP values (e.g. `sleep_hours` is low, `working_hours` is high, `stress_level` is high) and includes them as `importantFactors` in the API payload.

---

## 6. Serialization & Deployment
*   **Export:** The trained pipeline, containing scaling parameters and the classifier, is serialized to `backend/app/ml/models/burnout_model.pkl` using `joblib`.
*   **Inference Loader:** FastAPI loads the pickle file into memory during system startup (`main.py` event handler).
*   **Prediction Service:** Endpoint `/api/predict/burnout` triggers synchronous prediction runs in less than 50 milliseconds.
