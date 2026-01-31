//+------------------------------------------------------------------+
//|                                                     GUIPanel.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "9.00" // 5 Inputs: Trend, Wicks(2), H1(2)

#include <ChartObjects/ChartObjectsTxtControls.mqh>
#include <ChartObjects/ChartObjectsShapes.mqh>
#include <Controls/Dialog.mqh> 

enum ENUM_STRENGTH {
    STR_NONE,
    STR_WEAK,
    STR_STRONG
};

enum ENUM_TREND_TYPE {
    TR_BEARISH,
    TR_SIDEWAYS,
    TR_BULLISH
};

class GUIPanel : public CObject
{
private:
    long      m_cid;
    int       m_win;
    int       m_x, m_y, m_w, m_h;
    
    // States
    ENUM_TREND_TYPE m_trend_val;
    ENUM_STRENGTH   m_w_up_val, m_w_lo_val;
    ENUM_STRENGTH   m_h1_bear_val, m_h1_bull_val;
    
    // UI Logic States
    bool m_open_trend;
    bool m_open_w_up, m_open_w_lo;
    bool m_open_h1_bear, m_open_h1_bull;
    bool m_is_minimized;
    bool m_dragging;
    int  m_drag_x, m_drag_y;

    // Objects
    CChartObjectRectLabel m_bg, m_hb;
    CChartObjectLabel     m_tl;
    CChartObjectButton    m_btn_min;
    
    // 1. Trend UI
    CChartObjectLabel     m_lbl_tr;
    CChartObjectButton    m_btn_tr_main;
    CChartObjectButton    m_btn_tr_bear, m_btn_tr_side, m_btn_tr_bull;

    // 2. Wicks UI (Left/Right)
    CChartObjectLabel     m_lbl_w;
    CChartObjectButton    m_btn_w_up_main, m_btn_w_lo_main;
    // Wick Options
    CChartObjectButton    m_opt_w_up_none, m_opt_w_up_str;
    CChartObjectButton    m_opt_w_lo_none, m_opt_w_lo_str;
    
    // 3. H1 UI (Left/Right)
    CChartObjectLabel     m_lbl_h1;
    CChartObjectButton    m_btn_h1_bear_main, m_btn_h1_bull_main;
    // H1 Options
    CChartObjectButton    m_opt_h1_be_none, m_opt_h1_be_wk, m_opt_h1_be_str;
    CChartObjectButton    m_opt_h1_bu_none, m_opt_h1_bu_wk, m_opt_h1_bu_str;

    void HideAll() {
        m_btn_tr_bear.X_Distance(-1000); m_btn_tr_side.X_Distance(-1000); m_btn_tr_bull.X_Distance(-1000);
        m_opt_w_up_none.X_Distance(-1000); m_opt_w_up_str.X_Distance(-1000);
        m_opt_w_lo_none.X_Distance(-1000); m_opt_w_lo_str.X_Distance(-1000);
        m_opt_h1_be_none.X_Distance(-1000); m_opt_h1_be_wk.X_Distance(-1000); m_opt_h1_be_str.X_Distance(-1000);
        m_opt_h1_bu_none.X_Distance(-1000); m_opt_h1_bu_wk.X_Distance(-1000); m_opt_h1_bu_str.X_Distance(-1000);
    }

