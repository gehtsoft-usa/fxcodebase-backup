//+------------------------------------------------------------------+
//|                                                          QQE.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Red

extern int RSI_Length=14;
extern int SF=5;
extern double DarFactor=4.236;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double Pbuff[], Mbuff[];
int Wilders_Length;
double RSI[], MA_RSI[], Abs_MA_RSI[], MA1[];

int init()
  {
   IndicatorShortName("QQE oscillator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Pbuff);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Mbuff);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,RSI);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,MA_RSI);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,Abs_MA_RSI);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,MA1);
   Wilders_Length=2*RSI_Length-1;
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=RSI_Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  RSI[pos]=iRSI(NULL, 0, RSI_Length, PRICE_CLOSE, pos);
  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  MA_RSI[pos]=iMAOnArray(RSI, 0, SF, 0, Method, pos);
  Abs_MA_RSI[pos]=MathAbs(iMAOnArray(RSI, 0, SF, 0, Method, pos+1)-iMAOnArray(RSI, 0, SF, 0, Method, pos));
  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  MA1[pos]=iMAOnArray(Abs_MA_RSI, 0, Wilders_Length, 0, Method, pos);
  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  double dar=iMAOnArray(MA1, 0, Wilders_Length, 0, Method, pos)*DarFactor;
  double tr=Mbuff[pos+1];
  double dv=tr;
  if (MA_RSI[pos]<tr)
  {
   tr=MA_RSI[pos]+dar;
   if (MA_RSI[pos+1]<dv && tr>dv)
   {
    tr=dv;
   }
  }
  else
  {
   tr=MA_RSI[pos]-dar;
   if (MA_RSI[pos+1]>dv && tr<dv)
   {
    tr=dv;
   }
  }
  Mbuff[pos]=tr;
  Pbuff[pos]=MA_RSI[pos];
  pos--;
 }

 return(0);
}

