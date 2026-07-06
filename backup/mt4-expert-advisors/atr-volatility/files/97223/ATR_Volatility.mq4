//+------------------------------------------------------------------+
//|                                               ATR_Volatility.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Yellow

extern int ATR_Length=12;
extern double High_Level=300.;
extern double Low_Level=200.;
extern string Type_Str="Type: 0 - Pip, 1 - %";
extern int Type=0;   // 0 - Pip, 1 - %

double AATR[], AATR_Dn[], AATR_No[];
double ATR[];

int init()
{
 IndicatorShortName("ATR Volatility");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,AATR);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,AATR_Dn);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,AATR_No);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,ATR);

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
  ATR[pos]=iATR(NULL, 0, ATR_Length, pos);

  pos--;
 } 
 
 double Min, Max;
 Min=ATR[ArrayMinimum(ATR, WHOLE_ARRAY, 0)];
 Max=ATR[ArrayMaximum(ATR, WHOLE_ARRAY, 0)];
 
 double Top, Bottom;
 double Percentage;
 
 if (Type==0)
 {
  Top=High_Level*Point;
  Bottom=Low_Level*Point;
 }
 else
 {
  Percentage=(Max-Min)/100.;
  Top=Min+Percentage*High_Level;
  Bottom=Min*Percentage*Low_Level;
 }
 
 pos=limit;
 while(pos>=0)
 {
  AATR[pos]=0.;
  AATR_Dn[pos]=0.;
  AATR_No[pos]=0.;
  
  if (ATR[pos]>Top)
  {
   AATR[pos]=1.;
  }
  else
  {
   if (ATR[pos]<Bottom)
   {
    AATR_Dn[pos]=1.;
   }
   else
   {
    AATR_No[pos]=1.;
   }
  }

  pos--;
 }
   
 return(0);
}

