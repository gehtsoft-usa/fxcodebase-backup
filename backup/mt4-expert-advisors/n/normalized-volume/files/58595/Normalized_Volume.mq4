//+------------------------------------------------------------------+
//|                                            Normalized_Volume.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green

extern int Minutes=1;

double NVolume[];

int init()
  {
   IndicatorShortName("Normalized volume");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,NVolume);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=2) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  NVolume[pos]=Volume[pos]*Minutes/Period();
  pos--;
 }

 return(0);
}

