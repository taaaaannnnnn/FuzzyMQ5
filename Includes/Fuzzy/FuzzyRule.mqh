//+------------------------------------------------------------------+
//|                                                    FuzzyRule.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "FuzzyVariable.mqh"

class FuzzyTerm : public CObject
{
public:
    FuzzyVariable *m_variable;
    FuzzySet      *m_set;

    FuzzyTerm(FuzzyVariable *var, string set_name)
    {
        m_variable = var;
        if(CheckPointer(var) != POINTER_INVALID)
            m_set = var.getFuzzySetByName(set_name);
        else
            m_set = NULL;
    }
};

class FuzzyRule : public CObject
{
private:
    FuzzyTerm *m_antecedents[];
    FuzzyTerm *m_consequent;
    double     m_strength;

public:
    FuzzyRule();
    ~FuzzyRule();

    bool  addAntecedent(FuzzyVariable *var, string set_name);
    void  setConsequent(FuzzyVariable *var, string set_name);
    void  evaluate();
    double getStrength() const;
    FuzzyTerm* getConsequent();
};

FuzzyRule::FuzzyRule()
{
    ArrayResize(m_antecedents, 0);
    m_consequent = NULL;
    m_strength = 0.0;
}

FuzzyRule::~FuzzyRule()
{
    for(int i = 0; i < ArraySize(m_antecedents); i++)
    {
        if(CheckPointer(m_antecedents[i]) == POINTER_DYNAMIC) delete m_antecedents[i];
    }
    ArrayFree(m_antecedents);
    
    if (CheckPointer(m_consequent) == POINTER_DYNAMIC)
    {
        delete m_consequent;
    }
}

bool FuzzyRule::addAntecedent(FuzzyVariable *var, string set_name)
{
    if(CheckPointer(var) == POINTER_INVALID) return false;
    FuzzyTerm *term = new FuzzyTerm(var, set_name);
    if(CheckPointer(term.m_set) == POINTER_INVALID)
    {
        delete term;
        return false;
    }
    int size = ArraySize(m_antecedents);
    ArrayResize(m_antecedents, size + 1);
    m_antecedents[size] = term;
    return true;
}

void FuzzyRule::setConsequent(FuzzyVariable *var, string set_name)
{
    if(CheckPointer(var) == POINTER_INVALID) return;
    if(CheckPointer(m_consequent) == POINTER_DYNAMIC) delete m_consequent;
    m_consequent = new FuzzyTerm(var, set_name);
}

void FuzzyRule::evaluate()
{
    m_strength = 1.0;
    int total = ArraySize(m_antecedents);
    if(total == 0) 
    {
        m_strength = 0.0;
        return;
    }

    for(int i = 0; i < total; i++)
    {
        FuzzyTerm *term = m_antecedents[i];
        if(CheckPointer(term) != POINTER_INVALID && CheckPointer(term.m_set) != POINTER_INVALID)
        {
            m_strength = MathMin(m_strength, term.m_set.getDOM());
        }
    }
}

double FuzzyRule::getStrength() const { return m_strength; }
FuzzyTerm* FuzzyRule::getConsequent() { return m_consequent; }
