//+------------------------------------------------------------------+
//|                                               Sidus_V1_Cloud.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 Blue
#property indicator_color5 Yellow
#property indicator_color6 Red
#property indicator_color7 Red

extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int First_LWMA_Length=5;
extern int Second_LWMA_Length=8;
extern int First_EMA_Length=18;
extern int Second_EMA_Length=28;

double H1[], H2[], H3[];
double LWMA1[], LWMA2[], EMA1[], EMA2[];

int init()
{
 IndicatorShortName("Sidus V1 Cloud");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,H3);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,H1);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,H2);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,LWMA1);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,LWMA2);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,EMA1);
 SetIndexStyle(6,DRAW_LINE);
 SetIndexBuffer(6,EMA2);

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
 double MaxEMA, MinEMA, MaxLWMA, MinLWMA;
 pos=limit;
 while(pos>=0)
 {
  LWMA1[pos]=iMA(NULL, 0, First_LWMA_Length, 0, MODE_LWMA, Price, pos);
  LWMA2[pos]=iMA(NULL, 0, Second_LWMA_Length, 0, MODE_LWMA, Price, pos);
  EMA1[pos]=iMA(NULL, 0, First_EMA_Length, 0, MODE_EMA, Price, pos);
  EMA2[pos]=iMA(NULL, 0, Second_EMA_Length, 0, MODE_EMA, Price, pos);
  
  MaxEMA=MathMax(EMA1[pos], EMA2[pos]);
  MinEMA=MathMin(EMA1[pos], EMA2[pos]);
  MaxLWMA=MathMax(LWMA1[pos], LWMA2[pos]);
  MinLWMA=MathMin(LWMA1[pos], LWMA2[pos]);
  
  H1[pos]=EMPTY_VALUE;
  H2[pos]=EMPTY_VALUE;
  H3[pos]=EMPTY_VALUE;
  if (MinLWMA>MaxEMA)
  {
   H1[pos]=MinLWMA;
   H3[pos]=MaxEMA;
  }
  else
  {
   if (MinEMA>MaxLWMA)
   {
    H2[pos]=MinEMA;
    H3[pos]=MaxLWMA;
   }
  }

  pos--;
 } 
 return(0);
}

