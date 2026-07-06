//+------------------------------------------------------------------+
//|                                                TradeBreakOut.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

extern int Length=50;
extern int PriceType=0; // Price type
                        // 0 - High/Low
                        // 1 - Close

double Upper[], Lower[];

int init()
  {
   IndicatorShortName("TradeBreakOut oscillator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Upper);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Lower);

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
 double H, L;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  if (PriceType==0)
  {
   H=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
   L=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
   if (L!=0)
   {
    Upper[pos]=(Low[pos]-L)/L;
   }
   if (H!=0)
   { 
    Lower[pos]=(High[pos]-H)/H;
   } 
  }
  else
  {
   H=Close[iHighest(NULL, 0, MODE_CLOSE, Length, pos)];
   L=Close[iLowest(NULL, 0, MODE_CLOSE, Length, pos)];
   if (L!=0)
   {
    Upper[pos]=(Close[pos]-L)/L;
   }
   if (H!=0)
   { 
    Lower[pos]=(Close[pos]-H)/H;
   } 
  }
  pos--;
 }

 return(0);
}

