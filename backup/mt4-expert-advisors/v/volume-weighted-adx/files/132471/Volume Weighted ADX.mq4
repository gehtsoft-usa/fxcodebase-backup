// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69604

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

input int TP = 14; // Time Periods

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Green

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

double vadx[], vdmip[], vdmim[];

int init()
{
   IndicatorName = GenerateIndicatorName("Volume Weighted ADX");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(3);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, vadx);
   SetIndexLabel(0, "VADX");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, vdmip);
   SetIndexLabel(1, "VDMI+");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, vdmim);
   SetIndexLabel(2, "VDMI-");

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int minBars = TP;
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      double adx = 0;
      double dmip = 0;
      double dmim = 0;
      double vol = 0;
      for (int ii = 0; ii < TP; ++ii)
      {
         adx += iADX(_Symbol, _Period, TP, PRICE_CLOSE, MODE_MAIN, i + ii) * Volume[i + ii];
         dmip += iADX(_Symbol, _Period, TP, PRICE_CLOSE, MODE_PLUSDI, i+ ii) * Volume[i + ii];
         dmim += iADX(_Symbol, _Period, TP, PRICE_CLOSE, MODE_MINUSDI, i + ii) * Volume[i + ii];
         vol += Volume[i + ii];
      }
      vadx[i] = adx / vol;
      vdmip[i] = dmip / vol;
      vdmim[i] = dmim / vol;
   }
   return 0;
}


