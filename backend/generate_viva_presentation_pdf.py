"""
MindSync AI - 10-15 Minute Viva Presentation & Live Demo Guide PDF Generator
=============================================================================
Generates a structured, concise PDF guide designed for a 10 to 15-minute viva
presentation and live app demonstration. Includes slide-by-slide scripts,
timing markers, click-by-click live demo instructions, technical highlights,
and viva cheatsheets.
"""

import os
from datetime import datetime
from reportlab.lib.pagesizes import letter
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    PageBreak, HRFlowable, KeepTogether
)
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib import colors
from reportlab.lib.units import inch
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY

OUTPUT_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "MindSync_AI_15Min_Viva_Presentation_And_Demo_Guide.pdf"
)

# ============================== STYLES ==============================
def get_styles():
    base = getSampleStyleSheet()
    return {
        "cover_title": ParagraphStyle("CT", parent=base["Title"], fontName="Helvetica-Bold", fontSize=26, textColor=colors.HexColor("#0D47A1"), alignment=TA_CENTER, spaceAfter=6),
        "cover_sub": ParagraphStyle("CS", parent=base["Heading2"], fontName="Helvetica", fontSize=14, textColor=colors.HexColor("#1565C0"), alignment=TA_CENTER, spaceAfter=4),
        "cover_meta": ParagraphStyle("CM", parent=base["Normal"], fontName="Helvetica-Oblique", fontSize=9.5, textColor=colors.HexColor("#546E7A"), alignment=TA_CENTER, spaceBefore=4),
        "ch": ParagraphStyle("CH", parent=base["Heading1"], fontName="Helvetica-Bold", fontSize=18, textColor=colors.HexColor("#0D47A1"), spaceBefore=16, spaceAfter=8),
        "se": ParagraphStyle("SE", parent=base["Heading2"], fontName="Helvetica-Bold", fontSize=13, textColor=colors.HexColor("#1565C0"), spaceBefore=12, spaceAfter=5),
        "ss": ParagraphStyle("SS", parent=base["Heading3"], fontName="Helvetica-Bold", fontSize=10.5, textColor=colors.HexColor("#0277BD"), spaceBefore=8, spaceAfter=3),
        "b": ParagraphStyle("B", parent=base["BodyText"], fontName="Helvetica", fontSize=9, leading=13, textColor=colors.HexColor("#263238"), alignment=TA_JUSTIFY, spaceAfter=4),
        "bb": ParagraphStyle("BB", parent=base["BodyText"], fontName="Helvetica-Bold", fontSize=9, leading=13, textColor=colors.HexColor("#263238"), spaceAfter=4),
        "c": ParagraphStyle("C", parent=base["Code"], fontName="Courier", fontSize=8, leading=10.5, textColor=colors.HexColor("#1B5E20"), backColor=colors.HexColor("#F5F5F5"), borderWidth=0.4, borderColor=colors.HexColor("#BDBDBD"), borderPadding=4, spaceBefore=3, spaceAfter=5),
        "note": ParagraphStyle("N", parent=base["BodyText"], fontName="Helvetica-Oblique", fontSize=8.5, leading=11.5, textColor=colors.HexColor("#004D40"), backColor=colors.HexColor("#E0F2F1"), borderWidth=0.4, borderColor=colors.HexColor("#00897B"), borderPadding=6, spaceBefore=4, spaceAfter=6),
        "bl": ParagraphStyle("BL", parent=base["BodyText"], fontName="Helvetica", fontSize=9, leading=12.5, textColor=colors.HexColor("#263238"), leftIndent=16, bulletIndent=8, spaceAfter=2.5),
        "time": ParagraphStyle("TM", parent=base["Normal"], fontName="Helvetica-Bold", fontSize=9, textColor=colors.HexColor("#D84315"), spaceBefore=2, spaceAfter=2),
        "dis": ParagraphStyle("DIS", parent=base["BodyText"], fontName="Helvetica-Oblique", fontSize=7.5, textColor=colors.HexColor("#90A4AE"), alignment=TA_CENTER),
    }

