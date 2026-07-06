//+------------------------------------------------------------------+
//|                                     Consecutive_Candle_Count.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1

extern int Length=0;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Count[];

int init()
{
 IndicatorShortName("Consecutive Candle Count");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_NONE);
 SetIndexBuffer(0,Count);

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
 int limit=Bars;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double Pr0, Pr1;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars)
  {
   Count[pos]=0.;
  }
  else
  {
   Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
   Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  
   if (Pr0>Pr1)
   {
    if (Count[pos+1]<0.)
    {
     Count[pos]=1.;
    }
    else
    {
     Count[pos]=Count[pos+1]+1.;
    }
   }
   else
   {
    if (Pr0<Pr1)
    {
     if (Count[pos+1]>0.)
     {
      Count[pos]=-1.;
     }
     else
     {
      Count[pos]=Count[pos+1]-1.;
     }
    }
    else
    {
     Count[pos]=0.;
    }
   }
  } 

  pos--;
 } 

 double Min, Max;
 if (Length==0)
 {
  Min=MathAbs(Count[ArrayMinimum(Count, WHOLE_ARRAY, 0)]);
  Max=Count[ArrayMaximum(Count, WHOLE_ARRAY, 0)];
 }
 else
 {
  Min=MathAbs(Count[ArrayMinimum(Count, Length, 0)]);
  Max=Count[ArrayMaximum(Count, Length, 0)];
 } 
 
 string Str="Up trend: "+Max+"\nDown trend: "+Min;
 
 Comment(Str);
  
 return(0);
}

