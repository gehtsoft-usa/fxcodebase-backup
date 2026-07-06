// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69433
// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69433

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

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red

input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
input int lb = 5; // Left Bars
input int rb = 5; // Right Bars
input bool shownum = true; // Show Divergence Number
input bool showpivot = false; // Show Pivot Points
input bool calcmacd = true; // MACD
input bool calcmacda = true; // MACD Histogram
input bool calcrsi = true; // RSI
input bool calcstoc = true; // Stochastic
input bool calccci = true; // CCI
input bool calcmom = true; // Momentum
input bool calcobv = true; // OBV
input bool calccmf = true; // Chaikin Money Flow

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

double closeChange[], volume[], Cmfm[], lastHigh[], obv[], lastLow[], Cmfv[];

int init()
{
   IndicatorName = GenerateIndicatorName("Divergence for many indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(7);
   int id = 0;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, closeChange);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, Cmfm);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, volume);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, lastHigh);
   SetIndexEmptyValue(id, 0);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, lastLow);
   SetIndexEmptyValue(id, 0);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, obv);
   SetIndexEmptyValue(id, 0);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, Cmfv);
   SetIndexEmptyValue(id, 0);
   ++id;

   double temp = iCustom(NULL, 0, "Divergence for many oscillator", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Divergence for many oscillator' indicator");
      return INIT_FAILED;
   }

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

void ProcessUp(int i)
{
   double negdivergence = iCustom(_Symbol, tf, "Divergence for many oscillator", lb, rb, false, false, false, calcmacd, calcmacda, calcrsi, calcstoc, calccci, calcmom, calcobv, calccmf, 1, i);
   if (negdivergence <= 0)
   {
      return;
   }
   double lastHighIndex = iCustom(_Symbol, tf, "Divergence for many oscillator", lb, rb, false, false, false, calcmacd, calcmacda, calcrsi, calcstoc, calccci, calcmom, calcobv, calccmf, 5, i) + i;
   datetime timeI = iTime(_Symbol, tf, i);
   datetime timeLastI = iTime(_Symbol, tf, (int)lastHighIndex);
   double highI = iHigh(_Symbol, tf, i);
   double lastHighI = iHigh(_Symbol, tf, (int)lastHighIndex);
   ResetLastError();
   string trend = IndicatorObjPrefix + TimeToString(timeI) + "uptrendidValue";
   if (ObjectFind(0, trend) == -1)
   {
      if (!ObjectCreate(0, trend, OBJ_TREND, 0, timeLastI, lastHighI, timeI, highI))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, trend, OBJPROP_COLOR, Red);
      ObjectSetInteger(0, trend, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, trend, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, trend, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetDouble(0, trend, OBJPROP_PRICE1, lastHighI);
   ObjectSetDouble(0, trend, OBJPROP_PRICE2, highI);
   ObjectSetInteger(0, trend, OBJPROP_TIME1, timeLastI);
   ObjectSetInteger(0, trend, OBJPROP_TIME2, timeI);
   if (shownum)
   {
      string txt = "";
      txt = txt + (shownum ? IntegerToString(negdivergence) : "");
      ResetLastError();
      string id = IndicatorObjPrefix + TimeToString(timeI) + "upLabelidValue";
      if (ObjectFind(0, id) == -1)
      {
         if (!ObjectCreate(0, id, OBJ_TEXT, 0, timeI, highI))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            return ;
         }
         ObjectSetString(0, id, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 10);
         ObjectSetInteger(0, id, OBJPROP_COLOR, White);
         ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LOWER);
      }
      ObjectSetInteger(0, id, OBJPROP_TIME, timeI);
      ObjectSetDouble(0, id, OBJPROP_PRICE1, highI);
      ObjectSetString(0, id, OBJPROP_TEXT, txt);
   }
}

void ProcessDown(int i)
{
   double posdivergence = iCustom(_Symbol, tf, "Divergence for many oscillator", lb, rb, false, false, false, calcmacd, calcmacda, calcrsi, calcstoc, calccci, calcmom, calcobv, calccmf, 0, i);
   if (posdivergence <= 0)
   {
      return;
   }
   double lastLowIndex = iCustom(_Symbol, tf, "Divergence for many oscillator", lb, rb, false, false, false, calcmacd, calcmacda, calcrsi, calcstoc, calccci, calcmom, calcobv, calccmf, 6, i) + i;
   datetime timeI = iTime(_Symbol, tf, i);
   datetime timeLastI = iTime(_Symbol, tf, (int)lastLowIndex);
   double lowI = iLow(_Symbol, tf, i);
   double lastLowI = iLow(_Symbol, tf, (int)lastLowIndex);
   ResetLastError();
   string trend = IndicatorObjPrefix + TimeToString(timeI) + "dnidValue";
   if (ObjectFind(0, trend) == -1)
   {
      if (!ObjectCreate(0, trend, OBJ_TREND, 0, timeLastI, lastLowI, timeI, lowI))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, trend, OBJPROP_COLOR, Lime);
      ObjectSetInteger(0, trend, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, trend, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, trend, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetDouble(0, trend, OBJPROP_PRICE1, lastLowI);
   ObjectSetDouble(0, trend, OBJPROP_PRICE2, lowI);
   ObjectSetInteger(0, trend, OBJPROP_TIME1, timeLastI);
   ObjectSetInteger(0, trend, OBJPROP_TIME2, timeI);
   if (shownum)
   {
      string txt = "";
      txt = txt + (shownum ? IntegerToString(posdivergence) : "");
      ResetLastError();
      string id = IndicatorObjPrefix + TimeToString(timeI) + "dnlidValue";
      if (ObjectFind(0, id) == -1)
      {
         if (!ObjectCreate(0, id, OBJ_TEXT, 0, timeI, lowI))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            return ;
         }
         ObjectSetString(0, id, OBJPROP_FONT, "Arial");
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 10);
         ObjectSetInteger(0, id, OBJPROP_COLOR, White);
         ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_UPPER);
      }
      ObjectSetInteger(0, id, OBJPROP_TIME, timeI);
      ObjectSetDouble(0, id, OBJPROP_PRICE1, lowI);
      ObjectSetString(0, id, OBJPROP_TEXT, txt);
   }
}


int start()
{
   int counted_bars = IndicatorCounted();
   datetime lastDate = Time[Bars - 1 - counted_bars];
   int counted_bars_btf = iBars(_Symbol, tf) - iBarShift(_Symbol, tf, lastDate) - 1;

   int minBars = lb + rb + 1;
   int limit = MathMin(iBars(_Symbol, tf) - 1 - minBars, iBars(_Symbol, tf) - counted_bars_btf - 1);
   for (int i = limit; i >= 0; i--)
   {
      ProcessUp(i);
      ProcessDown(i);
   }
   return 0;
}
