//+------------------------------------------------------------------+
//|                                                FuzzyVariable.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "FuzzySet.mqh"

class FuzzyVariable : public CObject
{
private:
    string m_name;
    FuzzySet *m_fuzzy_sets[];

public:
    FuzzyVariable(string name);
    ~FuzzyVariable();

    bool addFuzzySet(FuzzySet *fuzzy_set);
    void fuzzify(double crisp_value);

    string getName() const;
    FuzzySet* getFuzzySetByName(string set_name);
    int GetTotalSets() { return ArraySize(m_fuzzy_sets); }
    FuzzySet* GetSetAt(int index) { if(index >= 0 && index < ArraySize(m_fuzzy_sets)) return m_fuzzy_sets[index]; return NULL; }
};

FuzzyVariable::FuzzyVariable(string name)
{
    m_name = name;
    ArrayResize(m_fuzzy_sets, 0);
}

FuzzyVariable::~FuzzyVariable()
{
    for(int i = 0; i < ArraySize(m_fuzzy_sets); i++)
    {
        if(CheckPointer(m_fuzzy_sets[i]) == POINTER_DYNAMIC) delete m_fuzzy_sets[i];
    }
    ArrayFree(m_fuzzy_sets);
}

bool FuzzyVariable::addFuzzySet(FuzzySet *fuzzy_set)
{
    if (CheckPointer(fuzzy_set) == POINTER_INVALID) return false;
    if (getFuzzySetByName(fuzzy_set.getName()) != NULL) return false;
    
    int size = ArraySize(m_fuzzy_sets);
    ArrayResize(m_fuzzy_sets, size + 1);
    m_fuzzy_sets[size] = fuzzy_set;
    return true;
}

void FuzzyVariable::fuzzify(double crisp_value)
{
    for (int i = 0; i < ArraySize(m_fuzzy_sets); i++)
    {
        FuzzySet *fs = m_fuzzy_sets[i];
        if (CheckPointer(fs) != POINTER_INVALID)
        {
            fs.setDOM(fs.calculateDOM(crisp_value));
        }
    }
}

string FuzzyVariable::getName() const { return m_name; }

FuzzySet* FuzzyVariable::getFuzzySetByName(string set_name)
{
    for (int i = 0; i < ArraySize(m_fuzzy_sets); i++)
    {
        FuzzySet *fs = m_fuzzy_sets[i];
        if (CheckPointer(fs) != POINTER_INVALID && fs.getName() == set_name) return fs;
    }
    return NULL;
}
