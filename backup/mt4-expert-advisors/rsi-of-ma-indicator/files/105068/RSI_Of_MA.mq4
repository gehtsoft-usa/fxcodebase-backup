//+------------------------------------------------------------------+
//|                                                    RSI_Of_MA.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int MA_Length=14;
extern int RSI_Length=21;
extern int MA_RSI_Length=15;

double MA_RSI[];
double MA[], RSI[];

int init()
{
 IndicatorShortName("RSI of MA");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MA_RSI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,MA);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,RSI);

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
 pos=limit;
 while(pos>=0)
 {
  MA[pos]=iMA(NULL, 0, MA_Length, 0, MODE_EMA, Price, pos);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  RSI[pos]=iRSIOnArray(MA, 0, RSI_Length, pos);

  pos--;
 }
   
 pos=limit;
 while(pos>=0)
 {
  MA_RSI[pos]=iMAOnArray(RSI, 0, MA_RSI_Length, 0, MODE_EMA, pos);

  pos--;
 }
  
 return(0);
}

