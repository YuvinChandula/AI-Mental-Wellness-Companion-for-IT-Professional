import os
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

def set_cell_background(cell, fill_hex):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{fill_hex}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(f'''
        <w:tcMar {nsdecls("w")}>
            <w:top w:w="{top}" w:type="dxa"/>
            <w:bottom w:w="{bottom}" w:type="dxa"/>
            <w:left w:w="{left}" w:type="dxa"/>
            <w:right w:w="{right}" w:type="dxa"/>
        </w:tcMar>
    ''')
    tcPr.append(tcMar)

def add_callout(doc, text_list, title="KEY INSIGHT"):
    tbl = doc.add_table(rows=1, cols=1)
    tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
    cell = tbl.cell(0, 0)
    set_cell_background(cell, "F0F4F8")
    set_cell_margins(cell, top=140, bottom=140, left=200, right=200)
    
    # Set left border
    tcPr = cell._tc.get_or_add_tcPr()
    borders = parse_xml(f'''
        <w:tcBorders {nsdecls("w")}>
            <w:top w:val="none"/>
            <w:left w:val="single" w:sz="36" w:space="0" w:color="1E3A8A"/>
            <w:bottom w:val="none"/>
            <w:right w:val="none"/>
        </w:tcBorders>
    ''')
    tcPr.append(borders)
    
    p = cell.paragraphs[0]
    p.paragraph_format.space_before = Pt(2)
    p.paragraph_format.space_after = Pt(4)
    run_t = p.add_run(f"💡 {title}\n")
    run_t.bold = True
    run_t.font.name = "Calibri"
    run_t.font.size = Pt(11)
    run_t.font.color.rgb = RGBColor(0x1E, 0x3A, 0x8A)
    
    for idx, item in enumerate(text_list):
        p_item = cell.add_paragraph()
        p_item.paragraph_format.space_before = Pt(2)
        p_item.paragraph_format.space_after = Pt(2)
        p_item.paragraph_format.line_spacing = 1.15
        run = p_item.add_run(item)
        run.font.name = "Calibri"
        run.font.size = Pt(10.5)
        run.font.color.rgb = RGBColor(0x1F, 0x29, 0x37)

