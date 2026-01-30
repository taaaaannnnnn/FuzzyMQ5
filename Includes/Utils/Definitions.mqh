//+------------------------------------------------------------------+
//|                                                  Definitions.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//+------------------------------------------------------------------+
#property strict

//====================================================================
// FUZZY VARIABLES (NAMES)
//====================================================================
#define FZ_VAR_TREND            "Trend"
#define FZ_VAR_DAILY_REJ        "Daily_Rejection"
#define FZ_VAR_H1_BREAKOUT      "H1_Breakout"
#define FZ_VAR_TREND_REV        "Trend_Reversal"

//====================================================================
// FUZZY TERMS (LABELS)
//====================================================================
// Trend
#define FZ_TERM_SIDEWAYS        "SIDEWAYS"

// Daily Rejection
#define FZ_TERM_NO              "NO"
#define FZ_TERM_YES             "YES"

// H1 Breakout
#define FZ_TERM_NONE            "NONE"
#define FZ_TERM_WEAK            "WEAK"
#define FZ_TERM_STRONG          "STRONG"

// Trend Reversal Output
#define FZ_TERM_NOT_FORMED      "NOT_FORMED"
#define FZ_TERM_IN_OLD_TREND    "IN_OLD_TREND"
#define FZ_TERM_WEAKLY_FORMING  "WEAKLY_FORMING"
#define FZ_TERM_CLEARLY_FORMING "CLEARLY_FORMING"

//====================================================================
// CRISP VALUES (MAGIC NUMBERS)
//====================================================================
// Values used for mapping GUI states to Fuzzy Inputs
#define VAL_BOOL_TRUE           1.0
#define VAL_BOOL_FALSE          0.0

#define VAL_H1_NONE             0.0
#define VAL_H1_WEAK             50.0
#define VAL_H1_STRONG           90.0

#define VAL_TREND_SIDEWAYS      50.0 // Center of Sideways set
