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

#### Input Variables (Automated - Suggestions):
*   **MA_Slope:** (Slope of a long-term Moving Average)
    *   `STEEP_UP`, `SLIGHT_UP`, `FLAT`, `SLIGHT_DOWN`, `STEEP_DOWN`
*   **ADX_Value:** (Value of the Average Directional Index)
    *   `WEAK_OR_NO_TREND` (< 25), `STRONG_TREND` (>= 25)

#### Output Variable:
*   **Trend:**
    *   `STRONG_UP`, `WEAK_UP`, `SIDEWAYS`, `WEAK_DOWN`, `STRONG_DOWN`

#### Sample Rules:
1.  IF `MA_Slope` IS `STEEP_UP` AND `ADX_Value` IS `STRONG_TREND` THEN `Trend` IS `STRONG_UP`.
2.  IF `MA_Slope` IS `FLAT` THEN `Trend` IS `SIDEWAYS`.
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

#### Rules for Trend_Reversal (based on your input):
These rules apply only IF `Trend` IS `SIDEWAYS`.

1.  IF `Daily_Rejection_Candle_Detected` IS `YES` AND `H1_Breakout_Strength` IS `STRONG` THEN `Trend_Reversal` IS `CLEARLY_FORMING`.
2.  IF `Daily_Rejection_Candle_Detected` IS `YES` AND `H1_Breakout_Strength` IS `WEAK` THEN `Trend_Reversal` IS `WEAKLY_FORMING`.
3.  IF `Daily_Rejection_Candle_Detected` IS `YES` AND `H1_Breakout_Strength` IS `NONE` THEN `Trend_Reversal` IS `NOT_FORMED`.
4.  IF `Daily_Rejection_Candle_Detected` IS `NO` THEN `Trend_Reversal` IS `IN_OLD_TREND`.

---

## Part 2: Trading Decision Rules

This part will use the `Trend` and `Trend_Reversal` variables from Part 1 as its inputs, along with other Automated/Manual inputs.

### Input Variables (Suggestions):
*   `Trend` (Output from Part 1a)
*   `Trend_Reversal` (Output from Part 1b)
*   `RSI_Value` (Automated)
*   `Stochastic_Oscillator` (Automated)

### Output Variable:
*   **Decision:**
    *   `BUY`, `SELL`, `WAIT`

### Sample Rules:
1.  IF `Trend` IS `STRONG_UP` AND `RSI_Value` IS `OVER_SOLD` THEN `Decision` IS `BUY`.
2.  IF `Trend_Reversal` IS `CLEARLY_FORMING` (and it's a bullish reversal, assuming the context provides this) THEN `Decision` IS `BUY`.
3.  IF `Trend` IS `SIDEWAYS` THEN `Decision` IS `WAIT`.

---

## **YOUR AREA**
**(Please add/edit your rules for all parts here)**

**Part 1a Rules (Trend):**
1.  ...

**Part 1b Rules (Trend Reversal):**
1.  IF `Trend` IS `SIDEWAYS` AND `Daily_Rejection_Candle_Detected` IS `YES` AND `H1_Breakout_Strength` IS `STRONG` THEN `Trend_Reversal` IS `CLEARLY_FORMING`.
2.  IF `Trend` IS `SIDEWAYS` AND `Daily_Rejection_Candle_Detected` IS `YES` AND `H1_Breakout_Strength` IS `WEAK` THEN `Trend_Reversal` IS `WEAKLY_FORMING`.
3.  IF `Trend` IS `SIDEWAYS` AND `Daily_Rejection_Candle_Detected` IS `YES` AND `H1_Breakout_Strength` IS `NONE` THEN `Trend_Reversal` IS `NOT_FORMED`.
4.  IF `Trend` IS `SIDEWAYS` AND `Daily_Rejection_Candle_Detected` IS `NO` THEN `Trend_Reversal` IS `IN_OLD_TREND`.

**Part 2 Rules (Decision):**
1.  ...
