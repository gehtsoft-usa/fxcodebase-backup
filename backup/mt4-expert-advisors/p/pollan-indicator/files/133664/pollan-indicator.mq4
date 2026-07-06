// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69815

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
#property indicator_buffers 2
#property indicator_color1 LimeGreen
#property indicator_color2 Red
//---- input parameters
extern int CountBars=1000;//70000
extern int nPeriod=15;
extern int CCI1Period=15;
extern int CCI2Period=20;
extern int RSI1Period=15;
extern int RSI2Period=20;

//---- buffers
double value[];
double value2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(0,value);
   SetIndexBuffer(1,value2);

   SetIndexDrawBegin(0,Bars-CountBars+nPeriod+1);
   SetIndexDrawBegin(1,Bars-CountBars+nPeriod+1);
   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
{
   int minBars = nPeriod;
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      value[i] = CalcVal(i, CCI1Period, 0, RSI1Period, 0);
      value2[i] = CalcVal(i, CCI2Period, 0, RSI2Period, 0);
   }

   return(0);
}

double CalcVal(int i, int vCCIPeriod=0, int vCCIPrice=0, int vRSIPeriod=0, int vRSIPrice=0)
{
   double cci = iCCI(Symbol(), 0, vCCIPeriod, vCCIPrice, i + 1) / 100;
   double rsi = iRSI(Symbol(), 0, vRSIPeriod, vRSIPrice, i + 1) / 100;
   double prev = (cci - rsi);
   double l = prev;
   double h = prev;
   for (int pix = 1; pix <= nPeriod - 1; pix++)
   {
      cci = iCCI(Symbol(), 0, vCCIPeriod, vCCIPrice, i + pix + 1) / 100;
      rsi = iRSI(Symbol(), 0, vRSIPeriod, vRSIPrice, i + pix + 1) / 100;
      prev = (cci - rsi) + prev;  
      if (prev > h)
      {
         h = prev;
      }
      if (prev < l)
      {
         l = prev;
      }
   }
   return l + h;
}

