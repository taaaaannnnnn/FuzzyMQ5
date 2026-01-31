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
#define FZ_VAR_WICK_UPPER       "Daily_Upper_Wick"      // Resistance Rejection
#define FZ_VAR_WICK_LOWER       "Daily_Lower_Wick"      // Support Rejection

// Split H1 Breakout (Momentum)
#define FZ_VAR_H1_BULL          "H1_Bull_Break"
#define FZ_VAR_H1_BEAR          "H1_Bear_Break"

// Output
#define FZ_VAR_TREND_REV        "Trend_Reversal"

//====================================================================
// FUZZY TERMS (LABELS)
//====================================================================
// Trend (Context)
#define FZ_TERM_BEARISH         "BEARISH"
#define FZ_TERM_SIDEWAYS        "SIDEWAYS"
#define FZ_TERM_BULLISH         "BULLISH"

// Strength Terms (Used for Wicks & Breakouts)
#define FZ_TERM_NONE            "NONE"
#define FZ_TERM_WEAK            "WEAK"   // Used for H1
#define FZ_TERM_STRONG          "STRONG"

// Trend Reversal Output (-100 to 100)
#define FZ_TERM_CLEARLY_DOWN    "CLEARLY_DOWN"
#define FZ_TERM_MODERATE_DOWN   "MODERATE_DOWN"
#define FZ_TERM_WEAK_DOWN       "WEAK_DOWN"
#define FZ_TERM_STARTING_DOWN   "STARTING_DOWN"

#define FZ_TERM_NOT_FORMED      "NOT_FORMED"

#define FZ_TERM_STARTING_UP     "STARTING_UP"
#define FZ_TERM_WEAK_UP         "WEAK_UP"
#define FZ_TERM_MODERATE_UP     "MODERATE_UP"
#define FZ_TERM_CLEARLY_UP      "CLEARLY_UP"

//====================================================================
// CRISP VALUES (MAGIC NUMBERS)
//====================================================================

// Strength Values (0-100)
#define VAL_STRENGTH_NONE       10.0  
#define VAL_STRENGTH_WEAK       50.0  
#define VAL_STRENGTH_STRONG     90.0  

// Trend Values
#define VAL_TREND_BEARISH       20.0
#define VAL_TREND_SIDEWAYS      50.0
#define VAL_TREND_BULLISH       80.0
