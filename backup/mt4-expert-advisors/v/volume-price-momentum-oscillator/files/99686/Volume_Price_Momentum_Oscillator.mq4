//+------------------------------------------------------------------+
//|                             Volume_Price_Momentum_Oscillator.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=3;

double VPMO[];
double vpm[];

int init()
{
 IndicatorShortName("Volume price momentum oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,VPMO);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,vpm);

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
  vpm[pos]=Volume[pos]*(Close[pos]-Close[pos+1]);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  VPMO[pos]=iMAOnArray(vpm, 0, Length, 0, MODE_EMA, pos)/Point;

  pos--;
 }
   
 return(0);
}

