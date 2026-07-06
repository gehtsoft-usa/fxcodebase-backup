//+------------------------------------------------------------------+
//|                                                 StdDev_Cross.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Magenta

extern int Length1=10;
extern int Method1=0;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern int Length2=20;                       
extern int Method2=0;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted
extern int DotSize=3;                        

double StdDev1[], StdDev2[], Cross_Up[], Cross_Dn[];

int init()
{
 IndicatorShortName("StdDev Cross");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,StdDev1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,StdDev2);
 SetIndexStyle(2,DRAW_ARROW,0,DotSize);
 SetIndexArrow(2,119);
 SetIndexBuffer(2,Cross_Up);
 SetIndexStyle(3,DRAW_ARROW,0,DotSize);
 SetIndexArrow(3,119);
 SetIndexBuffer(3,Cross_Dn);

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
 double MA1, MA2;
 double dAmount;
 int i;
 pos=limit;
 while(pos>=0)
 {
  MA1=iMA(NULL, 0, Length1, 0, Method1, Price, pos);
  MA2=iMA(NULL, 0, Length2, 0, Method2, Price, pos);
  
  dAmount=0.;
  for (i=0;i<=Length1;i++)
  {
   Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+i);
   dAmount=dAmount+(Pr-MA1)*(Pr-MA1);
  }
  StdDev1[pos]=MathSqrt(dAmount/(0.+Length1));

  dAmount=0.;
  for (i=0;i<=Length2;i++)
  {
   Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+i);
   dAmount=dAmount+(Pr-MA2)*(Pr-MA2);
  }
  StdDev2[pos]=MathSqrt(dAmount/(0.+Length2));
  
  if (StdDev1[pos+1]<StdDev2[pos+1] && StdDev1[pos]>=StdDev2[pos])
  {
   Cross_Up[pos]=(StdDev1[pos]+StdDev2[pos])/2.;
  }
  else
  {
   if (StdDev1[pos+1]>StdDev2[pos+1] && StdDev1[pos]<=StdDev2[pos])
   {
    Cross_Dn[pos]=(StdDev1[pos]+StdDev2[pos])/2.;
   }
  }

  pos--;
 } 
 return(0);
}

