//+------------------------------------------------------------------+
//|                                                      Fan_RSI.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Lime
#property indicator_color2 LawnGreen
#property indicator_color3 GreenYellow
#property indicator_color4 Yellow
#property indicator_color5 Gold
#property indicator_color6 Goldenrod
#property indicator_color7 DarkOrange
#property indicator_color8 Red

extern int First_Length=5;
extern int Length_Step=5;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double RSI1[], RSI2[], RSI3[], RSI4[], RSI5[], RSI6[], RSI7[], RSI8[];

int init()
{
 IndicatorShortName("Fan of RSI indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,RSI1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,RSI2);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,RSI3);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,RSI4);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,RSI5);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,RSI6);
 SetIndexStyle(6,DRAW_LINE);
 SetIndexBuffer(6,RSI7);
 SetIndexStyle(7,DRAW_LINE);
 SetIndexBuffer(7,RSI8);

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
 
 int Length=First_Length;
 pos=limit;
 while(pos>=0)
 {
  RSI1[pos]=iRSI(NULL, 0, Length, Price, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  RSI2[pos]=iRSI(NULL, 0, Length, Price, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  RSI3[pos]=iRSI(NULL, 0, Length, Price, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  RSI4[pos]=iRSI(NULL, 0, Length, Price, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  RSI5[pos]=iRSI(NULL, 0, Length, Price, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  RSI6[pos]=iRSI(NULL, 0, Length, Price, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  RSI7[pos]=iRSI(NULL, 0, Length, Price, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  RSI8[pos]=iRSI(NULL, 0, Length, Price, pos);
  pos--;
 } 
 
 return(0);
}

