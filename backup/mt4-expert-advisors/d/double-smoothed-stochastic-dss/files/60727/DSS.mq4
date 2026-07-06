//+------------------------------------------------------------------+
//|                                                          DSS.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property  indicator_buffers 3
#property  indicator_color1  Red
#property  indicator_color2  Green

extern int Frame=13;
extern int EMA_Frame=8;
extern int Signal_Frame=8;

double DSS[], Signal[], Buffer[];

double SmoothCoeff;

int init()
  {
   IndicatorShortName("DSS Bressert");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,DSS);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Signal);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,Buffer);
   SmoothCoeff=2./(1.+EMA_Frame);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   if(Bars<=Frame) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int limit=Bars-2;
   int pos;
   double H, L;
   double Delta;
   double Mit;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
   pos=limit;
   while(pos>=0)
   {
    H=High[ArrayMaximum(High, Frame, pos)];
    L=Low[ArrayMinimum(Low, Frame, pos)];
    Delta=Close[pos]-L;
    Mit=Delta*100/(H-L);
    Buffer[pos]=SmoothCoeff*Mit+(1-SmoothCoeff)*Buffer[pos+1];
    H=Buffer[ArrayMaximum(Buffer, Frame, pos)];
    L=Buffer[ArrayMinimum(Buffer, Frame, pos)];
    Delta=Buffer[pos]-L;
    Mit=Delta*100/(H-L);
    DSS[pos]=SmoothCoeff*Mit+(1-SmoothCoeff)*DSS[pos+1];
    pos--;
   }
   pos=limit;
   while(pos>=0)
   {
    Signal[pos]=iMAOnArray(DSS, 0, Signal_Frame, 0, MODE_EMA, pos);
    pos--;
   } 
    
   return(0);
  }

