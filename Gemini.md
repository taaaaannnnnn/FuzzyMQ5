# Gemini Context & Instructions

Whenever a new session begins or context needs to be refreshed, follow these steps to ensure continuity and alignment with the project's state:

## 1. Context Retrieval
Thoroughly review the following resources in order:
1.  **This File (`Gemini.md`):** For global mandates and coding standards.
2.  **Lessons Learned (`Documentation/lessons_learned.md`):** To avoid repeating past technical errors (syntax, library conflicts).
3.  **Project State:** Read `Documentation/code_organization.md` and the latest log in `Logs/`.
4.  **Logic & Rules:** Read `Documentation/rules.csv` for confirmed trading logic.

## 2. Technical Mandates (MQL5 Specific)
-   **Static UI Objects:** Use `CChartObjectButton m_btn;` (static) instead of pointers. NEVER use `new`/`delete` for UI unless absolutely necessary.
-   **Member Access:** ALWAYS use the dot operator (`.`) for both objects and pointers to ensure compiler compatibility.
-   **Method Signatures:** Use the 5-parameter `Create(chart, name, win, x, y)` for all ChartObjects, then set `X_Size()` and `Y_Size()` explicitly.
-   **Fuzzy Core:** Keep the Fuzzy Logic engine "Native". Use dynamic arrays `[]` and `ArrayResize` instead of `CArrayObj`.
-   **Logging:** Use the `Logger` utility class for system-wide information and user actions.

## 3. UI/UX Design Standards
-   **Light Theme:** Background `clrWhiteSmoke`, Text `clrBlack`, Active Buttons `clrLightGreen`.
-   **Dropdown Mechanics:**
    -   Use **Occlusion logic**: When a dropdown opens, hide (`X_Distance(-1000)`) all UI elements that would be covered by it.
    -   Auto-collapse dropdowns when an item is selected or when another dropdown is opened.
-   **Interaction Pattern:** Trigger logic updates (`RunFuzzyLogic()`) immediately inside `OnChartEvent` upon successful UI interaction (`return true` from `GUIPanel::OnEvent`).
-   **Smooth Dragging:** Disable chart scrolling (`CHART_MOUSE_SCROLL`) during drag operations and re-enable it on mouse up.

## 4. Operational Protocols
-   **Confirmed Logic Only:** Only implement rules marked as "Confirmed" in `rules.csv`.
-   **No Assumptions:** If a rule or UI behavior is ambiguous, ask the user. NEVER add "Sample" code to the production files.
-   **Build Verification:** Always run `.\build.ps1` after changes to verify zero errors.
-   **Source of Truth:** Maintain `.md` files proactively. If a new pattern is established, update `lessons_learned.md` immediately.
