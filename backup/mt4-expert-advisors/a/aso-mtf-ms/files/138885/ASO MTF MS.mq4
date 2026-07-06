// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70627

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
#property indicator_color1 RoyalBlue
#property indicator_color2 Red
#property indicator_levelcolor DimGray
#property indicator_width1 1
#property indicator_width2 1
//---- input parameters
input int AsoPeriod=10;
input int Mode=0;
input bool Bulls=true;
input bool Bears=true;
input string symbol = "EURUSD"; // Symbol
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe
//---- buffers
double AsoBufferBulls[];
double AsoBufferBears[];
double TempBufferBulls[];
double TempBufferBears[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   string short_name;
//---- 2 additional buffers used for counting.
   IndicatorBuffers(4);
   SetIndexBuffer(2,TempBufferBulls);
   SetIndexBuffer(3,TempBufferBears);   
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,AsoBufferBulls);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,AsoBufferBears);
//---- level
   SetLevelValue( 0, 50 );   
//---- name for DataWindow and indicator subwindow label
   short_name="ASO("+AsoPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"ASO Bulls");
   SetIndexLabel(1,"ASO Bears");
//----
   SetIndexDrawBegin(0,AsoPeriod);
   SetIndexDrawBegin(1,AsoPeriod);
//----
   return(0);
}
//+------------------------------------------------------------------+
//| Average Sentiment Oscillator                                     |
//+------------------------------------------------------------------+
int start()
{
   int i,counted_bars=IndicatorCounted();
//----
   if(Bars<=AsoPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
   {
      for(i=1;i<=AsoPeriod;i++) AsoBufferBulls[Bars-i]=0.0;
      for(i=1;i<=AsoPeriod;i++) AsoBufferBears[Bars-i]=0.0;
   }
//---- 
   i=Bars-counted_bars-1;
   while(i>=0)
   {
      int index = i == 0 ? 0 : iBarShift(symbol, tf, Time[i]);
      if (index < 0)
      {
         continue;
      }
      if (Bulls) 
      {
         AsoBufferBulls[i] = iCustom(symbol, tf, "ASO", AsoPeriod, Mode, Bulls, Bears, 0, index);
      }
      if (Bears) 
      {
         AsoBufferBears[i] = iCustom(symbol, tf, "ASO", AsoPeriod, Mode, Bulls, Bears, 1, index);
      }
      i--;
   }
   return(0);
}
//+------------------------------------------------------------------+