//+------------------------------------------------------------------+
//|                                 Percentage_Crossover_Channel.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Yellow


extern double Percent=1;
extern int PriceType=0;

double PlusValue, MinusValue;
double Upper[], Middle[], Lower[];

#property indicator_chart_window

int init()
  {
   PlusValue=1+Percent/100;
   MinusValue=1-Percent/100;
   IndicatorShortName("Percentage Crossover Channel");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Upper);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Middle);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Lower);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   double Price;
   int    counted_bars=IndicatorCounted();
   if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>=0)
   {
    Price=iMA(NULL, 0, 1, 0, MODE_SMA, PriceType, pos);
    if (pos==Bars-2)
    {
     Middle[pos]=Price;
    }
    else
    {
     if (Price*MinusValue>Middle[pos+1])
     {
      Middle[pos]=Price*MinusValue;
     }
     else
     {
      if (Price*PlusValue<Middle[pos+1])
      {
       Middle[pos]=Price*PlusValue;
      }
      else
      {
       Middle[pos]=Middle[pos+1];
      }
     }
    }
    Upper[pos]=Middle[pos]*PlusValue;
    Lower[pos]=Middle[pos]*MinusValue;
    pos--;
   } 

   return(0);
  }

