//+------------------------------------------------------------------+
//|                                       FuzzyLogicBasedOnTan.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "0.98 Beta"
#property strict

//--- Includes & Definitions
#include "Includes\Utils\Logger.mqh"
#include "Includes\Utils\Definitions.mqh" // Centralized Definitions
#include "Includes\GUI\GUIAdapter.mqh"
#include "Includes\Fuzzy\FuzzyAdapter.mqh"

//--- Global Objects
GUIAdapter    m_gui;
FuzzyAdapter *m_trend_system;
FuzzyAdapter *m_reversal_system;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Logger::Info("Main", "Initializing Independent Component Fuzzy System...");
   
   m_gui.Create(20, 50);
   InitTrendSystem();
   InitReversalSystem();

   Logger::Info("Main", "System Ready.");
   RunFuzzyLogic();
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   m_gui.Destroy();
   if(CheckPointer(m_trend_system) == POINTER_DYNAMIC) delete m_trend_system;
   if(CheckPointer(m_reversal_system) == POINTER_DYNAMIC) delete m_reversal_system;
   Comment("");
}

void OnTick() { RunFuzzyLogic(); }

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(m_gui.OnEvent(id, lparam, dparam, sparam)) RunFuzzyLogic();
}

//+------------------------------------------------------------------+
//| Main Logic Core                                                  |
//+------------------------------------------------------------------+
void RunFuzzyLogic()
{
   // 1. Get Inputs (SIMULATED for now, pending GUI update)
   // In the future, GUIAdapter needs to provide these 5 values independently
   
   // Simulating a "Perfect Buy Setup"
   double trend_val       = VAL_TREND_SIDEWAYS;
   double wick_lower      = VAL_STRENGTH_STRONG; // Strong Support Rejection (Bullish Pinbar)
   double wick_upper      = VAL_STRENGTH_NONE;   // No Resistance Rejection
   double break_up        = VAL_STRENGTH_STRONG; // Strong Breakout Up
   double break_down      = VAL_STRENGTH_NONE;   // No Breakout Down

   // 2. Set Inputs
   m_reversal_system.SetInput(FZ_VAR_TREND, trend_val);
   
   // Daily Components
   m_reversal_system.SetInput(FZ_VAR_WICK_LOWER, wick_lower);
   m_reversal_system.SetInput(FZ_VAR_WICK_UPPER, wick_upper);
   
   // H1 Components
   m_reversal_system.SetInput(FZ_VAR_H1_BREAK_UP, break_up);
   m_reversal_system.SetInput(FZ_VAR_H1_BREAK_DOWN, break_down);

   // 3. Calculate Results
   double reversal_score = m_reversal_system.GetOutput(FZ_VAR_TREND_REV);

   // 4. Update Dashboard
   string out = "=== INDEPENDENT COMPONENT FUZZY LOGIC (v0.98) ===\n";
   out += StringFormat("Input: Wick Lower (Buy Pressure): %.1f\n", wick_lower);
   out += StringFormat("Input: Wick Upper (Sell Pressure): %.1f\n", wick_upper);
   out += StringFormat("Input: Break Up   (Buy Momentum): %.1f\n", break_up);
   out += StringFormat("Input: Break Down (Sell Momentum): %.1f\n", break_down);
   out += "----------------------------\n";
   out += StringFormat("Reversal Score: %.2f\n", reversal_score);
   
   if(reversal_score > 60) out += ">> SIGNAL: STRONG BUY <<";
   else if(reversal_score < -60) out += ">> SIGNAL: STRONG SELL <<";
   else out += ">> SIGNAL: NEUTRAL / MIXED <<";

   Comment(out);
}

//+------------------------------------------------------------------+
//| Initialization Helpers                                           |
//+------------------------------------------------------------------+
void InitTrendSystem()
{
   m_trend_system = new FuzzyAdapter();
}

