//+------------------------------------------------------------------+
//|                                             Lentz_Volatility.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int ATR_Length=20;
extern int MA_Method=1;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
extern int MA_Length=20;

double LV_Up[], LV_Dn[];
double ATR[];

int init()
{
 IndicatorShortName("Lentz Volatility oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,LV_Up);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,LV_Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,ATR);

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
  ATR[pos]=iATR(NULL, 0, ATR_Length, pos);

  pos--;
 } 
 
 double MA;
 pos=limit;
 while(pos>=0)
 {
  MA=iMAOnArray(ATR, 0, MA_Length, 0, MA_Method, pos);
  if (MA>ATR[pos])
  {
   LV_Up[pos]=(MA-ATR[pos])/Point;
   LV_Dn[pos]=0.;
  }
  else
  {
   LV_Up[pos]=0.;
   LV_Dn[pos]=(MA-ATR[pos])/Point;
  }

  pos--;
 }
   
 return(0);
}

