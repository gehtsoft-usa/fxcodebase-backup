//+------------------------------------------------------------------+
//|                                                          TPI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Yellow

extern int Channel_Length=10;
extern int Average_Length=21;
extern double Coeff=0.015;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double TPI[];
double Buff1[], Buff2[], MA1[];

int init()
{
 IndicatorShortName("Trading Channel Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TPI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Buff1);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Buff2);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,MA1);

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
 double Pr;
 pos=limit;
 while(pos>=0)
 {
  MA1[pos]=iMA(NULL, 0, Channel_Length, 0, MODE_EMA, Price, pos);
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Buff1[pos]=MathAbs(Pr-MA1[pos]);

  pos--;
 } 
 
 double MA2;
 pos=limit;
 while(pos>=0)
 {
  MA2=iMAOnArray(Buff1, 0, Channel_Length, 0, MODE_EMA, pos);
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Buff2[pos]=(Pr-MA1[pos])/(Coeff*MA2);

  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  TPI[pos]=iMAOnArray(Buff2, 0, Average_Length, 0, MODE_EMA, pos);

  pos--;
 }
     
 return(0);
}

