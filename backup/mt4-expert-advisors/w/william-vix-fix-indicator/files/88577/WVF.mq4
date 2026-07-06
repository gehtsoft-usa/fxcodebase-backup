//+------------------------------------------------------------------+
//|                                                          WVF.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=22;
extern bool ShowLine=true;

double WVF[];

int init()
{
 IndicatorShortName("William Vix Fix indicator");
 IndicatorDigits(Digits);
 if (ShowLine)
 {
  SetIndexStyle(0,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(0,DRAW_HISTOGRAM);
 } 
 SetIndexBuffer(0,WVF);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double Max;
 pos=limit;
 while(pos>=0)
 {
  Max=Close[iHighest(NULL, 0, MODE_CLOSE, Length, pos)];
  if (Max>0)
  {
   WVF[pos]=100*(Max-Low[pos])/Max;
  }
  else
  {
   WVF[pos]=0;
  } 
  pos--;
 } 
 return(0);
}

