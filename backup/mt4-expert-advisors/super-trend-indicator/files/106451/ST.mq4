//+------------------------------------------------------------------+
//|                                                           ST.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=14;
extern int Shift=20;
extern bool Use_Filter=true;

double UP[], DN[];
double Flag[];

int init()
{
 IndicatorShortName("SuperTrend");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,DN);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Flag);

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
 double CCI;
 pos=limit;
 while(pos>=0)
 {
   CCI=iCCI(NULL, 0, Length, PRICE_TYPICAL, pos);
   UP[pos]=UP[pos+1];
   Flag[pos]=Flag[pos+1];
   
   if (CCI>0. && Flag[pos]<=0.)
   {
    Flag[pos]=1.;
    UP[pos]=Low[pos]-Shift*Point;
   }
   
   if (CCI<0. && Flag[pos]>=0.)
   {
    Flag[pos]=-1.;
    UP[pos]=High[pos]+Shift*Point;
   }
   
   if (Flag[pos]>0. && Low[pos]-Shift*Point>UP[pos+1])
   {
    UP[pos]=Low[pos]-Shift*Point;
   }
   else
   {
    if (Flag[pos]<0. && High[pos]+Shift*Point<UP[pos+1])
    {
     UP[pos]=High[pos]+Shift*Point;
    }
   }
   
   if (Use_Filter)
   {
    if (Flag[pos]>0. && UP[pos]>UP[pos+1])
    {
     if (Close[pos]<Open[pos])
     {
      UP[pos]=UP[pos+1];
     }
     if (High[pos]<High[pos+1])
     {
      UP[pos]=UP[pos+1];
     }
    }
    if (Flag[pos]<0. && UP[pos]<UP[pos+1])
    {
     if (Close[pos]>Open[pos])
     {
      UP[pos]=UP[pos+1];
     }
     if (Low[pos]>Low[pos+1])
     {
      UP[pos]=UP[pos+1];
     }
    }
   }
   
   if (Close[pos]>UP[pos])
   {
    DN[pos]=EMPTY_VALUE;
   }
   else
   {
    DN[pos]=UP[pos];
   }

  pos--;
 } 
 return(0);
}

