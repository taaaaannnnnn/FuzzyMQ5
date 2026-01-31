//+------------------------------------------------------------------+
//|                                                  Definitions.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//+------------------------------------------------------------------+
#property strict

//====================================================================
// FUZZY VARIABLES (NAMES)
//====================================================================
#define FZ_VAR_TREND            "Trend"

// Split Daily Rejection (Wicks)
#define FZ_VAR_WICK_UPPER       "Daily_Wick_Upper"      // Resistance Rejection
#define FZ_VAR_WICK_LOWER       "Daily_Wick_Lower"      // Support Rejection

// Split H1 Breakout (Momentum)
#define FZ_VAR_H1_BREAK_UP      "H1_Break_Up"
#define FZ_VAR_H1_BREAK_DOWN    "H1_Break_Down"

// Output
#define FZ_VAR_TREND_REV        "Trend_Reversal"

//====================================================================
// FUZZY TERMS (LABELS)
//====================================================================
// Trend (Context)
#define FZ_TERM_SIDEWAYS        "SIDEWAYS"

// Component Strength (Used for Wicks & Breakouts)
#define FZ_TERM_NONE            "NONE"
#define FZ_TERM_WEAK            "WEAK"
#define FZ_TERM_STRONG          "STRONG"

// Trend Reversal Output (-100 to 100)
#define FZ_TERM_CLEARLY_DOWN    "CLEARLY_DOWN"      // -100 to -80
#define FZ_TERM_MODERATE_DOWN   "MODERATE_DOWN"     // -80 to -60
#define FZ_TERM_WEAK_DOWN       "WEAK_DOWN"         // -60 to -40
#define FZ_TERM_STARTING_DOWN   "STARTING_DOWN"     // -40 to -20

#define FZ_TERM_NOT_FORMED      "NOT_FORMED"        // -20 to +20

#define FZ_TERM_STARTING_UP     "STARTING_UP"       // +20 to +40
#define FZ_TERM_WEAK_UP         "WEAK_UP"           // +40 to +60
#define FZ_TERM_MODERATE_UP     "MODERATE_UP"       // +60 to +80
#define FZ_TERM_CLEARLY_UP      "CLEARLY_UP"        // +80 to +100

//====================================================================
// CRISP VALUES (MAGIC NUMBERS)
//====================================================================
// Values used for mapping GUI states to Fuzzy Inputs
#define VAL_BOOL_TRUE           1.0
#define VAL_BOOL_FALSE          0.0

// Simplified Testing Values
#define VAL_STRENGTH_NONE       0.0
#define VAL_STRENGTH_WEAK       50.0
#define VAL_STRENGTH_STRONG     90.0

#define VAL_TREND_SIDEWAYS      50.0 // Center of Sideways set
