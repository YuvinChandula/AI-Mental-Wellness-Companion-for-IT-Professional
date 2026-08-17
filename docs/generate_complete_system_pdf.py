import os
import sys
import datetime
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak, KeepTogether, HRFlowable
)
from reportlab.pdfgen import canvas

class NumberedCanvas(canvas.Canvas):
    """Two-pass canvas to dynamically compute and display total page counts and running headers/footers."""
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        num_pages = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self.draw_page_decorations(num_pages)
            super().showPage()
        super().save()

    def draw_page_decorations(self, page_count):
        self.saveState()
        
        # Omit header and footer on cover page (Page 1)
        if self._pageNumber > 1:
            # Header
            self.setFont("Helvetica-Bold", 8)
            self.setFillColor(colors.HexColor("#0D47A1")) # Dark Blue
            self.drawString(54, 750, "MINDSYNC AI — MASTER SYSTEM DOCUMENTATION & VIVA PREPARATION GUIDE")
            self.setStrokeColor(colors.HexColor("#90CAF9"))
            self.setLineWidth(0.75)
            self.line(54, 742, 558, 742)

            # Footer
            self.setFont("Helvetica", 8)
            self.setFillColor(colors.HexColor("#1565C0"))
            self.drawString(54, 36, "MindSync AI Wellness Companion for IT Professionals")
            page_str = f"Page {self._pageNumber} of {page_count}"
            self.drawRightString(558, 36, page_str)
            self.setStrokeColor(colors.HexColor("#E0E0E0"))
            self.setLineWidth(0.5)
            self.line(54, 46, 558, 46)

        self.restoreState()

