"""
MindSync AI - Comprehensive Documentation Generator
Generates a professional Word document (.docx) covering:
  - App Overview & Working Guide
  - Features Breakdown
  - Technical Architecture Guide
  - ML/AI Pipelines
  - API Reference
  - Database Schemas
  - Security & Testing
"""

from docx import Document
from docx.shared import Inches, Pt, RGBColor, Cm, Emu
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.enum.section import WD_ORIENT
from docx.oxml.ns import qn, nsdecls
from docx.oxml import parse_xml
import os

def set_cell_shading(cell, color_hex):
    """Set cell background color."""
    shading_elm = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{color_hex}"/>')
    cell._tc.get_or_add_tcPr().append(shading_elm)

def add_styled_table(doc, headers, rows, header_color="1E88E5"):
    """Add a professionally styled table."""
    table = doc.add_table(rows=1 + len(rows), cols=len(headers))
    table.style = 'Light Grid Accent 1'
    table.alignment = WD_TABLE_ALIGNMENT.CENTER

    # Header row
    hdr_cells = table.rows[0].cells
    for i, header in enumerate(headers):
        hdr_cells[i].text = header
        for paragraph in hdr_cells[i].paragraphs:
            paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
            for run in paragraph.runs:
                run.bold = True
                run.font.color.rgb = RGBColor(255, 255, 255)
                run.font.size = Pt(10)
        set_cell_shading(hdr_cells[i], header_color)

    # Data rows
    for row_idx, row_data in enumerate(rows):
        row_cells = table.rows[row_idx + 1].cells
        for col_idx, cell_text in enumerate(row_data):
            row_cells[col_idx].text = str(cell_text)
            for paragraph in row_cells[col_idx].paragraphs:
                for run in paragraph.runs:
                    run.font.size = Pt(9)
        if row_idx % 2 == 1:
            for cell in row_cells:
                set_cell_shading(cell, "F0F4F8")

    return table

