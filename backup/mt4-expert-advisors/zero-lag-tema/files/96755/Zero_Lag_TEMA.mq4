//+------------------------------------------------------------------+
//|                                                Zero_Lag_TEMA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Yellow

extern int Length=50;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double TEMA[];
double EMA1[], EMA2[], TEMA1[], EMA4[], EMA5[]; 

int init()
{
 IndicatorShortName("Zero Lag Triple Exponential Moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TEMA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,EMA1);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,EMA2);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,TEMA1);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,EMA4);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,EMA5);

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
 
 pos=limit;
 while(pos>=0)
 {
  EMA2[pos]=iMAOnArray(EMA1, 0, Length, 0, MODE_EMA, pos);

  pos--;
 }
 
 double EMA3;  
 pos=limit;
 while(pos>=0)
 {
  EMA3=iMAOnArray(EMA2, 0, Length, 0, MODE_EMA, pos);
  TEMA1[pos]=3.*(EMA1[pos]-EMA2[pos])+EMA3;

  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  EMA4[pos]=iMAOnArray(TEMA1, 0, Length, 0, MODE_EMA, pos);

  pos--;
 }
   
 pos=limit;
 while(pos>=0)
 {
  EMA5[pos]=iMAOnArray(EMA4, 0, Length, 0, MODE_EMA, pos);

  pos--;
 }

 double EMA6; 
 double TEMA2;
 double Diff;
 pos=limit;
 while(pos>=0)
 {
  EMA6=iMAOnArray(EMA5, 0, Length, 0, MODE_EMA, pos);
  TEMA2=3.*(EMA4[pos]-EMA5[pos])+EMA6;
  Diff=TEMA1[pos]-TEMA2;
  TEMA[pos]=TEMA1[pos]+Diff;

  pos--;
 }
   
 
   
 return(0);
}

