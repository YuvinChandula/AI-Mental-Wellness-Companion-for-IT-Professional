# MindSync AI – Module 11: FastAPI Backend & Production Services

This document details the production backend architecture, folder layout responsibilities, Firebase Authentication middleware, containerization parameters, and multi-platform deployment instructions.

---

## 1. Backend Folder Structure

```
backend/
├── app/
│   ├── api/
│   │   └── endpoints/              # REST Endpoints (health, predict, recommendations, analytics, notifications)
│   │
│   ├── core/
│   │   ├── config.py               # Env settings management (python-dotenv & Pydantic models)
│   │   ├── exceptions.py           # Central error-mapping exception handlers
│   │   ├── firebase.py             # Firebase Admin SDK setup and Firestore client
│   │   ├── logging.py              # Loguru structured timing logging redirector
│   │   └── security.py             # Firebase ID Token verifier (with test mocks bypass)
│   │
│   ├── middleware/
│   │   ├── logging_middleware.py   # Request timer audit logger
│   │   ├── rate_limit_middleware.py# IP-based sliding window rate limiter
│   │   └── security_headers_middleware.py # Enforces HSTS, nosniff, frame denial
│   │
│   ├── ml/
│   │   ├── models/                 # Serialized model pickles
│   │   ├── pipeline.py             # Preprocessing & inference loops
│   │   └── train.py                # Synthetic data training pipelines
│   │
│   └── utils/
│       └── responses.py            # Standardized JSON response utilities
│
├── tests/                          # Automated Pytest suites
├── Dockerfile                      # Production container spec
├── docker-compose.yml              # Local orchestration builder
├── requirements.txt                # Python package list
└── .env.example                    # Environment settings template
```

---

## 2. Authentication & Middleware Guide

- **Bearer Authorization**: Private endpoints are guarded using `app.core.security.get_current_user_id`. The client must attach the HTTP header:
  `Authorization: Bearer <Firebase_ID_Token>`
- **Token Validation**: In production, the backend passes the token through `firebase_admin.auth.verify_id_token` to inspect signatures, expiration times, and retrieve the Firebase User UID.
- **Testing Sandbox Bypass**: If the token matches the bypass string `"mock_token_for_testing"` or starts with `"mock_"`, the backend returns `"usr_mock_123"` immediately without checking Firebase servers, enabling offline testing.

---

## 3. OpenAPI, Swagger & ReDoc

- **Interactive Swagger Docs**: Available at `http://localhost:8000/docs`.
- **ReDoc static schemas**: Available at `http://localhost:8000/redoc`.
- **JSON Schemas**: Downloadable OpenAPI raw JSON structure is served at `http://localhost:8000/openapi.json`.

---

## 4. Multi-Platform Deployment Guides

### A. Docker Container Execution
Build and execute the backend microservice inside container environments:
```bash
# Build
docker build -t mindsync-backend ./backend

# Run local container
docker run -p 8000:8000 -e ENV=production mindsync-backend
```

### B. Railway or Render Deployment
1. Connect your Github repository to Render or Railway.
2. Specify Root Directory as `backend`.
3. Select Build Command: `pip install -r requirements.txt` (or choose Docker image builder since `Dockerfile` is provided).
4. Select Start Command: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`.
5. Insert Environment Variables from `.env.example` (ensuring `GEMINI_API_KEY` and `FIREBASE_CREDENTIALS_PATH` are populated).

### C. AWS Elastic Beanstalk / Azure App Service
1. Initialize the EB CLI and execute `eb init -p docker mindsync-backend`.
2. Configure environment variables in AWS dashboard configurations.
3. Deploy changes using `eb deploy`.
