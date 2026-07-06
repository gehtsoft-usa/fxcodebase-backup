//+------------------------------------------------------------------+
//|                                                          NEF.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow

extern int Length=15;
extern int Momentum=5;
extern bool Use_Distance_Coeff=false;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted 

double EF[];
double Pr[], Coeff[], PriceCoeff[];

int init()
{
 IndicatorShortName("Nonlinear Ehlers Filter");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,EF);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Pr);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Coeff);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,PriceCoeff);

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
 
 pos=limit;
 while(pos>=0)
 {
  if (Use_Distance_Coeff)
  {
   Coeff[pos]=(Pr[pos]-Pr[pos+Momentum])*(Pr[pos]-Pr[pos+Momentum]);
  }
  else
  {
   Coeff[pos]=MathAbs(Pr[pos]-Pr[pos+Momentum]);
  } 
  PriceCoeff[pos]=Coeff[pos]*Pr[pos];

  pos--;
 }

 double AvgCoeff, AvgPriceCoeff;
 pos=limit;
 while(pos>=0)
 {
  AvgCoeff=iMAOnArray(Coeff, 0, Length, 0, MODE_SMA, pos);
  AvgPriceCoeff=iMAOnArray(PriceCoeff, 0, Length, 0, MODE_SMA, pos);
  if (AvgCoeff!=0.)
  {
   EF[pos]=AvgPriceCoeff/AvgCoeff;
  }
  else
  {
   EF[pos]=EMPTY_VALUE;
  }

  pos--;
 }
     
 return(0);
}

