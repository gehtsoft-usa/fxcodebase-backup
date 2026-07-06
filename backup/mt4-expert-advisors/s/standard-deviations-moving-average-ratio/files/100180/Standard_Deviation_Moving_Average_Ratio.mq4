//+------------------------------------------------------------------+
//|                      Standard_Deviation_Moving_Average_Ratio.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

#property indicator_style1 STYLE_SOLID

extern int Length=20;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Ratio[];

int init()
{
 IndicatorShortName("Standard Deviations Moving Average Ratio");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Ratio);

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
 double StdDev;
 double MA;
 pos=limit;
 while(pos>=0)
 {
  StdDev=iStdDev(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  MA=iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  
  if (MA!=0.)
  {
   Ratio[pos]=StdDev/MA;
  }

  pos--;
 } 
 return(0);
}