def create_document():
    doc = Document()
    
    # Page setup - Margins 1 inch
    sections = doc.sections
    for section in sections:
        section.top_margin = Inches(1.0)
        section.bottom_margin = Inches(1.0)
        section.left_margin = Inches(1.0)
        section.right_margin = Inches(1.0)
        
    # Styles Setup
    normal_style = doc.styles['Normal']
    normal_style.font.name = 'Calibri'
    normal_style.font.size = Pt(11)
    normal_style.font.color.rgb = RGBColor(0x1F, 0x29, 0x37) # Dark Charcoal
    
    # Title Header
    title_p = doc.add_paragraph()
    title_p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    title_p.paragraph_format.space_before = Pt(0)
    title_p.paragraph_format.space_after = Pt(4)
    run_title = title_p.add_run("MindSync AI – Artificial Intelligence & Machine Learning Guide")
    run_title.font.name = "Calibri"
    run_title.font.size = Pt(24)
    run_title.bold = True
    run_title.font.color.rgb = RGBColor(0x1E, 0x3A, 0x8A) # Navy Blue
    
    sub_p = doc.add_paragraph()
    sub_p.paragraph_format.space_after = Pt(18)
    run_sub = sub_p.add_run("Comprehensive Technical Explanation, Beginner-Friendly Glossary, Dataset Analysis, and Code Base Mapping")
    run_sub.font.name = "Calibri"
    run_sub.font.size = Pt(13)
    run_sub.italic = True
    run_sub.font.color.rgb = RGBColor(0x4B, 0x55, 0x63) # Slate Grey
    
    doc.add_paragraph().paragraph_format.space_after = Pt(6)

    # -------------------------------------------------------------
    # SECTION 1
    # -------------------------------------------------------------
    h1 = doc.add_paragraph()
    h1.paragraph_format.space_before = Pt(14)
    h1.paragraph_format.space_after = Pt(6)
    r = h1.add_run("1. Executive Overview: Dual-AI Architecture")
    r.font.size = Pt(16)
    r.bold = True
    r.font.color.rgb = RGBColor(0x1E, 0x3A, 0x8A)
    
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(8)
    p.paragraph_format.line_spacing = 1.15
    p.add_run(
        "MindSync AI is a specialized mental wellness companion built specifically for software engineers, developers, and IT professionals. "
        "The system combines two distinct branches of Artificial Intelligence to deliver real-time risk assessment and compassionate coaching:"
    )
    
    p1 = doc.add_paragraph(style='List Bullet')
    p1.paragraph_format.space_after = Pt(4)
    r1 = p1.add_run("1. Supervised Machine Learning (ML) – Risk Assessment Engine: ")
    r1.bold = True
    p1.add_run(
        "Analyzes quantitative telemetry data logged by the user (sleep hours, stress ratings, working hours, hydration, and activity) "
        "to calculate continuous Burnout Risk Scores (0–100) and classify users into Low, Medium, or High risk categories."
    )
    
    p2 = doc.add_paragraph(style='List Bullet')
    p2.paragraph_format.space_after = Pt(10)
    r2 = p2.add_run("2. Generative AI / Large Language Models (LLM) – Conversational Coach: ")
    r2.bold = True
    p2.add_run(
        "Powered by Llama 3.3 70B (via Groq API / Gemini fallback), this module acts as a empathetic coach. It reads telemetry data and write "
        "natural language daily check-ins, weekly wellness reports, and developer-tailored chat responses using programming analogies."
    )

    add_callout(
        doc,
        [
            "Dual-AI Harmony: Machine Learning provides statistical accuracy and objective risk calculations, while Generative AI provides human warmth, empathy, and tailored actionable advice.",
            "Explainable AI (XAI): Unlike standard black-box AI models, MindSync AI explains EXACTLY why a user is flagged for risk using SHAP values."
        ],
        title="CORE PHILOSOPHY"
    )

    # -------------------------------------------------------------
    # SECTION 2
    # -------------------------------------------------------------
    h1 = doc.add_paragraph()
    h1.paragraph_format.space_before = Pt(16)
    h1.paragraph_format.space_after = Pt(6)
    r = h1.add_run("2. Beginner-Friendly Glossary of Technical Terms")
    r.font.size = Pt(16)
    r.bold = True
    r.font.color.rgb = RGBColor(0x1E, 0x3A, 0x8A)

    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(8)
    p.add_run("Below is a plain-language explanation of all technical terms used throughout the codebase and documentation:")

    terms = [
        ("Supervised Machine Learning", "Teaching an AI model by providing examples. The model learns patterns from 10,000 historical records where health numbers are paired with ground-truth burnout risk labels."),
        ("Telemetry / Telemetry Data", "Quantitative daily tracking data logged by users or wearable integrations (e.g., 6 hours sleep, 10 working hours, 8/10 stress, 5,000 steps)."),
        ("Random Forest Classifier", "An ensemble AI algorithm. Imagine 100 individual decision flowcharts (decision trees) analyzing the user's data. Each tree votes on the risk tier, and the majority vote becomes the final result, preventing individual errors."),
        ("GridSearchCV (Hyperparameter Tuning)", "An automated optimization technique that systematically tests different configuration knobs (such as tree depth and number of estimators) to discover the highest accuracy model setup."),
        ("RobustScaler (Feature Scaling)", "Step counts are measured in thousands (e.g., 8,000), whereas sleep is measured in single digits (e.g., 6.5). RobustScaler rescales all features to a unified range using median and interquartile statistics, preventing large numbers from dominating the AI while remaining immune to extreme outliers."),
        ("Explainable AI (XAI) & SHAP", "SHapley Additive exPlanations. Most AI models are 'black boxes' that output a answer without reason. SHAP opens the box and calculates exact mathematical feature contributions (e.g., +25% risk due to low sleep, +15% due to long work hours)."),
        ("Model Serialization (.pkl File)", "Saving the trained AI model to a disk file (burnout_model.pkl). This allows the FastAPI server to load the pre-trained brain in milliseconds without having to re-train the model on every user request."),
        ("Large Language Model (LLM)", "An advanced AI model trained on massive text corpora to understand and generate natural human language (e.g., Llama 3.3 by Meta, Gemini by Google)."),
        ("Groq API", "An ultra-high-speed cloud AI inference provider that executes Llama 3.3 70B parameter models in milliseconds."),
        ("Prompt Engineering", "Designing structured instructions given to the LLM (e.g., 'You are MindSync AI, an empathetic wellness coach for software developers. Use programming analogies like compile times and refactoring')."),
        ("Hybrid Recommendation Engine", "A multi-layered recommendation system combining hardcoded health rules (e.g. sleep < 6h), ML predictions (high burnout risk protocols), and creative Generative AI suggestions.")
    ]

    for term, definition in terms:
        p_term = doc.add_paragraph()
        p_term.paragraph_format.space_after = Pt(4)
        p_term.paragraph_format.line_spacing = 1.15
        r_t = p_term.add_run(f"• {term}: ")
        r_t.bold = True
        r_t.font.color.rgb = RGBColor(0x0D, 0x94, 0x88) # Teal Accent
        p_term.add_run(definition)

    # -------------------------------------------------------------
    # SECTION 3
    # -------------------------------------------------------------
    h1 = doc.add_paragraph()
    h1.paragraph_format.space_before = Pt(16)
    h1.paragraph_format.space_after = Pt(6)
    r = h1.add_run("3. Machine Learning Architecture & Implementation")
    r.font.size = Pt(16)
    r.bold = True
    r.font.color.rgb = RGBColor(0x1E, 0x3A, 0x8A)

    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(8)
    p.add_run(
        "The Machine Learning subsystem predicts burnout risk using a structured pipeline that runs from data generation to REST API serving:"
    )

    steps = [
        ("Step 1: Data Generation & Preprocessing", "Synthetic telemetry data is generated with realistic Gaussian noise. Data is split into training (80%) and testing (20%) sets. RobustScaler standardizes feature scales."),
        ("Step 2: Model Evaluation & Tuning", "Four classification algorithms are evaluated: Logistic Regression, Decision Trees, Random Forest, and Gradient Boosting. Random Forest is selected and hyper-tuned via GridSearchCV."),
        ("Step 3: SHAP XAI Integration", "A TreeExplainer computes SHAP values to extract human-readable risk factors (e.g. 'Prolonged working hours', 'Low sleep duration')."),
        ("Step 4: Serialization", "Model weights, scaler instances, and feature order arrays are pickled into backend/app/ml/models/burnout_model.pkl."),
        ("Step 5: API Serving", "FastAPI endpoint POST /api/predict/burnout loads the model singleton and responds with prediction outputs in under 50 milliseconds.")
    ]

    for s_title, s_desc in steps:
        p_s = doc.add_paragraph()
        p_s.paragraph_format.space_after = Pt(4)
        r_st = p_s.add_run(f"{s_title}\n")
        r_st.bold = True
        r_st.font.color.rgb = RGBColor(0x1E, 0x3A, 0x8A)
        p_s.add_run(s_desc)

    # -------------------------------------------------------------
    # SECTION 4
    # -------------------------------------------------------------
    h1 = doc.add_paragraph()
    h1.paragraph_format.space_before = Pt(16)
    h1.paragraph_format.space_after = Pt(6)
    r = h1.add_run("4. Training Dataset Breakdown & Mathematical Formulas")
    r.font.size = Pt(16)
    r.bold = True
    r.font.color.rgb = RGBColor(0x1E, 0x3A, 0x8A)

    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(8)
    p.add_run(
        "Because real patient mental health records are subject to strict privacy regulations, the ML model was trained on a domain-engineered "
        "synthetic dataset of 10,000 IT professional records generated in backend/app/ml/train.py."
    )

    # Table of Features
    table = doc.add_table(rows=1, cols=4)
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    hdr_cells = table.rows[0].cells
    headers = ["Feature Name", "Data Type", "Value Domain", "Clinical / Domain Description"]
    
    for i, header_text in enumerate(headers):
        hdr_cells[i].text = header_text
        set_cell_background(hdr_cells[i], "1E3A8A")
        set_cell_margins(hdr_cells[i], top=100, bottom=100, left=120, right=120)
        for p_h in hdr_cells[i].paragraphs:
            for r_h in p_h.runs:
                r_h.font.bold = True
                r_h.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
                r_h.font.size = Pt(10)

    feature_table_data = [
        ("sleep_hours", "Float", "[4.0, 10.0] hrs", "Hours of sleep tracked per 24-hour period"),
        ("working_hours", "Float", "[3.0, 16.0] hrs", "Active desk / coding duration logged"),
        ("mood_score", "Integer", "[1, 10] rating", "Self-reported mood score (1=Very Low, 10=Great)"),
        ("stress_level", "Integer", "[1, 10] rating", "Self-reported stress level rating"),
        ("energy_level", "Integer", "[1, 10] rating", "Self-reported stamina / energy level"),
        ("water_intake", "Integer", "[1, 12] glasses", "Hydration count (glasses or converted from ml)"),
        ("daily_steps", "Integer", "[1,000, 18,000]", "Pedometer total daily step count"),
        ("exercise_minutes", "Integer", "[0, 120] mins", "Physical workout or walking duration"),
        ("consecutive_working_days", "Integer", "[0, 12] days", "Active consecutive days worked without a break")
    ]

    for row_idx, data in enumerate(feature_table_data):
        row_cells = table.add_row().cells
        bg_color = "F9FAFB" if row_idx % 2 == 1 else "FFFFFF"
        for i, text in enumerate(data):
            row_cells[i].text = text
            set_cell_background(row_cells[i], bg_color)
            set_cell_margins(row_cells[i], top=80, bottom=80, left=120, right=120)
            for p_c in row_cells[i].paragraphs:
                for r_c in p_c.runs:
                    r_c.font.size = Pt(9.5)

    doc.add_paragraph().paragraph_format.space_after = Pt(6)

    # Formula Box
    add_callout(
        doc,
        [
            "Base Score Formula:",
            "Base Score = (3.5 × working_hours) + (5.0 × stress_level) + (4.0 × (10 - sleep_hours)) + (3.0 × (10 - mood_score)) + (3.0 × (10 - energy_level)) + (2.0 × consecutive_working_days) - (0.15 × exercise_minutes) - (0.6 × water_intake) - (0.0003 × daily_steps) + Random_Noise",
            "",
            "Target Classification Thresholds:",
            "• Class 0 (Low Risk): Risk Score < 40.0",
            "• Class 1 (Medium Risk): 40.0 <= Risk Score < 70.0",
            "• Class 2 (High Risk): Risk Score >= 70.0"
        ],
        title="MATHEMATICAL GROUND-TRUTH FORMULA"
    )

    # -------------------------------------------------------------
    # SECTION 5
    # -------------------------------------------------------------
    h1 = doc.add_paragraph()
    h1.paragraph_format.space_before = Pt(16)
    h1.paragraph_format.space_after = Pt(6)
    r = h1.add_run("5. Codebase File Mapping & Architectural Summary")
    r.font.size = Pt(16)
    r.bold = True
    r.font.color.rgb = RGBColor(0x1E, 0x3A, 0x8A)

    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(8)
    p.add_run("The table below maps all key AI/ML code files across the repository:")

    # Table of Files
    table_files = doc.add_table(rows=1, cols=3)
    table_files.alignment = WD_TABLE_ALIGNMENT.CENTER
    hdr_f = table_files.rows[0].cells
    headers_f = ["File Relative Path", "Primary Responsibility", "Key Functions & Subsystems"]
    
    for i, header_text in enumerate(headers_f):
        hdr_f[i].text = header_text
        set_cell_background(hdr_f[i], "1E3A8A")
        set_cell_margins(hdr_f[i], top=100, bottom=100, left=120, right=120)
        for p_h in hdr_f[i].paragraphs:
            for r_h in p_h.runs:
                r_h.font.bold = True
                r_h.font.color.rgb = RGBColor(0xFF, 0xFF, 0xFF)
                r_h.font.size = Pt(10)

    files_data = [
        ("backend/app/ml/train.py", "Model Training & Export", "generate_synthetic_dataset(), train_and_evaluate(), GridSearchCV, SHAP init, Joblib dump"),
        ("backend/app/ml/pipeline.py", "Inference & XAI Pipeline", "BurnoutPipeline singleton, predict(), SHAP TreeExplainer, continuous risk score calculation"),
        ("backend/app/ml/recommendation_engine.py", "Hybrid Recommendation System", "HybridRecommendationEngine, rule-based checks, ML protocols, Groq AI lifestyle fetcher"),
        ("backend/app/services/ai_orchestrator.py", "LLM Orchestration & Cache", "AIOrchestrator, Groq API async client (Llama 3.3 70B), retry backoff, CacheService TTL integration"),
        ("backend/app/core/prompt_library.py", "Developer Prompt Engineering", "PromptLibrary, daily_summary, weekly_report, chat_coaching, developer analogy prompts"),
        ("backend/app/api/endpoints/predict.py", "REST API Endpoint", "predict_burnout(), Pydantic PredictionRequest validation, HTTP status handling"),
        ("docs/ml_pipeline.md", "ML Pipeline Spec", "Documentation of feature bounds, pipeline flow diagram, scaling specs, XAI rationale")
    ]

    for row_idx, data in enumerate(files_data):
        row_cells = table_files.add_row().cells
        bg_color = "F9FAFB" if row_idx % 2 == 1 else "FFFFFF"
        for i, text in enumerate(data):
            row_cells[i].text = text
            set_cell_background(row_cells[i], bg_color)
            set_cell_margins(row_cells[i], top=80, bottom=80, left=120, right=120)
            for p_c in row_cells[i].paragraphs:
                for r_c in p_c.runs:
                    if i == 0:
                        r_c.font.bold = True
                    r_c.font.size = Pt(9.5)

    doc.add_paragraph().paragraph_format.space_after = Pt(12)
    
    # Output path
    output_path = os.path.join("docs", "MindSync_AI_And_ML_Explanation_Guide.docx")
    doc.save(output_path)
    print(f"Successfully generated document at: {output_path}")

if __name__ == "__main__":
    create_document()
