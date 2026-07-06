//+------------------------------------------------------------------+
//|                                                    RSI_STARC.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Gray

extern int RSI_Length=14;
extern int ATR_Length=14;
extern int MA_Length=14;
extern double Top_Multiplier=2.;
extern double Bottom_Multiplier=2.;

double Top[], RSI[], Central[], MA[];
double tr[];

int init()
{
 IndicatorShortName("RSI STARC");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Top);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,RSI);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Central);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,MA);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,tr);

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
  RSI[pos]=iRSI(NULL, 0, RSI_Length, PRICE_CLOSE, pos);
  
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  MA[pos]=iMAOnArray(RSI, 0, MA_Length, 0, MODE_SMA, pos);
  tr[pos]=MathAbs(RSI[pos]-RSI[pos+1]);
  
  pos--;
 } 
 
 double ATR;
 pos=limit;
 while(pos>=0)
 {
  ATR=iMAOnArray(tr, 0, ATR_Length, 0, MODE_SMA, pos);
  Top[pos]=MA[pos]+Top_Multiplier*ATR;
  Central[pos]=MA[pos]-Bottom_Multiplier*ATR;

  pos--;
 }  
 
 return(0);
}

