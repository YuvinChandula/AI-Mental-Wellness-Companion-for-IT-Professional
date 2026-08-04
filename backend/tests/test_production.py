import os
import sys
from fastapi.testclient import TestClient

# Add app directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.main import app

client = TestClient(app)

def test_security_headers_are_present():
    response = client.get("/health")
    assert response.status_code == 200
    assert "x-frame-options" in response.headers
    assert response.headers["x-frame-options"] == "DENY"
    assert "x-content-type-options" in response.headers
    assert response.headers["x-content-type-options"] == "nosniff"

def test_validation_error_standardized_response():
    # Post empty JSON to trigger validation error on predict endpoint
    headers = {"Authorization": "Bearer mock_token_for_testing"}
    response = client.post("/api/predict/burnout", headers=headers, json={})
    assert response.status_code == 422
    res = response.json()
    assert res["success"] is False
    assert "requestId" in res
    assert "timestamp" in res
    assert "data" in res
    assert "details" in res["data"]
