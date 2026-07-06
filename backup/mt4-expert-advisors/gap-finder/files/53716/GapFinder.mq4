//+------------------------------------------------------------------+
//|                                                    GapFinder.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2



extern int MinGapSize=2;

double Up[], Down[];
double MinGapSizePoint;

int init()
  {
    SetIndexBuffer(0,Up);
    SetIndexBuffer(1,Down);   
    SetIndexStyle(0,DRAW_ARROW,0,4);
    SetIndexArrow(0,241);
    SetIndexStyle(1,DRAW_ARROW,0,4);
    SetIndexArrow(1,242);
    SetIndexLabel(0,"Up Gap");
    SetIndexLabel(1,"Down Gap");
    MinGapSizePoint=MinGapSize*Point;
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
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>=0)
   {
    if (Low[pos]-High[pos+1]>=MinGapSizePoint)
    {
     Up[pos]=Low[pos];
    }
    else
    {
     Up[pos]=EMPTY_VALUE;
    }
    if (Low[pos+1]-High[pos]>=MinGapSizePoint)
    {
     Down[pos]=High[pos];
    }
    else
    {
     Down[pos]=EMPTY_VALUE;
    }
    pos--;
   }
   return(0);
  }

