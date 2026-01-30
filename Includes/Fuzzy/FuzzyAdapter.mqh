//+------------------------------------------------------------------+
//|                                                 FuzzyAdapter.mqh |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//+------------------------------------------------------------------+
#property strict
#include <Math\Fuzzy\mamdanifuzzysystem.mqh>
#include <Math\Fuzzy\dictionary.mqh>

class FuzzyAdapter : public CObject
{
private:
   CMamdaniFuzzySystem *m_fs;
   
   // Internal storage for inputs because CFuzzyVariable doesn't store crisp values
   string               m_input_names[];
   double               m_input_values[];

public:
   FuzzyAdapter() { m_fs = new CMamdaniFuzzySystem(); }
   ~FuzzyAdapter() 
   { 
      if(CheckPointer(m_fs) == POINTER_DYNAMIC) delete m_fs; 
      ArrayFree(m_input_names);
      ArrayFree(m_input_values);
   }

   void AddInput(string arg_name, double min_v, double max_v) 
   { 
      CFuzzyVariable *v = new CFuzzyVariable(arg_name, min_v, max_v);
      m_fs.Input().Add(v); 
      
      // Register in internal storage
      int size = ArraySize(m_input_names);
      ArrayResize(m_input_names, size + 1);
      ArrayResize(m_input_values, size + 1);
      m_input_names[size] = arg_name;
      m_input_values[size] = 0.0; // Default
   }
   
   void AddOutput(string arg_name, double min_v, double max_v) 
   { 
      CFuzzyVariable *v = new CFuzzyVariable(arg_name, min_v, max_v);
      m_fs.Output().Add(v); 
   }

   void AddTerm(string arg_var, string arg_term, double a, double b, double c, double d)
   {
      CObject *obj = m_fs.InputByName(arg_var);
      if(CheckPointer(obj) == POINTER_INVALID) obj = m_fs.OutputByName(arg_var);
      
      if(CheckPointer(obj) != POINTER_INVALID) 
      {
         CFuzzyVariable *v_ptr = (CFuzzyVariable*)obj;
         CTrapezoidMembershipFunction *func = new CTrapezoidMembershipFunction(a, b, c, d);
         CFuzzyTerm *term = new CFuzzyTerm(arg_term, func);
         v_ptr.Terms().Add(term);
      }
   }

   void AddRule(string arg_text, double arg_weight = 1.0) 
   { 
      CMamdaniFuzzyRule *r = m_fs.ParseRule(arg_text);
      if(CheckPointer(r) != POINTER_INVALID)
      {
         r.Weight(arg_weight);
         m_fs.Rules().Add(r); 
      }
   }

   void SetInput(string arg_name, double arg_val)
   {
      for(int i=0; i<ArraySize(m_input_names); i++)
      {
         if(m_input_names[i] == arg_name)
         {
            m_input_values[i] = arg_val;
            return;
         }
      }
   }

   double GetOutput(string arg_out_name)
   {
      // 1. Build the Input List required by Calculate()
      CList *input_list = new CList();
      
      for(int i=0; i<ArraySize(m_input_names); i++)
      {
         CObject *obj = m_fs.InputByName(m_input_names[i]);
         if(CheckPointer(obj) != POINTER_INVALID)
         {
            CFuzzyVariable *var = (CFuzzyVariable*)obj;
            CDictionary_Obj_Double *pair = new CDictionary_Obj_Double();
            pair.SetAll(var, m_input_values[i]);
            input_list.Add(pair);
         }
      }

      // 2. Execute Calculation
      CList *results = m_fs.Calculate(input_list); 
      
      // 3. Extract Result
      double final_val = 0.0;
      if(CheckPointer(results) != POINTER_INVALID)
      {
         // Find output value by name from the results list (Dictionary List)
         for(int i=0; i<results.Total(); i++)
         {
            CDictionary_Obj_Double *res_pair = (CDictionary_Obj_Double*)results.GetNodeAtIndex(i);
            CFuzzyVariable *res_var = (CFuzzyVariable*)res_pair.Key();
            
            if(CheckPointer(res_var) != POINTER_INVALID && res_var.Name() == arg_out_name)
            {
               final_val = res_pair.Value();
               break;
            }
         }
      }
      
      // 4. Cleanup
      delete input_list; // This deletes the Dictionary objects inside it
      // Do NOT delete 'results', as Calculate() returns a list that might be managed internally or needs careful handling. 
      // Checking genericfuzzysystem: Calculate returns a 'result' list created with 'new'. So we MUST delete it.
      if(CheckPointer(results) == POINTER_DYNAMIC) delete results;

      return final_val;
   }
};