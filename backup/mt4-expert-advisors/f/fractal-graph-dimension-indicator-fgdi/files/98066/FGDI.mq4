//+------------------------------------------------------------------+
//|                                                         FGDI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_color5 Blue
#property indicator_color6 Red

extern int Length=30;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern double Random_Line=1.5;                       

double B1[], B1DN[], B2[], B2DN[], B3[], B3DN[];
double Pr[];
double Log2, LogLength;

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,B1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,B1DN);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,B2);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,B2DN);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,B3);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,B3DN);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,Pr);
 
 SetLevelValue(0., Random_Line);
 
 Log2=MathLog(2.);
 LogLength=MathLog(2.*(Length-1.));

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
 
 double Min, Max;
 double diff, priordiff, len;
 double sum, delta, variance, fdi, mean, stddev;
 int i;
 pos=limit;
 while(pos>=0)
 {
  Min=Pr[ArrayMinimum(Pr, Length, pos)];
  Max=Pr[ArrayMaximum(Pr, Length, pos)];
  
  priordiff=0.;
  len=0.;
  if (Min!=Max)
  {
   for (i=pos+Length-1;i>=pos;i--)
   {
    diff=(Pr[i]-Min)/(Max-Min);
    if (i!=pos+Length-1)
    {
     len=len+MathSqrt(MathPow(diff-priordiff, 2.)+1./MathPow(Length, 2.));
    }
    priordiff=diff;
   }
  } 
  
  sum=0.;
  if (len>0.)
  {
   fdi=1.+(MathLog(len)+Log2)/LogLength;
   mean=len/(Length-1.);
   
   if (Max!=Min)
   for (i=pos+Length-1;i>=pos;i--)
   {
    diff=(Pr[i]-Min)/(Max-Min);
    if (i!=pos+Length-1)
    {
     delta=MathSqrt(MathPow(diff-priordiff, 2)+1./MathPow(Length, 2.));
     sum=sum+MathPow(delta-len/(Length-1.), 2.);
    } 
    priordiff=diff;
   }
   variance=sum/(MathPow(len, 2.)*LogLength*LogLength);
  }
  else
  {
   fdi=0.;
   variance=0.;
  }
  
  stddev=MathSqrt(variance);
  
  B1[pos]=fdi;
  B2[pos]=fdi+stddev;
  B3[pos]=fdi-stddev;
  
  if (B1[pos]<Random_Line)
  {
   B1DN[pos]=B1[pos];
  }

  if (B2[pos]<Random_Line)
  {
   B2DN[pos]=B2[pos];
  }

  if (B3[pos]<Random_Line)
  {
   B3DN[pos]=B3[pos];
  }

  pos--;
 }
   
 return(0);
}

