import os
import sys
from fastapi.testclient import TestClient

# Add app directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.main import app

client = TestClient(app)

def test_get_notifications_unauthorized():
    response = client.get("/api/notifications")
    assert response.status_code in [401, 403]

def test_get_notifications_authorized():
    headers = {"Authorization": "Bearer mock_token_for_testing"}
    response = client.get("/api/notifications", headers=headers)
    assert response.status_code == 200
    res = response.json()
    assert res["success"] is True
    assert len(res["data"]) >= 2
    assert res["data"][0]["type"] == "wellness"

def test_mark_as_read_success():
    headers = {"Authorization": "Bearer mock_token_for_testing"}
    response = client.post("/api/notifications/seed_01/read", headers=headers)
    assert response.status_code == 200
    assert response.json()["success"] is True

    # Re-fetch notifications and verify isRead is True
    get_resp = client.get("/api/notifications", headers=headers)
    notifs = get_resp.json()["data"]
    target = [n for n in notifs if n["notificationId"] == "seed_01"][0]
    assert target["isRead"] is True

def test_delete_notification_success():
    headers = {"Authorization": "Bearer mock_token_for_testing"}
    response = client.delete("/api/notifications/seed_02", headers=headers)
    assert response.status_code == 200
    assert response.json()["success"] is True

    # Verify deleted
    get_resp = client.get("/api/notifications", headers=headers)
    notifs = get_resp.json()["data"]
    assert len([n for n in notifs if n["notificationId"] == "seed_02"]) == 0

def test_preferences_crud():
    headers = {"Authorization": "Bearer mock_token_for_testing"}
    # Get defaults
    get_pref = client.get("/api/notifications/preferences", headers=headers)
    assert get_pref.status_code == 200
    assert get_pref.json()["data"]["pushEnabled"] is True

    # Update preferences
    payload = {
        "pushEnabled": False,
        "emailEnabled": True,
        "dailyReminders": False,
        "weeklySummaries": True,
        "aiSuggestions": True,
        "motivationMessages": False,
        "goalReminders": True,
        "soundEnabled": False,
        "vibrationEnabled": False,
        "wakeUpTime": "07:30",
        "sleepTime": "23:00",
        "waterFrequencyHours": 1,
        "quietHoursStart": "23:00",
        "quietHoursEnd": "06:00",
        "timezone": "PST"
    }
    update_pref = client.post("/api/notifications/preferences", headers=headers, json=payload)
    assert update_pref.status_code == 200
    assert update_pref.json()["data"]["pushEnabled"] is False
    assert update_pref.json()["data"]["wakeUpTime"] == "07:30"

def test_trigger_evaluation_high_stress():
    headers = {"Authorization": "Bearer mock_token_for_testing"}
    metrics_payload = {
        "sleepHours": 5.0,
        "workingHours": 10.0,
        "moodScore": 3,
        "stressLevel": 9,
        "energyLevel": 4,
        "waterIntake": 4,
        "dailySteps": 3000,
        "exerciseMinutes": 10,
        "burnoutRisk": "High"
    }
    response = client.post("/api/notifications/trigger-evaluation", headers=headers, json=metrics_payload)
    assert response.status_code == 200
    res = response.json()
    assert res["success"] is True
    # Should compile multiple rules (burnout/sleep/hydration/exercise/mood)
    assert len(res["data"]) > 0
    # Confirm it returns a critical/high alert due to sleep/burnout rules
    types = [n["type"] for n in res["data"]]
    assert "burnout" in types or "sleep" in types or "water" in types
