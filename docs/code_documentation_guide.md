# MindSync AI – Complete Architecture & Code Documentation Guide

> **Exhaustive code reference, architectural breakdown, and feature documentation for MindSync AI (FastAPI ML Backend & Flutter Mobile Client).**

---

## Table of Contents

1. [System Overview & Architecture High-Level](#1-system-overview--architecture-high-level)
2. [Backend Architecture & Code Walkthrough (`backend/`)](#2-backend-architecture--code-walkthrough-backend)
   - [2.1 Main Application Bootstrap (`app/main.py`)](#21-main-application-bootstrap-appmainpy)
   - [2.2 API Endpoint Routers (`app/api/endpoints/`)](#22-api-endpoint-routers-appapiendpoints)
   - [2.3 Core Services & Security (`app/core/`)](#23-core-services--security-appcore)
   - [2.4 Middleware Components (`app/middleware/`)](#24-middleware-components-appmiddleware)
   - [2.5 Machine Learning Pipeline (`app/ml/`)](#25-machine-learning-pipeline-appml)
   - [2.6 Background Services & Scheduler (`app/services/`)](#26-background-services--scheduler-appservices)
3. [Frontend Architecture & Code Walkthrough (`frontend/`)](#3-frontend-architecture--code-walkthrough-frontend)
   - [3.1 Application Entry & Storage Initialization (`lib/main.dart`)](#31-application-entry--storage-initialization-libmaindart)
   - [3.2 Core Foundation Layer (`lib/core/`)](#32-core-foundation-layer-libcore)
   - [3.3 Feature Modules (`lib/features/`)](#33-feature-modules-libfeatures)
     - [3.3.1 Authentication Feature (`lib/features/authentication/`)](#331-authentication-feature-libfeaturesauthentication)
     - [3.3.2 Dashboard Feature (`lib/features/dashboard/`)](#332-dashboard-feature-libfeaturesdashboard)
     - [3.3.3 Burnout Assessment & Prediction (`lib/features/burnout/`)](#333-burnout-assessment--prediction-libfeaturesburnout)
     - [3.3.4 AI Chat Companion (`lib/features/chat/`)](#334-ai-chat-companion-libfeatureschat)
     - [3.3.5 Mood & Telemetry Tracking (`lib/features/mood/`)](#335-mood--telemetry-tracking-libfeaturesmood)
     - [3.3.6 Recommendation Engine (`lib/features/recommendations/`)](#336-recommendation-engine-libfeaturesrecommendations)
     - [3.3.7 Notifications Engine (`lib/features/notifications/`)](#337-notifications-engine-libfeaturesnotifications)
     - [3.3.8 Analytics & Report Exporter (`lib/features/reports/`)](#338-analytics--report-exporter-libfeaturesreports)
     - [3.3.9 Profile & Settings System (`lib/features/profile/` & `settings/`)](#339-profile--settings-system-libfeaturesprofile--settings)
4. [Firebase & Security Configuration (`firebase/`)](#4-firebase--security-configuration-firebase)
5. [End-to-End Operational Workflows](#5-end-to-end-operational-workflows)

---

## 1. System Overview & Architecture High-Level

MindSync AI is built on a **Clean Architecture** paradigm, dividing backend microservices and frontend clients into decoupled layers:

```
+-------------------------------------------------------------------------+
|                          Flutter Mobile Client                          |
|  Presentation (Riverpod)  <-->  Domain (Use Cases)  <-->  Data (Hive/Dio)  |
+------------------------------------+------------------------------------+
                                     | REST API (HTTP / JSON)
                                     v
+-------------------------------------------------------------------------+
|                           FastAPI Backend Microservices                  |
|  Routers  -->  Middlewares  -->  ML Pipelines (Scikit-Learn)  --> SHAP  |
+------------------------------------+------------------------------------+
                                     |
                                     v
+-------------------------------------------------------------------------+
|                           Cloud Services & Database                      |
|       Firebase Auth    |    Cloud Firestore    |    Firebase Storage    |
+-------------------------------------------------------------------------+
```

---

## 2. Backend Architecture & Code Walkthrough (`backend/`)

### 2.1 Main Application Bootstrap (`app/main.py`)

File: [main.py](file:///c:/Users/YUVIN/OneDrive/Documents/AI-Mental-Wellness-Companion-for-IT-Professionals/backend/app/main.py)

- **Purpose**: Initializes the FastAPI application instance, registers global exception handlers, configures CORS policies, attaches security and audit middlewares, and handles startup hooks.
- **Key Initialization Steps**:
  1. `setup_logging()`: Configures structured JSON logging via Loguru.
  2. `setup_exception_handlers(app)`: Registers custom status code mappers for `HTTPException` and validation errors.
  3. **Middleware Pipeline**:
     - `CORSMiddleware`: Controls cross-origin requests (`ALLOWED_ORIGINS`).
     - `RequestLoggingMiddleware`: Logs HTTP method, URL, status code, and latency for every request.
     - `RateLimitingMiddleware`: Enforces IP-based request limits (`RATE_LIMIT_PER_MINUTE`).
     - `SecurityHeadersMiddleware`: Injects XSS protection, HSTS, and frame options headers.
  4. **Startup Lifecycle Hook** (`startup_event()`):
     - `FirebaseService.initialize()`: Connects to Firebase Admin SDK using service account JSON credentials.
     - `ModelManager().initialize()`: Scans model directories for pre-trained Random Forest weights.
     - `BackgroundScheduler().start()`: Starts background tasks for model metrics sync and cache cleanup.
     - `BurnoutPipeline().initialize()`: Pre-loads ML scikit-learn models and SHAP explainers into memory.

---

### 2.2 API Endpoint Routers (`app/api/endpoints/`)

1. **Health Router** (`health.py`):
   - `GET /health`: Returns service operational state, runtime environment, version info, and ML model loaded status.

2. **Prediction Router** (`predict.py`):
   - `POST /api/v1/predict/burnout`: Accepts developer work metrics (overtime hours, sleep hours, GitHub commits, meeting hours, stress index). Evaluates risk through `BurnoutPipeline`, returning:
     - `burnout_score` (0.0 to 100.0)
     - `risk_level` (`Low`, `Moderate`, `High`, `Critical`)
     - `top_risk_factors` (derived via SHAP values)

3. **Recommendations Router** (`recommendations.py`):
   - `GET /api/v1/recommendations`: Provides context-aware habit suggestions based on burnout score and developer role.
   - Leverages Google Gemini LLM API when configured, falling back to static heuristic recommendation matrices when offline.

4. **Analytics Router** (`analytics.py`):
   - `GET /api/v1/analytics/summary`: Computes aggregate telemetry (average sleep, weekly stress, burnout trajectory).
   - `POST /api/v1/analytics/export-pdf`: Generates downloadable PDF reports formatted via ReportLab.

5. **Notifications Router** (`notifications.py`):
   - `POST /api/v1/notifications/evaluate`: Evaluates telemetry and dispatches FCM (Firebase Cloud Messaging) push alerts if developer stress thresholds are exceeded.

---

### 2.3 Core Services & Security (`app/core/`)

- **`config.py`**: Pydantic BaseSettings class loading configuration from `.env`:
  - `PROJECT_NAME`, `VERSION`, `ENV`
  - `FIREBASE_CREDENTIALS_PATH`
  - `GEMINI_API_KEY`
  - `RATE_LIMIT_PER_MINUTE`
- **`firebase.py`**: Initializes `firebase_admin` singleton and provides Firestore and Auth client handles.
- **`logging.py`**: Intercepts standard Python logging statements and redirects them through Loguru for formatted file and console output.
- **`exceptions.py`**: Defines standard error responses (`APIException`, `ModelNotFoundException`, `UnauthorizedException`).

---

### 2.4 Middleware Components (`app/middleware/`)

- **`logging_middleware.py`**: Generates a unique request ID (`x-request-id`) for request tracing and records execution elapsed milliseconds.
- **`rate_limit_middleware.py`**: In-memory token bucket sliding window per client IP address.
- **`security_headers_middleware.py`**: Sets HTTP security response headers (`X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Content-Security-Policy`).

---

### 2.5 Machine Learning Pipeline (`app/ml/`)

1. **Training Script** (`train.py`):
   - Trains a `RandomForestClassifier` on developer workload datasets (`synthetic_burnout_dataset.csv`).
   - Performs standard scaling (`StandardScaler`) on input features.
   - Serializes trained model pipeline using `joblib` into `app/ml/models/burnout_model.pkl`.
2. **ML Pipeline Execution** (`pipeline.py`):
   - Loads `.pkl` binary artifacts into memory.
   - Executes feature preprocessing: scaling overtime, normalization of sleep/stress ratios.
   - Computes SHAP (`shap.TreeExplainer`) feature contributions to identify top drivers of burnout.

---

### 2.6 Background Services & Scheduler (`app/services/`)

- **`model_manager.py`**: Manages model artifact lifecycle, supporting model hot-swapping without restarting the FastAPI process.
- **`scheduler.py`**: Uses Python `threading.Timer` to periodically prune old cached prediction logs and verify model file checksum integrity.

---

## 3. Frontend Architecture & Code Walkthrough (`frontend/`)

The mobile client is built in **Flutter (Dart)** following **Feature-First Clean Architecture** with **Riverpod** for reactive state management.

```
frontend/lib/
├── main.dart                       # Entry point, Hive init, dotenv loading
├── core/                           # Shared foundation infrastructure
│   ├── config/                     # Environment configuration loader
│   ├── network/                    # Dio client, Auth interceptor
│   ├── routing/                    # GoRouter navigation rules
│   ├── services/                   # StorageService (Hive), SyncEngine
│   ├── theme/                      # Light/Dark AppTheme & AppColors
│   └── widgets/                    # Shared buttons, card layouts, loading overlays
└── features/                       # Independent domain feature modules
    ├── authentication/
    ├── burnout/
    ├── chat/
    ├── dashboard/
    ├── mood/
    ├── notifications/
    ├── profile/
    ├── recommendations/
    ├── reports/
    └── settings/
```

---

### 3.1 Application Entry (`lib/main.dart`)

File: [main.dart](file:///c:/Users/YUVIN/OneDrive/Documents/AI-Mental-Wellness-Companion-for-IT-Professionals/frontend/lib/main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await StorageService.init(); // Opens Hive local cache boxes
  runApp(const ProviderScope(child: MindSyncApp()));
}
```

---

### 3.2 Core Foundation Layer (`lib/core/`)

- **`routing/app_router.dart`**: Defines `GoRouter` declarative route tree:
  - `/login`, `/register`, `/forgot-password`, `/verify-email`
  - ShellRoute (Bottom Navigation Bar): `/dashboard`, `/mood`, `/chat`, `/recommendations`, `/reports`
  - `/settings`, `/profile`, `/security-settings`, `/privacy-settings`, `/data-management`, `/help-support`, `/about`
- **`theme/app_theme.dart`**: Implements light and dark Material 3 themes using Google Fonts (`Inter`), custom `ColorScheme`, and `CardThemeData`.
- **`services/storage_service.dart`**: Hive key-value box manager (`cacheBox`, `userBox`, `settingsBox`).
- **`services/sync_engine.dart`**: Background synchronizer that uploads locally queued offline logs (journals, mood logs) to Cloud Firestore when internet connection is restored.

---

### 3.3 Feature Modules (`lib/features/`)

Each feature module is structured into three layers:
1. `domain/`: Pure Dart entities, abstract repository interfaces, use cases.
2. `data/`: Data models (JSON/Firestore serializable), data sources (Dio/Firebase), repository implementations.
3. `presentation/`: UI screens (pages), reusable widgets, Riverpod state notifiers (`StateNotifierProvider`).

#### 3.3.1 Authentication Feature (`lib/features/authentication/`)
- Handles user signup, login, email verification check, and password reset.
- `AuthNotifier` manages `AuthState` transitions (`AuthInitial`, `AuthLoading`, `AuthSuccess`, `AuthVerificationPending`, `AuthFailure`).

#### 3.3.2 Dashboard Feature (`lib/features/dashboard/`)
- Displays welcome header, current local weather (via OpenWeather API with geolocation fallback), physical activity summary, and weekly wellness line charts (`fl_chart`).
- `DashboardNotifier` coordinates data fetching from local Hive cache and remote microservices.

#### 3.3.3 Burnout Assessment & Prediction (`lib/features/burnout/`)
- Guided multi-step assessment questionnaire gathering work metrics.
- Invokes FastAPI `/api/v1/predict/burnout` endpoint and displays color-coded risk meter and top SHAP risk factors.

#### 3.3.4 AI Chat Companion (`lib/features/chat/`)
- Conversational interface powered by Google Gemini API.
- Supports chat history session persistence, offline message queuing, and streaming AI responses.

#### 3.3.5 Mood & Telemetry Tracking (`lib/features/mood/`)
- Loggers for daily mood (1–5 scale), sleep hours, water intake (ml), stress levels (1–10), and exercise minutes.
- Renders interactive statistical summary charts.

#### 3.3.6 Recommendation Engine (`lib/features/recommendations/`)
- Contextual developer habit recommendations (e.g., "Pomodoro 25/5", "Postural Stretch", "Hydration Alert").
- Filter by category (`Workload`, `Mindfulness`, `Physical`, `Sleep`) with completion toggle tracking.

#### 3.3.7 Notifications Engine (`lib/features/notifications/`)
- Manages push notification preferences, quiet hours scheduling, and unread notification badge counters.

#### 3.3.8 Analytics & Report Exporter (`lib/features/reports/`)
- Telemetry trends overview with custom date range filters.
- PDF Report Exporter: Requests generated PDF from FastAPI backend and triggers native download file preview.

#### 3.3.9 Profile & Settings System (`lib/features/profile/` & `settings/`)
- User profile editing, avatar photo upload to Firebase Storage.
- Application settings: Theme mode switcher (Light/Dark/System), font size modifier, local Hive cache purging, data export (JSON/CSV/PDF), and account deletion flow.

---

## 4. Firebase & Security Configuration (`firebase/`)

- **`firestore.rules`**: Enforces strict user isolation. Users can only read/write documents where `resource.data.userId == request.auth.uid`.
- **`storage.rules`**: Restricts profile picture upload directory access to the authenticated document owner (`/users/{userId}/avatar.jpg`).

---

## 5. End-to-End Operational Workflows

### Burnout Prediction Sequence
```
[ User Completes Form ] 
          │
          ▼
[ Flutter BurnoutNotifier ] ──(HTTP POST /api/v1/predict/burnout)──► [ FastAPI Router ]
                                                                             │
                                                                             ▼
[ Flutter UI Renders Score ] ◄──(JSON: score, level, shap_factors)── [ ML Pipeline Predicts ]
```

### Offline-to-Online Sync Sequence
```
[ User Logs Mood (Offline) ] ──► [ Hive Storage (Queued) ]
                                          │
                        (Connectivity Restored Event)
                                          │
                                          ▼
[ Cloud Firestore ] ◄────── [ SyncEngine Flush Queue ]
```

---

> **Related Documentation Index**: See the [Master Documentation Index](documentation_index.md) for all architectural and engineering guides.
