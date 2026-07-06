//+------------------------------------------------------------------+
//|                                                   Custom_CCI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;
extern double OverBoughtLevel1=100;
extern double OverSoldLevel1=-100;
extern double OverBoughtLevel2=250;
extern double OverSoldLevel2=-250;
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

double CCI[];

int init()
{
 IndicatorShortName("Custom CCI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CCI);
 
 SetLevelValue(0, 0);
 SetLevelValue(1, OverBoughtLevel1);
 SetLevelValue(2, OverSoldLevel1);
 SetLevelValue(3, OverBoughtLevel2);
 SetLevelValue(4, OverSoldLevel2);
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
 pos=limit;
 while(pos>=0)
 {
  CCI[pos]=iCCI(NULL, 0, Length, Price, pos);

  pos--;
 } 
 return(0);
}

