//+------------------------------------------------------------------+
//|                                                    Slingshot.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length1=14;
extern int Price1=0;    // Applied price
                        // 0 - Close
                        // 1 - Open
                        // 2 - High
                        // 3 - Low
                        // 4 - Median
                        // 5 - Typical
                        // 6 - Weighted  
extern int Length2=14;
extern int Price2=3;    // Applied price
                        // 0 - Close
                        // 1 - Open
                        // 2 - High
                        // 3 - Low
                        // 4 - Median
                        // 5 - Typical
                        // 6 - Weighted  

double B1[], B2[];

int init()
{
 IndicatorShortName("Slingshot oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,B1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,B2);

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
 double Pr10, Pr11, Pr20, Pr21;
 pos=limit;
 while(pos>=0)
 {
  Pr10=iMA(NULL, 0, 1, 0, MODE_SMA, Price1, pos);
  Pr11=iMA(NULL, 0, 1, 0, MODE_SMA, Price1, pos+Length1);
  Pr20=iMA(NULL, 0, 1, 0, MODE_SMA, Price2, pos);
  Pr21=iMA(NULL, 0, 1, 0, MODE_SMA, Price2, pos+Length2);
  
  B1[pos]=Pr10-Pr11;
  B2[pos]=Pr20-Pr21;

  pos--;
 } 
 return(0);
}