def create_document():
    doc = Document()

    # =========================================================================
    # PAGE SETUP
    # =========================================================================
    for section in doc.sections:
        section.top_margin = Cm(2.54)
        section.bottom_margin = Cm(2.54)
        section.left_margin = Cm(2.54)
        section.right_margin = Cm(2.54)

    style = doc.styles['Normal']
    font = style.font
    font.name = 'Calibri'
    font.size = Pt(11)

    # =========================================================================
    # COVER PAGE
    # =========================================================================
    for _ in range(6):
        doc.add_paragraph()

    title = doc.add_paragraph()
    title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = title.add_run("MindSync AI")
    run.bold = True
    run.font.size = Pt(36)
    run.font.color.rgb = RGBColor(30, 136, 229)

    subtitle = doc.add_paragraph()
    subtitle.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = subtitle.add_run("AI-Driven Mental Wellness Companion\nfor IT Professionals")
    run.font.size = Pt(18)
    run.font.color.rgb = RGBColor(100, 100, 100)

    doc.add_paragraph()

    line = doc.add_paragraph()
    line.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = line.add_run("━" * 50)
    run.font.color.rgb = RGBColor(30, 136, 229)

    doc.add_paragraph()

    desc = doc.add_paragraph()
    desc.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = desc.add_run("Comprehensive Application Guide\nFeatures Documentation & Technical Reference")
    run.font.size = Pt(14)
    run.font.color.rgb = RGBColor(80, 80, 80)

    for _ in range(4):
        doc.add_paragraph()

    info_items = [
        ("Module:", "CMP7003 – Emerging Mobile Applications"),
        ("Developer:", "Yuvin Chandula"),
        ("Version:", "1.0.0"),
        ("Date:", "July 2026"),
    ]
    for label, value in info_items:
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        run = p.add_run(label + " ")
        run.bold = True
        run.font.size = Pt(11)
        run = p.add_run(value)
        run.font.size = Pt(11)

    doc.add_page_break()

    # =========================================================================
    # TABLE OF CONTENTS
    # =========================================================================
    doc.add_heading('Table of Contents', level=1)
    toc_items = [
        "1. Introduction & Project Overview",
        "2. Application Working Guide",
        "   2.1 Getting Started",
        "   2.2 User Registration & Login",
        "   2.3 Dashboard Overview",
        "   2.4 Mood Tracking & Journal",
        "   2.5 AI Wellness Coach (Gemini Chat)",
        "   2.6 Burnout Risk Prediction",
        "   2.7 Smart Recommendations",
        "   2.8 Reports & Analytics",
        "   2.9 Notifications Center",
        "   2.10 Profile & Settings",
        "   2.11 Auto Sign-Out on Inactivity",
        "3. Complete Features Catalog",
        "4. Technical Architecture Guide",
        "   4.1 System Architecture Overview",
        "   4.2 Frontend Architecture (Flutter)",
        "   4.3 Backend Architecture (FastAPI)",
        "   4.4 Database Schema (Firestore + Hive)",
        "5. Machine Learning Pipeline",
        "   5.1 Burnout Risk Prediction Model",
        "   5.2 Training Pipeline",
        "   5.3 SHAP Explainability",
        "   5.4 Hybrid Recommendation Engine",
        "6. AI Orchestration Layer",
        "   6.1 Gemini API Integration",
        "   6.2 Prompt Engineering",
        "   6.3 MLOps & Model Management",
        "7. REST API Reference",
        "8. Security Architecture",
        "9. Testing & Quality Assurance",
        "10. Deployment Guide",
        "11. Technology Stack Summary",
    ]
    for item in toc_items:
        p = doc.add_paragraph(item)
        if not item.startswith("   "):
            for run in p.runs:
                run.bold = True

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 1: INTRODUCTION
    # =========================================================================
    doc.add_heading('1. Introduction & Project Overview', level=1)

    doc.add_paragraph(
        'MindSync AI is a production-grade, AI-powered mental wellness companion application '
        'designed specifically for software engineers, DevOps professionals, system administrators, '
        'and other IT professionals who face high-stress, sedentary work environments. The application '
        'combines cutting-edge machine learning with Google Gemini AI to deliver real-time burnout '
        'risk prediction, personalized wellness recommendations, mood tracking, and conversational '
        'AI coaching.'
    )

    doc.add_heading('Problem Statement', level=2)
    doc.add_paragraph(
        'IT professionals are disproportionately affected by workplace burnout due to long screen hours, '
        'irregular sleep patterns, high-pressure deadlines, and sedentary lifestyles. Traditional wellness '
        'apps fail to address the unique behavioral patterns and stressors of the tech industry. MindSync AI '
        'bridges this gap by using domain-specific ML models trained on IT-relevant behavioral data.'
    )

    doc.add_heading('Solution', level=2)
    doc.add_paragraph(
        'MindSync AI offers a holistic approach combining:'
    )
    bullets = [
        'Random Forest ML model for burnout risk classification (Low/Medium/High)',
        'SHAP-based Explainable AI (XAI) for transparent risk factor identification',
        'Google Gemini 1.5 Flash for conversational wellness coaching',
        'Hybrid recommendation engine (Rules-based + AI-generated)',
        'Real-time weather integration for context-aware activity suggestions',
        'Offline-first architecture with automatic data synchronization',
        'Firebase Authentication, Firestore, and Cloud Storage integration',
    ]
    for b in bullets:
        doc.add_paragraph(b, style='List Bullet')

    doc.add_heading('Target Users', level=2)
    doc.add_paragraph(
        'Software Engineers, DevOps Engineers, System Administrators, QA Engineers, '
        'Data Scientists, IT Project Managers, and any technology professionals working '
        'in high-pressure, screen-intensive environments.'
    )

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 2: APPLICATION WORKING GUIDE
    # =========================================================================
    doc.add_heading('2. Application Working Guide', level=1)

    doc.add_heading('2.1 Getting Started', level=2)
    doc.add_paragraph(
        'When you first launch MindSync AI, the application performs the following initialization sequence:'
    )
    steps = [
        'Firebase services are initialized (Authentication, Firestore, Storage).',
        'Environment variables are loaded from the .env configuration.',
        'The ML burnout prediction model is pre-loaded into memory.',
        'If this is your first launch, you will see a 3-slide Onboarding Carousel introducing key features.',
        'If you have previously logged in, the app automatically navigates to the Dashboard.',
    ]
    for i, s in enumerate(steps, 1):
        doc.add_paragraph(f'{i}. {s}')

    doc.add_heading('2.2 User Registration & Login', level=2)
    doc.add_heading('Registration', level=3)
    doc.add_paragraph(
        'New users can create an account by providing their full name, email address, and a secure password. '
        'The app uses Firebase Authentication for credential management. After registration, a verification '
        'email is sent to confirm the account. A Firestore document is automatically created under the '
        '/users/{userId} collection to store the user profile.'
    )
    doc.add_heading('Login', level=3)
    doc.add_paragraph(
        'Returning users enter their email and password. The app validates credentials against Firebase Auth, '
        'retrieves a short-lived JWT ID Token, and stores it securely for subsequent API calls. A "Forgot Password" '
        'link allows users to reset their password via email.'
    )
    doc.add_heading('Authentication Security', level=3)
    doc.add_paragraph(
        'Every API request to the FastAPI backend includes an Authorization: Bearer <ID_Token> header. '
        'The backend verifies the token signature against Google\'s public JWKS certificates, ensuring '
        'that only authenticated users can access their own data.'
    )

    doc.add_heading('2.3 Dashboard Overview', level=2)
    doc.add_paragraph(
        'The Dashboard is the primary wellness hub that provides a comprehensive overview of your current health status:'
    )
    dashboard_items = [
        ('Welcome Banner', 'Personalized greeting with your name, current date, and time-of-day context.'),
        ('Weather Widget', 'Live weather data from Open-Meteo API showing temperature, conditions, humidity, and a contextual wellness nudge (e.g., "It\'s sunny outside – take a 10-minute walk").'),
        ('Wellness Score Card', 'An overall wellness score (0-100) calculated from your recent mood, sleep, steps, and exercise data.'),
        ('Burnout Risk Card', 'Real-time burnout risk level (Low/Medium/High) with risk percentage and top contributing factors.'),
        ('Daily Telemetry Cards', 'Quick-view cards showing daily steps, water intake, and sleep hours.'),
        ('Quick Actions Grid', 'Shortcut buttons for Log Mood, Ask AI Coach, and View Charts.'),
    ]
    for title, desc in dashboard_items:
        p = doc.add_paragraph()
        run = p.add_run(f'• {title}: ')
        run.bold = True
        p.add_run(desc)

    doc.add_heading('2.4 Mood Tracking & Journal', level=2)
    doc.add_paragraph(
        'The Mood Journal screen allows you to log your emotional state and daily wellness metrics. '
        'The logging process is designed to take under 15 seconds:'
    )
    mood_steps = [
        'Select your current mood from 7 options: Very Happy, Happy, Neutral, Sad, Anxious, Exhausted, or Angry.',
        'Adjust the Stress Level slider (1-10 scale, from "Calm" to "Severe").',
        'Adjust the Energy Level slider (1-10 scale, from "Exhausted" to "Vibrant").',
        'Enter optional journal notes (up to 500 characters) describing how you feel.',
        'Add context tags such as "work", "meeting", "deadline", "exercise", "social".',
        'Tap "Save Entry" to submit the log.',
    ]
    for i, s in enumerate(mood_steps, 1):
        doc.add_paragraph(f'{i}. {s}')
    doc.add_paragraph(
        'After saving, the app automatically triggers the ML burnout prediction model to recalculate '
        'your risk level based on the updated metrics. The mood calendar view shows your historical entries '
        'with color-coded indicators for each day.'
    )

    doc.add_heading('2.5 AI Wellness Coach (Gemini Chat)', level=2)
    doc.add_paragraph(
        'The AI Wellness Coach provides a conversational interface powered by Google Gemini 1.5 Flash. '
        'It acts as a virtual wellness counselor specifically trained for IT professionals.'
    )
    doc.add_heading('How It Works:', level=3)
    chat_steps = [
        'Navigate to the "AI Coach" tab from the bottom navigation bar.',
        'You\'ll see a friendly welcome message and suggested conversation starters.',
        'Type your wellness question or select from prompt chips (e.g., "Tips for screen fatigue", "Help me wind down", "Breathing exercises").',
        'The AI processes your message along with your profile context (mood history, stress levels, work patterns).',
        'Responses are delivered in markdown format with actionable steps, empathetic tone, and practical IT-specific advice.',
        'Chat history is preserved per session and can be cleared with the "Clear Chat" button.',
    ]
    for i, s in enumerate(chat_steps, 1):
        doc.add_paragraph(f'{i}. {s}')
    doc.add_paragraph(
        'Important: The AI Coach includes a standard disclaimer that it is a wellness companion and '
        'does not replace professional medical advice.'
    )

    doc.add_heading('2.6 Burnout Risk Prediction', level=2)
    doc.add_paragraph(
        'MindSync AI uses a trained Random Forest Classifier to predict your burnout risk level. '
        'The prediction is based on 9 key wellness metrics:'
    )
    add_styled_table(doc,
        ['Metric', 'Range', 'Description'],
        [
            ['Sleep Hours', '0-24 hours', 'Duration of sleep tracked'],
            ['Working Hours', '0-24 hours', 'Working time in a 24-hour period'],
            ['Mood Score', '1-10', 'Self-reported mood rating'],
            ['Stress Level', '1-10', 'Self-reported stress index'],
            ['Energy Level', '1-10', 'Self-reported energy rating'],
            ['Water Intake', '0-30 glasses', 'Daily hydration tracking'],
            ['Daily Steps', '0-100,000', 'Pedometer step count'],
            ['Exercise Minutes', '0-1440', 'Physical activity duration'],
            ['Consecutive Work Days', '0-365', 'Days worked without a full rest break'],
        ]
    )
    doc.add_paragraph()
    doc.add_paragraph(
        'The model outputs three key pieces of information:'
    )
    pred_outputs = [
        ('Risk Category', 'Low, Medium, or High burnout risk classification'),
        ('Risk Score', 'A continuous percentage (0-100%) indicating overall burnout likelihood'),
        ('Top Contributing Factors', 'The 3 most impactful metrics driving the prediction, identified by SHAP explainability analysis'),
    ]
    for title, desc in pred_outputs:
        p = doc.add_paragraph()
        run = p.add_run(f'• {title}: ')
        run.bold = True
        p.add_run(desc)

    doc.add_heading('2.7 Smart Recommendations', level=2)
    doc.add_paragraph(
        'The Hybrid Recommendation Engine combines three sources to generate personalized wellness suggestions:'
    )
    rec_sources = [
        ('Rules Engine', 'Threshold-based health rules (e.g., if sleep < 6 hours → suggest sleep routine improvements)'),
        ('ML Risk Output', 'Recommendations aligned with the predicted burnout risk category'),
        ('Gemini AI', 'Context-aware, dynamically generated suggestions using your profile, weather, and recent metrics'),
    ]
    for title, desc in rec_sources:
        p = doc.add_paragraph()
        run = p.add_run(f'• {title}: ')
        run.bold = True
        p.add_run(desc)
    doc.add_paragraph(
        'Each recommendation includes: title, description, reason, category, priority level, '
        'expected benefit, estimated time, difficulty level, and suggested follow-up action. '
        'Users can mark recommendations as completed, save them for later, or provide feedback.'
    )

    doc.add_heading('2.8 Reports & Analytics', level=2)
    doc.add_paragraph(
        'The Reports screen provides interactive visual analytics of your wellness journey:'
    )
    report_features = [
        'Time Period Filters: View trends for 7 days, 30 days, or 90 days.',
        'Mood & Stress Trend Lines: Interactive line charts plotting mood scores and stress levels over time.',
        'Sleep & Steps Bar Charts: Daily comparison bars for sleep hours and step counts.',
        'AI Insight Summary: A Gemini-generated narrative summarizing your wellness patterns for the selected period.',
        'Export Options: Download reports as PDF or CSV files for personal records or sharing with healthcare providers.',
    ]
    for f in report_features:
        doc.add_paragraph(f, style='List Bullet')

    doc.add_heading('2.9 Notifications Center', level=2)
    doc.add_paragraph(
        'MindSync AI uses Firebase Cloud Messaging (FCM) and an intelligent notification engine to deliver:'
    )
    notif_types = [
        ('Critical Alerts (High Priority)', 'High burnout risk warnings displayed as system dialog overlays.'),
        ('Daily Goal Reminders (Medium Priority)', 'Hydration reminders, break prompts, sleep nudges, and exercise encouragement.'),
        ('Achievement Updates', 'Streak completions, mood logging milestones, and wellness score improvements.'),
    ]
    for title, desc in notif_types:
        p = doc.add_paragraph()
        run = p.add_run(f'• {title}: ')
        run.bold = True
        p.add_run(desc)
    doc.add_paragraph(
        'Unread notifications show a green dot indicator. Swiping marks items as read or deletes them. '
        'Users can configure notification preferences in Settings.'
    )

    doc.add_heading('2.10 Profile & Settings', level=2)
    doc.add_heading('Profile Management', level=3)
    profile_features = [
        'View and edit full name, occupation, age, and gender.',
        'Upload or change profile avatar (stored in Firebase Storage).',
        'View account statistics: total mood logs, active days streak, account creation date.',
    ]
    for f in profile_features:
        doc.add_paragraph(f, style='List Bullet')

    doc.add_heading('Settings Controls', level=3)
    settings_features = [
        'Appearance: Toggle between Dark Mode and Light Mode.',
        'Notification Preferences: Enable/disable hydration, break, sleep, and walk reminders.',
        'Account Security: Change password, manage active sessions.',
        'Data Management: Export all data as JSON, or permanently delete account (requires password confirmation).',
        'Auto Sign-Out: Configure automatic session timeout on inactivity.',
    ]
    for f in settings_features:
        doc.add_paragraph(f, style='List Bullet')

    doc.add_heading('2.11 Auto Sign-Out on Inactivity', level=2)
    doc.add_paragraph(
        'MindSync AI includes an automatic idle sign-out system to protect user privacy when the app is left unattended:'
    )
    signout_features = [
        'When enabled, a background timer monitors user interactions (touches, scrolls, drags).',
        'If no interaction is detected for the configured duration, the app automatically signs the user out.',
        'A floating snackbar notification informs: "Signed out automatically due to inactivity."',
        'Configurable timeout durations: 1 minute (demo), 5 minutes, 15 minutes, 30 minutes, or 60 minutes.',
        'The setting persists across app reboots via Hive local storage.',
    ]
    for f in signout_features:
        doc.add_paragraph(f, style='List Bullet')

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 3: FEATURES CATALOG
    # =========================================================================
    doc.add_heading('3. Complete Features Catalog', level=1)

    add_styled_table(doc,
        ['Feature', 'Category', 'Status', 'Description'],
        [
            ['User Authentication', 'Core', '✅ Complete', 'Email/Password login, registration, email verification, forgot password'],
            ['Onboarding Carousel', 'Core', '✅ Complete', '3-slide feature introduction for new users'],
            ['Dashboard Hub', 'Core', '✅ Complete', 'Wellness score, burnout risk, weather, daily telemetry, quick actions'],
            ['Mood Journal & Calendar', 'Tracking', '✅ Complete', '7 mood types, stress/energy sliders, journal notes, context tags'],
            ['Burnout Risk Prediction', 'ML/AI', '✅ Complete', 'Random Forest model with 9-feature input and SHAP explainability'],
            ['AI Wellness Coach', 'ML/AI', '✅ Complete', 'Gemini 1.5 Flash conversational chatbot with IT-specific coaching'],
            ['Smart Recommendations', 'ML/AI', '✅ Complete', 'Hybrid engine: Rules + ML risk + Gemini AI generated suggestions'],
            ['Reports & Analytics', 'Analytics', '✅ Complete', 'Interactive charts, time filters, AI insights, PDF/CSV export'],
            ['Weather Integration', 'Context', '✅ Complete', 'Open-Meteo API live weather with wellness nudges'],
            ['Smart Notifications', 'Engagement', '✅ Complete', 'FCM push, burnout alerts, hydration/break/sleep reminders'],
            ['Profile Management', 'User', '✅ Complete', 'Avatar upload, profile editing, account statistics'],
            ['Dark/Light Mode', 'UI/UX', '✅ Complete', 'Material 3 theme switching with persistent preference'],
            ['Offline-First Support', 'Architecture', '✅ Complete', 'Hive local cache, offline sync queue, connectivity monitoring'],
            ['Auto Sign-Out', 'Security', '✅ Complete', 'Configurable inactivity timeout with automatic logout'],
            ['Data Export', 'Privacy', '✅ Complete', 'Export personal data as JSON for GDPR compliance'],
            ['Account Deletion', 'Privacy', '✅ Complete', 'Permanent data wipe with password confirmation'],
            ['Rate Limiting', 'Security', '✅ Complete', '100 requests/minute/user sliding window throttle'],
            ['CORS & Security Headers', 'Security', '✅ Complete', 'HSTS, CSP, X-Frame-Options, restricted origins'],
            ['Prompt Injection Defense', 'Security', '✅ Complete', 'Blacklist filtering for LLM prompt injection attacks'],
            ['Automated Testing', 'Quality', '✅ Complete', '27 pytest backend tests + Flutter widget/unit tests'],
        ]
    )

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 4: TECHNICAL ARCHITECTURE
    # =========================================================================
    doc.add_heading('4. Technical Architecture Guide', level=1)

    doc.add_heading('4.1 System Architecture Overview', level=2)
    doc.add_paragraph(
        'MindSync AI is designed as a distributed, multi-tier system consisting of four primary layers:'
    )
    arch_layers = [
        ('Client Tier (Flutter Mobile App)', 'Cross-platform mobile application built with Flutter SDK 3.22+ and Dart 3.4+. Uses Material 3 design system, Riverpod for state management, GoRouter for navigation, Dio for HTTP networking, and Hive for local offline storage.'),
        ('Security & Auth Tier (Firebase)', 'Firebase Authentication for user management, Cloud Firestore for NoSQL data persistence, Firebase Storage for file hosting, and Firebase Cloud Messaging for push notifications.'),
        ('Application Server Tier (FastAPI)', 'Python-based REST API server using FastAPI framework, hosting ML prediction endpoints, AI orchestration services, analytics engines, and notification pipelines.'),
        ('External Provider Tier', 'Google Gemini API (gemini-1.5-flash) for AI coaching, and Open-Meteo API for weather data retrieval.'),
    ]
    for title, desc in arch_layers:
        p = doc.add_paragraph()
        run = p.add_run(f'• {title}: ')
        run.bold = True
        p.add_run(desc)

    doc.add_heading('Communication Flow', level=3)
    doc.add_paragraph(
        '1. The Flutter app authenticates via Firebase Auth and receives a JWT ID Token.\n'
        '2. All API requests to FastAPI include the Bearer token in the Authorization header.\n'
        '3. FastAPI verifies the token against Google\'s public JWKS certificates.\n'
        '4. Backend processes the request (ML inference, AI chat, data CRUD) and returns a standardized JSON response.\n'
        '5. Results are cached locally in Hive for offline access.'
    )

    doc.add_heading('4.2 Frontend Architecture (Flutter)', level=2)
    doc.add_paragraph(
        'The mobile application implements a feature-based Clean Architecture pattern:'
    )
    doc.add_heading('Layer Structure', level=3)
    layers = [
        ('Presentation Layer', 'UI Pages (screens), Reusable Widgets, Riverpod State Controllers/Providers'),
        ('Domain Layer', 'Business Entities, Use Cases, Repository Interfaces'),
        ('Data Layer', 'Repository Implementations, Remote Data Sources (Dio/API), Local Data Sources (Hive)'),
    ]
    for title, desc in layers:
        p = doc.add_paragraph()
        run = p.add_run(f'• {title}: ')
        run.bold = True
        p.add_run(desc)

    doc.add_heading('Feature Modules', level=3)
    add_styled_table(doc,
        ['Module', 'Directory', 'Key Files'],
        [
            ['Authentication', 'features/authentication/', 'splash, onboarding, login, register, forgot_password'],
            ['Dashboard', 'features/dashboard/', 'dashboard_page, weather_widget, wellness_score'],
            ['Mood Journal', 'features/mood/', 'mood_journal_page, mood_calendar, mood_provider'],
            ['AI Chat', 'features/chat/', 'ai_chat_page, chat_provider, message_bubble'],
            ['Burnout', 'features/burnout/', 'burnout_provider, burnout_risk_card'],
            ['Recommendations', 'features/recommendations/', 'recommendations_page, recommendation_card'],
            ['Reports', 'features/reports/', 'reports_page, chart_widgets, export_service'],
            ['Notifications', 'features/notifications/', 'notifications_page, notification_provider'],
            ['Profile', 'features/profile/', 'profile_page, profile_edit, avatar_upload'],
            ['Settings', 'features/settings/', 'settings_page, security_settings, appearance'],
        ]
    )

    doc.add_heading('4.3 Backend Architecture (FastAPI)', level=2)
    doc.add_heading('Directory Structure', level=3)
    doc.add_paragraph(
        'backend/\n'
        '├── app/\n'
        '│   ├── main.py                 # App bootstrap & lifespan events\n'
        '│   ├── api/endpoints/          # API route handlers\n'
        '│   │   ├── health.py           # Health check endpoints\n'
        '│   │   ├── predict.py          # ML burnout prediction\n'
        '│   │   ├── recommendations.py  # Smart recommendations\n'
        '│   │   ├── analytics.py        # Reports, trends, exports\n'
        '│   │   └── notifications.py    # Notification management\n'
        '│   ├── core/                   # Security, configs, Firebase SDK\n'
        '│   ├── middleware/             # Rate limiter, request logger, CORS\n'
        '│   ├── ml/                     # ML models & training pipeline\n'
        '│   │   ├── pipeline.py         # Inference pipeline with SHAP\n'
        '│   │   ├── train.py            # Model training script\n'
        '│   │   ├── recommendation_engine.py  # Hybrid engine\n'
        '│   │   └── models/burnout_model.pkl  # Serialized model\n'
        '│   ├── services/               # Cache, model loader, scheduler\n'
        '│   └── utils/                  # Response formatting, sanitizers\n'
        '├── tests/                      # Pytest automated test suites\n'
        '└── requirements.txt            # Python dependencies'
    )

    doc.add_heading('4.4 Database Schema (Firestore + Hive)', level=2)
    doc.add_heading('Cloud Firestore Collections', level=3)
    add_styled_table(doc,
        ['Collection', 'Document Key', 'Key Fields', 'Purpose'],
        [
            ['users', '{userId}', 'fullName, email, occupation, age, gender, profileImage', 'User profile data'],
            ['mood_logs', '{logId}', 'userId, mood, moodScore, stressLevel, energyLevel, journal, tags', 'Mood journal entries'],
            ['activity_logs', '{logId}', 'userId, date, steps, sleepHours, waterGlasses, exerciseMinutes', 'Health telemetry data'],
            ['chat_sessions', '{sessionId}', 'userId, title, createdAt + messages/ sub-collection', 'AI chat conversation history'],
            ['burnout_predictions', '{predId}', 'userId, burnoutRisk, confidence, riskScore, importantFactors', 'ML prediction results'],
            ['recommendations', '{recId}', 'userId, title, description, reason, category, priority', 'Wellness suggestions'],
        ]
    )
    doc.add_paragraph()
    doc.add_heading('Local Hive Storage Boxes', level=3)
    add_styled_table(doc,
        ['Box Name', 'Purpose'],
        [
            ['auth_box', 'JWT tokens, refresh tokens, user profile cache for persistent login'],
            ['settings_box', 'Dark/Light mode, notification preferences, auto sign-out config'],
            ['mood_sync_queue', 'Offline mood entries queued for sync when connectivity resumes'],
            ['cached_data_box', 'Dashboard JSON, weather forecasts for offline access'],
        ]
    )

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 5: MACHINE LEARNING PIPELINE
    # =========================================================================
    doc.add_heading('5. Machine Learning Pipeline', level=1)

    doc.add_heading('5.1 Burnout Risk Prediction Model', level=2)
    doc.add_paragraph(
        'The core ML component is a Random Forest Classifier trained to predict burnout risk levels '
        'for IT professionals based on 9 behavioral and wellness metrics.'
    )
    doc.add_heading('Model Specifications', level=3)
    add_styled_table(doc,
        ['Property', 'Value'],
        [
            ['Algorithm', 'Random Forest Classifier (Ensemble)'],
            ['Training Data', '10,000 synthetic records with domain-expert-weighted risk formula'],
            ['Feature Count', '9 input features'],
            ['Output Classes', '3 (Low=0, Medium=1, High=2)'],
            ['Scaling', 'RobustScaler (handles outliers)'],
            ['Hyperparameter Tuning', 'GridSearchCV with 3-fold cross-validation'],
            ['Tuning Parameters', 'n_estimators: [50, 100, 150], max_depth: [6, 10, None], min_samples_split: [2, 5]'],
            ['Primary Metric', 'F1-Score (macro-averaged)'],
            ['Target Accuracy', '≥ 85%'],
            ['Serialization', 'Joblib (.pkl format)'],
            ['Inference Time', '< 50 milliseconds'],
        ]
    )

    doc.add_heading('5.2 Training Pipeline', level=2)
    doc.add_paragraph(
        'The training pipeline follows these stages:'
    )
    training_steps = [
        'Data Generation: A synthetic dataset of 10,000 records is created using numpy random distributions with domain-expert-calibrated risk weights for IT professional burnout scenarios.',
        'Risk Score Formula: base_score = (working_hours × 3.5) + (stress_level × 5.0) + ((10 - sleep_hours) × 4.0) + ((10 - mood_score) × 3.0) + ((10 - energy_level) × 3.0) + (consecutive_working_days × 2.0) - (exercise_minutes × 0.15) - (water_intake × 0.6) - (daily_steps × 0.0003)',
        'Class Labeling: Low (score < 40), Medium (40 ≤ score < 70), High (score ≥ 70)',
        'Train/Test Split: 80/20 stratified split maintaining class balance.',
        'Feature Scaling: RobustScaler to normalize features while handling outliers.',
        'Model Comparison: Logistic Regression (baseline), Decision Tree, Random Forest, and Gradient Boosting are trained and compared.',
        'Hyperparameter Tuning: GridSearchCV optimizes the Random Forest model.',
        'SHAP Integration: TreeExplainer is initialized for global feature importance analysis.',
        'Model Export: The pipeline (model + scaler + feature names + metadata) is serialized to burnout_model.pkl.',
    ]
    for i, s in enumerate(training_steps, 1):
        doc.add_paragraph(f'{i}. {s}')

    doc.add_heading('5.3 SHAP Explainability (XAI)', level=2)
    doc.add_paragraph(
        'To build user trust and avoid black-box predictions, MindSync AI uses SHAP '
        '(SHapley Additive exPlanations) to compute individual feature contributions:'
    )
    shap_items = [
        'TreeExplainer computes game-theory-based importance values for each feature.',
        'For each prediction, the top 3 positive SHAP values are extracted as "Important Factors".',
        'Factors are mapped to human-readable labels (e.g., "Elevated stress index", "Low sleep duration", "Prolonged working hours").',
        'These factors are returned in the API response and displayed on the Burnout Risk Card in the app.',
    ]
    for f in shap_items:
        doc.add_paragraph(f, style='List Bullet')

    doc.add_heading('5.4 Hybrid Recommendation Engine', level=2)
    doc.add_paragraph(
        'The recommendation engine uses a 3-tier hybrid approach:'
    )
    doc.add_heading('Tier 1: Rules Engine', level=3)
    add_styled_table(doc,
        ['Condition', 'Recommendation', 'Priority'],
        [
            ['Sleep < 6 hours', 'Unwind Sleep Routine – 15-min screenless wind-down', 'High'],
            ['Stress > 7/10', 'Nervous System Reset – 4-7-8 breathing technique', 'Critical'],
            ['Water < 6 glasses', 'Desk Hydration Boost – Drink 250ml immediately', 'Medium'],
            ['Exercise < 20 min', 'Active Desk Stretching – Neck and shoulder rolls', 'Medium'],
        ]
    )
    doc.add_paragraph()
    doc.add_heading('Tier 2: ML Risk-Based', level=3)
    doc.add_paragraph(
        'Based on the predicted burnout risk category, the engine adds targeted recommendations:\n'
        '• High Risk: "Take a 15-minute screen break immediately", "Target 7-8 hours of sleep tonight"\n'
        '• Medium Risk: "Keep water bottle near desk (aim for 2L)", "Limit consecutive screen hours"\n'
        '• Low Risk: "Maintain healthy patterns", "Log daily wellness check-ins"'
    )
    doc.add_heading('Tier 3: Gemini AI Generation', level=3)
    doc.add_paragraph(
        'The engine constructs a context-rich prompt including the user\'s current metrics, burnout risk, '
        'and weather conditions, then sends it to Google Gemini to generate dynamic, personalized '
        'wellness suggestions that go beyond static rules.'
    )

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 6: AI ORCHESTRATION LAYER
    # =========================================================================
    doc.add_heading('6. AI Orchestration Layer', level=1)

    doc.add_heading('6.1 Gemini API Integration', level=2)
    doc.add_paragraph(
        'MindSync AI integrates Google Gemini 1.5 Flash for multiple AI-powered features:'
    )
    gemini_features = [
        ('Conversational Coaching', 'Interactive chat sessions where the AI acts as a wellness coach, understanding IT-specific stressors and providing empathetic, actionable guidance.'),
        ('Mood Analysis', 'Sentiment and stress detection from journal entries, identifying emotional patterns.'),
        ('Report Summarization', 'AI-generated narrative summaries of wellness trends over configurable time periods.'),
        ('Dynamic Recommendations', 'Context-aware suggestion generation that considers user profile, metrics, weather, and historical patterns.'),
    ]
    for title, desc in gemini_features:
        p = doc.add_paragraph()
        run = p.add_run(f'• {title}: ')
        run.bold = True
        p.add_run(desc)

    doc.add_heading('6.2 Prompt Engineering', level=2)
    doc.add_paragraph(
        'Prompts are managed centrally in a Prompt Library to separate AI instructions from business logic:'
    )
    add_styled_table(doc,
        ['Template', 'Purpose'],
        [
            ['daily_summary', 'Translates telemetry scores into concise health tips'],
            ['weekly_report', 'Renders markdown reports summarizing work stress metrics'],
            ['chat_coaching', 'Configures chatbot personality as an IT wellness coach'],
            ['motivational_quote', 'Returns short inspirational coding/wellness analogies'],
        ]
    )

    doc.add_heading('6.3 MLOps & Model Management', level=2)
    doc.add_paragraph(
        'The MLOps pipeline ensures reliable model deployment and monitoring:'
    )
    mlops_items = [
        'Model Loading: On app startup, the pipeline locates burnout_model.pkl, verifies SHA-256 checksum integrity, and loads it into memory.',
        'Fallback Strategy: If the model file is missing or corrupted, a heuristics-based fallback calculator provides degraded but functional predictions.',
        'Retry Logic: AI orchestrator requests to Gemini use exponential backoff (1s, 2s, 4s) with up to 3 retries for handling timeouts and rate limits.',
        'Cache-Aside Pattern: AI responses are cached in an in-memory store; identical queries resolve in milliseconds without external API calls.',
        'Background Scheduler: Nightly tasks clean temp directories and flush expired cache entries. Recommendation metrics are pre-compiled twice daily.',
        'Health Diagnostics: The /api/health/details endpoint reports status of API, database, AI service, ML model, and background workers.',
    ]
    for f in mlops_items:
        doc.add_paragraph(f, style='List Bullet')

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 7: REST API REFERENCE
    # =========================================================================
    doc.add_heading('7. REST API Reference', level=1)

    doc.add_paragraph(
        'All API endpoints are served by the FastAPI backend at http://localhost:8000. '
        'Except health endpoints, all routes require Bearer token authentication.'
    )

    doc.add_heading('Standard Response Format', level=2)
    doc.add_paragraph(
        '{\n'
        '    "success": true,\n'
        '    "message": "Operation status description",\n'
        '    "data": { ... },\n'
        '    "timestamp": "2026-07-31T09:46:49Z"\n'
        '}'
    )

    doc.add_heading('Endpoints Catalog', level=2)
    add_styled_table(doc,
        ['Method', 'Endpoint', 'Auth', 'Description'],
        [
            ['GET', '/health', 'No', 'Liveness and readiness check'],
            ['GET', '/api/health/details', 'No', 'Detailed component health diagnostics'],
            ['POST', '/api/users/profile', 'Yes', 'Create or update user profile in Firestore'],
            ['POST', '/api/mood/log', 'Yes', 'Submit a new mood journal entry'],
            ['GET', '/api/mood/history', 'Yes', 'Retrieve historical mood logs with filters'],
            ['POST', '/api/predict/burnout', 'Yes', 'Run ML burnout risk prediction'],
            ['POST', '/api/chat/message', 'Yes', 'Send message to Gemini AI chat coach'],
            ['GET', '/api/recommendations', 'Yes', 'Get personalized wellness recommendations'],
            ['POST', '/api/recommendations/feedback', 'Yes', 'Submit feedback on a recommendation'],
            ['GET', '/api/analytics/summary', 'Yes', 'Get aggregated wellness analytics'],
            ['GET', '/api/analytics/trends', 'Yes', 'Get trend data for charts'],
            ['POST', '/api/analytics/report', 'Yes', 'Generate comprehensive wellness report'],
            ['GET', '/api/analytics/export', 'Yes', 'Export report as PDF or CSV'],
            ['GET', '/api/notifications', 'Yes', 'Retrieve notification list'],
            ['PATCH', '/api/notifications/{id}/read', 'Yes', 'Mark notification as read'],
        ]
    )

    doc.add_heading('Error Codes', level=2)
    add_styled_table(doc,
        ['Code', 'Meaning', 'Example Cause'],
        [
            ['400', 'Bad Request', 'Invalid metric values (e.g., sleep hours = 26)'],
            ['401', 'Unauthorized', 'Missing or expired authentication token'],
            ['403', 'Forbidden', 'Accessing another user\'s data'],
            ['429', 'Too Many Requests', 'Rate limit exceeded (100 req/min/user)'],
            ['500', 'Internal Server Error', 'Model loading failure or third-party API error'],
        ]
    )

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 8: SECURITY
    # =========================================================================
    doc.add_heading('8. Security Architecture', level=1)

    doc.add_heading('8.1 Authentication & Authorization', level=2)
    security_items = [
        'Firebase Authentication manages user credentials with email/password flow.',
        'JWT ID Tokens are short-lived and verified against Google\'s JWKS public certificates.',
        'Every backend request requires a valid Bearer token in the Authorization header.',
        'Firestore Security Rules enforce per-user data isolation (request.auth.uid == resource.data.userId).',
    ]
    for f in security_items:
        doc.add_paragraph(f, style='List Bullet')

    doc.add_heading('8.2 OWASP Top 10 Compliance', level=2)
    add_styled_table(doc,
        ['OWASP Category', 'Mitigation'],
        [
            ['Broken Object-Level Authorization', 'Firebase ID Token UID matching for all data queries'],
            ['Broken User Authentication', 'Firebase Auth JWT validation with token expiration checks'],
            ['Excessive Data Exposure', 'Standardized response filtering prevents database key dumps'],
            ['Lack of Rate Limiting', 'Sliding window rate limiter (60 req/min/IP)'],
            ['Security Misconfiguration', 'CORS restrictions, HSTS, CSP, X-Frame-Options headers'],
        ]
    )

    doc.add_heading('8.3 AI Security', level=2)
    ai_security = [
        'Prompt Injection Defense: Sanitization module filters blacklisted injection patterns (e.g., "ignore prior instructions", "system override").',
        'Medical Disclaimer: Every AI response appends a standard disclaimer that the app is not a substitute for professional medical advice.',
        'Content Safety: AI-generated responses are validated for appropriateness before delivery.',
    ]
    for f in ai_security:
        doc.add_paragraph(f, style='List Bullet')

    doc.add_heading('8.4 Local Data Security', level=2)
    local_security = [
        'Hive local databases do not store raw authentication tokens; session management uses Firebase\'s secure handles.',
        'Exported data files are written to temporary system paths with OS-level sandboxing.',
        'Auto sign-out protects against unauthorized access on unattended devices.',
    ]
    for f in local_security:
        doc.add_paragraph(f, style='List Bullet')

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 9: TESTING
    # =========================================================================
    doc.add_heading('9. Testing & Quality Assurance', level=1)

    doc.add_heading('9.1 Backend Testing (Python/Pytest)', level=2)
    doc.add_paragraph('The backend includes 27 automated tests across 7 test files:')
    add_styled_table(doc,
        ['Test File', 'Tests', 'Coverage Area'],
        [
            ['test_api.py', '3', 'Core API endpoint validation, auth checks'],
            ['test_mlops.py', '4', 'ML model loading, inference, SHAP values, model health'],
            ['test_analytics.py', '7', 'Summary, trends, historical stats, report generation, PDF/CSV export'],
            ['test_notifications.py', '6', 'Notification CRUD, preferences, trigger evaluation'],
            ['test_recommendations.py', '3', 'Recommendation generation, feedback submission'],
            ['test_production.py', '2', 'Validation error responses, production readiness'],
            ['test_security.py', '2', 'Unauthorized endpoint rejection, security headers'],
        ]
    )

    doc.add_heading('9.2 Frontend Testing (Flutter/Dart)', level=2)
    doc.add_paragraph(
        'Flutter testing covers unit tests for providers and services, widget tests for UI components, '
        'and integration tests for navigation flows. Tests use Mocktail for mocking dependencies.'
    )

    doc.add_heading('9.3 Running Tests', level=2)
    doc.add_paragraph('Backend:')
    doc.add_paragraph('    cd backend\n    .venv\\Scripts\\python.exe -m pytest')
    doc.add_paragraph('Frontend:')
    doc.add_paragraph('    cd frontend\n    flutter test')

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 10: DEPLOYMENT
    # =========================================================================
    doc.add_heading('10. Deployment Guide', level=1)

    doc.add_heading('10.1 Backend Setup', level=2)
    backend_steps = [
        'Navigate to the backend directory: cd backend',
        'Create a Python virtual environment: python -m venv .venv',
        'Activate the virtual environment: .venv\\Scripts\\activate (Windows) or source .venv/bin/activate (Linux/Mac)',
        'Install dependencies: pip install -r requirements.txt',
        'Configure .env file with Firebase credentials path and Gemini API key',
        'Place firebase-credentials.json in the backend root',
        'Train the ML model: python app/ml/train.py',
        'Start the server: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload',
    ]
    for i, s in enumerate(backend_steps, 1):
        doc.add_paragraph(f'{i}. {s}')

    doc.add_heading('10.2 Frontend Setup', level=2)
    frontend_steps = [
        'Navigate to the frontend directory: cd frontend',
        'Ensure Flutter SDK 3.22+ is installed and configured',
        'Create .env file with GEMINI_API_KEY and WEATHER_API_KEY',
        'Fetch packages: flutter pub get',
        'Generate code files: flutter pub run build_runner build --delete-conflicting-outputs',
        'Run on Android emulator: flutter run',
        'Build release APK: flutter build apk --release',
    ]
    for i, s in enumerate(frontend_steps, 1):
        doc.add_paragraph(f'{i}. {s}')

    doc.add_heading('10.3 Docker Deployment', level=2)
    doc.add_paragraph(
        'The backend includes a Dockerfile and docker-compose.yml for containerized deployment:\n\n'
        '    docker-compose up --build\n\n'
        'This creates a containerized FastAPI instance with the ML model pre-loaded.'
    )

    doc.add_page_break()

    # =========================================================================
    # CHAPTER 11: TECHNOLOGY STACK
    # =========================================================================
    doc.add_heading('11. Technology Stack Summary', level=1)

    doc.add_heading('Frontend Technologies', level=2)
    add_styled_table(doc,
        ['Technology', 'Purpose', 'Version'],
        [
            ['Flutter SDK', 'Cross-platform UI framework', '3.22+'],
            ['Dart', 'Programming language', '3.4+'],
            ['Material 3', 'Google design system', 'Included'],
            ['Riverpod', 'State management & DI', '2.5.1+'],
            ['GoRouter', 'Declarative navigation', '14.2.0+'],
            ['Dio', 'HTTP client', '5.4.3+'],
            ['Hive', 'Local NoSQL database', '1.1.0+'],
            ['fl_chart', 'Interactive charts', '0.68.0+'],
            ['Google Fonts', 'Typography (Inter)', '6.2.1+'],
            ['Lottie', 'Interactive animations', '3.1.2+'],
        ]
    )

    doc.add_paragraph()
    doc.add_heading('Backend Technologies', level=2)
    add_styled_table(doc,
        ['Technology', 'Purpose', 'Version'],
        [
            ['Python', 'Backend language', '3.11+'],
            ['FastAPI', 'REST API framework', '0.111.0+'],
            ['Uvicorn', 'ASGI server', '0.30.0+'],
            ['Pydantic v2', 'Data validation', '2.7.0+'],
            ['Firebase Admin SDK', 'Auth & database', '6.5.0+'],
            ['HTTPX', 'Async HTTP client', '0.27.0+'],
            ['Scikit-Learn', 'ML model training', 'Latest'],
            ['SHAP', 'Explainable AI', 'Latest'],
            ['Joblib', 'Model serialization', 'Latest'],
            ['Pandas/NumPy', 'Data processing', 'Latest'],
        ]
    )

    doc.add_paragraph()
    doc.add_heading('Cloud & Infrastructure', level=2)
    add_styled_table(doc,
        ['Service', 'Purpose'],
        [
            ['Firebase Authentication', 'User credential management (Email/Password)'],
            ['Cloud Firestore', 'NoSQL cloud database for structured collections'],
            ['Firebase Storage', 'Profile photos and generated PDF hosting'],
            ['Firebase Cloud Messaging', 'Push notification delivery'],
            ['Open-Meteo API', 'Real-time weather data (no API key required)'],
            ['Google Gemini API', 'LLM-powered AI coaching and content generation'],
            ['Docker', 'Backend containerization'],
        ]
    )

    # =========================================================================
    # FOOTER NOTE
    # =========================================================================
    doc.add_page_break()
    doc.add_heading('End of Document', level=1)
    doc.add_paragraph(
        'This document provides a comprehensive guide to the MindSync AI application, covering '
        'all features, technical architecture, ML/AI pipelines, API specifications, security measures, '
        'and deployment instructions. For further questions or support, refer to the project documentation '
        'repository in the docs/ directory.'
    )
    p = doc.add_paragraph()
    run = p.add_run('\n\nDocument generated for MindSync AI v1.0.0')
    run.italic = True
    run.font.color.rgb = RGBColor(150, 150, 150)

    p = doc.add_paragraph()
    run = p.add_run('© 2026 MindSync AI – AI Mental Wellness Companion for IT Professionals')
    run.italic = True
    run.font.color.rgb = RGBColor(150, 150, 150)
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER

    # =========================================================================
    # SAVE
    # =========================================================================
    output_path = os.path.join(os.path.dirname(__file__), 'MindSync_AI_Complete_Guide.docx')
    doc.save(output_path)
    print(f"\n[OK] Document saved successfully to: {output_path}")
    print(f"   Total sections: 11 chapters")
    print(f"   Format: Microsoft Word (.docx)")
    return output_path

if __name__ == '__main__':
    create_document()
