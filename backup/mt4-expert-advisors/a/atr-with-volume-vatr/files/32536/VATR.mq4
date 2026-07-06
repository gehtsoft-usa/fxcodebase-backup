//+------------------------------------------------------------------+
//|                                                         VATR.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window

#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Green

extern int Length=14;         // Period of indicator
extern bool UseVolume=true;   // Use the volume?
extern int Type=0;            // Type of indicator. 0 - line, 1 - histogram 

double VATR[];
double tr[];

int init()
  {
   IndicatorShortName("VATR");
   if (Type==0)
   {
    SetIndexStyle(0,DRAW_LINE);
   }
   else
   {
    SetIndexStyle(0,DRAW_HISTOGRAM);
   } 
   SetIndexBuffer(0,VATR);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,tr);
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
   int    limit=Bars-2;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars;
   int pos=limit;
   while(pos>=0)
   {
    double hl=MathAbs(High[pos]-Low[pos]);
    double hc=MathAbs(High[pos]-Close[pos+1]);
    double lc=MathAbs(Low[pos]-Close[pos+1]);
    tr[pos]=MathMin(MathMin(hl,hc),lc);
    if (UseVolume) tr[pos]=tr[pos]*Volume[pos];
    pos--;
   } 
   pos=limit-Length;
   while(pos>=0)
   {
    VATR[pos]=iMAOnArray(tr,0,Length,0,MODE_SMA,pos);
    pos--;
   } 

   return(0);
  }