    void UpdateLayout() {
        m_hb.X_Distance(m_x); m_hb.Y_Distance(m_y);
        m_tl.X_Distance(m_x+10); m_tl.Y_Distance(m_y+5);
        m_btn_min.X_Distance(m_x+m_w-25); m_btn_min.Y_Distance(m_y+2);
        m_btn_min.Description(m_is_minimized?"+":"-");
        
        HideAll();

        if(m_is_minimized) {
            m_bg.X_Distance(-1000);
            m_lbl_tr.X_Distance(-1000); m_btn_tr_main.X_Distance(-1000);
            m_lbl_w.X_Distance(-1000); m_btn_w_up_main.X_Distance(-1000); m_btn_w_lo_main.X_Distance(-1000);
            m_lbl_h1.X_Distance(-1000); m_btn_h1_bear_main.X_Distance(-1000); m_btn_h1_bull_main.X_Distance(-1000);
            return;
        }

        m_bg.X_Distance(m_x); m_bg.Y_Distance(m_y); m_bg.Y_Size(230);
        int bx = m_x + 10;
        int w_full = 200;
        int w_half = 95;
        
        // --- 1. TREND ---
        int y1 = m_y + 30;
        m_lbl_tr.X_Distance(bx); m_lbl_tr.Y_Distance(y1);
        m_btn_tr_main.X_Distance(bx); m_btn_tr_main.Y_Distance(y1+15);
        string t_txt = "SIDEWAYS";
        if(m_trend_val==TR_BEARISH) t_txt="BEARISH";
        if(m_trend_val==TR_BULLISH) t_txt="BULLISH";
        m_btn_tr_main.Description(t_txt + (m_open_trend?" [^]":" [v]"));

        // --- 2. WICKS ---
        int y2 = y1 + 50;
        if(!m_open_trend) {
            m_lbl_w.X_Distance(bx); m_lbl_w.Y_Distance(y2);
            // Upper (Red)
            m_btn_w_up_main.X_Distance(bx); m_btn_w_up_main.Y_Distance(y2+15);
            m_btn_w_up_main.Description("Up: "+(m_w_up_val==STR_STRONG?"STR":"NONE"));
            // Lower (Green)
            m_btn_w_lo_main.X_Distance(bx + w_half + 10); m_btn_w_lo_main.Y_Distance(y2+15);
            m_btn_w_lo_main.Description("Lo: "+(m_w_lo_val==STR_STRONG?"STR":"NONE"));
        } else {
             m_lbl_w.X_Distance(-1000); m_btn_w_up_main.X_Distance(-1000); m_btn_w_lo_main.X_Distance(-1000);
        }

        // --- 3. H1 BREAKOUTS ---
        int y3 = y2 + 50;
        if(!m_open_trend && !m_open_w_up && !m_open_w_lo) {
            m_lbl_h1.X_Distance(bx); m_lbl_h1.Y_Distance(y3);
            // Bear (Red)
            m_btn_h1_bear_main.X_Distance(bx); m_btn_h1_bear_main.Y_Distance(y3+15);
            string be_txt="NONE"; if(m_h1_bear_val==STR_WEAK) be_txt="WEAK"; if(m_h1_bear_val==STR_STRONG) be_txt="STR";
            m_btn_h1_bear_main.Description("Bear: "+be_txt);
            
            // Bull (Green)
            m_btn_h1_bull_main.X_Distance(bx + w_half + 10); m_btn_h1_bull_main.Y_Distance(y3+15);
            string bu_txt="NONE"; if(m_h1_bull_val==STR_WEAK) bu_txt="WEAK"; if(m_h1_bull_val==STR_STRONG) bu_txt="STR";
            m_btn_h1_bull_main.Description("Bull: "+bu_txt);
        } else {
            m_lbl_h1.X_Distance(-1000); m_btn_h1_bear_main.X_Distance(-1000); m_btn_h1_bull_main.X_Distance(-1000);
        }

        // --- OPEN MENUS ---
        // Trend
        if(m_open_trend) {
            int oy = m_btn_tr_main.Y_Distance() + 25;
            m_btn_tr_bear.X_Distance(bx); m_btn_tr_bear.Y_Distance(oy);
            m_btn_tr_side.X_Distance(bx); m_btn_tr_side.Y_Distance(oy+25);
            m_btn_tr_bull.X_Distance(bx); m_btn_tr_bull.Y_Distance(oy+50);
            m_bg.Y_Size(oy + 85 - m_y);
        }
        // Wick Up
        if(m_open_w_up) {
            int oy = m_btn_w_up_main.Y_Distance() + 25;
            m_opt_w_up_none.X_Distance(bx); m_opt_w_up_none.Y_Distance(oy);
            m_opt_w_up_str.X_Distance(bx);  m_opt_w_up_str.Y_Distance(oy+25);
            m_bg.Y_Size(oy + 60 - m_y);
        }
        // Wick Lo
        if(m_open_w_lo) {
            int ox = bx + w_half + 10;
            int oy = m_btn_w_lo_main.Y_Distance() + 25;
            m_opt_w_lo_none.X_Distance(ox); m_opt_w_lo_none.Y_Distance(oy);
            m_opt_w_lo_str.X_Distance(ox);  m_opt_w_lo_str.Y_Distance(oy+25);
            m_bg.Y_Size(oy + 60 - m_y);
        }
        // H1 Bear
        if(m_open_h1_bear) {
            int oy = m_btn_h1_bear_main.Y_Distance() + 25;
            m_opt_h1_be_none.X_Distance(bx); m_opt_h1_be_none.Y_Distance(oy);
            m_opt_h1_be_wk.X_Distance(bx);   m_opt_h1_be_wk.Y_Distance(oy+25);
            m_opt_h1_be_str.X_Distance(bx);  m_opt_h1_be_str.Y_Distance(oy+50);
            m_bg.Y_Size(oy + 85 - m_y);
        }
        // H1 Bull
        if(m_open_h1_bull) {
            int ox = bx + w_half + 10;
            int oy = m_btn_h1_bull_main.Y_Distance() + 25;
            m_opt_h1_bu_none.X_Distance(ox); m_opt_h1_bu_none.Y_Distance(oy);
            m_opt_h1_bu_wk.X_Distance(ox);   m_opt_h1_bu_wk.Y_Distance(oy+25);
            m_opt_h1_bu_str.X_Distance(ox);  m_opt_h1_bu_str.Y_Distance(oy+50);
            m_bg.Y_Size(oy + 85 - m_y);
        }
        ChartRedraw(m_cid);
    }
    
