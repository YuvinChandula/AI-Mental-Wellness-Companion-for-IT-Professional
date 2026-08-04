# MindSync AI – Cloud Deployment, CI/CD & DevOps Guide

This guide details environment setup configurations, release processes, database backups, rollback policies, and disaster recovery guides.

---

## 1. Environment Configurations Matrix

We support four independent environments (Development, Testing, Staging, Production) driven by environment parameters:

| Environment | Variable Name | Dev Value | Test Value | Staging Value | Production Value |
|-------------|---------------|-----------|------------|---------------|------------------|
| App Mode    | `ENV`         | `development` | `testing` | `staging`     | `production`     |
| CORS limits | `ALLOWED_ORIGINS`| `*`    | `*`        | `https://staging.mindsync.ai` | `https://app.mindsync.ai` |
| Rate Limit  | `RATE_LIMIT_PER_MINUTE` | `100` | `1000` | `60`          | `60`             |
| Sec Headers | `SECURE_HEADERS_ENABLED` | `false`| `false`| `true`        | `true`           |

*Note: Credentials keys like `GEMINI_API_KEY` are isolated inside secrets managers (e.g. Render Secrets panels or AWS parameter stores).*

---

## 2. Cloud Deployment Handbooks

### A. FastAPI Backend Deployment (Render or Railway)
1. Register a new web service linked to the repository path.
2. Select Root Directory as `backend`.
3. Choose the build and run configs:
   - **Build command**: `pip install -r requirements.txt` (or choose Docker builder using `Dockerfile`).
   - **Start command**: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`.
4. In the Variables panel, register all variables: `ENV=production`, `ALLOWED_ORIGINS`, `RATE_LIMIT_PER_MINUTE`, `SECURE_HEADERS_ENABLED=true`, `GEMINI_API_KEY`, and upload `firebase-credentials.json` path.

### B. Flutter App Release Builds (Android APK/AAB)
Compiling signed binaries:
```bash
# 1. Update packages
flutter pub get

# 2. Compile Release APK
flutter build apk --release

# 3. Compile Android App Bundle for Google Play Store upload
flutter build appbundle --release
```

---

## 3. Database Backup & Recoveries

### Firestore Backups
Firestore documents are exported to a Google Cloud Storage bucket:
```bash
# Scheduled Daily Cron (executed in GCP Console Scheduler)
gcloud firestore export gs://mindsync-firestore-backups-bucket
```

### Restoration Procedure
If database corruption occurs:
```bash
gcloud firestore import gs://mindsync-firestore-backups-bucket/2026-07-23T08:00:00/
```

---

## 4. Release, Rollback & Disaster Recovery

### Semantic Versioning
The app conforms to SemVer formats:
- **Major.Minor.Patch** (e.g. `1.0.0` initial launch, `1.0.1` hotfix patch, `1.1.0` new features update).

### Rollback Strategy
- **Backend Deployment**: Render and Railway allow immediate rollbacks via dashboard version select. Under failing states, select the prior successful build commit ID and select "Redeploy".
- **ML Model rollbacks**: ModelManager checks pickle checksums on boot; if a newly updated model file is invalid, it falls back to the heuristics backup rules automatically.

### Disaster Recovery
- **AI API Downtime**: AIOrchestrator retries failed queries with exponential backoffs and defaults to rule heuristics summaries to keep chat panels operational.
- **Database Outage**: Client applications serve cached summaries and logs from local Hive databases. Offlines logs sync back when connection recovers.
