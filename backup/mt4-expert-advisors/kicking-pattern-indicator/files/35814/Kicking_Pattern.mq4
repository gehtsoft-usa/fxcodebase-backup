//+------------------------------------------------------------------+
//|                                              Kicking_Pattern.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Yellow

extern bool ShowBullish=true;
extern bool ShowBearish=true;

double Bullish[], Bearish[];

int init()
  {
   IndicatorShortName("Kicking pattern");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_ARROW,0,1);
   SetIndexArrow(0,119);
   SetIndexBuffer(0,Bullish);
   SetIndexStyle(1,DRAW_ARROW,0,1);
   SetIndexArrow(1,119);
   SetIndexBuffer(1,Bearish);

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=5) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  if (ShowBullish)
  {
   if (Close[pos]>Open[pos] && Close[pos+1]<Open[pos+1] && Close[pos+2]>Open[pos+2] && Close[pos+3]<Open[pos+3])
   {
    Bullish[pos]=High[pos];
   }
   else
   {
    Bullish[pos]=EMPTY_VALUE;
   }
  }
  if (ShowBearish)
  {
   if (Close[pos]<Open[pos] && Close[pos+1]>Open[pos+1] && Close[pos+2]<Open[pos+2] && Close[pos+3]>Open[pos+3])
   {
    Bearish[pos]=High[pos];
   }
   else
   {
    Bearish[pos]=EMPTY_VALUE;
   }
  }
  pos--;
 } 
 return(0);
}

