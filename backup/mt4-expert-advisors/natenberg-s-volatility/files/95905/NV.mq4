//+------------------------------------------------------------------+
//|                                                           NV.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=10;

double NV[];
double Raw[];
double Coeff;

int init()
{
 IndicatorShortName("Natenberg's Volatility");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,NV);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Raw);
 
 Coeff=MathSqrt(365.*1440./Period());

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
  if (Close[pos+1]!=0.)
  {
   Raw[pos]=MathLog(Close[pos]/Close[pos+1]);
  } 

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  NV[pos]=iStdDevOnArray(Raw, 0, Length, 0, MODE_SMA, pos)*Coeff;
 
  pos--;
 } 

 return(0);
}

