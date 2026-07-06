//+------------------------------------------------------------------+
//|                                                          AMS.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Short_Length=12;
extern int Long_Length=26;
extern int Signal_Length=9;
extern string Method_Str="Method: 0 - Zero line, 1 - Signal line";
extern int Method=0;  // 0 - Zero line, 1 - Signal line
extern int Length=3;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double AMS[];

int init()
{
 IndicatorShortName("Average MACD Swing");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,AMS);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 int Br;
 int i;
 double Sum;
 int CountCross;
 double MACD0, MACD_S0, MACD1, MACD_S1;
 pos=limit;
 while(pos>=0)
 {
  Sum=0.;
  i=pos;
  Br=1;
  CountCross=1;
  while (i<Bars-2 && Br<=Length)
  {
   MACD0=iMACD(NULL, 0, Short_Length, Long_Length, Signal_Length, Price, MODE_MAIN, i);
   MACD1=iMACD(NULL, 0, Short_Length, Long_Length, Signal_Length, Price, MODE_MAIN, i+1);
   if (Method==0)
   {
    MACD_S0=0.;
    MACD_S1=0.;
   }
   else
   {
    MACD_S0=iMACD(NULL, 0, Short_Length, Long_Length, Signal_Length, Price, MODE_SIGNAL, i);
    MACD_S1=iMACD(NULL, 0, Short_Length, Long_Length, Signal_Length, Price, MODE_SIGNAL, i+1);
   } 
   if (MACD1<MACD_S1 && MACD0>MACD_S0)
   {
    Sum=Sum+High[iHighest(NULL, 0, MODE_HIGH, CountCross, i)]-iMA(NULL, 0, 1, 0, MODE_SMA, Price, i);
    CountCross=1;
    Br++;
   }
   if (MACD1>MACD_S1 && MACD0<MACD_S0)
   {
    Sum=Sum-iMA(NULL, 0, 1, 0, MODE_SMA, Price, i)+Low[iLowest(NULL, 0, MODE_LOW, CountCross, i)];
    CountCross=1;
    Br++;
   }
   
   i++;
   CountCross++;
  }
  if (Br!=1)
  {
   AMS[pos]=Sum/(Br-1);
  }
  else
  {
   AMS[pos]=EMPTY_VALUE;
  } 

  pos--;
 } 
 return(0);
}

