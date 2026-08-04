# MindSync AI – Viva Presentation Slides & Script

This document details the slide-by-slide presentation deck and corresponding speaker notes for the MindSync AI academic defense.

---

## Slide 1: Title & Introduction
- **Slide Contents**:
  - **MindSync AI**: An AI-Driven Wellness Companion for IT Professionals
  - **Subtitle**: Machine learning, LLM orchestration, and offline-first mobile design
  - **Candidate**: Yuvin Chandula
  - **Supervisor**: University Board
- **Speaker Notes**:
  > "Good morning, members of the board. Today I present MindSync AI, a specialized mental wellness platform built explicitly for software developers to predict, monitor, and mitigate workplace burnout."

---

## Slide 2: The Problem
- **Slide Contents**:
  - IT sector workload pressures and prolonged screen times.
  - Absence of tools connecting behavioral patterns (sleep, steps, focus) to cognitive fatigue.
  - Alert fatigue from poorly timed wellness reminders.
- **Speaker Notes**:
  > "Software developers work under tight release pressures, leading to high burnout rates. Generic health monitors fail to connect behavioral logs to cognitive fatigue. Our system aims to bridge this gap."

---

## Slide 3: Project Aim & Objectives
- **Slide Contents**:
  - **Aim**: Build an offline-first companion predicting burnout and suggesting personalized habits.
  - **Core Objectives**:
    1. Cross-platform UI dashboard using Flutter.
    2. Async backend using FastAPI.
    3. Random Forest ML model predicting burnout levels.
    4. Gemini AI orchestrator with fault tolerance.
- **Speaker Notes**:
  > "The core aim is to create an offline-first mobile app that predicts burnout and provides personalized wellness summaries. We structured the project around four key technical objectives."

---

## Slide 4: System Architecture
- **Slide Contents**:
  - Clean Architecture & Domain-Driven Design.
  - Layered isolation: Domain, Data, Presentation.
  - Backend/Frontend separation via REST endpoints.
- **Speaker Notes**:
  > "We adopted Clean Architecture principles on both the Flutter client and the FastAPI backend. This ensures the codebase remains modular, testable, and easy to maintain."

---

## Slide 5: Machine Learning Pipeline
- **Slide Contents**:
  - Model: Random Forest Classifier (Scikit-Learn).
  - Features: sleep, working hours, mood logs, stress, active steps.
  - Explainability: SHAP values determining top burnout risk factors.
- **Speaker Notes**:
  > "For burnout predictions, we trained a Random Forest model. To make it transparent, we integrated SHAP values to explain the top three factors contributing to the user's risk score."

---

## Slide 6: AI Orchestration Layer
- **Slide Contents**:
  - Centralized Prompts Library.
  - Exponential backoff retry loops on Gemini API calls.
  - Fail-safe rules-based text summary fallbacks.
- **Speaker Notes**:
  > "The AI Orchestration layer routes prompts to Gemini. If the external API fails or hits rate limits, the orchestrator retries using exponential backoff before falling back to preconfigured local summaries."

---

## Slide 7: Offline-First Design
- **Slide Contents**:
  - Local caching via Hive databases.
  - Connection status monitoring using `connectivity_plus`.
  - Automatic background synchronization on connection recovery.
- **Speaker Notes**:
  > "MindSync AI uses an offline-first approach. All logs save instantly to local Hive boxes. The sync engine automatically uploads queued entries to Firestore once connectivity is restored."

---

## Slide 8: Security Hardening
- **Slide Contents**:
  - Firebase JWT Token validation.
  - Firestore Rules isolating user collections.
  - OWASP secure headers and in-memory rate limiting.
- **Speaker Notes**:
  > "Security is a priority. We validate Firebase ID tokens in our backend auth middleware, enforce database access isolation via Firestore rules, and protect endpoints with rate limiters."

---

## Slide 9: Evaluation Results
- **Slide Contents**:
  - Model accuracy: **93.3%**.
  - API response time: **<22ms** (with connection keep-alive).
  - Mobile cold startup: **1.1s**.
- **Speaker Notes**:
  > "Evaluation shows strong performance: our ML model achieves 93.3% accuracy, while preloaded pipelines and caches keep API latencies under 22 milliseconds."

---

## Slide 10: Future Enhancements
- **Slide Contents**:
  - Direct wearables integration (Apple Health & Google Fit).
  - Advanced multilingual LLM wellness coaching.
  - Federated Learning for decentralized model training.
- **Speaker Notes**:
  > "Future work will focus on integrating with Apple Health and Google Fit to automate activity logging. We also plan to explore Federated Learning for decentralized training."

---

## Slide 11: Conclusion
- **Slide Contents**:
  - MindSync AI successfully bridges mobile diagnostics, ML, and LLMs.
  - Extensible, secure, and production-ready.
  - Open for questions.
- **Speaker Notes**:
  > "In conclusion, MindSync AI is a production-ready mental wellness companion for software developers. Thank you for your time. I am now open to your questions."
