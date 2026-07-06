// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68838


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
#property indicator_buffers 0
#property indicator_plots 0

input int x = 100;
input int y = 100;
input ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER; // Corner
input color clr = Red; // Color

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

double out[];

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("vd");
   IndicatorSetString(INDICATOR_SHORTNAME, "Volume Display");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
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
   string id = IndicatorObjPrefix + "idValue";
   if (ObjectFind(0, id) == -1)
   {
      ObjectCreate(0, id, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, id, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, id, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, id, OBJPROP_CORNER, corner);
      ObjectSetString(0, id, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
   }
   ObjectSetString(0, id, OBJPROP_TEXT, "Volume: " + IntegerToString(tick_volume[rates_total - 1]));
   return rates_total;
}