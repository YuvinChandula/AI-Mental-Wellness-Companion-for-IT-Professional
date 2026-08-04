import os
import json
import firebase_admin
from firebase_admin import credentials, firestore, auth, messaging
from typing import Optional

class FirebaseService:
    _initialized = False
    db = None

    @classmethod
    def initialize(cls) -> None:
        if cls._initialized:
            return

        # Method 1: Load from JSON environment variable (for Render/cloud deployment)
        firebase_creds_json = os.getenv("FIREBASE_CREDENTIALS_JSON")
        if firebase_creds_json:
            try:
                cred_dict = json.loads(firebase_creds_json)
                cred = credentials.Certificate(cred_dict)
                firebase_admin.initialize_app(cred)
                cls._initialized = True
            except Exception as e:
                print(f"Warning: Failed to load Firebase credentials from ENV JSON: {e}")

        # Method 2: Load from file path (for local development)
        if not cls._initialized:
            cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH")
            if cred_path and os.path.exists(cred_path):
                try:
                    cred = credentials.Certificate(cred_path)
                    firebase_admin.initialize_app(cred)
                    cls._initialized = True
                except Exception as e:
                    print(f"Warning: Failed to load Firebase credentials from Certificate: {e}")

        # Method 3: Default credentials (for GCP environments)
        if not cls._initialized:
            try:
                firebase_admin.initialize_app()
                cls._initialized = True
            except Exception:
                # Fail silently during testing environment execution
                pass
        
        try:
            cls.db = firestore.client()
        except Exception:
            cls.db = None
