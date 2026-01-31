import numpy as np
import skfuzzy as fuzz
from skfuzzy import control as ctrl

def run_debug():
    print("Initializing Fuzzy System...")
    
    # Inputs
    wick_upper = ctrl.Antecedent(np.arange(0, 101, 1), 'wick_upper')
    wick_lower = ctrl.Antecedent(np.arange(0, 101, 1), 'wick_lower')
    break_up   = ctrl.Antecedent(np.arange(0, 101, 1), 'break_up')
    break_down = ctrl.Antecedent(np.arange(0, 101, 1), 'break_down')

    # Output
    reversal = ctrl.Consequent(np.arange(-100, 101, 1), 'reversal')

    # MF Setup
    for comp in [wick_upper, wick_lower, break_up, break_down]:
        comp['NONE']   = fuzz.trapmf(comp.universe, [0, 0, 20, 30])
        comp['WEAK']   = fuzz.trapmf(comp.universe, [20, 30, 50, 60]) # Fixed range?
        comp['STRONG'] = fuzz.trapmf(comp.universe, [60, 70, 100, 100]) # Fixed range?

    # Re-check original ranges in fuzzy_simulator.py:
    # NONE: [0, 0, 20, 30]
    # WEAK: [30, 40, 60, 70]
    # STRONG: [70, 80, 100, 100]
    
    # Use ORIGINAL ranges
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

    # Rules
    rules = []
    # Buy Rules
    rules.append(ctrl.Rule(wick_lower['STRONG'] & break_up['STRONG'], reversal['CLEARLY_UP']))
    
    # System
    reversal_ctrl = ctrl.ControlSystem(rules)
    sim = ctrl.ControlSystemSimulation(reversal_ctrl)

    # Test
    print("Running Test: Strong Buy")
    inputs = {'wick_upper': 10, 'wick_lower': 90, 'break_up': 90, 'break_down': 10}
    print(f"Inputs: {inputs}")
    
    sim.input['wick_upper'] = inputs['wick_upper'] 
    sim.input['wick_lower'] = inputs['wick_lower'] 
    sim.input['break_up']   = inputs['break_up']   
    sim.input['break_down'] = inputs['break_down'] 
    
    try:
        sim.compute()
        print(f"Output Score: {sim.output['reversal']}")
        # print(sim.print_state())
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    run_debug()
