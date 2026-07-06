// Id: 9685
//+------------------------------------------------------------------+
//|                                                      LR_MACD.mq4 |
//|                               Copyright � 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green

extern int ShortLength=12;
extern int LongLength=26;
extern int SignalMethod=1;  // 0 - SMA
                            // 1 - EMA
                            // 2 - SMMA
                            // 3 - LWMA
extern int SignalLength=9;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
                       

double MACD[], Signal[], Histogram[];

int init()
{
     double temp = iCustom(NULL, 0, "LRL", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'LRL' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Linear regression MACD");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MACD);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,Histogram);
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=ShortLength || Bars<=LongLength) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 double Short_LR, Long_LR;
 pos=limit;
 while(pos>=0)
 {
  Short_LR=iCustom(NULL, 0, "LRL", ShortLength, Price, 0, pos);
  Long_LR=iCustom(NULL, 0, "LRL", LongLength, Price, 0, pos);
  MACD[pos]=Short_LR-Long_LR;
  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(MACD, 0, SignalLength, 0, SignalMethod, pos);
  Histogram[pos]=MACD[pos]-Signal[pos];
  pos--;
 }  

 return(0);
}

