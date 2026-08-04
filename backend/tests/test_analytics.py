import os
import sys
from fastapi.testclient import TestClient

# Add app directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.main import app

client = TestClient(app)

from datetime import datetime, timedelta

_now = datetime.utcnow()
_now_iso = _now.isoformat() + "Z"
_yesterday_iso = (_now - timedelta(days=1)).isoformat() + "Z"

# Helper mock telemetry data payload
mock_payload = {
    "moodLogs": [
        {
            "id": "log_01",
            "userId": "usr_mock_123",
            "mood": "😊",
            "moodScore": 8,
            "stressLevel": 3,
            "energyLevel": 7,
            "sleepHours": 8.0,
            "waterIntake": 8,
            "exerciseMinutes": 30,
            "notes": "Good day coding",
            "createdAt": _now_iso
        },
        {
            "id": "log_02",
            "userId": "usr_mock_123",
            "mood": "😐",
            "moodScore": 6,
            "stressLevel": 5,
            "energyLevel": 5,
            "sleepHours": 6.0,
            "waterIntake": 5,
            "exerciseMinutes": 15,
            "notes": "Standard day, a bit tired",
            "createdAt": _yesterday_iso
        }
    ],
    "burnoutPredictions": [
        {
            "predictionId": "pred_01",
            "userId": "usr_mock_123",
            "burnoutRisk": "Low",
            "confidence": 0.95,
            "riskScore": 12.0,
            "importantFactors": ["Good sleep", "Balanced work"],
            "createdAt": _now_iso
        }
    ],
    "recommendations": [
        {
            "recommendationId": "rec_01",
            "userId": "usr_mock_123",
            "completed": True,
            "saved": False,
            "feedback": "none",
            "category": "Sleep",
            "priority": "High",
            "createdAt": _now_iso
        }
    ]
}

def test_analytics_summary_unauthorized():
    response = client.post("/api/analytics/summary", json=mock_payload)
    assert response.status_code in [401, 403]

def test_analytics_summary_success():
    headers = {"Authorization": "Bearer mock_token_for_testing"}
    response = client.post("/api/analytics/summary", headers=headers, json=mock_payload)
    assert response.status_code == 200
    res = response.json()
    assert res["success"] is True
    assert "overallWellnessScore" in res["data"]
    assert res["data"]["overallWellnessScore"] > 0
    assert res["data"]["burnoutRisk"] == "Low"
    assert res["data"]["successRate"] == 100.0

def test_analytics_trends_success():
    headers = {"Authorization": "Bearer mock_token_for_testing"}
    payload_with_filter = {**mock_payload, "filterType": "last_7_days"}
    response = client.post("/api/analytics/trends", headers=headers, json=payload_with_filter)
    assert response.status_code == 200
    res = response.json()
    assert res["success"] is True
    assert len(res["data"]) > 0
    assert "wellnessScore" in res["data"][0]
    assert "date" in res["data"][0]

def test_historical_stats_success():
    headers = {"Authorization": "Bearer mock_token_for_testing"}
    response = client.post("/api/analytics/historical-stats", headers=headers, json=mock_payload)
    assert response.status_code == 200
    res = response.json()
    assert res["success"] is True
    assert "personalAverage" in res["data"]
    assert "weekChange" in res["data"]

def test_generate_report_success():
    headers = {"Authorization": "Bearer mock_token_for_testing"}
    response = client.post("/api/analytics/report/generate", headers=headers, json=mock_payload)
    assert response.status_code == 200
    res = response.json()
    assert res["success"] is True
    assert "reportId" in res["data"]
    assert "aiInsights" in res["data"]

def test_export_report_pdf():
    # Fetch report payload first
    headers = {"Authorization": "Bearer mock_token_for_testing"}
    gen_resp = client.post("/api/analytics/report/generate", headers=headers, json=mock_payload)
    report_data = gen_resp.json()["data"]
    
    # Post report payload to export PDF
    resp = client.post("/api/analytics/report/export?format=pdf", json=report_data)
    assert resp.status_code == 200
    assert resp.headers["content-type"] == "application/pdf"
    assert len(resp.content) > 0

def test_export_report_csv():
    headers = {"Authorization": "Bearer mock_token_for_testing"}
    gen_resp = client.post("/api/analytics/report/generate", headers=headers, json=mock_payload)
    report_data = gen_resp.json()["data"]
    
    # Post report payload to export CSV
    resp = client.post("/api/analytics/report/export?format=csv", json=report_data)
    assert resp.status_code == 200
    assert resp.headers["content-type"].startswith("text/csv")
    assert b"MINDSYNC AI WELLNESS REPORT" in resp.content
