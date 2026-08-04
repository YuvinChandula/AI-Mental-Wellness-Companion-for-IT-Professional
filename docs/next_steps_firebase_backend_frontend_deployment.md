# MindSync AI – Full Next Steps Guide  
## From Demo Mode → Firebase → Backend → Frontend → Production Deployment

> **Purpose:** This document is the single roadmap for taking MindSync AI from the current **UI-only demo mode** to a fully connected, production-ready system.  
> **Audience:** Developers continuing the project after local Flutter demo runs.  
> **Last updated:** July 2026

---

## Table of Contents

1. [Current Project Status](#1-current-project-status)
2. [Roadmap Overview](#2-roadmap-overview)
3. [Phase 0 – Prerequisites & Accounts](#3-phase-0--prerequisites--accounts)
4. [Phase 1 – Firebase Setup (Required First)](#4-phase-1--firebase-setup-required-first)
5. [Phase 2 – Backend Setup (FastAPI + ML)](#5-phase-2--backend-setup-fastapi--ml)
6. [Phase 3 – Frontend Integration (Disable Demo Mode)](#6-phase-3--frontend-integration-disable-demo-mode)
7. [Phase 4 – Local Full-Stack Verification](#7-phase-4--local-full-stack-verification)
8. [Phase 5 – Testing & Quality Gates](#8-phase-5--testing--quality-gates)
9. [Phase 6 – Staging Deployment](#9-phase-6--staging-deployment)
10. [Phase 7 – Production Deployment](#10-phase-7--production-deployment)
11. [Phase 8 – Post-Launch Operations](#11-phase-8--post-launch-operations)
12. [Checklist Summary](#12-checklist-summary)
13. [Related Documentation](#13-related-documentation)
14. [Troubleshooting](#14-troubleshooting)

---

## 1. Current Project Status

### What already works (as of demo mode)

| Area | Status | Notes |
|------|--------|-------|
| Flutter UI screens | ✅ Done | Dashboard, Mood, Chat, Reports, Profile, Settings |
| Demo mode | ✅ Enabled | `AppConfig.demoMode = true` — mock data, no Firebase/backend |
| Android emulator run | ✅ Working | Pixel 5 / Pixel 7 Pro via Flutter |
| FastAPI backend code | ✅ Present | `backend/app/` with ML, Gemini, analytics endpoints |
| ML training script | ✅ Present | `backend/app/ml/train.py` |
| Firestore rules | ✅ Present | `firestore.rules` / `firebase/firestore.rules` |
| Docker backend | ✅ Present | `backend/Dockerfile` + `docker-compose.yml` |
| Real Firebase project | ❌ Not configured | Missing `google-services.json` + Admin credentials |
| Real API keys | ❌ Placeholders | Gemini / OpenWeather still example values |
| Backend live server | ❌ Not required for demo | Needed for real AI/ML features |
| Signed Play Store build | ❌ Not done | Release signing + AAB pending |
| Production hosting | ❌ Not done | Render/Railway/Cloud Run pending |

### Important flag

```dart
// frontend/lib/core/config/app_config.dart
static const bool demoMode = true; // ← set to false when Firebase + backend are ready
```

While `demoMode` is `true`, the app uses local mock repositories and skips Firebase initialization.

---

## 2. Roadmap Overview

```text
Phase 0  Prerequisites (accounts, keys, tools)
   ↓
Phase 1  Firebase project + Auth + Firestore + Storage + FCM
   ↓
Phase 2  Backend .env + credentials + train models + run API
   ↓
Phase 3  Frontend .env + google-services.json + demoMode=false
   ↓
Phase 4  Local end-to-end test (emulator ↔ backend ↔ Firebase)
   ↓
Phase 5  Automated tests + security review
   ↓
Phase 6  Staging deploy (backend cloud + internal APK)
   ↓
Phase 7  Production deploy (Play Store / cloud API)
   ↓
Phase 8  Monitoring, backups, ML retraining
```

**Recommended order:** Do **not** skip Firebase. Auth, Firestore, and token verification depend on it before backend/frontend production mode.

---

## 3. Phase 0 – Prerequisites & Accounts

### 3.1 Software to install

| Tool | Minimum | Purpose |
|------|---------|---------|
| Flutter SDK | 3.44+ | Mobile app |
| Android Studio | Latest | Emulator + SDK |
| Python | 3.11–3.12 preferred | Backend (3.14 may have package issues) |
| Git | Latest | Version control |
| Docker Desktop (optional) | Latest | Backend containers |
| Firebase CLI (optional) | Latest | Deploy rules |
| JDK 17 | Bundled with Android Studio | Android builds |

### 3.2 Accounts & API keys to create

| Account / Key | Where to get | Used by |
|---------------|--------------|---------|
| Google account | https://accounts.google.com | Firebase, Play Console |
| Firebase project | https://console.firebase.google.com | Auth, Firestore, Storage, FCM |
| Gemini API key | https://aistudio.google.com | Chat + AI summaries |
| OpenWeather API key | https://openweathermap.org/api | Weather widget |
| Google Play Console (later) | https://play.google.com/console | App publishing |
| Render / Railway / Cloud Run | Cloud provider of choice | Backend hosting |

### 3.3 Verify local tooling

```powershell
# Flutter
$env:Path = "C:\src\flutter\bin;" + $env:Path
flutter doctor -v
flutter doctor --android-licenses

# Python
python --version
pip --version

# Android emulator
flutter emulators
```

### Phase 0 exit criteria

- [ ] Flutter doctor shows Android toolchain ready  
- [ ] At least one AVD (Pixel 5 / Pixel 7) boots successfully  
- [ ] Gemini + OpenWeather keys obtained (store securely, not in git)  
- [ ] Google account ready for Firebase  

---

## 4. Phase 1 – Firebase Setup (Required First)

### 4.1 Create Firebase project

1. Open [Firebase Console](https://console.firebase.google.com)
2. **Add project** → name e.g. `mindsync-ai`
3. Enable Google Analytics (optional)
4. Wait for project creation

### 4.2 Enable required services

| Service | Console path | Required settings |
|---------|--------------|-------------------|
| **Authentication** | Build → Authentication → Sign-in method | Enable **Email/Password** |
| **Cloud Firestore** | Build → Firestore Database | Create database (start in **test mode** for local only, then deploy rules) |
| **Cloud Storage** | Build → Storage | Create default bucket |
| **Cloud Messaging** | Build → Messaging | Enabled by default for Android |

### 4.3 Register Android app

1. Project Settings → **Add app** → Android  
2. **Package name (must match exactly):**

```text
com.mindsyncai.mindsync_ai
```

3. Download `google-services.json`  
4. Place file at:

```text
frontend/android/app/google-services.json
```

> ⚠️ This file is gitignored. Never commit production keys. Each developer / CI must supply their own copy.

### 4.4 Create Admin SDK credentials (for backend)

1. Project Settings → **Service accounts**  
2. **Generate new private key** → downloads a JSON file  
3. Save as:

```text
backend/firebase-credentials.json
```

> ⚠️ Also gitignored. Treat as a secret.

### 4.5 Deploy Firestore security rules

Rules already exist in the repo:

- `firestore.rules`
- `firebase/firestore.rules`

**Option A – Firebase CLI**

```bash
npm install -g firebase-tools
firebase login
firebase init firestore   # if firebase.json not present
firebase deploy --only firestore:rules
```

**Option B – Console**

1. Firestore → Rules  
2. Paste contents of `firestore.rules`  
3. Publish  

### 4.6 Recommended Firestore collections

Align with existing app code (`users`, `mood_logs`, `chat_sessions`, `chat_messages`, `burnout_predictions`, `recommendations`, `notifications`, etc.). See [database_schema.md](database_schema.md) for full field lists.

### 4.7 (Optional) iOS / Web later

- iOS needs `GoogleService-Info.plist`  
- Web needs Firebase web config in Flutter web bootstrap  

Not required for Android-first deployment.

### Phase 1 exit criteria

- [ ] Email/Password auth enabled  
- [ ] Firestore + Storage created  
- [ ] `google-services.json` in `frontend/android/app/`  
- [ ] `firebase-credentials.json` in `backend/`  
- [ ] Security rules published  
- [ ] Test user can be created manually in Auth console  

---

## 5. Phase 2 – Backend Setup (FastAPI + ML)

### 5.1 Create backend environment file

```powershell
cd backend
copy .env.example .env
```

Edit `backend/.env`:

```dotenv
PROJECT_NAME="MindSync AI Wellness Companion"
VERSION="1.0.0"
ENV="development"

ALLOWED_ORIGINS="*"
FIREBASE_CREDENTIALS_PATH="firebase-credentials.json"
GEMINI_API_KEY="PASTE_REAL_GEMINI_KEY_HERE"
RATE_LIMIT_PER_MINUTE=60
SECURE_HEADERS_ENABLED=true
```

### 5.2 Python virtual environment

```powershell
cd backend
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

> Prefer **Python 3.11 or 3.12** for best package compatibility.

### 5.3 Train ML models (first time)

```powershell
python app/ml/train.py
```

Artifacts should appear under `backend/app/ml/models/` (e.g. burnout model pickle).

### 5.4 Start API server

```powershell
python app/main.py
```

Or:

```powershell
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

### 5.5 Verify backend health

| Check | URL |
|-------|-----|
| Health | http://localhost:8000/health |
| Swagger | http://localhost:8000/docs |
| ReDoc | http://localhost:8000/redoc |

### 5.6 Auth model (how frontend talks to backend)

1. Flutter signs in via **Firebase Auth**  
2. Client gets **Firebase ID token**  
3. Client calls FastAPI with:

```http
Authorization: Bearer <Firebase_ID_Token>
```

4. Backend verifies token with Firebase Admin SDK  

See [backend_production_guide.md](backend_production_guide.md) and [api_design.md](api_design.md).

### 5.7 Docker alternative (optional)

```powershell
cd backend
docker-compose up --build
```

Ensure `firebase-credentials.json` is mounted / available per `docker-compose.yml`.

### Phase 2 exit criteria

- [ ] `.env` filled with real Gemini key  
- [ ] `firebase-credentials.json` present  
- [ ] Models trained  
- [ ] `/health` returns OK  
- [ ] Swagger UI loads  
- [ ] Backend stays running while testing mobile app  

---

## 6. Phase 3 – Frontend Integration (Disable Demo Mode)

### 6.1 Configure frontend `.env`

```powershell
cd frontend
copy .env.example .env
```

For **Android emulator**:

```dotenv
BACKEND_URL=http://10.0.2.2:8000
GEMINI_API_KEY=your_gemini_api_key_here
OPENWEATHER_API_KEY=your_openweather_api_key_here
```

For **physical device**, use your PC LAN IP:

```dotenv
BACKEND_URL=http://192.168.x.x:8000
```

### 6.2 Confirm Firebase Android config

```text
frontend/android/app/google-services.json   ← real file from Firebase Console
```

### 6.3 Turn off demo mode

Edit `frontend/lib/core/config/app_config.dart`:

```dart
static const bool demoMode = false;
```

### 6.4 Restore real Firebase init in `main.dart`

When leaving demo mode, ensure startup includes:

1. `dotenv.load`  
2. `Firebase.initializeApp()`  
3. Hive `StorageService.init()`  

(Demo mode currently skips Firebase init intentionally.)

### 6.5 Install packages & generate code

```powershell
cd frontend
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### 6.6 Run on emulator

```powershell
flutter emulators --launch Pixel_5
flutter run -d emulator-5554
```

### Phase 3 exit criteria

- [ ] `demoMode = false`  
- [ ] Real `google-services.json` present  
- [ ] Frontend `.env` points to running backend  
- [ ] App builds without Gradle Google Services errors  
- [ ] Splash → Login/Register works with Firebase Auth  

---

## 7. Phase 4 – Local Full-Stack Verification

### 7.1 End-to-end happy path

| Step | Action | Expected |
|------|--------|----------|
| 1 | Start backend on `:8000` | Health OK |
| 2 | Launch Pixel emulator | Device online in `adb devices` |
| 3 | `flutter run` | App installs |
| 4 | Register new user | Appears in Firebase Auth |
| 5 | Verify email (if enforced) / login | Dashboard loads |
| 6 | Log a mood entry | Document in Firestore `mood_logs` |
| 7 | Open AI Chat | Gemini response via backend (or configured path) |
| 8 | Open Reports | Charts/analytics from API or Firestore |
| 9 | Kill network then restore | Offline cache / sync behavior |

### 7.2 Emulator ↔ host networking reminder

| Target | Use this URL |
|--------|--------------|
| Android emulator → host PC | `http://10.0.2.2:8000` |
| iOS simulator → host PC | `http://localhost:8000` |
| Physical phone → host PC | `http://<LAN-IP>:8000` |

### 7.3 Clear demo leftovers (if needed)

If Hive still has demo onboarding flags:

- Uninstall app from emulator, or  
- Clear app storage, or  
- Use Settings → Data management (when available)

### Phase 4 exit criteria

- [ ] Register / login / logout works  
- [ ] Mood CRUD persists in Firestore  
- [ ] Backend receives authenticated requests  
- [ ] Chat or prediction endpoint returns real responses  
- [ ] No Firebase `[core/no-app]` crashes  

---

## 8. Phase 5 – Testing & Quality Gates

### 8.1 Backend tests

```powershell
cd backend
venv\Scripts\activate
python -m pytest tests/ -v
```

### 8.2 Frontend tests

```powershell
cd frontend
flutter test
```

### 8.3 Manual QA checklist (minimum)

- [ ] Auth: register, login, forgot password  
- [ ] Mood: create, edit, history, calendar  
- [ ] Chat: send message, session list  
- [ ] Dashboard: wellness cards load  
- [ ] Reports: charts render  
- [ ] Profile: edit name / photo (Storage)  
- [ ] Settings: theme, privacy, logout  
- [ ] Offline banner / sync after reconnect  
- [ ] Permissions: location (weather), notifications  

### 8.4 Security gates before staging

- [ ] Firestore rules **not** left in open test mode for production  
- [ ] No secrets committed (`.env`, credentials JSON)  
- [ ] Rate limiting enabled in non-dev environments  
- [ ] CORS restricted for staging/production origins  

Details: [security_audit_report.md](security_audit_report.md), [qa_report_and_tests.md](qa_report_and_tests.md)

### Phase 5 exit criteria

- [ ] Critical automated tests pass  
- [ ] Manual smoke checklist completed  
- [ ] Secrets audited  

---

## 9. Phase 6 – Staging Deployment

### 9.1 Backend staging (Render / Railway / Cloud Run)

1. Connect GitHub repo  
2. Root directory: `backend`  
3. Build: `pip install -r requirements.txt` **or** Docker  
4. Start: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`  
5. Set secrets:

| Variable | Staging value |
|----------|---------------|
| `ENV` | `staging` |
| `ALLOWED_ORIGINS` | staging web/app origins (not `*`) |
| `GEMINI_API_KEY` | staging key |
| `FIREBASE_CREDENTIALS_PATH` | path / secret file mount |
| `RATE_LIMIT_PER_MINUTE` | `60` |
| `SECURE_HEADERS_ENABLED` | `true` |

6. Note public URL, e.g. `https://mindsync-api-staging.onrender.com`

### 9.2 Point Flutter staging build at staging API

```dotenv
BACKEND_URL=https://mindsync-api-staging.onrender.com
```

Build internal test APK:

```powershell
cd frontend
flutter build apk --release
```

Distribute via Firebase App Distribution / internal testers.

### 9.3 Firebase staging project (recommended)

Prefer a **separate Firebase project** for staging vs production to avoid polluting production user data.

### Phase 6 exit criteria

- [ ] Staging API health endpoint public & healthy  
- [ ] Internal APK connects to staging  
- [ ] Auth + Firestore work against staging Firebase project  

---

## 10. Phase 7 – Production Deployment

### 10.1 Backend production

Same as staging with stricter config:

```dotenv
ENV=production
ALLOWED_ORIGINS=https://app.mindsync.ai   # real domains only
SECURE_HEADERS_ENABLED=true
RATE_LIMIT_PER_MINUTE=60
```

Use provider secrets manager for Gemini + Firebase service account.

Optional hardening:

- Put API behind HTTPS only  
- Enable Cloud Logging / Loguru shipping  
- Schedule Firestore exports (see [deployment_and_devops_guide.md](deployment_and_devops_guide.md))

### 10.2 Android release signing

1. Create upload keystore (keep backup offline):

```powershell
keytool -genkey -v -keystore mindsync-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias mindsync
```

2. Configure `frontend/android/key.properties` (gitignored)  
3. Wire signing in `android/app/build.gradle.kts` for `release`  
4. Build Play Bundle:

```powershell
cd frontend
flutter build appbundle --release
```

Output: `frontend/build/app/outputs/bundle/release/app-release.aab`

### 10.3 Google Play Console

1. Create app listing (name, description, screenshots, privacy policy)  
2. Complete Data safety form (health/mood data is sensitive)  
3. Upload AAB to Internal testing → Closed → Production  
4. Set content rating questionnaire  
5. Submit for review  

### 10.4 Production Firebase

- [ ] Production Firebase project  
- [ ] Strict Firestore rules published  
- [ ] Auth domain / authorized apps configured  
- [ ] App Check (recommended later)  
- [ ] Billing alerts enabled  

### 10.5 Versioning

Follow SemVer in `pubspec.yaml` and backend `VERSION`:

```text
1.0.0  → first production
1.0.1  → hotfix
1.1.0  → feature release
```

### Phase 7 exit criteria

- [ ] Production API live with HTTPS  
- [ ] Production Firebase locked down  
- [ ] Signed AAB uploaded  
- [ ] Play Console listing + privacy + data safety complete  
- [ ] Smoke test on real devices  

---

## 11. Phase 8 – Post-Launch Operations

### 11.1 Monitoring

| Signal | Tool / approach |
|--------|-----------------|
| API uptime | Provider health checks + `/health` |
| Crash reporting | Firebase Crashlytics (add if not yet) |
| Auth errors | Firebase Auth metrics |
| API latency | Loguru + provider logs |
| ML accuracy drift | Periodic retrain + evaluation notes |

### 11.2 Backups

```bash
gcloud firestore export gs://mindsync-firestore-backups-bucket
```

Schedule daily exports. Document restore steps from [deployment_and_devops_guide.md](deployment_and_devops_guide.md).

### 11.3 ML model updates

1. Retrain: `python app/ml/train.py`  
2. Validate metrics  
3. Deploy new pickle + checksum via ModelManager flow  
4. Keep previous model for rollback  

### 11.4 Incident playbooks (short)

| Incident | Immediate action |
|----------|------------------|
| Gemini outage | Rely on rule/heuristic fallbacks already coded |
| Firestore outage | App continues from Hive cache; queue sync |
| Bad backend release | Rollback previous deploy on host |
| Compromised key | Rotate Gemini/Firebase key; revoke old credentials |

---

## 12. Checklist Summary

### A. Must create / obtain

| Artifact | Location |
|----------|----------|
| Firebase project | Console |
| `google-services.json` | `frontend/android/app/` |
| `firebase-credentials.json` | `backend/` |
| Frontend `.env` | `frontend/.env` |
| Backend `.env` | `backend/.env` |
| Gemini API key | Both `.env` files (as needed) |
| OpenWeather API key | `frontend/.env` |
| Trained ML models | `backend/app/ml/models/` |
| Android upload keystore | Secure offline + CI secret |
| Play Console listing | Google Play |
| Staging/Production API URL | Cloud host |
| Privacy policy URL | Required for Play Store |

### B. Must change in code/config for production path

| Change | File / place |
|--------|--------------|
| `demoMode = false` | `frontend/lib/core/config/app_config.dart` |
| Real Firebase init | `frontend/lib/main.dart` |
| Staging/prod `BACKEND_URL` | `frontend/.env` or build flavors |
| Restrict CORS | `backend/.env` |
| Release signing | Android Gradle + `key.properties` |

### C. Must not commit

- `.env` files  
- `google-services.json` (if treated as secret / env-specific)  
- `firebase-credentials.json`  
- `*.jks` / `key.properties`  
- Any personal API keys  

---

## 13. Related Documentation

| Document | When to use |
|----------|-------------|
| [application_run_guide.md](application_run_guide.md) | Day-to-day local run steps |
| [developer_onboarding_manual.md](developer_onboarding_manual.md) | New developer setup |
| [backend_production_guide.md](backend_production_guide.md) | Backend structure & auth middleware |
| [api_design.md](api_design.md) | Endpoint contracts |
| [database_schema.md](database_schema.md) | Firestore collections |
| [deployment_and_devops_guide.md](deployment_and_devops_guide.md) | CI/CD, backups, rollbacks |
| [security_audit_report.md](security_audit_report.md) | Security checklist |
| [qa_report_and_tests.md](qa_report_and_tests.md) | Test strategy |
| [ml_pipeline.md](ml_pipeline.md) | Burnout model details |
| [notifications_architecture.md](notifications_architecture.md) | Push / FCM design |

---

## 14. Troubleshooting

| Problem | Fix |
|---------|-----|
| `google-services.json is missing` | Download from Firebase and place under `frontend/android/app/` |
| `[core/no-app] No Firebase App` | Call `Firebase.initializeApp()` before using Auth/Firestore; ensure demoMode false uses real init |
| Emulator cannot reach backend | Use `http://10.0.2.2:8000`, backend bound to `0.0.0.0:8000` |
| Auth works but API 401 | Send Firebase ID token; verify Admin SDK credentials path |
| Emulator stuck offline / DLL errors | Kill `emulator.exe` / `qemu-system-x86_64.exe`, clear AVD `*.lock`, relaunch |
| Flutter command not found | Add `C:\src\flutter\bin` to PATH |
| `No pubspec.yaml` | Run Flutter commands from `frontend/`, not `backend/` |
| Play build unsigned | Configure release signing + `flutter build appbundle --release` |
| Firestore permission denied | Publish correct rules; ensure `request.auth.uid` matches `userId` fields |

---

## Quick Start (After Firebase + Keys Exist)

```powershell
# Terminal 1 – Backend
cd backend
venv\Scripts\activate
copy .env.example .env          # fill keys once
# place firebase-credentials.json here
python app/ml/train.py          # first time
python app/main.py

# Terminal 2 – Frontend
cd frontend
copy .env.example .env          # BACKEND_URL=http://10.0.2.2:8000
# place google-services.json in android/app/
# set AppConfig.demoMode = false
$env:Path = "C:\src\flutter\bin;" + $env:Path
flutter pub get
flutter run -d emulator-5554
```

---

## Suggested Team Ownership Split

| Role | Owns |
|------|------|
| Mobile engineer | Flutter demo→prod switch, Play signing, UI QA |
| Backend engineer | FastAPI deploy, Gemini keys, ML train/deploy |
| Cloud / DevOps | Firebase projects, rules, hosting, backups |
| Product / academic lead | Privacy policy, demo script, store listing copy |

---

> **Bottom line:** Demo mode proves the Flutter UI. Next, configure **Firebase**, run the **FastAPI backend**, set **`demoMode = false`**, verify locally, then deploy **staging → production** with signed Android builds and secured secrets.
