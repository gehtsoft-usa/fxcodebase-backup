//+------------------------------------------------------------------+
//|                                                     Fan_RSI2.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Yellow

extern int First_Length=5;
extern string Increment_Type_Str="0 - Add, 1 - Mult";
extern int Increment_Type=0;    // 0 - Add, 1 - Mult
extern int Length_Step=2;
extern int RSI_Count=10;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  
extern int Average_Length=10;
extern int Average_Method=0;  // 0 - SMA
                              // 1 - EMA
                              // 2 - SMMA
                              // 3 - LWMA


double Up[], Dn[], Av[];
double Sum[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Up);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Dn);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Av);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Sum);

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
 double S, RSI0, RSI1;
 int i, Length;
 pos=limit;
 while(pos>=0)
 {
  S=0.;
  Length=First_Length;
  for (i=1;i<=RSI_Count;i++)
  {
   RSI0=iRSI(NULL, 0, Length, Price, pos);
   RSI1=iRSI(NULL, 0, Length, Price, pos+1);
   if (RSI0>RSI1)
   {
    S=S+1.;
   }
   else
   {
    S=S-1.;
   }
   if (Increment_Type==0)
   {
    Length=Length+Length_Step;
   }
   else
   {
    Length=Length*Length_Step;
   }
  }
  
  S=S/(0.+RSI_Count);
  
  Sum[pos]=S;
  if (S>0.)
  {
   Up[pos]=S;
   Dn[pos]=0.;
  }
  else
  {
   Up[pos]=0.;
   Dn[pos]=S;
  }

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Av[pos]=iMAOnArray(Sum, 0, Average_Length, 0, Average_Method, pos);

  pos--;
 }
   
 return(0);
}

