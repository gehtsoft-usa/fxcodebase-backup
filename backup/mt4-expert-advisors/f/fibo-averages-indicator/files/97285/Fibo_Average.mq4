//+------------------------------------------------------------------+
//|                                                 Fibo_Average.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Red

extern int Fibo_Count=11;
extern int MA_Method=0;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
extern int MA_Length=55;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double Fibo[], FiMA[];
double Pr[];
int FiboNumbers[];

int init()
{
 IndicatorShortName("Fibo averages indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Fibo);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,FiMA);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Pr);

 ArrayResize(FiboNumbers, Fibo_Count+1);
 FiboNumbers[1]=0;
 FiboNumbers[2]=1;
 int i;
 for (i=3;i<=Fibo_Count;i++)
 {
  FiboNumbers[i]=FiboNumbers[i-1]+FiboNumbers[i-2];
 }
 
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
 double Sum;
 int i;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
 
  pos--;
 }
  
 pos=limit;
 while(pos>=0)
 {
  Sum=0.;
  for (i=1;i<=Fibo_Count;i++)
  {
   Sum=Sum+Pr[pos+FiboNumbers[i]];
  }
  Fibo[pos]=Sum/Fibo_Count;

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  FiMA[pos]=iMAOnArray(Fibo, 0, MA_Length, 0, MA_Method, pos);

  pos--;
 }
   
 return(0);
}

