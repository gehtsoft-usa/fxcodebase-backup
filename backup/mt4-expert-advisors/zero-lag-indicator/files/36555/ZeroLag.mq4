//+------------------------------------------------------------------+
//|                                                      ZeroLag.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=20;
extern int GainLimit=50;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double ZL[];
double Alpha;
double GainLimit10;

int init()
  {
   IndicatorShortName("Zero lag");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ZL);
   Alpha=2./(1.+Length);
   GainLimit10=(0.+GainLimit)/10.;
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
 int pos;
 double EMA, err, gain, diff;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  EMA=iMA(NULL, 0, Length, 0, MODE_EMA, Price, pos);
  err=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos)-ZL[pos+1];
  gain=0;
  if (MathAbs(Alpha*err)>0.000000001) 
  {
   diff=ZL[pos+1]-EMA;
   gain=(err+Alpha*diff)/(Alpha*err);
  }
  gain=MathMax(MathMin(gain,GainLimit10),-GainLimit10);
  if (gain>0)
  {
   gain=MathFloor(gain*10+0.5)/10;
  }
  else
  {
   gain=MathCeil(gain*10-0.5)/10;
  }
  ZL[pos]=Alpha*(EMA+gain*err)+(1-Alpha)*ZL[pos+1];
  pos--;
 } 

 return(0);
}

