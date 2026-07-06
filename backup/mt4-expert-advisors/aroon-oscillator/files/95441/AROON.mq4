//+------------------------------------------------------------------+
//|                                                        AROON.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

extern int Length=25;
extern double OverBoughtLevel=70;
extern double OverSoldLevel=30;
extern int LevelWidth=1;
extern color LevelColor=Gray;                        

double UP[], DN[];

int init()
{
 IndicatorShortName("AROON Indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,DN);

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
 int MinBar, MaxBar;
 pos=limit;
 while(pos>=0)
 {
  MinBar=iLowest(NULL, 0, MODE_LOW, Length, pos);
  MaxBar=iHighest(NULL, 0, MODE_HIGH, Length, pos);
  
  UP[pos]=100.*(Length-MaxBar+pos)/Length;
  DN[pos]=100.*(Length-MinBar+pos)/Length;

  pos--;
 } 
 return(0);
}

