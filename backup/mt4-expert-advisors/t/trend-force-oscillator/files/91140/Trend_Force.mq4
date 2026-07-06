//+------------------------------------------------------------------+
//|                                                  Trend_Force.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 LawnGreen
#property indicator_color2 Yellow
#property indicator_color3 Chocolate
#property indicator_color4 Red

extern int Length=12;
extern int ATR_Length=7;
extern double ATR_Coeff=2;

double TF[], TF_PDN[], TF_NUP[], TF_NDN[];
double MinSt[], MaxSt[];

int init()
{
 IndicatorShortName("Trend force oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,TF);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,TF_PDN);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,TF_NUP);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,TF_NDN);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,MinSt);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,MaxSt);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double Min, Max;
 double ATR;
 pos=limit;
 while(pos>=0)
 {
  Min=Low[iLowest(NULL, 0, MODE_LOW, ATR_Length, pos)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, ATR_Length, pos)];
  ATR=iATR(NULL, 0, ATR_Length, pos);
  MinSt[pos]=Max-ATR_Coeff*ATR;
  MaxSt[pos]=Min+ATR_Coeff*ATR;
  pos--;
 } 
 
 double Up, Dn;
 pos=limit;
 while(pos>=0)
 {
  Up=MinSt[ArrayMaximum(MinSt, Length, pos)];
  Dn=MaxSt[ArrayMinimum(MaxSt, Length, pos)];
  TF[pos]=(Up-Dn)/Point;
  TF_PDN[pos]=EMPTY_VALUE;
  TF_NUP[pos]=EMPTY_VALUE;
  TF_NDN[pos]=EMPTY_VALUE;
  if (TF[pos]>0)
  {
   if (TF[pos]<TF[pos+1])
   {
    TF_PDN[pos]=TF[pos];
   }
  }
  else
  {
   if (TF[pos]>=TF[pos+1])
   {
    TF_NUP[pos]=TF[pos];
   }
   else
   {
    TF_NDN[pos]=TF[pos];
   }
  }
  pos--;
 } 
 
 return(0);
}

