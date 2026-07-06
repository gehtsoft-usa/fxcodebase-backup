//+------------------------------------------------------------------+
//|                                                         VAMA.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red

extern int Length=10;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
                       

double VAMA[], VPrice[], Vol[];

int init()
  {
   IndicatorShortName("Volume Adjusted Moving Average");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,VAMA);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,VPrice);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,Vol);
   
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
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  VPrice[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos)*Volume[pos];
  Vol[pos]=Volume[pos];
  pos--;
 }

 pos=limit;
 double SumVol;
 while(pos>=0)
 {
  SumVol=iMAOnArray(Vol, 0, Length, 0, MODE_SMA, pos);
  if (SumVol!=0) VAMA[pos]=iMAOnArray(VPrice, 0, Length, 0, MODE_SMA, pos)/SumVol;
  pos--;
 }

 return(0);
}

