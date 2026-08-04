# MindSync AI – Application Run Guide

> **Complete step-by-step guide for setting up and running the MindSync AI Mental Wellness Companion on your local development machine.**

---

## Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Clone the Repository](#2-clone-the-repository)
3. [Backend Setup (FastAPI)](#3-backend-setup-fastapi)
4. [Firebase Configuration](#4-firebase-configuration)
5. [Frontend Setup (Flutter)](#5-frontend-setup-flutter)
6. [Running on Android Emulator (Android Studio)](#6-running-on-android-emulator-android-studio)
7. [Running on Physical Android Device](#7-running-on-physical-android-device)
8. [Running on Web (Chrome)](#8-running-on-web-chrome)
9. [Running Tests](#9-running-tests)
10. [Docker Deployment (Backend)](#10-docker-deployment-backend)
11. [Troubleshooting](#11-troubleshooting)

---

## 1. Prerequisites

Ensure the following tools are installed on your system before proceeding.

### Required Software

| Tool               | Minimum Version | Download Link                                                     |
| ------------------ | --------------- | ----------------------------------------------------------------- |
| **Flutter SDK**    | 3.44.x          | https://docs.flutter.dev/get-started/install                      |
| **Dart SDK**       | 3.12.x          | Bundled with Flutter                                              |
| **Android Studio** | Latest          | https://developer.android.com/studio                              |
| **Python**         | 3.12+           | https://www.python.org/downloads/                                 |
| **Git**            | Latest          | https://git-scm.com/downloads                                    |
| **Node.js** (opt.) | 18+             | https://nodejs.org/ (only if using Firebase CLI)                  |

### Environment Variables & API Keys

You will need the following API keys:

| Key                      | Provider                           | Where to Get                                |
| ------------------------ | ---------------------------------- | ------------------------------------------- |
| **Gemini API Key**       | Google AI Studio                   | https://aistudio.google.com                 |
| **OpenWeather API Key**  | OpenWeatherMap                     | https://openweathermap.org/api              |
| **Firebase Credentials** | Google Firebase Console            | https://console.firebase.google.com         |

### Verify Flutter Installation

Open a terminal and run:

```bash
flutter doctor -v
```

Ensure you see checkmarks (`✓`) for **Flutter**, **Android toolchain**, and **Connected devices**. Fix any issues reported before continuing.

---

## 2. Clone the Repository

```bash
git clone https://github.com/YuvinChandula/AI-Mental-Wellness-Companion-for-IT-Professionals.git
cd AI-Mental-Wellness-Companion-for-IT-Professionals
```

---

## 3. Backend Setup (FastAPI)

### Step 3.1 – Navigate to the Backend Directory

```bash
cd backend
```

### Step 3.2 – Create a Python Virtual Environment

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# macOS / Linux
python3 -m venv venv
source venv/bin/activate
```

### Step 3.3 – Install Dependencies

```bash
pip install -r requirements.txt
```

This installs: FastAPI, Uvicorn, Scikit-learn, Pandas, NumPy, SHAP, Firebase Admin SDK, Loguru, and all other dependencies.

### Step 3.4 – Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env       # macOS/Linux
copy .env.example .env     # Windows
```

Edit the `.env` file and fill in the required values:

```dotenv
PROJECT_NAME="MindSync AI Wellness Companion"
VERSION="1.0.0"
ENV="development"

ALLOWED_ORIGINS="*"
FIREBASE_CREDENTIALS_PATH="firebase-credentials.json"
GEMINI_API_KEY="YOUR_GEMINI_API_KEY_HERE"
RATE_LIMIT_PER_MINUTE=60
SECURE_HEADERS_ENABLED=true
```

### Step 3.5 – Place Firebase Credentials

Download your Firebase Admin SDK service account JSON from the Firebase Console:

1. Go to **Firebase Console** → Your Project → **Project Settings** → **Service Accounts**
2. Click **Generate new private key**
3. Save the downloaded JSON file as `firebase-credentials.json` in the `backend/` directory

### Step 3.6 – Train ML Models (First Time Only)

```bash
python app/ml/train.py
```

This trains the Random Forest burnout prediction model and saves artifacts to `app/ml/models/`.

### Step 3.7 – Start the Backend Server

```bash
python app/main.py
```

Or, using Uvicorn directly:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

✅ **Verify**: Open http://localhost:8000/health in a browser. You should see a health check JSON response.

📝 **Note**: The backend runs on **port 8000** by default. Keep this terminal running while working with the frontend.

---

## 4. Firebase Configuration

### Step 4.1 – Create a Firebase Project

1. Go to https://console.firebase.google.com
2. Click **Add Project** and follow the wizard
3. Enable **Google Analytics** if desired

### Step 4.2 – Enable Required Firebase Services

Enable the following services in the Firebase Console:

- **Authentication** → Enable **Email/Password** sign-in provider
- **Cloud Firestore** → Create database in **test mode** (for development)
- **Cloud Storage** → Set up default bucket
- **Cloud Messaging** → For push notifications

### Step 4.3 – Register Android App in Firebase

1. In Firebase Console → **Project Settings** → **Add App** → Select **Android**
2. Enter the Android package name: `com.example.mindsync_ai` (or your custom package name)
3. Download the `google-services.json` file
4. Place it in: `frontend/android/app/google-services.json`

### Step 4.4 – Deploy Firestore Security Rules

```bash
# From the project root
firebase deploy --only firestore:rules
```

Or manually copy the rules from `firebase/firestore.rules` into the Firebase Console **Firestore → Rules** tab.

---

## 5. Frontend Setup (Flutter)

### Step 5.1 – Navigate to the Frontend Directory

```bash
cd frontend
```

### Step 5.2 – Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env       # macOS/Linux
copy .env.example .env     # Windows
```

Edit the `.env` file:

```dotenv
# For Android Emulator → use 10.0.2.2 (maps to host machine's localhost)
BACKEND_URL=http://10.0.2.2:8000

# For Physical Device → use your computer's local IP (e.g., 192.168.x.x)
# BACKEND_URL=http://192.168.1.100:8000

GEMINI_API_KEY=your_gemini_api_key_here
OPENWEATHER_API_KEY=your_openweather_api_key_here
```

> ⚠️ **Important**: For Android Emulator, use `http://10.0.2.2:8000` as the backend URL. The emulator maps `10.0.2.2` to the host machine's `localhost`.

### Step 5.3 – Install Flutter Dependencies

```bash
flutter pub get
```

### Step 5.4 – Run Code Generation (Build Runner)

This project uses `freezed`, `json_serializable`, and `riverpod_annotation` for code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Step 5.5 – Verify Project Setup

```bash
flutter analyze
```

Resolve any reported issues before proceeding.

---

## 6. Running on Android Emulator (Android Studio)

### Step 6.1 – Open Android Studio & Create a Virtual Device

1. Open **Android Studio**
2. Go to **Tools** → **Device Manager** (or **AVD Manager**)
3. Click **Create Virtual Device**
4. Select a device profile (recommended: **Pixel 7** or **Pixel 8**)
5. Select a system image:
   - Recommended: **API 34 (Android 14)** or higher
   - Download the image if not already installed
6. Click **Finish** to create the AVD

### Step 6.2 – Launch the Emulator

**Option A – From Android Studio:**
- In the Device Manager, click the **Play** (▶️) button next to your virtual device

**Option B – From the Command Line:**

```bash
# List available emulators
flutter emulators

# Launch a specific emulator
flutter emulators --launch Pixel_7
```

**Option C – Direct Emulator Launch (Windows):**

```powershell
& "$env:LOCALAPPDATA\Android\sdk\emulator\emulator.exe" -avd Pixel_7
```

### Step 6.3 – Verify the Emulator is Connected

Wait for the emulator to fully boot, then run:

```bash
flutter devices
```

You should see output similar to:

```
Found 4 connected devices:
  sdk gphone16k x86 64 (mobile) • emulator-5554 • android-x64 • Android 17 (API 37) (emulator)
  Windows (desktop)             • windows       • windows-x64 • Microsoft Windows
  Chrome (web)                  • chrome        • web-javascript
  Edge (web)                    • edge          • web-javascript
```

### Step 6.4 – Ensure the Backend is Running

Before running the Flutter app, make sure the backend server is running on port 8000 (see [Step 3.7](#step-37--start-the-backend-server)).

### Step 6.5 – Run the Flutter App on the Emulator

```bash
# Auto-selects the mobile device
flutter run

# Or target a specific device
flutter run -d emulator-5554
```

### Step 6.6 – First Launch Expectations

- The first build takes **3–5 minutes** (Gradle download + build)
- Subsequent hot reloads are near-instant
- The app loads the `.env` configuration and initializes Hive local storage
- Firebase services connect using `google-services.json`

### Step 6.7 – Hot Reload & Hot Restart

While the app is running:

| Key | Action                                        |
| --- | --------------------------------------------- |
| `r` | **Hot Reload** – applies code changes instantly |
| `R` | **Hot Restart** – full app restart              |
| `q` | **Quit** – stops the app                        |

---

## 7. Running on Physical Android Device

### Step 7.1 – Enable Developer Options

1. On your Android device, go to **Settings** → **About Phone**
2. Tap **Build Number** 7 times to unlock Developer Options
3. Go to **Settings** → **Developer Options**
4. Enable **USB Debugging**

### Step 7.2 – Connect via USB

1. Connect the device to your PC via USB cable
2. Accept the debugging authorization prompt on the device
3. Verify connection:

```bash
flutter devices
```

### Step 7.3 – Update the Backend URL

Edit `frontend/.env` and change `BACKEND_URL` to your PC's local IP:

```dotenv
BACKEND_URL=http://192.168.x.x:8000
```

Find your IP with:

```bash
# Windows
ipconfig

# macOS/Linux
ifconfig
```

### Step 7.4 – Run the App

```bash
flutter run -d <device-id>
```

---

## 8. Running on Web (Chrome)

```bash
flutter run -d chrome
```

> 📝 **Note**: Some features like push notifications, sensors, and pedometer are not available on web.

---

## 9. Running Tests

### Backend Tests (Python)

```bash
cd backend
python -m pytest tests/ -v
```

### Frontend Tests (Flutter/Dart)

```bash
cd frontend
flutter test
```

### Run Tests with Coverage

```bash
# Backend
python -m pytest tests/ --cov=app --cov-report=html

# Frontend
flutter test --coverage
```

---

## 10. Docker Deployment (Backend)

### Using Docker Compose (Recommended)

```bash
cd backend
docker-compose up --build
```

### Using Docker Directly

```bash
cd backend
docker build -t mindsync-backend .
docker run -p 8000:8000 \
  -e ENV=development \
  -e GEMINI_API_KEY=your_key_here \
  -v $(pwd)/firebase-credentials.json:/workspace/firebase-credentials.json \
  mindsync-backend
```

The backend will be available at http://localhost:8000.

---

## 11. Troubleshooting

### Common Issues & Solutions

#### ❌ `flutter doctor` shows Android toolchain issues

```bash
# Install missing command-line tools
# Open Android Studio → Settings → SDK Manager → SDK Tools
# Check "Android SDK Command-line Tools" and click Apply

# Accept licenses
flutter doctor --android-licenses
```

#### ❌ Emulator not detected by `flutter devices`

```bash
# Ensure emulator is fully booted
adb devices

# If the emulator shows as "offline", restart ADB
adb kill-server
adb start-server
```

#### ❌ `adb server is out of date` errors

This happens when multiple ADB versions conflict (Android Studio vs SDK). Fix:

```bash
# Kill all ADB instances
adb kill-server

# Use the SDK's ADB directly
& "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" devices
```

#### ❌ Backend connection refused from emulator

- Ensure the backend is running on port 8000
- Use `http://10.0.2.2:8000` in the frontend `.env` (not `localhost`)
- Check firewall is not blocking port 8000

#### ❌ Firebase initialization errors

- Verify `google-services.json` is in `frontend/android/app/`
- Verify `firebase-credentials.json` is in `backend/`
- Ensure Firebase project services (Auth, Firestore, Storage) are enabled

#### ❌ `flutter pub get` fails

```bash
# Clean and retry
flutter clean
flutter pub cache repair
flutter pub get
```

#### ❌ Build Runner code generation errors

```bash
# Clean generated files and rebuild
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

#### ❌ Gradle build failures (first run)

```bash
# Ensure JAVA_HOME is set correctly
# Android Studio bundles JDK, use it:
# Windows: Set JAVA_HOME to Android Studio's JBR path
# Usually: C:\Program Files\Android\Android Studio\jbr

# Clean Gradle cache
cd frontend/android
./gradlew clean        # macOS/Linux
gradlew.bat clean      # Windows
```

#### ❌ ML model not found at startup

```bash
# Train the models first
cd backend
python app/ml/train.py
```

---

## Quick Start Summary

For those who want the fastest path to running the app:

```bash
# 1. Clone
git clone https://github.com/YuvinChandula/AI-Mental-Wellness-Companion-for-IT-Professionals.git
cd AI-Mental-Wellness-Companion-for-IT-Professionals

# 2. Backend
cd backend
python -m venv venv && venv\Scripts\activate   # Windows
pip install -r requirements.txt
copy .env.example .env                         # Edit with your API keys
python app/ml/train.py                         # Train ML models
python app/main.py                             # Start server (keep running)

# 3. Frontend (new terminal)
cd frontend
copy .env.example .env                         # Edit with your API keys
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter emulators --launch Pixel_7             # Start emulator
flutter run -d emulator-5554                   # Launch app
```

---

> **Need help?** Check `flutter doctor -v` for environment issues, or refer to the [Developer Onboarding Manual](developer_onboarding_manual.md) for detailed architecture context.
