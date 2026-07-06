//+------------------------------------------------------------------+
//|                                                       ROC_TO.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length1=10;
extern int Length2=20;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double ROC_TO[], ROC_TO_Dn[];
double Pr[], ROC1[], ROC2[];
int MaxLength;

int init()
{
 IndicatorShortName("Rate of Change Trend oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,ROC_TO);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,ROC_TO_Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Pr);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,ROC1);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,ROC2);
 
 MaxLength=MathMax(Length1, Length2);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=MaxLength) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (Pr[pos+Length1]!=0)
  {
   ROC1[pos]=(Pr[pos]/Pr[pos+Length1]-1)*100;
  } 
  if (Pr[pos+Length2]!=0)
  {
   ROC2[pos]=(Pr[pos]/Pr[pos+Length2]-1)*100;
  } 
  ROC_TO[pos]=ROC1[pos]+ROC2[pos];
  if (ROC_TO[pos]<ROC_TO[pos+1])
  {
   ROC_TO_Dn[pos]=ROC_TO[pos];
  }
  else
  {
   ROC_TO_Dn[pos]=EMPTY_VALUE;
  }
  pos--;
 }
   
 return(0);
}

