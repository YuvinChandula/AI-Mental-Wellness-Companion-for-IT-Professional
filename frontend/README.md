# MindSync AI – Frontend Mobile Client

This directory houses the Flutter mobile codebase.

---

## 1. Setup Instructions

### Environment Variables
1. Copy `.env.example` to `.env`.
2. Update backend endpoints and api keys:
   * **Android Emulator:** Use `http://10.0.2.2:8000` for `BACKEND_URL`.
   * **iOS Simulator:** Use `http://localhost:8000` for `BACKEND_URL`.

### Dependencies & Execution
1. Install Flutter (v3.22.0+).
2. Fetch package dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

---

## 2. Directory Layout Architecture

*   **`lib/core/`**: Central theme specifications, routing mechanisms, networks configuration, error models, and generic utility classes.
*   **`lib/features/`**: Feature modules structured following domain-driven design principles.
*   **`lib/shared/`**: Global reusable UI widgets, configurations, and state provider containers.
