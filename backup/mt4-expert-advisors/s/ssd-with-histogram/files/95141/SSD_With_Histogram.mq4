//+------------------------------------------------------------------+
//|                                           SSD_With_Histogram.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 clrLightSeaGreen
#property indicator_color2 clrChocolate
#property indicator_color3 clrGreen
#property indicator_color4 clrRed

extern int K_Period=5;
extern int D_Slowing=3;
extern int D_Period=3;
extern int Method=0;      // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
                          
extern int Price_Field=0; // 0 - Low/High
                          // 1 - Close/Close                      

double K[], D[], Hist[], Hist_Dn[];

int init()
{
 IndicatorShortName("SSD with histogram");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,K);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,D);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,Hist);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,Hist_Dn);

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
  K[pos]=iStochastic(NULL, 0, K_Period, D_Period, D_Slowing, Method, Price_Field, MODE_SIGNAL, pos)-50;
  
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  D[pos]=iMAOnArray(K, 0, D_Period, 0, MODE_SMA, pos);
  Hist[pos]=K[pos]-D[pos];
  if (Hist[pos]<=Hist[pos+1])
  {
   Hist_Dn[pos]=Hist[pos];
  }
  else
  {
   Hist_Dn[pos]=EMPTY_VALUE;
  }
  
  pos--;
 } 
 return(0);
}

