//+------------------------------------------------------------------+
//|                                             Small_Inside_Bar.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Yellow

double Bullish[], Bearish[];

int init()
  {
   IndicatorShortName("Small inside bar");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexBuffer(0,Bullish);
   SetIndexArrow(0,108);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1,Bearish);
   SetIndexArrow(1,108);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   bool BullFl, BearFl;
   double Ratio;
   if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>=0)
   {
    BullFl=false;
    BearFl=false;
    if (High[pos]-Low[pos]==0) Ratio=10; else Ratio=(High[pos+1]-Low[pos+1])/(High[pos]-Low[pos]);
    if (High[pos]<High[pos+1] && Low[pos]>Low[pos+1] && Ratio>2)
    {
     if (Close[pos]>Open[pos] && High[pos]<(High[pos+1]+Low[pos+1])/2 && Close[pos+1]<Open[pos+1]) BullFl=true;
     if (Close[pos]<Open[pos] && Low[pos]<(High[pos+1]+Low[pos+1])/2 && Close[pos+1]>Open[pos+1]) BearFl=true;
    }
    if (BullFl) Bullish[pos]=Low[pos]; else Bullish[pos]=EMPTY_VALUE;
    if (BearFl) Bearish[pos]=High[pos]; else Bearish[pos]=EMPTY_VALUE;
    
    pos--;
   } 
   return(0);
  }


