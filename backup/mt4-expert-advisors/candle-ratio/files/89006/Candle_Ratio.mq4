//+------------------------------------------------------------------+
//|                                                 Candle_Ratio.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=21;
extern int MA_Length=21;
extern int MA_Method=1;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA

double Ratio[], MA[];
double Up[], Dn[];

int init()
{
 IndicatorShortName("Candle ratio");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Ratio);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,MA);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Up);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Dn);

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
  if (Close[pos]>Open[pos])
  {
   Up[pos]=Close[pos]-Open[pos];
   Dn[pos]=0;
  }
  else
  {
   Dn[pos]=Open[pos]-Close[pos];
   Up[pos]=0;
  }
  pos--;
 } 
 
 double SUp, SDn;
 pos=limit;
 while(pos>=0)
 {
  SUp=iMAOnArray(Up, 0, Length, 0, MODE_SMA, pos);
  SDn=iMAOnArray(Dn, 0, Length, 0, MODE_SMA, pos);
  if (SDn!=0)
  {
   Ratio[pos]=SUp/SDn;
  }
  else
  {
   Ratio[pos]=0;
  } 
  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  MA[pos]=iMAOnArray(Ratio, 0, MA_Length, 0, MA_Method, pos);
  pos--;
 }  
 return(0);
}

