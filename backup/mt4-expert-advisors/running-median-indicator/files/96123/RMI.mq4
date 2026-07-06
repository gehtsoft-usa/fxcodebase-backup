//+------------------------------------------------------------------+
//|                                                          RMI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=13;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
double RMI[];
double Arr[];
int Len;
int index;

int init()
  {
   IndicatorShortName("Running Median Indicator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RMI);
   ArrayResize(Arr, Length);
   if (MathRound(Length/2)*2==Length) 
   {
    Len=Length+1; 
   }
   else 
   {
    Len=Length;
   } 
   index=MathFloor(Len/2.+0.5);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=Len) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int i;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  for (i=0;i<Len;i++)
  {
   Arr[i]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+i);
  }
  ArraySort(Arr);
  RMI[pos]=Arr[index];
  
  pos--;
 }

 return(0);
}

