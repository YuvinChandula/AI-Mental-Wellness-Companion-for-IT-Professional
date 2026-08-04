# Portfolio Case Study – MindSync AI

## Project Overview
IT professionals operate under high stress, leading to high burnout rates. MindSync AI is a production-grade wellness companion that combines real-time machine learning (Scikit-Learn Random Forest) with LLM orchestration (Google Gemini) to predict burnout risk, explain contributing factors using SHAP values, and suggest personalized habits.

---

## Technical Stack
- **Frontend**: Flutter, Dart, Riverpod (State Management), Hive (Local caching DB), GoRouter.
- **Backend**: Python, FastAPI, Uvicorn, Pydantic, HTTPX, Loguru.
- **ML & AI**: Scikit-Learn (Random Forest), SHAP (Explainability), Joblib, Pandas, NumPy, Gemini 1.5 Flash.
- **Infrastructure**: Firebase (Auth, Firestore, Cloud Messaging, Storage), Docker, GitHub Actions CI/CD.

---

## Architecture Highlight: Offline-First & AI Orchestration

MindSync AI uses a clean architecture with offline-first synchronization:
1. **Local cache**: User updates are written to Hive immediately.
2. **Sync Queue**: Writes are queued locally if offline.
3. **Reactive sync**: The sync engine uploads queued entries to Firestore once connectivity is restored.
4. **AI Orchestration**: Backend pipelines route requests to Gemini with exponential backoff retries and rule-based summaries as fallbacks.

---

## Key Challenges & Solutions

### Challenge 1: Alert Fatigue & Inconvenient Prompts
- **Problem**: Regular alarm loops interrupt developer focus.
- **Solution**: Built a scheduler that shifts alerts out of user quiet hours.

### Challenge 2: Unreliable AI Connections
- **Problem**: API timeouts or limits can crash report displays.
- **Solution**: The orchestrator uses exponential backoff retries and falls back to rule-based summaries if the API is unreachable.

---

## Project Impact
- **Accurate prediction**: ML models achieve 93.3% accuracy in predicting burnout risks.
- **Explainability**: SHAP explanations build trust by highlighting specific behavioral factors contributing to the risk score.
- **Resilience**: The app remains functional offline, ensuring continuous usability.
