# Authentication Module – Clean Architecture

This directory implements the secure **Firebase Authentication** features for **MindSync AI**.

---

## 1. Domain Layer (`domain/`)
*   **`entities/user_entity.dart`**: Business-level model containing basic profiles details (uid, fullName, email, verification flags, and timestamps).
*   **`repositories/auth_repository.dart`**: Repository interface mapping boundary contracts.
*   **`usecases/`**: Contains use case workflows: sign in, registration, email verifications, password resets, and session reloads.

---

## 2. Data Layer (`data/`)
*   **`models/user_model.dart`**: Extends `UserEntity` with JSON serialization mapping operations.
*   **`datasources/firebase_auth_datasource.dart`**: Interfaces with standard Firebase libraries and writes initial profiles to Firestore collection `users`.
*   **`repositories/auth_repository_impl.dart`**: Handles data mapping and exception validations.

---

## 3. Presentation Layer (`presentation/`)
*   **`providers/auth_provider.dart`**: Riverpod state providers implementing login execution flows and auth listeners.
*   **`pages/`**: Includes page interfaces (Splash, Onboarding, Login, Register, Forgot Password) designed matching Material 3 specifications.
