// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70752

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

input string format = "{symbol} ({timeframe})"; // Format
input int font_size = 20; // Font size
input color font_color = Gray; // Font color
input int x = 50; // X
input int y = 100; // Y

input string format2 = "{date}"; // Format
input int font_size2 = 20; // Font size
input color font_color2 = Gray; // Font color
input int x2 = 50; // X
input int y2 = 140; // Y

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
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

string TimeframeToString(ENUM_TIMEFRAMES tf)
{
   switch (tf)
   {
      case PERIOD_M1: return "M1";
      case PERIOD_M5: return "M5";
      case PERIOD_D1: return "D1";
      case PERIOD_H1: return "H1";
      case PERIOD_H4: return "H4";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_MN1: return "MN1";
      case PERIOD_W1: return "W1";
   }
   return "";
}

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("wm");
   IndicatorShortName("Watermark");

   IndicatorBuffers(1);

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

void Draw(string id, string text, int fontSize, color fontColor, int X, int Y)
{
   ResetLastError();
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_LABEL, 0, 0, 0))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, id, OBJPROP_XDISTANCE, X);
      ObjectSetInteger(0, id, OBJPROP_YDISTANCE, Y);
      ObjectSetInteger(0, id, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetString(0, id, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, id, OBJPROP_FONTSIZE, fontSize);
      ObjectSetInteger(0, id, OBJPROP_COLOR, fontColor);
      ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, id, OBJPROP_BACK, true);
   }
   StringReplace(text, "{symbol}", _Symbol);
   StringReplace(text, "{timeframe}", TimeframeToString((ENUM_TIMEFRAMES)_Period));
   string date = TimeToString(Time[0]);
   StringReplace(text, "{date}", date);
   ObjectSetString(0, id, OBJPROP_TEXT, text);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   Draw(IndicatorObjPrefix + "idValue1", format, font_size, font_color, x, y);
   Draw(IndicatorObjPrefix + "idValue2", format2, font_size2, font_color2, x2, y2);
   return rates_total;
}
