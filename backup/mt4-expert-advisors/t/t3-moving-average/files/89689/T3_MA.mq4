//+------------------------------------------------------------------+
//|                                                        T3_MA.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Yellow

extern int Length=10;
extern double b=0.88;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double T3_MA[];
double e1[], e2[], e3[], e4[], e5[], e6[];

double c1, c2, c3, c4, w1, w2;

int init()
{
 IndicatorShortName("T3 moving average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,T3_MA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,e1);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,e2);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,e3);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,e4);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,e5);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,e6);
 
 double b2, b3;
 b2=b*b;
 b3=b2*b;
 w1=4./(3.+Length);
 w2=1.-w1;
 c1=-b3;
 c2=3*(b2+b3);
 c3=-3*(2*b2+b+b3);
 c4=1+3*b+b3+3*b2;
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
  double Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  e1[pos]=w1*Pr+w2*e1[pos+1];
  e2[pos]=w1*e1[pos]+w2*e2[pos+1];
  e3[pos]=w1*e2[pos]+w2*e3[pos+1];
  e4[pos]=w1*e3[pos]+w2*e4[pos+1];
  e5[pos]=w1*e4[pos]+w2*e5[pos+1];
  e6[pos]=w1*e5[pos]+w2*e6[pos+1];
  T3_MA[pos]=c1*e6[pos]+c2*e5[pos]+c3*e4[pos]+c4*e3[pos];
  pos--;
 } 
 return(0);
}

