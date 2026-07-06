//+------------------------------------------------------------------+
//|                                                         WAAB.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Gray

extern int ADX_Length=14;
extern int Bollinger_Length=20;
extern int Bollinger_Price=0;      // Applied price
                                   // 0 - Close
                                   // 1 - Open
                                   // 2 - High
                                   // 3 - Low
                                   // 4 - Median
                                   // 5 - Typical
                                   // 6 - Weighted  

double WAAB[], WAAB_M[], WAAB_N[];

int init()
{
 IndicatorShortName("Waddah Attar ADXxBollinger");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,WAAB);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,WAAB_M);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,WAAB_N);

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
 double ADX, DIM, DIP, TL, BL;
 double Explo;
 pos=limit;
 while(pos>=0)
 {
  ADX=iADX(NULL, 0, ADX_Length, PRICE_CLOSE, MODE_MAIN, pos);
  DIM=iADX(NULL, 0, ADX_Length, PRICE_CLOSE, MODE_MINUSDI, pos);
  DIP=iADX(NULL, 0, ADX_Length, PRICE_CLOSE, MODE_PLUSDI, pos);
  TL=iBands(NULL, 0, Bollinger_Length, 2., 0, Bollinger_Price, MODE_UPPER, pos);
  BL=iBands(NULL, 0, Bollinger_Length, 2., 0, Bollinger_Price, MODE_LOWER, pos);
  
  Explo=TL-BL;
  WAAB[pos]=Explo*ADX;
  WAAB_M[pos]=EMPTY_VALUE;
  WAAB_N[pos]=EMPTY_VALUE;
  if (DIP<DIM)
  {
   WAAB_M[pos]=WAAB[pos];
  }
  else
  {
   WAAB_N[pos]=WAAB[pos];
  }

  pos--;
 } 
 return(0);
}

