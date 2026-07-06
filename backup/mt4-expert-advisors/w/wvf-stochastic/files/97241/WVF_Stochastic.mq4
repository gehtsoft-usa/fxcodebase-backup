//+------------------------------------------------------------------+
//|                                               WVF_Stochastic.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Green

extern int WVF_Length=14;
extern int Stochastic_K_Length=5;
extern int Stochastic_D_Length=3;
extern double Overbought_Level=80.;
extern double Oversold_Level=20.;

double K[], D[];
double WVF[];

int init()
{
 IndicatorShortName("WVF Stochastic");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,K);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,D);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,WVF);
 
 SetLevelValue(0, Overbought_Level);
 SetLevelValue(1, Oversold_Level);

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
 double Max;
 pos=limit;
 while(pos>=0)
 {
  Max=Close[iHighest(NULL, 0, MODE_CLOSE, WVF_Length, pos)];
  if (Max>0)
  {
   WVF[pos]=100*(Max-Low[pos])/Max;
  }
  else
  {
   WVF[pos]=0;
  } 

  pos--;
 } 
 
 double minLow, maxHigh;
 double mins, maxes;
 pos=limit;
 while(pos>=0)
 {
  minLow=WVF[ArrayMinimum(WVF, Stochastic_K_Length, pos)];
  maxHigh=WVF[ArrayMaximum(WVF, Stochastic_K_Length, pos)];
  
  mins=WVF[pos]-minLow;
  maxes=maxHigh-minLow;
  
  if (maxes>0.)
  {
   K[pos]=100.*mins/maxes;
  }
  else
  {
   K[pos]=50.;
  }

  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  D[pos]=iMAOnArray(K, 0, Stochastic_D_Length, 0, MODE_SMA, pos);

  pos--;
 }  
   
 return(0);
}

