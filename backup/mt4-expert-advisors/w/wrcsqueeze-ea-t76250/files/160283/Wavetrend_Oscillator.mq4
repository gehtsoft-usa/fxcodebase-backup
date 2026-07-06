
//More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=61860

//+------------------------------------------------------------------+
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+


#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"



#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

#property indicator_levelcolor clrBlue

extern int Channel_Length=10;
extern int Average_Length=21;
extern int Signal_Length=4;
extern double Overbought_Level1=50.;
extern double Oversold_Level1=-50.;
extern double Overbought_Level2=53.;
extern double Oversold_Level2=-53.;

double wt1[], wt2[], wt3[];
double Raw1[], Raw2[];

int init()
{
 IndicatorShortName("Wavetrend oscillator");
 IndicatorBuffers(5);
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,wt1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,wt2);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,wt3);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Raw1);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Raw2);
 
SetLevelValue(0,Overbought_Level1);
SetLevelValue(1,Oversold_Level1);
SetLevelValue(2,Overbought_Level2);
SetLevelValue(3,Oversold_Level2);

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
 double EMA1, EMA2;
 double TP;
 pos=limit;
 while(pos>=0)
 {
  EMA1=iMA(NULL, 0, Channel_Length, 0, MODE_EMA, PRICE_TYPICAL, pos);
  TP=iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_TYPICAL, pos);
  Raw1[pos]=MathAbs(TP-EMA1);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  EMA2=iMAOnArray(Raw1, 0, Channel_Length, 0, MODE_EMA, pos);
  EMA1=iMA(NULL, 0, Channel_Length, 0, MODE_EMA, PRICE_TYPICAL, pos);
  TP=iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_TYPICAL, pos);
  
  if (EMA2!=0.)
  {
   Raw2[pos]=(TP-EMA1)/(0.015*EMA2);
  } 

  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
 wt1[pos]=iMAOnArray(Raw2, 0, Average_Length, 0, MODE_EMA, pos);

  pos--;
 }
     
 pos=limit;
 while(pos>=0)
 {
  wt2[pos]=iMAOnArray(wt1, 0, Signal_Length, 0, MODE_SMA, pos);
  wt3[pos]=wt1[pos]-wt2[pos];

  pos--;
 }
        
 return(0);
}

