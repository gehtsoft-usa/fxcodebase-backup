//+------------------------------------------------------------------+
//|                                               Cumulative_RSI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int RSI_Length=2;
extern int RSI_Accumulation=2;
extern double Oversold_Level=35.;
extern double Overbought_Level=65.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double CRSI[];
double RSI[];

int init()
{
 IndicatorShortName("Cumulative RSI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CRSI);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,RSI);

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
  RSI[pos]=iRSI(NULL, 0, RSI_Length, Price, pos);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  CRSI[pos]=iMAOnArray(RSI, 0, RSI_Accumulation, 0, MODE_SMA, pos)*RSI_Accumulation;

  pos--;
 }
   
 return(0);
}