void InitReversalSystem()
{
   m_reversal_system = new FuzzyAdapter();
   
   // === INPUTS (Standardized 0-100) ===
   
   // 1. Trend
   m_reversal_system.AddInput(FZ_VAR_TREND, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_TREND, FZ_TERM_SIDEWAYS, 40, 50, 50, 60);
   
   // 2. Daily Wick Upper (Sell Pressure)
   m_reversal_system.AddInput(FZ_VAR_WICK_UPPER, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_WICK_UPPER, FZ_TERM_NONE,    0, 0, 10, 20);
   m_reversal_system.AddTerm(FZ_VAR_WICK_UPPER, FZ_TERM_WEAK,    20, 30, 50, 60);
   m_reversal_system.AddTerm(FZ_VAR_WICK_UPPER, FZ_TERM_STRONG,  60, 70, 100, 100);
   
   // 3. Daily Wick Lower (Buy Pressure)
   m_reversal_system.AddInput(FZ_VAR_WICK_LOWER, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_WICK_LOWER, FZ_TERM_NONE,    0, 0, 10, 20);
   m_reversal_system.AddTerm(FZ_VAR_WICK_LOWER, FZ_TERM_WEAK,    20, 30, 50, 60);
   m_reversal_system.AddTerm(FZ_VAR_WICK_LOWER, FZ_TERM_STRONG,  60, 70, 100, 100);
   
   // 4. H1 Break Up (Buy Momentum)
   m_reversal_system.AddInput(FZ_VAR_H1_BREAK_UP, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_H1_BREAK_UP, FZ_TERM_NONE,    0, 0, 10, 20);
   m_reversal_system.AddTerm(FZ_VAR_H1_BREAK_UP, FZ_TERM_WEAK,    20, 30, 50, 60);
   m_reversal_system.AddTerm(FZ_VAR_H1_BREAK_UP, FZ_TERM_STRONG,  60, 70, 100, 100);
   
   // 5. H1 Break Down (Sell Momentum)
   m_reversal_system.AddInput(FZ_VAR_H1_BREAK_DOWN, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_H1_BREAK_DOWN, FZ_TERM_NONE,   0, 0, 10, 20);
   m_reversal_system.AddTerm(FZ_VAR_H1_BREAK_DOWN, FZ_TERM_WEAK,   20, 30, 50, 60);
   m_reversal_system.AddTerm(FZ_VAR_H1_BREAK_DOWN, FZ_TERM_STRONG, 60, 70, 100, 100);

   // === OUTPUT: Trend Reversal (-100 to 100) ===
   m_reversal_system.AddOutput(FZ_VAR_TREND_REV, -100, 100);
   
   // Sell Zones
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_CLEARLY_DOWN,  -100, -100, -85, -75);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_MODERATE_DOWN, -80, -70, -70, -60);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_WEAK_DOWN,     -60, -50, -50, -40);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_STARTING_DOWN, -45, -35, -35, -25);
   
   // Neutral
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_NOT_FORMED,    -25, -5, 5, 25);
   
   // Buy Zones
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_STARTING_UP,    25, 35, 35, 45);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_WEAK_UP,        40, 50, 50, 60);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_MODERATE_UP,    60, 70, 70, 80);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_CLEARLY_UP,     75, 85, 100, 100);
   
   // === RULES (COMPONENT BASED) ===
   
   // --- BUY SCENARIOS ---
   
   // Rule B1: Strong Wick Lower + Strong Break Up -> CLEARLY UP
   string rule_b1 = "if (" + FZ_VAR_WICK_LOWER + " is " + FZ_TERM_STRONG + ") and (" 
                         + FZ_VAR_H1_BREAK_UP + " is " + FZ_TERM_STRONG + ") then (" 
                         + FZ_VAR_TREND_REV + " is " + FZ_TERM_CLEARLY_UP + ")";
   m_reversal_system.AddRule(rule_b1, 1.0);
   
   // Rule B2: Strong Wick Lower + Weak Break Up -> WEAKLY UP
   string rule_b2 = "if (" + FZ_VAR_WICK_LOWER + " is " + FZ_TERM_STRONG + ") and (" 
                         + FZ_VAR_H1_BREAK_UP + " is " + FZ_TERM_WEAK + ") then (" 
                         + FZ_VAR_TREND_REV + " is " + FZ_TERM_WEAK_UP + ")";
   m_reversal_system.AddRule(rule_b2, 0.8);
   
   // --- SELL SCENARIOS ---
   
   // Rule S1: Strong Wick Upper + Strong Break Down -> CLEARLY DOWN
   string rule_s1 = "if (" + FZ_VAR_WICK_UPPER + " is " + FZ_TERM_STRONG + ") and (" 
                         + FZ_VAR_H1_BREAK_DOWN + " is " + FZ_TERM_STRONG + ") then (" 
                         + FZ_VAR_TREND_REV + " is " + FZ_TERM_CLEARLY_DOWN + ")";
   m_reversal_system.AddRule(rule_s1, 1.0);
   
   // Rule S2: Strong Wick Upper + Weak Break Down -> WEAKLY DOWN
   string rule_s2 = "if (" + FZ_VAR_WICK_UPPER + " is " + FZ_TERM_STRONG + ") and (" 
                         + FZ_VAR_H1_BREAK_DOWN + " is " + FZ_TERM_WEAK + ") then (" 
                         + FZ_VAR_TREND_REV + " is " + FZ_TERM_WEAK_DOWN + ")";
   m_reversal_system.AddRule(rule_s2, 0.8);

   // --- DEFAULT / NEUTRAL ---
   // (Optional: Add rules for No Signal if needed, but Fuzzy handles defaults well if no rules fire)
}