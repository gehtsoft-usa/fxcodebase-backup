// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69391

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

input double gap = 0.03; // VWAP Gap %
input color rColor = Purple; // Level Color
input ENUM_LINE_STYLE rStyle = STYLE_SOLID; // Level Style
input int rWidth = 2; // Level Width

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

double wp[], vwap[], vol[];

int init()
{
   IndicatorName = GenerateIndicatorName("VWAP Gap Level");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(3);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, vwap);
   SetIndexLabel(0, "VWAP");

   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, wp);

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, vol);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = MathMax(1, MathMin(Bars - 1 - 0, Bars - counted_bars - 1));
   for (int i = limit; i >= 0; i--)
   {
      if (i == Bars - 1)
      {
         wp[i] = Volume[i] * (High[i] + Low[i] + Close[i]) / 3;
         vol[i] = Volume[i];
      }
      else
      {
         wp[i] = wp[i + 1] + Volume[i] * (High[i] + Low[i] + Close[i]) / 3;
         vol[i] = vol[i + 1] + Volume[i];
      }
      vwap[i] = wp[i] / vol[i];

      if (i < Bars - 2 && i != 0)
      {
         if ((MathAbs(vwap[i] - vwap[i + 1]) / vwap[i + 1]) * 100 > gap)
         {
            ResetLastError();
            string id = IndicatorObjPrefix + TimeToString(Time[i]) + "idValue";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[i], vwap[i + 1], Time[0], vwap[i + 1]))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
                  continue;
               }
               ObjectSetInteger(0, id, OBJPROP_COLOR, rColor);
               ObjectSetInteger(0, id, OBJPROP_STYLE, rStyle);
               ObjectSetInteger(0, id, OBJPROP_WIDTH, rWidth);
               ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, true);
            }
            ObjectSetDouble(0, id, OBJPROP_PRICE1, vwap[i + 1]);
            ObjectSetDouble(0, id, OBJPROP_PRICE2, vwap[i + 1]);
            ObjectSetInteger(0, id, OBJPROP_TIME1, Time[i]);
            ObjectSetInteger(0, id, OBJPROP_TIME2, Time[0]);
         }
      }
   }
   return 0;
}
