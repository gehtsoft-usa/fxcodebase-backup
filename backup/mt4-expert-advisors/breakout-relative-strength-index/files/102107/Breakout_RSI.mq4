//+------------------------------------------------------------------+
//|                                                 Breakout_RSI.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Yellow

extern int Length=14;
extern double Overbought_Level=80.;
extern double Oversold_Level=20.;

double BRSI[];
double BPower[], n[], p[];

int init()
{
 IndicatorShortName("Breakout RSI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,BRSI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,BPower);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,n);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,p);

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
 double Min, Max;
 double BPrice, BStrength, BVolume;
 pos=limit;
 while(pos>=0)
 {
  Min=MathMin(Low[pos], Low[pos+1]);
  Max=MathMax(High[pos], High[pos+1]);
  
  BPrice=(Open[pos+1]+Max+Min+Close[pos])/4.;
  BStrength=(Close[pos]-Open[pos+1])/(Max-Min);
  BVolume=Volume[pos]+Volume[pos+1];
  
  BPower[pos]=(BPrice*BStrength*BVolume)*Point;
  
  if (BPower[pos]>BPower[pos+1])
  {
   p[pos]=MathAbs(BPower[pos]);
   n[pos]=0.;
  }
  else
  {
   n[pos]=MathAbs(BPower[pos]);
   p[pos]=0.;
  }

  pos--;
 } 
 
 double Navg, Pavg;
 pos=limit;
 while(pos>=0)
 {
  Navg=iMAOnArray(n, 0, Length, 0, MODE_SMA, pos);
  Pavg=iMAOnArray(p, 0, Length, 0, MODE_SMA, pos);
  
  if (Navg!=0.)
  {
   BRSI[pos]=100.-100./(1.+Pavg/Navg);
  }
  else
  {
   BRSI[pos]=0.;
  }

  pos--;
 }
   
 return(0);
}

