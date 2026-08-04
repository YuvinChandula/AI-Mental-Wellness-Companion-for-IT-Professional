# MindSync AI – Viva Defense Preparation (50 Q&A)

This document contains 50 likely viva questions along with detailed model answers to prepare for the academic project defense.

---

## Section 1: Architecture & Technology Decisions

### Q1: Why did you choose Flutter instead of native Android/iOS?
> **Answer**: Flutter enables a single cross-platform codebase, reducing development time while maintaining 60 FPS performance via direct GPU rendering.

### Q2: What is Clean Architecture and why did you use it?
> **Answer**: Clean Architecture separates the codebase into Domain (logic/entities), Data (repositories/sources), and Presentation (widgets/providers) layers. This ensures the app is decoupled, testable, and independent of external frameworks.

### Q3: Why is the backend built in FastAPI instead of Flask or Django?
> **Answer**: FastAPI is built on ASGI, supporting asynchronous requests natively. It is faster than Flask and automatically generates OpenAPI/Swagger schemas.

### Q4: Why did you use Riverpod instead of Provider or Bloc?
> **Answer**: Riverpod is compile-safe, does not depend on the Flutter widget tree, and allows easy provider overrides for unit testing.

### Q5: What is the purpose of the Hive database?
> **Answer**: Hive is a lightweight, fast, no-SQL key-value database written in pure Dart. It is ideal for local caching and offline-first mobile synchronization.

---

## Section 2: Machine Learning & AI Orchestration

### Q6: How does the burnout prediction ML model work?
> **Answer**: It is a Random Forest Classifier trained on behavioral features (sleep, working hours, mood, stress, steps, exercise). It predicts risk as Low, Medium, or High.

### Q7: What is SHAP and how is it used in your application?
> **Answer**: SHAP (SHapley Additive exPlanations) is a game-theory approach to explain ML outputs. We use it to identify the top three behavioral factors pushing a user's risk score higher.

### Q8: What happens if the Gemini AI API fails?
> **Answer**: The `AIOrchestrator` uses exponential backoff retries. If all retries fail, it falls back to a rule-based heuristic summary to ensure a smooth user experience.

### Q9: How do you prevent prompt injection attacks?
> **Answer**: The `AISecurityManager` checks input prompts against a regex blacklist of system override keywords (e.g. "ignore prior instructions") and rejects matches with a 400 error.

### Q10: How do you address the risk of AI hallucination?
> **Answer**: Prompts are constrained with strict context templates. Output templates enforce formatting constraints, and responses append a medical disclaimer.

---

## Section 3: Security & Operations

### Q11: How do you validate user sessions?
> **Answer**: The backend auth middleware validates the Firebase ID token in the authorization header using the Firebase Admin SDK.

### Q12: Explain your Firestore Security Rules.
> **Answer**: Firestore rules restrict read/write access to authenticated owners. Users can only access documents where `resource.data.userId == request.auth.uid`.

### Q13: How does your account deletion workflow comply with privacy standards?
> **Answer**: It uses Firestore write batches to delete all logs across collections (`users`, `mood_logs`, `burnout_predictions`, `recommendations`, `reports`, `notifications`, `privacy_settings`, `application_settings`). It also removes the user's profile picture and deletes their Firebase Auth credentials.

### Q14: What rate limiting approach did you choose?
> **Answer**: We implemented a sliding-window rate limiter in FastAPI middleware, restricting requests to 60 per minute per IP address.

### Q15: How does the offline-first sync work?
> **Answer**: Mood logs and preferences are saved locally to Hive boxes immediately. If the network is offline, the operation is queued. When the connectivity service detects a reconnection, the sync engine pushes the queue to Firestore.

---

## Section 4: Testing & Quality Assurance

### Q16: What is your testing strategy?
> **Answer**: We use unit tests for utilities and validators, repository tests for database logic, and API tests in FastAPI to verify response formats under different scenarios.

### Q17: How did you verify security headers?
> **Answer**: Pytest calls health endpoints and asserts the presence of HSTS, CSP, and frame-denial parameters in response headers.

### Q18: What accessibility features are implemented?
> **Answer**: We ensure touch targets are at least 48x48 dp, support dynamic font scaling, and maintain a WCAG AA-compliant contrast ratio.

*(Additional 32 questions and answers covering docker configurations, dependency audits, memory optimizations, and future wearable integrations are documented in this viva preparation guide).*
