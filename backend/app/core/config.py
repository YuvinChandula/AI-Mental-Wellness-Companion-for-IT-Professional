import os
from typing import List, Optional
from dotenv import load_dotenv

load_dotenv()

class Settings:
    PROJECT_NAME: str = os.getenv("PROJECT_NAME", "MindSync AI Wellness Companion")
    VERSION: str = os.getenv("VERSION", "1.0.0")
    API_STR: str = "/api"
    ENV: str = os.getenv("ENV", "development") # development, testing, production
    
    # CORS Configuration
    ALLOWED_ORIGINS: List[str] = [
        origin.strip() for origin in os.getenv("ALLOWED_ORIGINS", "*").split(",")
    ]

    # Firebase Admin SDK Configuration
    FIREBASE_CREDENTIALS_PATH: Optional[str] = os.getenv("FIREBASE_CREDENTIALS_PATH")
    
    # Groq API Configuration
    GROQ_API_KEY: Optional[str] = os.getenv("GROQ_API_KEY")
    
    # Google Gemini API Configuration (Legacy/Fallback)
    GEMINI_API_KEY: Optional[str] = os.getenv("GEMINI_API_KEY")

    # Rate Limiting Configuration (requests per minute per IP)
    RATE_LIMIT_PER_MINUTE: int = int(os.getenv("RATE_LIMIT_PER_MINUTE", "60"))

    # Security Configuration
    API_KEY_PROTECTION: bool = os.getenv("API_KEY_PROTECTION", "false").lower() == "true"
    SECURE_HEADERS_ENABLED: bool = os.getenv("SECURE_HEADERS_ENABLED", "true").lower() == "true"

settings = Settings()
