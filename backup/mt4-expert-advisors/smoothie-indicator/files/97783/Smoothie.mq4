//+------------------------------------------------------------------+
//|                                                     Smoothie.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Yellow
#property indicator_color2 Yellow
#property indicator_color3 Yellow
#property indicator_color4 Yellow
#property indicator_color5 Yellow
#property indicator_color6 Yellow
#property indicator_color7 Yellow
#property indicator_color8 Yellow

extern int Length=20;
extern int Number_Of_Repetitions=1;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern bool Show_Only_Last=true;                      
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double S1[], S2[], S3[], S4[], S5[], S6[], S7[], S8[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 if (Show_Only_Last && Number_Of_Repetitions>1)
 {
  SetIndexStyle(0,DRAW_NONE);
 }
 else
 {
  SetIndexStyle(0,DRAW_LINE);
 } 
 SetIndexBuffer(0,S1);
 if ((Show_Only_Last && Number_Of_Repetitions>2) || Number_Of_Repetitions<2)
 {
  SetIndexStyle(1,DRAW_NONE);
 }
 else
 {
  SetIndexStyle(1,DRAW_LINE);
 } 
 SetIndexBuffer(1,S2);
 if ((Show_Only_Last && Number_Of_Repetitions>3) || Number_Of_Repetitions<3)
 {
  SetIndexStyle(2,DRAW_NONE);
 }
 else
 {
  SetIndexStyle(2,DRAW_LINE);
 } 
 SetIndexBuffer(2,S3);
 if ((Show_Only_Last && Number_Of_Repetitions>4) || Number_Of_Repetitions<4)
 {
  SetIndexStyle(3,DRAW_NONE);
 }
 else
 {
  SetIndexStyle(3,DRAW_LINE);
 } 
 SetIndexBuffer(3,S4);
 if ((Show_Only_Last && Number_Of_Repetitions>5) || Number_Of_Repetitions<5)
 {
  SetIndexStyle(4,DRAW_NONE);
 }
 else
 {
  SetIndexStyle(4,DRAW_LINE);
 } 
 SetIndexBuffer(4,S5);
 if ((Show_Only_Last && Number_Of_Repetitions>6) || Number_Of_Repetitions<6)
 {
  SetIndexStyle(5,DRAW_NONE);
 }
 else
 {
  SetIndexStyle(5,DRAW_LINE);
 } 
 SetIndexBuffer(5,S6);
 if ((Show_Only_Last && Number_Of_Repetitions>7) || Number_Of_Repetitions<7)
 {
  SetIndexStyle(6,DRAW_NONE);
 }
 else
 {
  SetIndexStyle(6,DRAW_LINE);
 } 
 SetIndexBuffer(6,S7);
 if (Number_Of_Repetitions<8)
 {
  SetIndexStyle(7,DRAW_NONE);
 }
 else
 {
  SetIndexStyle(7,DRAW_LINE);
 } 
 SetIndexBuffer(7,S8);

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
  S1[pos]=iMA(NULL, 0, Length, 0, Method, Price, pos);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  S2[pos]=iMAOnArray(S1, 0, Length, 0, Method, pos);

  pos--;
 }
   
 pos=limit;
 while(pos>=0)
 {
  S3[pos]=iMAOnArray(S2, 0, Length, 0, Method, pos);

  pos--;
 }
   
 pos=limit;
 while(pos>=0)
 {
  S4[pos]=iMAOnArray(S3, 0, Length, 0, Method, pos);

  pos--;
 }
   
 pos=limit;
 while(pos>=0)
 {
  S5[pos]=iMAOnArray(S4, 0, Length, 0, Method, pos);

  pos--;
 }
   
 pos=limit;
 while(pos>=0)
 {
  S6[pos]=iMAOnArray(S5, 0, Length, 0, Method, pos);

  pos--;
 }
   
 pos=limit;
 while(pos>=0)
 {
  S7[pos]=iMAOnArray(S6, 0, Length, 0, Method, pos);

  pos--;
 }
   
 pos=limit;
 while(pos>=0)
 {
  S8[pos]=iMAOnArray(S7, 0, Length, 0, Method, pos);

  pos--;
 }
   
 return(0);
}

