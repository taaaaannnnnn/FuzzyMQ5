import tkinter as tk
from tkinter import ttk
import numpy as np
# Remove pyplot to avoid global state conflicts
# import matplotlib.pyplot as plt 
from matplotlib.figure import Figure 
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import skfuzzy as fuzz
from skfuzzy import control as ctrl

# ==========================================
# 1. FUZZY SYSTEM SETUP (scikit-fuzzy)
# ==========================================

def create_fuzzy_system():
    # --- Inputs ---
    # trend = ctrl.Antecedent(np.arange(0, 101, 1), 'trend') # Removed to align with MQL5
    wick_upper = ctrl.Antecedent(np.arange(0, 101, 1), 'wick_upper')
    wick_lower = ctrl.Antecedent(np.arange(0, 101, 1), 'wick_lower')
    break_up   = ctrl.Antecedent(np.arange(0, 101, 1), 'break_up')
    break_down = ctrl.Antecedent(np.arange(0, 101, 1), 'break_down')

    # --- Output ---
    reversal = ctrl.Consequent(np.arange(-100, 101, 1), 'reversal')

    # --- Membership Functions ---
    # trend['SIDEWAYS'] = fuzz.trapmf(trend.universe, [40, 50, 50, 60])

    for comp in [wick_upper, wick_lower, break_up, break_down]:
        comp['NONE']   = fuzz.trapmf(comp.universe, [0, 0, 20, 30])
        comp['WEAK']   = fuzz.trapmf(comp.universe, [30, 40, 60, 70])
        comp['STRONG'] = fuzz.trapmf(comp.universe, [70, 80, 100, 100])

    reversal['CLEARLY_DOWN']  = fuzz.trapmf(reversal.universe, [-100, -100, -85, -75])
    reversal['MODERATE_DOWN'] = fuzz.trapmf(reversal.universe, [-80, -70, -70, -60])
    reversal['WEAK_DOWN']     = fuzz.trapmf(reversal.universe, [-60, -50, -50, -40])
    reversal['STARTING_DOWN'] = fuzz.trapmf(reversal.universe, [-45, -35, -35, -25])
    reversal['NOT_FORMED']    = fuzz.trapmf(reversal.universe, [-25, -5, 5, 25])
    reversal['STARTING_UP']   = fuzz.trapmf(reversal.universe, [25, 35, 35, 45])
    reversal['WEAK_UP']       = fuzz.trapmf(reversal.universe, [40, 50, 50, 60])
    reversal['MODERATE_UP']   = fuzz.trapmf(reversal.universe, [60, 70, 70, 80])
    reversal['CLEARLY_UP']    = fuzz.trapmf(reversal.universe, [75, 85, 100, 100])

    # --- Rules ---
    rules = []

    # Buy Rules (Aligned with MQL5 - removed trend condition)
    rules.append(ctrl.Rule(wick_lower['STRONG'] & break_up['STRONG'], reversal['CLEARLY_UP']))
    rules.append(ctrl.Rule(wick_lower['STRONG'] & break_up['WEAK'],   reversal['WEAK_UP']))

    # Sell Rules
    rules.append(ctrl.Rule(wick_upper['STRONG'] & break_down['STRONG'], reversal['CLEARLY_DOWN']))
    rules.append(ctrl.Rule(wick_upper['STRONG'] & break_down['WEAK'],   reversal['WEAK_DOWN']))

    # Rule 3: Confirmed Rejection but No Momentum (Daily=YES, H1=NONE) -> NOT_FORMED
    rules.append(ctrl.Rule(wick_lower['STRONG'] & break_up['NONE'],   reversal['NOT_FORMED']))
    rules.append(ctrl.Rule(wick_upper['STRONG'] & break_down['NONE'], reversal['NOT_FORMED']))

    # Neutral Rules (No Change)
    rules.append(ctrl.Rule(wick_upper['NONE'] & wick_lower['NONE'], reversal['NOT_FORMED']))
    rules.append(ctrl.Rule(wick_upper['STRONG'] & wick_lower['STRONG'], reversal['NOT_FORMED'])) # Conflict = Neutral

    reversal_ctrl = ctrl.ControlSystem(rules)
    simulation = ctrl.ControlSystemSimulation(reversal_ctrl)
    
    return simulation, reversal  # Return reversal consequent for plotting

