//+------------------------------------------------------------------+
//|                                                      Fan_CCI.mq4 |
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

double CCI1[], CCI2[], CCI3[], CCI4[], CCI5[], CCI6[], CCI7[], CCI8[];

int init()
{
 IndicatorShortName("Fan of CCI indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CCI1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,CCI2);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,CCI3);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,CCI4);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,CCI5);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,CCI6);
 SetIndexStyle(6,DRAW_LINE);
 SetIndexBuffer(6,CCI7);
 SetIndexStyle(7,DRAW_LINE);
 SetIndexBuffer(7,CCI8);

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
  CCI1[pos]=iCCI(NULL, 0, Length, Price, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  CCI2[pos]=iCCI(NULL, 0, Length, Price, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  CCI3[pos]=iCCI(NULL, 0, Length, Price, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  CCI4[pos]=iCCI(NULL, 0, Length, Price, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  CCI5[pos]=iCCI(NULL, 0, Length, Price, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  CCI6[pos]=iCCI(NULL, 0, Length, Price, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  CCI7[pos]=iCCI(NULL, 0, Length, Price, pos);
  pos--;
 } 

 Length+=Length_Step;
 pos=limit;
 while(pos>=0)
 {
  CCI8[pos]=iCCI(NULL, 0, Length, Price, pos);
  pos--;
 } 
 
 return(0);
}

