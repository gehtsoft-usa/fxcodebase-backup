//+------------------------------------------------------------------+
//|                                              Momentum_Signal.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int CCI_Length=6;
extern int ATR_Length=12;
extern int Momentum_Length=7;
extern int RSI_Length=7;
extern int ADX_Length=7;
extern double Substract_From_Signal=-5.;
extern double Substract_From_Indicator=-1.;

double Mom[], Signal[];

int init()
{
 IndicatorShortName("Momentum Signal oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Mom);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);

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
 double CCI, ATR, Momentum, RSI, ADX;
 pos=limit;
 while(pos>=0)
 {
  CCI=iCCI(NULL, 0, CCI_Length, PRICE_TYPICAL, pos);
  ATR=iATR(NULL, 0, ATR_Length, pos);
  Momentum=iMomentum(NULL, 0, Momentum_Length, PRICE_TYPICAL, pos);
  RSI=iRSI(NULL, 0, RSI_Length, PRICE_TYPICAL, pos);
  ADX=iADX(NULL, 0, ADX_Length, PRICE_TYPICAL, MODE_MAIN, pos);
  
  if (ATR+ADX!=0.)
  {
   Signal[pos]=Momentum/(ATR+ADX)-Substract_From_Signal;
  }
  
  if (ADX!=0.) 
  {
   Mom[pos]=(ATR+CCI+RSI)/ADX-Substract_From_Indicator;
  } 

  pos--;
 } 
 return(0);
}

