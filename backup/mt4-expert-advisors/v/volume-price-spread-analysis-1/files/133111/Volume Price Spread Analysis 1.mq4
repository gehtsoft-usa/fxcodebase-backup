// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69722

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

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_label1  "Open"
#property indicator_type1   DRAW_LINE
#property indicator_color1  DarkOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_label2  "Close"
#property indicator_type2   DRAW_LINE
#property indicator_color2  DarkOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
#property indicator_label3  "High"
#property indicator_type3   DRAW_LINE
#property indicator_color3  DarkOrange
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
#property indicator_label4  "Low"
#property indicator_type4   DRAW_LINE
#property indicator_color4  DarkOrange
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

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

double o[], h[], l[], c[], volumex[];
int init()
{
   IndicatorName = GenerateIndicatorName("Volume Price Spread Analysis 1");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(5);

   SetIndexBuffer(0, o);
   SetIndexBuffer(1, c);
   SetIndexBuffer(2, h);
   SetIndexBuffer(3, l);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, volumex);

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      volumex[i] = MathLog(Volume[i]);
      if (c[i + 1] != EMPTY_VALUE)
      {
         c[i] = ((Close[i] * volumex[i]) + (High[i] * volumex[i]) + (Low[i] * volumex[i]) + c[i + 1]) * 0.25;
         o[i] = (c[i + 1] + (Open[i] * volumex[i])) * 0.5;
      }
      else
      {
         c[i] = ((Close[i] * volumex[i]) + (High[i] * volumex[i]) + (Low[i] * volumex[i]) + (((Close[i + 1] * volumex[i + 1]) + (Open[i] * volumex[i])) * 0.5)) * 0.25;
         o[i] = (c[i] + (Open[i] * volumex[i])) * 0.5;
      }
      h[i] = MathMax(MathMax(High[i] * volumex[i], c[i]), o[i]);
      l[i] = MathMin(MathMin(Low[i] * volumex[i], c[i]), o[i]);
   }
   return 0;
}
