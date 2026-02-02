//+------------------------------------------------------------------+
//|                                                 ZigZagModule.mqh |
//|                                                          Created |
//|                                                           by Tan |
//+------------------------------------------------------------------+
#property copyright "Tan"
#property strict

#include "TrendSystem.mqh"

// Struct for internal calculation
struct ZigZagLeg
  {
   double            start_price;
   double            end_price;
   datetime          start_time;
   datetime          end_time;
   double            length_pips;
   int               duration_bars;
   double            velocity;
   bool              is_bullish;
  };

class CZigZagModule : public CTrendModule
  {
private:
   int               m_handle;      // Indicator handle
   int               m_buffer_idx;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_period;
   double            m_sensitivity; // Sensitivity factor (1.0 = standard, <1.0 = filtered)

public:
                     CZigZagModule(string name, int handle, ENUM_TIMEFRAMES period, int buffer_idx=0, double sensitivity=1.0)
                     : CTrendModule(name), m_handle(handle), m_period(period), m_buffer_idx(buffer_idx), m_sensitivity(sensitivity)
     {
      m_symbol = _Symbol;
     }
                    ~CZigZagModule() {}

   //--- Implementation: Returns -1.0 to 1.0
   virtual double Calculate(double current_price, datetime current_time) override
     {
      if(m_handle == INVALID_HANDLE) return 0.0;

      // 1. Get Data
      double points[5];
      datetime times[5];
      if(!GetZigZagVertices(points, times)) return 0.0;
      
      points[0] = current_price;
      times[0] = current_time;

      // 2. Build Legs
      ZigZagLeg legs[4];
      BuildLegs(points, times, legs);

      // 3. Sub-Calculations
      double score_struct = CalcStructure(points); 
      
      double dir = 0;
      if(score_struct > 0) dir = 1.0;
      else if(score_struct < 0) dir = -1.0;

      if(dir == 0) 
        {
         m_last_value = 0.0;
         return 0.0;
        }

      double score_effic  = CalcEfficiency(legs, dir);  
      double score_time   = CalcTiming(legs, dir);      

      // 4. DYNAMIC TIMING BONUS
      double velocity_bonus = 0;
      if(score_time > 20.0) velocity_bonus = 10.0 * dir; 

      // 5. Combine Logic
      double raw_total = score_struct + (score_effic * dir) + (score_time * dir) + velocity_bonus;
      
      // APPLY SENSITIVITY SCALING
      // This dampens the score for noisy timeframes
      raw_total *= m_sensitivity;
      
      double normalized = raw_total / 100.0;
      
      if(normalized > 1.0) normalized = 1.0;
      if(normalized < -1.0) normalized = -1.0;
      
      // LOG TO CONSOLE
      PrintFormat("TrendModule [%s]: Struct=%.1f, Effic=%.1f, Time=%.1f, Bonus=%.1f | Total(Scaled)=%.2f", 
                  m_name, score_struct, score_effic, score_time, velocity_bonus, normalized);

      m_last_value = normalized;
      return normalized;
     }

private:
   //--- Helpers (Same logic as before, just kept compact)
   bool GetZigZagVertices(double &out_points[], datetime &out_times[])
     {
      int required = 4;
      int found = 0;
      double buff[];
      datetime time_buff[];
      
      int count = CopyBuffer(m_handle, m_buffer_idx, 0, 1000, buff);
      int t_count = CopyTime(m_symbol, m_period, 0, 1000, time_buff);
      
      if(count < 0 || t_count < 0) return false;

      ArraySetAsSeries(buff, true);
      ArraySetAsSeries(time_buff, true);

      for(int i=1; i<count; i++)
        {
         if(buff[i] != 0.0 && buff[i] != EMPTY_VALUE)
           {
            found++;
            out_points[found] = buff[i];
            out_times[found] = time_buff[i];
            if(found >= required) break;
           }
        }
      return (found >= required);
     }

   void BuildLegs(const double &pts[], const datetime &tms[], ZigZagLeg &out_legs[])
     {
      double point_val = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      if(point_val == 0) point_val = 0.00001;

      for(int i=0; i<4; i++)
        {
         out_legs[i].start_price = pts[i+1];
         out_legs[i].end_price   = pts[i];
         out_legs[i].start_time  = tms[i+1];
         out_legs[i].end_time    = tms[i];
         out_legs[i].length_pips = MathAbs(pts[i] - pts[i+1]) / point_val;
         
         long seconds = (long)tms[i] - (long)tms[i+1];
         int bars = (int)(seconds / PeriodSeconds(m_period));
         if(bars < 1) bars = 1; 
         out_legs[i].duration_bars = bars;
         out_legs[i].velocity = out_legs[i].length_pips / bars;
         out_legs[i].is_bullish = (pts[i] > pts[i+1]);
        }
     }

   double CalcStructure(const double &pts[])
     {
      // pts[0] = Current Price (Dynamic)
      // pts[1] = Last Hard Vertex
      // pts[2] = Vertex before P1
      // pts[3] = Vertex before P2
      // pts[4] = Vertex before P3

      bool p1_is_high = (pts[1] > pts[2]);
      
      // Calculate Average Impulse Velocity for Timing Bonus
      double v_current = 0;
      double v_avg_imp = 0;
      int count_imp = 0;
      
      double point_val = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      if(point_val == 0) point_val = 0.00001;

      // Current Leg (Leg 0) velocity
      double len0 = MathAbs(pts[0] - pts[1]) / point_val;
      // Note: duration calculation here is an estimate since we don't have full leg info yet in this scope
      // We'll use a simplified version for the bonus.
      
      // --- LOGIC 1: DYNAMIC BREAKOUT CHECK (BOS) ---
      
      if(p1_is_high) // Moving down from High P1
      {
         if(pts[0] > pts[1]) return 50.0; // Breakout Up (Strong Bullish)
         
         if(pts[0] < pts[2]) // Lower Low
         {
            if(pts[1] < pts[3]) return -50.0; // LH + LL (Strong Bearish)
            return -30.0; // Reversal Down
         }
      }
      else // Moving up from Low P1
      {
         if(pts[0] < pts[1]) return -50.0; // Breakout Down (Strong Bearish)
         
         if(pts[0] > pts[2]) // Higher High
         {
            if(pts[1] > pts[3]) return 50.0; // HL + HH (Strong Bullish)
            return 30.0; // Reversal Up
         }
      }

      // --- LOGIC 2: HISTORICAL STRUCTURE (Standard) ---
      if(p1_is_high) // Sequence: H(1)-L(2)-H(3)-L(4)
        {
         bool HH = (pts[1] > pts[3]);
         bool HL = (pts[2] > pts[4]);
         if(HH && HL) return 40.0;
         if(HH) return 20.0;
         if(HL) return 10.0;
         return -10.0;
        }
      else // Sequence: L(1)-H(2)-L(3)-H(4)
        {
         bool LL = (pts[1] < pts[3]);
         bool LH = (pts[2] < pts[4]);
         if(LL && LH) return -40.0;
         if(LL) return -20.0;
         if(LH) return -10.0;
         return 10.0;
        }
     }

   //--- Logic 2: Efficiency (Max 30, Signed based on Price Movement)
   double CalcEfficiency(const ZigZagLeg &legs[], double direction_sign)
     {
      double total_path = 0;
      for(int i=0; i<4; i++) total_path += legs[i].length_pips;
      if(total_path == 0) return 0;
      
      double point_val = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
      if(point_val == 0) point_val = 0.00001;

      // SIGNED Displacement: Current Price (Leg 0 End) minus Start Price (Leg 3 Start)
      double displacement = (legs[0].end_price - legs[3].start_price) / point_val;
      
      // E = Displacement / Total_Path
      // If Displacement is in same direction as Trend (direction_sign), E is positive.
      // If price has reversed below start point, E becomes negative, penalizing the score.
      double E = displacement / total_path; 
      
      // We normalize E to a 0-1.0 scale relative to the intended direction
      double relative_E = E * direction_sign; 
      
      double score = relative_E * 30.0; 
      if(score > 30.0) score = 30.0;
      if(score < -30.0) score = -30.0; // Can be negative if price reverses hard
      
      return score;
     }

   //--- Logic 3: Timing (Max 30, Signed based on Performance)
   double CalcTiming(const ZigZagLeg &legs[], double direction_sign)
     {
      // direction_sign: 1.0 for Bull, -1.0 for Bear
      bool trend_bull = (direction_sign > 0);
      
      double v_imp = 0, v_cor = 0;
      int c_imp = 0, c_cor = 0;
      
      for(int i=0; i<4; i++)
        {
         if(legs[i].is_bullish == trend_bull) { v_imp += legs[i].velocity; c_imp++; }
         else                                 { v_cor += legs[i].velocity; c_cor++; }
        }
        
      if(c_cor == 0 || v_cor == 0) return 30.0; 
      
      double avg_imp = (c_imp > 0) ? v_imp/c_imp : 0;
      double avg_cor = v_cor/c_cor;
      if(avg_cor == 0) return 30.0;
      
      double ratio = avg_imp / avg_cor; 
      
      // If Impulse is slower than Correction (Ratio < 1.0), it's a negative sign for the trend
      double score = (ratio - 1.0) * 30.0;
      
      if(score > 30.0) score = 30.0;
      if(score < -15.0) score = -15.0; // Penalty for slow impulse
      
      return score;
     }
  };
