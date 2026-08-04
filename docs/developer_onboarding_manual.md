# MindSync AI – Developer Onboarding & Maintenance Manual

This manual provides instructions for configuring, running, maintaining, and extending the MindSync AI platform.

---

## 1. Project Setup & Running Locally

### A. Python Backend (FastAPI)
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Define environment variables in `.env` based on `.env.example`.
5. Pre-train the synthetic ML models:
   ```bash
   python app/ml/train.py
   ```
6. Start the local server:
   ```bash
   python app/main.py
   ```

### B. Flutter Client (Mobile App)
1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Fetch Dart packages:
   ```bash
   flutter pub get
   ```
3. Run project build generation:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. Run mobile app in developer emulator:
   ```bash
   flutter run
   ```

---

## 2. Coding Standards & Git Workflow

### Coding Principles
- **SOLID**: Keep class scopes singular. Decompose large widgets into reusable widgets (`lib/core/widgets`).
- **DRY**: Shared providers manage authentication, navigation, and connection states.
- **KISS**: Limit complex third-party wrappers; utilize native Dart streams and async libraries.

### Git Branching & Versioning
- **Branch Strategy**:
  - `main`: Production-ready release code.
  - `dev`: Primary features aggregation branch.
  - `feature/<name>`: Topic feature development.
- **Semantic Versioning**:
  - Format: `Major.Minor.Patch` (e.g. `1.0.0` initial release, `1.1.0` feature addition, `1.0.1` defect hotfix).

---

## 3. Maintenance & Model Upgrades

### Updating ML Model Pipelines
To retrain and hot-swap models without downtime:
1. Run `python app/ml/train.py` with the updated datasets.
2. Verify the new model accuracy score outputs.
3. Compute the file's SHA-256 checksum and copy the pickle file to `app/ml/models/burnout_model.pkl`.
4. Deploy the update. The `ModelManager` checks the checksum on boot. If mismatched or corrupted, it falls back to default rule parameters.

### Upgrading Dependencies
- **FastAPI**: Execute `pip list --outdated` to review packages. Update `requirements.txt` and rebuild Docker containers.
- **Flutter**: Execute `flutter pub outdated`. Update versions inside `pubspec.yaml` and run tests.

---

## 4. Limitations & Future Integrations Roadmap

### Current Limitations
- **In-Memory Rate Limiting**: The backend rate-limiter resets records if the server container restarts. Recommend implementing a shared Redis instance for multi-container deployments.
- **Rules Fallbacks**: If Gemini limits are hit, LLM summary lists return default backup messages.

### Future Work: Wearable Device Integrations
1. **Apple Health (iOS)**:
   - Integrate `health` pub package.
   - Query user step counts and sleep duration permissions in `features/wearables/data/datasources/apple_health_datasource.dart`.
2. **Google Fit (Android)**:
   - Query Google Fit API endpoints.
   - Map logs to the `activitySummaryProvider` to auto-log steps and calories.
