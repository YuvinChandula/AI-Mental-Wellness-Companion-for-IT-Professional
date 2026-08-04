import os
import joblib
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.preprocessing import RobustScaler
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.metrics import classification_report, accuracy_score, f1_score
import shap

def generate_synthetic_dataset(num_records=10000, seed=42):
    """
    Generates a realistic, slightly noisy synthetic dataset reflecting
    burnout risks for IT professionals based on behavioral and wellness metrics.
    """
    np.random.seed(seed)
    
    # 1. Feature generation
    sleep_hours = np.random.uniform(4.0, 10.0, num_records)
    working_hours = np.random.uniform(3.0, 16.0, num_records)
    mood_score = np.random.randint(1, 11, num_records)
    stress_level = np.random.randint(1, 11, num_records)
    energy_level = np.random.randint(1, 11, num_records)
    water_intake = np.random.randint(1, 13, num_records)
    daily_steps = np.random.randint(1000, 18000, num_records)
    exercise_minutes = np.random.randint(0, 121, num_records)
    consecutive_working_days = np.random.randint(0, 13, num_records)
    
    # 2. Risk score formula (with weights reflecting domain guidelines)
    # Higher working hours, stress, consecutive days, low sleep/mood/energy increase risk
    base_score = (
        (working_hours * 3.5) +
        (stress_level * 5.0) +
        ((10.0 - sleep_hours) * 4.0) +
        ((10.0 - mood_score) * 3.0) +
        ((10.0 - energy_level) * 3.0) +
        (consecutive_working_days * 2.0) -
        (exercise_minutes * 0.15) -
        (water_intake * 0.6) -
        (daily_steps * 0.0003)
    )
    
    # Add random noise to simulate natural variance and prevent 100% deterministic splits
    noise = np.random.normal(0, 4.0, num_records)
    total_score = base_score + noise
    
    # Clip between 0 and 100
    total_score = np.clip(total_score, 0, 100)
    
    # 3. Class labeling
    # Low: < 40, Medium: 40 - 70, High: >= 70
    risk_labels = []
    for score in total_score:
        if score < 40.0:
            risk_labels.append(0) # Low
        elif score < 70.0:
            risk_labels.append(1) # Medium
        else:
            risk_labels.append(2) # High
            
    df = pd.DataFrame({
        'sleep_hours': sleep_hours,
        'working_hours': working_hours,
        'mood_score': mood_score,
        'stress_level': stress_level,
        'energy_level': energy_level,
        'water_intake': water_intake,
        'daily_steps': daily_steps,
        'exercise_minutes': exercise_minutes,
        'consecutive_working_days': consecutive_working_days,
        'risk_score': total_score,
        'risk_label': risk_labels
    })
    return df

def train_and_evaluate():
    print("Generating synthetic wellness dataset...")
    df = generate_synthetic_dataset()
    
    X = df.drop(columns=['risk_score', 'risk_label'])
    y = df['risk_label']
    
    feature_names = list(X.columns)
    
    # Preprocessing: Split and Scale
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
    
    print("\nScaling features using RobustScaler...")
    scaler = RobustScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    
    # Define models
    models = {
        'Logistic Regression': LogisticRegression(max_iter=1000, random_state=42),
        'Decision Tree': DecisionTreeClassifier(random_state=42),
        'Random Forest': RandomForestClassifier(random_state=42),
        'Gradient Boosting': GradientBoostingClassifier(random_state=42)
    }
    
    print(f"\nSelecting Random Forest for tuning and export (per pipeline guidelines)...")
    best_model_name = 'Random Forest'
    best_raw_model = models['Random Forest']
    
    # Tuning the selected model (Random Forest)
    print("\nTuning hyperparameters using Grid Search...")
    param_grid = {
        'n_estimators': [50, 100, 150],
        'max_depth': [6, 10, None],
        'min_samples_split': [2, 5]
    }
    grid_search = GridSearchCV(
        RandomForestClassifier(random_state=42),
        param_grid,
        cv=3,
        scoring='f1_macro',
        n_jobs=-1
    )
    grid_search.fit(X_train_scaled, y_train)
    tuned_model = grid_search.best_estimator_
    print(f"Best params found: {grid_search.best_params_}")
    
    # Re-evaluate
    grid_preds = tuned_model.predict(X_test_scaled)
    grid_acc = accuracy_score(y_test, grid_preds)
    grid_f1 = f1_score(y_test, grid_preds, average='macro')
    print(f"Tuned Random Forest: Accuracy = {grid_acc:.4f}, F1-Score = {grid_f1:.4f}")
    print("\nClassification Report:")
    print(classification_report(y_test, grid_preds, target_names=['Low', 'Medium', 'High']))

    # Initialize SHAP explainer on training data
    print("\nInitializing SHAP explainer for global explainability...")
    explainer = shap.TreeExplainer(tuned_model)
    
    # Create directory if not exists
    os.makedirs(os.path.join('backend', 'app', 'ml', 'models'), exist_ok=True)
    model_path = os.path.join('backend', 'app', 'ml', 'models', 'burnout_model.pkl')
    
    # Save model pipeline
    print(f"Exporting model artifact to {model_path}...")
    pipeline_data = {
        'model': tuned_model,
        'scaler': scaler,
        'features': feature_names,
        'metadata': {
            'version': '1.0.0',
            'train_date': pd.Timestamp.now().isoformat(),
            'algorithm': best_model_name
        }
    }
    joblib.dump(pipeline_data, model_path)
    print("Export complete!")

if __name__ == '__main__':
    train_and_evaluate()
