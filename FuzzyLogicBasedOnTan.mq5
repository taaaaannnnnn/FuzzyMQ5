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
#include "Includes\Utils\Definitions.mqh" 
#include "Includes\GUI\GUIAdapter.mqh"
#include "Includes\Fuzzy\FuzzyAdapter.mqh"

//--- Trend System Includes
#include "Includes\Trend\TrendSystem.mqh"
#include "Includes\Trend\ZigZagModule.mqh"

//--- Global Objects
GUIAdapter      m_gui;
FuzzyAdapter   *m_reversal_system;
CTrendCollector m_trend_collector;

//--- Indicator Handles
int h_zz_slow = INVALID_HANDLE;
int h_zz_fast = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Logger::Info("Main", "Initializing Modular Fuzzy System v0.99 Beta...");
   
   // --- CHART VISUAL SETUP (B&W Style) ---
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   
   // Mode
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
   ChartSetInteger(0, CHART_SHOW_GRID, false); // Optional: Cleaner look
   
   // Colors
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrWhite);
   ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrBlack); // Text & Scale
   
   // Candle Colors
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrBlack);  // Body Bear -> Black
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrWhite);  // Body Bull -> White
   
   // Wicks & Borders (All Black)
   ChartSetInteger(0, CHART_COLOR_CHART_UP, clrBlack);     // Border Bull -> Black
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrBlack);   // Border Bear -> Black
   ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrBlack);   // Line Graph / Doji -> Black

   // 1. GUI Setup - Initializing at Bottom Left
   int chart_height = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS);
   int panel_height = 230; // Standard height defined in GUIPanel
   int initial_x = 20;
   int initial_y = chart_height - panel_height - 40; 
   if(initial_y < 0) initial_y = 50; // Fallback
   
   m_gui.Create(initial_x, initial_y);
   
   // 2. Trend Modules Setup (Major D1, Minor H1)
   h_zz_slow = iCustom(_Symbol, PERIOD_D1, "Examples\\ZigZag", 12, 5, 3);
   h_zz_fast = iCustom(_Symbol, PERIOD_H1, "Examples\\ZigZag", 5, 2, 2);
   
   if(h_zz_slow == INVALID_HANDLE || h_zz_fast == INVALID_HANDLE)
   {
      Logger::Error("Main", "Failed to create ZigZag handles!");
      return(INIT_FAILED);
   }
   
   m_trend_collector.AddModule(new CZigZagModule("Major_ZZ", h_zz_slow, PERIOD_D1));
   m_trend_collector.AddModule(new CZigZagModule("Minor_ZZ", h_zz_fast, PERIOD_H1));
   
   if(!m_trend_collector.InitAll()) return(INIT_FAILED);

   // 3. Reversal Logic Setup
   InitReversalSystem();

   Logger::Info("Main", "System Ready.");
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   m_gui.Destroy();
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
   // 1. Calculate Real-time Trends
   double trend_scores[];
   m_trend_collector.GetAllScores(trend_scores);
   
   double score_major = (ArraySize(trend_scores) > 0) ? trend_scores[0] : 0;
   double score_minor = (ArraySize(trend_scores) > 1) ? trend_scores[1] : 0;

   // 2. Get Other Inputs from GUI
   double wick_upper      = m_gui.GetUpperWickValue();
   double wick_lower      = m_gui.GetLowerWickValue();
   double h1_bear         = m_gui.GetH1BearValue();
   double h1_bull         = m_gui.GetH1BullValue();

   // 3. Set Inputs to Fuzzy System (Using Major Trend for now)
   double fuzzy_trend_input = (score_major + 1.0) * 50.0; 
   
   m_reversal_system.SetInput(FZ_VAR_TREND, fuzzy_trend_input);
   m_reversal_system.SetInput(FZ_VAR_WICK_UPPER, wick_upper);
   m_reversal_system.SetInput(FZ_VAR_WICK_LOWER, wick_lower);
   m_reversal_system.SetInput(FZ_VAR_H1_BEAR, h1_bear);
   m_reversal_system.SetInput(FZ_VAR_H1_BULL, h1_bull);

   // 4. Calculate Results
   double reversal_score = m_reversal_system.GetOutput(FZ_VAR_TREND_REV);

   // 4. Update Dashboard
   string out = "=== MODULAR FUZZY SYSTEM (v0.99 Beta) ===\n";
   out += "------------------------------------------\n";
   out += StringFormat("MAJOR TREND (D1): %.4f\n", score_major);
   out += StringFormat("MINOR TREND (H1): %.4f\n", score_minor);
   out += "------------------------------------------\n";
   out += StringFormat("Input Trend (Mapped): %.1f\n", fuzzy_trend_input);
   out += StringFormat("Upper Wick: %s\n", m_gui.GetUpperWickStatus());
   out += StringFormat("Lower Wick: %s\n", m_gui.GetLowerWickStatus());
   out += StringFormat("H1 Bear: %s | H1 Bull: %s\n", m_gui.GetH1BearStatus(), m_gui.GetH1BullStatus());
   out += "------------------------------------------\n";
   out += StringFormat("Logic Score: %.2f\n", reversal_score);
   
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
//| Initialization Helpers (Logic remained same as previous)         |
//+------------------------------------------------------------------+
void InitReversalSystem()
{
   m_reversal_system = new FuzzyAdapter();
   
   // (Rest of the InitReversalSystem logic remains exactly as you had it)
   // I'll keep the rules you confirmed in previous session
   m_reversal_system.AddInput(FZ_VAR_TREND, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_TREND, FZ_TERM_BEARISH,   0, 0, 30, 40);
   m_reversal_system.AddTerm(FZ_VAR_TREND, FZ_TERM_SIDEWAYS,  40, 50, 50, 60);
   m_reversal_system.AddTerm(FZ_VAR_TREND, FZ_TERM_BULLISH,   60, 70, 100, 100);
   
   m_reversal_system.AddInput(FZ_VAR_WICK_UPPER, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_WICK_UPPER, FZ_TERM_NONE,    0, 0, 20, 30);
   m_reversal_system.AddTerm(FZ_VAR_WICK_UPPER, FZ_TERM_STRONG,  60, 70, 100, 100);
   
   m_reversal_system.AddInput(FZ_VAR_WICK_LOWER, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_WICK_LOWER, FZ_TERM_NONE,    0, 0, 20, 30);
   m_reversal_system.AddTerm(FZ_VAR_WICK_LOWER, FZ_TERM_STRONG,  60, 70, 100, 100);
   
   m_reversal_system.AddInput(FZ_VAR_H1_BEAR, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_H1_BEAR, FZ_TERM_NONE,    0, 0, 20, 30);
   m_reversal_system.AddTerm(FZ_VAR_H1_BEAR, FZ_TERM_WEAK,    30, 40, 60, 70);
   m_reversal_system.AddTerm(FZ_VAR_H1_BEAR, FZ_TERM_STRONG,  70, 80, 100, 100);
   
   m_reversal_system.AddInput(FZ_VAR_H1_BULL, 0, 100);
   m_reversal_system.AddTerm(FZ_VAR_H1_BULL, FZ_TERM_NONE,    0, 0, 20, 30);
   m_reversal_system.AddTerm(FZ_VAR_H1_BULL, FZ_TERM_WEAK,    30, 40, 60, 70);
   m_reversal_system.AddTerm(FZ_VAR_H1_BULL, FZ_TERM_STRONG,  70, 80, 100, 100);

   m_reversal_system.AddOutput(FZ_VAR_TREND_REV, -100, 100);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_CLEARLY_DOWN,  -100, -100, -85, -75);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_MODERATE_DOWN, -75, -65, -55, -45);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_WEAK_DOWN,     -50, -40, -40, -30);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_STARTING_DOWN, -30, -20, -20, -10);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_NOT_FORMED,    -10, 0, 0, 10);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_STARTING_UP,    10, 20, 20, 30);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_WEAK_UP,        30, 40, 40, 50);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_MODERATE_UP,    45, 55, 65, 75);
   m_reversal_system.AddTerm(FZ_VAR_TREND_REV, FZ_TERM_CLEARLY_UP,     75, 85, 100, 100);

   // Side, Up, Dn rules from previous sessions...
   string side = "if (Trend is SIDEWAYS) and ";
   m_reversal_system.AddRule(side + "(Daily_Upper_Wick is STRONG) and (H1_Bear_Break is STRONG) then (Trend_Reversal is MODERATE_DOWN)");
   m_reversal_system.AddRule(side + "(Daily_Upper_Wick is STRONG) and (H1_Bear_Break is WEAK) then (Trend_Reversal is WEAK_DOWN)");
   m_reversal_system.AddRule(side + "(Daily_Lower_Wick is STRONG) and (H1_Bull_Break is STRONG) then (Trend_Reversal is MODERATE_UP)");
   m_reversal_system.AddRule(side + "(Daily_Lower_Wick is STRONG) and (H1_Bull_Break is WEAK) then (Trend_Reversal is WEAK_UP)");
   
   string up = "if (Trend is BULLISH) and ";
   m_reversal_system.AddRule(up + "(Daily_Lower_Wick is STRONG) and (H1_Bull_Break is STRONG) then (Trend_Reversal is CLEARLY_UP)");
   m_reversal_system.AddRule(up + "(Daily_Upper_Wick is STRONG) and (H1_Bear_Break is STRONG) then (Trend_Reversal is MODERATE_DOWN)");
   m_reversal_system.AddRule(up + "(Daily_Upper_Wick is STRONG) then (Trend_Reversal is STARTING_DOWN)");
   
   string dn = "if (Trend is BEARISH) and ";
   m_reversal_system.AddRule(dn + "(Daily_Upper_Wick is STRONG) and (H1_Bear_Break is STRONG) then (Trend_Reversal is CLEARLY_DOWN)");
   m_reversal_system.AddRule(dn + "(Daily_Lower_Wick is STRONG) and (H1_Bull_Break is STRONG) then (Trend_Reversal is MODERATE_UP)");
   m_reversal_system.AddRule(dn + "(Daily_Lower_Wick is STRONG) then (Trend_Reversal is STARTING_UP)");
}