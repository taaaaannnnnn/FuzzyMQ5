import unittest
import numpy as np
from fuzzy_simulator import create_fuzzy_system

class TestFuzzyLogic(unittest.TestCase):
    def setUp(self):
        self.sim, self.consequent = create_fuzzy_system()
        # Constants for input values based on MFs
        self.SIDEWAYS = 50
        
        self.NONE = 10
        self.WEAK = 50
        self.STRONG = 90
        
        # Expected Output Ranges
        self.CLEARLY_UP_MIN = 75
        self.WEAK_UP_MIN = 40
        self.WEAK_UP_MAX = 60
        
        self.CLEARLY_DOWN_MAX = -75
        self.WEAK_DOWN_MAX = -40
        self.WEAK_DOWN_MIN = -60

        self.NEUTRAL_MIN = -25
        self.NEUTRAL_MAX = 25

    def compute_score(self, trend, wick_up, wick_low, break_up, break_down):
        self.sim.input['trend'] = trend
        self.sim.input['wick_upper'] = wick_up
        self.sim.input['wick_lower'] = wick_low
        self.sim.input['break_up'] = break_up
        self.sim.input['break_down'] = break_down
        self.sim.compute()
        return self.sim.output['reversal']

    # =================================================================
    # RULE 1: Strong Buy
    # Trend=SIDEWAYS & Daily=YES (Lower Wick) & H1=STRONG (Break Up)
    # -> CLEARLY_FORMING (Buy)
    # =================================================================
    def test_rule_1_strong_buy(self):
        score = self.compute_score(
            trend=self.SIDEWAYS,
            wick_up=self.NONE,
            wick_low=self.STRONG,
            break_up=self.STRONG,
            break_down=self.NONE
        )
        self.assertGreaterEqual(score, self.CLEARLY_UP_MIN, "Rule 1 (Buy) should return CLEARLY_UP score (>75)")

    # =================================================================
    # RULE 1 (Mirror): Strong Sell
    # Trend=SIDEWAYS & Daily=YES (Upper Wick) & H1=STRONG (Break Down)
    # -> CLEARLY_FORMING (Sell)
    # =================================================================
    def test_rule_1_strong_sell(self):
        score = self.compute_score(
            trend=self.SIDEWAYS,
            wick_up=self.STRONG,
            wick_low=self.NONE,
            break_up=self.NONE,
            break_down=self.STRONG
        )
        self.assertLessEqual(score, self.CLEARLY_DOWN_MAX, "Rule 1 (Sell) should return CLEARLY_DOWN score (<-75)")

    # =================================================================
    # RULE 2: Weak Buy
    # Trend=SIDEWAYS & Daily=YES (Lower Wick) & H1=WEAK (Break Up)
    # -> WEAKLY_FORMING (Buy)
    # =================================================================
    def test_rule_2_weak_buy(self):
        score = self.compute_score(
            trend=self.SIDEWAYS,
            wick_up=self.NONE,
            wick_low=self.STRONG,
            break_up=self.WEAK,
            break_down=self.NONE
        )
        # Check range 40 to 60
        self.assertTrue(self.WEAK_UP_MIN <= score <= self.WEAK_UP_MAX, 
                        f"Rule 2 (Buy) should be in WEAK_UP range (40-60). Got {score}")

    # =================================================================
    # RULE 2 (Mirror): Weak Sell
    # Trend=SIDEWAYS & Daily=YES (Upper Wick) & H1=WEAK (Break Down)
    # -> WEAKLY_FORMING (Sell)
    # =================================================================
    def test_rule_2_weak_sell(self):
        score = self.compute_score(
            trend=self.SIDEWAYS,
            wick_up=self.STRONG,
            wick_low=self.NONE,
            break_up=self.NONE,
            break_down=self.WEAK
        )
        # Check range -60 to -40
        self.assertTrue(self.WEAK_DOWN_MIN <= score <= self.WEAK_DOWN_MAX, 
                        f"Rule 2 (Sell) should be in WEAK_DOWN range (-60 to -40). Got {score}")

    # =================================================================
    # RULE 3: Not Formed (Conflict or No Momentum)
    # Trend=SIDEWAYS & Daily=YES & H1=NONE
    # =================================================================
    # Note: The current simulator handles "Rule 3" implicitly via default or neutral rules.
    # We explicitly test the case where there is a wick but no breakout.
    def test_rule_3_no_momentum_buy_side(self):
        score = self.compute_score(
            trend=self.SIDEWAYS,
            wick_up=self.NONE,
            wick_low=self.STRONG,
            break_up=self.NONE,
            break_down=self.NONE
        )
        # Should be Neutral / Not Formed
        self.assertTrue(self.NEUTRAL_MIN <= score <= self.NEUTRAL_MAX,
                        f"Rule 3 (Buy Side No Momentum) should be NEUTRAL. Got {score}")

    def test_rule_3_no_momentum_sell_side(self):
        score = self.compute_score(
            trend=self.SIDEWAYS,
            wick_up=self.STRONG,
            wick_low=self.NONE,
            break_up=self.NONE,
            break_down=self.NONE
        )
        # Should be Neutral / Not Formed
        self.assertTrue(self.NEUTRAL_MIN <= score <= self.NEUTRAL_MAX,
                        f"Rule 3 (Sell Side No Momentum) should be NEUTRAL. Got {score}")

    # =================================================================
    # RULE 4: No Daily Rejection
    # Trend=SIDEWAYS & Daily=NO
    # =================================================================
    def test_rule_4_no_daily_signal(self):
        score = self.compute_score(
            trend=self.SIDEWAYS,
            wick_up=self.NONE,
            wick_low=self.NONE,
            break_up=self.STRONG, # Even if strong breakout
            break_down=self.NONE
        )
        # Since Daily Rejection is a prerequisite for reversal, this should be neutral/low
        # The simulator has a rule: wick_upper['NONE'] & wick_lower['NONE'] -> reversal['NOT_FORMED']
        self.assertTrue(self.NEUTRAL_MIN <= score <= self.NEUTRAL_MAX,
                        f"Rule 4 (No Daily Wick) should be NEUTRAL regardless of breakout. Got {score}")

if __name__ == '__main__':
    unittest.main()
