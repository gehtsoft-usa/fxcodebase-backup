//+------------------------------------------------------------------+
//|                                                          DMX.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=14;
extern int Smoothing_Length=5;
extern int Smoothing_Method=0;  // 0 - SMA
                                // 1 - EMA
                                // 2 - SMMA
                                // 3 - LWMA
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double DMX[], Signal[];

int init()
{
 IndicatorShortName("Bipolar DMI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,DMX);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);

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
 double DMI_P, DMI_M;
 double Sum;
 pos=limit;
 while(pos>=0)
 {
  DMI_P=iADX(NULL, 0, Length, Price, MODE_PLUSDI, pos);
  DMI_M=iADX(NULL, 0, Length, Price, MODE_MINUSDI, pos);
  Sum=DMI_P+DMI_M;
  if (Sum!=0.)
  {
   DMX[pos]=(DMI_P-DMI_M)/Sum;
  }

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(DMX, 0, Smoothing_Length, 0, Smoothing_Method, pos);

  pos--;
 }
   
 return(0);
}

