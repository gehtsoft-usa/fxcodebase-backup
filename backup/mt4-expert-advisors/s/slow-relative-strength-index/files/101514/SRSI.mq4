//+------------------------------------------------------------------+
//|                                                         SRSI.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=8;
extern int Smoothing_Length=5;
extern double Overbought_Level=80.;
extern double Oversold_Level=20.;
extern double Middle_Line=50.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double SRSI[];
double NetChgAvg[], TotChgAvg[];
double SF;

int init()
{
 IndicatorShortName("Slow Relative Strength Index oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,SRSI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,NetChgAvg);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,TotChgAvg);

 SF=1./(0.+Length);
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
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double EMA, EMA1, EMAL;
 double Change;
 double ChgRatio;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   EMA=iMA(NULL, 0, Smoothing_Length, 0, MODE_EMA, Price, pos);
   EMAL=iMA(NULL, 0, Smoothing_Length, 0, MODE_EMA, Price, pos+Length);
   EMA1=iMA(NULL, 0, Smoothing_Length, 0, MODE_EMA, Price, pos+1);
   NetChgAvg[pos]=(EMA-EMA1)*SF;
   TotChgAvg[pos]=MathAbs(EMA-EMA1);
  }
  else
  {
   EMA=iMA(NULL, 0, Smoothing_Length, 0, MODE_EMA, Price, pos);
   EMA1=iMA(NULL, 0, Smoothing_Length, 0, MODE_EMA, Price, pos+1);
   Change=EMA-EMA1;
   
   NetChgAvg[pos]=NetChgAvg[pos+1]+SF*(Change-NetChgAvg[pos+1]);
   TotChgAvg[pos]=TotChgAvg[pos+1]+SF*(MathAbs(Change)-TotChgAvg[pos+1]);
   
   if (TotChgAvg[pos]!=0.)
   {
    ChgRatio=NetChgAvg[pos]/TotChgAvg[pos];
   }
   else
   {
    ChgRatio=0.;
   }
   
   SRSI[pos]=50.*(1.+ChgRatio);
  }
  
  pos--;
 } 
 return(0);
}

