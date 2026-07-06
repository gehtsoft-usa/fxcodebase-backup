//+------------------------------------------------------------------+
//|                                                         MSMA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Yellow
#property indicator_color2 Gray
#property indicator_color3 Gray
#property indicator_color4 Gray
#property indicator_color5 Gray
#property indicator_color6 Gray
#property indicator_color7 Gray
#property indicator_color8 Gray
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT
#property indicator_style4 STYLE_DOT
#property indicator_style5 STYLE_DOT
#property indicator_style6 STYLE_DOT
#property indicator_style7 STYLE_DOT
#property indicator_style8 STYLE_DOT

extern int Length=5;
extern int Repetitions=5;
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

double MSMA[], B1[], B2[], B3[], B4[], B5[], B6[], B7[];

int init()
{
 IndicatorShortName("Multiple smoothing moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MSMA);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,B1);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,B2);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,B3);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,B4);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,B5);
 SetIndexStyle(6,DRAW_LINE);
 SetIndexBuffer(6,B6);
 SetIndexStyle(7,DRAW_LINE);
 SetIndexBuffer(7,B7);
 
 if (Repetitions>8)
 {
  Alert("Repetitions can not be more 8!!!");
 }

 return(0);
}

int deinit()
{

 return(0);
}

void MA(double& res[], int Iteration, double Source[], int index)
{
 double R;
 if (Iteration==1)
 {
  R=iMA(NULL, 0, Length, 0, Method, Price, index);
 }
 else
 {
  R=iMAOnArray(Source, 0, Length, 0, Method, index);
 }
  
 if (Iteration==Repetitions)
 {
  MSMA[index]=R;
 }
 else
 {
  res[index]=R;
 }
 
 return;
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
  MA(B1, 1, B2, pos);

  pos--;
 } 
 
 if (Repetitions>1)
 {
  pos=limit;
  while(pos>=0)
  {
   MA(B2, 2, B1, pos);

   pos--;
  } 
 }

 if (Repetitions>2)
 {
  pos=limit;
  while(pos>=0)
  {
   MA(B3, 3, B2, pos);

   pos--;
  } 
 }

 if (Repetitions>3)
 {
  pos=limit;
  while(pos>=0)
  {
   MA(B4, 4, B3, pos);

   pos--;
  } 
 }

 if (Repetitions>4)
 {
  pos=limit;
  while(pos>=0)
  {
   MA(B5, 5, B4, pos);

   pos--;
  } 
 }

 if (Repetitions>5)
 {
  pos=limit;
  while(pos>=0)
  {
   MA(B6, 6, B5, pos);

   pos--;
  } 
 }

 if (Repetitions>6)
 {
  pos=limit;
  while(pos>=0)
  {
   MA(B7, 7, B6, pos);

   pos--;
  } 
 }

 if (Repetitions>7)
 {
  pos=limit;
  while(pos>=0)
  {
   MA(MSMA, 8, B7, pos);

   pos--;
  } 
 }

  
 return(0);
}

