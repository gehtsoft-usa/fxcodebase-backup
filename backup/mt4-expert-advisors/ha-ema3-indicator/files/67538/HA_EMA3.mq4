//+------------------------------------------------------------------+
//|                                                       HAEMA3.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Green

extern int Length=10;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double Buff[];
double HAopen[], HAclose[], EMA1[], EMA2[];

int init()
  {
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Buff);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,EMA1);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,EMA2);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,HAopen);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,HAclose);

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
 while(pos>0)
 {
  HAopen[pos]=((Open[pos+1]+High[pos+1]+Low[pos+1]+Close[pos+1])/4+HAopen[pos+1])/2;
  HAclose[pos]=((Open[pos]+High[pos]+Low[pos]+Close[pos])/4+HAopen[pos]+MathMax(High[pos], HAopen[pos])+MathMin(Low[pos], HAopen[pos]))/4;
  pos--;
 } 

 pos=limit;
 while(pos>0)
 {
  EMA1[pos]=iMAOnArray(HAclose, 0, Length, 0, Method, pos);
  pos--;
 } 

 pos=limit;
 while(pos>0)
 {
  EMA2[pos]=iMAOnArray(EMA1, 0, Length, 0, Method, pos);
  pos--;
 } 

 pos=limit;
 while(pos>0)
 {
  Buff[pos]=iMAOnArray(EMA2, 0, Length, 0, Method, pos);
  pos--;
 } 

 return(0);
}

