# Gemini Context & Instructions

# 0. CRITICAL ZERO TOLERANCE PROTOCOL (READ FIRST)
*   **NO SAMPLES IN CODE:** NEVER implement "Sample Rules", "Example Logic", or "Placeholders" into `.mq5` or `.mqh` files.
*   **CONFIRMED ONLY:** You are strictly forbidden from implementing any trading logic (Rules) unless it is explicitly listed in `Documentation/rules.csv` or `Documentation/rules.md` under a "CONFIRMED" header.
*   **EMPTY IS BETTER:** If a system (e.g., "Trend System") has no confirmed rules yet, initialize the variables but LEAVE THE RULE SET EMPTY. Do not try to "make it work" with fake data.
*   **VIOLATION CONSEQUENCE:** Adding unconfirmed logic is considered a critical system failure.

---

Whenever a new session begins or context needs to be refreshed, follow these steps to ensure continuity and alignment with the project's state:

## 1. Context Retrieval
Thoroughly review the following resources in order:
1.  **Environment Config (`project_env.json`):** Read this first to locate Terminal and Include paths.
2.  **This File (`Gemini.md`):** For global mandates and coding standards.
3.  **Lessons Learned (`Documentation/lessons_learned.md`):** To avoid repeating past technical errors.
3.  **Project State:** Read `Documentation/code_organization.md` and the latest log in `Logs/`.
4.  **Logic & Rules:** Read `Documentation/rules.csv` for confirmed trading logic.

## 2. Technical Mandates (MQL5 Specific)
-   **Static UI Objects:** Use `CChartObjectButton m_btn;` (static) instead of pointers. NEVER use `new`/`delete` for UI unless absolutely necessary.
-   **Member Access:** ALWAYS use the dot operator (`.`) for both objects and pointers to ensure compiler compatibility.
-   **Method Signatures:** Use the 5-parameter `Create(chart, name, win, x, y)` for all ChartObjects, then set `X_Size()` and `Y_Size()` explicitly.
-   **Fuzzy Core:** MUST use the **MQL5 Standard Library** (`<Math\Fuzzy\MamdaniFuzzySystem.mqh>`). Do NOT write custom fuzzy engines.
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