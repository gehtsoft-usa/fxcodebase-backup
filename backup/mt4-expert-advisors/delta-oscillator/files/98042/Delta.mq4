//+------------------------------------------------------------------+
//|                                                        Delta.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

double Price[], Delta[];

int init()
{
 IndicatorShortName("Delta oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Price);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Delta);

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
 double Diff;
 pos=limit;
 while(pos>=0)
 {
  Price[pos]=(Open[pos]+High[pos]+Low[pos]+Close[pos])/4.;
  if (Price[pos]>0. && Price[pos+1]>0.)
  {
   Diff=MathLog10(Price[pos+1]/Price[pos]);
   
   Delta[pos]=Price[pos]+Diff;
  } 

  pos--;
 } 
 return(0);
}

