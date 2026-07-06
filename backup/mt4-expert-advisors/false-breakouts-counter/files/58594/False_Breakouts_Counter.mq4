//+------------------------------------------------------------------+
//|                                      False_Breakouts_Counter.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Yellow

extern int Length=5;

double Up[], Dn[], Sum[];

int init()
  {
   IndicatorShortName("False Breakouts Counter");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Up);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Dn);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Sum);
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
 int i;
 int limit=Bars-2;
 double Max, Min;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 int i2;
 int SumUp, SumDn;
 while(pos>=0)
 {
  SumUp=0;
  SumDn=0;
  for (i2=0;i2<Length;i2++)
  {
   if (High[pos+i2]>High[pos+i2+1] && Close[pos+i2]<=High[pos+i2+1]) SumUp++;
   if (Low[pos+i2]<Low[pos+i2+1] && Close[pos+i2]>=Low[pos+i2+1]) SumDn++;
  }
  Up[pos]=SumUp;
  Dn[pos]=SumDn;
  Sum[pos]=SumUp+SumDn;
  pos--;
 }

 return(0);
}

