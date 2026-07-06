//+------------------------------------------------------------------+
//|                                                           T3.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 6
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

double T3[];
double EMA1[], GD1[], EMA2[], GD2[], EMA3[];

int init()
{
 IndicatorShortName("T3 average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,T3);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,EMA1);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,GD1);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,EMA2);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,GD2);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,EMA3);

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
  EMA1[pos]=iMA(NULL, 0, Length, 0, MODE_EMA, Price, pos);

  pos--;
 } 
 
 double EMAofEMA;
 pos=limit;
 while(pos>=0)
 {
  EMAofEMA=iMAOnArray(EMA1, 0, Length, 0, MODE_EMA, pos);
  
  GD1[pos]=(1.+VF)*EMA1[pos]-VF*EMAofEMA;

  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  EMA2[pos]=iMAOnArray(GD1, 0, Length, 0, MODE_EMA, pos);

  pos--;
 }    

 pos=limit;
 while(pos>=0)
 {
  EMAofEMA=iMAOnArray(EMA2, 0, Length, 0, MODE_EMA, pos);
  
  GD2[pos]=(1.+VF)*EMA2[pos]-VF*EMAofEMA;

  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  EMA3[pos]=iMAOnArray(GD2, 0, Length, 0, MODE_EMA, pos);

  pos--;
 }    

 pos=limit;
 while(pos>=0)
 {
  EMAofEMA=iMAOnArray(EMA3, 0, Length, 0, MODE_EMA, pos);
  
  T3[pos]=(1.+VF)*EMA3[pos]-VF*EMAofEMA;

  pos--;
 }

 return(0);
}

