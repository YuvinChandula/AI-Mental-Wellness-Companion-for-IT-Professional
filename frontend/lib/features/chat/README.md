# Module 5: AI Chat Assistant (Gemini AI Integration)

This module implements a production-ready, context-aware AI wellness assistant using the Google Gemini API REST endpoints and Cloud Firestore for conversation logging.

## Directory Structure

```
lib/features/chat/
├── data/
│   ├── datasources/
│   │   ├── chat_local_datasource.dart       # Local session & message cache in Hive
│   │   └── chat_remote_datasource.dart      # Firestore database & Gemini Dio REST client
│   ├── models/
│   │   ├── chat_message_model.dart          # Chat message mapping schema
│   │   └── chat_session_model.dart          # Chat session mapping schema
│   └── repositories/
│       └── chat_repository_impl.dart        # Repository wiring local cache with network streams
├── domain/
│   ├── entities/
│   │   ├── chat_message.dart                # Chat message parameters
│   │   └── chat_session.dart                # Chat session metadata container
│   └── repositories/
│       └── chat_repository.dart             # Repository contracts
├── presentation/
│   ├── pages/
│   │   └── chat_page.dart                   # Chat page with drawers and text inputs
│   ├── providers/
│   │   └── chat_providers.dart              # Riverpod states (Sessions, messages, typing status)
│   └── widgets/
│       ├── chat_bubble.dart                 # Message bubble with copy/share actions
│       ├── conversation_drawer.dart         # Conversational sidebar (New/Rename/Delete)
│       └── suggested_prompts_list.dart      # Suggested chip list quick prompts
└── prompt_engineering/
    └── prompt_templates.dart                # System templates & context formatters
```

---

## Gemini REST Integration Guide

### 1. Endpoint & Client
We communicate directly with the Gemini API via a REST POST call using the configured `Dio` client to avoid dependencies conflicts:
- **Model**: `gemini-1.5-flash` (Ideal for speedy responses and lower token latency).
- **Endpoint**: `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=API_KEY`
- **Headers**: `Content-Type: application/json`

### 2. API Key Safeguards
- The API key is loaded from `.env` via `dotenv.env['GEMINI_API_KEY']`. It is never hard-coded.
- **Graceful Mock Fallback**: If the key is the placeholder `mock_gemini_key_for_testing` or empty, the `ChatRemoteDataSource` catches the request and generates high-quality mock wellness guidelines dynamically (based on keywords like mood, sleep, or stress), facilitating testing and reviews out-of-the-box.

---

## Prompt Architecture & Context

### 1. System Prompt (`PromptTemplates.systemInstruction`)
Details the AI persona as **MindSync AI**—a supportive mental wellness guide for IT workers. It implements two critical guardrails:
- **Disclaimer**: Expressly states that it is not a clinical medical service and cannot diagnose conditions.
- **Crisis Keywords Interception**: Scans prompts for crisis vocabulary (e.g. suicide, self-harm). If detected, it immediately overrides generation and returns warm, structured helpline resources (Lifeline 988).

### 2. Context-Aware Injection
Before dispatching a user prompt, the `ChatPage` reads the local Riverpod states (`dashboardDataProvider`, `activitySummaryProvider`, and `weatherStateProvider`) to construct a detailed context block:
```json
User Daily Wellness Context:
- Today's Mood: 😊 Happy (Score: 4/5)
- Stress Level: 3/10
- Energy Level: 8/10
- Sleep Duration: 8.0 hours
- Hydration: 1200 ml (Goal: 2000 ml)
- Physical Exercise: 25 minutes
- Steps Walked: 6420 (Goal: 10000)
- Weather at Location: Clouds, 28.5°C
```
This data is prepended to the user's prompt so the AI can give metrics-grounded wellness advice without guessing.

---

## Firestore Schema

### 1. Conversations (`chat_sessions` Collection)
- `sessionId` (String, Doc ID)
- `userId` (String, Owner)
- `title` (String, Session summary)
- `createdAt` (Timestamp)
- `updatedAt` (Server Timestamp)

### 2. Messages (`chat_messages` Collection)
- `messageId` (String, Doc ID)
- `sessionId` (String, Target session)
- `sender` (String, `user` | `model`)
- `message` (String, Body text)
- `createdAt` (Timestamp)

---

## Security (Firestore Rules)
Rules enforce that:
- Users can only read, write, rename, or delete their own sessions (`resource.data.userId == request.auth.uid`).
- Message actions are validated against authenticated session references.

---

## Run Tests
Run test cases:
```bash
flutter test test/features/chat
```
- **Repository Tests**: Verifies cache fallback logic under remote failure.
- **Prompt Tests**: Verifies safety disclaimer presence and crisis resource guidelines.
- **Notifier Tests**: Verifies sessions list loads and active session pointers.
- **Widget Tests**: Verifies markdown parsing and prompt chip selections.
