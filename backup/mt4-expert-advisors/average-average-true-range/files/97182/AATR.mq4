//+------------------------------------------------------------------+
//|                                                         AATR.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int ATR_Length=14;
extern int MA_Length=50;

double AATR[], AATR_Dn[];
double ATR[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,AATR);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,AATR_Dn);
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
 
 pos=limit;
 while(pos>=0)
 {
  AATR[pos]=iMAOnArray(ATR, 0, MA_Length, 0, MODE_SMA, pos);
  
  if (AATR[pos]>AATR[pos+1])
  {
   AATR_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   AATR_Dn[pos]=AATR[pos];
  }

  pos--;
 }
   
 return(0);
}

