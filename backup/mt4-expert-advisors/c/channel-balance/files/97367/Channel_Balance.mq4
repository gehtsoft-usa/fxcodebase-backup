//+------------------------------------------------------------------+
//|                                              Channel_Balance.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=20;

double CB[];
double T[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CB);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,T);

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
 double Min, Max;
 double Range;
 double MedianPrice;
 pos=limit;
 while(pos>=0)
 {
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  
  Range=Max-Min;
  if (Range!=0.)
  {
   MedianPrice=iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_MEDIAN, pos);
   T[pos]=(MedianPrice-Min)/Range;
  }

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  CB[pos]=100.*iMAOnArray(T, 0, Length, 0, MODE_SMA, pos);

  pos--;
 }
   
 return(0);
}

