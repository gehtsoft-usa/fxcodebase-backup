//+------------------------------------------------------------------+
//|                                                 MACD_Squeeze.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Gray
#property indicator_color4 Blue

extern int Short_EMA_Length=8;
extern int Long_EMA_Length=21;
extern int Bollinger_Length=20;
extern double Bollinger_Deviation=2;
extern int Bollinger_MA_Method=1;  // 0 - SMA
                                   // 1 - EMA
                                   // 2 - SMMA
                                   // 3 - LWMA
extern int Keltner_Length=20;
extern double Keltner_Deviation=1.5;
extern int Keltner_ATR_Length=10;
extern int Keltner_MA_Method=1;  // 0 - SMA
                                 // 1 - EMA
                                 // 2 - SMMA
                                 // 3 - LWMA


double MACD[], MACD_DN[], Squeeze_In[], Squeeze_Out[];

int init()
{
 IndicatorShortName("MACD Squeeze oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,MACD);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,MACD_DN);
 SetIndexStyle(2,DRAW_ARROW,0,4);
 SetIndexBuffer(2,Squeeze_In);
 SetIndexArrow(2,119);
 SetIndexStyle(3,DRAW_ARROW,0,4);
 SetIndexBuffer(3,Squeeze_Out);
 SetIndexArrow(3,119);

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
 double Short_EMA, Long_EMA;
 double BB_MA, BB_StdDev;
 double BTL, BBL;
 double KTL, KBL;
 double K_MA, K_ATR;
 pos=limit;
 while(pos>=0)
 {
  Short_EMA=iMA(NULL, 0, Short_EMA_Length, 0, MODE_EMA, PRICE_CLOSE, pos);
  Long_EMA=iMA(NULL, 0, Long_EMA_Length, 0, MODE_EMA, PRICE_CLOSE, pos);
  MACD[pos]=Short_EMA-Long_EMA;
  if (MACD[pos]<MACD[pos+1])
  {
   MACD_DN[pos]=MACD[pos];
  }
  else
  {
   MACD_DN[pos]=EMPTY_VALUE;
  }
  
  BB_MA=iMA(NULL, 0, Bollinger_Length, 0, Bollinger_MA_Method, PRICE_CLOSE, pos);
  BB_StdDev=iStdDev(NULL, 0, Bollinger_Length, 0, MODE_SMA, PRICE_CLOSE, pos);
  BTL=BB_MA+BB_StdDev*Bollinger_Deviation;
  BBL=BB_MA-BB_StdDev*Bollinger_Deviation;
  
  K_MA=iMA(NULL, 0, Keltner_Length, 0, Keltner_MA_Method, PRICE_CLOSE, pos);
  K_ATR=iATR(NULL, 0, Keltner_ATR_Length, pos);
  KTL=K_MA+K_ATR*Keltner_Deviation;
  KBL=K_MA-K_ATR*Keltner_Deviation;
  
  if (BTL<KTL && BBL>KBL)
  {
   Squeeze_Out[pos]=0.;
   Squeeze_In[pos]=EMPTY_VALUE;
  }
  else
  {
   Squeeze_In[pos]=0.;
   Squeeze_Out[pos]=EMPTY_VALUE;
  }
  
  pos--;
 } 
 return(0);
}

