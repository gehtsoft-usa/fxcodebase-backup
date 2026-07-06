
// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69204

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

#property indicator_chart_window
#property indicator_buffers 0

input int days = 14; // Days
input double level1 = 100; // Level 1, %
input color lines_color_1 = Red; // Level 1 color
input double level2 = 50; // Level 2, %
input color lines_color_2 = Green; // Level 2 color
input double level3 = 150; // Level 3, %
input color lines_color_3 = Yellow; // Level 3 color

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

int init()
{
   IndicatorName = GenerateIndicatorName("DailyATRange");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(1);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

void DrawLines(datetime openTime, datetime closeTime, double atrValue, double open, int index, color clr)
{
   ResetLastError();
   string id = IndicatorObjPrefix + TimeToString(openTime) + "highValue" + IntegerToString(index);
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TREND, 0, openTime, open + atrValue, closeTime, open + atrValue))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE1, open + atrValue);
   ObjectSetDouble(0, id, OBJPROP_PRICE2, open + atrValue);

   ResetLastError();
   id = IndicatorObjPrefix + TimeToString(openTime) + "lowValue" + IntegerToString(index);
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TREND, 0, openTime, open - atrValue, closeTime, open - atrValue))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE1, open - atrValue);
   ObjectSetDouble(0, id, OBJPROP_PRICE2, open - atrValue);
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars - 1;
   for (int i = limit; i >= 0; i--)
   {
      int index = iBarShift(_Symbol, PERIOD_D1, Time[i]);
      if (index < 0)
      {
         continue;
      }
      double atrValue = iATR(_Symbol, PERIOD_D1, days, index);
      double open = iOpen(_Symbol, PERIOD_D1, index);
      datetime openTime = iTime(_Symbol, PERIOD_D1, index);
      datetime closeTime = openTime + 86400;
      DrawLines(openTime, closeTime, atrValue * level1 / 100, open, 1, lines_color_1);
      DrawLines(openTime, closeTime, atrValue * level2 / 100, open, 2, lines_color_2);
      DrawLines(openTime, closeTime, atrValue * level3 / 100, open, 3, lines_color_3);
   }
   return 0;
}
