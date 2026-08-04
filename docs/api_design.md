# MindSync AI – REST API Design Specifications

This document outlines the REST API endpoints exposed by the FastAPI backend, including requests, responses, data validation parameters, and error status conventions.

---

## 1. Authentication & Security Middleware

Except for documentation routes (Swagger UI / Redoc) and health endpoints, all endpoints are secured by an authorization dependency.

*   **Authorization Header Required:** `Authorization: Bearer <Firebase_ID_Token>`
*   **Verification Protocol:** The backend extracts the bearer token, validates the token signature against Firebase's public keys, and sets the request context `user_id` equal to the token subject.
*   **Rate Limiting:** Requests are throttled at a standard rate of **100 calls per minute per user ID** to prevent API abuse.

---

## 2. API Endpoints Catalog

### A. Health & Diagnostics
*   **Endpoint:** `GET /health`
*   **Authentication:** Not required
*   **Purpose:** Liveness and readiness check. Returns status code `200` with payload:
    ```json
    {
      "status": "healthy",
      "timestamp": "2026-07-21T09:46:49Z",
      "version": "1.0.0"
    }
    ```

---

### B. User Management
*   **Endpoint:** `POST /api/users/profile`
*   **Method:** `POST`
*   **Purpose:** Initial setup or update of Firestore user details.
*   **Request Body (JSON):**
    ```json
    {
      "fullName": "Jane Doe",
      "occupation": "DevOps Engineer",
      "age": 30,
      "gender": "Female"
    }
    ```
*   **Response Payload (200 OK):**
    ```json
    {
      "success": true,
      "message": "Profile updated successfully",
      "data": {
        "uid": "usr_xyz123",
        "email": "jane@company.com",
        "fullName": "Jane Doe",
        "occupation": "DevOps Engineer",
        "age": 30,
        "gender": "Female",
        "createdAt": "2026-07-21T15:18:12Z"
      }
    }
    ```

---

### C. Mood Logger
*   **Endpoint:** `POST /api/mood/log`
*   **Method:** `POST`
*   **Purpose:** Log a new mood journal entry.
*   **Request Body (JSON):**
    ```json
    {
      "mood": "Exhausted",
      "moodScore": 3,
      "stressLevel": 8,
      "energyLevel": 2,
      "journal": "Had a long debugging session that ran late into the night.",
      "tags": ["work", "late-hours"]
    }
    ```
*   **Response Payload (201 Created):**
    ```json
    {
      "success": true,
      "message": "Mood logged successfully",
      "data": {
        "id": "log_550e8400",
        "userId": "usr_xyz123",
        "mood": "Exhausted",
        "moodScore": 3,
        "stressLevel": 8,
        "energyLevel": 2,
        "journal": "Had a long debugging session that ran late into the night.",
        "tags": ["work", "late-hours"],
        "createdAt": "2026-07-21T15:18:12Z"
      }
    }
    ```

*   **Endpoint:** `GET /api/mood/history`
*   **Method:** `GET`
*   **Purpose:** Retrieve historical logs for the logged-in user.
*   **Query Parameters:**
    *   `limit` (Optional, default = 30): Page size.
    *   `startDate` / `endDate` (Optional, ISO-8601 strings): Date filters.
*   **Response Payload (200 OK):**
    ```json
    {
      "success": true,
      "data": [
        {
          "id": "log_550e8400",
          "mood": "Exhausted",
          "moodScore": 3,
          "stressLevel": 8,
          "createdAt": "2026-07-21T15:18:12Z"
        }
      ]
    }
    ```

---

### D. Machine Learning Burnout Predictor
*   **Endpoint:** `POST /api/predict/burnout`
*   **Method:** `POST`
*   **Purpose:** Run Random Forest model prediction based on recent tracked metrics.
*   **Request Body (JSON):**
    ```json
    {
      "sleepHours": 5.5,
      "workingHours": 10.0,
      "moodScore": 3,
      "stressLevel": 8,
      "dailySteps": 2500,
      "waterGlasses": 3,
      "exerciseMinutes": 0
    }
    ```
*   **Response Payload (200 OK):**
    ```json
    {
      "success": true,
      "data": {
        "burnoutRisk": "High",
        "confidence": 0.87,
        "riskScore": 84.0,
        "importantFactors": [
          "Low sleep (5.5h)",
          "Prolonged working hours (10.0h)",
          "Inadequate daily activity (2500 steps)"
        ],
        "recommendations": [
          "Take a 15-minute screen break immediately.",
          "Increase water intake.",
          "Target at least 7 hours of sleep tonight."
        ],
        "timestamp": "2026-07-21T15:18:12Z"
      }
    }
    ```

---

### E. Gemini AI Chat Assistant
*   **Endpoint:** `POST /api/chat/message`
*   **Method:** `POST`
*   **Purpose:** Submit a message to the conversational wellness coach.
*   **Request Body (JSON):**
    ```json
    {
      "sessionId": "session_001",
      "message": "How can I reduce my burnout risk today?"
    }
    ```
*   **Response Payload (200 OK):**
    ```json
    {
      "success": true,
      "data": {
        "response": "Hello Jane! Based on your current logged metrics, your sleep is low (5.5h) and stress is high (8/10). I suggest taking a short walk away from your desk right now, then dedicating 10 minutes to deep breathing. Try setting an alarm for 10 PM to begin winding down for sleep. How does that sound?",
        "timestamp": "2026-07-21T15:18:12Z"
      }
    }
    ```

---

### F. Recommendations Engine
*   **Endpoint:** `GET /api/recommendations`
*   **Method:** `GET`
*   **Purpose:** Retrieve a list of smart, context-aware suggestions.
*   **Response Payload (200 OK):**
    ```json
    {
      "success": true,
      "data": [
        {
          "id": "rec_8829",
          "title": "Unwind Outdoors",
          "description": "It's sunny outside. Put away your devices and walk for 15 minutes to clear your mind.",
          "reason": "Generated because current weather is clear, stress level is high, and daily steps are under 3000.",
          "category": "Activity",
          "priority": "High"
        }
      ]
    }
    ```

---

## 3. Standard Response Format

All backend responses conform to a unified wrapper structure:

```json
{
  "success": true,
  "message": "Operation description status",
  "data": {},
  "timestamp": "2026-07-21T09:46:49Z"
}
```

### Error Code Conventions:
*   `400 Bad Request`: Validation failure (e.g. out-of-bounds metrics like sleep hours = 26).
*   `401 Unauthorized`: Missing or malformed authentication token.
*   `403 Forbidden`: User attempts to write or read a resource belonging to a different `uid`.
*   `429 Too Many Requests`: Throttling rate limit exceeded.
*   `500 Internal Server Error`: Uncaught server exceptions, third-party API issues, or model loading failures.
