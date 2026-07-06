//+------------------------------------------------------------------+
//|                                                        ALWMA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern string ModeStr="Mode: 0 - Regular, 1 - Inverse, 2 - Asymmetric, 3 - Inverse asymmetric";
extern int Mode=0;  // 0 - Regular, 1 - Inverse, 2 - Asymmetric, 3 - Inverse asymmetric
extern int Length=20;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double ALWMA[];
double Pr[];

int init()
{
 IndicatorShortName("Asymmetric Linear Weighted Moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ALWMA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Pr);

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
 double Count, Total, k;
 int i;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
 
  pos--;
 }
  
 pos=limit;
 while(pos>=0)
 {
  Count=0.;
  Total=0.;
  k=0.;
  for (i=pos+Length;i>=pos;i--)
  {
   if (Mode==0)
   {
    Count=Count+1;
   }
   else
   {
    if (Mode==1)
    {
     if (Count==0.)
     {
      Count=Length;
     }
     else
     {
      Count=Count-1.;
     }
    }
    else
    {
     if (Mode==2)
     {
      if (Count==0.)
      {
       Count=2.;
      }
      else
      {
       if (i-pos<Length/2)
       {
        Count=Count+2.;
       }
       else
       {
        Count=Count-2.;
       }
      }
     }
     else
     {
      if (Count==0.)
      {
       Count=Length;
      }
      else
      {
       if (i-pos<Length/2)
       {
        Count=Count-2.;
       }
       else
       {
        Count=Count+2.;
       }
      }
     }
    }
   }
   k=k+Count;
   Total=Total+Pr[i]*Count;
  }
  
  ALWMA[pos]=Total/k;

  pos--;
 } 
 return(0);
}

