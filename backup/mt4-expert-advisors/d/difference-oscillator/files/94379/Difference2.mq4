//+------------------------------------------------------------------+
//|                                                  Difference2.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=10;
extern string _Method="0 - Absolute, 1 - Relative";
extern int Method=0;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Diff[], DiffDn[];

int init()
{
 IndicatorShortName("Difference");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Diff);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,DiffDn);

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
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double Pr0, Pr1;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+Length);
  if (Method==0)
  {
   Diff[pos]=Pr0-Pr1;
  }
  else
  {
   if (Pr1!=0.)
   {
    Diff[pos]=100.*(Pr0-Pr1)/Pr1;
   }
   else
   {
    Diff[pos]=EMPTY_VALUE;
   } 
  }
  
  if (Diff[pos]<=Diff[pos+1])
  {
   DiffDn[pos]=Diff[pos];
  }
  else
  {
   DiffDn[pos]=EMPTY_VALUE;
  }

  pos--;
 } 
 return(0);
}

