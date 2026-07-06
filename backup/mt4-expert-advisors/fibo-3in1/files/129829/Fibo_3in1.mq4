// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69142

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

input double level1 = 0; // Level 1
input double level2 = 0.236; // Level 2
input double level3 = 0.382; // Level 3
input double level4 = 0.5; // Level 4
input double level5 = 0.618; // Level 5
input double level6 = 0.764; // Level 6
input double level7 = 1; // Level 7
input bool invert = false; // Invert
input bool show_monthly = true; // Show monthly
input bool show_weekly = true; // Show weekly
input bool show_daily = true; // Show daily
input color level1_color = Red; // Level 1 color
input color level2_color = Red; // Level 2 color
input color level3_color = Red; // Level 3 color
input color level4_color = Red; // Level 4 color
input color level5_color = Red; // Level 5 color
input color level6_color = Red; // Level 6 color
input color level7_color = Red; // Level 7 color

string IndicatorName;
string IndicatorObjPrefix;
string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}
int OnInit(void)
{
   IndicatorName = GenerateIndicatorName("Fibo 3 in 1");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   return INIT_SUCCEEDED;//INIT_FAILED
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

void DrawLine(string id, datetime start, double high, double low, double level, color clr)
{
   double value = invert ? high - (high - low) * level : low + (high - low) * level;
   ResetLastError();
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TREND, 0, start, value, Time[0], value))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetInteger(0, id, OBJPROP_TIME2, Time[0]);
   ObjectSetDouble(0, id, OBJPROP_PRICE1, value);
   ObjectSetDouble(0, id, OBJPROP_PRICE2, value);
}

void DrawFib(ENUM_TIMEFRAMES timeframe)
{
   datetime startTime = iTime(_Symbol, timeframe, 1);
   int index = iBarShift(_Symbol, _Period, startTime);
   if (index < 0)
      return;

   int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, index, 0);
   double highest = iHigh(_Symbol, _Period, highestIndex);
   int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, index, 0);
   double lowest = iLow(_Symbol, _Period, lowestIndex);
   DrawLine(IndicatorObjPrefix + "idValue1_" + IntegerToString(timeframe), startTime, highest, lowest, level1, level1_color);
   DrawLine(IndicatorObjPrefix + "idValue2_" + IntegerToString(timeframe), startTime, highest, lowest, level2, level2_color);
   DrawLine(IndicatorObjPrefix + "idValue3_" + IntegerToString(timeframe), startTime, highest, lowest, level3, level3_color);
   DrawLine(IndicatorObjPrefix + "idValue4_" + IntegerToString(timeframe), startTime, highest, lowest, level4, level4_color);
   DrawLine(IndicatorObjPrefix + "idValue5_" + IntegerToString(timeframe), startTime, highest, lowest, level5, level5_color);
   DrawLine(IndicatorObjPrefix + "idValue6_" + IntegerToString(timeframe), startTime, highest, lowest, level6, level6_color);
   DrawLine(IndicatorObjPrefix + "idValue7_" + IntegerToString(timeframe), startTime, highest, lowest, level7, level7_color);
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
   if (show_monthly)
      DrawFib(PERIOD_MN1);
   if (show_weekly)
      DrawFib(PERIOD_W1);
   if (show_daily)
      DrawFib(PERIOD_D1);
   return rates_total;
}