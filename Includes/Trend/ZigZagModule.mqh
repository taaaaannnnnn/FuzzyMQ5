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
   int               m_handle;      // ZigZag handle
   int               m_handle_atr;  // ATR handle for normalization
   int               m_buffer_idx;
   string            m_symbol;
   ENUM_TIMEFRAMES   m_period;
   double            m_sensitivity; 

public:
                     CZigZagModule(string name, int handle, int handle_atr, ENUM_TIMEFRAMES period, int buffer_idx=0, double sensitivity=1.0)
                     : CTrendModule(name), m_handle(handle), m_handle_atr(handle_atr), m_period(period), m_buffer_idx(buffer_idx), m_sensitivity(sensitivity)
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
      
      // Get ATR for Volatility Context
      double atr = GetCurrentATR();
      if(atr == 0) atr = 0.00100; // Fallback
      
      points[0] = current_price;
      times[0] = current_time;

      // 2. Build Legs
      ZigZagLeg legs[4];
      BuildLegs(points, times, legs);

      // 3. Sub-Calculations (New Continuous Logic)
      double score_struct = CalcStructure(points, atr); 
      
      double dir = 0;
      if(score_struct > 0) dir = 1.0;
      else if(score_struct < 0) dir = -1.0;

      if(dir == 0) 
        {
         m_last_value = 0.0;
         return 0.0;
        }

      // --- LOGIC FIX: Handle V-Shape Reversal ---
      double score_effic = 0;
      // Is it a breakout? If structure score is high (> 20), we assume breakout phase
      bool is_breakout = (MathAbs(score_struct) >= 20.0);
      
      if(is_breakout)
      {
         double point_val = SymbolInfoDouble(m_symbol, SYMBOL_POINT);
         if(point_val == 0) point_val = 0.00001;
         
         double leg0_len = legs[0].length_pips;
         double displacement = (legs[0].end_price - legs[0].start_price) / point_val;
         
         double E = 0;
         if(leg0_len > 0) E = displacement / leg0_len; 
         
         double relative_E = E * dir; 
         score_effic = relative_E * 30.0;
         if(score_effic < 0) score_effic = 0; 
      }
      else
      {
         score_effic = CalcEfficiency(legs, dir); 
      }

      double score_time   = CalcTiming(legs, dir);      

      // 4. DYNAMIC TIMING BONUS
      double velocity_bonus = 0;
      if(score_time > 20.0) velocity_bonus = 10.0 * dir; 

      // 5. SIDEWAYS SUPPRESSION
      double damping = 1.0;
      double abs_effic = MathAbs(score_effic);
      if(abs_effic < 15.0) 
      {
         damping = 0.5; 
         score_struct *= damping;
         score_time   *= damping;
         velocity_bonus *= damping;
      }

      // 6. Combine Logic
      double raw_total = score_struct + (score_effic * dir) + (score_time * dir) + velocity_bonus;
      raw_total *= m_sensitivity;
      
      double normalized = raw_total / 100.0;
      
      if(normalized > 1.0) normalized = 1.0;
      if(normalized < -1.0) normalized = -1.0;
      
      PrintFormat("TrendModule [%s]: Struct=%.1f, Effic=%.1f, Time=%.1f, Bonus=%.1f, Damp=%.1f | Total=%.2f", 
                  m_name, score_struct, score_effic, score_time, velocity_bonus, damping, normalized);

      m_last_value = normalized;
      return normalized;
     }

private:
   //--- Helpers
   double GetCurrentATR()
   {
      if(m_handle_atr == INVALID_HANDLE) return 0.0;
      double buff[1];
      if(CopyBuffer(m_handle_atr, 0, 0, 1, buff) > 0) return buff[0];
      return 0.0;
   }

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

   // --- CONTINUOUS STRUCTURE LOGIC ---
   double CalcStructure(const double &pts[], double atr)
     {
      // pts[0]=Cur, pts[1]=LastHard
      bool p1_is_high = (pts[1] > pts[2]);
      
      // Threshold for significant breakout (e.g., 0.5 ATR)
      double threshold = atr * 0.5;
      if(threshold == 0) threshold = 0.0001;

      if(p1_is_high) // Moving down from P1
      {
         // 1. Breakout Up Check (P0 > P1)
         if(pts[0] > pts[1]) 
         {
            double penetration = pts[0] - pts[1];
            // Linear scaling: 0.0 -> 0 pts, Threshold -> 50 pts
            double score = (penetration / threshold) * 50.0;
            if(score > 50.0) score = 50.0;
            return score; 
         }
         
         // 2. Breakout Down Check (P0 < P2) -> Continuation/Reversal
         // Note: P2 is Low
         if(pts[0] < pts[2])
         {
             // Check context: If P1 < P3 (Lower High) AND P0 < P2 (Lower Low) -> Strong Bear
             double base_score = -20.0;
             if(pts[1] < pts[3]) base_score = -40.0;
             
             // Add penetration bonus
             double penetration = pts[2] - pts[0];
             double bonus = (penetration / threshold) * 10.0; // Max +10 extra
             if(bonus > 10.0) bonus = 10.0;
             
             return base_score - bonus;
         }
      }
      else // Moving up from P1
      {
         // 1. Breakout Down Check (P0 < P1)
         if(pts[0] < pts[1])
         {
            double penetration = pts[1] - pts[0];
            double score = (penetration / threshold) * 50.0;
            if(score > 50.0) score = 50.0;
            return -score; // Negative for Bearish Breakout
         }
         
         // 2. Breakout Up Check (P0 > P2)
         // Note: P2 is High
         if(pts[0] > pts[2])
         {
            double base_score = 20.0;
            if(pts[1] > pts[3]) base_score = 40.0; // HL + HH
            
            double penetration = pts[0] - pts[2];
            double bonus = (penetration / threshold) * 10.0;
            if(bonus > 10.0) bonus = 10.0;
            
            return base_score + bonus;
         }
      }

      // --- NO BREAKOUT YET (Retracement / Consolidation) ---
      // We rely on historical structure, but weaker
      if(p1_is_high) // H(1)-L(2)-H(3)
        {
         bool HH = (pts[1] > pts[3]);
         bool HL = (pts[2] > pts[4]);
         if(HH && HL) return 30.0; // Reduced from 40 to allow dynamic to shine
         if(HH) return 15.0;
         return -5.0;
        }
      else // L(1)-H(2)-L(3)
        {
         bool LL = (pts[1] < pts[3]);
         bool LH = (pts[2] < pts[4]);
         if(LL && LH) return -30.0;
         if(LL) return -15.0;
         return 5.0;
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
      
      double E = displacement / total_path; 
      
      double relative_E = E * direction_sign; 
      
      double score = relative_E * 30.0; 
      if(score > 30.0) score = 30.0;
      if(score < -30.0) score = -30.0; 
      
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
