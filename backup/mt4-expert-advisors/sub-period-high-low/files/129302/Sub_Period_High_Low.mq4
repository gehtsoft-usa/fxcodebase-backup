// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69036

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
//#property indicator_separate_window
#property indicator_buffers 0

input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT; // Timeframe
input color high_color = Red; // High color
input color low_color = Green; // Low color
input color color_label = Gray; // Label color
input int font_size = 12; // Font size
input bool show_text = true; // Show text

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
   IndicatorName = GenerateIndicatorName("Sub Period High/Low");
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

void DrawLine(string id, int pos, double value, color clr, int width, string label)
{
   datetime start_time = iTime(_Symbol, timeframe, pos);
   datetime stop_time = pos == 0 ? iTime(_Symbol, timeframe, pos) + (start_time - iTime(_Symbol, timeframe, pos + 1))
      :  iTime(_Symbol, timeframe, pos - 1);
   ResetLastError();
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TREND, 0, start_time, value, stop_time, value))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, width);
      ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetInteger(0, id, OBJPROP_TIME1, start_time);
   ObjectSetInteger(0, id, OBJPROP_TIME2, stop_time);
   ObjectSetDouble(0, id, OBJPROP_PRICE1, value);
   ObjectSetDouble(0, id, OBJPROP_PRICE2, value);
   
   ResetLastError();
   string labelId = id + "label";
   if (ObjectFind(0, labelId) == -1)
   {
      if (!ObjectCreate(0, labelId, OBJ_TEXT, 0, (start_time + stop_time) / 2, value))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetString(0, labelId, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, labelId, OBJPROP_FONTSIZE, font_size);
      ObjectSetInteger(0, labelId, OBJPROP_COLOR, color_label);
      ObjectSetInteger(0, labelId, OBJPROP_ANCHOR, ANCHOR_UPPER);
   }
   ObjectSetInteger(0, labelId, OBJPROP_TIME, (start_time + stop_time) / 2);
   ObjectSetDouble(0, labelId, OBJPROP_PRICE1, value);
   ObjectSetString(0, labelId, OBJPROP_TEXT, label);
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? iBars(_Symbol, timeframe) - ExtCountedBars - 1 : iBars(_Symbol, timeframe) - 2;
   for (int pos = limit; pos >= 0; --pos)
   {
      datetime start_time = iTime(_Symbol, timeframe, pos);
      double high = iHigh(_Symbol, timeframe, pos);
      DrawLine(IndicatorObjPrefix + TimeToString(start_time) + "H", pos, 
         high, high_color, 1, DoubleToString(high, Digits));

      double low = iLow(_Symbol, timeframe, pos);
      DrawLine(IndicatorObjPrefix + TimeToString(start_time) + "L", pos, 
         low, low_color, 1, DoubleToString(low, Digits));
   } 
   return 0;
}