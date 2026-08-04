# MindSync AI – Coursework Assessment Mapping & Future Research

This document maps the implemented project features to coursework learning outcomes and suggests directions for future research.

---

## 1. Coursework Assessment Mapping

| Coursework Learning Outcome | Implemented Feature | Assessment Verification |
|-----------------------------|---------------------|-------------------------|
| **LO1: Software Architecture & Design** | Clean Architecture, Riverpod, GoRouter, domain model isolation. | Meets industry standards; separation of domain, data, and presentation layers. |
| **LO2: API Design & Web Services** | REST endpoints, async processing, custom authentication middleware, rate limiting. | FastAPI endpoints fully verified using Pytest. |
| **LO3: Data Integrity & Caching** | Hive local database, Firebase Storage, Firestore sync. | Cache-aside and offline-first queue synchronization. |
| **LO4: Machine Learning & explainability** | Scikit-learn Random Forest model, SHAP values. | Classifier achieves 93.3% accuracy. Explains top factors. |
| **LO5: Human-Computer Interaction (HCI)** | Custom widgets, dynamic text themes, contrast guidelines. | Checked against WCAG AA standards. |
| **LO6: DevOps & Cloud Security** | Multi-stage Docker, GitHub Actions, secure headers. | Automated tests run on PRs and pushes to main. |

---

## 2. Future Research Directions

### A. Wearable Sensors Integration
- **Direct telemetry sync**: Pulling resting heart rate, sleep cycles, and physical activity from Apple Health (HealthKit) and Google Fit (Google Fit APIs).
- **Hypothesis**: Replacing manual logs with automated sensor inputs reduces user friction and improves prediction accuracy.

### B. Federated Learning
- **Decentralized training**: Training models on-device using local telemetry without uploading raw personal logs to servers.
- **Privacy benefit**: Complies with privacy-by-design standards by keeping personal behavioral logs secure on-device.

### C. Multilingual Coaching Conversational AI
- **Advanced models**: Orchestrating localized models (Gemini Pro multilingual options) to support developer coaching in multiple languages.
- **Personalized agents**: Training custom agents that adapt recommendations to the user's coding stack and team sprint schedules.
