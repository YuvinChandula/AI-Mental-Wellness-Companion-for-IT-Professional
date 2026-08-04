# MindSync AI – Technology Stack Specification

This document details the selected technologies, frameworks, libraries, and tools for the **MindSync AI** platform, aligned with the academic and practical requirements for Module **CMP7003 – Emerging Mobile Applications**.

---

## 1. Frontend (Mobile Application)

The frontend is built using **Flutter**, targeting Android and iOS from a single Dart codebase.

| Technology | Purpose | Version/Range |
| :--- | :--- | :--- |
| **Flutter SDK** | Cross-platform UI development framework | `^3.22.0` (Stable) |
| **Dart** | Programming language for Flutter | `^3.4.0` |
| **Material 3** | Google's latest design system standard | Included in SDK |
| **Riverpod** | Compile-safe state management & dependency injection | `flutter_riverpod: ^2.5.1` |
| **GoRouter** | Declarative routing package for navigation | `go_router: ^14.2.0` |
| **Dio** | Robust HTTP client for API communication | `dio: ^5.4.3` |
| **Hive** | Lightweight, NoSQL local database | `hive_flutter: ^1.1.0` |
| **fl_chart** | Dynamic, interactive charts for wellness analytics | `fl_chart: ^0.68.0` |
| **Google Fonts** | Custom typography | `google_fonts: ^6.2.1` |
| **Lottie** | Interactive animations | `lottie: ^3.1.2` |
| **Flutter SVG** | Render vector graphics files seamlessly | `flutter_svg: ^2.0.10` |

---

## 2. Backend API Service

The backend is built as a REST API using **FastAPI** (Python), acting as the central processing unit for ML prediction, Gemini API integration, and database orchestration support.

| Technology | Purpose | Version/Range |
| :--- | :--- | :--- |
| **Python** | High-level programming language for AI/ML and API services | `^3.11` |
| **FastAPI** | High-performance, modern web framework for building APIs | `^0.111.0` |
| **Uvicorn** | ASGI server implementation for executing FastAPI applications | `^0.30.0` |
| **Pydantic v2** | Data validation and settings management using Python type annotations | `^2.7.0` |
| **Firebase Admin SDK** | Secure verification of auth tokens and database operations | `firebase-admin: ^6.5.0` |
| **HTTPX** | Fully featured asynchronous HTTP client for calling external APIs | `^0.27.0` |
| **Loguru** | Structured and elegant logging output | `^0.7.2` |

---

## 3. Database & Cloud Infrastructure

The application utilizes **Firebase** as its primary cloud backend, combined with local storage for offline capabilities.

*   **Firebase Authentication**: Secure user management (Email/Password credentials and status verification).
*   **Cloud Firestore**: NoSQL cloud database storing structural collections (users, mood logs, activity logs, water logs, predictions, recommendations).
*   **Firebase Storage**: Secure file hosting for user profile pictures and generated PDF reports.
*   **Firebase Cloud Messaging (FCM)**: Push notification routing for behavioral nudge alerts.
*   **Hive DB (Local)**: High-speed local database storing theme configurations, offline sync queues, and caching schemas.

---

## 4. Artificial Intelligence & Machine Learning

The cognitive features of MindSync AI are powered by the **Google Gemini API** (LLM) and a custom predictive machine learning model.

*   **Google Gemini API (`gemini-1.5-flash`)**: Used for conversational wellness coaching, mood entry analysis (sentiment and stress detection), and context-aware suggestion generation.
*   **Scikit-Learn**: Machine learning library used to construct and compare burnout prediction algorithms.
*   **Random Forest Classifier**: Selected machine learning algorithm for final prediction delivery due to its robustness against overfitting on tabular metrics.
*   **Pandas & NumPy**: Tabular data processing and statistical analysis.
*   **Joblib**: Model serialization for rapid FastAPI inference loads.

---

## 5. Device Features & Hardware Access

To support context-aware recommendations, the mobile client requests runtime permissions to interface with core device sensors.

*   **Geolocator (GPS)**: Determines broad location attributes to adapt suggestions based on environmental conditions.
*   **Pedometer & Accelerometer**: Automatically processes steps taken, active minutes, and motion transitions.
*   **Connectivity Plus**: Real-time monitoring of network status to handle offline queues gracefully.

---

## 6. Testing Suite

Robust verification is integrated across layers to ensure high availability and security compliance.

*   **Flutter Test / Mocktail**: Unit testing, state verification, mock models, and widget isolation testing.
*   **Pytest**: Backend unit tests validating schemas, services, and route endpoints.
*   **FastAPI TestClient**: Integration testing representing network requests without overhead.
