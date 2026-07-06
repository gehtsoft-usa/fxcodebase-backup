//+------------------------------------------------------------------+
//|                                                Auto_Envelope.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red

extern int Length=22;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Factor=27;
extern int Deviation_Length=100;                      

double Central[], Top[], Bottom[];
double Raw[];

int init()
{
 IndicatorShortName("Auto Envelope");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Central);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Top);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Bottom);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Raw);

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
 double MA;
 pos=limit;
 while(pos>=0)
 {
  MA=iMA(NULL, 0, Length, 0, Method, PRICE_CLOSE, pos);
  if (MA!=0.)
  {
   Raw[pos]=2.*MathMax(MathAbs(High[pos]-MA), MathAbs(Low[pos]-MA))/MA;
   Central[pos]=MA;
  } 

  pos--;
 } 
 
 double StdDev, Csize, Channel;
 pos=limit;
 while(pos>=0)
 {
  StdDev=iStdDevOnArray(Raw, 0, Deviation_Length, 0, MODE_SMA, pos);
  Csize=StdDev*Factor/10.;
  Channel=Csize*Central[pos];
  Top[pos]=Central[pos]+Channel/2.;
  Bottom[pos]=Central[pos]-Channel/2.;

  pos--;
 }
   
 return(0);
}

