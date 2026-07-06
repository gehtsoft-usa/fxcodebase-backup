//+------------------------------------------------------------------+
//|                                                          RSS.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Short_Length=10;
extern int Long_Length=50;
extern int RSI_Length=5;
extern int Smoothing_Length=5;
extern double OverBoughtLevel=70;
extern double OverSoldLevel=30;
extern int LevelWidth=1;
extern color LevelColor=Gray;                        
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted 

double RSS[];
double Spread[], RSI[];

int init()
{
 IndicatorShortName("Relative Spread Strength");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,RSS);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Spread);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,RSI);

 SetLevelValue(0, 50);
 SetLevelValue(1, OverBoughtLevel);
 SetLevelValue(2, OverSoldLevel);
 SetLevelStyle(EMPTY, LevelWidth, LevelColor);

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
 double Short_MA, Long_MA;
 pos=limit;
 while(pos>=0)
 {
  Short_MA=iMA(NULL, 0, Short_Length, 0, MODE_EMA, Price, pos);
  Long_MA=iMA(NULL, 0, Long_Length, 0, MODE_EMA, Price, pos);
  Spread[pos]=Short_MA-Long_MA;

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  RSI[pos]=iRSIOnArray(Spread, 0, RSI_Length, pos);

  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  RSS[pos]=iMAOnArray(RSI, 0, Smoothing_Length, 0, MODE_SMA, pos);

  pos--;
 }  
   
 return(0);
}

