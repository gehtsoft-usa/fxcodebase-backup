//+------------------------------------------------------------------+
//|                                            Performance_Index.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;
extern string Instrument="GBPUSD";
extern int Method=0;     // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
                      
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double PI[];

int init()
{
 IndicatorShortName("Performance Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PI);

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
 double MA1, MA2;
 double Pr1, Pr2;
 int index;
 pos=limit;
 while(pos>=0)
 {
  index=iBarShift(Instrument, 0, Time[pos], false);
  MA1=iMA(NULL, 0, Length, 0, Method, Price, pos);
  MA2=iMA(Instrument, 0, Length, 0, Method, Price, index);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr2=iMA(Instrument, 0, 1, 0, MODE_SMA, Price, index);
  if (MA2!=0 && Pr2!=0)
  {
   PI[pos]=Pr1*MA2/(Pr2*MA1);
  }
  else
  {
   PI[pos]=EMPTY_VALUE;
  }
  
  pos--;
 } 
 return(0);
}

