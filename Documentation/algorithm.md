# Fuzzy Logic Algorithm

We will implement a fuzzy inference system based on the Mamdani method, which is one of the most common approaches. This process consists of the following main steps:

1.  **Fuzzification:** Convert crisp input values from indicators (e.g., an RSI value of 25) into fuzzy values.
    *   For example, an RSI value of 25 might be interpreted as `OVER_SOLD` to a degree of `0.8` and `SELL` to a degree of `0.2`.
    *   This is achieved using **membership functions**, which are typically triangular or trapezoidal in shape.

2.  **Rule Evaluation:** Apply the defined fuzzy rules (from the `rules.md` file) to the fuzzy values.
    *   For instance, consider the rule `IF RSI is OVER_SOLD AND MACD is RISING THEN Decision is BUY`.
    *   If `RSI is OVER_SOLD` has a truth degree of `0.8` and `MACD is RISING` has a truth degree of `0.5`, the strength of this rule (using the AND operator, typically the MIN function) will be `MIN(0.8, 0.5) = 0.5`.

3.  **Aggregation:** Combine the results from all rules. Each rule "clips" a portion of the output variable's membership function (e.g., `BUY`, `SELL`, `WAIT`). All these clipped portions are aggregated to form a single fuzzy region for the output.

4.  **Defuzzification:** Convert the aggregated fuzzy region from the output into a single crisp output value.
    *   For example, convert the fuzzy decision region into a specific number, such as +0.8 (STRONG BUY), -0.2 (WEAK SELL), or 0.0 (WAIT).
    *   We will use the "Center of Gravity" (Centroid) method to find the representative value for the final decision.