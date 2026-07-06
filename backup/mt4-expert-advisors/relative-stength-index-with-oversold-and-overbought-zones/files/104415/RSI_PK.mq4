//+------------------------------------------------------------------+
//|                                                       RSI_PK.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=17;
extern double Overbought_Level=60.;
extern double Oversold_Level=40.;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double RSI[], RSI_Dn[];
double ppos[], nneg[], WMA_pos[], WMA_neg[], trend[];
double k;

int init()
{
 IndicatorShortName("Relative Stength Index with zone and trend highlighting");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,RSI);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,RSI_Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,ppos);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,nneg);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,WMA_pos);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,WMA_neg);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,trend);
 
 SetLevelValue(0, Overbought_Level);
 SetLevelValue(1, Oversold_Level);
 
 k=1./Length;

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
 double Pr0, Pr1;
 double diff;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  diff=Pr0-Pr1;
  
  if (diff>=0)
  {
   ppos[pos]=diff;
   nneg[pos]=0.;
  }
  else
  {
   ppos[pos]=0.;
   nneg[pos]=-diff;
  }
  
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   WMA_pos[pos]=iMAOnArray(ppos, 0, Length, 0, MODE_SMA, pos);
   WMA_neg[pos]=iMAOnArray(nneg, 0, Length, 0, MODE_SMA, pos);
  }
  else
  {
   WMA_pos[pos]=(ppos[pos]-WMA_pos[pos+1])*k+WMA_pos[pos+1];
   WMA_neg[pos]=(nneg[pos]-WMA_neg[pos+1])*k+WMA_neg[pos+1];
  }
  
  if (WMA_neg[pos]==0.)
  {
   RSI[pos]=0.;
  }
  else
  {
   RSI[pos]=100.-(100./(1.+WMA_pos[pos]/WMA_neg[pos]));
  }
  
  trend[pos]=trend[pos+1];
  if (RSI[pos]>Overbought_Level)
  {
   trend[pos]=1.;
  }
  else
  {
   if (RSI[pos]<Oversold_Level)
   {
    trend[pos]=-1.;
   }
  }
  
  if (trend[pos]>0.)
  {
   RSI_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   RSI_Dn[pos]=RSI[pos];
  }

  pos--;
 }
   
 return(0);
}

