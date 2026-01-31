//+------------------------------------------------------------------+
//|                                       FuzzyLogicBasedOnTan.mq5 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "0.99 Beta"
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
   Logger::Info("Main", "Initializing Independent Component Fuzzy System v0.99 Beta...");
   
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
   // 1. Get Inputs from GUI
   double trend_val       = m_gui.GetTrendValue();
   double wick_upper      = m_gui.GetUpperWickValue();
   double wick_lower      = m_gui.GetLowerWickValue();
   double h1_bear         = m_gui.GetH1BearValue();
   double h1_bull         = m_gui.GetH1BullValue();

   // 2. Set Inputs to Fuzzy System
   m_reversal_system.SetInput(FZ_VAR_TREND, trend_val);
   m_reversal_system.SetInput(FZ_VAR_WICK_UPPER, wick_upper);
   m_reversal_system.SetInput(FZ_VAR_WICK_LOWER, wick_lower);
   m_reversal_system.SetInput(FZ_VAR_H1_BEAR, h1_bear);
   m_reversal_system.SetInput(FZ_VAR_H1_BULL, h1_bull);

   // 3. Calculate Results
   double reversal_score = m_reversal_system.GetOutput(FZ_VAR_TREND_REV);

   // 4. Update Dashboard
   string out = "=== INDEPENDENT COMPONENT FUZZY LOGIC (v0.99 Beta) ===\n";
   out += "----------------------------\n";
   out += StringFormat("Trend: %s\n", m_gui.GetTrendStatus());
   out += StringFormat("Upper Wick: %s\n", m_gui.GetUpperWickStatus());
   out += StringFormat("Lower Wick: %s\n", m_gui.GetLowerWickStatus());
   out += StringFormat("H1 Bear: %s | H1 Bull: %s\n", m_gui.GetH1BearStatus(), m_gui.GetH1BullStatus());
   out += "----------------------------\n";
   out += StringFormat("Reversal Score: %.2f\n", reversal_score);
   
   if(reversal_score >= 80)      out += ">> SIGNAL: STRONG BUY <<";
   else if(reversal_score >= 50) out += ">> SIGNAL: MODERATE BUY <<";
   else if(reversal_score >= 20) out += ">> SIGNAL: WEAK BUY / MOMENTUM <<";
   else if(reversal_score <= -80) out += ">> SIGNAL: STRONG SELL <<";
   else if(reversal_score <= -50) out += ">> SIGNAL: MODERATE SELL <<";
   else if(reversal_score <= -20) out += ">> SIGNAL: WEAK SELL / MOMENTUM <<";
   else                           out += ">> SIGNAL: NEUTRAL / CONFLICT <<";

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
   
   // === INPUTS ===
   
   // 1. Trend (Context)
   m_reversal_system.AddInput(FZ_VAR_TREND, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_TREND, FZ_TERM_BEARISH,   0, 0, 30, 40);
   m_reversal_system.AddTerm(FZ_VAR_TREND, FZ_TERM_SIDEWAYS,  40, 50, 50, 60);
   m_reversal_system.AddTerm(FZ_VAR_TREND, FZ_TERM_BULLISH,   60, 70, 100, 100);
   
   // 2. Daily Wick Upper (Sell Pressure)
   m_reversal_system.AddInput(FZ_VAR_WICK_UPPER, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_WICK_UPPER, FZ_TERM_NONE,    0, 0, 20, 30);
   m_reversal_system.AddTerm(FZ_VAR_WICK_UPPER, FZ_TERM_STRONG,  60, 70, 100, 100);
   
   // 3. Daily Wick Lower (Buy Pressure)
   m_reversal_system.AddInput(FZ_VAR_WICK_LOWER, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_WICK_LOWER, FZ_TERM_NONE,    0, 0, 20, 30);
   m_reversal_system.AddTerm(FZ_VAR_WICK_LOWER, FZ_TERM_STRONG,  60, 70, 100, 100);
   
   // 4. H1 Bear Break (Sell Momentum)
   m_reversal_system.AddInput(FZ_VAR_H1_BEAR, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_H1_BEAR, FZ_TERM_NONE,    0, 0, 20, 30);
   m_reversal_system.AddTerm(FZ_VAR_H1_BEAR, FZ_TERM_WEAK,    30, 40, 60, 70);
   m_reversal_system.AddTerm(FZ_VAR_H1_BEAR, FZ_TERM_STRONG,  70, 80, 100, 100);
   
   // 5. H1 Bull Break (Buy Momentum)
   m_reversal_system.AddInput(FZ_VAR_H1_BULL, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_H1_BULL, FZ_TERM_NONE,    0, 0, 20, 30);
   m_reversal_system.AddTerm(FZ_VAR_H1_BULL, FZ_TERM_WEAK,    30, 40, 60, 70);
   m_reversal_system.AddTerm(FZ_VAR_H1_BULL, FZ_TERM_STRONG,  70, 80, 100, 100);

   // === OUTPUT: Trend Reversal (-100 to 100) ===
   m_reversal_system.AddOutput(FZ_VAR_TREND_REV, -100, 100);
   
   // Sell Zones
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_CLEARLY_DOWN,  -100, -100, -85, -75);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_MODERATE_DOWN, -75, -65, -55, -45);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_WEAK_DOWN,     -50, -40, -40, -30);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_STARTING_DOWN, -30, -20, -20, -10);
   
   // Neutral
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_NOT_FORMED,    -10, 0, 0, 10);
   
   // Buy Zones
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_STARTING_UP,    10, 20, 20, 30);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_WEAK_UP,        30, 40, 40, 50);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_MODERATE_UP,    45, 55, 65, 75);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_CLEARLY_UP,     75, 85, 100, 100);
   
   // === RULES ===
   
   // --- 1. SIDEWAYS SCENARIOS ---
   string side = "if (Trend is SIDEWAYS) and ";

   // S1: Strong Wick + Strong Bear H1 -> Clearly Down (Target -70)
   m_reversal_system.AddRule(side + "(Daily_Upper_Wick is STRONG) and (H1_Bear_Break is STRONG) then (Trend_Reversal is MODERATE_DOWN)");
   // S2: Strong Wick + Weak Bear H1 -> Moderate Down (Target -40)
   m_reversal_system.AddRule(side + "(Daily_Upper_Wick is STRONG) and (H1_Bear_Break is WEAK) then (Trend_Reversal is WEAK_DOWN)");
   // S3: No Wick + Strong Bear H1 -> Weak Down (Target -20)
   m_reversal_system.AddRule(side + "(Daily_Upper_Wick is NONE) and (Daily_Lower_Wick is NONE) and (H1_Bear_Break is STRONG) then (Trend_Reversal is STARTING_DOWN)");
   // S4: Strong Wick + No H1 -> Starting Down (Target -10)
   m_reversal_system.AddRule(side + "(Daily_Upper_Wick is STRONG) and (H1_Bear_Break is NONE) and (H1_Bull_Break is NONE) then (Trend_Reversal is STARTING_DOWN)");

   // B1: Strong Wick + Strong Bull H1 -> Clearly Up (Target +70)
   m_reversal_system.AddRule(side + "(Daily_Lower_Wick is STRONG) and (H1_Bull_Break is STRONG) then (Trend_Reversal is MODERATE_UP)");
   // B2: Strong Wick + Weak Bull H1 -> Moderate Up (Target +40)
   m_reversal_system.AddRule(side + "(Daily_Lower_Wick is STRONG) and (H1_Bull_Break is WEAK) then (Trend_Reversal is WEAK_UP)");
   // B3: No Wick + Strong Bull H1 -> Weak Up (Target +20)
   m_reversal_system.AddRule(side + "(Daily_Lower_Wick is NONE) and (Daily_Upper_Wick is NONE) and (H1_Bull_Break is STRONG) then (Trend_Reversal is STARTING_UP)");
   // B4: Strong Wick + No H1 -> Starting Up (Target +10)
   m_reversal_system.AddRule(side + "(Daily_Lower_Wick is STRONG) and (H1_Bull_Break is NONE) and (H1_Bear_Break is NONE) then (Trend_Reversal is STARTING_UP)");

   // CONFLICT RULES (SIDEWAYS ONLY)
   // S_CONFLICT: Upper Wick (Sell) + H1 Bull (Buy) -> Neutralize (-15)
   m_reversal_system.AddRule(side + "(Daily_Upper_Wick is STRONG) and (H1_Bull_Break is STRONG) then (Trend_Reversal is WEAK_UP)");
   // B_CONFLICT: Lower Wick (Buy) + H1 Bear (Sell) -> Neutralize (+15)
   m_reversal_system.AddRule(side + "(Daily_Lower_Wick is STRONG) and (H1_Bear_Break is STRONG) then (Trend_Reversal is WEAK_DOWN)");

   // --- 2. UPTREND SCENARIOS ---
   string up = "if (Trend is BULLISH) and ";
   
   // U1: Follow - Strong Wick + Strong Bull -> Clearly Up (Super Buy)
   m_reversal_system.AddRule(up + "(Daily_Lower_Wick is STRONG) and (H1_Bull_Break is STRONG) then (Trend_Reversal is CLEARLY_UP)");
   // U2: Follow - Strong Wick + Weak Bull -> Moderate Up
   m_reversal_system.AddRule(up + "(Daily_Lower_Wick is STRONG) and (H1_Bull_Break is WEAK) then (Trend_Reversal is MODERATE_UP)");
   // U3: Follow - No Wick + Strong Bull -> Moderate Up
   m_reversal_system.AddRule(up + "(Daily_Lower_Wick is NONE) and (H1_Bull_Break is STRONG) then (Trend_Reversal is MODERATE_UP)");

   // U_C1: Counter - Strong Wick Upper + Strong Bear -> Weak Down
   m_reversal_system.AddRule(up + "(Daily_Upper_Wick is STRONG) and (H1_Bear_Break is STRONG) then (Trend_Reversal is WEAK_DOWN)");
   // U_C2: Counter - Strong Wick Upper + Weak Bear -> Starting Down
   m_reversal_system.AddRule(up + "(Daily_Upper_Wick is STRONG) and (H1_Bear_Break is WEAK) then (Trend_Reversal is STARTING_DOWN)");
   // U_C3 REMOVED: Prevent double punishment. Friction rule handles the wick impact.

   // ** U_DRAG: Friction Rule **
   // If Uptrend but hitting Resistance (Upper Wick), reduce the Buy score SLIGHTLY (was WEAK_DOWN, now STARTING_DOWN)
   m_reversal_system.AddRule(up + "(Daily_Upper_Wick is STRONG) then (Trend_Reversal is STARTING_DOWN)");
   
   // ** U_MOM_DRAG: Momentum Drag **
   // If Uptrend but H1 is crashing (Strong Bear), reduce Buy score even if no Daily Wick
   m_reversal_system.AddRule(up + "(H1_Bear_Break is STRONG) then (Trend_Reversal is STARTING_DOWN)");


   // --- 3. DOWNTREND SCENARIOS ---
   string dn = "if (Trend is BEARISH) and ";

   // D1: Follow - Strong Wick + Strong Bear -> Clearly Down (Super Sell)
   m_reversal_system.AddRule(dn + "(Daily_Upper_Wick is STRONG) and (H1_Bear_Break is STRONG) then (Trend_Reversal is CLEARLY_DOWN)");
   // D2: Follow - Strong Wick + Weak Bear -> Moderate Down
   m_reversal_system.AddRule(dn + "(Daily_Upper_Wick is STRONG) and (H1_Bear_Break is WEAK) then (Trend_Reversal is MODERATE_DOWN)");
   // D3: Follow - No Wick + Strong Bear -> Moderate Down
   m_reversal_system.AddRule(dn + "(Daily_Upper_Wick is NONE) and (H1_Bear_Break is STRONG) then (Trend_Reversal is MODERATE_DOWN)");

   // D_C1: Counter - Strong Wick Lower + Strong Bull -> Weak Up
   m_reversal_system.AddRule(dn + "(Daily_Lower_Wick is STRONG) and (H1_Bull_Break is STRONG) then (Trend_Reversal is WEAK_UP)");
   // D_C2: Counter - Strong Wick Lower + Weak Bull -> Starting Up
   m_reversal_system.AddRule(dn + "(Daily_Lower_Wick is STRONG) and (H1_Bull_Break is WEAK) then (Trend_Reversal is STARTING_UP)");
   // D_C3 REMOVED

   // ** D_DRAG: Friction Rule **
   // If Downtrend but hitting Support (Lower Wick), reduce the Sell score SLIGHTLY
   m_reversal_system.AddRule(dn + "(Daily_Lower_Wick is STRONG) then (Trend_Reversal is STARTING_UP)");
   
   // ** D_MOM_DRAG: Momentum Drag **
   // If Downtrend but H1 is pumping (Strong Bull), reduce Sell score even if no Daily Wick
   m_reversal_system.AddRule(dn + "(H1_Bull_Break is STRONG) then (Trend_Reversal is STARTING_UP)");
}