# MindSync AI – AI Mental Wellness Companion for IT Professionals

MindSync AI is a production-grade wellness application designed specifically for software engineers and IT professionals. It leverages state-of-the-art Random Forest machine learning models and Gemini LLM orchestration to predict developer burnout risks, supply context-aware habit suggestions, track moods, support AI chat coaching, and compile visual telemetry.

---

## 1. Project Directory Structure

```
MindSync AI/
├── backend/                        # FastAPI microservices & ML pipelines
│   ├── app/
│   │   ├── main.py                 # App bootstrap
│   │   ├── api/endpoints/          # API routers (health, predict, recommendations, analytics, notifications)
│   │   ├── core/                   # Security, configs, and Firebase SDK setups
│   │   ├── middleware/             # Rate limiters, request loggers, security headers
│   │   ├── ml/                     # ML training, pipelines, and SHAP trees
│   │   ├── services/               # Caches, models loaders, and schedulers
│   │   └── utils/                  # Unified JSON response models & injection sanitizers
│   │
│   └── tests/                      # Python pytest automated testing suites
│
├── frontend/                       # Flutter client mobile codebase
│   ├── lib/
│   │   ├── core/                   # Routing, themes, network, storage, and sync engines
│   │   ├── features/               # Auth, mood, chat, recommendations, reports, settings
│   │   └── shared/                 # Shared widgets & providers
│   │
│   └── test/                       # Dart unit and widget tests
│
└── docs/                           # Software architecture, APIs, and schemas guides
```

---

## 2. Technical Documentation Index

Detailed architectural descriptions are organized inside the [Documentation Index](file:///c:/Users/YUVIN/OneDrive/Documents/AI-Mental-Wellness-Companion-for-IT-Professionals/docs/documentation_index.md):

- **Architectures**: [Software Architecture](file:///c:/Users/YUVIN/OneDrive/Documents/AI-Mental-Wellness-Companion-for-IT-Professionals/docs/software_architecture_document.md) | [Database Schemas](file:///c:/Users/YUVIN/OneDrive/Documents/AI-Mental-Wellness-Companion-for-IT-Professionals/docs/database_schema.md) | [UML Diagrams](file:///c:/Users/YUVIN/OneDrive/Documents/AI-Mental-Wellness-Companion-for-IT-Professionals/docs/architecture.md)
- **API Spec**: [REST API Mappings](file:///c:/Users/YUVIN/OneDrive/Documents/AI-Mental-Wellness-Companion-for-IT-Professionals/docs/api_design.md)
- **ML & AI**: [ML Prediction Pipelines](file:///c:/Users/YUVIN/OneDrive/Documents/AI-Mental-Wellness-Companion-for-IT-Professionals/docs/ml_pipeline.md) | [MLOps Orchestrations](file:///c:/Users/YUVIN/OneDrive/Documents/AI-Mental-Wellness-Companion-for-IT-Professionals/docs/mlops_and_ai_orchestration.md)
- **Security & Quality**: [Security Auditing Checklist](file:///c:/Users/YUVIN/OneDrive/Documents/AI-Mental-Wellness-Companion-for-IT-Professionals/docs/security_audit_report.md) | [QA & Test Configurations](file:///c:/Users/YUVIN/OneDrive/Documents/AI-Mental-Wellness-Companion-for-IT-Professionals/docs/qa_report_and_tests.md) | [Performance Optimization](file:///c:/Users/YUVIN/OneDrive/Documents/AI-Mental-Wellness-Companion-for-IT-Professionals/docs/performance_and_scalability.md)
- **Operations**: [DevOps Deployment Guide](file:///c:/Users/YUVIN/OneDrive/Documents/AI-Mental-Wellness-Companion-for-IT-Professionals/docs/deployment_and_devops_guide.md) | [Developer Onboarding Manual](file:///c:/Users/YUVIN/OneDrive/Documents/AI-Mental-Wellness-Companion-for-IT-Professionals/docs/developer_onboarding_manual.md) | [Application Run Guide](file:///c:/Users/YUVIN/OneDrive/Documents/AI-Mental-Wellness-Companion-for-IT-Professionals/docs/application_run_guide.md)

---

## 3. Running & Testing

### A. Python Backend
1. Install dependencies:
   ```bash
   pip install -r backend/requirements.txt
   ```
2. Train ML models:
   ```bash
   python backend/app/ml/train.py
   ```
3. Start local FastAPI server:
   ```bash
   python backend/app/main.py
   ```
4. Execute Pytest suite:
   ```bash
   python -m pytest backend/tests
   ```

### B. Flutter Frontend
1. Fetch packages:
   ```bash
   flutter pub get
   ```
2. Build files:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. Run mobile application:
   ```bash
   flutter run
   ```
4. Run testing suite:
   ```bash
   flutter test
   ```
