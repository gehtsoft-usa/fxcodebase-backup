// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70673

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict
// based on Copyright © 2011, TrendLaboratory http://finance.groups.yahoo.com/group/TrendLaboratory igorad2003@yahoo.co.uk
#property indicator_chart_window
#property indicator_plots 1
#property indicator_buffers 2
#property indicator_type1  DRAW_COLOR_LINE
#property indicator_color1 DeepSkyBlue,OrangeRed
#property indicator_width1 2
#property indicator_style1 STYLE_SOLID

#define ACT_ON_SWITCH

input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
input ENUM_APPLIED_PRICE Price = PRICE_CLOSE; // Price type
input bool use_ha = true; // Use HA prices
input int Length = 14;          //
input double Sigma = 6.0;       //Sigma parameter
input double Offset = 0.85;     //Offset of Gaussian distribution (0...1)
input double DampingFactor = 1; //0...1.0(ex.0.7)
input double PctFilter = 0;     //Dynamic filter in decimal
input int Shift = 0;            //

double Uptrend[];
double trendColor[];

int draw_begin0;

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

int _indi;
int OnInit(void)
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("hullalmtf");
   IndicatorSetString(INDICATOR_SHORTNAME, "Hull AL MTF");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   int id = 0;
   SetIndexBuffer(id++, Uptrend, INDICATOR_DATA);
   SetIndexBuffer(id++, trendColor, INDICATOR_COLOR_INDEX);
   _indi = iCustom(_Symbol, tf, "hull_al", Price, use_ha, Length, Sigma, Offset, DampingFactor, PctFilter, Shift);
   
   return INIT_SUCCEEDED;//INIT_FAILED
}

void OnDeinit(const int reason)
{
   IndicatorRelease(_indi);
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
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
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(Uptrend, EMPTY_VALUE);
      ArrayInitialize(trendColor, EMPTY_VALUE);
   }
   int first = 1;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int index = pos == rates_total - 1 ? 0 : iBarShift(_Symbol, tf, time[pos]);
      if (index < 0)
      {
         continue;
      }
      double buffer[1];
      if (CopyBuffer(_indi, 0, index, 1, buffer) != 1)
      {
         if (GetLastError() == ERR_INDICATOR_DATA_NOT_FOUND)
         {
            Comment("Failed to load data from indicator");
            return 0;
         }
         continue;
      }
      Uptrend[pos] = buffer[0];
      if (CopyBuffer(_indi, 1, index, 1, buffer) != 1)
      {
         continue;
      }
      trendColor[pos] = buffer[0];
   }
   return rates_total;
}