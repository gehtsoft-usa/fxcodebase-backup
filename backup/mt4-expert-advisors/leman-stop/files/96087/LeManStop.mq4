//+------------------------------------------------------------------+
//|                                                    LeManStop.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=24;
extern int Coeff=4;
extern int Fast_MA_Length=9;
extern int Fast_MA_Method=0;  // 0 - SMA
                              // 1 - EMA
                              // 2 - SMMA
                              // 3 - LWMA
extern int Slow_MA_Length=18;
extern int Slow_MA_Method=0;  // 0 - SMA
                              // 1 - EMA
                              // 2 - SMMA
                              // 3 - LWMA

double LeMan[], LeManDn[];
double HO[], OL[];

int init()
{
 IndicatorShortName("LeMan Stop");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,LeMan);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,LeManDn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,HO);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,OL);

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
  HO[pos]=High[pos]-Open[pos];
  OL[pos]=Open[pos]-Low[pos];

  pos--;
 } 
 
 double EMA0, EMA1, PreStop, x, Stop;
 pos=limit;
 while(pos>=0)
 {
  EMA0=iMA(NULL, 0, Fast_MA_Length, 0, Fast_MA_Method, PRICE_CLOSE, pos)-iMA(NULL, 0, Slow_MA_Length, 0, Slow_MA_Method, PRICE_CLOSE, pos);
  EMA1=iMA(NULL, 0, Fast_MA_Length, 0, Fast_MA_Method, PRICE_CLOSE, pos+1)-iMA(NULL, 0, Slow_MA_Length, 0, Slow_MA_Method, PRICE_CLOSE, pos+1);
  PreStop=LeMan[pos+1];
  Stop=PreStop;
  
  if (EMA0>0.)
  {
   x=iMAOnArray(HO, 0, Length, 0, MODE_SMA, pos);
   Stop=Open[pos]-Coeff*x;
   if (Stop<PreStop && EMA1>0.)
   {
    Stop=PreStop;
   }
  }
  else
  {
   if (EMA0<0.)
   {
    x=iMAOnArray(OL, 0, Length, 0, MODE_SMA, pos);
    Stop=Open[pos+1]+Coeff*x;
    if (Stop>PreStop && EMA1<0.)
    {
     Stop=PreStop;
    }
   }
  }
  
  LeMan[pos]=Stop;
  
  if (LeMan[pos]>Close[pos])
  {
   LeManDn[pos]=LeMan[pos];
   LeManDn[pos+1]=LeMan[pos+1];
  }
  else
  {
   LeManDn[pos]=EMPTY_VALUE;
  }

  pos--;
 }
   
 return(0);
}

