//+------------------------------------------------------------------+
//|                                   Linear_Regression_Reversal.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=20;
extern int Dot_Size=3;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double LRR[], Cross[];
double Pr[], LR[];

int init()
{
 IndicatorShortName("Linear Regression Reversal");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,LRR);
 SetIndexBuffer(1,Cross);   
 SetIndexStyle(1,DRAW_ARROW,0,Dot_Size);
 SetIndexArrow(1,119);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Pr);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,LR);

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
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);

  pos--;
 } 

 double x, y, xy, x2;
 int i;
 double Temp, m, yint;
 
 pos=limit;
 while(pos>=0)
 {
  x=0; y=0; xy=0; x2=0;
  for (i=0;i<Length;i++)
  {
   y=y+Pr[pos+i];
   xy=xy+Pr[pos+i]*i;
   x=x+i;
   x2=x2+i*i;
  }
  Temp=Length*x2-x*x;
  m=(Length*xy-x*y)/Temp;
  yint=(y+m*x)/Length;
  LR[pos]=yint-m*Length;
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (LR[pos]>LR[pos+1])
  {
   LRR[pos]=1.;
  }
  else
  {
   if (LR[pos]<LR[pos+1])
   {
    LRR[pos]=-1.;
   }
   else
   {
    LRR[pos]=0.;
   }
  }
  
  if (LRR[pos]*LRR[pos+1]==-1.)
  {
   Cross[pos]=0.;
  }
  else
  {
   Cross[pos]=EMPTY_VALUE;
  }

  pos--;
 }
 
 return(0);
}

