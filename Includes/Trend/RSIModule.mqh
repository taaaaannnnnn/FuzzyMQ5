//+------------------------------------------------------------------+
//|                                                   RSIModule.mqh |
//|                                                          Created |
//|                                                           by Tan |
//+------------------------------------------------------------------+
#property copyright "Tan"
#property strict

#include "TrendSystem.mqh"

class CRSIModule : public CTrendModule
  {
private:
   int               m_handle;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_period;
   int               m_period_rsi;

public:
                     CRSIModule(string name, int period_rsi)
                     : CTrendModule(name), m_period_rsi(period_rsi)
     {
      m_symbol = _Symbol;
      m_period = _Period;
      m_handle = iRSI(m_symbol, m_period, m_period_rsi, PRICE_CLOSE);
     }
                    ~CRSIModule() {}

   virtual double Calculate(double current_price, datetime current_time) override
     {
      if(m_handle == INVALID_HANDLE) return 0.0;
      
      double buff[];
      ArraySetAsSeries(buff, true);
      
      // Copy last 1 value
      if(CopyBuffer(m_handle, 0, 0, 1, buff) < 0) return 0.0;
      
      double rsi = buff[0];
      
      // Normalize RSI (0-100) to (-1.0 to 1.0)
      // Center at 50. 
      // 50 -> 0
      // 100 -> 1.0
      // 0 -> -1.0
      
      double normalized = (rsi - 50.0) / 50.0;
      
      // Clamp (RSI is usually 0-100 anyway)
      if(normalized > 1.0) normalized = 1.0;
      if(normalized < -1.0) normalized = -1.0;
      
      m_last_value = normalized;
      return normalized;
     }
  };
