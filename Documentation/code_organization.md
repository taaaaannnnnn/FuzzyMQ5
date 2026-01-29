# Code Organization (v7.50)

## Directory Structure

`MQL5/Experts/FuzzyLogicBasedOnTan/`
├── `FuzzyLogicBasedOnTan.mq5` (Main Entry Point - Controller)
├── `Includes/`
│   ├── `Fuzzy/` (Core Logic - Native Arrays, No StdLib Dependency)
│   │   ├── `FuzzySet.mqh`
│   │   ├── `FuzzyVariable.mqh`
│   │   ├── `FuzzyRule.mqh`
│   │   └── `FuzzySystem.mqh`
│   ├── `GUI/`
│   │   └── `GUIPanel.mqh` (Light Theme, Dual Dropdowns, Anti-Scroll)
│   └── `Utils/`
│       └── `Logger.mqh` (Simple Console Logging)
└── `Documentation/`
    ├── `rules.csv` (Official Rules)
    ├── `lessons_learned.md` (Technical Knowledge Base)
    ├── `algorithm.md`
    └── `code_organization.md` (This file)

## Module Responsibilities

### 1. Main Controller (`FuzzyLogicBasedOnTan.mq5`)
*   **Role:** Orchestrator.
*   **Tasks:** 
    *   Initializes Systems (Trend, Reversal) and GUI.
    *   Handles `OnChartEvent` to trigger logic immediately upon UI interaction.
    *   Maps raw UI inputs to Fuzzy variables.
    *   Displays final output using `Comment()`.

### 2. GUI Module (`GUIPanel.mqh`)
*   **Version:** 7.50 (Overlay/Occlusion Mode)
*   **Features:**
    *   **Dual Dropdowns:** "Daily Rejection" and "H1 Breakout" use custom dropdowns.
    *   **Occlusion:** Hides lower elements when a dropdown expands to prevent visual overlap.
    *   **Static Objects:** Uses `CChartObject...` members directly (no pointers) for stability.
    *   **Light Theme:** Professional look (Black text on Light Green/Gray).
    *   **UX:** Anti-scroll dragging mechanism.

### 3. Fuzzy Core (`Includes/Fuzzy/`)
*   **Philosophy:** "Zero Dependency". Uses native MQL5 dynamic arrays (`[]` + `ArrayResize`) instead of `CArrayObj` to avoid compiler path issues.
*   **Components:** 
    *   `FuzzySet`: Membership functions & Centroid calculation.
    *   `FuzzySystem`: Inference engine using Mamdani-like logic & Height Method defuzzification.

### 4. Utilities
*   **`Logger.mqh`**: Centralized logging helper to keep Main EA clean.
