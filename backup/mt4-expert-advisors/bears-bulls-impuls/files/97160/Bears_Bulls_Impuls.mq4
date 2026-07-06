//+------------------------------------------------------------------+
//|                                           Bears_Bulls_Impuls.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=13;
extern int Type=0;    // Applied price
                      // 0 - Close
                      // 1 - Open
                      // 2 - High
                      // 3 - Low
                      // 4 - Median
                      // 5 - Typical
                      // 6 - Weighted

double Bulls[], Bears[];

int init()
{
 IndicatorShortName("Bears Bulls Impuls");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Bulls);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Bears);

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
 double EMA;
 double Bu, Be, res;
 pos=limit;
 while(pos>=0)
 {
  EMA=iMA(NULL, 0, Length, 0, MODE_EMA, Type, pos);
  
  Bu=High[pos]-EMA;
  Be=Low[pos]-EMA;
  res=Bu+Be;
  
  if (res>0.)
  {
   Bulls[pos]=1.;
   Bears[pos]=-1.;
  }
  else
  {
   Bulls[pos]=-1.;
   Bears[pos]=1.;
  }

  pos--;
 } 
 return(0);
}