    void CloseAll() { m_open_trend=false; m_open_w_up=false; m_open_w_lo=false; m_open_h1_bear=false; m_open_h1_bull=false; }
    void Toggle(int idx) {
        bool was = false;
        if(idx==1) was=m_open_trend; if(idx==2) was=m_open_w_up; if(idx==3) was=m_open_w_lo;
        if(idx==4) was=m_open_h1_bear; if(idx==5) was=m_open_h1_bull;
        CloseAll();
        if(idx==1) m_open_trend=!was; if(idx==2) m_open_w_up=!was; if(idx==3) m_open_w_lo=!was;
        if(idx==4) m_open_h1_bear=!was; if(idx==5) m_open_h1_bull=!was;
        UpdateLayout();
    }

public:
    GUIPanel(long cid=0, int win=0) {
        m_cid=(cid==0)?ChartID():cid; m_win=win; m_x=20; m_y=50; m_w=220; m_h=230;
        m_trend_val=TR_SIDEWAYS; 
        m_w_up_val=STR_NONE; m_w_lo_val=STR_NONE; 
        m_h1_bear_val=STR_NONE; m_h1_bull_val=STR_NONE;
    }
    ~GUIPanel() { Destroy(); }
    void Destroy() { 
        m_bg.Delete(); m_hb.Delete(); m_tl.Delete(); m_btn_min.Delete();
        m_lbl_tr.Delete(); m_btn_tr_main.Delete(); m_btn_tr_bear.Delete(); m_btn_tr_side.Delete(); m_btn_tr_bull.Delete();
        m_lbl_w.Delete(); m_btn_w_up_main.Delete(); m_btn_w_lo_main.Delete(); 
        m_opt_w_up_none.Delete(); m_opt_w_up_str.Delete(); m_opt_w_lo_none.Delete(); m_opt_w_lo_str.Delete();
        m_lbl_h1.Delete(); m_btn_h1_bear_main.Delete(); m_btn_h1_bull_main.Delete();
        m_opt_h1_be_none.Delete(); m_opt_h1_be_wk.Delete(); m_opt_h1_be_str.Delete();
        m_opt_h1_bu_none.Delete(); m_opt_h1_bu_wk.Delete(); m_opt_h1_bu_str.Delete();
    }
    
