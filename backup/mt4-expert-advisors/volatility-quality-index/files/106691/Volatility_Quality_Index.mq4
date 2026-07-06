//+------------------------------------------------------------------+
//|                                     Volatility_Quality_Index.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=7;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Smoothing=1;
extern int Filter=5;

double UP[], DN[];
double VQ[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,DN);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,VQ);

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
 double h, l, o, c, c2, Max;
 double VQnew;
 pos=limit;
 while(pos>=0)
 {
  h=iMA(NULL, 0, Length, 0, Method, PRICE_HIGH, pos);
  l=iMA(NULL, 0, Length, 0, Method, PRICE_LOW, pos);
  o=iMA(NULL, 0, Length, 0, Method, PRICE_OPEN, pos);
  c=iMA(NULL, 0, Length, 0, Method, PRICE_CLOSE, pos);
  c2=iMA(NULL, 0, Length, 0, Method, PRICE_CLOSE, pos+Smoothing);
  
  Max=MathMax(h-l, MathMax(h-c2, c2-l));
  
  if (Max!=0. && h-l!=0.)
  {
   VQnew=MathAbs(((c-c2)/Max+(c-o)/(h-l))*0.5)*((c-c2+(c-o))*0.5);
  
   if (MathAbs(VQnew)<Filter*Point)
   {
    VQ[pos]=VQ[pos+1];
   }
   else
   {
    VQ[pos]=VQnew;
   }
  
   if (VQ[pos]>0.)
   {
    UP[pos]=1.;
    DN[pos]=0.;
   }
   else
   {
    UP[pos]=0.;
    DN[pos]=1.;
   } 
  }

  pos--;
 } 
 return(0);
}

