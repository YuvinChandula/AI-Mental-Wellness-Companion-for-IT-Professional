import os
import sys
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
            self.setFillColor(colors.HexColor("#1A237E")) # Deep Navy
            self.drawString(54, 750, "MINDSYNC AI — TECHNICAL MASTERY GUIDE: AI & ML SUBSYSTEMS")
            self.setStrokeColor(colors.HexColor("#C5CAE9"))
            self.setLineWidth(0.75)
            self.line(54, 742, 558, 742)

            # Footer
            self.setFont("Helvetica", 8)
            self.setFillColor(colors.HexColor("#5C6BC0"))
            self.drawString(54, 36, "MindSync AI Mental Wellness Companion for IT Professionals")
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

    # Custom Color Palette
    PRIMARY = colors.HexColor("#1A237E")    # Deep Navy / Slate Blue
    SECONDARY = colors.HexColor("#0D47A1")  # Dark Blue Accent
    ACCENT = colors.HexColor("#00838F")     # Dark Teal / Cyber Accent
    DARK_TEXT = colors.HexColor("#212121")  # Off-black body
    BG_LIGHT = colors.HexColor("#F5F7FA")   # Card Background
    BOX_BORDER = colors.HexColor("#C5CAE9") # Light Slate Border

    # Custom Typography Styles
    title_style = ParagraphStyle(
        'CoverTitle',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=26,
        leading=32,
        textColor=PRIMARY,
        alignment=0,
        spaceAfter=10
    )

    subtitle_style = ParagraphStyle(
        'CoverSubtitle',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=14,
        leading=18,
        textColor=ACCENT,
        alignment=0,
        spaceAfter=25
    )

    h1_style = ParagraphStyle(
        'SectionH1',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=16,
        leading=20,
        textColor=PRIMARY,
        spaceBefore=18,
        spaceAfter=8,
        keepWithNext=True
    )

    h2_style = ParagraphStyle(
        'SectionH2',
        parent=styles['Normal'],
        fontName='Helvetica-Bold',
        fontSize=12,
        leading=16,
        textColor=SECONDARY,
        spaceBefore=12,
        spaceAfter=6,
        keepWithNext=True
    )

    body_style = ParagraphStyle(
        'BodyDark',
        parent=styles['Normal'],
        fontName='Helvetica',
        fontSize=9.5,
        leading=14,
        textColor=DARK_TEXT,
        spaceAfter=8
    )

    bullet_style = ParagraphStyle(
        'BulletDark',
        parent=body_style,
        leftIndent=15,
        firstLineIndent=-10,
        spaceAfter=4
    )

    code_style = ParagraphStyle(
        'CodeSnippet',
        parent=styles['Normal'],
        fontName='Courier',
        fontSize=8.5,
        leading=11,
        textColor=colors.HexColor("#1B5E20"),
        backColor=colors.HexColor("#E8F5E9"),
        borderColor=colors.HexColor("#A5D6A7"),
        borderWidth=0.5,
        borderPadding=6,
        spaceBefore=6,
        spaceAfter=8
    )

    callout_style = ParagraphStyle(
        'CalloutText',
        parent=body_style,
        fontSize=9,
        leading=13,
        textColor=colors.HexColor("#0D47A1")
    )

    story = []

    # =========================================================================
    # COVER PAGE / HEADER BLOCK
    # =========================================================================
    story.append(Spacer(1, 15))
    story.append(Paragraph("MindSync AI — Complete AI & ML Technical Mastery Guide", title_style))
    story.append(Paragraph("Architectural Blueprints, Mathematical Formulations, XAI Explanations, & Viva Presentation Handbook", subtitle_style))
    story.append(HRFlowable(width="100%", thickness=2, color=PRIMARY, spaceAfter=15))

    meta_table_data = [
        [Paragraph("<b>Target Domain:</b> IT & Software Developer Mental Health", body_style), Paragraph("<b>ML Paradigm:</b> Supervised Ensemble + XAI + LLMs", body_style)],
        [Paragraph("<b>Primary Model:</b> Random Forest Classifier + SHAP", body_style), Paragraph("<b>GenAI Model:</b> Llama 3.3 70B (via Groq LPUs)", body_style)],
        [Paragraph("<b>Frameworks:</b> Scikit-Learn, FastAPI, Flutter, Hive", body_style), Paragraph("<b>Deployed Backend:</b> Render Cloud Platform", body_style)]
    ]
    t_meta = Table(meta_table_data, colWidths=[250, 250])
    t_meta.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), BG_LIGHT),
        ('BOX', (0, 0), (-1, -1), 1, BOX_BORDER),
        ('PADDING', (0, 0), (-1, -1), 8),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    story.append(t_meta)
    story.append(Spacer(1, 15))

    # =========================================================================
    # SECTION 1: EXECUTIVE OVERVIEW & SYSTEM ARCHITECTURE
    # =========================================================================
    story.append(Paragraph("1. Executive Overview & Quad-Core AI Architecture", h1_style))
    story.append(Paragraph(
        "<b>MindSync AI</b> is an enterprise-grade digital mental wellness companion engineered specifically to counter software engineering stressors (tight sprint deadlines, sedentary desk hours, code review exhaustion, context switching, and on-call burnout).",
        body_style
    ))
    story.append(Paragraph(
        "Unlike generic wellness apps that rely purely on manual journaling, MindSync AI operates on a <b>Quad-Core Hybrid AI Architecture</b> combining deterministic biometrics, machine learning risk classification, explainable artificial intelligence (XAI), and generative LLM orchestration:",
        body_style
    ))

    arch_points = [
        "<b>Core 1: Supervised ML Classifier (Random Forest):</b> Evaluates a multi-dimensional telemetry feature vector (sleep, stress, work hours, mood, steps, hydration, exercise) to forecast burnout probability (0% to 100%).",
        "<b>Core 2: Explainable AI Engine (SHAP):</b> Computes game-theoretic Shapley Additive Explanations to quantify exact marginal contributions of each biometric feature to the risk score.",
        "<b>Core 3: LLM Orchestrator (Llama 3.3 70B via Groq):</b> Executes ultra-low latency inference to generate personalized developer lifestyle recommendations and empathetic conversational guidance.",
        "<b>Core 4: Deterministic Safety & Rule Engine:</b> Enforces hard clinical boundaries, medical disclaimers, and 988 Crisis Lifeline safety overrides."
    ]
    for p in arch_points:
        story.append(Paragraph(f"• {p}", bullet_style))
    story.append(Spacer(1, 10))

    # =========================================================================
    # SECTION 2: SUPERVISED MACHINE LEARNING & MATHEMATICAL FOUNDATIONS
    # =========================================================================
    story.append(Paragraph("2. Supervised Machine Learning Subsystem (Random Forest)", h1_style))
    story.append(Paragraph(
        "The core prediction module utilizes a <b>Random Forest Classifier</b>. Random Forest is an ensemble learning technique based on <i>Bootstrap Aggregation (Bagging)</i> of multiple Decision Trees.",
        body_style
    ))
    
    story.append(Paragraph("Mathematical Formulations of the ML Subsystem:", h2_style))
    story.append(Paragraph(
        "<b>1. Entropy:</b> Measures the impurity or randomness of a set of telemetry data samples <i>S</i> containing class probabilities <i>p_i</i>:<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;<b>H(S) = - ∑ [ p_i * log2(p_i) ]</b>",
        body_style
    ))
    story.append(Paragraph(
        "<b>2. Information Gain:</b> Measures the reduction in entropy achieved by splitting dataset <i>S</i> on biometric attribute <i>A</i>:<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;<b>IG(S, A) = H(S) - ∑ [ (|S_v| / |S|) * H(S_v) ]</b>",
        body_style
    ))
    story.append(Paragraph(
        "<b>3. Gini Impurity:</b> The node splitting criterion used during tree construction to minimize classification variance:<br/>"
        "&nbsp;&nbsp;&nbsp;&nbsp;<b>Gini(S) = 1 - ∑ (p_i)^2</b>",
        body_style
    ))

    story.append(Paragraph("Feature Vector Specification (9 Input Features):", h2_style))

    feat_table_data = [
        [Paragraph("<b>Feature Symbol</b>", body_style), Paragraph("<b>Telemetry Name</b>", body_style), Paragraph("<b>Scale / Unit</b>", body_style), Paragraph("<b>Engineering Purpose</b>", body_style)],
        [Paragraph("x₁", body_style), Paragraph("sleep_hours", body_style), Paragraph("0.0 – 24.0 hrs", body_style), Paragraph("Primary restorative recovery metric", body_style)],
        [Paragraph("x₂", body_style), Paragraph("working_hours", body_style), Paragraph("0.0 – 24.0 hrs", body_style), Paragraph("Direct measure of desk/screen strain", body_style)],
        [Paragraph("x₃", body_style), Paragraph("mood_score", body_style), Paragraph("1 – 10 rating", body_style), Paragraph("Subjective psychological state", body_style)],
        [Paragraph("x₄", body_style), Paragraph("stress_level", body_style), Paragraph("1 – 10 rating", body_style), Paragraph("Subjective cognitive load rating", body_style)],
        [Paragraph("x₅", body_style), Paragraph("energy_level", body_style), Paragraph("1 – 10 rating", body_style), Paragraph("Subjective physical vigor", body_style)],
        [Paragraph("x₆", body_style), Paragraph("water_intake", body_style), Paragraph("0 – 30 (glasses)", body_style), Paragraph("Hydration adequacy (converted from ml)", body_style)],
        [Paragraph("x₇", body_style), Paragraph("daily_steps", body_style), Paragraph("0 – 50,000 steps", body_style), Paragraph("Hardware pedometer physical movement", body_style)],
        [Paragraph("x₈", body_style), Paragraph("exercise_minutes", body_style), Paragraph("0 – 1,440 mins", body_style), Paragraph("Active physical conditioning duration", body_style)],
        [Paragraph("x₉", body_style), Paragraph("consecutive_working_days", body_style), Paragraph("0 – 365 days", body_style), Paragraph("Accumulated overtime / fatigue factor", body_style)]
    ]
    t_feat = Table(feat_table_data, colWidths=[60, 120, 110, 210])
    t_feat.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), PRIMARY),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('GRID', (0, 0), (-1, -1), 0.5, BOX_BORDER),
        ('PADDING', (0, 0), (-1, -1), 5),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, BG_LIGHT])
    ]))
    story.append(t_feat)
    story.append(Spacer(1, 15))

    # =========================================================================
    # SECTION 3: EXPLAINABLE AI (XAI) — SHAP VALUES
    # =========================================================================
    story.append(Paragraph("3. Explainable AI (XAI) Subsystem — SHAP Integration", h1_style))
    story.append(Paragraph(
        "In healthcare and mental wellness applications, ML models cannot act as opaque 'black boxes'. Users and examiners require transparency into <b>why</b> a specific burnout risk classification was assigned.",
        body_style
    ))
    story.append(Paragraph(
        "MindSync AI integrates <b>SHAP (SHapley Additive exPlanations)</b>, a game-theoretic approach developed by Lloyd Shapley to compute optimal credit allocation among input features.",
        body_style
    ))

    story.append(Paragraph("Shapley Value Formula:", h2_style))
    story.append(Paragraph(
        "&nbsp;&nbsp;&nbsp;&nbsp;<b>ϕ_i(v) = ∑ [ (|S|! * (|N| - |S| - 1)!) / |N|! ] * [ v(S ∪ {i}) - v(S) ]</b>",
        body_style
    ))
    story.append(Paragraph(
        "Where <i>N</i> is the total set of features, <i>S</i> is a subset of features excluding feature <i>i</i>, and <i>v(S)</i> is the prediction outcome for subset <i>S</i>.",
        body_style
    ))

    story.append(Paragraph("Real World XAI Example in MindSync AI:", h2_style))
    xai_code = """# SHAP Explanation Output generated for a High-Risk Developer Log:
Base Expected Risk Score: 25.0%
Feature Attribution Breakdown:
  + 35.0% -> Prolonged Working Hours (13.0 hrs vs 8.0 hrs baseline)
  + 25.0% -> Elevated Stress Rating (9/10 vs 4/10 baseline)
  + 18.0% -> Insufficient Sleep Duration (4.0 hrs vs 7.5 hrs baseline)
  -  8.0% -> Hydration Compliance (1,500 ml logged)
----------------------------------------------------------------------
Final Calculated Risk Score: 95.0% (Risk Category: HIGH BURNOUT RISK)"""
    story.append(Paragraph(xai_code, code_style))
    story.append(Spacer(1, 10))

    # =========================================================================
    # SECTION 4: GENERATIVE AI & LLM ORCHESTRATION
    # =========================================================================
    story.append(Paragraph("4. Generative AI & Natural Language Processing (LLM)", h1_style))
    story.append(Paragraph(
        "MindSync AI harnesses <b>Llama 3.3 70B Versatile</b>, a 70-billion parameter auto-regressive transformer model executed via <b>Groq LPUs (Language Processing Units)</b>.",
        body_style
    ))

    llm_details = [
        "<b>Inference Throughput:</b> Groq LPUs provide custom hardware acceleration delivering 500+ tokens per second with near-zero latency.",
        "<b>Context Injection:</b> The AI Orchestrator constructs system prompts containing real-time biometric context (mood score, sleep hours, stress level, weather) so responses are strictly grounded.",
        "<b>Crisis Safety Override:</b> Pre-LLM safety scanners monitor input strings for self-harm keywords (e.g. <i>suicide</i>, <i>kill myself</i>, <i>want to die</i>) and immediately return standard 988 Lifeline resources without invoking external APIs."
    ]
    for d in llm_details:
        story.append(Paragraph(f"• {d}", bullet_style))
    story.append(Spacer(1, 10))

    # =========================================================================
    # SECTION 5: HYBRID RECOMMENDATION SYSTEM
    # =========================================================================
    story.append(Paragraph("5. Tri-Layer Hybrid Recommendation Engine", h1_style))
    story.append(Paragraph(
        "To guarantee high reliability, MindSync AI does not rely solely on LLMs. Instead, it utilizes a <b>Tri-Layer Hybrid Recommendation Engine</b>:",
        body_style
    ))

    rec_layers = [
        "<b>Layer 1 (Deterministic Rules):</b> Immediate threshold evaluations (e.g. if sleep < 6h → trigger screenless wind-down routine; if water < 1.5L → trigger hydration alert).",
        "<b>Layer 2 (ML-Guided Weights):</b> Prioritizes recommendations matching the user's Random Forest risk profile.",
        "<b>Layer 3 (Groq AI Generative LLM):</b> Formulates customized developer lifestyle advice matching current sprint workload and weather context."
    ]
    for r in rec_layers:
        story.append(Paragraph(f"• {r}", bullet_style))
    story.append(Spacer(1, 15))

    # =========================================================================
    # SECTION 6: VIVA EXAMINER Q&A & TECHNICAL DICTIONARY
    # =========================================================================
    story.append(PageBreak()) # Clean break for Viva Guide section
    story.append(Paragraph("6. Viva Presentation Cheat Sheet & Examiner Q&A Guide", h1_style))
    story.append(Paragraph(
        "Use this section during your viva voce examination to explain the project with complete technical confidence.",
        body_style
    ))

    story.append(Paragraph("30-Second Elevator Story for Viva Examiners:", h2_style))
    story.append(Paragraph(
        "<i>\"MindSync AI is an intelligent mental wellness shield designed for software developers. It collects biometric telemetry like sleep, steps, and stress, passes them through a Random Forest Machine Learning classifier to predict burnout risk, uses SHAP Explainable AI to pinpoint exact root causes, and leverages Groq-accelerated Llama 3.3 LLMs to deliver real-time actionable developer coaching.\"</i>",
        ParagraphStyle('StoryQuote', parent=body_style, fontName='Helvetica-Oblique', textColor=PRIMARY, backColor=BG_LIGHT, borderPadding=8)
    ))
    story.append(Spacer(1, 10))

    story.append(Paragraph("Top 5 Viva Examiner Questions & Perfect Responses:", h2_style))

    qa_list = [
        ("Q1: Why did you choose Random Forest instead of Deep Learning (Neural Networks)?",
         "Answer: Random Forest performs exceptionally well on tabular telemetry datasets of moderate size without overfitting. Furthermore, tree-based models integrate seamlessly with SHAP for exact Explainable AI feature attribution, whereas deep neural networks act as opaque black boxes."),

        ("Q2: How do you handle cases where API keys are missing or network goes offline?",
         "Answer: MindSync AI features a multi-tiered fallback pipeline. If the Groq API key is unconfigured or network fails, the system smoothly falls back to rule-based heuristics and local Hive cached data, ensuring 0% application crashes."),

        ("Q3: What is the significance of SHAP values in your system?",
         "Answer: SHAP values provide game-theoretic mathematical proof for why a user received a specific burnout risk score. It explains whether high work hours or poor sleep contributed more to their stress, providing actionable transparency."),

        ("Q4: How do you protect user privacy and handle crisis safety?",
         "Answer: All personal telemetry is stored locally using encrypted Hive key-value storage. Additionally, a pre-processing safety scanner intercepts crisis keywords locally and provides instant 988 helpline information without sending sensitive distress data to third-party APIs."),

        ("Q5: What is the role of FastAPI and Render in your backend deployment?",
         "Answer: FastAPI provides asynchronous, high-throughput REST microservices with automatic Pydantic data validation and OpenAPI documentation. Render hosts the live backend, providing scalable containerized deployment for our ML pipelines.")
    ]

    for q, a in qa_list:
        story.append(Paragraph(f"<b>{q}</b>", ParagraphStyle('QStyle', parent=body_style, fontName='Helvetica-Bold', textColor=SECONDARY)))
        story.append(Paragraph(f"<i>{a}</i>", ParagraphStyle('AStyle', parent=body_style, leftIndent=10, spaceAfter=8)))

    story.append(Spacer(1, 10))
    story.append(Paragraph("Essential AI/ML Technical Glossary:", h2_style))

    dict_table_data = [
        [Paragraph("<b>Technical Term</b>", body_style), Paragraph("<b>Definition & Project Context</b>", body_style)],
        [Paragraph("Bootstrap Aggregation (Bagging)", body_style), Paragraph("Ensemble method that trains multiple decision trees on random subsets of telemetry data to reduce variance.", body_style)],
        [Paragraph("SHAP (Shapley Explanations)", body_style), Paragraph("Game-theoretic algorithm computing feature importance for transparent explainable AI.", body_style)],
        [Paragraph("LLM Context Injection", body_style), Paragraph("Technique of embedding live biometric state directly into system prompts before sending to Llama 3.3.", body_style)],
        [Paragraph("Groq LPU Acceleration", body_style), Paragraph("Hardware-accelerated tensor execution engine running LLM inference at 500+ tokens/sec.", body_style)],
        [Paragraph("Hive Local Storage", body_style), Paragraph("Lightweight, fast key-value database for Flutter ensuring offline persistence and quick data access.", body_style)]
    ]
    t_dict = Table(dict_table_data, colWidths=[150, 350])
    t_dict.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), SECONDARY),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('GRID', (0, 0), (-1, -1), 0.5, BOX_BORDER),
        ('PADDING', (0, 0), (-1, -1), 5),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, BG_LIGHT])
    ]))
    story.append(t_dict)

    # Build Document
    doc.build(story, canvasmaker=NumberedCanvas)
    print(f"SUCCESS: Generated PDF Guide at: {filename}")

if __name__ == "__main__":
    out_dir = os.path.join(os.getcwd(), "docs")
    os.makedirs(out_dir, exist_ok=True)
    pdf_path = os.path.join(out_dir, "MindSync_AI_And_ML_Mastery_Guide.pdf")
    build_pdf(pdf_path)
