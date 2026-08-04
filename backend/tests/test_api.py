import os
import sys
from fastapi.testclient import TestClient

# Add app directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.main import app

client = TestClient(app)

def test_health_endpoint():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_predict_burnout_unauthorized():
    response = client.post(
        "/api/predict/burnout",
        json={
            "sleepHours": 7.0,
            "workingHours": 8.0,
            "moodScore": 8,
            "stressLevel": 3,
            "dailySteps": 10000,
            "exerciseMinutes": 30
        }
    )
    # Checks that it fails when missing authorization bearer token
    assert response.status_code == 403 or response.status_code == 401

def test_predict_burnout_success():
    # Pass authorization header token bypass
    headers = {"Authorization": "Bearer mock_token_for_testing"}
    
    response = client.post(
        "/api/predict/burnout",
        headers=headers,
        json={
            "sleepHours": 5.0,
            "workingHours": 12.0,
            "moodScore": 3,
            "stressLevel": 9,
            "energyLevel": 3,
            "waterIntake": 4,
            "dailySteps": 2000,
            "exerciseMinutes": 0,
            "consecutiveWorkingDays": 6
        }
    )
    
    assert response.status_code == 200
    payload = response.json()
    assert payload["success"] is True
    assert "burnoutRisk" in payload["data"]
    assert "confidence" in payload["data"]
    assert "riskScore" in payload["data"]
    assert "importantFactors" in payload["data"]
    assert "recommendations" in payload["data"]
