//+------------------------------------------------------------------+
//|                                                        TMAGi.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Green

extern int Fast_Length=8;
extern int Middle_Length=16;
extern int Slow_Length=25;
extern int Slowing_SMA_Length=3;
extern int Slowing_LWMA_Length=8;
extern int ADX_Length=14;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double B1[], B2[];
double B[];

int init()
{
 IndicatorShortName("TMAGi oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,B1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,B2);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,B);

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
 double Slow_MA, Middle_MA, Fast_MA;
 double P_ADX, M_ADX, di;
 pos=limit;
 while(pos>=0)
 {
  P_ADX=iADX(NULL, 0, ADX_Length, Price, MODE_PLUSDI, pos);
  M_ADX=iADX(NULL, 0, ADX_Length, Price, MODE_MINUSDI, pos);
  di=P_ADX-M_ADX;
  
  Slow_MA=iMA(NULL, 0, Slow_Length, 0, MODE_SMA, Price, pos);
  Middle_MA=iMA(NULL, 0, Middle_Length, 0, MODE_SMA, Price, pos);
  Fast_MA=iMA(NULL, 0, Fast_Length, 0, MODE_SMA, Price, pos);
  
  B[pos]=(MathAbs(Fast_MA-Middle_MA)+MathAbs(Fast_MA-Slow_MA)+MathAbs(Middle_MA-Slow_MA))*di;

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  B1[pos]=iMAOnArray(B, 0, Slowing_SMA_Length, 0, MODE_SMA, pos);
  B2[pos]=iMAOnArray(B, 0, Slowing_LWMA_Length, 0, MODE_LWMA, pos);

  pos--;
 }
   
 return(0);
}

