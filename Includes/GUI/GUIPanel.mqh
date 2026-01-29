//+------------------------------------------------------------------+
//|                                                     GUIPanel.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "7.50" // Overlay Occlusion Mode

#include <ChartObjects/ChartObjectsTxtControls.mqh>
#include <ChartObjects/ChartObjectsShapes.mqh>
#include <Controls/Dialog.mqh> 

enum ENUM_H1_BREAKOUT_STRENGTH {
    H1_BREAKOUT_NONE,
    H1_BREAKOUT_WEAK,
    H1_BREAKOUT_STRONG
};

enum ENUM_DAILY_REJECTION {
    DAILY_REJECTION_NO,
    DAILY_REJECTION_YES
};

class GUIPanel : public CObject
{
private:
    long      m_cid;
    int       m_win;
    int       m_x, m_y, m_w, m_h;
    
    // States
    ENUM_DAILY_REJECTION      m_rej_val;
    ENUM_H1_BREAKOUT_STRENGTH m_h1_val;
    bool      m_is_rej_open;
    bool      m_is_h1_open;
    bool      m_is_minimized;
    
    bool      m_dragging;
    int       m_drag_x_off, m_drag_y_off;

    CChartObjectRectLabel m_bg;
    CChartObjectRectLabel m_hb;
    CChartObjectLabel     m_tl;
    CChartObjectButton    m_btn_min;
    
    CChartObjectLabel     m_lbl_rej;
    CChartObjectButton    m_rej_main;
    CChartObjectButton    m_rej_opt_no;
    CChartObjectButton    m_rej_opt_yes;
    
    CChartObjectLabel     m_lbl_h1;
    CChartObjectButton    m_h1_main;
    CChartObjectButton    m_h1_opt_none;
    CChartObjectButton    m_h1_opt_weak;
    CChartObjectButton    m_h1_opt_strong;

    void UpdateLayout() {
        // --- HEADER ---
        m_hb.X_Distance(m_x); m_hb.Y_Distance(m_y);
        m_tl.X_Distance(m_x+10); m_tl.Y_Distance(m_y+5);
        m_btn_min.X_Distance(m_x + m_w - 25); m_btn_min.Y_Distance(m_y + 2);
        m_btn_min.Description(m_is_minimized ? "+" : "-");
        
        // Reset ALL floating items to hidden first
        m_rej_opt_no.X_Distance(-1000); m_rej_opt_yes.X_Distance(-1000);
        m_h1_opt_none.X_Distance(-1000); m_h1_opt_weak.X_Distance(-1000); m_h1_opt_strong.X_Distance(-1000);

        if (m_is_minimized) {
            m_bg.X_Distance(-1000);
            m_lbl_rej.X_Distance(-1000); m_rej_main.X_Distance(-1000);
            m_lbl_h1.X_Distance(-1000); m_h1_main.X_Distance(-1000);
        } else {
            // FIXED Background Size (No accordion)
            m_bg.X_Distance(m_x); m_bg.Y_Distance(m_y); m_bg.Y_Size(160); // Fixed height
            
            // --- 1. REJECTION MAIN ---
            int rej_y = m_y + 35;
            m_lbl_rej.X_Distance(m_x+15); m_lbl_rej.Y_Distance(rej_y);
            m_rej_main.X_Distance(m_x+15); m_rej_main.Y_Distance(rej_y + 18);
            m_rej_main.Description((m_rej_val==DAILY_REJECTION_YES?"YES":"NO") + (m_is_rej_open?"  [ ^ ]":"  [ v ]"));

            // --- 2. H1 MAIN (Default Position) ---
            int h1_y = m_y + 90;
            // Only show H1 controls if Rejection dropdown is CLOSED
            // This prevents "bleeding" and collision.
            if(!m_is_rej_open) {
                m_lbl_h1.X_Distance(m_x+15); m_lbl_h1.Y_Distance(h1_y);
                m_h1_main.X_Distance(m_x+15); m_h1_main.Y_Distance(h1_y + 18);
                
                string h1t = "NONE";
                if(m_h1_val == H1_BREAKOUT_WEAK) h1t = "WEAK";
                if(m_h1_val == H1_BREAKOUT_STRONG) h1t = "STRONG";
                m_h1_main.Description(h1t + (m_is_h1_open?"  [ ^ ]":"  [ v ]"));
            } else {
                // Hide H1 controls when Rejection is open to allow overlay
                m_lbl_h1.X_Distance(-1000);
                m_h1_main.X_Distance(-1000);
            }

            // --- 3. RENDER DROPDOWN OPTIONS (ON TOP) ---
            
            // Rejection Options
            if(m_is_rej_open) {
                int ox = m_x + 15; int oy = m_rej_main.Y_Distance() + 25;
                m_rej_opt_no.X_Distance(ox);  m_rej_opt_no.Y_Distance(oy);
                m_rej_opt_yes.X_Distance(ox); m_rej_opt_yes.Y_Distance(oy + 25);
                
                m_rej_opt_no.BackColor(m_rej_val==DAILY_REJECTION_NO?clrLimeGreen:clrLightGreen);
                m_rej_opt_yes.BackColor(m_rej_val==DAILY_REJECTION_YES?clrLimeGreen:clrLightGreen);
                
                // Increase BG height temporarily if needed (optional)
                m_bg.Y_Size(oy + 50 + 10 - m_y); 
            }
            
            // H1 Options
            if(m_is_h1_open && !m_is_rej_open) {
                int ox = m_x + 15; int oy = m_h1_main.Y_Distance() + 25;
                m_h1_opt_none.X_Distance(ox);   m_h1_opt_none.Y_Distance(oy);
                m_h1_opt_weak.X_Distance(ox);   m_h1_opt_weak.Y_Distance(oy + 25);
                m_h1_opt_strong.X_Distance(ox); m_h1_opt_strong.Y_Distance(oy + 50);
                
                m_h1_opt_none.BackColor(m_h1_val==H1_BREAKOUT_NONE?clrLimeGreen:clrLightGreen);
                m_h1_opt_weak.BackColor(m_h1_val==H1_BREAKOUT_WEAK?clrLimeGreen:clrLightGreen);
                m_h1_opt_strong.BackColor(m_h1_val==H1_BREAKOUT_STRONG?clrLimeGreen:clrLightGreen);
                
                // Increase BG height
                m_bg.Y_Size(oy + 75 + 10 - m_y);
            }
        }
        ChartRedraw(m_cid);
    }

public:
    GUIPanel(long cid=0, int win=0) {
        m_cid=(cid==0)?ChartID():cid; m_win=win;
        m_x=20; m_y=50; m_w=220; m_h=160;
        m_rej_val=DAILY_REJECTION_NO; m_h1_val=H1_BREAKOUT_NONE;
        m_is_minimized=false; m_is_rej_open=false; m_is_h1_open=false; m_dragging=false;
    }
    
