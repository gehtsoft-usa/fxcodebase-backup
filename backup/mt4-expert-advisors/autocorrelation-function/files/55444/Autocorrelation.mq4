//+------------------------------------------------------------------+
//|                                              Autocorrelation.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window

#property indicator_buffers 1
#property indicator_color1 Red

extern int Length=100;

double Buff[];

int init()
  {
   IndicatorShortName("Autocorrelation");
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Buff);

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   if (Bars<2*Length) return;
   int i1, i2;
   double sum, SKO;
   double sumx=0;
   double sumy=0;
   double v1=0;
   double v2=0;
   for (i1=0;i1<=Length;i1++)
   {
    SKO=SKO+Close[i1]*Close[i1];
    sumx=sumx+Time[i1]-Time[Length];
    sumy=sumy+Close[i1];
   }
   SKO=SKO/Length;
   sumx=sumx/(Length+1);
   sumy=sumy/(Length+1);
   for (i1=0;i1<Length;i1++)
   {
    v1=v1+(Time[i1]-Time[Length]-sumx)*(Close[i1]-sumy);
    v2=v2+(Time[i1]-Time[Length]-sumx)*(Time[i1]-Time[Length]-sumx);
   }
   v1=v1/v2;
   v2=sumy-v1*sumx;
   
   for (i1=0;i1<=Length;i1++)
   {
    sum=0;
    for (i2=0;i2<=Length;i2++)
    {
     if (i1+i2<=Length) sum=sum+(Close[i2]-v1*(Time[i2]-Time[Length])-v2)*(Close[i2+i1]-v1*(Time[i2+i1]-Time[Length])-v2);
    }
    Buff[i1]=sum/SKO;
   }
   
   for (i1=Length;i1>=0;i1--)
   {
    Buff[i1]=Buff[i1]/Buff[0];
   }

   return(0);
  }

