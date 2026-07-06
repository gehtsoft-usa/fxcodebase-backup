//+------------------------------------------------------------------+
//|                                                    Mirror_MA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Method1=0;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern int Price1=0;    // Applied price
                        // 0 - Close
                        // 1 - Open
                        // 2 - High
                        // 3 - Low
                        // 4 - Median
                        // 5 - Typical
                        // 6 - Weighted  
extern int Length1=20;
extern int Method2=0;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern int Price2=1;    // Applied price
                        // 0 - Close
                        // 1 - Open
                        // 2 - High
                        // 3 - Low
                        // 4 - Median
                        // 5 - Typical
                        // 6 - Weighted  
extern int Length2=20;
extern int Signal_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern int Signal_Length=20;

double B1[], B2[], Sig[];

int init()
{
 IndicatorShortName("Mirror MA oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,B1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,B2);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Sig);

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
  MA1=iMA(NULL, 0, Length1, 0, Method1, Price1, pos);
  MA2=iMA(NULL, 0, Length2, 0, Method2, Price2, pos);
  
  B1[pos]=MA1-MA2;
  B2[pos]=MA2-MA1;

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Sig[pos]=iMAOnArray(B1, 0, Signal_Length, 0, Signal_Method, pos);

  pos--;
 }
   
 return(0);
}

