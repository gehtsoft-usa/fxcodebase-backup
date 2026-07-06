
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69402


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

input ENUM_TIMEFRAMES BTF = PERIOD_D1;
input int DOJI = 10; // Max. Doji Body Lengt
input color UP_Color = Green; // Color for UP
input color DOWN_Color = Red; // Color for DOWN
input color DOJI_Color = Gray; // Color for Doji

double pipSize;

string IndicatorName;
string IndicatorObjPrefix;
string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}
int OnInit(void)
{
   IndicatorName = GenerateIndicatorName("Bigger TF Candle");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digit = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int mult = digit == 3 || digit == 5 ? 10 : 1;
   pipSize = point * mult;

   return INIT_SUCCEEDED;//INIT_FAILED
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
   for (int pos = prev_calculated; pos < rates_total; ++pos)
   {
      int index = iBarShift(_Symbol, BTF, time[pos]);
      if (index >= 0)
      {
         datetime baseTime = iTime(_Symbol, BTF, index);
         string timeStr = TimeToString(baseTime);
         string bodyId = IndicatorObjPrefix + timeStr + "body";
         double open = iOpen(_Symbol, BTF, index);
         double high = iHigh(_Symbol, BTF, index);
         double low = iLow(_Symbol, BTF, index);
         double close = iClose(_Symbol, BTF, index);
         bool isDoji = (MathAbs(open - close) / pipSize) < DOJI;
         color clr = isDoji ? DOJI_Color : (open > close ? DOWN_Color : UP_Color);

         string id = IndicatorObjPrefix + TimeToString(baseTime) + "rect1";
         if (ObjectFind(0, id) == -1)
         {
            if (ObjectCreate(0, id, OBJ_RECTANGLE, 0, baseTime, open, time[pos], close))
            {
               ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
               ObjectSetInteger(0, id, OBJPROP_FILL, true);
            }
         }
         ObjectSetInteger(0, id, OBJPROP_TIME, 0, baseTime);
         ObjectSetDouble(0, id, OBJPROP_PRICE, 0, open);
         ObjectSetInteger(0, id, OBJPROP_TIME, 1, time[pos]);
         ObjectSetDouble(0, id, OBJPROP_PRICE, 1, close);

         datetime center = (baseTime + time[pos]) / 2;
         string upTrendId = IndicatorObjPrefix + TimeToString(baseTime) + "upTrend";
         if (ObjectFind(0, upTrendId) == -1)
         {
            if (ObjectCreate(0, upTrendId, OBJ_TREND, 0, center, MathMax(open, close), center, high))
            {
               ObjectSetInteger(0, upTrendId, OBJPROP_COLOR, clr);
               ObjectSetInteger(0, upTrendId, OBJPROP_WIDTH, 5);
               ObjectSetInteger(0, upTrendId, OBJPROP_RAY_LEFT, false);
               ObjectSetInteger(0, upTrendId, OBJPROP_RAY_RIGHT, false);
            }
         }
         ObjectSetInteger(0, upTrendId, OBJPROP_TIME, 0, center);
         ObjectSetDouble(0, upTrendId, OBJPROP_PRICE, 0, MathMax(open, close));
         ObjectSetInteger(0, upTrendId, OBJPROP_TIME, 1, center);
         ObjectSetDouble(0, upTrendId, OBJPROP_PRICE, 1, high);

         string donwTrendId = IndicatorObjPrefix + TimeToString(baseTime) + "downId";
         if (ObjectFind(0, donwTrendId) == -1)
         {
            if (ObjectCreate(0, donwTrendId, OBJ_TREND, 0, center, MathMin(open, close), center, low))
            {
               ObjectSetInteger(0, donwTrendId, OBJPROP_COLOR, clr);
               ObjectSetInteger(0, donwTrendId, OBJPROP_WIDTH, 5);
               ObjectSetInteger(0, donwTrendId, OBJPROP_RAY_LEFT, false);
               ObjectSetInteger(0, donwTrendId, OBJPROP_RAY_RIGHT, false);
            }
         }
         ObjectSetInteger(0, donwTrendId, OBJPROP_TIME, 0, center);
         ObjectSetDouble(0, donwTrendId, OBJPROP_PRICE, 0, MathMin(open, close));
         ObjectSetInteger(0, donwTrendId, OBJPROP_TIME, 1, center);
         ObjectSetDouble(0, donwTrendId, OBJPROP_PRICE, 1, low);
      }
   }
   return rates_total;
}