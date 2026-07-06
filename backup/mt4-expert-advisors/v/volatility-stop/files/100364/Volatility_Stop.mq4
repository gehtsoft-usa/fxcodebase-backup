//+------------------------------------------------------------------+
//|                                              Volatility_Stop.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern double Multiplier=2.;
extern int Length=20;

double VS[];
double HiLoDiff[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,VS);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,HiLoDiff);

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
  HiLoDiff[pos]=High[pos]-Low[pos];

  pos--;
 } 
 
 double HiLoAvg;
 pos=limit;
 while(pos>=0)
 {
  HiLoAvg=iMAOnArray(HiLoDiff, 0, Length, 0, MODE_SMA, pos);
  
  VS[pos]=Close[pos]-Multiplier*HiLoAvg;

  pos--;
 }
   
 return(0);
}

