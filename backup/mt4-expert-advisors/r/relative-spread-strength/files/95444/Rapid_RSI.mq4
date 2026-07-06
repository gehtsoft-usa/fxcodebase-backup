//+------------------------------------------------------------------+
//|                                                    Rapid_RSI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int RSI_Length=5;
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

double Rapid_RSI[];
double UP[], DN[];

int init()
{
 IndicatorShortName("Rapid_RSI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Rapid_RSI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,UP);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,DN);

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
 double Pr0, Pr1;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  if (Pr0>Pr1)
  {
   UP[pos]=Pr0-Pr1;
   DN[pos]=0.;
  }
  else
  {
   UP[pos]=0.;
   DN[pos]=Pr1-Pr0;
  }

  pos--;
 } 
 
 double UpSum, DnSum;
 double RS;
 pos=limit;
 while(pos>=0)
 {
  UpSum=iMAOnArray(UP, 0, RSI_Length, 0, MODE_SMA, pos);
  DnSum=iMAOnArray(DN, 0, RSI_Length, 0, MODE_SMA, pos);
  if (DnSum!=0.)
  {
   RS=UpSum/DnSum;
  }
  else
  {
   RS=0.;
  }
  
  Rapid_RSI[pos]=100.-100./(1.+RS);

  pos--;
 }
   
 return(0);
}

