//+------------------------------------------------------------------+
//|                                              Volatility_Band.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red

extern int Length_Vol_Band=8;
extern int Length_Vol=13;
extern double Dev_Factor=3.55;
extern double Low_Band_Adjust=0.9;

double Upper[], Middle[], Lower[];
double tpSeries[], V_Value[];

int init()
{
 IndicatorShortName("Volatility Band");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Middle);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Lower);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Upper);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,tpSeries);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,V_Value);

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
 double tp0, tp1;
 double l0, l1;
 pos=limit;
 while(pos>=0)
 {
  tp0=iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_TYPICAL, pos);
  tp1=iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_TYPICAL, pos+1);
  l0=iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_LOW, pos);
  l1=iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_LOW, pos+1);
  if (tp0>=tp1)
  {
   tpSeries[pos]=tp0-l1;
  }
  else
  {
   tpSeries[pos]=tp1-l0;
  }
  
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  V_Value[pos]=iMAOnArray(tpSeries, 0, Length_Vol, 0, MODE_SMA, pos)/Dev_Factor;

  pos--;
 }
 
 double EMA1, EMA2;
 double devHigh, devLow;
 pos=limit;
 while(pos>=0)
 {
  EMA1=iMAOnArray(V_Value, 0, Length_Vol_Band, 0, MODE_EMA, pos);
  EMA2=iMA(NULL, 0, Length_Vol_Band, 0, MODE_EMA, PRICE_TYPICAL, pos);
  devHigh=EMA1;
  devLow=devHigh*Low_Band_Adjust;
  Middle[pos]=EMA2;
  Lower[pos]=Middle[pos]-devLow;
  Upper[pos]=Middle[pos]+devHigh;
  
  pos--;
 }  
   
 return(0);
}

