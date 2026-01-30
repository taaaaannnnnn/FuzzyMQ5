//+------------------------------------------------------------------+
//|                                       FuzzyLogicBasedOnTan.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "0.90 Beta"
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
   Logger::Info("Main", "Initializing with Standardized Definitions...");
   
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
   // 1. Get Inputs from GUI Adapter
   double daily_rej = m_gui.GetDailyRejectionValue();
   double h1_break  = m_gui.GetH1BreakoutValue();
   
   // Hardcoded Trend Value from Definitions (For Testing)
   double trend_scr = VAL_TREND_SIDEWAYS; 

   // 2. Set Inputs using Defined Names
   m_reversal_system.SetInput(FZ_VAR_TREND, trend_scr);
   m_reversal_system.SetInput(FZ_VAR_DAILY_REJ, daily_rej);
   m_reversal_system.SetInput(FZ_VAR_H1_BREAKOUT, h1_break);

   // 3. Calculate Results
   double reversal_score = m_reversal_system.GetOutput(FZ_VAR_TREND_REV);

   // 4. Update Dashboard
   string out = "=== FUZZY LOGIC STATUS (v0.90 Beta - No Magic Numbers) ===\n";
   out += "Daily Rejection: " + m_gui.GetDailyRejectionStatus() + "\n";
   out += "H1 Breakout: " + m_gui.GetH1BreakoutStatus() + "\n";
   out += "----------------------------\n";
   out += StringFormat("Trend Score: %.2f (Simulated)\n", trend_scr);
   out += StringFormat("Reversal Score: %.2f\n", reversal_score);
   
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
   
   // -- INPUT: Trend --
   m_reversal_system.AddInput(FZ_VAR_TREND, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_TREND, FZ_TERM_SIDEWAYS, 40, 50, 50, 60);
   
   // -- INPUT: Daily Rejection --
   m_reversal_system.AddInput(FZ_VAR_DAILY_REJ, 0, 1);
   m_reversal_system.AddTerm(FZ_VAR_DAILY_REJ, FZ_TERM_NO,  0, 0, 0, 0.1);
   m_reversal_system.AddTerm(FZ_VAR_DAILY_REJ, FZ_TERM_YES, 0.9, 1, 1, 1);
   
   // -- INPUT: H1 Breakout --
   m_reversal_system.AddInput(FZ_VAR_H1_BREAKOUT, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_H1_BREAKOUT, FZ_TERM_NONE,   0, 0, 20, 30);
   m_reversal_system.AddTerm(FZ_VAR_H1_BREAKOUT, FZ_TERM_WEAK,   30, 40, 60, 70);
   m_reversal_system.AddTerm(FZ_VAR_H1_BREAKOUT, FZ_TERM_STRONG, 70, 80, 100, 100);
   
   // -- OUTPUT: Trend Reversal --
   m_reversal_system.AddOutput(FZ_VAR_TREND_REV, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_NOT_FORMED,      0, 0, 20, 30);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_IN_OLD_TREND,    20, 30, 40, 50);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_WEAKLY_FORMING,  50, 60, 70, 80);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_CLEARLY_FORMING, 80, 90, 100, 100);
   
   // -- RULES (Constructed dynamically using Definitions) --
   
   // Rule 1: STRONG Signal -> Weight 1.0 (Default)
   string r1 = "if (" + FZ_VAR_TREND + " is " + FZ_TERM_SIDEWAYS + ") and (" 
                    + FZ_VAR_DAILY_REJ + " is " + FZ_TERM_YES + ") and (" 
                    + FZ_VAR_H1_BREAKOUT + " is " + FZ_TERM_STRONG + ") then (" 
                    + FZ_VAR_TREND_REV + " is " + FZ_TERM_CLEARLY_FORMING + ")";
   m_reversal_system.AddRule(r1, 1.0);
   
   // Rule 2: WEAK Signal -> Weight 0.8 (Less confidence)
   string r2 = "if (" + FZ_VAR_TREND + " is " + FZ_TERM_SIDEWAYS + ") and (" 
                    + FZ_VAR_DAILY_REJ + " is " + FZ_TERM_YES + ") and (" 
                    + FZ_VAR_H1_BREAKOUT + " is " + FZ_TERM_WEAK + ") then (" 
                    + FZ_VAR_TREND_REV + " is " + FZ_TERM_WEAKLY_FORMING + ")";
   m_reversal_system.AddRule(r2, 0.8);
   
   // Rule 3: NONE Signal -> Weight 1.0
   string r3 = "if (" + FZ_VAR_TREND + " is " + FZ_TERM_SIDEWAYS + ") and (" 
                    + FZ_VAR_DAILY_REJ + " is " + FZ_TERM_YES + ") and (" 
                    + FZ_VAR_H1_BREAKOUT + " is " + FZ_TERM_NONE + ") then (" 
                    + FZ_VAR_TREND_REV + " is " + FZ_TERM_NOT_FORMED + ")";
   m_reversal_system.AddRule(r3, 1.0);
   
   // Rule 4: NO Rejection -> Weight 1.0
   string r4 = "if (" + FZ_VAR_TREND + " is " + FZ_TERM_SIDEWAYS + ") and (" 
                    + FZ_VAR_DAILY_REJ + " is " + FZ_TERM_NO + ") then (" 
                    + FZ_VAR_TREND_REV + " is " + FZ_TERM_IN_OLD_TREND + ")";
   m_reversal_system.AddRule(r4, 1.0);
}