    void Create(int x, int y) {
        m_x=x; m_y=y;
        m_bg.Create(m_cid,"GB",m_win,x,y,m_w,m_h); m_bg.BackColor(clrWhiteSmoke);
        m_hb.Create(m_cid,"GH",m_win,x,y,m_w,25); m_hb.BackColor(clrLightSteelBlue);
        m_tl.Create(m_cid,"GT",m_win,x+10,y+5); m_tl.Description("Fuzzy Controller v9"); m_tl.Color(clrBlack);
        m_btn_min.Create(m_cid,"GM",m_win,x+m_w-25,y+2,20,20); m_btn_min.BackColor(clrLightGreen); m_btn_min.Color(clrBlack);
        
        // Trend
        m_lbl_tr.Create(m_cid,"L_TR",m_win,0,0); m_lbl_tr.Description("Market Context:"); m_lbl_tr.Color(clrBlack);
        m_btn_tr_main.Create(m_cid,"B_TR_M",m_win,0,0,200,25); m_btn_tr_main.BackColor(clrWheat); m_btn_tr_main.Color(clrBlack);
        m_btn_tr_bear.Create(m_cid,"B_TR_1",m_win,-1000,0,200,25); m_btn_tr_bear.Description("BEARISH");
        m_btn_tr_side.Create(m_cid,"B_TR_2",m_win,-1000,0,200,25); m_btn_tr_side.Description("SIDEWAYS");
        m_btn_tr_bull.Create(m_cid,"B_TR_3",m_win,-1000,0,200,25); m_btn_tr_bull.Description("BULLISH");
        
        // Wicks
        m_lbl_w.Create(m_cid,"L_W",m_win,0,0); m_lbl_w.Description("Daily Wicks (Up/Lo):"); m_lbl_w.Color(clrBlack);
        m_btn_w_up_main.Create(m_cid,"B_WU_M",m_win,0,0,95,25); m_btn_w_up_main.BackColor(clrLightPink); m_btn_w_up_main.Color(clrBlack);
        m_btn_w_lo_main.Create(m_cid,"B_WL_M",m_win,0,0,95,25); m_btn_w_lo_main.BackColor(clrLightGreen); m_btn_w_lo_main.Color(clrBlack);
        
        m_opt_w_up_none.Create(m_cid,"O_WU_0",m_win,-1000,0,95,25); m_opt_w_up_none.Description("NONE");
        m_opt_w_up_str.Create(m_cid,"O_WU_1",m_win,-1000,0,95,25); m_opt_w_up_str.Description("STRONG");
        m_opt_w_lo_none.Create(m_cid,"O_WL_0",m_win,-1000,0,95,25); m_opt_w_lo_none.Description("NONE");
        m_opt_w_lo_str.Create(m_cid,"O_WL_1",m_win,-1000,0,95,25); m_opt_w_lo_str.Description("STRONG");

        // H1
        m_lbl_h1.Create(m_cid,"L_H1",m_win,0,0); m_lbl_h1.Description("H1 Break (Bear/Bull):"); m_lbl_h1.Color(clrBlack);
        m_btn_h1_bear_main.Create(m_cid,"B_HB_M",m_win,0,0,95,25); m_btn_h1_bear_main.BackColor(clrLightPink); m_btn_h1_bear_main.Color(clrBlack);
        m_btn_h1_bull_main.Create(m_cid,"B_HU_M",m_win,0,0,95,25); m_btn_h1_bull_main.BackColor(clrLightGreen); m_btn_h1_bull_main.Color(clrBlack);
        
        m_opt_h1_be_none.Create(m_cid,"O_HB_0",m_win,-1000,0,95,25); m_opt_h1_be_none.Description("NONE");
        m_opt_h1_be_wk.Create(m_cid,"O_HB_1",m_win,-1000,0,95,25); m_opt_h1_be_wk.Description("WEAK");
        m_opt_h1_be_str.Create(m_cid,"O_HB_2",m_win,-1000,0,95,25); m_opt_h1_be_str.Description("STRONG");
        
        m_opt_h1_bu_none.Create(m_cid,"O_HU_0",m_win,-1000,0,95,25); m_opt_h1_bu_none.Description("NONE");
        m_opt_h1_bu_wk.Create(m_cid,"O_HU_1",m_win,-1000,0,95,25); m_opt_h1_bu_wk.Description("WEAK");
        m_opt_h1_bu_str.Create(m_cid,"O_HU_2",m_win,-1000,0,95,25); m_opt_h1_bu_str.Description("STRONG");

        UpdateLayout();
    }
    
