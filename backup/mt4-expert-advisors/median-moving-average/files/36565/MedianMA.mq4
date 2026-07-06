//+------------------------------------------------------------------+
//|                                                     MedianMA.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=10;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
double MedianMA[];
double Arr[];
bool Even;
int index;

int init()
  {
   IndicatorShortName("Median Moving Average");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MedianMA);
   ArrayResize(Arr, Length);
   if (MathRound(Length/2)*2==Length) Even=true; else Even=false;
   index=MathFloor(Length/2);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int i;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  for (i=0;i<Length;i++)
  {
   Arr[i]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+i);
  }
  ArraySort(Arr);
  if (Even)
  {
   MedianMA[pos]=(Arr[index]+Arr[index-1])/2;
  }
  else
  {
   MedianMA[pos]=Arr[index];
  }
  pos--;
 }

 return(0);
}

