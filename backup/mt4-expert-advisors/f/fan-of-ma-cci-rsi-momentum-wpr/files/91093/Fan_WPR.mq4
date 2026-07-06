//+------------------------------------------------------------------+
//|                                                      Fan_WPR.mq4 |
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

double WPR1[], WPR2[], WPR3[], WPR4[], WPR5[], WPR6[], WPR7[], WPR8[];

int init()
{
 IndicatorShortName("Fan of WPR indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,WPR1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,WPR2);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,WPR3);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,WPR4);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,WPR5);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,WPR6);
 SetIndexStyle(6,DRAW_LINE);
 SetIndexBuffer(6,WPR7);
 SetIndexStyle(7,DRAW_LINE);
 SetIndexBuffer(7,WPR8);

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
  WPR1[pos]=iWPR(NULL, 0, Length, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  WPR2[pos]=iWPR(NULL, 0, Length, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  WPR3[pos]=iWPR(NULL, 0, Length, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  WPR4[pos]=iWPR(NULL, 0, Length, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  WPR5[pos]=iWPR(NULL, 0, Length, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  WPR6[pos]=iWPR(NULL, 0, Length, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  WPR7[pos]=iWPR(NULL, 0, Length, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  WPR8[pos]=iWPR(NULL, 0, Length, pos);
  pos--;
 } 
 
 return(0);
}

