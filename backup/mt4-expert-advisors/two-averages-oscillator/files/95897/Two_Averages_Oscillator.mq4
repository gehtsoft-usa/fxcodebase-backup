//+------------------------------------------------------------------+
//|                                      Two_Averages_Oscillator.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Lime
#property indicator_color2 Green
#property indicator_color3 DarkOrange
#property indicator_color4 Red

extern int Method1=0;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern int Length1=20;
extern int Method2=0;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern int Length2=50;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double H_UU[], H_UD[], H_DU[], H_DD[];

int init()
{
 IndicatorShortName("Two Averages oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,H_UU);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,H_UD);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,H_DU);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,H_DD);

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
 pos=limit;
 while(pos>=0)
 {
  MA1=iMA(NULL, 0, Length1, 0, Method1, Price, pos);
  MA2=iMA(NULL, 0, Length2, 0, Method2, Price, pos);
  H_UU[pos]=MA1-MA2;
  if (H_UU[pos]>0.)
  {
   if (H_UU[pos]<H_UU[pos+1])
   {
    H_UD[pos]=H_UU[pos];
   }
  }
  else
  {
   if (H_UU[pos]>=H_UU[pos+1])
   {
    H_DU[pos]=H_UU[pos];
   }
   else
   {
    H_DD[pos]=H_UU[pos];
   }
  }

  pos--;
 } 
 return(0);
}

