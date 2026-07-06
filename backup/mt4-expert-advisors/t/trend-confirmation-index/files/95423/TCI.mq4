//+------------------------------------------------------------------+
//|                                                          TCI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Blue

extern int Length=14;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern double OverBoughtLevel=70;
extern double OverSoldLevel=30;
extern int LevelWidth=1;
extern color LevelColor=Gray;                        
extern bool ShowActual=false;
extern int ActualSize=2;

double TCI[], Raw[];

int init()
{
 IndicatorShortName("Trend Confirmation Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TCI);
 
 SetIndexBuffer(1,Raw);
 if (ShowActual)
 {
  SetIndexStyle(1,DRAW_ARROW,0,ActualSize);
  SetIndexArrow(1,119);
 }
 else
 {
  SetIndexStyle(1,DRAW_NONE);
 }

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
 pos=limit;
 while(pos>=0)
 {
  if (High[pos]-Low[pos]!=0.)
  {
   Raw[pos]=100.*(Close[pos]-Low[pos])/(High[pos]-Low[pos]);
  }
  else
  {
   Raw[pos]=0.;
  } 

  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  TCI[pos]=iMAOnArray(Raw, 0, Length, 0, Method, pos);

  pos--;
 }  
 
 return(0);
}

