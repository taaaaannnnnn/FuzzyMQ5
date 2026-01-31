import tkinter as tk
from tkinter import ttk
import numpy as np
from matplotlib.figure import Figure 
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import skfuzzy as fuzz
from skfuzzy import control as ctrl

# ==========================================
# 1. FUZZY SYSTEM SETUP (Matches MQL5 v0.99 Beta - No C3)
# ==========================================

def create_fuzzy_system():
    # 1. Inputs
    trend = ctrl.Antecedent(np.arange(0, 101, 1), 'trend')
    wick_up = ctrl.Antecedent(np.arange(0, 101, 1), 'wick_up')
    wick_lo = ctrl.Antecedent(np.arange(0, 101, 1), 'wick_lo')
    h1_bear = ctrl.Antecedent(np.arange(0, 101, 1), 'h1_bear')
    h1_bull = ctrl.Antecedent(np.arange(0, 101, 1), 'h1_bull')

    # 2. Output
    reversal = ctrl.Consequent(np.arange(-100, 101, 1), 'reversal')

    # 3. MFs (Membership Functions)
    trend['BEARISH']  = fuzz.trapmf(trend.universe, [0, 0, 30, 40])
    trend['SIDEWAYS'] = fuzz.trapmf(trend.universe, [40, 50, 50, 60])
    trend['BULLISH']  = fuzz.trapmf(trend.universe, [60, 70, 100, 100])

    for v in [wick_up, wick_lo, h1_bear, h1_bull]:
        v['NONE']   = fuzz.trapmf(v.universe, [0, 0, 20, 30])
        v['WEAK']   = fuzz.trapmf(v.universe, [30, 40, 60, 70])
        v['STRONG'] = fuzz.trapmf(v.universe, [70, 80, 100, 100])

    reversal['CLEARLY_DOWN']  = fuzz.trapmf(reversal.universe, [-100, -100, -85, -75])
    reversal['MODERATE_DOWN'] = fuzz.trapmf(reversal.universe, [-75, -65, -55, -45])
    reversal['WEAK_DOWN']     = fuzz.trapmf(reversal.universe, [-50, -40, -40, -30])
    reversal['STARTING_DOWN'] = fuzz.trapmf(reversal.universe, [-30, -20, -20, -10])
    reversal['NOT_FORMED']    = fuzz.trapmf(reversal.universe, [-10, 0, 0, 10])
    reversal['STARTING_UP']   = fuzz.trapmf(reversal.universe, [10, 20, 20, 30])
    reversal['WEAK_UP']       = fuzz.trapmf(reversal.universe, [30, 40, 40, 50])
    reversal['MODERATE_UP']   = fuzz.trapmf(reversal.universe, [45, 55, 65, 75])
    reversal['CLEARLY_UP']    = fuzz.trapmf(reversal.universe, [75, 85, 100, 100])

    # 4. Rules
    rules = []

    # --- SIDEWAYS (Target 70) ---
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_up['STRONG'] & h1_bear['STRONG'], reversal['MODERATE_DOWN'])) # S1
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_up['STRONG'] & h1_bear['WEAK'],   reversal['WEAK_DOWN']))     # S2
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_up['NONE'] & wick_lo['NONE'] & h1_bear['STRONG'], reversal['STARTING_DOWN'])) # S3
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_up['STRONG'] & h1_bear['NONE'] & h1_bull['NONE'], reversal['STARTING_DOWN'])) # S4

    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_lo['STRONG'] & h1_bull['STRONG'], reversal['MODERATE_UP']))   # B1
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_lo['STRONG'] & h1_bull['WEAK'],   reversal['WEAK_UP']))       # B2
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_lo['NONE'] & wick_up['NONE'] & h1_bull['STRONG'], reversal['STARTING_UP']))   # B3
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_lo['STRONG'] & h1_bull['NONE'] & h1_bear['NONE'], reversal['STARTING_UP']))   # B4

    # Conflict Sideways (+/- 15)
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_up['STRONG'] & h1_bull['STRONG'], reversal['WEAK_UP'])) 
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_lo['STRONG'] & h1_bear['STRONG'], reversal['WEAK_DOWN']))

    # --- UPTREND (Target 95) ---
    rules.append(ctrl.Rule(trend['BULLISH'] & wick_lo['STRONG'] & h1_bull['STRONG'], reversal['CLEARLY_UP']))  # U1
    rules.append(ctrl.Rule(trend['BULLISH'] & wick_lo['STRONG'] & h1_bull['WEAK'],   reversal['MODERATE_UP'])) # U2
    rules.append(ctrl.Rule(trend['BULLISH'] & wick_lo['NONE']   & h1_bull['STRONG'], reversal['MODERATE_UP'])) # U3

    # Friction (-15) & Momentum Drag (-20)
    rules.append(ctrl.Rule(trend['BULLISH'] & wick_up['STRONG'], reversal['STARTING_DOWN']))     # U_DRAG (-15)
    rules.append(ctrl.Rule(trend['BULLISH'] & h1_bear['STRONG'], reversal['STARTING_DOWN'])) # U_MOM_DRAG (-20)
    
    # Counter (-25) 
    rules.append(ctrl.Rule(trend['BULLISH'] & wick_up['STRONG'] & h1_bear['STRONG'], reversal['STARTING_DOWN'])) # U_C1 (-25)
    rules.append(ctrl.Rule(trend['BULLISH'] & wick_up['STRONG'] & h1_bear['WEAK'],   reversal['STARTING_DOWN'])) # U_C2
    # U_C3 REMOVED

    # --- DOWNTREND (Target -95) ---
    rules.append(ctrl.Rule(trend['BEARISH'] & wick_up['STRONG'] & h1_bear['STRONG'], reversal['CLEARLY_DOWN'])) # D1
    rules.append(ctrl.Rule(trend['BEARISH'] & wick_up['STRONG'] & h1_bear['WEAK'],   reversal['MODERATE_DOWN'])) # D2
    rules.append(ctrl.Rule(trend['BEARISH'] & wick_up['NONE']   & h1_bear['STRONG'], reversal['MODERATE_DOWN'])) # D3

    # Friction (+15) & Momentum Drag (+20)
    rules.append(ctrl.Rule(trend['BEARISH'] & wick_lo['STRONG'], reversal['STARTING_UP']))       # D_DRAG (+15)
    rules.append(ctrl.Rule(trend['BEARISH'] & h1_bull['STRONG'], reversal['STARTING_UP']))   # D_MOM_DRAG (+20)
    
    # Counter (+25)
    rules.append(ctrl.Rule(trend['BEARISH'] & wick_lo['STRONG'] & h1_bull['STRONG'], reversal['STARTING_UP'])) # D_C1
    rules.append(ctrl.Rule(trend['BEARISH'] & wick_lo['STRONG'] & h1_bull['WEAK'],   reversal['STARTING_UP'])) # D_C2
    # D_C3 REMOVED

    # Build
    reversal_ctrl = ctrl.ControlSystem(rules)
    simulation = ctrl.ControlSystemSimulation(reversal_ctrl)
    
    return simulation, reversal

