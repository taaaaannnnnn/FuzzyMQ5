//+------------------------------------------------------------------+
//|                                                 FuzzySystem.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "FuzzyRule.mqh"

class FuzzySystem : public CObject
{
private:
    FuzzyVariable *m_input_variables[];
    FuzzyVariable *m_output_variables[];
    FuzzyRule     *m_rules[];

    void      evaluateRules();
    void      aggregate();

public:
    FuzzySystem();
    ~FuzzySystem();

    bool addInputVariable(FuzzyVariable *var);
    bool addOutputVariable(FuzzyVariable *var);
    bool addRule(FuzzyRule *rule);

    double calculate(string output_variable_name);
    
    FuzzyVariable* getInputVariableByName(string name);
    FuzzyVariable* getOutputVariableByName(string name);
};

FuzzySystem::FuzzySystem()
{
    ArrayResize(m_input_variables, 0);
    ArrayResize(m_output_variables, 0);
    ArrayResize(m_rules, 0);
}

FuzzySystem::~FuzzySystem()
{
    for(int i=0; i<ArraySize(m_input_variables); i++) if(CheckPointer(m_input_variables[i]) == POINTER_DYNAMIC) delete m_input_variables[i];
    for(int i=0; i<ArraySize(m_output_variables); i++) if(CheckPointer(m_output_variables[i]) == POINTER_DYNAMIC) delete m_output_variables[i];
    for(int i=0; i<ArraySize(m_rules); i++) if(CheckPointer(m_rules[i]) == POINTER_DYNAMIC) delete m_rules[i];
    ArrayFree(m_input_variables);
    ArrayFree(m_output_variables);
    ArrayFree(m_rules);
}

bool FuzzySystem::addInputVariable(FuzzyVariable *var) 
{ 
    if(CheckPointer(var) == POINTER_INVALID) return false; 
    int size = ArraySize(m_input_variables);
    ArrayResize(m_input_variables, size + 1);
    m_input_variables[size] = var;
    return true; 
}

bool FuzzySystem::addOutputVariable(FuzzyVariable *var) 
{ 
    if(CheckPointer(var) == POINTER_INVALID) return false; 
    int size = ArraySize(m_output_variables);
    ArrayResize(m_output_variables, size + 1);
    m_output_variables[size] = var;
    return true; 
}

bool FuzzySystem::addRule(FuzzyRule *rule) 
{ 
    if(CheckPointer(rule) == POINTER_INVALID) return false; 
    int size = ArraySize(m_rules);
    ArrayResize(m_rules, size + 1);
    m_rules[size] = rule;
    return true; 
}

void FuzzySystem::evaluateRules()
{
    for(int i = 0; i < ArraySize(m_rules); i++)
    {
        FuzzyRule *rule = m_rules[i];
        if(CheckPointer(rule) != POINTER_INVALID) rule.evaluate();
    }
}

void FuzzySystem::aggregate()
{
    for(int i = 0; i < ArraySize(m_output_variables); i++)
    {
        FuzzyVariable *output_var = m_output_variables[i];
        if(CheckPointer(output_var) == POINTER_INVALID) continue;
        
        for(int j = 0; j < output_var.GetTotalSets(); j++)
        {
            FuzzySet *output_set = output_var.GetSetAt(j);
            if(CheckPointer(output_set) == POINTER_INVALID) continue;
            
            output_set.clearDOM();
            double max_strength = 0.0;
            
            for(int k = 0; k < ArraySize(m_rules); k++)
            {
                FuzzyRule *rule = m_rules[k];
                if(CheckPointer(rule) != POINTER_INVALID) 
                {
                   FuzzyTerm *consequent = rule.getConsequent();
                   if(CheckPointer(consequent) != POINTER_INVALID && CheckPointer(consequent.m_set) != POINTER_INVALID && consequent.m_set.getName() == output_set.getName())
                   {
                       max_strength = MathMax(max_strength, rule.getStrength());
                   }
                }
            }
            output_set.setDOM(max_strength);
        }
    }
}

double FuzzySystem::calculate(string output_variable_name)
{
    evaluateRules();
    aggregate();

    FuzzyVariable *output_var = getOutputVariableByName(output_variable_name);
    if(CheckPointer(output_var) == POINTER_INVALID) return 0.0;

    double numerator = 0.0;
    double denominator = 0.0;
    
    for(int i = 0; i < output_var.GetTotalSets(); i++)
    {
        FuzzySet *set = output_var.GetSetAt(i);
        if(CheckPointer(set) == POINTER_INVALID) continue;

        double strength = set.getDOM();
        double center = set.getCenter();
        
        numerator += center * strength;
        denominator += strength;
    }
    
    if(denominator == 0.0) return 0.0;
    return numerator / denominator;
}

FuzzyVariable* FuzzySystem::getInputVariableByName(string name)
{
    for(int i=0; i<ArraySize(m_input_variables); i++)
    {
        FuzzyVariable *var = m_input_variables[i];
        if(CheckPointer(var) != POINTER_INVALID && var.getName() == name) return var;
    }
    return NULL;
}

FuzzyVariable* FuzzySystem::getOutputVariableByName(string name)
{
    for(int i=0; i<ArraySize(m_output_variables); i++)
    {
        FuzzyVariable *var = m_output_variables[i];
        if(CheckPointer(var) != POINTER_INVALID && var.getName() == name) return var;
    }
    return NULL;
}