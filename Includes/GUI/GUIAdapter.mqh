//+------------------------------------------------------------------+
//|                                                   GUIAdapter.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//+------------------------------------------------------------------+
#include "GUIPanel.mqh"
#include "..\Utils\Definitions.mqh"

class GUIAdapter : public CObject
{
private:
   GUIPanel m_panel;
   
   double StrengthToVal(ENUM_STRENGTH s) {
      if(s==STR_STRONG) return VAL_STRENGTH_STRONG;
      if(s==STR_WEAK)   return VAL_STRENGTH_WEAK;
      return VAL_STRENGTH_NONE;
   }
   
   string StrengthToStr(ENUM_STRENGTH s) {
      if(s==STR_STRONG) return "STRONG";
      if(s==STR_WEAK)   return "WEAK";
      return "NONE";
   }

public:
   void Create(int x, int y) { m_panel.Create(x, y); }
   void Destroy() { m_panel.Destroy(); }
   bool OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam) 
   { 
      return m_panel.OnEvent(id, lparam, dparam, sparam); 
   }

   // --- Business Logic Getters ---

   double GetTrendValue() {
      ENUM_TREND_TYPE t = m_panel.getTrend();
      if(t == TR_BEARISH) return VAL_TREND_BEARISH;
      if(t == TR_BULLISH) return VAL_TREND_BULLISH;
      return VAL_TREND_SIDEWAYS;
   }
   
   double GetUpperWickValue() { return StrengthToVal(m_panel.getWickUp()); }
   double GetLowerWickValue() { return StrengthToVal(m_panel.getWickLo()); }
   
   double GetH1BearValue()    { return StrengthToVal(m_panel.getH1Bear()); }
   double GetH1BullValue()    { return StrengthToVal(m_panel.getH1Bull()); }
   
   // Status Strings
   string GetTrendStatus() { 
      ENUM_TREND_TYPE t = m_panel.getTrend();
      if(t==TR_BEARISH) return "BEARISH";
      if(t==TR_BULLISH) return "BULLISH";
      return "SIDEWAYS";
   }
   
   string GetUpperWickStatus() { return StrengthToStr(m_panel.getWickUp()); }
   string GetLowerWickStatus() { return StrengthToStr(m_panel.getWickLo()); }
   string GetH1BearStatus()    { return StrengthToStr(m_panel.getH1Bear()); }
   string GetH1BullStatus()    { return StrengthToStr(m_panel.getH1Bull()); }
};