# ==========================================
# 2. CONSOLE DEMO
# ==========================================
def run_console_demo():
    # 1. Initialize System
    sim, _ = create_fuzzy_system()
    
    # 2. Define Test Scenarios
    scenarios = [
        {
            "name": "SCENARIO 1: Strong Buy Setup",
            "desc": "Sideways + Strong Lower Wick + Strong Break Up",
            "inputs": {'wick_upper': 10, 'wick_lower': 90, 'break_up': 90, 'break_down': 10}
        },
        {
            "name": "SCENARIO 2: Weak Sell Setup",
            "desc": "Sideways + Strong Upper Wick + Weak Break Down",
            "inputs": {'wick_upper': 90, 'wick_lower': 10, 'break_up': 10, 'break_down': 50}
        },
        {
            "name": "SCENARIO 3: No Momentum (Neutral)",
            "desc": "Sideways + Strong Lower Wick + No Breakout",
            "inputs": {'wick_upper': 10, 'wick_lower': 90, 'break_up': 10, 'break_down': 10}
        },
        {
            "name": "SCENARIO 4: No Signal",
            "desc": "Sideways + No Wicks + Strong Break Up (Ignored)",
            "inputs": {'wick_upper': 10, 'wick_lower': 10, 'break_up': 90, 'break_down': 10}
        }
    ]

    print("\n=== FUZZY LOGIC SIMULATION RESULTS ===")

    # 3. Run Simulations
    for sc in scenarios:
        print(f"\n--- {sc['name']} ---")
        print(f"Context: {sc['desc']}")
        
        # Set Inputs
        for key, val in sc['inputs'].items():
            sim.input[key] = val
            
        # Compute
        try:
            sim.compute()
            score = sim.output['reversal']
            
            # Interpret Result
            decision = "NEUTRAL"
            if score > 60: decision = "STRONG BUY"
            elif score > 20: decision = "WEAK BUY"
            elif score < -60: decision = "STRONG SELL"
            elif score < -20: decision = "WEAK SELL"
            
            print(f"Inputs: {sc['inputs']}")
            print(f"Output Score: {score:.2f}")
            print(f"Decision:     {decision}")
            
        except Exception as e:
            print(f"Error computing: {e}")
    print("\n======================================\n")

# ==========================================
# 3. GUI APP (Dropdown Style)
# ==========================================

class FuzzyApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Fuzzy Logic Simulator (Digital Twin)")
        self.root.geometry("1100x700")
        
        # Initialize Fuzzy System
        self.simulation, self.reversal_consequent = create_fuzzy_system()
        
        # Define Mapping
        self.mapping = {
            "NONE": 10,
            "WEAK": 50,
            "STRONG": 90
        }
        
        # self.var_trend = tk.StringVar(value="SIDEWAYS")
        self.var_w_up  = tk.StringVar(value="NONE")
        self.var_w_low = tk.StringVar(value="NONE")
        self.var_b_up  = tk.StringVar(value="NONE")
        self.var_b_down= tk.StringVar(value="NONE")
        
        # Proper Matplotlib Embedding
        self.fig = Figure(figsize=(8, 6), dpi=100)
        self.ax = self.fig.add_subplot(111)
        
        self.setup_ui()
        self.update_chart()

    def setup_ui(self):
        # Main Layout: 2 Columns
        # Left: Controls (Inputs)
        # Right: Chart (Output)
        
        control_frame = ttk.Frame(self.root, padding=20, width=300)
        control_frame.pack(side=tk.LEFT, fill=tk.Y)
        
        # Title
        ttk.Label(control_frame, text="MQL5 Dashboard Inputs", font=("Segoe UI", 16, "bold")).pack(pady=(0, 20))
        
        # Input 1: Trend
        # self.create_dropdown(control_frame, "Trend Context", self.var_trend, ["SIDEWAYS"])
        # ttk.Separator(control_frame, orient='horizontal').pack(fill='x', pady=15)
        
        # Input 2 & 3: Sell Components
        ttk.Label(control_frame, text="SELL FACTORS", font=("Segoe UI", 10, "bold"), foreground="red").pack(anchor="w")
        self.create_dropdown(control_frame, "Wick Upper (Resist. Rej)", self.var_w_up, ["NONE", "WEAK", "STRONG"])
        self.create_dropdown(control_frame, "H1 Break Down", self.var_b_down, ["NONE", "WEAK", "STRONG"])
        ttk.Separator(control_frame, orient='horizontal').pack(fill='x', pady=15)

        # Input 4 & 5: Buy Components
        ttk.Label(control_frame, text="BUY FACTORS", font=("Segoe UI", 10, "bold"), foreground="green").pack(anchor="w")
        self.create_dropdown(control_frame, "Wick Lower (Supp. Rej)", self.var_w_low, ["NONE", "WEAK", "STRONG"])
        self.create_dropdown(control_frame, "H1 Break Up", self.var_b_up, ["NONE", "WEAK", "STRONG"])
        
        # Result Box
        res_frame = ttk.LabelFrame(control_frame, text="Fuzzy Output", padding=10)
        res_frame.pack(fill=tk.X, pady=30)
        
        self.lbl_score = ttk.Label(res_frame, text="0.00", font=("Consolas", 24, "bold"))
        self.lbl_score.pack(anchor="center")
        self.lbl_status = ttk.Label(res_frame, text="NEUTRAL", font=("Segoe UI", 12))
        self.lbl_status.pack(anchor="center")

        # Chart Area
        self.canvas = FigureCanvasTkAgg(self.fig, master=self.root)
        self.canvas.get_tk_widget().pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)

    def create_dropdown(self, parent, label, variable, values):
        frame = ttk.Frame(parent)
        frame.pack(fill=tk.X, pady=5)
        
        ttk.Label(frame, text=label).pack(anchor="w")
        
        cb = ttk.Combobox(frame, textvariable=variable, values=values, state="readonly", font=("Segoe UI", 10))
        cb.pack(fill=tk.X)
        cb.bind("<<ComboboxSelected>>", lambda e: self.update_chart())

    def update_chart(self):
        try:
            # Get values
            # t_val = 50 # Sideways
            wu_val = self.mapping.get(self.var_w_up.get(), 0)
            wl_val = self.mapping.get(self.var_w_low.get(), 0)
            bu_val = self.mapping.get(self.var_b_up.get(), 0)
            bd_val = self.mapping.get(self.var_b_down.get(), 0)

            # Pass inputs
            # self.simulation.input['trend'] = t_val
            self.simulation.input['wick_upper'] = wu_val
            self.simulation.input['wick_lower'] = wl_val
            self.simulation.input['break_up']   = bu_val
            self.simulation.input['break_down'] = bd_val
            
            # Compute
            self.simulation.compute()
            score = self.simulation.output['reversal']
            
        except Exception as e:
            score = 0.0

        # Update Text
        self.lbl_score.config(text=f"{score:.2f}")
        
        status = "NEUTRAL"
        color = "gray"
        if score > 60: 
            status = "STRONG BUY"
            color = "green"
        elif score > 20: 
            status = "WEAK BUY"
            color = "#2E8B57" # SeaGreen
        elif score < -60: 
            status = "STRONG SELL"
            color = "red"
        elif score < -20: 
            status = "WEAK SELL"
            color = "#B22222" # Firebrick
            
        self.lbl_status.config(text=status, foreground=color)
        self.lbl_score.config(foreground=color)

        # Draw Graph (MANUALLY to avoid popup issues)
        self.ax.clear()
        
        # 1. Plot Membership Functions
        universe = self.reversal_consequent.universe
        for label, term in self.reversal_consequent.terms.items():
            self.ax.plot(universe, term.mf, label=label, linewidth=1, alpha=0.5)
            
        # 2. Plot Result Line
        self.ax.axvline(x=score, color='black', linewidth=3, linestyle='--')
        self.ax.text(score, 1.05, f"{score:.1f}", ha='center', va='bottom', fontsize=12, fontweight='bold')

        # 3. Styling
        self.ax.set_title("Fuzzy Logic Decision Surface")
        self.ax.set_xlabel("Reversal Score (-100 Sell ... +100 Buy)")
        self.ax.set_ylim(0, 1.1)
        self.ax.grid(True, alpha=0.2)
        # self.ax.legend(loc='upper right', fontsize='small') # Optional, might crowd the plot
        
        self.canvas.draw()

if __name__ == "__main__":
    # RUN CONSOLE DEMO FIRST
    run_console_demo()
    
    # THEN START GUI
    root = tk.Tk()
    app = FuzzyApp(root)
    root.mainloop()