    bool OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
         if(id == CHARTEVENT_MOUSE_MOVE) {
            int mx = (int)lparam; int my = (int)dparam; int st = (int)StringToInteger(sparam);
            if(st==1) {
                if(!m_dragging) {
                    if(mx >= m_x && mx <= m_x+m_w && my >= m_y && my <= m_y+25) { m_dragging = true; m_drag_x = mx - m_x; m_drag_y = my - m_y; ChartSetInteger(m_cid, CHART_MOUSE_SCROLL, false); }
                } else { m_x = mx - m_drag_x; m_y = my - m_drag_y; if(m_x<0) m_x=0; if(m_y<0) m_y=0; UpdateLayout(); }
            } else if(m_dragging) { m_dragging = false; ChartSetInteger(m_cid, CHART_MOUSE_SCROLL, true); }
            return false;
        }
        
        if(id == CHARTEVENT_OBJECT_CLICK) {
            string o = sparam;
            if(o=="GM") { m_is_minimized=!m_is_minimized; if(m_is_minimized) CloseAll(); UpdateLayout(); return true; }
            if(m_is_minimized) return false;
            
            // Toggle Main Buttons
            if(o=="B_TR_M") { Toggle(1); return false; }
            if(o=="B_WU_M") { Toggle(2); return false; }
            if(o=="B_WL_M") { Toggle(3); return false; }
            if(o=="B_HB_M") { Toggle(4); return false; }
            if(o=="B_HU_M") { Toggle(5); return false; }
            
            // Trend Options
            if(o=="B_TR_1") { m_trend_val=TR_BEARISH; CloseAll(); UpdateLayout(); return true; }
            if(o=="B_TR_2") { m_trend_val=TR_SIDEWAYS; CloseAll(); UpdateLayout(); return true; }
            if(o=="B_TR_3") { m_trend_val=TR_BULLISH; CloseAll(); UpdateLayout(); return true; }
            
            // Wick Options
            if(o=="O_WU_0") { m_w_up_val=STR_NONE; CloseAll(); UpdateLayout(); return true; }
            if(o=="O_WU_1") { m_w_up_val=STR_STRONG; CloseAll(); UpdateLayout(); return true; }
            if(o=="O_WL_0") { m_w_lo_val=STR_NONE; CloseAll(); UpdateLayout(); return true; }
            if(o=="O_WL_1") { m_w_lo_val=STR_STRONG; CloseAll(); UpdateLayout(); return true; }

            // H1 Options
            if(o=="O_HB_0") { m_h1_bear_val=STR_NONE; CloseAll(); UpdateLayout(); return true; }
            if(o=="O_HB_1") { m_h1_bear_val=STR_WEAK; CloseAll(); UpdateLayout(); return true; }
            if(o=="O_HB_2") { m_h1_bear_val=STR_STRONG; CloseAll(); UpdateLayout(); return true; }
            if(o=="O_HU_0") { m_h1_bull_val=STR_NONE; CloseAll(); UpdateLayout(); return true; }
            if(o=="O_HU_1") { m_h1_bull_val=STR_WEAK; CloseAll(); UpdateLayout(); return true; }
            if(o=="O_HU_2") { m_h1_bull_val=STR_STRONG; CloseAll(); UpdateLayout(); return true; }
            
            CloseAll(); UpdateLayout();
        }
        return false;
    }
    
    ENUM_TREND_TYPE getTrend() const { return m_trend_val; }
    ENUM_STRENGTH getWickUp() const { return m_w_up_val; }
    ENUM_STRENGTH getWickLo() const { return m_w_lo_val; }
    ENUM_STRENGTH getH1Bear() const { return m_h1_bear_val; }
    ENUM_STRENGTH getH1Bull() const { return m_h1_bull_val; }
};