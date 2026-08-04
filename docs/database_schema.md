# MindSync AI – Database Schema & Data Models

This document specifies the data persistence architecture for MindSync AI, detailing Cloud Firestore collections, Hive local configurations, data model serialization requirements, and security rules.

---

## 1. Cloud Firestore Collections

MindSync AI uses **Cloud Firestore** for structured, scalable NoSQL cloud storage. Collections are defined below.

```
Firestore Root
│
├── users/ (Collection)
│   └── {userId} (Document)
│
├── mood_logs/ (Collection)
│   └── {logId} (Document)
│
├── activity_logs/ (Collection)
│   └── {logId} (Document)
│
├── chat_sessions/ (Collection)
│   └── {sessionId} (Document)
│       └── messages/ (Sub-collection)
│           └── {messageId} (Document)
│
├── recommendations/ (Collection)
│   └── {recId} (Document)
│
└── burnout_predictions/ (Collection)
    └── {predId} (Document)
```

---

## 2. Collection Schemas & Fields

### A. Collection: `users`
Stores user profile information, role classification, and system configurations.

| Field Name | Data Type | Description |
| :--- | :--- | :--- |
| `uid` | String | Unique Identifier (matches Firebase Auth UID) |
| `fullName` | String | User's full name |
| `email` | String | Account email address |
| `occupation` | String | Job title (e.g. Software Engineer, DevOps, etc.) |
| `age` | Number | User's age |
| `gender` | String | Gender identifier |
| `profileImage` | String (URL) | Link to profile avatar uploaded in Cloud Storage |
| `onboardingCompleted` | Boolean | True if user has seen onboarding carousel |
| `notificationPreferences`| Map | Map of keys (`hydration`, `break`, `sleep`, `walk`) |
| `createdAt` | Timestamp | Account creation datetime |
| `lastLogin` | Timestamp | Last authenticated session access |

*Example Document Schema:*
```json
{
  "uid": "usr_abc123xyz",
  "fullName": "Jane Doe",
  "email": "jane.doe@techcompany.com",
  "occupation": "Software Engineer",
  "age": 28,
  "gender": "Female",
  "profileImage": "https://firebasestorage.googleapis.com/.../profile.jpg",
  "onboardingCompleted": true,
  "notificationPreferences": {
    "hydration": true,
    "break": true,
    "sleep": true,
    "walk": false
  },
  "createdAt": "2026-07-21T09:46:49Z",
  "lastLogin": "2026-07-21T15:18:07Z"
}
```

---

### B. Collection: `mood_logs`
Stores journals, moods, self-reported anxiety, energy, and stress metrics.

| Field Name | Data Type | Description |
| :--- | :--- | :--- |
| `id` | String | Unique entry log ID |
| `userId` | String | Associated User's UID |
| `mood` | String | Mood tag (`Very Happy`, `Happy`, `Neutral`, `Sad`, `Very Sad`, `Angry`, `Anxious`, `Exhausted`) |
| `moodScore` | Number | Numeric assessment from `1` (lowest) to `10` (highest) |
| `stressLevel` | Number | Reported stress numeric metric: `1` to `10` |
| `energyLevel` | Number | Reported energy level: `1` to `10` |
| `journal` | String | User written journal entry notes |
| `tags` | Array (String) | List of contextual tags (`deadline`, `family`, `meeting`, etc.) |
| `createdAt` | Timestamp | Entry creation timestamp |
| `updatedAt` | Timestamp | Last modification timestamp |

---

### C. Collection: `activity_logs`
Aggregates health telemetry inputs (steps, sleep, hydration) gathered from sensors or custom settings inputs.

| Field Name | Data Type | Description |
| :--- | :--- | :--- |
| `id` | String | Unique activity log ID |
| `userId` | String | Associated User's UID |
| `date` | String | Date string formatted as `YYYY-MM-DD` |
| `steps` | Number | Pedometer cumulative step counts |
| `sleepHours` | Number | Hours of sleep tracked |
| `sleepQuality` | Number | Sleep rating: `1` to `10` |
| `waterGlasses` | Number | Water intake tracked in glasses (250ml units) |
| `exerciseMinutes`| Number | Total dynamic exercise duration in minutes |
| `timestamp` | Timestamp | Sync event creation timestamp |

---

### D. Collection: `chat_sessions` & Sub-collection: `messages`
Maintains conversational memory context logs for the Gemini AI wellness companion.

*   `chat_sessions` Document: `{ "sessionId": "session_001", "userId": "usr_abc123", "title": "Coping with deadlines", "createdAt": "Timestamp" }`
*   `chat_sessions/session_001/messages/` Document:
    ```json
    {
      "messageId": "msg_98765",
      "sender": "user",
      "message": "I feel extremely overwhelmed by our deployment cycle.",
      "createdAt": "Timestamp"
    }
    ```

---

### E. Collection: `burnout_predictions`
Houses the predictions returned by the custom machine learning model.

| Field Name | Data Type | Description |
| :--- | :--- | :--- |
| `id` | String | Prediction document ID |
| `userId` | String | Associated User's UID |
| `burnoutRisk` | String | Prediction category: `Low`, `Medium`, or `High` |
| `confidence` | Number | Machine Learning model prediction probability (0.0 to 1.0) |
| `riskScore` | Number | Numeric assessment from `0` to `100` |
| `importantFactors`| Array (String) | Features leading to risk (e.g. `Low sleep`, `Overtime`) |
| `createdAt` | Timestamp | Execution output timestamp |

---

### F. Collection: `recommendations`
Stores context-aware habits suggestions generated by the Recommendation Engine (Gemini AI + Rule Engine).

| Field Name | Data Type | Description |
| :--- | :--- | :--- |
| `id` | String | Recommendation ID |
| `userId` | String | Associated User's UID |
| `title` | String | Headline wellness suggestion |
| `description` | String | Actionable habit instructions |
| `reason` | String | Why this recommendation was output (Explainable AI) |
| `category` | String | Classification: `Stress`, `Sleep`, `Hydration`, `Activity`, `Breaks` |
| `priority` | String | Category weight: `Low`, `Medium`, `High`, `Critical` |
| `completed` | Boolean | True if user marks it done |
| `feedback` | String | User review: `liked`, `disliked`, or `none` |
| `timestamp` | Timestamp | Entry creation timestamp |

---

## 3. Local Hive Database (Offline Storage)

MindSync AI uses **Hive** for fast, local object storage on the mobile client. Local storage boxes are separated as follows:

1.  **`auth_box`**: Stores the JWT token, refresh tokens, and user profile data to support persistent login.
2.  **`settings_box`**: Stores app state details (Dark/Light mode selection, notification settings, language preference).
3.  **`mood_sync_queue`**: Holds unsynced offline mood entries to push to the API once connection status updates to online.
4.  **`cached_data_box`**: Caches the last dashboard JSON structure and weather forecasts to enable offline opening capability.
