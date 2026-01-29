# Technical Lessons Learned & Troubleshooting

This document records critical technical challenges encountered during development and their proven solutions.

## 1. MQL5 UI & UX Patterns

### 1.1. Custom Dropdowns on Chart
*   **Challenge:** MQL5 has no native ComboBox for charts. Radio buttons are cluttered.
*   **Solution:** Built a custom Dropdown using `CChartObjectButton`.
*   **Critical Technique (Occlusion):** When opening a dropdown, **hide** (`X_Distance(-1000)`) the UI elements below it instead of pushing them down. This prevents Z-order clipping issues where lower buttons "bleed" through the active dropdown list.

### 1.2. Anti-Scroll Dragging
*   **Challenge:** Dragging a dashboard often scrolls the chart background, frustrating users.
*   **Solution:** 
    *   On Mouse Down (Start Drag): `ChartSetInteger(id, CHART_MOUSE_SCROLL, false)`
    *   On Mouse Up (End Drag): `ChartSetInteger(id, CHART_MOUSE_SCROLL, true)`

### 1.3. UI Object Management
*   **Mandate:** **Avoid Pointers for UI Objects** if possible. Using `CChartObjectButton m_btn;` (static member) is significantly more stable than `CChartObjectButton *m_btn;` because:
    *   No `new`/`delete` management required.
    *   Eliminates syntax confusion between `.` and `->`.
    *   Prevents `undeclared identifier` errors caused by complex pointer scope resolution.

## 2. Compilation & Libraries

### 2.1. Standard Library "Create" Overloads
*   **Issue:** `CChartObjectRectLabel::Create` signatures vary between library versions (some enforce 7 params, some 5).
*   **Solution:** Use the **Lowest Common Denominator**. Call the base `Create(chart, name, win, x, y)` (5 params) first, then explicitly set `X_Size` and `Y_Size` properties. This works on ALL MetaEditor versions.

### 2.2. Include Path Conflicts
*   **Lesson:** Never copy standard libraries to a local `Libs/` folder unless absolutely necessary. It causes "Identifier already used" errors due to double inclusion (System Lib vs Local Lib). Always link to the system's `<...>` includes.

## 3. Fuzzy Logic Architecture
*   **Zero Dependency:** The Fuzzy engine was rewritten to use native MQL5 dynamic arrays (`m_rules[]`) instead of `CArrayObj`. This ensures the core logic is portable and compiles via CLI without path configuration headaches.