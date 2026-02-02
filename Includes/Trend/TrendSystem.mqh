//+------------------------------------------------------------------+
//|                                                  TrendSystem.mqh |
//|                                                          Created |
//|                                                           by Tan |
//+------------------------------------------------------------------+
#property copyright "Tan"
#property strict

#include <Arrays\List.mqh>

//+------------------------------------------------------------------+
//| ABSTRACT BASE CLASS: CTrendModule                                |
//| Interface for all Trend Indicators.                              |
//| Must return a Normalized Score from -1.0 to +1.0                 |
//+------------------------------------------------------------------+
class CTrendModule : public CObject
  {
protected:
   string            m_name;        // Module Name (e.g. "ZigZag_D1")
   double            m_last_value;  // Cache last calculation (-1.0 to 1.0)

public:
                     CTrendModule(string name) 
                     : m_name(name), m_last_value(0.0) {}
                    ~CTrendModule() {}

   //--- MAIN INTERFACE: Must be implemented by children
   // Returns: -1.0 (Strong Bear) ... 0.0 (Neutral) ... +1.0 (Strong Bull)
   virtual double    Calculate(double current_price, datetime current_time) { return 0.0; }
   
   //--- Initialization
   virtual bool      Init() { return true; }
   
   //--- Getters
   string            Name() const { return m_name; }
   double            LastValue() const { return m_last_value; }
  };

//+------------------------------------------------------------------+
//| SYSTEM MANAGER: CTrendCollector                                  |
//| Collects inputs from all modules for the Fuzzy Engine            |
//+------------------------------------------------------------------+
class CTrendCollector
  {
private:
   CList             m_modules;     // List of CTrendModule*

public:
                     CTrendCollector() {}
                    ~CTrendCollector() { m_modules.Clear(); } 

   //--- Add a sensor module
   void AddModule(CTrendModule *module)
     {
      if(CheckPointer(module) == POINTER_DYNAMIC)
        {
         m_modules.Add(module);
        }
     }

   //--- Initialize all sensors
   bool InitAll()
     {
      bool res = true;
      CTrendModule *mod = m_modules.GetFirstNode();
      while(CheckPointer(mod) != POINTER_INVALID)
        {
         if(!mod.Init())
           {
            Print("TrendCollector: Failed to init module ", mod.Name());
            res = false;
           }
         mod = m_modules.GetNextNode();
        }
      return res;
     }

   //--- Run all calculations and return array of results
   // Use this array to feed the Fuzzy Engine
   void GetAllScores(double &output_scores[])
     {
      int count = m_modules.Total();
      ArrayResize(output_scores, count);
      
      int i = 0;
      CTrendModule *mod = m_modules.GetFirstNode();
      while(CheckPointer(mod) != POINTER_INVALID)
        {
         output_scores[i] = mod.Calculate(SymbolInfoDouble(_Symbol, SYMBOL_BID), TimeCurrent());
         mod = m_modules.GetNextNode();
         i++;
        }
     }
  };