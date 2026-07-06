// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=62453
//+------------------------------------------------------------------+
//|                                                     SVSI_MTF.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property description "Slow Volume Strenght Index MTF"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 clrYellow
#property indicator_color2 clrRed
#property indicator_color3 clrDodgerBlue

enum e_cycles{ Min_5=1, Min_15=2, Min_30=3, Min_60=4, Min_240=5, Daily=6, Weekly=7, Monthly=8 };

input string Symbol_1 = "EURUSD"; // Symbol
input  e_cycles TimeFrame_1      = Min_15;
input  e_cycles TimeFrame_2      = Min_60;
input  e_cycles TimeFrame_3      = Min_240;
extern int      EMA_Length       = 6;
extern int      Smooth_Length    = 14;
extern double   Overbought_Level = 80.;
extern double   Oversold_Level   = 20.;
extern double   Middle_Line      = 50.;

double SVSI1[], PosVolume1[], NegVolume1[];
double SVSI2[], PosVolume2[], NegVolume2[];
double SVSI3[], PosVolume3[], NegVolume3[];

int init(){
   double temp = iCustom(NULL, 0, "SVSI_MTF", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'SVSI_MTF' indicator");
      return INIT_FAILED;
   }
 IndicatorShortName("Slow Volume Strength Index oscillator MTF");
 IndicatorDigits(Digits);
 IndicatorBuffers(3);
 
 SetIndexStyle(0,DRAW_SECTION);
 SetIndexBuffer(0,SVSI1);
 
 SetIndexStyle(1,DRAW_SECTION);
 SetIndexBuffer(1,SVSI2);
 
 SetIndexStyle(2,DRAW_SECTION);
 SetIndexBuffer(2,SVSI3);
 SetLevelValue(0, Overbought_Level);
 SetLevelValue(1, Oversold_Level);
 SetLevelValue(2, Middle_Line);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   for (int pos = limit; pos >= 0; --pos)
   {
      int index = pos == 0 ? 0 : iBarShift(Symbol_1, _Period, Time[pos]);
      if (index < 0)
         continue;
      SVSI1[pos] = iCustom(Symbol_1, _Period, "SVSI_MTF", TimeFrame_1, TimeFrame_2, TimeFrame_3,
         EMA_Length, Smooth_Length, 0, pos);
      SVSI2[pos] = iCustom(Symbol_1, _Period, "SVSI_MTF", TimeFrame_1, TimeFrame_2, TimeFrame_3,
         EMA_Length, Smooth_Length, 1, pos);
      SVSI3[pos] = iCustom(Symbol_1, _Period, "SVSI_MTF", TimeFrame_1, TimeFrame_2, TimeFrame_3,
         EMA_Length, Smooth_Length, 2, pos);

   } 
   return 0;
}
