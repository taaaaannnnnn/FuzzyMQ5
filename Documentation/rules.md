# Trading Rules

This document defines the rules for the fuzzy logic system. Our system will have a two-step process:
1.  **Market Analysis:** First, we analyze the market to determine two things in parallel: the current `Trend` and if a `Trend_Reversal` is occurring.
2.  **Trading Decision:** Then, we use the `Trend`, `Trend_Reversal`, and other indicators to make a Buy/Sell/Wait decision.

---

## Input Variable Classification

We will have two types of input variables:
*   **Automated Inputs:** Values calculated directly from technical indicators.
*   **Manual Inputs:** Values provided by the user via an on-chart GUI.

---

## Part 1: Market Analysis

### Part 1a: Trend Determination

*(Waiting for User Definitions...)*

---
### Part 1b: Trend Reversal Determination

#### Input Variables:
*   **Trend:** (Automated - Output from Part 1a)
*   **Daily_Rejection_Candle_Detected:** (Manual Input - Boolean: `YES`/`NO`)
*   **H1_Breakout_Strength:** (Manual Input - Fuzzy Variable)
    *   `STRONG`
    *   `WEAK`
    *   `NONE`

#### Output Variable:
*   **Trend_Reversal:**
    *   `CLEARLY_FORMING`
    *   `WEAKLY_FORMING`
    *   `NOT_FORMED`
    *   `IN_OLD_TREND`

#### CONFIRMED RULES (Implemented & Verified):
These rules apply only IF `Trend` IS `SIDEWAYS`.
*(Status: VERIFIED via Python Simulator v1.0)*

1.  IF `Daily_Rejection_Candle_Detected` IS `YES` AND `H1_Breakout_Strength` IS `STRONG` THEN `Trend_Reversal` IS `CLEARLY_FORMING`.
2.  IF `Daily_Rejection_Candle_Detected` IS `YES` AND `H1_Breakout_Strength` IS `WEAK` THEN `Trend_Reversal` IS `WEAKLY_FORMING`.
3.  IF `Daily_Rejection_Candle_Detected` IS `YES` AND `H1_Breakout_Strength` IS `NONE` THEN `Trend_Reversal` IS `NOT_FORMED`.
4.  IF `Daily_Rejection_Candle_Detected` IS `NO` THEN `Trend_Reversal` IS `IN_OLD_TREND`.

---

## Part 2: Trading Decision Rules

*(Waiting for User Definitions...)*

---

## **YOUR AREA**
**(Please add/edit your rules for all parts here)**

**Part 1a Rules (Trend):**
*(Empty)*

**Part 1b Rules (Trend Reversal):**
1.  IF `Trend` IS `SIDEWAYS` AND `Daily_Rejection_Candle_Detected` IS `YES` AND `H1_Breakout_Strength` IS `STRONG` THEN `Trend_Reversal` IS `CLEARLY_FORMING`.
2.  IF `Trend` IS `SIDEWAYS` AND `Daily_Rejection_Candle_Detected` IS `YES` AND `H1_Breakout_Strength` IS `WEAK` THEN `Trend_Reversal` IS `WEAKLY_FORMING`.
3.  IF `Trend` IS `SIDEWAYS` AND `Daily_Rejection_Candle_Detected` IS `YES` AND `H1_Breakout_Strength` IS `NONE` THEN `Trend_Reversal` IS `NOT_FORMED`.
4.  IF `Trend` IS `SIDEWAYS` AND `Daily_Rejection_Candle_Detected` IS `NO` THEN `Trend_Reversal` IS `IN_OLD_TREND`.

**Part 2 Rules (Decision):**
*(Empty)*