def tbl(headers, rows, cw=None):
    bs = ParagraphStyle("TB", fontName="Helvetica", fontSize=8, leading=10.5, textColor=colors.HexColor("#263238"))
    hs = ParagraphStyle("TH", fontName="Helvetica-Bold", fontSize=8, leading=10.5, textColor=colors.white)
    d = [[Paragraph(h, hs) for h in headers]]
    for r in rows:
        d.append([Paragraph(str(c), bs) for c in r])
    t = Table(d, colWidths=cw, repeatRows=1)
    t.setStyle(TableStyle([
        ("BACKGROUND",(0,0),(-1,0),colors.HexColor("#1565C0")),
        ("GRID",(0,0),(-1,-1),0.3,colors.HexColor("#90A4AE")),
        ("BACKGROUND",(0,1),(-1,-1),colors.HexColor("#FAFAFA")),
        ("ROWBACKGROUNDS",(0,1),(-1,-1),[colors.HexColor("#FAFAFA"),colors.HexColor("#ECEFF1")]),
        ("VALIGN",(0,0),(-1,-1),"TOP"),
        ("PADDING",(0,0),(-1,-1),4),
    ]))
    return t

def hr():
    return HRFlowable(width="100%", thickness=0.4, color=colors.HexColor("#B0BEC5"), spaceBefore=5, spaceAfter=5)

def code(s, txt):
    return Paragraph(txt.replace("\n", "<br/>").replace("  ", "&nbsp;&nbsp;").replace("<", "&lt;").replace(">", "&gt;"), s["c"])

def bullets(s, items):
    return [Paragraph("* " + i, s["bl"]) for i in items]

