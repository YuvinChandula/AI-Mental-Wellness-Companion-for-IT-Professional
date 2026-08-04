# MindSync AI – How to Run in Demo Mode

> **Goal:** Launch the Flutter app on an Android emulator **without Firebase, backend, API keys, or network services**.  
> Demo mode shows the full UI with local mock data so you can explore screens quickly.

---

## 1. What Demo Mode Is

| Item | Demo mode |
|------|-----------|
| Firebase | Not required |
| FastAPI backend | Not required |
| Gemini / OpenWeather keys | Not required |
| Login / register | Skipped — auto demo user |
| Data | Local mock (mood, chat, reports, profile) |
| Best for | UI review, screenshots, presentations, first-time run |

Demo mode is controlled by one flag:

```dart
// File: frontend/lib/core/config/app_config.dart
static const bool demoMode = true;
```

When `demoMode` is `true`:

- Splash goes straight to the **Dashboard**
- Auth uses a local demo user (`Demo Developer`)
- Mood, Chat, Reports, Profile, Notifications use in-memory mock repositories
- Firebase is **not** initialized

---

## 2. Prerequisites

Install only these:

| Tool | Notes |
|------|--------|
| **Flutter SDK** | e.g. `C:\src\flutter` |
| **Android Studio** | With Android SDK + at least one AVD |
| **JDK** | Bundled with Android Studio (usually fine) |

You do **not** need:

- Python / backend
- Firebase project
- `.env` API keys
- Docker

### Check Flutter

```powershell
$env:Path = "C:\src\flutter\bin;" + $env:Path
flutter doctor -v
```

Ensure Android toolchain and at least one connected device/emulator can work.

---

## 3. Confirm Demo Mode Is On

Open:

```text
frontend/lib/core/config/app_config.dart
```

Make sure this line is:

```dart
static const bool demoMode = true;
```

If it was set to `false` earlier, change it back to `true` and save.

---

## 4. (Optional) Placeholder `google-services.json`

Even in demo mode, the Android Gradle Google Services plugin may still expect this file.

If build fails with `google-services.json is missing`, create:

```text
frontend/android/app/google-services.json
```

A minimal placeholder (package must match `com.mindsyncai.mindsync_ai`) is enough for demo builds. A real Firebase file is only needed when you leave demo mode.

---

## 5. Run on Android Emulator (Recommended)

### Step 5.1 – Open a terminal in the frontend folder

```powershell
cd C:\Users\odilhara\Desktop\yuvin\AI-Mental-Wellness-Companion-for-IT-Professionals\frontend
$env:Path = "C:\src\flutter\bin;" + $env:Path
```

> Important: run Flutter commands from `frontend/`, not `backend/`.

### Step 5.2 – Install packages

```powershell
flutter pub get
```

### Step 5.3 – Start an emulator

**Option A – Android Studio**

1. Open Android Studio  
2. **Tools → Device Manager**  
3. Click ▶ on **Pixel_5** or **Pixel_7_Pro**  
4. Wait until the home screen appears  

**Option B – Command line**

```powershell
flutter emulators
flutter emulators --launch Pixel_5
```

### Step 5.4 – Confirm the device is online

```powershell
flutter devices
```

You should see something like:

```text
sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64 • Android ...
```

If it shows **offline**:

```powershell
& "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" kill-server
& "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" start-server
adb devices
```

### Step 5.5 – Launch the app

```powershell
flutter run -d emulator-5554
```

First build can take several minutes. After that, hot reload is fast.

### Step 5.6 – What you should see

1. Splash screen (~2 seconds) – MindSync AI branding  
2. **Dashboard** with sample wellness score, charts, cards  
3. Bottom navigation:
   - Dashboard  
   - Mood  
   - AI Chat  
   - Reports  
   - Profile  

Tap through screens — all use mock data.

---

## 6. Run from Android Studio (Alternative)

1. Open the `frontend` folder in Android Studio (or open the Android module)  
2. Select the running emulator in the device dropdown  
3. Confirm `AppConfig.demoMode = true`  
4. Click **Run** (green play button)  

---

## 7. Hot Reload While Exploring UI

With `flutter run` still active in the terminal:

| Key | Action |
|-----|--------|
| `r` | Hot reload |
| `R` | Hot restart |
| `q` | Quit |

---

## 8. Quick Copy-Paste Commands (Windows)

```powershell
# 1) Go to frontend
cd C:\Users\odilhara\Desktop\yuvin\AI-Mental-Wellness-Companion-for-IT-Professionals\frontend

# 2) Flutter on PATH
$env:Path = "C:\src\flutter\bin;" + $env:Path

# 3) Ensure demo mode
# Open lib\core\config\app_config.dart → demoMode = true

# 4) Packages
flutter pub get

# 5) Emulator
flutter emulators --launch Pixel_5

# 6) Wait until device is ready, then:
flutter devices
flutter run -d emulator-5554
```

---

## 9. What Works / What Does Not in Demo Mode

### Works

- Browse all main UI screens  
- See sample mood history, chat, analytics, profile  
- Theme / layout / navigation review  
- Screenshots for demos or reports  

### Does not work (by design)

- Real Firebase login / registration  
- Real Gemini AI replies (chat returns a fixed demo message)  
- Real burnout ML predictions from backend  
- Real weather API (mock weather may still appear from dashboard mock data)  
- Push notifications to a real device token  
- Cloud sync of data across devices  

To enable the full stack later, see:

- [next_steps_firebase_backend_frontend_deployment.md](next_steps_firebase_backend_frontend_deployment.md)  
- [application_run_guide.md](application_run_guide.md)  

---

## 10. Turn Demo Mode Off Later

When Firebase + backend are ready:

1. Set in `app_config.dart`:

```dart
static const bool demoMode = false;
```

2. Add real:
   - `frontend/android/app/google-services.json`
   - `frontend/.env` with `BACKEND_URL`, keys
   - Backend running on port 8000

3. Ensure `main.dart` initializes Firebase again (required for production mode)

4. Rebuild:

```powershell
flutter run -d emulator-5554
```

---

## 11. Troubleshooting

| Problem | Fix |
|---------|-----|
| `No pubspec.yaml file found` | `cd frontend` before running Flutter |
| `flutter` not recognized | Add `C:\src\flutter\bin` to PATH for that terminal |
| `google-services.json is missing` | Add placeholder (or real) file under `frontend/android/app/` |
| Emulator not listed | Start AVD, wait for boot, run `flutter devices` |
| Emulator stuck / crash | Close emulator, kill `emulator.exe` / `qemu-system-x86_64.exe`, clear AVD locks, relaunch |
| Still sees login screen | Confirm `demoMode = true`, hot restart (`R`) or full re-run |
| Want a clean install | Uninstall app from emulator, then `flutter run` again |

---

## 12. Files Involved in Demo Mode

| File / folder | Role |
|---------------|------|
| `frontend/lib/core/config/app_config.dart` | `demoMode` switch |
| `frontend/lib/main.dart` | Skips Firebase init in demo |
| `frontend/lib/core/demo/` | Mock auth, mood, chat, reports, profile, notifications |
| `frontend/lib/features/.../providers/` | Swap to demo repositories when `demoMode` is true |
| `frontend/android/app/google-services.json` | May still be needed for Gradle build |

---

> **Summary:** Set `demoMode = true`, open `frontend/`, start Pixel emulator, run `flutter run`. No Firebase or backend needed to explore the app UI.
