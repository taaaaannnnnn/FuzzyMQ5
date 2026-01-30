//+------------------------------------------------------------------+
//|                                       FuzzyLogicBasedOnTan.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "7.51"
#property strict

//--- Includes
#include "Includes\Utils\Logger.mqh"
#include "Includes\GUI\GUIPanel.mqh"
#include "Includes\Fuzzy\FuzzySystem.mqh"
#include "Includes\Fuzzy\FuzzyVariable.mqh"
#include "Includes\Fuzzy\FuzzySet.mqh"
#include "Includes\Fuzzy\FuzzyRule.mqh"

//--- Global Objects
GUIPanel    m_gui;
FuzzySystem *m_trend_system;
FuzzySystem *m_reversal_system;
FuzzySystem *m_decision_system;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Logger::Info("Main", "System Initializing...");

   // 1. Initialize GUI
   m_gui.Create(20, 50);

   // 2. Initialize Fuzzy Systems
   InitTrendSystem();
   InitReversalSystem();
   // InitDecisionSystem(); // Reserved for Part 2

   Logger::Info("Main", "System Initialized Successfully.");
   
   // Run initial logic check
   RunFuzzyLogic();
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   m_gui.Destroy();
   
   if(CheckPointer(m_trend_system) == POINTER_DYNAMIC) delete m_trend_system;
   if(CheckPointer(m_reversal_system) == POINTER_DYNAMIC) delete m_reversal_system;
   if(CheckPointer(m_decision_system) == POINTER_DYNAMIC) delete m_decision_system;
   
   Logger::Info("Main", "System Deinitialized.");
   Comment("");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // In a real scenario, we might want to run this only on new bars
   // or periodically. For now, we run it to keep indicators updated.
   RunFuzzyLogic();
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   // Delegate event handling to GUI
   // If GUI returns true (interaction occurred), we run the logic immediately
   if(m_gui.OnEvent(id, lparam, dparam, sparam))
   {
      RunFuzzyLogic();
   }
}

//+------------------------------------------------------------------+
//| Main Logic Core                                                  |
//+------------------------------------------------------------------+
void RunFuzzyLogic()
{
   // --- 1. Gather Inputs ---
   
   // A. Automated Inputs (Mocked for now, strictly per instructions to not assume indicators)
   // TODO: Replace these with real iMA, iADX, iRSI calls
   double ma_slope_val = 0.5; // Flat
   double adx_val      = 30.0; // Strong Trend
   
   // B. Manual Inputs (From GUI)
   bool   is_daily_rej = m_gui.getDailyRejectionDetected();
   int    h1_breakout  = (int)m_gui.getH1BreakoutStrength(); // 0=None, 1=Weak, 2=Strong
   
   // Map Enum to Fuzzy Value (0-100 scale)
   double h1_val_fuzzy = 0.0;
   if(h1_breakout == 1) h1_val_fuzzy = 50.0; // Weak
   if(h1_breakout == 2) h1_val_fuzzy = 90.0; // Strong
   
   double daily_rej_fuzzy = is_daily_rej ? 1.0 : 0.0;

   // --- 2. Fuzzify & Evaluate System 1a (Trend) ---
   FuzzyVariable *fv_slope = m_trend_system.getInputVariableByName("MA_Slope");
   FuzzyVariable *fv_adx   = m_trend_system.getInputVariableByName("ADX_Value");
   
   if(fv_slope != NULL) fv_slope.fuzzify(ma_slope_val);
   if(fv_adx != NULL)   fv_adx.fuzzify(adx_val);
   
   double trend_score = m_trend_system.calculate("Trend");
   
   // --- 3. Fuzzify & Evaluate System 1b (Reversal) ---
   FuzzyVariable *fv_trend_rev = m_reversal_system.getInputVariableByName("Trend");
   FuzzyVariable *fv_rej       = m_reversal_system.getInputVariableByName("Daily_Rejection");
   FuzzyVariable *fv_h1        = m_reversal_system.getInputVariableByName("H1_Breakout");
   
   // Pass Output of System 1a into System 1b
   if(fv_trend_rev != NULL) fv_trend_rev.fuzzify(trend_score);
   
   // Pass Manual Inputs
   if(fv_rej != NULL) fv_rej.fuzzify(daily_rej_fuzzy);
   if(fv_h1 != NULL)  fv_h1.fuzzify(h1_val_fuzzy);
   
   double reversal_score = m_reversal_system.calculate("Trend_Reversal");

   // --- 4. Output Display ---
   string out = "=== FUZZY LOGIC STATUS (v7.50) ===\n";
   out += "--- Inputs ---\n";
   out += StringFormat("MA Slope (Auto): %.2f\n", ma_slope_val);
   out += StringFormat("Daily Rejection (Manual): %s\n", is_daily_rej ? "YES" : "NO");
   out += StringFormat("H1 Breakout (Manual): %s\n", EnumToString((ENUM_H1_BREAKOUT_STRENGTH)h1_breakout));
   out += "\n--- Fuzzy Outputs ---\n";
   out += StringFormat("Trend Score: %.2f\n", trend_score);
   out += StringFormat("Reversal Score: %.2f\n", reversal_score);
   
   Comment(out);
}

