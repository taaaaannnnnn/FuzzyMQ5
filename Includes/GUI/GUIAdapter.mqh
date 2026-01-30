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

public:
   void Create(int x, int y) { m_panel.Create(x, y); }
   void Destroy() { m_panel.Destroy(); }
   bool OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam) 
   { 
      return m_panel.OnEvent(id, lparam, dparam, sparam); 
   }

   // Business Logic Getters
   double GetDailyRejectionValue() 
   { 
      return m_panel.getDailyRejectionDetected() ? VAL_BOOL_TRUE : VAL_BOOL_FALSE; 
   }
   
   double GetH1BreakoutValue() 
   {
      int val = (int)m_panel.getH1BreakoutStrength();
      if(val == 1) return VAL_H1_WEAK;   // Mapped from Definitions
      if(val == 2) return VAL_H1_STRONG; // Mapped from Definitions
      return VAL_H1_NONE;
   }
   
   string GetH1BreakoutStatus() { return EnumToString(m_panel.getH1BreakoutStrength()); }
   string GetDailyRejectionStatus() { return m_panel.getDailyRejectionDetected() ? "YES" : "NO"; }
};