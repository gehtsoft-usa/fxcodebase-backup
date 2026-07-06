//+------------------------------------------------------------------+
//|                                                 VolatilityMA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow

extern int Lookback=300;
extern double Barrier=2.;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double VolMA[];
double Pr[], Raw[], Length[];

int init()
{
 IndicatorShortName("Volatility moving average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,VolMA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Pr);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Raw);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Length);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Lookback) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  Raw[pos]=(Pr[pos]-Pr[pos+1])/Pr[pos];
  
  pos--;
 } 

 double Average, Variance, sDev, sDevNow;
 int i;
 pos=limit;
 while(pos>=0)
 {
  Average=iMAOnArray(Raw, 0, Lookback, 0, MODE_SMA, pos);
  Variance=0.;
  for (i=0;i<=Lookback;i++)
  {
   Variance=Variance+MathPow(Raw[pos+i]+Average, 2);
  }
  sDev=MathSqrt(Variance/Lookback);
  sDevNow=Raw[pos]/(Pr[pos]*sDev);
  if (MathAbs(sDevNow)>Barrier)
  {
   Length[pos]=1;
  }
  else
  {
   Length[pos]=Length[pos+1]+1;
  }
  VolMA[pos]=iMAOnArray(Pr, 0, Length[pos], 0, MODE_SMA, pos);
  
  pos--;
 } 
 return(0);
}

