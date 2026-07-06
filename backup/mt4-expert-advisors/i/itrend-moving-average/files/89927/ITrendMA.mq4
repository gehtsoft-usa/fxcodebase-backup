//+------------------------------------------------------------------+
//|                                                     ITrendMA.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
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

double ITrend_MA[];
double Pr[];

double Alpha;
double c1, c2, c3, c4, c5;

int init()
{
 IndicatorShortName("ITrend Moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ITrend_MA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Pr);

 Alpha=2./(Length+1.); 
 c1=Alpha-Alpha*Alpha/4;
 c2=Alpha*Alpha/2;
 c3=Alpha-0.75*Alpha*Alpha;
 c4=2*(1-Alpha);
 c5=(1-Alpha)*(1-Alpha);
 
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
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (pos>Bars-6)
  {
   ITrend_MA[pos]=(Pr[pos]+2*Pr[pos+1]+Pr[pos+2])/4;
  }
  else
  {
   ITrend_MA[pos]=c1*Pr[pos]+c2*Pr[pos+1]-c3*Pr[pos+2]+c4*ITrend_MA[pos+1]-c5*ITrend_MA[pos+2];
  } 
  pos--;
 }  
 
 return(0);
}

