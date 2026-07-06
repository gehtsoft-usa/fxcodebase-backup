// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69641
// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69641

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

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_levelcolor Peru
#property indicator_level1 30
#property indicator_level2 70

extern int RSI_Period = 21, RSI_Period2 = 8;
extern bool Alarm = true;               
double RSIBuffer[], RSI2Buffer[];
double SignalBuffer[];
 
#define SIGNAL_BAR 1               
               
int init()
{
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);

   SetIndexBuffer(0, RSIBuffer);
   SetIndexBuffer(1, RSI2Buffer);
   
   SetIndexLabel(0, "RSI");
   SetIndexLabel(1, "RSI 2");

   return(0);
}

int deinit()
{
   return(0);
}

bool IsPositionExist()
{
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if (OrderSymbol() == _Symbol)
         {
            return true;
         }
      }
   }
   return false;
}

bool HaveAnotherCross(int period)
{
   for (int i = period; i < Bars - 2; ++i)
   {
      if (RSIBuffer[i] - RSI2Buffer[i] > 0 && RSI2Buffer[i + 1] - RSIBuffer[i + 1] >= 0)
      {
         return true;
      }
      if (RSI2Buffer[i] - RSIBuffer[i] > 0 && RSIBuffer[i + 1] - RSI2Buffer[i + 1] >= 0)
      {
         return true;
      }
      if (RSIBuffer[i] > 70 || RSIBuffer[i] < 30)
      {
         return false;
      }
   }
   return false;
}

int start()
{
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) counted_bars=0;
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
  
   for (int i = 0 ;i < limit; i++)
   {
      RSIBuffer[i] = iRSI(Symbol(),0,RSI_Period,PRICE_CLOSE,i);
   }
   for (int x = 0; x < ArraySize(RSIBuffer); x++)
   {
      RSI2Buffer[x] = iRSI(Symbol(),0,RSI_Period2,PRICE_CLOSE,x);
   }

   if (Alarm == true && !IsPositionExist())
   {
      static int PrevSignal = 0, PrevTime = 0;
      if(SIGNAL_BAR > 0 && Time[0] <= PrevTime)
      {
         return(0);
      }
      PrevTime = Time[0];
      if(PrevSignal <= 0)
      {
         if (RSIBuffer[SIGNAL_BAR] - RSI2Buffer[SIGNAL_BAR] > 0 
            && RSI2Buffer[SIGNAL_BAR + 1] - RSIBuffer[SIGNAL_BAR + 1] >= 0 
            && RSIBuffer[SIGNAL_BAR] > 70
            && !HaveAnotherCross(SIGNAL_BAR + 1))
         {
            PrevSignal = 1;
            Alert("Fast RSI crossed Slow RSI to DOWN (", Symbol(), ", ", Period(), ")  -  SELL!!!");
         }
      }
      if (PrevSignal >= 0)
      {
         if (RSI2Buffer[SIGNAL_BAR] - RSIBuffer[SIGNAL_BAR] > 0 
            && RSIBuffer[SIGNAL_BAR + 1] - RSI2Buffer[SIGNAL_BAR + 1] >= 0 
            && RSIBuffer[SIGNAL_BAR] < 30
            && !HaveAnotherCross(SIGNAL_BAR + 1))
         {
            PrevSignal = -1;
            Alert("Fast RSI crossed Slow RSI to UP (", Symbol(), ", ", Period(), ")  -  BUY!!!");
         }
      }
   }
   return(0);
}