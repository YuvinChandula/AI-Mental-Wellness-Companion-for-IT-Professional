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
            self.drawString(54, 750, "MINDSYNC AI — EXHAUSTIVE SYSTEM & CODE MASTERBOOK")
            self.setStrokeColor(colors.HexColor("#90CAF9"))
            self.setLineWidth(0.75)
            self.line(54, 742, 558, 742)

            # Footer
            self.setFont("Helvetica", 8)
            self.setFillColor(colors.HexColor("#1565C0"))
            self.drawString(54, 36, "MindSync AI Wellness Companion — Complete Viva & Technical Master Reference")
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

    # Palette
    PRIMARY = colors.HexColor("#0D47A1")    # Deep Navy
    SECONDARY = colors.HexColor("#1565C0")  # Royal Blue Accent
    ACCENT = colors.HexColor("#00838F")     # Dark Teal Accent
    DARK_TEXT = colors.HexColor("#212121")  # Dark Charcoal Body
    BG_LIGHT = colors.HexColor("#F5F7FA")   # Card Background
    BOX_BORDER = colors.HexColor("#BBDEFB") # Border Blue
    CODE_BG = colors.HexColor("#ECEFF1")    # Light Grey Code BG

    # Typography Styles
    title_style = ParagraphStyle(
        'DocTitle', parent=styles['Normal'],
        fontName='Helvetica-Bold', fontSize=24, leading=30, textColor=PRIMARY, spaceAfter=8
    )

    subtitle_style = ParagraphStyle(
        'DocSubtitle', parent=styles['Normal'],
        fontName='Helvetica', fontSize=12, leading=16, textColor=ACCENT, spaceAfter=18
    )

    h1_style = ParagraphStyle(
        'H1', parent=styles['Normal'],
        fontName='Helvetica-Bold', fontSize=14, leading=18, textColor=PRIMARY,
        spaceBefore=14, spaceAfter=6, keepWithNext=True
    )

    h2_style = ParagraphStyle(
        'H2', parent=styles['Normal'],
        fontName='Helvetica-Bold', fontSize=11, leading=15, textColor=SECONDARY,
        spaceBefore=10, spaceAfter=4, keepWithNext=True
    )

    body_style = ParagraphStyle(
        'Body', parent=styles['Normal'],
        fontName='Helvetica', fontSize=8.5, leading=12.5, textColor=DARK_TEXT, spaceAfter=5
    )

    bullet_style = ParagraphStyle(
        'Bullet', parent=body_style,
        leftIndent=12, firstLineIndent=-8, spaceAfter=3
    )

    code_style = ParagraphStyle(
        'CodeSnippet', parent=styles['Normal'],
        fontName='Courier', fontSize=7.5, leading=10, textColor=colors.HexColor("#263238"),
        backColor=CODE_BG, borderColor=BOX_BORDER, borderWidth=0.5, borderPadding=5,
        spaceBefore=4, spaceAfter=6
    )

    story = []

    # =========================================================================
    # COVER / HEADER METADATA
    # =========================================================================
    story.append(Paragraph("MindSync AI — Exhaustive Codebase & Technical MasterBook", title_style))
    story.append(Paragraph("Complete Line-by-Line Architecture, Codefile Manual, Feature Operating Guides, & Viva Defense Handbook", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=2, color=PRIMARY, spaceAfter=12))

    meta = [
        [Paragraph("<b>System Name:</b> MindSync AI Wellness Companion", body_style), Paragraph("<b>Target Audience:</b> IT Professionals & Software Engineers", body_style)],
        [Paragraph("<b>Frontend Stack:</b> Flutter 3.x, Dart 3.x, Riverpod, Hive", body_style), Paragraph("<b>Backend Stack:</b> FastAPI, Python 3.14, Pydantic", body_style)],
        [Paragraph("<b>ML & XAI Engine:</b> Random Forest + SHAP (Scikit-Learn)", body_style), Paragraph("<b>GenAI Acceleration:</b> Groq LPUs (Llama 3.3 70B)", body_style)],
        [Paragraph("<b>Deployment Platform:</b> Render Cloud Platform", body_style), Paragraph("<b>Live Backend:</b> https://ai-mental-wellness-companion-for-it.onrender.com/", body_style)]
    ]
    t_meta = Table(meta, colWidths=[250, 250])
    t_meta.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), BG_LIGHT),
        ('BOX', (0, 0), (-1, -1), 1, BOX_BORDER),
        ('PADDING', (0, 0), (-1, -1), 5),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    story.append(t_meta)
    story.append(Spacer(1, 10))

    # =========================================================================
    # SECTION 1: EXECUTIVE OVERVIEW & ARCHITECTURE
    # =========================================================================
    story.append(Paragraph("1. System Technical Overview & Microservices Architecture", h1_style))
    story.append(Paragraph(
        "<b>MindSync AI</b> is a preventive digital health shield engineered specifically to reduce IT developer burnout, sedentary desk exhaustion, and workplace mental fatigue. The system integrates hardware accelerometer sensors, subjective biometric telemetry, machine learning risk classification, explainable AI, and generative language models into a cohesive, high-throughput platform.",
        body_style
    ))

    arch_text = """+-----------------------------------------------------------------------------------+
|                         FLUTTER MOBILE FRONTEND LAYER                             |
|  - UI Pages: Dashboard, Mood Logging, Burnout Predictor, AI Chatbot, Reports      |
|  - State Management: Riverpod (authStateProvider, dashboardProviders)             |
|  - Hardware Sensors: Pedometer (Step Stream) & Geolocator (Weather)               |
|  - Storage: Hive Key-Value Storage (authBox, settingsBox, moodSyncBox)            |
+------------------------------------------+----------------------------------------+
                                           | HTTP / REST API (Bearer Firebase Token)
                                           v
+-----------------------------------------------------------------------------------+
|                         FASTAPI BACKEND MICROSERVICES LAYER                       |
|  - Security & Auth: JWT Bearer Validation + Fallback Payload Decoder              |
|  - Endpoints: /health, /api/predict/burnout, /api/recommendations/*, /api/analytics|
|  - Firebase Admin SDK: Project 'mindsync-ai-18fbb' Sync                            |
+------------------------------------------+----------------------------------------+
                                           |
                    +----------------------+----------------------+
                    v                                             v
+---------------------------------------+     +---------------------------------------+
|  ML & XAI SUBSYSTEM                   |     |  GENERATIVE AI & LLM ORCHESTRATION    |
|  - Model: Random Forest Classifier    |     |  - Model: Llama 3.3 70B Versatile     |
|  - Features: 9 Telemetry Metrics      |     |  - Hardware: Groq LPU Accelerated     |
|  - Explainability: SHAP Values        |     |  - Safety: 988 Crisis Override        |
+---------------------------------------+     +---------------------------------------+"""
    story.append(Paragraph(arch_text, code_style))
    story.append(Spacer(1, 8))

    # =========================================================================
    # SECTION 2: COMPLETE FILE INVENTORY
    # =========================================================================
    story.append(Paragraph("2. Complete Codebase File Inventory & Architecture Map", h1_style))
    
    file_map_data = [
        [Paragraph("<b>File Path</b>", body_style), Paragraph("<b>Subsystem</b>", body_style), Paragraph("<b>Lines / Size</b>", body_style), Paragraph("<b>Detailed Code Function & Purpose</b>", body_style)],
        # Backend
        [Paragraph("backend/app/main.py", body_style), Paragraph("Backend", body_style), Paragraph("65 lines", body_style), Paragraph("FastAPI app instance creation, CORS middleware setup, router mounting (/health, /api/predict, /api/recommendations, /api/analytics).", body_style)],
        [Paragraph("backend/app/core/security.py", body_style), Paragraph("Backend", body_style), Paragraph("45 lines", body_style), Paragraph("JWT Bearer validation. Verifies Firebase ID tokens via Firebase Admin SDK; includes _decode_jwt_payload_fallback for Render cloud execution.", body_style)],
        [Paragraph("backend/app/core/firebase.py", body_style), Paragraph("Backend", body_style), Paragraph("52 lines", body_style), Paragraph("FirebaseService singleton class. Initializes Firebase Admin SDK with explicit projectId 'mindsync-ai-18fbb' and Firestore db client.", body_style)],
        [Paragraph("backend/app/ml/pipeline.py", body_style), Paragraph("Backend ML", body_style), Paragraph("110 lines", body_style), Paragraph("BurnoutPipeline class. Loads pre-trained Random Forest model, runs inference on 9-feature telemetry vector, and computes SHAP feature importance.", body_style)],
        [Paragraph("backend/app/ml/recommendation_engine.py", body_style), Paragraph("Backend ML", body_style), Paragraph("300 lines", body_style), Paragraph("HybridRecommendationEngine class. Evaluates rule-based health checks + ML risk weights + Groq AI generative recommendations.", body_style)],
        [Paragraph("backend/app/services/ai_orchestrator.py", body_style), Paragraph("Backend Service", body_style), Paragraph("91 lines", body_style), Paragraph("AIOrchestrator class. Executes Groq Llama 3.3 70B API requests with exponential retry backoff and CacheService TTL integration.", body_style)],
        [Paragraph("backend/app/api/endpoints/predict.py", body_style), Paragraph("Backend API", body_style), Paragraph("66 lines", body_style), Paragraph("POST /api/predict/burnout endpoint. Pydantic request validation for 9 biometric parameters, returns risk category and SHAP factors.", body_style)],
        [Paragraph("backend/app/api/endpoints/recommendations.py", body_style), Paragraph("Backend API", body_style), Paragraph("138 lines", body_style), Paragraph("POST /api/recommendations/generate & /daily-summary endpoints. Formats metrics and yields personalized developer lifestyle habits.", body_style)],
        [Paragraph("backend/app/api/endpoints/analytics.py", body_style), Paragraph("Backend API", body_style), Paragraph("570 lines", body_style), Paragraph("POST /api/analytics/report/export endpoint. Generates formatted 2.9KB PDF binary stream document using ReportLab for client download.", body_style)],
        # Frontend
        [Paragraph("frontend/lib/main.dart", body_style), Paragraph("Frontend", body_style), Paragraph("107 lines", body_style), Paragraph("Flutter app entry point. Initializes WidgetsBinding, Firebase, StorageService, loads .env, wraps Riverpod ProviderScope, mounts error guards.", body_style)],
        [Paragraph("frontend/lib/core/config/app_config.dart", body_style), Paragraph("Frontend Core", body_style), Paragraph("25 lines", body_style), Paragraph("Reads BACKEND_URL from .env (default: Render URL), API keys, responsive layout breakpoints, and demoMode toggle.", body_style)],
        [Paragraph("frontend/lib/core/network/dio_client.dart", body_style), Paragraph("Frontend Network", body_style), Paragraph("91 lines", body_style), Paragraph("Configures Dio HTTP client with base URL, 15s connect/receive timeouts, LogInterceptor, and mounts AuthInterceptor.", body_style)],
        [Paragraph("frontend/lib/core/network/auth_interceptor.dart", body_style), Paragraph("Frontend Security", body_style), Paragraph("23 lines", body_style), Paragraph("Intercepts outgoing HTTP calls, fetches stored Firebase ID token from Hive authBox, and attaches Authorization: Bearer header.", body_style)],
        [Paragraph("frontend/lib/core/services/pedometer_service.dart", body_style), Paragraph("Frontend Service", body_style), Paragraph("85 lines", body_style), Paragraph("Hardware Pedometer stepCountStream subscriber. Persists step count in Hive and falls back smoothly to realistic step simulation.", body_style)],
        [Paragraph("frontend/lib/features/authentication/", body_style), Paragraph("Frontend Auth", body_style), Paragraph("208 lines", body_style), Paragraph("FirebaseAuthDataSourceImpl & AuthNotifier. Handles sign in, sign up, password reset, email verification, and token persistence.", body_style)],
        [Paragraph("frontend/lib/features/chat/", body_style), Paragraph("Frontend Chat", body_style), Paragraph("238 lines", body_style), Paragraph("ChatRemoteDataSourceImpl. AI Chat interface. Calls Groq Llama 3.3 70B with crisis safety overrides & IT wellness fallbacks.", body_style)],
        [Paragraph("frontend/lib/features/reports/", body_style), Paragraph("Frontend Reports", body_style), Paragraph("163 lines", body_style), Paragraph("ReportHistoryPanel widget. Downloads PDF/CSV report streams and uses OpenFilex & path_provider to auto-open files on device.", body_style)]
    ]
    t_fmap = Table(file_map_data, colWidths=[120, 60, 60, 260])
    t_fmap.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), PRIMARY),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('GRID', (0, 0), (-1, -1), 0.5, BOX_BORDER),
        ('PADDING', (0, 0), (-1, -1), 4),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, BG_LIGHT])
    ]))
    story.append(t_fmap)
    story.append(Spacer(1, 10))

    # =========================================================================
    # SECTION 3: LINE-BY-LINE EXPLANATION OF CORE FILES
    # =========================================================================
    story.append(Paragraph("3. Detailed File-by-File & Line-by-Line Code Explanations", h1_style))

    # Code 1: backend/app/core/security.py
    story.append(Paragraph("3.1 Backend Security & JWT Fallback (security.py)", h2_style))
    story.append(Paragraph(
        "<b>Purpose:</b> Authenticates every incoming HTTP request. Verifies Firebase JWT tokens using Firebase Admin SDK and provides a fallback JWT payload decoder for cloud deployment on Render.",
        body_style
    ))
    sec_code = """def _decode_jwt_payload_fallback(token: str) -> Optional[str]:
    # Decodes raw JWT payload (header.payload.signature) if Firebase Admin lacks service account JSON on Render
    try:
        parts = token.split('.')
        if len(parts) == 3:
            payload_b64 = parts[1] + '=' * (-len(parts[1]) % 4) # Add base64 padding
            payload_data = json.loads(base64.b64decode(payload_b64).decode('utf-8'))
            return payload_data.get("user_id") or payload_data.get("sub") or payload_data.get("uid")
    except Exception:
        pass
    return None"""
    story.append(Paragraph(sec_code, code_style))

    # Code 2: backend/app/ml/pipeline.py
    story.append(Paragraph("3.2 Random Forest ML & SHAP XAI Pipeline (pipeline.py)", h2_style))
    story.append(Paragraph(
        "<b>Purpose:</b> Executes supervised machine learning inference on the 9-feature telemetry vector and calculates SHAP values to explain feature contributions.",
        body_style
    ))
    ml_code = """class BurnoutPipeline:
    def predict(self, features: dict) -> dict:
        # Construct feature DataFrame matching exact trained feature ordering
        X = pd.DataFrame([features])
        prob = float(self.model.predict_proba(X)[0][1]) * 100.0 # Calculate Risk %
        risk_level = "High" if prob >= 70.0 else ("Medium" if prob >= 40.0 else "Low")
        
        # Calculate SHAP Shapley values for Explainable AI (XAI)
        explainer = shap.TreeExplainer(self.model)
        shap_values = explainer.shap_values(X)
        important_factors = self._extract_top_factors(shap_values, X)
        return {"burnoutRisk": risk_level, "riskScore": prob, "importantFactors": important_factors}"""
    story.append(Paragraph(ml_code, code_style))

    # Code 3: frontend/lib/core/network/auth_interceptor.dart
    story.append(Paragraph("3.3 Frontend Auth Interceptor (auth_interceptor.dart)", h2_style))
    story.append(Paragraph(
        "<b>Purpose:</b> Intercepts all outgoing HTTP requests from the mobile app and attaches the stored Firebase ID token as a Bearer authorization header.",
        body_style
    ))
    interceptor_code = """class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (Hive.isBoxOpen(AppConstants.authBoxName)) {
      final authBox = Hive.box(AppConstants.authBoxName);
      final token = authBox.get(AppConstants.keyJwtToken) as String?;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token'; // Attach Firebase Bearer token
      }
    }
    super.onRequest(options, handler);
  }
}"""
    story.append(Paragraph(interceptor_code, code_style))
    story.append(Spacer(1, 10))

    # =========================================================================
    # SECTION 4: EXHAUSTIVE FEATURE USER GUIDES
    # =========================================================================
    story.append(Paragraph("4. Exhaustive Operating Guides for All Application Features", h1_style))

    guides = [
        ("Feature 1: User Authentication & Session Persistence",
         "Users register or log in using email and password. Upon sign-in, FirebaseAuthDataSourceImpl retrieves the user's Firebase ID token and stores it securely in Hive's authBox (key: 'jwt_token'). If the app is closed and reopened, getCurrentUser() automatically restores the token and verifies email verification status. Auto-signout triggers after 15 minutes of inactivity."),

        ("Feature 2: Dashboard & Real-Time Step Counter",
         "The Dashboard displays the daily wellness score, steps progress bar, weather card, and motivational quote. Hardware step counting is managed by pedometer_service.dart. It listens to Pedometer.stepCountStream and saves steps in Hive. If run in an emulator without hardware sensors, it smoothly generates realistic step updates so tests pass cleanly."),

        ("Feature 3: Daily Mood & Biometric Check-In",
         "Users tap 'Log Mood' to enter their daily metrics: Mood Rating (1-10 scale), Sleep Duration (hours), Stress Level (1-10), Water Intake (ml/glasses), and Active Exercise Minutes. Submitting syncs data to Firebase Firestore and triggers an automatic refresh of analytics trends."),

        ("Feature 4: Supervised ML Burnout Risk Forecast & SHAP XAI",
         "Users access the Burnout Predictor screen to calculate their burnout index. The app sends a 9-parameter vector to POST /api/predict/burnout on Render. The backend Random Forest model outputs the burnout probability % and displays top SHAP attribution factors (e.g. '+35% risk from 13h work day')."),

        ("Feature 5: AI Chatbot & Crisis Safety Overrides",
         "Users open the AI Chat tab to interact with MindSync AI. The chatbot calls Llama 3.3 70B via Groq LPUs. If crisis keywords like 'suicide', 'harm myself', or 'want to die' are detected, the app immediately intercepts the prompt locally and returns 988 Suicide & Crisis Lifeline contact resources."),

        ("Feature 6: Analytics & Automatic PDF/CSV Report Opening",
         "Users select time ranges (7 Days, 30 Days, Custom) on the Reports page. Tapping 'Export PDF' sends a request to POST /api/analytics/report/export. The backend generates a formatted 2.9KB PDF binary stream. Upon download, the app uses path_provider to save the file and OpenFilex.open(file.path) to automatically open the PDF viewer on the device.")
    ]

    for g_title, g_desc in guides:
        story.append(Paragraph(f"• <b>{g_title}:</b>", h2_style))
        story.append(Paragraph(g_desc, body_style))
        story.append(Spacer(1, 2))
    story.append(Spacer(1, 10))

    # =========================================================================
    # SECTION 5: MATHEMATICAL FORMULATIONS & PROOFS
    # =========================================================================
    story.append(Paragraph("5. Complete Mathematical Formulations & ML Proofs", h1_style))
    story.append(Paragraph(
        "<b>1. Entropy (Information Theory):</b><br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;<b>H(S) = - ∑ [ p_i * log2(p_i) ]</b><br/>"
        "Quantifies impurity in dataset <i>S</i> across target risk categories (Low, Medium, High).",
        body_style
    ))
    story.append(Paragraph(
        "<b>2. Information Gain:</b><br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;<b>IG(S, A) = H(S) - ∑ [ (|S_v| / |S|) * H(S_v) ]</b><br/>"
        "Measures reduction in entropy when splitting decision trees on biometric feature <i>A</i> (e.g. sleep hours).",
        body_style
    ))
    story.append(Paragraph(
        "<b>3. Gini Impurity:</b><br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;<b>Gini(S) = 1 - ∑ (p_i)^2</b><br/>"
        "Used by Scikit-Learn Random Forest Classifier as node splitting metric to minimize sub-tree variance.",
        body_style
    ))
    story.append(Paragraph(
        "<b>4. SHAP Shapley Values (Game Theory):</b><br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;<b>ϕ_i(v) = ∑ [ (|S|! * (|N| - |S| - 1)!) / |N|! ] * [ v(S ∪ {i}) - v(S) ]</b><br/>"
        "Calculates exact marginal feature attribution for every individual prediction.",
        body_style
    ))
    story.append(Spacer(1, 10))

    # =========================================================================
    # SECTION 6: VIVA DEFENSE MASTERSCRIPT & EXAMINER Q&A
    # =========================================================================
    story.append(PageBreak()) # Clean break for Viva Masterbook
    story.append(Paragraph("6. Viva Presentation Defense MasterScript & Examiner Q&A", h1_style))

    story.append(Paragraph("5-Step Presentation Storyline for Viva Examination:", h2_style))
    story_steps = [
        ("Step 1: The Problem", "Developer burnout is at an all-time high due to tight sprint deadlines, sedentary desk hours, code review stress, and context switching. Generic apps only offer manual journaling without predictive technology."),
        ("Step 2: The Solution", "MindSync AI acts as a preventive digital health shield. It combines hardware step tracking, subjective mood logs, supervised ML prediction, explainable AI, and generative LLMs."),
        ("Step 3: The Architecture", "Flutter frontend communicating asynchronously via Firebase JWT Bearer tokens to a FastAPI microservices backend deployed on Render, powered by Random Forest and Groq-accelerated Llama 3.3."),
        ("Step 4: Key Technical Highlights", "SHAP XAI for transparent risk attribution, hardware pedometer stream fallback, automated PDF report generation and auto-opening via OpenFilex, and local 988 crisis safety overrides."),
        ("Step 5: Enterprise Impact", "Scalable B2B SaaS model targeting IT organizations to reduce developer turnover, lower absenteeism, and improve software engineering productivity.")
    ]
    for s_title, s_desc in story_steps:
        story.append(Paragraph(f"• <b>{s_title}:</b> {s_desc}", bullet_style))
    story.append(Spacer(1, 8))

    story.append(Paragraph("Top 10 Technical Viva Questions & Examiner Defense Answers:", h2_style))
    viva_qa = [
        ("Q1: How does authentication work between Flutter and FastAPI on Render?",
         "Answer: Flutter uses Firebase Auth for user login. Upon login, the ID token is persisted in Hive (authBox). Every outgoing Dio HTTP request attaches this token as a Bearer header. FastAPI verifies the token via Firebase Admin SDK, with a JWT payload fallback decoder if service account keys are absent on Render."),

        ("Q2: Why did you choose Random Forest instead of Deep Learning (Neural Networks)?",
         "Answer: Random Forest provides superior classification accuracy on tabular biometric data without overfitting. More importantly, tree ensembles integrate directly with SHAP for exact Explainable AI (XAI) attribution, whereas neural networks act as opaque black boxes."),

        ("Q3: What is the purpose of SHAP values in your system?",
         "Answer: SHAP values provide game-theoretic mathematical proof for why a user received a specific burnout risk score. It explains whether high work hours (+35%) or poor sleep (+25%) contributed more to their stress, providing actionable transparency."),

        ("Q4: How does the step counter work automatically?",
         "Answer: The app uses pedometer_service.dart which listens to hardware accelerometer sensors via Pedometer.stepCountStream. If hardware sensors are absent (e.g. emulators), it smoothly falls back to a realistic step simulation engine so the UI never crashes."),

        ("Q5: How do you handle API key failures or offline mode?",
         "Answer: The app features a multi-tiered fallback architecture. If Groq API keys are unconfigured or network requests fail, the app identifies placeholder patterns ('your_', 'mock_') and seamlessly falls back to local intelligent IT wellness rules and Hive cached data."),

        ("Q6: How does report auto-opening work after export?",
         "Answer: Upon downloading a PDF or CSV report, the app saves the file to local device storage using path_provider and immediately invokes OpenFilex.open(file.path) to launch the native PDF reader automatically."),

        ("Q7: How do you enforce crisis safety for self-harm keywords?",
         "Answer: Before sending prompts to Groq LLM, chat_remote_datasource.dart checks for crisis keywords ('suicide', 'kill myself', 'want to die'). If detected, it immediately overrides with 988 Suicide & Crisis Lifeline resources without invoking external APIs."),

        ("Q8: How is state managed across Flutter screens?",
         "Answer: We use Riverpod (authStateProvider, dashboardProviders, analyticsSummaryStateProvider). It provides reactive, immutable state management with dependency injection and easy unit testing."),

        ("Q9: What is the role of Hive storage in your architecture?",
         "Answer: Hive is a lightweight, fast key-value database written in pure Dart. It caches authentication tokens, user settings, offline mood logs, and dashboard summaries for instant app startups and offline support."),

        ("Q10: What is the deployment architecture on Render?",
         "Answer: FastAPI backend is containerized and hosted on Render. Render watches our main Git branch and automatically redeploys microservices whenever changes are pushed to GitHub.")
    ]

    for q, a in viva_qa:
        story.append(Paragraph(f"<b>{q}</b>", ParagraphStyle('QStyle', parent=body_style, fontName='Helvetica-Bold', textColor=SECONDARY)))
        story.append(Paragraph(f"<i>{a}</i>", ParagraphStyle('AStyle', parent=body_style, leftIndent=10, spaceAfter=6)))

    # Build Document
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"SUCCESS: Generated Exhaustive MasterBook PDF at: {filename}")

if __name__ == "__main__":
    out_dir = os.path.join(os.getcwd(), "docs")
    os.makedirs(out_dir, exist_ok=True)
    pdf_path = os.path.join(out_dir, "MindSync_AI_Exhaustive_System_Code_Documentation_And_Viva_MasterBook.pdf")
    build_pdf(pdf_path)
