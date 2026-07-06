//+------------------------------------------------------------------+
//|                                                         WRSI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Yellow

extern int Length=14;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted
extern double OverBoughtLevel=70;
extern double OverSoldLevel=30;
extern int LevelWidth=1;
extern color LevelColor=Gray;                        

double WRSI[];
double posa[], nega[], positive[], negative[];
double k;

int init()
{
 IndicatorShortName("Wilder's RSI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,WRSI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,posa);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,nega);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,positive);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,negative);

 SetLevelValue(0, 50.);
 SetLevelValue(1, OverBoughtLevel);
 SetLevelValue(2, OverSoldLevel);
 SetLevelValue(3, 0.);
 SetLevelValue(4, 100.);
 SetLevelStyle(EMPTY, LevelWidth, LevelColor);
 
 k=1./Length;
 
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
 double Pr0, Pr1, diff;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  diff=Pr0-Pr1;
  
  posa[pos]=0.;
  nega[pos]=0.;
  if (diff>0.)
  {
   posa[pos]=diff;
  }
  else
  {
   if (diff<0.)
   {
    nega[pos]=-diff;
   }
  }

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2-Length)
  {
   positive[pos]=iMAOnArray(posa, 0, Length, 0, MODE_SMA, pos);
   negative[pos]=iMAOnArray(nega, 0, Length, 0, MODE_SMA, pos);
  }
  else
  {
   if (pos<Bars-2-Length)
   {
    positive[pos]=k*(posa[pos]-positive[pos+1])+positive[pos+1];
    negative[pos]=k*(nega[pos]-negative[pos+1])+negative[pos+1];
   }
  }
  
  if (negative[pos]!=0.)
  {
   WRSI[pos]=100.-100./(1.+positive[pos]/negative[pos]);
  } 

  pos--;
 }
   
 return(0);
}

