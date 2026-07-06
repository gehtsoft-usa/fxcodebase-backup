// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67213

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window

extern ENUM_TIMEFRAMES TF = PERIOD_D1; // Timeframe
extern int N = 14; // ADR Periods
extern double Multiplier = 0.5; // Multiplier
extern color LevelsColor = clrRed; // Levels color

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

double _pipSize;

int init()
{
   IndicatorName = GenerateIndicatorName("Average Daily Range");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);

   double _point = MarketInfo(_Symbol, MODE_POINT);
   double _digits = (int)MarketInfo(_Symbol, MODE_DIGITS); 
   double _mult = _digits == 3 || _digits == 5 ? 10 : 1;
   _pipSize = _point * _mult;
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

double CalcADR()
{
   double summ = 0;
   for (int i = 0; i < N; ++i)
   {
      summ += iHigh(NULL, TF, i) - iLow(NULL, TF, i);
   }

   return summ / N;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = Bars - 1;
   if(ExtCountedBars > 1) 
      limit = Bars - ExtCountedBars - 1;
   
   double adr = CalcADR();
   datetime startDate = iTime(NULL, TF, 0);
   int start = iBarShift(NULL, 0, startDate);
   if (start < 0)
      return 0;

   double max = Open[0] + adr * Multiplier;
   double min = Open[0] - adr * Multiplier;
   double distance = (max - min) / _pipSize;
   double distanceToMax = (max - Close[0]) / _pipSize;
   double distanceToMin = (Close[0] - min) / _pipSize;
   datetime endDate = startDate + (startDate - iTime(NULL, TF, 1));

   ObjectDelete(IndicatorObjPrefix + "H");
   ObjectCreate(IndicatorObjPrefix + "H", OBJ_TREND, 0, startDate, max, endDate, max);
   ObjectSetInteger(0, IndicatorObjPrefix + "H", OBJPROP_RAY_RIGHT, false);
   ObjectSet(IndicatorObjPrefix + "H", OBJPROP_COLOR, LevelsColor);
   
   string maxLabel = "ADR: " + DoubleToStr(distance, 1) + "; Remaining: " + DoubleToStr(distanceToMax, 1);
   ObjectDelete(IndicatorObjPrefix + "HL");
   ObjectCreate(0, IndicatorObjPrefix + "HL", OBJ_TEXT, 0, startDate, max);
   ObjectSetString(0, IndicatorObjPrefix + "HL", OBJPROP_TEXT, maxLabel);
   ObjectSetInteger(0, IndicatorObjPrefix + "HL", OBJPROP_COLOR, LevelsColor);
   ObjectSetInteger(0, IndicatorObjPrefix + "HL", OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER); 
   
   ObjectDelete(IndicatorObjPrefix + "L");
   ObjectCreate(IndicatorObjPrefix + "L", OBJ_TREND, 0, startDate, min, endDate, min);
   ObjectSetInteger(0, IndicatorObjPrefix + "L", OBJPROP_RAY_RIGHT, false);
   ObjectSet(IndicatorObjPrefix + "L", OBJPROP_COLOR, LevelsColor);
   
   string minLabel = "Remaining: " + DoubleToStr(distanceToMin, 1);
   ObjectDelete(IndicatorObjPrefix + "LL");
   ObjectCreate(0, IndicatorObjPrefix + "LL", OBJ_TEXT, 0, startDate, min);
   ObjectSetString(0, IndicatorObjPrefix + "LL", OBJPROP_TEXT, minLabel);
   ObjectSetInteger(0, IndicatorObjPrefix + "LL", OBJPROP_COLOR, LevelsColor);
   ObjectSetInteger(0, IndicatorObjPrefix + "LL", OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER); 
   
   return 0;
}