# ============================== DOCUMENT BUILDER ==============================
def build_pdf():
    s = get_styles()
    st = []

    # ------------------ COVER PAGE ------------------
    st.append(Spacer(1, 1.2 * inch))
    st.append(Paragraph("MindSync AI", s["cover_title"]))
    st.append(Paragraph("10-15 Minute Viva Presentation &amp; Live Demo Guide", s["cover_title"]))
    st.append(Spacer(1, 0.15 * inch))
    st.append(Paragraph("AI Mental Wellness Companion for IT Professionals", s["cover_sub"]))
    st.append(Paragraph("Master Presentation Script, Slide Deck &amp; Live Demo Workflow", s["cover_sub"]))
    st.append(Spacer(1, 0.3 * inch))
    st.append(Paragraph(f"Generated: {datetime.now().strftime('%B %d, %Y')}", s["cover_meta"]))
    st.append(Paragraph("Target Presentation Duration: 10 - 15 Minutes", s["cover_meta"]))
    st.append(Paragraph("Includes: 11 Slide Deck Scripts, Click-by-Click Live Demo Instructions, Technical Cheatsheet &amp; Q&amp;A Defense", s["cover_meta"]))
    st.append(PageBreak())

    # ------------------ SECTION 1: PRESENTATION TIMELINE ------------------
    st.append(Paragraph("SECTION 1: 10-15 MINUTE PRESENTATION TIMELINE", s["ch"]))
    st.append(hr())
    st.append(Paragraph("Below is the exact time allocation recommended for a 15-minute presentation committee slot. Adjust timing slightly if given 10 minutes.", s["b"]))
    
    st.append(tbl(
        ["Time Block", "Segment", "Focus Area", "Slide(s)"],
        [
            ["0:00 - 1:00 (1 min)", "Introduction", "Title, Project Overview &amp; Key Value Proposition", "Slide 1"],
            ["1:00 - 2:30 (1.5 min)", "Problem Statement", "IT Occupational Burnout Crisis &amp; Industry Need", "Slide 2"],
            ["2:30 - 4:00 (1.5 min)", "System Architecture", "Three-Tier Hybrid AI Design (ML + GenAI + Rules)", "Slide 3"],
            ["4:00 - 5:30 (1.5 min)", "ML &amp; Explainable AI", "Random Forest Model, RobustScaler &amp; SHAP TreeExplainer", "Slides 4 - 5"],
            ["5:30 - 7:00 (1.5 min)", "Generative AI &amp; Rules", "Groq LLaMA 3.3-70B, Prompt Security &amp; Rule Engine", "Slide 6"],
            ["7:00 - 11:30 (4.5 min)", "LIVE DEMO", "Step-by-Step Application Walkthrough (Flutter App)", "Slide 7 - 8"],
            ["11:30 - 13:00 (1.5 min)", "Security &amp; DevOps", "Firebase, JWT Auth, Docker &amp; Render Cloud Deployment", "Slide 9"],
            ["13:00 - 15:00 (2.0 min)", "Conclusion &amp; Q&amp;A", "Key Takeaways, Testing Metrics (93% Acc) &amp; Defense", "Slides 10 - 11"],
        ], cw=[100, 110, 210, 60]
    ))
    st.append(Spacer(1, 10))

    # ------------------ SECTION 2: SLIDE-BY-SLIDE SCRIPTS ------------------
    st.append(Paragraph("SECTION 2: SLIDE-BY-SLIDE PRESENTATION SCRIPT", s["ch"]))
    st.append(hr())

    slides = [
        ("Slide 1: Title &amp; Introduction", "0:00 - 1:00 min",
         "Good morning respected examiners and members of the panel. Today, I am presenting MindSync AI -- an AI-driven mental wellness companion engineered specifically for software engineers and IT professionals.",
         ["Project Name: MindSync AI",
          "Target Audience: Software developers, DevOps engineers, and IT professionals",
          "Key Feature Matrix: ML Burnout Prediction, Explainable AI (SHAP), Groq LLM Coaching, Hybrid Recommendations, Telemetry Dashboards",
          "Tech Stack: Flutter (Frontend), FastAPI Python (Backend), Random Forest + SHAP (ML), Groq LLaMA 3.3-70B (GenAI), Firebase (Cloud DB/Auth)"]),

        ("Slide 2: Problem Statement &amp; IT Burnout Crisis", "1:00 - 2:30 min",
         "According to industry research, over 83% of software developers suffer from occupational burnout. Long coding sessions, tight sprint deadlines, late-night debugging, and constant screen time lead to severe cognitive fatigue and mental exhaustion.",
         ["Existing Wellness Apps: Generic (meditation-only), ignore developer-specific stress triggers, lack predictive capabilities",
          "MindSync AI Solution: Data-driven predictive model tracking developer metrics (sleep, stress, working hours, consecutive days, exercise, hydration)",
          "Core Innovation: Combines predictive Machine Learning with Explainable AI so developers know WHY they are at risk"]),

        ("Slide 3: Three-Tier Hybrid AI Architecture", "2:30 - 4:00 min",
         "To guarantee system reliability and high-quality user assistance, MindSync AI utilizes a robust Three-Tier Hybrid AI Architecture.",
         ["Tier 1 - Classical Machine Learning: Random Forest model predicts burnout risk level (Low, Medium, High) with 93% accuracy",
          "Tier 2 - Generative AI: Groq LLM (LLaMA 3.3-70B) generates context-aware, creative habit recommendations and conversational chat coaching",
          "Tier 3 - Deterministic Rules Engine: Instant threshold-based notifications for critical stress, low sleep, and dehydration",
          "Graceful Degradation: If LLM API fails, Tier 1 ML and Tier 3 Rules continue operating seamlessly without app downtime"]),

        ("Slide 4: Machine Learning &amp; Burnout Prediction Pipeline", "4:00 - 4:45 min",
         "Our primary ML model is a Random Forest Classifier trained on 10,000 synthetic developer wellness records incorporating 9 key behavioral features.",
         ["Input Features (9): sleep_hours, working_hours, mood_score, stress_level, energy_level, water_intake, daily_steps, exercise_minutes, consecutive_working_days",
          "Data Preprocessing: RobustScaler normalizes features using median and IQR, resisting extreme outliers like 16-hour coding days",
          "Hyperparameter Tuning: GridSearchCV evaluated 18 configurations across 3-fold cross-validation, optimizing macro F1-score",
          "Output Schema: Risk Class (Low/Medium/High), Confidence %, and Continuous Risk Score (0-100 derived from weighted class probabilities)"]),

        ("Slide 5: Explainable AI (SHAP TreeExplainer)", "4:45 - 5:30 min",
         "A key requirement for user trust in healthcare/wellness AI is explainability. We integrated SHAP (SHapley Additive exPlanations) to make predictions transparent.",
         ["Game Theory Foundation: Calculates exact Shapley value contributions for each feature per prediction",
          "TreeExplainer: Optimized for tree-based models, computes feature contributions in real-time during API inference",
          "Human-Readable Factor Translation: Top positive risk contributors are translated to actionable user insights (e.g. 'Low sleep duration', 'Elevated stress index')",
          "User Empowerment: Developers can see exactly which habits are pushing them into high-risk zones"]),

        ("Slide 6: Generative AI, Prompt Security &amp; Rules Engine", "5:30 - 7:00 min",
         "For creative habit generation and interactive coaching, we integrated Groq's high-speed inference API running LLaMA 3.3-70B.",
         ["Structured JSON Output: Enforces strict response formats using system instructions and response_format parameters",
          "Developer-Centric Persona: Prompts instruct the LLM to use developer analogies (e.g. 'stack overflow', 'memory leak', 'compile errors')",
          "AI Security Layer (AISecurityManager): Strips HTML tags, filters 7 prompt injection regex patterns (e.g. 'ignore all prior rules'), and auto-appends medical disclaimers",
          "Rule-Based Notification Engine: Evaluates 6 threshold rules (e.g. Stress >= 8 and Sleep < 6h triggers 'Nervous System Reset')"]),

        ("Slide 7: Cross-Platform Client Architecture (Flutter)", "7:00 - 7:45 min",
         "The frontend is built using Flutter and Dart, following a clean 3-layer architecture (Data, Domain, Presentation).",
         ["State Management: Flutter Riverpod for reactive state management and dependency injection",
          "Declarative Routing: GoRouter with auth-based guards enforcing seamless splash/login/dashboard redirects",
          "Offline Resilience: Hive key-value database caches metrics locally when offline",
          "CrashGuard Protection: 3-tier error catching prevents app process crashes even during unexpected platform exceptions"]),

        ("Slide 8: Live Demonstration Setup &amp; Overview", "7:45 - 11:30 min",
         "Now, I will conduct a live demonstration of the application running end-to-end.",
         ["(Proceed to Section 3 of this document for click-by-click live demo script)",
          "Demonstrate: Auth Login -> Dashboard (11 Cards) -> Log Wellness Entry -> View ML Burnout Prediction &amp; SHAP Factors -> AI Recommendations -> AI Chat Coach -> Telemetry Charts &amp; PDF Export"]),

        ("Slide 9: Security, Cloud Infrastructure &amp; DevOps", "11:30 - 13:00 min",
         "The system is designed with production-grade security and cloud infrastructure.",
         ["Authentication &amp; Security: Firebase Auth issuing JWT ID Tokens, verified backend-side. OWASP security headers (X-Frame-Options: DENY, HSTS, CSP)",
          "Rate Limiting: Sliding-window rate limiter (60 req/min/IP) preventing API abuse",
          "Docker Containerization: Single container spec using python:3.12-slim with native HTTP healthchecks",
          "Cloud Hosting: Render cloud platform running Docker backend service connected to Firebase Firestore"]),

        ("Slide 10: Testing &amp; Quality Assurance", "13:00 - 14:00 min",
         "The backend features a comprehensive test suite written in Pytest.",
         ["Test Coverage: 7 test files covering 25+ test cases",
          "Validated Areas: Health endpoints, security injection filtering, ML prediction outputs, recommendation feedback, analytics calculations, notification evaluation, PDF generation",
          "Model Performance: Trained Random Forest model achieves 93% accuracy and 0.93 macro F1-score"]),

        ("Slide 11: Conclusion &amp; Q&amp;A Defense", "14:00 - 15:00 min",
         "In conclusion, MindSync AI demonstrates how combining Machine Learning prediction, Explainable AI, and Generative LLMs can create a tangible solution for software engineer wellness.",
         ["Key Takeaways: 3-Tier Hybrid AI, Real-time SHAP Explainability, Developer-tailored UX, Production Security &amp; Cloud Deployment",
          "Thank you for your time. I am now open to questions from the panel."]),
    ]

    for title, duration, script, highlights in slides:
        st.append(Paragraph(title, s["se"]))
        st.append(Paragraph(f"Timing: {duration}", s["time"]))
        st.append(Paragraph(f"<b>Speaker Script:</b> \"{script}\"", s["b"]))
        st.append(Paragraph("<b>Slide Visual Highlights:</b>", s["bb"]))
        st.extend(bullets(s, highlights))
        st.append(Spacer(1, 4))

    st.append(PageBreak())

    # ------------------ SECTION 3: STEP-BY-STEP LIVE DEMO WALKTHROUGH ------------------
    st.append(Paragraph("SECTION 3: STEP-BY-STEP LIVE DEMO EXECUTION SCRIPT", s["ch"]))
    st.append(hr())
    st.append(Paragraph("Follow this exact step-by-step procedure during the live demo segment of your presentation.", s["b"]))

    demo_steps = [
        ("Step 0: How to Launch the Application",
         "Choice A (Full Stack Mode): Run backend server ('python app/main.py' in backend/) and start Flutter client ('flutter run' in frontend/). Choice B (Instant Demo Mode): Set 'static const bool demoMode = true;' in AppConfig.dart to run instant zero-config presentation without backend dependencies.",
         ["Ensure phone/emulator screen is mirrored to the presentation display", "Keep backend terminal visible if showing API logs to technical examiners"]),

        ("Step 1: User Authentication &amp; Splash Screen",
         "Open the app. Point out the splash screen animation and auto-authentication check. Log in using demo credentials or tap 'Sign In as Guest/Demo User'.",
         ["Highlight Firebase Auth integration", "Mention JWT bearer token security"]),

        ("Step 2: Dashboard Exploration",
         "Show the main home screen. Highlight the 11 modular widget cards:",
         ["Welcome Header with user greeting", "Wellness Score Card (0-100 score)", "Burnout Risk Indicator Card",
          "Mood Summary Card", "Activity &amp; Hydration Summary", "AI Recommendations Carousel",
          "Weather Info Widget", "Developer Motivational Quote", "Weekly Wellness Charts", "Recent Logs", "Quick Actions Grid"]),

        ("Step 3: Logging a High-Stress Wellness Check-In",
         "Tap the '+ Log Mood' button to open the entry page. Input the following test values specifically engineered to trigger High Burnout Risk alerts:",
         ["Mood: Select Tired/Stressed emoji (Score 3/10)", "Stress Level: Set slider to 9/10", "Energy Level: Set slider to 3/10",
          "Sleep Hours: Enter 4.5 hours", "Working Hours: Enter 12.0 hours", "Water Intake: 3 glasses (750 ml)",
          "Daily Steps: 2,000 steps", "Exercise: 0 minutes", "Consecutive Work Days: 6 days", "Tap 'Submit Check-In'"]),

        ("Step 4: Demonstrating ML Prediction &amp; SHAP Explainability",
         "Show the resulting Burnout Prediction Screen:",
         ["Point to Risk Level: 'HIGH' (Red badge)", "Point to Continuous Risk Score: ~82/100", "Point to Confidence: ~91%",
          "<b>CRITICAL POINT FOR EXAMINERS:</b> Highlight the 'Top Contributing Factors' section generated by SHAP TreeExplainer: 'Low sleep duration', 'Elevated stress index', 'Prolonged working hours'"]),

        ("Step 5: Demonstrating Hybrid AI Recommendations",
         "Navigate to the Recommendations tab. Show how recommendations come from 3 distinct sources:",
         ["Rule Engine Rec: 'Nervous System Reset (4-7-8 Breathing)' (triggered by stress > 7)",
          "ML Rec: 'Mandatory Disconnection' (triggered by High Burnout Risk)",
          "Groq AI Rec: Creative suggestions generated by LLaMA 3.3-70B",
          "Demonstrate tapping 'Mark as Completed' or submitting feedback"]),

        ("Step 6: Demonstrating AI Chat Coach",
         "Navigate to the AI Chat tab. Type a message: \"I have been debugging a memory leak for 6 hours and feel completely exhausted.\"",
         ["Show the instant response from MindSync AI",
          "Point out the developer analogy in the response (e.g. referencing garbage collection or code refactoring)",
          "Show suggested prompt chips at the bottom"]),

        ("Step 7: Telemetry Analytics &amp; PDF Report Export",
         "Navigate to the Reports tab. Show the 8 interactive fl_chart graphs (Mood, Stress, Sleep, Hydration, Exercise, Burnout, Goals).",
         ["Select 'Last 7 Days' filter", "Tap 'Generate Wellness Report'", "Tap 'Export PDF'",
          "Show the styled ReportLab PDF opened on screen with telemetry matrices and AI summary"]),
    ]

    for title, desc, bullets_list in demo_steps:
        st.append(Paragraph(title, s["se"]))
        st.append(Paragraph(desc, s["b"]))
        st.extend(bullets(s, bullets_list))
        st.append(Spacer(1, 3))

    st.append(PageBreak())

    # ------------------ SECTION 4: VIVA EXAMINER CHEATSHEET ------------------
    st.append(Paragraph("SECTION 4: VIVA EXAMINER QUICK DEFENSE CHEATSHEET", s["ch"]))
    st.append(hr())
    st.append(Paragraph("Keep these key technical facts in mind to confidently answer rapid-fire questions during your viva defense.", s["b"]))

    facts = [
        ("1. Why Random Forest?", "Handles non-linear wellness relationships, resists overfitting via ensemble bagging, outputs probabilities for confidence scoring, and works with SHAP TreeExplainer for real-time explanations."),
        ("2. Why RobustScaler?", "Uses median and IQR (interquartile range) instead of mean/std dev, preventing extreme outliers (e.g. 16-hour workdays) from skewing feature scaling."),
        ("3. Why Synthetic Data?", "Real mental health data is restricted under HIPAA/GDPR. Synthetic data generated with NumPy mimics realistic statistical distributions without privacy violations."),
        ("4. What is SHAP?", "Shapley Additive exPlanations. Game-theoretic metric computing exact feature contributions per prediction. TreeExplainer provides local (per-user) explainability."),
        ("5. How does Groq LLM work?", "High-speed inference API running Meta's LLaMA 3.3-70B model with structured JSON schema enforcement and developer-centric system instructions."),
        ("6. What is the 3-Tier AI System?", "Tier 1: Random Forest ML (predicts risk), Tier 2: Groq LLM (generates recommendations/chat), Tier 3: Rules Engine (threshold notifications). Guarantees zero app downtime."),
        ("7. What security features are built-in?", "Firebase JWT auth token verification, AISecurityManager (HTML stripping, 7 prompt injection regex filters), OWASP security headers, and sliding-window rate limiting (60 req/min/IP)."),
        ("8. How does the Wellness Score work?", "Daily Score = 30% Mood + 20% Inverse Stress + 20% Sleep (cap 8h) + 15% Hydration (cap 8 glasses) + 15% Exercise (cap 30m). Range: 0-100."),
        ("9. What is Clean Architecture?", "3-layer design pattern in Flutter: Data (API/models) -> Domain (entities/use cases) -> Presentation (UI/Riverpod providers). Dependencies point inward."),
        ("10. What emergency backup exists if API fails during Viva?", "AppConfig.dart has a boolean 'demoMode = true' flag that instantly switches the entire app to local offline mock data without requiring internet or backend servers."),
    ]

    for q, a in facts:
        st.append(Paragraph(f"<b>{q}</b>", s["bb"]))
        st.append(Paragraph(a, s["b"]))
        st.append(Spacer(1, 2))

    st.append(Spacer(1, 15))
    st.append(hr())
    st.append(Paragraph("MindSync AI -- 10-15 Min Viva Presentation &amp; Live Demo Guide | All Systems Production-Ready", s["dis"]))

    return st

if __name__ == "__main__":
    print("[BUILD] Generating MindSync Viva Presentation & Demo Guide PDF...")
    print(f"   Output: {OUTPUT_PATH}")

    doc = SimpleDocTemplate(
        OUTPUT_PATH, pagesize=letter,
        rightMargin=36, leftMargin=36, topMargin=36, bottomMargin=36,
        title="MindSync AI 15Min Viva Presentation Guide",
        author="MindSync AI",
        subject="10-15 Min Viva Presentation Script and Live Demo Walkthrough",
    )

    story = build_pdf()
    doc.build(story)

    kb = os.path.getsize(OUTPUT_PATH) / 1024
    print(f"[OK] PDF generated successfully! ({kb:.1f} KB)")
    print(f"[FILE] {OUTPUT_PATH}")
