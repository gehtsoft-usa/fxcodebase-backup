//+------------------------------------------------------------------+
//|                                                         RIND.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=3;
extern int Smooth=10;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double RIND[];
double stochRange[], val1[];

int init()
{
 IndicatorShortName("Range Indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,RIND);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,stochRange);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,val1);

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
 double trueRange;
 pos=limit;
 while(pos>=0)
 {
  trueRange=MathMax(High[pos], Close[pos+1])-MathMin(Low[pos], Close[pos+1]);
  if (Close[pos]>Close[pos+1])
  {
   val1[pos]=trueRange/(Close[pos]-Close[pos+1]);
  }
  else
  {
   val1[pos]=trueRange;
  }

  pos--;
 } 
 
 double valMin, valMax;
 pos=limit;
 while(pos>=0)
 {
  valMin=val1[ArrayMinimum(val1, Length, pos)];
  valMax=val1[ArrayMaximum(val1, Length, pos)];
  if (valMax-valMin>0.)
  {
   stochRange[pos]=100.*(val1[pos]-valMin)/(valMax-valMin);
  }
  else
  {
   stochRange[pos]=100.*(val1[pos]-valMin);
  }

  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  RIND[pos]=iMAOnArray(stochRange, 0, Smooth, 0, Method, pos);

  pos--;
 }  
   
 return(0);
}

