//+------------------------------------------------------------------+
//|                                                      Mod_WMA.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=20;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double Mod_WMA[];

double k;

int init()
{
 IndicatorShortName("Modified Wilders smooting average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Mod_WMA);
 
 k=1./Length;
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
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   Mod_WMA[pos]=iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  }
  else
  {
   Mod_WMA[pos]=(iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos)-Mod_WMA[pos+1])*k+Mod_WMA[pos+1];
  }
  pos--;
 } 
 return(0);
}

