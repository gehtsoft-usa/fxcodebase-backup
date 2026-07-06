//+------------------------------------------------------------------+
//|                                                          KRI.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;

double KRI[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,KRI);

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
 double mvaValue;
 double Pr;
 pos=limit;
 while(pos>=0)
 {
  mvaValue=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_CLOSE, pos);
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_CLOSE, pos);
  
  if (mvaValue!=0.)
  {
   KRI[pos]=100.*(Pr-mvaValue)/mvaValue;
  }

  pos--;
 } 
 return(0);
}

