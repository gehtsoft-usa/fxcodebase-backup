//+------------------------------------------------------------------+
//|                                                        Power.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Length=14;
extern int Lookback_Length=14;

double Peaks[], Valleys[], Power[];
double Bulls[], Bears[];

int init()
{
 IndicatorShortName("Power oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Peaks);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Valleys);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Power);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Bulls);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Bears);

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
 double EMA;
 pos=limit;
 while(pos>=0)
 {
  EMA=iMA(NULL, 0, Length, 0, MODE_EMA, PRICE_CLOSE, pos);
  if (High[pos]>EMA)
  {
   Bulls[pos]=1.;
  }
  else
  {
   Bulls[pos]=0.;
  } 
  if (Low[pos]<EMA)
  {
   Bears[pos]=1.;
  }
  else
  {
   Bears[pos]=0.;
  } 

  pos--;
 } 
 
 double BullAvg, BearAvg;
 pos=limit;
 while(pos>=0)
 {
  BullAvg=iMAOnArray(Bulls, 0, Lookback_Length, 0, MODE_SMA, pos);
  BearAvg=iMAOnArray(Bears, 0, Lookback_Length, 0, MODE_SMA, pos);
  
  Power[pos]=100.*MathAbs(BullAvg-BearAvg);
  Peaks[pos]=100.*BearAvg;
  Valleys[pos]=100.*BullAvg;

  pos--;
 }
   
 return(0);
}

