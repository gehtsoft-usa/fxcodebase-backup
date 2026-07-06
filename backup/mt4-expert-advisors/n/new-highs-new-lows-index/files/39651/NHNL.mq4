//+------------------------------------------------------------------+
//|                                                         NHNL.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Length=20;

double H[], L[], C[];

int init()
  {
   IndicatorShortName("New High, New Low Index");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,H);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,L);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,C);

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
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 int i;
 int CountH, CountL;
 while(pos>=0)
 {
  CountH=0;
  CountL=0;
  for (i=0;i<Length;i++)
  {
   if (High[pos+i]>High[pos+i+1]) CountH++;
   if (Low[pos+i]<Low[pos+i+1]) CountL--;
  }
  H[pos]=CountH;
  L[pos]=CountL;
  C[pos]=CountH+CountL;
  pos--;
 } 

 return(0);
}

