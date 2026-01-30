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

### 2.2. MQL5 Standard Fuzzy Library Integration (CRITICAL)
*   **Rule:** NEVER assume Standard Library APIs based on documentation or memory.
*   **Protocol:** Always read the source code (`Get-Content "Path\To\Lib.mqh"`) before implementation.
*   **Discovery:** `CFuzzyVariable` in MQL5 Standard Lib uses `.Value()` for both getting and setting (overloaded), not `SetCrispValue`.
*   **Calculation Logic:** `CMamdaniFuzzySystem::Calculate(CList *inputValues)` requires a list of `CDictionary_Obj_Double` objects. Variables themselves do not store the input state for the system calculation.

### 2.3. Rule Weighting
*   **Functionality:** Each rule in Mamdani system can have a weight (0.0 to 1.0).
*   **API:** Use `CMamdaniFuzzyRule::Weight(double value)`. This scales the result of the rule's conditions (Firing Strength). Useful for reducing the impact of less reliable signals.

### 2.4. Compiler & Scope Quirks
*   **Casting:** Calling a method on a casted pointer in the same line often fails.
    *   *Bad:* `((CFuzzyVariable*)ptr).Value(val);` -> Error: `some operator expected`.
*   **Solution:** Separate fetching, casting, and execution into distinct steps with intermediary pointers.
*   **Naming Collision:** Function arguments named similarly to class methods (e.g., `value`, `name`) can confuse the MQL5 compiler. Use prefixes like `arg_` or `_`.

## 3. Fuzzy Logic Architecture
*   **Adapter Pattern:** Essential for isolating the main EA from the volatile and complex Standard Library API. The `FuzzyAdapter` now handles internal state storage for inputs and manages the creation of complex lists/dictionaries required by the library.
*   **Definitions Header:** Move all magic strings (Variable names, Term labels) and magic numbers (Fuzzy mapping values) to a centralized `Definitions.mqh` to ensure consistency across Adapters and the Main EA.