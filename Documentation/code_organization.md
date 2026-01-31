# Code Organization (v0.90 Beta)

## Directory Structure

`MQL5/Experts/FuzzyLogicBasedOnTan/`
├── `FuzzyLogicBasedOnTan.mq5` (Main Entry Point - Clean Controller)
├── `project_env.json` (Environment Configuration - Paths & Compiler)
├── `build.bat` (Windows Build Launcher)
├── `build.ps1` (PowerShell Build Logic - reads from JSON)
├── `Includes/`
│   ├── `Fuzzy/`
│   │   └── `FuzzyAdapter.mqh` (Wraps MQL5 Standard Library for stability)
│   ├── `GUI/`
│   │   ├── `GUIPanel.mqh` (Core UI Rendering)
│   │   └── `GUIAdapter.mqh` (Maps UI states to Fuzzy values)
│   └── `Utils/`
│       ├── `Logger.mqh` (Standardized Logging)
│       └── `Definitions.mqh` (Centralized Constants & Variable Names)
├── `Tests/`
│   └── `Python_Fuzzy_Sim/`
│       ├── `fuzzy_simulator.py` (Digital Twin & GUI Simulator)
│       ├── `test_fuzzy_logic.py` (Unit Tests for Logic Verification)
│       └── `requirements.txt` (Python dependencies)
└── `Documentation/`
    ├── `rules.csv` (Official Confirmed Rules)
    ├── `lessons_learned.md` (Technical Knowledge Base & API Docs)
    ├── `algorithm.md` (Mamdani Methodology)
    └── `code_organization.md` (This file)

## Module Responsibilities

### 1. Main Controller (`FuzzyLogicBasedOnTan.mq5`)
*   **Role:** High-level Orchestrator.
*   **Tasks:** 
    *   Initializes Adapters.
    *   Delegates Event handling to `GUIAdapter`.
    *   Triggers logic calculation without knowing internal Library details.

### 2. Adapters (Isolation Layer)
*   **`FuzzyAdapter.mqh`**: 
    *   Isolates the complex MQL5 Standard Fuzzy Library.
    *   Manages internal state for crisp values (since `CFuzzyVariable` doesn't).
    *   Provides safe, string-based API for setting inputs and getting results.
*   **`GUIAdapter.mqh`**:
    *   Converts human-readable UI states (YES/NO, STRONG/WEAK) into numerical Fuzzy inputs.
    *   Centralizes the "Business Logic" of mapping UI to Logic.

### 3. GUI Module (`GUIPanel.mqh`)
*   **Version:** 7.50 (Overlay/Occlusion Mode)
*   **Features:** Dual Dropdowns, Occlusion logic, Drag & Drop with Anti-Scroll.
*   **Static Nature:** Uses static `CChartObject` members for maximum stability.

### 4. Fuzzy Core (MQL5 Standard Library)
*   **Path:** `<Math\Fuzzy\mamdanifuzzysystem.mqh>`
*   **Usage:** Leverages the official MetaQuotes implementation for Mamdani inference.

### 5. Python Digital Twin (`Tests/Python_Fuzzy_Sim/`)
*   **Role:** Offline verification and visualization.
*   **`fuzzy_simulator.py`**: A Tkinter/Matplotlib GUI that replicates the MQL5 fuzzy logic. Used to visualize membership functions and rule surfaces without compiling MQL5.
*   **`test_fuzzy_logic.py`**: Automated unit tests to ensure the logic outputs (Buy/Sell/Neutral) match the `rules.csv` specifications.

### 6. Utilities & Config
*   **`Definitions.mqh`**: The **Source of Truth** for all strings and numbers. No magic values allowed elsewhere.
*   **`project_env.json`**: Decouples the source code from the local machine environment.