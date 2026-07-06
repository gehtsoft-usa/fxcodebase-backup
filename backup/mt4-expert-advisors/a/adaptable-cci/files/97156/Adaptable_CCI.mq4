//+------------------------------------------------------------------+
//|                                                Adaptable_CCI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Average_Length=14;
extern int Deviation_Length=14;
extern double Correction_Factor=0.015;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted
extern double Overbought_Level=100.;
extern double Oversold_Level=-100.;

double ACCI[];

int init()
{
 IndicatorShortName("Adaptable CCI oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ACCI);
 
 SetLevelValue(0, Overbought_Level);
 SetLevelValue(1, Oversold_Level);

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
 double mean;
 double Avg;
 double Sum;
 double Pr;
 double meandev;
 int i;
 pos=limit;
 while(pos>=0)
 {
  mean=iMA(NULL, 0, Average_Length, 0, Method, Price, pos);
  Avg=iMA(NULL, 0, Deviation_Length, 0, MODE_SMA, Price, pos);
  Sum=0.;
  for (i=0;i<Deviation_Length;i++)
  {
   Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+i);
   Sum=Sum+MathAbs(Pr-Avg);
  }
  meandev=Sum/Deviation_Length;
  
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  if (meandev==0.)
  {
   ACCI[pos]=0.;
  }
  else
  {
   ACCI[pos]=(Pr-mean)/(meandev*Correction_Factor);
  }

  pos--;
 } 
 return(0);
}

