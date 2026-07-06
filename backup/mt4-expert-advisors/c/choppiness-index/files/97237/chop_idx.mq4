//+------------------------------------------------------------------+
//|                                                     chop_idx.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=14;
extern double Trend_Level=38.2;
extern double Choppy_Level=61.8;
extern double Consolidation_Level=100.;
extern bool Show_Consolidation_Level=true;
extern bool Show_Zero_Level=true;

double CI[];
double ATR[];
double l10x;

int init()
{
 IndicatorShortName("Choppiness Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,ATR);
 
 if (Show_Consolidation_Level)
 {
  SetLevelValue(0, Consolidation_Level);
 }
 if (Show_Zero_Level)
 {
  SetLevelValue(1, 0.);
 }
 SetLevelValue(2, Trend_Level);
 SetLevelValue(3, Choppy_Level);
 
 l10x=MathLog10(0.+Length);

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
  ATR[pos]=iATR(NULL, 0, 1, pos);

  pos--;
 } 
 
 double ll, hh;
 double s;
 pos=limit;
 while(pos>=0)
 {
  ll=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  hh=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  s=Length*iMAOnArray(ATR, 0, Length, 0, MODE_SMA, pos);
  
  if (hh!=ll)
  {
   CI[pos]=100.*MathLog10(s/(hh-ll))/l10x;
  }

  pos--;
 }
   
 return(0);
}

