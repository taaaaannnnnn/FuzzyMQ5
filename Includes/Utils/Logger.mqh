//+------------------------------------------------------------------+
//|                                                       Logger.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

class Logger
{
public:
   static void Info(string context, string message)
   {
      PrintFormat("[INFO] [%s] %s", context, message);
   }
   
   static void Action(string ui_element, string value)
   {
      PrintFormat("[ACTION] User changed '%s' to: %s", ui_element, value);
   }
   
   static void Error(string context, string message)
   {
      PrintFormat("[ERROR] [%s] %s", context, message);
   }
};
