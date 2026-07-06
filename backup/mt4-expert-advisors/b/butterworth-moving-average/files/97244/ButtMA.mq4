//+------------------------------------------------------------------+
//|                                                       ButtMA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
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

double ButtMA[];
double p1, p2, p3, Kf;

int init()
{
 IndicatorShortName("Butterworth Moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ButtMA);
 
 p1=2./(1.+Length);
 Kf=MathSqrt(p1);
 p2=2.*(1.-Kf);
 p3=(1.-Kf)*(1.-Kf);

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
 double Pr;
 pos=limit;
 while(pos>=0)
 {
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  if (pos==Bars-2)
  {
   ButtMA[pos]=Pr;
  }
  else
  {
   ButtMA[pos]=p1*Pr+p2*ButtMA[pos+1]-p3*ButtMA[pos+2];
  }

  pos--;
 } 
 return(0);
}

