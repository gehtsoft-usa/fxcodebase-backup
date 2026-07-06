//+------------------------------------------------------------------+
//|                                                         MBBD.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 clrRed
#property indicator_color2 clrCrimson
#property indicator_color3 clrDarkViolet
#property indicator_color4 clrMediumBlue
#property indicator_color5 clrRoyalBlue
#property indicator_color6 clrDarkTurquoise
#property indicator_color7 clrLimeGreen
#property indicator_color8 clrGreen

extern int Length=20;
extern int Number_Of_Bands=4;
extern double Deviation=1.;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double U4[], U3[], U2[], U1[], L1[], L2[], L3[], L4[];

int init()
{
 IndicatorShortName("Multiple Bollinger Bands Deviation");
 IndicatorDigits(Digits);
 if (Number_Of_Bands>3)
 {
  SetIndexStyle(0,DRAW_LINE);
  SetIndexStyle(7,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(0,DRAW_NONE);
  SetIndexStyle(7,DRAW_NONE);
 }
 if (Number_Of_Bands>2) 
 {
  SetIndexStyle(1,DRAW_LINE);
  SetIndexStyle(6,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(1,DRAW_NONE);
  SetIndexStyle(6,DRAW_NONE);
 }
 if (Number_Of_Bands>1)
 {
  SetIndexStyle(2,DRAW_LINE);
  SetIndexStyle(5,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(2,DRAW_NONE);
  SetIndexStyle(5,DRAW_NONE);
 } 
 SetIndexStyle(3,DRAW_LINE);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(0,U4);
 SetIndexBuffer(1,U3);
 SetIndexBuffer(2,U2);
 SetIndexBuffer(3,U1);
 SetIndexBuffer(4,L1);
 SetIndexBuffer(5,L2);
 SetIndexBuffer(6,L3);
 SetIndexBuffer(7,L4);

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
 double MA, StdDev, d;
 pos=limit;
 while(pos>=0)
 {
  MA=iMA(NULL, 0, Length, 0, Method, Price, pos);
  StdDev=iStdDev(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  d=StdDev*Deviation;
  
  U1[pos]=MA+d;
  L1[pos]=MA-d;
  U2[pos]=MA+2.*d;
  L2[pos]=MA-2.*d;
  U3[pos]=MA+3.*d;
  L3[pos]=MA-3.*d;
  U4[pos]=MA+4.*d;
  L4[pos]=MA-4.*d;

  pos--;
 } 
 return(0);
}

