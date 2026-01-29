//+------------------------------------------------------------------+
//|                                                     FuzzySet.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Object.mqh>

class FuzzySet : public CObject
{
private:
    string m_name;
    double m_peak_point1, m_peak_point2, m_peak_point3, m_peak_point4;
    double m_degree_of_membership;

public:
    FuzzySet(string name, double p1, double p2, double p3, double p4);
    ~FuzzySet();

    double calculateDOM(double crisp_value);
    void   clearDOM();

    string getName() const;
    void   setDOM(double value);
    double getDOM() const;
    double getCenter() const;
    
    virtual bool      Equals(const CObject *obj) const { return GetPointer(this) == obj; }
    virtual int       Compare(const CObject *obj, int mode = 0) const { return 0; }
};

FuzzySet::FuzzySet(string name, double p1, double p2, double p3, double p4)
{
    m_name = name;
    m_peak_point1 = p1;
    m_peak_point2 = p2;
    m_peak_point3 = p3;
    m_peak_point4 = p4;
    m_degree_of_membership = 0.0;
}

FuzzySet::~FuzzySet()
{
}

double FuzzySet::calculateDOM(double crisp_value)
{
    if (crisp_value <= m_peak_point1 || crisp_value >= m_peak_point4) return 0.0;
    
    if (crisp_value > m_peak_point1 && crisp_value < m_peak_point2)
        return (crisp_value - m_peak_point1) / (m_peak_point2 - m_peak_point1);
    else if (crisp_value >= m_peak_point2 && crisp_value <= m_peak_point3)
        return 1.0;
    else if (crisp_value > m_peak_point3 && crisp_value < m_peak_point4)
        return (m_peak_point4 - crisp_value) / (m_peak_point4 - m_peak_point3);
    
    return 0.0;
}

void FuzzySet::clearDOM() { m_degree_of_membership = 0.0; }

void FuzzySet::setDOM(double value)
{
    if (value > 1.0) m_degree_of_membership = 1.0;
    else if (value < 0.0) m_degree_of_membership = 0.0;
    else m_degree_of_membership = value;
}

double FuzzySet::getDOM() const { return m_degree_of_membership; }
double FuzzySet::getCenter() const { return (m_peak_point2 + m_peak_point3) / 2.0; }
string FuzzySet::getName() const { return m_name; }