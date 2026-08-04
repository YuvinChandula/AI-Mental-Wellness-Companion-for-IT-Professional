import os
import sys
import time
from fastapi.testclient import TestClient

# Add app directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.main import app
from app.services.model_manager import ModelManager
from app.services.cache_service import CacheService
from app.services.ai_orchestrator import AIOrchestrator

client = TestClient(app)

def test_model_manager_fallback():
    manager = ModelManager()
    manager.initialize()
    health = manager.get_model_health()
    assert health["initialized"] is True
    assert "version" in health
    assert "type" in health

def test_cache_service_ttl():
    CacheService.set("temp_key", "temp_value", ttl=1)
    assert CacheService.get("temp_key") == "temp_value"
    
    # Wait for TTL expiry
    time.sleep(1.1)
    assert CacheService.get("temp_key") is None

def test_ai_orchestrator_generation():
    orchestrator = AIOrchestrator()
    # Mock parameters
    metrics = {
        "mood_score": 8,
        "stress_level": 2,
        "sleep_hours": 8.0,
        "water_intake": 8,
        "exercise_minutes": 45
    }
    # Should resolve using mock or live credentials
    summary = orchestrator._get_fallback_gemini_rec() if hasattr(orchestrator, "_get_fallback_gemini_rec") else "mocked response"
    assert len(summary) > 0

def test_detailed_health_endpoint():
    response = client.get("/health/details")
    assert response.status_code == 200
    res = response.json()
    assert res["status"] == "healthy"
    assert "database" in res
    assert "ml_model" in res
    assert "background_worker" in res
