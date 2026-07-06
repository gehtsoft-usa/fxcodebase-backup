//+------------------------------------------------------------------+
//|                                           OnChart_Stochastic.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Yellow
#property indicator_color2 Yellow
#property indicator_color3 Yellow
#property indicator_color4 Green
#property indicator_color5 Red

extern int K_Length=5;
extern int Slowing_Length=3;
extern int D_Length=3;
extern int K_Smooth_Method=0; // 0 - SMA
                              // 1 - EMA

extern int Price_Field=0;     // 0 - Low/High
                              // 1 - Close/Close
extern int ATR_Length=14;
extern double Overbought_Level=80;
extern double Oversold_Level=20;

double Central[], OB[], OS[], K[], D[];

int init()
{
 IndicatorShortName("OnChart stochastic");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Central);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,OB);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,OS);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,K);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,D);

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
 double StochK, StochD;
 pos=limit;
 while(pos>=0)
 {
  Central[pos]=iMA(NULL, 0, ATR_Length, 0, K_Smooth_Method, PRICE_CLOSE, pos);
  ATR=iATR(NULL, 0, ATR_Length, pos);
  StochK=iStochastic(NULL, 0, K_Length, D_Length, Slowing_Length, K_Smooth_Method, Price_Field, MODE_MAIN, pos);
  StochD=iStochastic(NULL, 0, K_Length, D_Length, Slowing_Length, K_Smooth_Method, Price_Field, MODE_SIGNAL, pos);
  OB[pos]=Central[pos]+ATR*(Overbought_Level-50)/100;
  OS[pos]=Central[pos]-ATR*(50-Oversold_Level)/100;
  K[pos]=Central[pos]+(StochK-50)*ATR/100;
  D[pos]=Central[pos]+(StochD-50)*ATR/100;
  pos--;
 } 
 return(0);
}