//+------------------------------------------------------------------+
//| Initialization Helpers                                           |
//+------------------------------------------------------------------+
void InitTrendSystem()
{
   m_trend_system = new FuzzySystem();
   
   // -- INPUT: MA_Slope --
   FuzzyVariable *slope = new FuzzyVariable("MA_Slope");
   slope.addFuzzySet(new FuzzySet("STEEP_UP",    80, 90, 100, 100));
   slope.addFuzzySet(new FuzzySet("SLIGHT_UP",   60, 70, 80, 90));
   slope.addFuzzySet(new FuzzySet("FLAT",        40, 50, 50, 60));
   slope.addFuzzySet(new FuzzySet("SLIGHT_DOWN", 10, 20, 30, 40));
   slope.addFuzzySet(new FuzzySet("STEEP_DOWN",   0,  0, 10, 20));
   m_trend_system.addInputVariable(slope);
   
   // -- INPUT: ADX_Value --
   FuzzyVariable *adx = new FuzzyVariable("ADX_Value");
   adx.addFuzzySet(new FuzzySet("WEAK_OR_NO", 0, 0, 20, 30));
   adx.addFuzzySet(new FuzzySet("STRONG",     25, 35, 100, 100));
   m_trend_system.addInputVariable(adx);
   
   // -- OUTPUT: Trend --
   FuzzyVariable *trend = new FuzzyVariable("Trend");
   trend.addFuzzySet(new FuzzySet("STRONG_UP",   80, 90, 100, 100));
   trend.addFuzzySet(new FuzzySet("WEAK_UP",     60, 70, 80, 90));
   trend.addFuzzySet(new FuzzySet("SIDEWAYS",    40, 50, 50, 60));
   trend.addFuzzySet(new FuzzySet("WEAK_DOWN",   10, 20, 30, 40));
   trend.addFuzzySet(new FuzzySet("STRONG_DOWN",  0,  0, 10, 20));
   m_trend_system.addOutputVariable(trend);
   
   // -- RULES --
   // No confirmed rules for Trend Analysis (Part 1a) yet.
   // Waiting for user definition.
}

void InitReversalSystem()
{
   m_reversal_system = new FuzzySystem();
   
   // -- INPUT: Trend (From Prev System) --
   FuzzyVariable *trend = new FuzzyVariable("Trend");
   trend.addFuzzySet(new FuzzySet("SIDEWAYS", 40, 50, 50, 60)); // Only mapping relevant sets for Reversal logic
   m_reversal_system.addInputVariable(trend);
   
   // -- INPUT: Daily Rejection (Binary but Fuzzy) --
   FuzzyVariable *rej = new FuzzyVariable("Daily_Rejection");
   rej.addFuzzySet(new FuzzySet("NO",  0, 0, 0, 0.1));
   rej.addFuzzySet(new FuzzySet("YES", 0.9, 1, 1, 1));
   m_reversal_system.addInputVariable(rej);
   
   // -- INPUT: H1 Breakout --
   FuzzyVariable *h1 = new FuzzyVariable("H1_Breakout");
   h1.addFuzzySet(new FuzzySet("NONE",   0, 0, 20, 30));
   h1.addFuzzySet(new FuzzySet("WEAK",   30, 40, 60, 70));
   h1.addFuzzySet(new FuzzySet("STRONG", 70, 80, 100, 100));
   m_reversal_system.addInputVariable(h1);
   
   // -- OUTPUT: Trend Reversal --
   FuzzyVariable *rev = new FuzzyVariable("Trend_Reversal");
   rev.addFuzzySet(new FuzzySet("NOT_FORMED",     0, 0, 20, 30));
   rev.addFuzzySet(new FuzzySet("IN_OLD_TREND",   20, 30, 40, 50)); // Arbitrary placement
   rev.addFuzzySet(new FuzzySet("WEAKLY_FORMING", 50, 60, 70, 80));
   rev.addFuzzySet(new FuzzySet("CLEARLY_FORMING",80, 90, 100, 100));
   m_reversal_system.addOutputVariable(rev);
   
   // -- RULES (From rules.md) --
   
   // 1. IF Trend IS SIDEWAYS AND Rej IS YES AND H1 IS STRONG THEN Reversal IS CLEARLY_FORMING
   FuzzyRule *r1 = new FuzzyRule();
   r1.addAntecedent(trend, "SIDEWAYS");
   r1.addAntecedent(rej, "YES");
   r1.addAntecedent(h1, "STRONG");
   r1.setConsequent(rev, "CLEARLY_FORMING");
   m_reversal_system.addRule(r1);
   
   // 2. IF Trend IS SIDEWAYS AND Rej IS YES AND H1 IS WEAK THEN Reversal IS WEAKLY_FORMING
   FuzzyRule *r2 = new FuzzyRule();
   r2.addAntecedent(trend, "SIDEWAYS");
   r2.addAntecedent(rej, "YES");
   r2.addAntecedent(h1, "WEAK");
   r2.setConsequent(rev, "WEAKLY_FORMING");
   m_reversal_system.addRule(r2);
   
   // 3. IF Trend IS SIDEWAYS AND Rej IS YES AND H1 IS NONE THEN Reversal IS NOT_FORMED
   FuzzyRule *r3 = new FuzzyRule();
   r3.addAntecedent(trend, "SIDEWAYS");
   r3.addAntecedent(rej, "YES");
   r3.addAntecedent(h1, "NONE");
   r3.setConsequent(rev, "NOT_FORMED");
   m_reversal_system.addRule(r3);
   
   // 4. IF Trend IS SIDEWAYS AND Rej IS NO THEN Reversal IS IN_OLD_TREND
   FuzzyRule *r4 = new FuzzyRule();
   r4.addAntecedent(trend, "SIDEWAYS");
   r4.addAntecedent(rej, "NO");
   r4.setConsequent(rev, "IN_OLD_TREND");
   m_reversal_system.addRule(r4);
}
