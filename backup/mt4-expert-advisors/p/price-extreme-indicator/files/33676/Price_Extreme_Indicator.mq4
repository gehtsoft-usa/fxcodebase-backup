//+------------------------------------------------------------------+
//|                                      Price_Extreme_Indicator.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Blue

extern int Multiplier=5;

double HighBorder[];
double LowBorder[];
int Coeff;

int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,HighBorder);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,LowBorder);
   SetIndexShift(0,Multiplier);
   SetIndexShift(1,Multiplier);
   Coeff=Period()*60*Multiplier;
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   int i, x, y, counted=IndicatorCounted();
   if (counted>0) counted--;
   int limit=Bars-counted+Multiplier;
   
   for (i=0;i<limit;i++)
   {
    datetime BeginTime=MathCeil(Time[i]/Coeff)*Coeff;
    datetime EndTime=MathCeil(Time[i]/Coeff+1)*Coeff;
    int BeginBar=iBarShift(NULL, 0, BeginTime, false);
    int EndBar=iBarShift(NULL, 0, EndTime, false);
    HighBorder[i]=High[iHighest(NULL, 0, MODE_HIGH, BeginBar-EndBar+1, EndBar)];
    LowBorder[i]=Low[iLowest(NULL, 0, MODE_LOW, BeginBar-EndBar+1, EndBar)];
   
   }

   return(0);
  }



