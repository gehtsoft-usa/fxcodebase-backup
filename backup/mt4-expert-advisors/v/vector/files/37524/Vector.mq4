//+------------------------------------------------------------------+
//|                                                       Vector.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

double WP[], WN[];

int init()
  {
   IndicatorShortName("Vector");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,WP);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,WN);

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=16) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  WP[pos]=Close[pos]-(Close[pos+2]+Close[pos+4]+Close[pos+8]+Close[pos+16])/4;
  WN[pos]=0.9375*Close[pos]-0.5*Close[pos+2]-0.25*Close[pos+4]-0.125*Close[pos+8]-0.0625*Close[pos+16];
  pos--;
 } 

 return(0);
}