def build_pdf(filename):
    doc = SimpleDocTemplate(
        filename,
        pagesize=letter,
        leftMargin=54,
        rightMargin=54,
        topMargin=54,
        bottomMargin=54
    )

    styles = getSampleStyleSheet()

    # Color Palette
    PRIMARY = colors.HexColor("#0D47A1")    # Deep Navy / Dark Blue
    SECONDARY = colors.HexColor("#1565C0")  # Royal Blue Accent
    ACCENT = colors.HexColor("#00838F")     # Dark Teal Accent
    DARK_TEXT = colors.HexColor("#212121")  # Dark Charcoal Body
    BG_LIGHT = colors.HexColor("#F5F7FA")   # Table / Block Background
    BOX_BORDER = colors.HexColor("#BBDEFB") # Border Blue
    CODE_BG = colors.HexColor("#ECEFF1")    # Light Grey Code BG

    # Typography Styles
    title_style = ParagraphStyle(
        'DocTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=24,
        leading=30,
        textColor=PRIMARY,
        spaceAfter=10
    )

    subtitle_style = ParagraphStyle(
        'DocSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=13,
        leading=17,
        textColor=ACCENT,
        spaceAfter=20
    )

    h1_style = ParagraphStyle(
        'H1',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=15,
        leading=19,
        textColor=PRIMARY,
        spaceBefore=16,
        spaceAfter=8,
        keepWithNext=True
    )

    h2_style = ParagraphStyle(
        'H2',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=11.5,
        leading=15,
        textColor=SECONDARY,
        spaceBefore=12,
        spaceAfter=6,
        keepWithNext=True
    )

    body_style = ParagraphStyle(
        'Body',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9,
        leading=13.5,
        textColor=DARK_TEXT,
        spaceAfter=6
    )

    bullet_style = ParagraphStyle(
        'Bullet',
        parent=body_style,
        leftIndent=12,
        firstLineIndent=-8,
        spaceAfter=4
    )

    code_style = ParagraphStyle(
        'CodeSnippet',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=8,
        leading=11,
        textColor=colors.HexColor("#263238"),
        backColor=CODE_BG,
        borderColor=BOX_BORDER,
        borderWidth=0.5,
        borderPadding=6,
        spaceBefore=4,
        spaceAfter=6
    )

    story = []

    # =========================================================================
    # TITLE & METADATA HEADER
    # =========================================================================
    story.append(Paragraph("MindSync AI — Master System Documentation & Viva Handbook", title_style))
    story.append(Paragraph("End-to-End Architectural Breakdown, Codefile Index, ML/XAI Formulations, & Feature Guides", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=2, color=PRIMARY, spaceAfter=15))

    meta = [
        [Paragraph("<b>System Name:</b> MindSync AI Wellness Companion", body_style), Paragraph("<b>Target Audience:</b> IT Professionals & Software Engineers", body_style)],
        [Paragraph("<b>Frontend Framework:</b> Flutter 3.x (Dart + Riverpod + Hive)", body_style), Paragraph("<b>Backend Framework:</b> FastAPI (Python 3.14 + Pydantic)", body_style)],
        [Paragraph("<b>ML & XAI Engine:</b> Random Forest + SHAP (Scikit-Learn)", body_style), Paragraph("<b>GenAI Model:</b> Llama 3.3 70B (via Groq LPUs)", body_style)],
        [Paragraph("<b>Cloud Backend Host:</b> Render Platform", body_style), Paragraph("<b>Live Backend URL:</b> https://ai-mental-wellness-companion-for-it.onrender.com/", body_style)]
    ]
    t_meta = Table(meta, colWidths=[250, 250])
    t_meta.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), BG_LIGHT),
        ('BOX', (0, 0), (-1, -1), 1, BOX_BORDER),
        ('PADDING', (0, 0), (-1, -1), 6),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    story.append(t_meta)
    story.append(Spacer(1, 12))

    # =========================================================================
    # SECTION 1: SYSTEM OVERVIEW & ARCHITECTURE
    # =========================================================================
    story.append(Paragraph("1. System Technical Overview & System Architecture", h1_style))
    story.append(Paragraph(
        "<b>MindSync AI</b> is a full-stack digital mental wellness platform designed specifically for software developers and IT professionals. It bridges the gap between hardware physical tracking (pedometer step count), subjective mental health reporting (mood, stress, sleep), machine learning risk forecasting (Random Forest), explainable AI (SHAP), and conversational AI coaching (Llama 3.3 70B via Groq).",
        body_style
    ))

    story.append(Paragraph("End-to-End System Architecture Pipeline:", h2_style))
    arch_box = """+-----------------------------------------------------------------------------------+
|                         1. MOBILE FRONTEND LAYER (FLUTTER)                        |
|  - UI Pages: Dashboard, Mood Logging, Burnout Predictor, AI Chatbot, Reports      |
|  - State Management: Riverpod (authStateProvider, dashboardProvider)              |
|  - Hardware Access: Pedometer (Step Counter) & Geolocator (Weather)              |
|  - Local Storage: Hive Key-Value Storage (authBox, settingsBox, moodSyncBox)      |
+------------------------------------------+----------------------------------------+
                                           | HTTP / REST API (Bearer Firebase Token)
                                           v
+-----------------------------------------------------------------------------------+
|                         2. BACKEND MICROSERVICES LAYER (FASTAPI)                  |
|  - Endpoints: /health, /api/predict/burnout, /api/recommendations/*, /api/analytics|
|  - Security & Auth: JWT Bearer Validation + Fallback Payload Decoder             |
|  - Firebase Service: Firebase Admin SDK + Firestore Database Sync                 |
+------------------------------------------+----------------------------------------+
                                           |
                    +----------------------+----------------------+
                    v                                             v
+---------------------------------------+     +---------------------------------------+
|  3. ML & XAI SUBSYSTEM                |     |  4. GENERATIVE AI & ORCHESTRATION     |
|  - Model: Random Forest Classifier    |     |  - Model: Llama 3.3 70B Versatile     |
|  - Features: 9 Telemetry Metrics      |     |  - Infrastructure: Groq LPU Hardware  |
|  - Explainability: SHAP Values        |     |  - Fallback: IT Wellness Rule System  |
+---------------------------------------+     +---------------------------------------+"""
    story.append(Paragraph(arch_box, code_style))
    story.append(Spacer(1, 10))

    # =========================================================================
    # SECTION 2: COMPLETE FILE INDEX & DIRECTORY BREAKDOWN
    # =========================================================================
    story.append(Paragraph("2. Complete Codebase File Inventory & Technical Directory", h1_style))
    story.append(Paragraph(
        "The project is structured into two main subsystems: the <b>Backend (FastAPI)</b> and the <b>Frontend (Flutter)</b>.",
        body_style
    ))

    files_table_data = [
        [Paragraph("<b>File / Component Path</b>", body_style), Paragraph("<b>Layer / Purpose</b>", body_style), Paragraph("<b>Key Responsibilities & Functions</b>", body_style)],
        # Backend Files
        [Paragraph("backend/app/main.py", body_style), Paragraph("Backend Entry", body_style), Paragraph("FastAPI app initialization, CORS middleware setup, router mounting for all API endpoints.", body_style)],
        [Paragraph("backend/app/core/security.py", body_style), Paragraph("Security", body_style), Paragraph("JWT Bearer token verification via Firebase Admin SDK + JWT payload fallback decoding for Render.", body_style)],
        [Paragraph("backend/app/core/firebase.py", body_style), Paragraph("Firebase Core", body_style), Paragraph("Firebase Admin SDK initialization with explicit projectId 'mindsync-ai-18fbb' and Firestore client.", body_style)],
        [Paragraph("backend/app/ml/pipeline.py", body_style), Paragraph("ML Pipeline", body_style), Paragraph("BurnoutPipeline class. Loads pre-trained Random Forest model, runs inference, and computes SHAP feature importance.", body_style)],
        [Paragraph("backend/app/ml/recommendation_engine.py", body_style), Paragraph("ML Recommendations", body_style), Paragraph("HybridRecommendationEngine class. Combines rule-based health checks + ML weights + Groq AI advice.", body_style)],
        [Paragraph("backend/app/services/ai_orchestrator.py", body_style), Paragraph("AI Orchestration", body_style), Paragraph("AIOrchestrator class. Executes Groq Llama 3.3 70B API calls with retry backoff and local caching.", body_style)],
        [Paragraph("backend/app/api/endpoints/predict.py", body_style), Paragraph("API Endpoint", body_style), Paragraph("POST /api/predict/burnout. Accepts 9-feature telemetry payload and returns ML burnout prediction + SHAP factors.", body_style)],
        [Paragraph("backend/app/api/endpoints/recommendations.py", body_style), Paragraph("API Endpoint", body_style), Paragraph("POST /api/recommendations/generate & /daily-summary. Generates personalized developer habits and summaries.", body_style)],
        [Paragraph("backend/app/api/endpoints/analytics.py", body_style), Paragraph("API Endpoint", body_style), Paragraph("POST /api/analytics/report/export. Generates formatted PDF binary stream report for users.", body_style)],
        # Frontend Files
        [Paragraph("frontend/lib/main.dart", body_style), Paragraph("Frontend Entry", body_style), Paragraph("Flutter app entry point, Firebase init, Riverpod ProviderScope wrap, global error catch guards.", body_style)],
        [Paragraph("frontend/lib/core/config/app_config.dart", body_style), Paragraph("App Config", body_style), Paragraph("Reads BACKEND_URL from .env (defaults to Render URL) and manages feature flags.", body_style)],
        [Paragraph("frontend/lib/core/network/dio_client.dart", body_style), Paragraph("Network Layer", body_style), Paragraph("Configures Dio HTTP client with base URL, timeouts (15s), and mounts AuthInterceptor.", body_style)],
        [Paragraph("frontend/lib/core/network/auth_interceptor.dart", body_style), Paragraph("Network Security", body_style), Paragraph("Intercepts outgoing HTTP calls, retrieves Firebase ID token from Hive authBox, and attaches Bearer header.", body_style)],
        [Paragraph("frontend/lib/core/services/pedometer_service.dart", body_style), Paragraph("Hardware Service", body_style), Paragraph("Subscribes to hardware Pedometer stepCountStream with smooth background step simulation fallback.", body_style)],
        [Paragraph("frontend/lib/features/authentication/", body_style), Paragraph("Auth Feature", body_style), Paragraph("Firebase authentication (SignIn, Register, Password Reset, Email Verification) with token persistence.", body_style)],
        [Paragraph("frontend/lib/features/chat/", body_style), Paragraph("Chat Feature", body_style), Paragraph("Empathetic AI Chatbot interface. Calls Groq Llama 3.3 with crisis safety overrides & IT wellness fallbacks.", body_style)],
        [Paragraph("frontend/lib/features/reports/", body_style), Paragraph("Reports Feature", body_style), Paragraph("PDF & CSV report export history panel. Uses OpenFilex & path_provider to auto-open files upon download.", body_style)]
    ]
    t_files = Table(files_table_data, colWidths=[130, 90, 280])
    t_files.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), PRIMARY),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('GRID', (0, 0), (-1, -1), 0.5, BOX_BORDER),
        ('PADDING', (0, 0), (-1, -1), 4),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, BG_LIGHT])
    ]))
    story.append(t_files)
    story.append(Spacer(1, 12))

    # =========================================================================
    # SECTION 3: USER GUIDE FOR ALL FEATURES
    # =========================================================================
    story.append(Paragraph("3. Comprehensive User Guide for All System Features", h1_style))

    features_list = [
        ("Dashboard & Hardware Pedometer Tracking",
         "When the app opens, the Dashboard displays real-time biometric metrics. The hardware Pedometer automatically counts steps in the background using device accelerometer sensors and updates the daily step progress bar (Goal: 10,000 steps). Weather data is fetched using local geolocation coordinates."),

        ("Daily Mood & Biometric Check-In",
         "Users tap 'Log Mood' to record their daily psychological state (1-10 scale: Stressed, Stable, Happy, Anxious, Exhausted), sleep duration, hydration (ml/glasses), and active exercise minutes. Data is synced to Firebase Firestore and cached locally in Hive."),

        ("ML Burnout Risk Predictor",
         "Users navigate to the Burnout Predictor screen and submit their daily metrics. The app sends the 9-feature telemetry vector to the backend Random Forest classifier, returning an instant Burnout Risk % (Low, Medium, High) alongside SHAP Explainable AI contributing factors (e.g. '+35% risk from 13h work day')."),

        ("Empathetic AI Chatbot",
         "Users can start an interactive conversation with MindSync AI. The chatbot utilizes Llama 3.3 70B to provide developer-specific wellness advice (managing pull request stress, screen breaks, sleep hygiene). If crisis keywords like 'suicide' are detected, the app immediately overrides with 988 Crisis Lifeline resources."),

        ("PDF & CSV Report Export",
         "Users can generate comprehensive weekly or monthly PDF/CSV health summaries. Upon download, the app uses OpenFilex and path_provider to automatically open the generated PDF document directly on the user's mobile device.")
    ]

    for title, desc in features_list:
        story.append(Paragraph(f"• <b>{title}:</b> {desc}", bullet_style))
        story.append(Spacer(1, 2))
    story.append(Spacer(1, 10))

    # =========================================================================
    # SECTION 4: MATHEMATICAL FORMULATIONS & ML PIPELINE
    # =========================================================================
    story.append(Paragraph("4. Mathematical Formulations & ML Pipeline", h1_style))
    story.append(Paragraph(
        "<b>Random Forest Classifier Equations:</b><br/>"
        "1. Entropy: <i>H(S) = - ∑ [ p_i * log2(p_i) ]</i><br/>"
        "2. Information Gain: <i>IG(S, A) = H(S) - ∑ [ (|S_v| / |S|) * H(S_v) ]</i><br/>"
        "3. Gini Impurity: <i>Gini(S) = 1 - ∑ (p_i)^2</i>",
        body_style
    ))
    story.append(Paragraph(
        "<b>SHAP Explainable AI (Shapley Value Formulation):</b><br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;<i>ϕ_i(v) = ∑ [ (|S|! * (|N| - |S| - 1)!) / |N|! ] * [ v(S ∪ {i}) - v(S) ]</i>",
        body_style
    ))
    story.append(Spacer(1, 10))

    # =========================================================================
    # SECTION 5: VIVA PRESENTATION GUIDE & EXAMINER Q&A
    # =========================================================================
    story.append(PageBreak()) # Clean break for Viva Guide
    story.append(Paragraph("5. Viva Presentation Cheat Sheet & Examiner Q&A Guide", h1_style))
    
    story.append(Paragraph("30-Second Elevator Pitch:", h2_style))
    story.append(Paragraph(
        "<i>\"MindSync AI is an intelligent mental wellness shield designed for software developers. It collects biometric telemetry like sleep, steps, and stress, passes them through a Random Forest Machine Learning classifier to predict burnout risk, uses SHAP Explainable AI to pinpoint exact root causes, and leverages Groq-accelerated Llama 3.3 LLMs to deliver real-time actionable developer coaching.\"</i>",
        ParagraphStyle('StoryQuote', parent=body_style, fontName='Helvetica-Oblique', textColor=PRIMARY, backColor=BG_LIGHT, borderPadding=8)
    ))
    story.append(Spacer(1, 10))

    qa = [
        ("Q1: How does authentication work between Flutter and FastAPI on Render?",
         "Answer: Flutter uses Firebase Auth to log in users. Upon login, the Firebase ID token is persisted in Hive. Every outgoing Dio HTTP request attaches this token as a Bearer header. FastAPI verifies the token via Firebase Admin SDK, with a JWT payload fallback decoder if service account keys are absent on Render."),

        ("Q2: Why did you use Random Forest instead of a Deep Learning Neural Network?",
         "Answer: Random Forest provides superior classification accuracy on tabular biometric data of moderate sample size without overfitting. More importantly, tree ensembles integrate directly with SHAP for exact Explainable AI attribution, whereas neural networks act as opaque black boxes."),

        ("Q3: How does the step counter work automatically?",
         "Answer: The app uses pedometer_service.dart which listens to device accelerometer sensors via Pedometer.stepCountStream. If hardware sensors are unavailable (such as in emulators), it smoothly falls back to a realistic step simulation engine so the UI never crashes."),

        ("Q4: How do you handle API key failures or offline mode?",
         "Answer: The app has a multi-tier fallback architecture. If Groq API keys are unconfigured or network requests fail, the app identifies placeholder patterns ('your_', 'mock_') and seamlessly falls back to local intelligent IT wellness rules and Hive cached data."),

        ("Q5: How does report auto-opening work after export?",
         "Answer: Upon downloading a PDF or CSV report, the app saves the file to local device storage using path_provider and immediately invokes OpenFilex.open(file.path) to trigger the device's native PDF reader automatically.")
    ]

    for q, a in qa:
        story.append(Paragraph(f"<b>{q}</b>", ParagraphStyle('QStyle', parent=body_style, fontName='Helvetica-Bold', textColor=SECONDARY)))
        story.append(Paragraph(f"<i>{a}</i>", ParagraphStyle('AStyle', parent=body_style, leftIndent=10, spaceAfter=8)))

    # Build Document
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"SUCCESS: Generated Complete System PDF Guide at: {filename}")

if __name__ == "__main__":
    out_dir = os.path.join(os.getcwd(), "docs")
    os.makedirs(out_dir, exist_ok=True)
    pdf_path = os.path.join(out_dir, "MindSync_AI_Complete_System_Documentation_And_Viva_Mastery_Guide.pdf")
    build_pdf(pdf_path)
