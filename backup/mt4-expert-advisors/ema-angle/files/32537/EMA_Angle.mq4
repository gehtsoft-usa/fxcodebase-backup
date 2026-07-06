//+------------------------------------------------------------------+
//|                                                    EMA_Angle.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window

#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Yellow

extern int Length=50;
extern int Shift=6;
extern double Treshold=0.3;

double UP[], DOWN[], ZERO[];

int init()
  {
   IndicatorShortName("EMA Angle");
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,UP);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,DOWN);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,ZERO);

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   if(Bars<=Shift+Length) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   pos=MathMin(pos,Bars-Shift-Length);
   while(pos>=0)
   {
    double EMA0=iMA(NULL, 0, Length, 0, MODE_EMA, PRICE_MEDIAN, pos);
    double EMA1=iMA(NULL, 0, Length, 0, MODE_EMA, PRICE_MEDIAN, pos+Shift);
    double Angle=(EMA0-EMA1)/Point;
    if (Angle>=Treshold)
    {
     UP[pos]=Angle;
     DOWN[pos]=EMPTY_VALUE;
     ZERO[pos]=EMPTY_VALUE;
    }
    else if (Angle<=-Treshold)
    {
     UP[pos]=EMPTY_VALUE;
     DOWN[pos]=Angle;
     ZERO[pos]=EMPTY_VALUE;
    }
    else
    {
     UP[pos]=EMPTY_VALUE;
     DOWN[pos]=EMPTY_VALUE;
     ZERO[pos]=Angle;
    }
    pos--;
   } 

   return(0);
  }


