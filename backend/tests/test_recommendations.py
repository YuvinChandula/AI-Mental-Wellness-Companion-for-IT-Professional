import os
import sys
from fastapi.testclient import TestClient

# Add app directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.main import app

client = TestClient(app)

def test_generate_recommendations_success():
    headers = {"Authorization": "Bearer mock_token_for_testing"}
    response = client.post(
        "/api/recommendations/generate",
        headers=headers,
        json={
            "sleepHours": 5.0,
            "workingHours": 10.0,
            "moodScore": 4,
            "stressLevel": 9,
            "energyLevel": 4,
            "waterIntake": 3,
            "dailySteps": 2000,
            "exerciseMinutes": 0,
            "burnoutRisk": "High"
        }
    )
    assert response.status_code == 200
    payload = response.json()
    assert payload["success"] is True
    assert len(payload["data"]) > 0
    
    # Rule recommendation for low sleep/stress should trigger
    titles = [rec["title"] for rec in payload["data"]]
    assert any("Sleep" in t or "Reset" in t for t in titles)

def test_submit_feedback_success():
    headers = {"Authorization": "Bearer mock_token_for_testing"}
    response = client.post(
        "/api/recommendations/feedback",
        headers=headers,
        json={
            "recommendationId": "rule_sleep_5",
            "completed": True,
            "saved": False,
            "feedback": "Felt much better after walking",
            "like": True,
            "dislike": False
        }
    )
    assert response.status_code == 200
    assert response.json()["success"] is True
