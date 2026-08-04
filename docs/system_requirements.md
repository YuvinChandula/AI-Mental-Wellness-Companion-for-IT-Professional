# MindSync AI – System Requirements Specification (SRS)

This Software Requirements Specification document details the functional, non-functional, and user scope specifications for MindSync AI.

---

## 1. Project Scope & Target Users

MindSync AI is designed to combat high workloads, stress, and burnout among IT professionals (Software Engineers, Data Scientists, DevOps Engineers, QA Engineers, System Administrators, UI/UX Designers) and university students in computing.

---

## 2. Functional Requirements

### A. User Management (Authentication)
*   **FR-1.1:** Users must be able to register an account using Email and Password.
*   **FR-1.2:** System must validate credentials and prompt verified email login flows.
*   **FR-1.3:** Users must be able to reset forgotten passwords securely.
*   **FR-1.4:** Users must be able to update profile data (fullName, age, gender, occupation).

### B. Mood & Wellness Logger
*   **FR-2.1:** Users must be able to create one mood log entry per calendar day.
*   **FR-2.2:** Logger must collect mood classification, stress/energy level metrics (1-10), and optional journal descriptions.
*   **FR-2.3:** Users must be able to view, edit, or delete historical journal entries.

### C. Predictive Burnout ML Service
*   **FR-3.1:** System must process metrics (sleep, stress, activity, water, work hours) and predict burnout risk (`Low`, `Medium`, or `High`).
*   **FR-3.2:** System must isolate key contributing factors using SHAP values.
*   **FR-3.3:** Prediction updates must run automatically upon mood log submission.

### D. Gemini AI Conversational Assistant
*   **FR-4.1:** Users must be able to ask wellness queries and receive streaming or fast AI answers.
*   **FR-4.2:** Assistant must load user history (mood history, sleep quality) as context for recommendations.
*   **FR-4.3:** System must enforce medical disclaimers and route crisis flags safely.

### E. Smart Habits Recommendation Engine
*   **FR-5.1:** Engine must automatically generate context-aware suggestions (Hydration, Break, Walk, Sleep, Exercise) based on time, weather conditions, activity levels, and prediction status.
*   **FR-5.2:** Users must be able to give feedback (like/dislike) on suggestions.

### F. Reports & Analytics Visualization
*   **FR-6.1:** System must display daily wellness summaries, weekly reports, and monthly trend graphs.
*   **FR-6.2:** System must provide options to export wellness reports as PDF or CSV files.

---

## 3. Non-Functional Requirements

### A. Security & Compliance
*   **NFR-1.1 (Data Transport):** All API communications must enforce HTTPS with SSL/TLS protocols.
*   **NFR-1.2 (Access Rule):** Cloud Firestore security rules must restrict data reads/writes strictly to verified document owners (`auth.uid == request.resource.data.userId`).
*   **NFR-1.3 (Secret Management):** API keys (Gemini, OpenWeather) must reside in environment variables and never be committed to git.

### B. Performance & Availability
*   **NFR-2.1 (API Latency):** Tabular ML inference must resolve in under 100 milliseconds.
*   **NFR-2.2 (Offline Mode):** Local database boxes must permit offline mood entry queues, syncing to cloud database systems immediately upon reconnection.
*   **NFR-2.3 (Battery Consumption):** Background pedometer sensor hooks must employ efficient sleeping threads to prevent device battery drain.