    ~GUIPanel() { 
        ChartSetInteger(m_cid, CHART_MOUSE_SCROLL, true);
        Destroy(); 
    }

    void Create(int x, int y) {
        m_x=x; m_y=y;
        ChartSetInteger(m_cid, CHART_EVENT_MOUSE_MOVE, true);
        
        m_bg.Create(m_cid, "F_BG", m_win, x, y, m_w, m_h); m_bg.BackColor(clrWhiteSmoke); m_bg.Z_Order(0);
        m_hb.Create(m_cid, "F_HB", m_win, x, y, m_w, 25); m_hb.BackColor(clrLightSteelBlue); m_hb.Z_Order(1);
        m_tl.Create(m_cid, "F_TL", m_win, x+10, y+5); m_tl.Description("Fuzzy Controller"); m_tl.Color(clrBlack); m_tl.FontSize(9); m_tl.Font("Arial Bold"); m_tl.Z_Order(2);
        m_btn_min.Create(m_cid, "F_MIN", m_win, x+m_w-25, y+2, 20, 20); m_btn_min.BackColor(clrLightGreen); m_btn_min.Color(clrBlack); m_btn_min.Z_Order(2);
        
        m_lbl_rej.Create(m_cid, "F_L0", m_win, 0, 0); m_lbl_rej.Description("Daily Rejection:"); m_lbl_rej.Color(clrBlack); m_lbl_rej.FontSize(8); m_lbl_rej.Z_Order(2);
        m_rej_main.Create(m_cid, "F_RE_M", m_win, 0, 0, 190, 25); m_rej_main.BackColor(clrLightGreen); m_rej_main.Color(clrBlack); m_rej_main.Z_Order(2);
        m_rej_opt_no.Create(m_cid, "F_RE_0", m_win, -1000, 0, 190, 25); m_rej_opt_no.Description("NO"); m_rej_opt_no.Color(clrBlack); m_rej_opt_no.Z_Order(100);
        m_rej_opt_yes.Create(m_cid, "F_RE_1", m_win, -1000, 0, 190, 25); m_rej_opt_yes.Description("YES"); m_rej_opt_yes.Color(clrBlack); m_rej_opt_yes.Z_Order(100);

        m_lbl_h1.Create(m_cid, "F_L1", m_win, 0, 0); m_lbl_h1.Description("H1 Breakout Strength:"); m_lbl_h1.Color(clrBlack); m_lbl_h1.FontSize(8); m_lbl_h1.Z_Order(2);
        m_h1_main.Create(m_cid, "F_H1_M", m_win, 0, 0, 190, 25); m_h1_main.BackColor(clrLightGreen); m_h1_main.Color(clrBlack); m_h1_main.Z_Order(2);
        m_h1_opt_none.Create(m_cid, "F_H1_0", m_win, -1000, 0, 190, 25); m_h1_opt_none.Description("NONE"); m_h1_opt_none.Color(clrBlack); m_h1_opt_none.Z_Order(100);
        m_h1_opt_weak.Create(m_cid, "F_H1_1", m_win, -1000, 0, 190, 25); m_h1_opt_weak.Description("WEAK"); m_h1_opt_weak.Color(clrBlack); m_h1_opt_weak.Z_Order(100);
        m_h1_opt_strong.Create(m_cid, "F_H1_2", m_win, -1000, 0, 190, 25); m_h1_opt_strong.Description("STRONG"); m_h1_opt_strong.Color(clrBlack); m_h1_opt_strong.Z_Order(100);
        
        UpdateLayout();
    }

