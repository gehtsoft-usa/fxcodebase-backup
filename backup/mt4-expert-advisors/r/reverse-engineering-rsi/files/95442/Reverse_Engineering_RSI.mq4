//+------------------------------------------------------------------+
//|                                      Reverse_Engineering_RSI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Yellow

extern int RSI_Length=14;
extern int MA_Length=45;
extern int MA_Method=0;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted 

double RE_RSI[];
double auc[], adc[], RSI[], Pr[];
int ExpLength;

int init()
{
 IndicatorShortName("Reverse Engineering RSI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,RE_RSI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,auc);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,adc);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,RSI);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Pr);
 
 ExpLength=2*RSI_Length-1;

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
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (Pr[pos]>Pr[pos+1])
  {
   auc[pos]=Pr[pos]-Pr[pos+1];
   adc[pos]=0.;
  }
  else
  {
   auc[pos]=0.;
   adc[pos]=Pr[pos+1]-Pr[pos];
  }
  
  RSI[pos]=iRSI(NULL, 0, RSI_Length, Price, pos);

  pos--;
 }  
 
 double AUC_MA, ADC_MA, RSI_MA, x;
 pos=limit;
 while(pos>=0)
 {
  AUC_MA=iMAOnArray(auc, 0, ExpLength, 0, MODE_EMA, pos);
  ADC_MA=iMAOnArray(adc, 0, ExpLength, 0, MODE_EMA, pos);
  RSI_MA=iMAOnArray(RSI, 0, MA_Length, 0, MA_Method, pos);
  
  if (RSI_MA!=100.)
  {
   x=(RSI_Length-1.)*(ADC_MA*RSI_MA/(100.-RSI_MA)-AUC_MA);
  }
  else
  {
   x=0.;
  } 
  
  if (x>=0. || RSI_MA==0.)
  {
   RE_RSI[pos]=Pr[pos]+x;
  }
  else
  {
   RE_RSI[pos]=Pr[pos]+x*(100.-RSI_MA)/RSI_MA;
  }

  pos--;
 }  
 
 return(0);
}

