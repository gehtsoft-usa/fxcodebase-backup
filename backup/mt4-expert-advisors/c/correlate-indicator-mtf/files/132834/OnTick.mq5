#property description"OnTick" 
#property indicator_chart_window
#property strict
//--- input parameters
input long     chartID=0;
input ushort   eventID=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
   if(prev_calculated)
      ::EventChartCustom(chartID,eventID,eventID,rates_total-prev_calculated,_Symbol);   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
