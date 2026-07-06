//+------------------------------------------------------------------+
//|                                                 Two_MA_Cross.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Yellow
#property indicator_color4 Cyan


extern int Period1=100;   // Period of MA1
extern int Method1=0;     // Method of MA1
extern int Price1=0;      // Price of MA1
extern int Period2=60;    // Period of MA2
extern int Method2=0;     // Method of MA2
extern int Price2=0;      // Price of MA2

double MA1[], MA2[], UP[], DN[];

int init()
  {
   IndicatorShortName("Two MA cross");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MA1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MA2);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexBuffer(2,UP);
   SetIndexArrow(2,233);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexBuffer(3,DN);
   SetIndexArrow(3,234);
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
    MA1[pos]=iMA(NULL, 0, Period1, 0, Method1, Price1, pos);
    MA2[pos]=iMA(NULL, 0, Period2, 0, Method2, Price2, pos);
    if (MA1[pos+1]<MA2[pos+1] && MA1[pos]>MA2[pos])
    {
     UP[pos]=MA2[pos];
    }
    else
    {
     UP[pos]=EMPTY_VALUE;
    }
    if (MA1[pos+1]>MA2[pos+1] && MA1[pos]<MA2[pos])
    {
     DN[pos]=MA2[pos];
    }
    else
    {
     DN[pos]=EMPTY_VALUE;
    }
    pos--;
   }

   return(0);
  }


