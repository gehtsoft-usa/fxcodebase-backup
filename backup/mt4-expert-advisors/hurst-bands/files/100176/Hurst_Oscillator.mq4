//+------------------------------------------------------------------+
//|                                             Hurst_Oscillator.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=10;
extern int Smooth=1;

double HO[];
double FlowValue[], CMA[];
int displacement;

int init()
{
 IndicatorShortName("Hurst oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,HO);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,FlowValue);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,CMA);
 
 displacement=Length/2.+1.;

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
 pos=limit;
 while(pos>=0)
 {
  CMA[pos]=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_MEDIAN, pos+displacement);
  
  if (Close[pos]>Close[pos+1])
  {
   FlowValue[pos]=High[pos];
  }
  else
  {
   if (Close[pos]<Close[pos+1])
   {
    FlowValue[pos]=Low[pos];
   }
   else
   {
    FlowValue[pos]=(High[pos]+Low[pos])/2.;
   }
  }

  pos--;
 } 
 
 double MA;
 pos=limit;
 while(pos>=0)
 {
  MA=iMAOnArray(FlowValue, 0, Smooth, 0, MODE_SMA, pos);
  
  HO[pos]=(MA-CMA[pos])/Point;

  pos--;
 }
   
 return(0);
}

