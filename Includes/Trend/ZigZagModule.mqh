//+------------------------------------------------------------------+
//|                                                 ZigZagModule.mqh |
//|                                                          Created |
//|                                                           by Tan |
//|                               Refactored: Position + Bias V4 |
//+------------------------------------------------------------------+
#property copyright "Tan"
#property strict

#include "TrendSystem.mqh"

class CZigZagModule : public CTrendModule
  {
private:
   int               m_handle;      // Indicator handle
   int               m_buffer_idx;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_period;

public:
                     CZigZagModule(string name, int handle, ENUM_TIMEFRAMES period, int buffer_idx=0)
                     : CTrendModule(name), m_handle(handle), m_period(period), m_buffer_idx(buffer_idx)
     {
      m_symbol = _Symbol;
     }
                    ~CZigZagModule() {}

   //--- Implementation: Returns -1.0 to 1.0 (Continuous Scoring)
   virtual double Calculate(double current_price, datetime current_time) override
     {
      if(m_handle == INVALID_HANDLE) return 0.0;

      // 1. Get History Points: P1..P4
      double pts[5]; 
      if(!GetZigZagVertices(pts)) return 0.0;
      pts[0] = current_price; // Current Dynamic Price

      // 2. Calculate Components
      double score_pos  = CalcPositionScore(pts); // Where is price in the range?
      double score_bias = CalcStructureBias(pts); // What is the trend structure?

      // 3. Combine: Position (60%) + Structure (40%)
      // This ensures that even if price pulls back (Pos drops), Structure holds the score up.
      double total_score = (score_pos * 0.6) + (score_bias * 0.4);
      
      // Clamp
      if(total_score > 1.0) total_score = 1.0;
      if(total_score < -1.0) total_score = -1.0;

      // LOG TO CONSOLE
      PrintFormat("TrendModule [%s]: Pos=%.2f, Bias=%.2f | Total=%.2f", 
                  m_name, score_pos, score_bias, total_score);

      m_last_value = total_score;
      return total_score;
     }

private:
   //--- Helper: Get raw points P1..P4
   bool GetZigZagVertices(double &out_points[])
     {
      int required = 4;
      int found = 0;
      double buff[];
      
      int count = CopyBuffer(m_handle, m_buffer_idx, 0, 1000, buff);
      if(count < 0) return false;

      ArraySetAsSeries(buff, true);

      for(int i=1; i<count; i++)
        {
         if(buff[i] != 0.0 && buff[i] != EMPTY_VALUE)
           {
            found++;
            out_points[found] = buff[i];
            if(found >= required) break;
           }
        }
      return (found >= required);
     }

   //--- LOGIC 1: POSITION SCORE (-1.0 to 1.0)
   // Determines where the price is relative to the recent trading range.
   double CalcPositionScore(const double &p[])
     {
      // Find Min/Max in recent history (P1..P4)
      double max_h = p[1];
      double min_l = p[1];
      
      for(int i=2; i<=4; i++)
      {
         if(p[i] > max_h) max_h = p[i];
         if(p[i] < min_l) min_l = p[i];
      }
      
      // Safety Check
      if(max_h <= min_l) return 0.0;
      
      // Range Properties
      double range = max_h - min_l;
      double mid   = min_l + (range / 2.0);
      
      // Check Dynamic Breakout
      double current = p[0];
      
      // Normalized Position: -1 (at Low) to +1 (at High)
      // Formula: (Price - Mid) / (Range / 2)
      double pos = (current - mid) / (range / 2.0);
      
      // Allow over-extension (Breakout) up to 1.2 or 1.5, then clamp
      if(pos > 1.2) pos = 1.2; 
      if(pos < -1.2) pos = -1.2;
      
      // If breakout is HUGE, we clamp it to avoid skewing, 
      // but let it be slightly > 1.0 to show power.
      
      return pos;
     }

   //--- LOGIC 2: STRUCTURE BIAS (-1.0 to 1.0)
   // Determines the "Tilt" of the market based on Highs and Lows.
   double CalcStructureBias(const double &p[])
     {
      // P1 is the Anchor.
      // Identify sequences of Highs and Lows.
      // Case A: Last Leg UP (P1 is High). Seq: H1-L2-H3-L4
      bool p1_is_high = (p[1] > p[2]);
      
      double score = 0;
      
      if(p1_is_high)
      {
         // Compare Highs (H1 vs H3)
         if(p[1] > p[3]) score += 0.5; // Higher High
         else            score -= 0.5; // Lower High
         
         // Compare Lows (L2 vs L4)
         if(p[2] > p[4]) score += 0.5; // Higher Low
         else            score -= 0.5; // Lower Low
      }
      else // Case B: Last Leg DOWN (P1 is Low). Seq: L1-H2-L3-H4
      {
         // Compare Lows (L1 vs L3)
         if(p[1] > p[3]) score += 0.5; // Higher Low
         else            score -= 0.5; // Lower Low
         
         // Compare Highs (H2 vs H4)
         if(p[2] > p[4]) score += 0.5; // Higher High
         else            score -= 0.5; // Lower High
      }
      
      // Result:
      // HH + HL = +1.0 (Strong Bull)
      // HH + LL = 0.0 (Expanding/Confusion)
      // LH + HL = 0.0 (Compressing/Triangle)
      // LH + LL = -1.0 (Strong Bear)
      
      return score;
     }
  };
