//+------------------------------------------------------------------+
//|                                                 Glitch_Index.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int MA_Length=30;
extern int MA_Method=0;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
extern int ROC_Length=1;                         
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double GI[], GI_Dn[];

int init()
{
 IndicatorShortName("Glitch Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,GI);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,GI_Dn);

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
 double Pr, MA, MA_ROC;
 double rocsma, smamult, diff;
 pos=limit;
 while(pos>=0)
 {
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  MA=iMA(NULL, 0, MA_Length, 0, MA_Method, Price, pos);
  MA_ROC=iMA(NULL, 0, MA_Length, 0, MA_Method, Price, pos+ROC_Length);
  rocsma=((MA-MA_ROC)*0.1)+1.;
  smamult=MA*rocsma;
  diff=Pr-smamult;
  GI[pos]=100.*diff/Pr;
  if (GI[pos]>0.)
  {
   GI_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   GI_Dn[pos]=GI[pos];
  }
  
  pos--;
 } 
 return(0);
}


