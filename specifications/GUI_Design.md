# GUI Design Specifications

This document outlines the planned design and functionality of the on-chart Graphical User Interface (GUI) for manual user input.

## Purpose

The GUI will allow the user to manually input their discretionary observations about market conditions, which will then be fed into the fuzzy logic system.

## Proposed Elements and Inputs

### For Trend Reversal Determination (Part 1b)

1.  **Daily Rejection Candle Detected:**
    *   **Element:** Checkbox
    *   **Label:** `Daily Rejection Candle Detected?`
    *   **States:** Checked (YES) / Unchecked (NO)

2.  **H1 Breakout Strength:**
    *   **Element:** Dropdown / Radio buttons
    *   **Label:** `H1 Breakout Strength:`
    *   **Options:**
        *   `NONE` (Default)
        *   `WEAK`
        *   `STRONG`

### General GUI Considerations

*   **Placement:** Top-left corner of the chart by default, but configurable.
*   **Appearance:** Clean, minimal design to not obstruct the chart.
*   **Interaction:** User clicks on elements to change their state.
*   **Feedback:** Visual feedback on selected states.

## Integration

The `GUIPanel` class will manage these objects, capture user interactions, and provide the current state of these inputs to the main EA logic for processing by the `FuzzySystem`.

## Your Feedback

Please provide your feedback or additional requirements for the GUI design here.
