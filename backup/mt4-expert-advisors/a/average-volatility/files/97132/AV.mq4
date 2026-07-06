//+------------------------------------------------------------------+
//|                                                           AV.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=5;

double AV[];
double Volatility[];

int init()
{
 IndicatorShortName("Average Volatility");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,AV);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Volatility);

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
  Volatility[pos]=High[pos]-Low[pos];

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  AV[pos]=iMAOnArray(Volatility, 0, Length, 0, MODE_SMA, pos)/Point;

  pos--;
 }
   
 return(0);
}

