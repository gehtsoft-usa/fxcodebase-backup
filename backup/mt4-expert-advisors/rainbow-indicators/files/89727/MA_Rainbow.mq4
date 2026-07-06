//+------------------------------------------------------------------+
//|                                                   MA_Rainbow.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Lime
#property indicator_color2 LawnGreen
#property indicator_color3 GreenYellow
#property indicator_color4 Yellow
#property indicator_color5 Gold
#property indicator_color6 Goldenrod
#property indicator_color7 DarkOrange
#property indicator_color8 Red

extern int Length=5;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double MA1[], MA2[], MA3[], MA4[], MA5[], MA6[], MA7[], MA8[];

int init()
{
 IndicatorShortName("MA rainbow");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MA1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,MA2);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,MA3);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,MA4);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,MA5);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,MA6);
 SetIndexStyle(6,DRAW_LINE);
 SetIndexBuffer(6,MA7);
 SetIndexStyle(7,DRAW_LINE);
 SetIndexBuffer(7,MA8);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  MA1[pos]=iMA(NULL, 0, Length, 0, Method, Price, pos);
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  MA2[pos]=iMAOnArray(MA1, 0, Length, 0, Method, pos);
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  MA3[pos]=iMAOnArray(MA2, 0, Length, 0, Method, pos);
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  MA4[pos]=iMAOnArray(MA3, 0, Length, 0, Method, pos);
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  MA5[pos]=iMAOnArray(MA4, 0, Length, 0, Method, pos);
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  MA6[pos]=iMAOnArray(MA5, 0, Length, 0, Method, pos);
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  MA7[pos]=iMAOnArray(MA6, 0, Length, 0, Method, pos);
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  MA8[pos]=iMAOnArray(MA7, 0, Length, 0, Method, pos);
  pos--;
 } 
 return(0);
}

