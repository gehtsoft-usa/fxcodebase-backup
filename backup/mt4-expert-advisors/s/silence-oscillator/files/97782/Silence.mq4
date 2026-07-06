//+------------------------------------------------------------------+
//|                                                      Silence.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Red

extern int Length=12;
extern int Interpolation_Length=288;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Aggressiveness[], Volatility[];
double SizeArray[], Aggress[], Volat[], Pr[];

int init()
{
 IndicatorShortName("Silence oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Aggressiveness);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Volatility);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,SizeArray);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Aggress);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Volat);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,Pr);

 return(0);
}

int deinit()
{

 return(0);
}

double Inter(double a, double b, double c, double d, double X)
{
 if (a==b)
 {
  return (1000000.);
 }
 else
 {
  return (d-(b-X)*(d-c)/(b-a));
 }
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
  SizeArray[pos]=MathAbs(Pr[pos]-Pr[pos+1]);

  pos--;
 }
 
 double B, dAmount, Avg;
 int i;
 pos=limit;
 while(pos>=0)
 {
  B=iMAOnArray(SizeArray, 0, Length, 0, MODE_SMA, pos);
  dAmount=0.;
  Avg=iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  for (i=pos+Length-1;i>=pos;i--)
  {
   dAmount=dAmount+MathPow(Pr[i]-Avg, 2.);
  }
  dAmount=dAmount/Length;
  
  Aggress[pos]=B/Point;
  Volat[pos]=MathSqrt(dAmount);

  pos--;
 }  
 
 double Min, Max;
 pos=limit;
 while(pos>=0)
 {
  Min=Aggress[ArrayMinimum(Aggress, Interpolation_Length, pos)];
  Max=Aggress[ArrayMaximum(Aggress, Interpolation_Length, pos)];
  
  Aggressiveness[pos]=Inter(Max, Min, 100., 0., Aggress[pos]);

  Min=Volat[ArrayMinimum(Volat, Interpolation_Length, pos)];
  Max=Volat[ArrayMaximum(Volat, Interpolation_Length, pos)];
  
  Volatility[pos]=Inter(Max, Min, 100., 0., Volat[pos]);

  pos--;
 }  
   
 return(0);
}