    void Destroy() {
        m_bg.Delete(); m_hb.Delete(); m_tl.Delete(); m_btn_min.Delete();
        m_lbl_rej.Delete(); m_rej_main.Delete(); m_rej_opt_no.Delete(); m_rej_opt_yes.Delete();
        m_lbl_h1.Delete(); m_h1_main.Delete(); m_h1_opt_none.Delete(); m_h1_opt_weak.Delete(); m_h1_opt_strong.Delete();
    }

    bool OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
        if(id == CHARTEVENT_MOUSE_MOVE) {
            int mx = (int)lparam; int my = (int)dparam; int st = (int)StringToInteger(sparam);
            if(st==1) {
                if(!m_dragging) {
                    if(mx >= m_x && mx <= m_x+m_w && my >= m_y && my <= m_y+25) {
                        m_dragging = true; m_drag_x_off = mx - m_x; m_drag_y_off = my - m_y;
                        ChartSetInteger(m_cid, CHART_MOUSE_SCROLL, false);
                    }
                } else {
                    m_x = mx - m_drag_x_off; m_y = my - m_drag_y_off;
                    if(m_x<0) m_x=0; if(m_y<0) m_y=0;
                    UpdateLayout();
                }
            } else if(m_dragging) { m_dragging = false; ChartSetInteger(m_cid, CHART_MOUSE_SCROLL, true); }
            return false;
        }

        if(id == CHARTEVENT_OBJECT_CLICK) {
            string o = sparam;
            if(o == "F_MIN") { m_is_minimized = !m_is_minimized; if(m_is_minimized) { m_is_rej_open=false; m_is_h1_open=false; } UpdateLayout(); return true; }
            if(m_is_minimized) return false;

            // Rejection Logic
            if(o == "F_RE_M") { m_is_rej_open = !m_is_rej_open; m_is_h1_open = false; UpdateLayout(); return false; }
            if(o == "F_RE_0") { m_rej_val = DAILY_REJECTION_NO; m_is_rej_open = false; UpdateLayout(); return true; }
            if(o == "F_RE_1") { m_rej_val = DAILY_REJECTION_YES; m_is_rej_open = false; UpdateLayout(); return true; }

            // H1 Logic
            if(o == "F_H1_M") { m_is_h1_open = !m_is_h1_open; m_is_rej_open = false; UpdateLayout(); return false; }
            if(o == "F_H1_0") { m_h1_val = H1_BREAKOUT_NONE; m_is_h1_open = false; UpdateLayout(); return true; }
            if(o == "F_H1_1") { m_h1_val = H1_BREAKOUT_WEAK; m_is_h1_open = false; UpdateLayout(); return true; }
            if(o == "F_H1_2") { m_h1_val = H1_BREAKOUT_STRONG; m_is_h1_open = false; UpdateLayout(); return true; }
            
            if(m_is_rej_open || m_is_h1_open) { m_is_rej_open = false; m_is_h1_open = false; UpdateLayout(); }
        }
        return false;
    }

    bool getDailyRejectionDetected() const { return (m_rej_val == DAILY_REJECTION_YES); }
    ENUM_H1_BREAKOUT_STRENGTH getH1BreakoutStrength() const { return m_h1_val; }
};