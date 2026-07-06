//+------------------------------------------------------------------+
//|                                                         MA28.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=10;

double MA28[];

int init()
{
 IndicatorShortName("MA28 indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MA28);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 double SMA_C, SMA_O, SMA_H, SMA_L, SMA_M, SMA_T, SMA_W;
 double EMA_C, EMA_O, EMA_H, EMA_L, EMA_M, EMA_T, EMA_W;
 double SMMA_C, SMMA_O, SMMA_H, SMMA_L, SMMA_M, SMMA_T, SMMA_W;
 double LWMA_C, LWMA_O, LWMA_H, LWMA_L, LWMA_M, LWMA_T, LWMA_W;
 double Sum_SMA, Sum_EMA, Sum_SMMA, Sum_LWMA;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  SMA_C=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_CLOSE, pos);
  SMA_O=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_OPEN, pos);
  SMA_H=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_HIGH, pos);
  SMA_L=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_LOW, pos);
  SMA_M=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_MEDIAN, pos);
  SMA_T=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_TYPICAL, pos);
  SMA_W=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_WEIGHTED, pos);

  EMA_C=iMA(NULL, 0, Length, 0, MODE_EMA, PRICE_CLOSE, pos);
  EMA_O=iMA(NULL, 0, Length, 0, MODE_EMA, PRICE_OPEN, pos);
  EMA_H=iMA(NULL, 0, Length, 0, MODE_EMA, PRICE_HIGH, pos);
  EMA_L=iMA(NULL, 0, Length, 0, MODE_EMA, PRICE_LOW, pos);
  EMA_M=iMA(NULL, 0, Length, 0, MODE_EMA, PRICE_MEDIAN, pos);
  EMA_T=iMA(NULL, 0, Length, 0, MODE_EMA, PRICE_TYPICAL, pos);
  EMA_W=iMA(NULL, 0, Length, 0, MODE_EMA, PRICE_WEIGHTED, pos);

  SMMA_C=iMA(NULL, 0, Length, 0, MODE_SMMA, PRICE_CLOSE, pos);
  SMMA_O=iMA(NULL, 0, Length, 0, MODE_SMMA, PRICE_OPEN, pos);
  SMMA_H=iMA(NULL, 0, Length, 0, MODE_SMMA, PRICE_HIGH, pos);
  SMMA_L=iMA(NULL, 0, Length, 0, MODE_SMMA, PRICE_LOW, pos);
  SMMA_M=iMA(NULL, 0, Length, 0, MODE_SMMA, PRICE_MEDIAN, pos);
  SMMA_T=iMA(NULL, 0, Length, 0, MODE_SMMA, PRICE_TYPICAL, pos);
  SMMA_W=iMA(NULL, 0, Length, 0, MODE_SMMA, PRICE_WEIGHTED, pos);

  LWMA_C=iMA(NULL, 0, Length, 0, MODE_LWMA, PRICE_CLOSE, pos);
  LWMA_O=iMA(NULL, 0, Length, 0, MODE_LWMA, PRICE_OPEN, pos);
  LWMA_H=iMA(NULL, 0, Length, 0, MODE_LWMA, PRICE_HIGH, pos);
  LWMA_L=iMA(NULL, 0, Length, 0, MODE_LWMA, PRICE_LOW, pos);
  LWMA_M=iMA(NULL, 0, Length, 0, MODE_LWMA, PRICE_MEDIAN, pos);
  LWMA_T=iMA(NULL, 0, Length, 0, MODE_LWMA, PRICE_TYPICAL, pos);
  LWMA_W=iMA(NULL, 0, Length, 0, MODE_LWMA, PRICE_WEIGHTED, pos);
  
  Sum_SMA=SMA_C+SMA_O+SMA_H+SMA_L+SMA_M+SMA_T+SMA_W;
  Sum_EMA=EMA_C+EMA_O+EMA_H+EMA_L+EMA_M+EMA_T+EMA_W;
  Sum_SMMA=SMMA_C+SMMA_O+SMMA_H+SMMA_L+SMMA_M+SMMA_T+SMMA_W;
  Sum_LWMA=LWMA_C+LWMA_O+LWMA_H+LWMA_L+LWMA_M+LWMA_T+LWMA_W;
  
  MA28[pos]=(Sum_SMA+Sum_EMA+Sum_SMMA+Sum_LWMA)/28.;
  
  pos--;
 } 
 return(0);
}

