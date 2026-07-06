// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70100

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+ 

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"
#property strict
#property indicator_chart_window

input int MaxShots = 100;
input int size_x = 400;
input int size_y = 300;
datetime Gt_100 = 0;
int Gi_104 = 1;
string Gs_108;
string Gs_116;

string IndicatorObjPrefix;
bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}
string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}
int OnInit(void)
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("sc");
   IndicatorSetString(INDICATOR_SHORTNAME, "Screen Capture");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

int OnCalculate(const int rates_total,       // size of input time series
                const int prev_calculated,   // number of handled bars at the previous call
                const datetime& time[],      // Time array
                const double& open[],        // Open array
                const double& high[],        // High array
                const double& low[],         // Low array
                const double& close[],       // Close array
                const long& tick_volume[],   // Tick Volume array
                const long& volume[],        // Real Volume array
                const int& spread[]          // Spread array
)
{
   if (Gt_100 != time[rates_total - 1] && Gi_104 < MaxShots) 
   {
      Gs_116 = "";
      if (Gi_104 < 100) Gs_116 = "0";
      if (Gi_104 < 10) Gs_116 = "00";
      Gs_108 = Symbol() + Period() + "-" + Gs_116 + Gi_104 + ".gif";
      ChartScreenShot(0, Gs_108, size_x, size_y);
      Gt_100 = time[rates_total - 1];
      Gi_104++;
   }
   return rates_total;
}
