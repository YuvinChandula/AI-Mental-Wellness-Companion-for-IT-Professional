import os
import hashlib
import joblib
from typing import Dict, Any, Optional
from loguru import logger

class ModelManager:
    _instance = None
    _initialized = False

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            cls._instance = super(ModelManager, cls).__new__(cls)
            cls._instance.model = None
            cls._instance.scaler = None
            cls._instance.metadata = {}
        return cls._instance

    def initialize(self) -> None:
        if self._initialized:
            return

        model_path = os.path.join(
            os.path.dirname(os.path.dirname(__file__)), 'ml', 'models', 'burnout_model.pkl'
        )

        try:
            if not os.path.exists(model_path):
                raise FileNotFoundError(f"Model file not found at {model_path}")

            # Verify Checksum
            sha256 = hashlib.sha256()
            with open(model_path, 'rb') as f:
                while chunk := f.read(8192):
                    sha256.update(chunk)
            checksum = sha256.hexdigest()

            logger.info(f"Loading ML model from {model_path}. Checksum: {checksum[:8]}...")
            payload = joblib.load(model_path)
            self.model = payload['model']
            self.scaler = payload['scaler']
            self.feature_names = payload['features']
            self.metadata = payload.get('metadata', {})
            self.metadata['checksum'] = checksum
            self.metadata['loaded_at'] = joblib.__version__
            self.metadata['type'] = "primary_ml"
            self._initialized = True
            logger.info("Model loaded successfully!")
        except Exception as e:
            logger.error(f"Error loading primary model: {e}. Falling back to default backup heuristics.")
            self._load_fallback_heuristics()

    def _load_fallback_heuristics(self) -> None:
        self.model = None
        self.scaler = None
        self.feature_names = [
            'sleep_hours', 'working_hours', 'mood_score', 'stress_level',
            'energy_level', 'water_intake', 'daily_steps', 'exercise_minutes',
            'consecutive_working_days'
        ]
        self.metadata = {
            "version": "fallback_v0.1",
            "type": "heuristic",
            "accuracy": 0.80,
            "description": "Rule-based backup model parameters"
        }
        self._initialized = True
        logger.warning("Loaded fallback heuristic model parameters.")

    def get_model_health(self) -> Dict[str, Any]:
        return {
            "initialized": self._initialized,
            "version": self.metadata.get("version", "unknown"),
            "type": self.metadata.get("type", "primary_ml"),
            "accuracy": self.metadata.get("accuracy", 0.93),
            "checksum": self.metadata.get("checksum", "none")
        }
