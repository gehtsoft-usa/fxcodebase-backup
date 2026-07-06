//+------------------------------------------------------------------+
//|                                                  MA_Sequence.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Yellow

extern bool Enable_Filter1=true;
extern bool Enable_Filter2=true;
extern bool Enable_Filter3=true;
extern int MA1_Length=10;
extern int MA1_Method=1;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int MA2_Length=20;
extern int MA2_Method=1;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int MA3_Length=50;
extern int MA3_Method=1;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int MA4_Length=200;
extern int MA4_Method=1;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double H1[], H2[], H3[];

int init()
{
 IndicatorShortName("MA Sequence");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,H1);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,H2);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,H3);

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
 double MA1, MA2, MA3, MA4;
 pos=limit;
 while(pos>=0)
 {
  MA1=iMA(NULL, 0, MA1_Length, 0, MA1_Method, Price, pos);
  MA2=iMA(NULL, 0, MA2_Length, 0, MA2_Method, Price, pos);
  MA3=iMA(NULL, 0, MA3_Length, 0, MA3_Method, Price, pos);
  MA4=iMA(NULL, 0, MA4_Length, 0, MA4_Method, Price, pos);
  
  H1[pos]=0.;
  H2[pos]=0.;
  H3[pos]=0.;
  
  if ((MA1>MA2 || !Enable_Filter1) && (MA2>MA3 || !Enable_Filter2) && (MA3>MA4 || !Enable_Filter3) && (Enable_Filter1 || Enable_Filter2 || Enable_Filter3))
  {
   H1[pos]=1.;
  }
  else
  {
   if ((MA1<MA2 || !Enable_Filter1) && (MA2<MA3 || !Enable_Filter2) && (MA3<MA4 || !Enable_Filter3) && (Enable_Filter1 || Enable_Filter2 || Enable_Filter3))
   {
    H2[pos]=1.;
   }
   else
   {
    H3[pos]=1.;
   }
  }

  pos--;
 } 
 return(0);
}