# ==========================================
# 2. GUI APP
# ==========================================

class FuzzyApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Fuzzy Logic Digital Twin (v0.99 Beta - No C3)")
        self.root.geometry("1200x800")
        
        self.simulation, self.reversal_consequent = create_fuzzy_system()
        
        self.val_map = {"NONE": 10, "WEAK": 50, "STRONG": 90, "SIDEWAYS": 50, "BEARISH": 20, "BULLISH": 80}
        
        self.var_trend = tk.StringVar(value="SIDEWAYS")
        self.var_w_up  = tk.StringVar(value="NONE")
        self.var_w_lo  = tk.StringVar(value="NONE")
        self.var_be    = tk.StringVar(value="NONE")
        self.var_bu    = tk.StringVar(value="NONE")
        
        self.setup_ui()
        self.update_chart()

    def setup_ui(self):
        # Left Panel (Controls)
        left = ttk.Frame(self.root, padding=20, width=300)
        left.pack(side=tk.LEFT, fill=tk.Y)
        
        ttk.Label(left, text="Inputs", font=("Arial", 16, "bold")).pack(pady=10)
        
        self.create_combo(left, "Trend", self.var_trend, ["BEARISH", "SIDEWAYS", "BULLISH"])
        ttk.Separator(left).pack(fill='x', pady=10)
        
        ttk.Label(left, text="Daily Wicks", font=("Arial", 10, "bold")).pack(anchor="w")
        self.create_combo(left, "Upper (Sell)", self.var_w_up, ["NONE", "STRONG"], "red")
        self.create_combo(left, "Lower (Buy)",  self.var_w_lo, ["NONE", "STRONG"], "green")
        ttk.Separator(left).pack(fill='x', pady=10)
        
        ttk.Label(left, text="H1 Breakout", font=("Arial", 10, "bold")).pack(anchor="w")
        self.create_combo(left, "Bear (Sell)", self.var_be, ["NONE", "WEAK", "STRONG"], "red")
        self.create_combo(left, "Bull (Buy)",  self.var_bu, ["NONE", "WEAK", "STRONG"], "green")
        
        # Result Panel
        res = ttk.LabelFrame(left, text="Result", padding=20)
        res.pack(fill='x', pady=20)
        self.lbl_score = ttk.Label(res, text="0.0", font=("Consolas", 30, "bold"))
        self.lbl_score.pack()
        self.lbl_msg = ttk.Label(res, text="NEUTRAL", font=("Arial", 12))
        self.lbl_msg.pack()
        
        # LOG BUTTON
        btn_log = tk.Button(left, text="LOG CASE", font=("Arial", 12, "bold"), bg="#ddd", command=self.log_case)
        btn_log.pack(fill='x', pady=20)
        
        # Right Panel (Chart)
        right = ttk.Frame(self.root)
        right.pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)
        
        self.fig = Figure(figsize=(8,6), dpi=100)
        self.ax = self.fig.add_subplot(111)
        self.canvas = FigureCanvasTkAgg(self.fig, master=right)
        self.canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)

    def create_combo(self, parent, label, var, values, color="black"):
        f = ttk.Frame(parent)
        f.pack(fill='x', pady=5)
        ttk.Label(f, text=label, foreground=color).pack(anchor="w")
        cb = ttk.Combobox(f, textvariable=var, values=values, state="readonly")
        cb.pack(fill='x')
        cb.bind("<<ComboboxSelected>>", lambda e: self.update_chart())

    def update_chart(self):
        try:
            self.simulation.input['trend'] = self.val_map[self.var_trend.get()]
            self.simulation.input['wick_up'] = self.val_map[self.var_w_up.get()]
            self.simulation.input['wick_lo'] = self.val_map[self.var_w_lo.get()]
            self.simulation.input['h1_bear'] = self.val_map[self.var_be.get()]
            self.simulation.input['h1_bull'] = self.val_map[self.var_bu.get()]
            
            self.simulation.compute()
            score = self.simulation.output['reversal']
        except:
            score = 0.0
            
        self.lbl_score.config(text=f"{score:.1f}")
        msg = "NEUTRAL"
        if score > 60: msg = "STRONG BUY"
        elif score > 20: msg = "WEAK BUY"
        elif score < -60: msg = "STRONG SELL"
        elif score < -20: msg = "WEAK SELL"
        self.lbl_msg.config(text=msg)
        
        self.ax.clear()
        universe = self.reversal_consequent.universe
        for label, term in self.reversal_consequent.terms.items():
            self.ax.plot(universe, term.mf, label=label, alpha=0.3)
        self.ax.axvline(x=score, color='r', linestyle='--', linewidth=2)
        self.ax.set_title(f"Score: {score:.1f} ({msg})")
        self.ax.legend(loc='upper right', fontsize='small')
        self.canvas.draw()

    def log_case(self):
        print(f"[LOG] Inputs: T={self.var_trend.get()} | W_UP={self.var_w_up.get()} | W_LO={self.var_w_lo.get()} | H1_BE={self.var_be.get()} | H1_BU={self.var_bu.get()} || Output: {self.lbl_score.cget('text')}")

if __name__ == "__main__":
    root = tk.Tk()
    app = FuzzyApp(root)
    root.mainloop()