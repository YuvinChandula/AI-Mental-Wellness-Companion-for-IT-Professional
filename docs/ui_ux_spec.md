# MindSync AI – UI/UX Design System Specification

This specification documents the MindSync AI design tokens, light/dark theme color palettes, typography guidelines, and Material 3 components system.

---

## 1. Color Palette (Material 3 Compliant)

Our colors are designed to promote calm, focus, and reduced cognitive fatigue.

### A. Light Theme (HEX Palette)
*   **Primary:** `#1E88E5` (Active Ocean Blue - represents focus and mental clarity)
*   **Secondary:** `#00ACC1` (Teal Stream - represents calm and relaxation)
*   **Background:** `#F5F7FA` (Cool Soft Grey - soft background, reduces glare)
*   **Surface:** `#FFFFFF` (Pure White - for cards and focus modules)
*   **Error:** `#D84315` (Rust Terracotta - for alerts and warnings without inducing panic)
*   **Success:** `#43A047` (Meadow Green - for completed habits and positive trends)

### B. Dark Theme (HEX Palette)
*   **Primary:** `#64B5F6` (Electric Slate Blue)
*   **Secondary:** `#4DD0E1` (Vibrant Turquoise)
*   **Background:** `#121214` (Deep Coal Black - standard dark mode)
*   **Surface:** `#1E1E24` (Charcoal Slate - card surfaces)
*   **Error:** `#FF7043` (Vibrant Terracotta Coral)
*   **Success:** `#81C784` (Light Emerald Green)

---

## 2. Typography Guidelines

We use Google Fonts' **Inter** typeface for high readability across varying device sizes.

| Style Name | Weight | Size (SP) | Line Height | Usage |
| :--- | :--- | :--- | :--- | :--- |
| **Headline Large** | Bold (700) | 28 | 34 | Splash screen, Onboarding headers |
| **Headline Medium**| Semi-Bold (600) | 22 | 28 | Navigation Page headers |
| **Title Medium** | Medium (500) | 16 | 22 | Card headers, list section headers |
| **Body Large** | Regular (400) | 16 | 24 | Default copy, chat text bubbles |
| **Body Medium** | Regular (400) | 14 | 20 | Subtitles, input placeholders |
| **Label Small** | Medium (500) | 12 | 16 | Bottom bar labels, tags, captions |

---

## 3. Core Component Layouts

### A. Bottom Navigation Bar
Persistent Material 3 bottom navigation mapping active tabs:
1.  **Dashboard**: Combined wellness scores, quick-action logging shortcuts, activity widgets.
2.  **Mood Journal**: Entry calendar, mood logs, trends visualizations.
3.  **AI Chat**: Interactive Gemini messaging interface.
4.  **Reports**: Trend analytical charts and AI reports.
5.  **Profile & Settings**: Account settings, preferences, information.

### B. AI Chat Bubble Layout
*   **User Message:** Align right. Slate Blue background (`Primary` color), white body text. Rounded borders except bottom-right corner.
*   **AI Coach Response:** Align left. Surface background color (`Surface` or light grey), charcoal body text. Includes a subtle "Sync AI" header tag with a Gemini icon. Rounded borders except bottom-left corner.
*   **Quick Action Chips:** Small pill-shaped buttons displayed horizontally below the last message to trigger fast queries (e.g. *"Give me sleep tips"*, *"Log my mood"*).

### C. Visual Charts (fl_chart)
*   Line and area graphs use gradient stroke fills fading down into transparent backgrounds.
*   Tooltips appear on point click events, rendering values inside rounded, drop-shadowed containers.
