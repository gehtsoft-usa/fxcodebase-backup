//+------------------------------------------------------------------+
//|                                                           GD.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern double VF=0.7;
extern int Length=20;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double GD[];
double EMA[];

int init()
{
 IndicatorShortName("Generalized DEMA");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,GD);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,EMA);

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
  EMA[pos]=iMA(NULL, 0, Length, 0, MODE_EMA, Price, pos);

  pos--;
 } 
 
 double EMAofEMA;
 pos=limit;
 while(pos>=0)
 {
  EMAofEMA=iMAOnArray(EMA, 0, Length, 0, MODE_EMA, pos);
  
  GD[pos]=(1.+VF)*EMA[pos]-VF*EMAofEMA;

  pos--;
 }
   
 return(0);
}

