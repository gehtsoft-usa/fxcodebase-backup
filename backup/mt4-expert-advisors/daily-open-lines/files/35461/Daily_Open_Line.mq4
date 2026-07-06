//+------------------------------------------------------------------+
//|                                              Daily_Open_Line.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int OpenHour=0;

double DailyOpenLine[];

int init()
  {
   SetIndexBuffer(0,DailyOpenLine);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   int H_Prev, H_Curr;
   if(Bars<=2) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int    limit=Bars-2;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars;
   int pos=limit;
   while(pos>=0)
   {
    H_Curr=TimeHour(Time[pos]);
    H_Prev=TimeHour(Time[pos+1]);
    if (H_Prev==23) H_Prev=-1;
    if (OpenHour>H_Prev && OpenHour<=H_Curr)
    {
     DailyOpenLine[pos]=Open[pos];
    }
    else
    {
     DailyOpenLine[pos]=DailyOpenLine[pos+1];
    }
    pos--;
   } 

   return(0);
  }

