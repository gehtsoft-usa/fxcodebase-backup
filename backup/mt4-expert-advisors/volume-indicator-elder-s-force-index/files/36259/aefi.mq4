//+------------------------------------------------------------------+
//|                                                         aefi.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern bool Smooth=true;
extern int SmoothPeriod=13;

double FI[];
double RawFI[];

int init()
  {
   IndicatorShortName("FI");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,FI);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,RawFI);

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
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  RawFI[pos]=(Close[pos]-Close[pos+1])/Volume[pos];
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (Smooth)
  {
   FI[pos]=iMAOnArray(RawFI, 0, SmoothPeriod, 0, MODE_EMA, pos)/Point;
  }
  else
  {
   FI[pos]=RawFI[pos]/Point;
  }
  pos--;
 } 

 return(0);
}

