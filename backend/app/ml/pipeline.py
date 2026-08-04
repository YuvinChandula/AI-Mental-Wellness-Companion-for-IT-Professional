import os
import joblib
import numpy as np
import shap

class BurnoutPipeline:
    _instance = None

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(BurnoutPipeline, cls).__new__(cls)
            cls._instance._initialized = False
        return cls._instance

    def initialize(self):
        if self._initialized:
            return
        
        # Determine path
        model_path = os.path.join(
            os.path.dirname(__file__), 'models', 'burnout_model.pkl'
        )
        if not os.path.exists(model_path):
            raise FileNotFoundError(
                f"Model artifact not found at {model_path}. Please run train.py first."
            )

        print(f"Loading ML pipeline from {model_path}...")
        payload = joblib.load(model_path)
        self.model = payload['model']
        self.scaler = payload['scaler']
        self.feature_names = payload['features']
        self.metadata = payload['metadata']
        
        # Initialize SHAP TreeExplainer
        self.explainer = shap.TreeExplainer(self.model)
        self._initialized = True
        print("ML pipeline successfully loaded into memory!")

    def predict(self, input_data: dict) -> dict:
        if not self._initialized:
            self.initialize()

        # Map API keys to trained feature order
        feature_order = [
            'sleep_hours',
            'working_hours',
            'mood_score',
            'stress_level',
            'energy_level',
            'water_intake',
            'daily_steps',
            'exercise_minutes',
            'consecutive_working_days'
        ]

        # Extract features and handle missing values by defaulting
        features = []
        for feat in feature_order:
            val = input_data.get(feat)
            if val is None:
                # Default values if missing
                defaults = {
                    'sleep_hours': 7.0,
                    'working_hours': 8.0,
                    'mood_score': 3,
                    'stress_level': 5,
                    'energy_level': 5,
                    'water_intake': 6,
                    'daily_steps': 5000,
                    'exercise_minutes': 30,
                    'consecutive_working_days': 5
                }
                val = defaults[feat]
            features.append(float(val))

        import pandas as pd
        features_df = pd.DataFrame([features], columns=self.feature_names)
        
        # Scale features
        scaled_features = self.scaler.transform(features_df)
        
        # Predict class
        pred_class_idx = int(self.model.predict(scaled_features)[0])
        probabilities = self.model.predict_proba(scaled_features)[0]
        confidence = float(probabilities[pred_class_idx])

        # Define class mappings
        class_mapping = {
            0: 'Low',
            1: 'Medium',
            2: 'High'
        }
        risk_label = class_mapping.get(pred_class_idx, 'Medium')

        # Calculate continuous risk score (0-100) based on weighted probabilities
        # Low=0, Medium=50, High=100
        risk_score = float((probabilities[1] * 50) + (probabilities[2] * 100))

        # Explain prediction via SHAP values
        shap_values = self.explainer.shap_values(scaled_features)
        
        # In newer shap versions, shap_values can be a 3D array [samples, features, classes] or a list of arrays [classes][samples, features]
        # Handle list structure
        if isinstance(shap_values, list):
            class_shap = shap_values[pred_class_idx][0]
        else:
            # Handle 3D array
            if len(shap_values.shape) == 3:
                class_shap = shap_values[0, :, pred_class_idx]
            else:
                class_shap = shap_values[0]

        # Map SHAP values to features and sort positive impact
        contributions = list(zip(self.feature_names, class_shap))
        contributions.sort(key=lambda x: x[1], reverse=True)

        # Human-readable labels mapping for top factors
        readable_factors = {
            'sleep_hours': 'Low sleep duration',
            'working_hours': 'Prolonged working hours',
            'mood_score': 'Low logged mood scores',
            'stress_level': 'Elevated stress index',
            'energy_level': 'Low stamina/energy',
            'water_intake': 'Inadequate hydration',
            'daily_steps': 'Inactivity (low daily steps)',
            'exercise_minutes': 'Lack of exercise',
            'consecutive_working_days': 'Continuous working days without break'
        }

        important_factors = []
        for feat, val in contributions:
            if val > 0.01: # positive impact pushing towards the predicted risk
                important_factors.append(readable_factors.get(feat, feat))
            if len(important_factors) >= 3:
                break

        # Fallback if no positive factors found
        if not important_factors:
            important_factors = ['Stress and sleep fluctuations']

        # Generate personalized wellness recommendations
        recommendations = []
        if risk_label == 'High':
            recommendations.extend([
                'Take a 15-minute screen break immediately.',
                'Target at least 7-8 hours of sleep tonight.',
                'Disconnect from code logs and Slack after work hours.'
            ])
        elif risk_label == 'Medium':
            recommendations.extend([
                'Keep water bottle near desk (aim for 2L daily).',
                'Engage in a 20-minute light walking break today.',
                'Limit consecutive screen hours.'
            ])
        else:
            recommendations.extend([
                'Maintain your healthy hydration and exercise patterns.',
                'Log your daily wellness check-ins regularly.'
            ])

        return {
            'burnoutRisk': risk_label,
            'confidence': confidence,
            'riskScore': risk_score,
            'importantFactors': important_factors,
            'recommendations': recommendations
        }
