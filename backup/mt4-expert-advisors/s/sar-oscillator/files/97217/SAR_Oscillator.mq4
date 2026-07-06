//+------------------------------------------------------------------+
//|                                               SAR_Oscillator.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern double SAR_Step=0.02;
extern double SAR_Max=0.2;
extern int MA_Length=7;

double SARO[], SARO_Dn[];
double CloseSAR[];

int init()
{
 IndicatorShortName("SAR Oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,SARO);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,SARO_Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,CloseSAR);

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
 double SAR;
 pos=limit;
 while(pos>=0)
 {
  SAR=iSAR(NULL, 0, SAR_Step, SAR_Max, pos);
  CloseSAR[pos]=Close[pos]-SAR;

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  SARO[pos]=iMAOnArray(CloseSAR, 0, MA_Length, 0, MODE_SMA, pos);
  
  if (SARO[pos]>SARO[pos+1])
  {
   SARO_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   SARO_Dn[pos]=SARO[pos];
  }

  pos--;
 }
   
 return(0);
}

