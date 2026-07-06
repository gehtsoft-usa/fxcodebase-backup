//+------------------------------------------------------------------+
//|                                                         TTMS.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Gray

extern int BB_Length=20;
extern double BB_Deviation=2;
extern int Keltner_Length=20;
extern int Keltner_Smooth_Length=20;
extern int Keltner_Smooth_Method=0;  // 0 - SMA
                                     // 1 - EMA
                                     // 2 - SMMA
                                     // 3 - LWMA
extern double Keltner_Deviation=2;
extern int AlertSize=2;

double TTMS_Up[], TTMS_Dn[], NoAlert[], AAlert[];

int init()
{
 IndicatorShortName("TTM Squeeze");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,TTMS_Up);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,TTMS_Dn);
 SetIndexStyle(2,DRAW_ARROW,0,AlertSize);
 SetIndexArrow(2,119);
 SetIndexBuffer(2,AAlert);
 SetIndexStyle(3,DRAW_ARROW,0,AlertSize);
 SetIndexArrow(3,119);
 SetIndexBuffer(3,NoAlert);

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
 double ATR;
 double MA;
 double H, L;
 double ML, D;
 double TL, BL;
 double TTMS;
 pos=limit;
 while(pos>=0)
 {
  ATR=iATR(NULL, 0, Keltner_Smooth_Length, pos);
  MA=iMA(NULL, 0, Keltner_Length, 0, Keltner_Smooth_Method, PRICE_CLOSE, pos);
  H=MA+ATR*Keltner_Deviation;
  L=MA-ATR*Keltner_Deviation;
  ML=iMA(NULL, 0, BB_Length, 0, MODE_SMA, PRICE_CLOSE, pos);
  D=iStdDev(NULL, 0, BB_Length, 0, MODE_SMA, PRICE_CLOSE, pos);
  TL=ML+BB_Deviation*D;
  BL=ML-BB_Deviation*D;
  if (TL!=BL)
  {
   TTMS=(H-L)/(TL-BL)-1;
  }
  else
  {
   TTMS=0;
  } 
  if (TTMS>TTMS_Up[pos+1]+TTMS_Dn[pos+1])
  {
   TTMS_Up[pos]=TTMS;
   TTMS_Dn[pos]=0;
  }
  else
  {
   TTMS_Up[pos]=0;
   TTMS_Dn[pos]=TTMS;
  }
  if (TL<H && BL>L)
  {
   AAlert[pos]=0;
   NoAlert[pos]=EMPTY_VALUE;
  }
  else
  {
   AAlert[pos]=EMPTY_VALUE;
   NoAlert[pos]=0;
  }
  pos--;
 } 
 return(0);
}

