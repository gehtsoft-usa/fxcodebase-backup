//+------------------------------------------------------------------+
//|                                                          FDI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Yellow

extern int Length=30;
extern int Average_Length=20;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double FDI[];
double Smooth[], Ratio[], Pr[];
double ML2;

int init()
{
 IndicatorShortName("Fractal dimension indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,FDI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Smooth);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Ratio);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Pr);
 
 ML2=MathLog(2.);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Average_Length) return(0);
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
  Smooth[pos]=(Pr[pos]+2.*Pr[pos+1]+2.*Pr[pos+2]+Pr[pos+3])/6.;

  pos--;
 }
 
 double Min, Max;
 double N1, N2, N3;
 pos=limit;
 while(pos>=0)
 {
  Min=Smooth[ArrayMinimum(Smooth, Length, pos)];
  Max=Smooth[ArrayMaximum(Smooth, Length, pos)];
  N3=(Max-Min)/Length;

  Min=Smooth[ArrayMinimum(Smooth, Length/2, pos)];
  Max=Smooth[ArrayMaximum(Smooth, Length/2, pos)];
  N1=2.*(Max-Min)/Length;

  if (pos+Length/2<Bars-2)
  {
   Min=Smooth[ArrayMinimum(Smooth, Length/2, pos+Length/2)];
   Max=Smooth[ArrayMaximum(Smooth, Length/2, pos+Length/2)];
   N2=2.*(Max-Min)/Length;
   
   if (FDI[pos+1]<1000000.)
   {
    Ratio[pos]=0.5*((MathLog(N1+N2)-MathLog(N3))/ML2+FDI[pos+1]);
   }
   else
   {
    Ratio[pos]=0.5*((MathLog(N1+N2)-MathLog(N3))/ML2);
   } 
  } 

  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  FDI[pos]=iMAOnArray(Ratio, 0, Average_Length, 0, MODE_SMA, pos);

  pos--;
 }  
   
 return(0);
}

