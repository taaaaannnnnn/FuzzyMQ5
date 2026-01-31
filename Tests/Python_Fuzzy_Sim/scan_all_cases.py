import numpy as np
import skfuzzy as fuzz
from skfuzzy import control as ctrl
import itertools

def create_fuzzy_system_v99_final_no_c3():
    trend = ctrl.Antecedent(np.arange(0, 101, 1), 'trend')
    wick_up = ctrl.Antecedent(np.arange(0, 101, 1), 'wick_up')
    wick_lo = ctrl.Antecedent(np.arange(0, 101, 1), 'wick_lo')
    h1_bear = ctrl.Antecedent(np.arange(0, 101, 1), 'h1_bear')
    h1_bull = ctrl.Antecedent(np.arange(0, 101, 1), 'h1_bull')
    reversal = ctrl.Consequent(np.arange(-100, 101, 1), 'reversal')

    # MFs (Same as MQL5)
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

    rules = []
    
    # === RULES FROM MQL5 ===

    # --- SIDEWAYS ---
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_up['STRONG'] & h1_bear['STRONG'], reversal['MODERATE_DOWN'])) # S1
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_up['STRONG'] & h1_bear['WEAK'],   reversal['WEAK_DOWN']))     # S2
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_up['NONE'] & wick_lo['NONE'] & h1_bear['STRONG'], reversal['STARTING_DOWN'])) # S3
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_up['STRONG'] & h1_bear['NONE'] & h1_bull['NONE'], reversal['STARTING_DOWN'])) # S4

    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_lo['STRONG'] & h1_bull['STRONG'], reversal['MODERATE_UP']))   # B1
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_lo['STRONG'] & h1_bull['WEAK'],   reversal['WEAK_UP']))       # B2
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_lo['NONE'] & wick_up['NONE'] & h1_bull['STRONG'], reversal['STARTING_UP']))   # B3
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_lo['STRONG'] & h1_bull['NONE'] & h1_bear['NONE'], reversal['STARTING_UP']))   # B4

    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_up['STRONG'] & h1_bull['STRONG'], reversal['WEAK_UP'])) 
    rules.append(ctrl.Rule(trend['SIDEWAYS'] & wick_lo['STRONG'] & h1_bear['STRONG'], reversal['WEAK_DOWN']))

    # --- UPTREND ---
    rules.append(ctrl.Rule(trend['BULLISH'] & wick_lo['STRONG'] & h1_bull['STRONG'], reversal['CLEARLY_UP']))  # U1
    rules.append(ctrl.Rule(trend['BULLISH'] & wick_lo['STRONG'] & h1_bull['WEAK'],   reversal['MODERATE_UP'])) # U2
    rules.append(ctrl.Rule(trend['BULLISH'] & wick_lo['NONE']   & h1_bull['STRONG'], reversal['MODERATE_UP'])) # U3

    # Friction (-15) & Momentum Drag (-20)
    # Changed output to STARTING_DOWN (-15) per last discussion
    rules.append(ctrl.Rule(trend['BULLISH'] & wick_up['STRONG'], reversal['STARTING_DOWN']))     # U_DRAG (-15)
    rules.append(ctrl.Rule(trend['BULLISH'] & h1_bear['STRONG'], reversal['STARTING_DOWN'])) # U_MOM_DRAG (-20) (Let's keep STARTING here too)
    
    # Counter (-25) 
    rules.append(ctrl.Rule(trend['BULLISH'] & wick_up['STRONG'] & h1_bear['STRONG'], reversal['STARTING_DOWN'])) # U_C1 (-25, mapped to STARTING)
    rules.append(ctrl.Rule(trend['BULLISH'] & wick_up['STRONG'] & h1_bear['WEAK'],   reversal['STARTING_DOWN'])) # U_C2
    # U_C3 REMOVED

    # --- DOWNTREND ---
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

    sim = ctrl.ControlSystemSimulation(ctrl.ControlSystem(rules))
    return sim

def scan_108():
    sim = create_fuzzy_system_v99_final_no_c3()
    
    V_NONE = 10
    V_WEAK = 50
    V_STR  = 90
    
    trends = [('BEAR', 20), ('SIDE', 50), ('BULL', 80)]
    wicks  = [('NONE', V_NONE), ('STR', V_STR)]
    breaks = [('NONE', V_NONE), ('WEAK', V_WEAK), ('STR', V_STR)] 

    print(f"{'No':<3}| {'TREND':<5} | {'W_UP':<4} | {'W_LO':<4} | {'H1_BE':<4} | {'H1_BU':<4} | {'SCORE':<5}")
    print("-" * 55)

    idx = 1
    for t in trends:
        for wu in wicks:
            for wl in wicks:
                for hbe in breaks:
                    for hbu in breaks:
                        sim.input['trend'] = t[1]
                        sim.input['wick_up'] = wu[1]
                        sim.input['wick_lo'] = wl[1]
                        sim.input['h1_bear'] = hbe[1]
                        sim.input['h1_bull'] = hbu[1]
                        
                        try:
                            sim.compute()
                            score = sim.output['reversal']
                        except:
                            score = 0.0
                        
                        su = "NO" if wu[0]=="NONE" else "ST"
                        sl = "NO" if wl[0]=="NONE" else "ST"
                        sbe = "NO" if hbe[0]=="NONE" else ("WK" if hbe[0]=="WEAK" else "ST")
                        sbu = "NO" if hbu[0]=="NONE" else ("WK" if hbu[0]=="WEAK" else "ST")
                        
                        print(f"{idx:<3}| {t[0]:<5} | {su:<4} | {sl:<4} | {sbe:<4} | {sbu:<4} | {score:5.1f}")
                        idx += 1

if __name__ == "__main__":
    scan_108()