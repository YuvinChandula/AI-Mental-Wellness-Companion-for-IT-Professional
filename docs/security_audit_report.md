# MindSync AI – Security Hardening & Audit Report

This report outlines the security posture, collection access controls, input validations, and vulnerability scans executed across the MindSync AI client and server systems.

---

## 1. Firebase Access Rules Audit

### A. Firestore Security Rules
All collections are structured to prevent cross-user data leakage.
- **Rule Verification**: Checks that `request.auth.uid` is compared against document ID or document metadata `resource.data.userId` fields.
- **Collection Coverage**:
  - `/users/{userId}`: Restricted to owner.
  - `/mood_logs/{logId}`: Requires auth; owner UID comparison enforced.
  - `/recommendations/{recId}`: Requires auth; owner UID comparison enforced.
  - `/reports/{reportId}`: Requires auth; owner UID comparison enforced.
  - `/notifications/{notifId}`: Requires auth; owner UID comparison enforced.
  - `/burnout_predictions/{predId}`: Requires auth; owner UID comparison enforced.
  - `/chat_sessions/{sessionId}` & `/chat_messages/{msgId}`: Requires auth; owner UID comparison enforced.
  - `/privacy_settings/{userId}` & `/application_settings/{userId}`: Restricted to owner.

### B. Firebase Storage Security Rules
- **Rule Verification**: Folder `/users/{userId}/` restricted so that writing and deleting files requires `request.auth.uid == userId`. Root write/read permissions are explicitly blocked.

---

## 2. API Security & OWASP Top 10

- **Broken Object Level Authorization (B1)**: Enforced via Firebase ID Token decoding matching Firestore client scopes.
- **Broken User Authentication (B2)**: Managed via Firebase Auth JWT validating token expiration and signatures.
- **Excessive Data Exposure (B3)**: Blocked via standardized response filtering (preventing database key dumps).
- **Lack of Resources & Rate Limiting (B4)**: In-memory sliding window rate limiter blocks connections exceeding 60 requests/minute/IP.
- **Security Misconfiguration (B5)**: CORS origins are restricted. Security headers (HSTS, Content Security Policy, X-Frame-Options) are active.

---

## 3. Local Storage & Cache Security

- **Local Databases (Hive)**: The application stores telemetry cache records locally. Sensitive tokens are not saved locally (managed in-memory or securely via Firebase Session handles).
- **Secure Storage Options**: Personal logs and data downloaded (exports) are written to temporary paths using `Directory.systemTemp.path`, allowing OS process sandboxing to scrub values after execution closes.

---

## 4. AI & Prompt Security

- **Prompt Injection Defense**: Sanitization module filters blacklisted injection templates (e.g. "ignore prior instructions", "system override", "jailbreak"). Attacks throw 400 Bad Request.
- **Disclaimer Enforcement**: Every LLM summary output appends the standard medical disclaimer:
  *"Disclaimer: MindSync is a wellness companion and does not replace medical advice. If you are experiencing distress, please contact a healthcare provider."*

---

## 5. Dependency Audit & Package Check

### Python Dependencies
- **Scanned packages**: `fastapi`, `pydantic`, `pyjwt`, `cryptography`, `firebase-admin`.
- **Status**: Secure. Minor warnings on minor package upgrades. Recommend running `pip audit` periodically in CI pipelines.

### Flutter Dependencies
- **Scanned packages**: `flutter_riverpod`, `go_router`, `hive`, `flutter_local_notifications`.
- **Status**: Safe. `flutter_local_notifications` has been upgraded to latest versions to address native Android permission changes.
