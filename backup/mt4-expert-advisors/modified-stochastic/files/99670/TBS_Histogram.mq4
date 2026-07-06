//+------------------------------------------------------------------+
//|                                                TBS_Histogram.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Red

extern bool Show_K_Line=true;
extern bool Show_D_Line=true;
extern int K_Length=5;
extern int D_Slowing=3;
extern int D_Length=3;
extern string K_Smoothing_Method_Str="0 - SMA, 1 - EMA, 2 - SMMA - , 3 - LWMA, 4 - MT algorithm";
extern int K_Smoothing_Method=0;  // 0 - SMA
                                  // 1 - EMA
                                  // 2 - SMMA
                                  // 3 - LWMA
                                  // 4 - MT algorithm
extern string D_Smoothing_Method_Str="0 - SMA, 1 - EMA, 2 - SMMA - , 3 - LWMA";                                  
extern int D_Smoothing_Method=0;  // 0 - SMA
                                  // 1 - EMA
                                  // 2 - SMMA
                                  // 3 - LWMA
extern double Overbought_Level=30.;
extern double Oversold_Level=-30.;                                  
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double K[], D[], Hist[], Hist_Dn[];
double mins[], maxes[], FastK[], Pr[];

int init()
{
 IndicatorShortName("Tick Based Stochastic with histogram");
 IndicatorDigits(Digits);
 if (Show_K_Line)
 {
  SetIndexStyle(0,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(0,DRAW_NONE);
 } 
 SetIndexBuffer(0,K);
 if (Show_D_Line)
 {
  SetIndexStyle(1,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(1,DRAW_NONE);
 } 
 SetIndexBuffer(1,D);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,Hist);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,Hist_Dn);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,mins);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,maxes);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,FastK);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,Pr);

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
 double minLow, maxHigh;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
 
  pos--;
 }
  
 pos=limit;
 while(pos>=0)
 {
  minLow=Pr[ArrayMinimum(Pr, K_Length, pos)];
  maxHigh=Pr[ArrayMaximum(Pr, K_Length, pos)];
  
  mins[pos]=Pr[pos]-minLow;
  maxes[pos]=maxHigh-minLow;
  
  if (maxes[pos]>0.)
  {
   FastK[pos]=100.*mins[pos]/maxes[pos];
  }
  else
  {
   FastK[pos]=50.;
  }

  pos--;
 } 
 
 double avgMax, avgMin;
 pos=limit;
 while(pos>=0)
 {
  if (K_Smoothing_Method<4)
  {
   K[pos]=iMAOnArray(FastK, 0, D_Slowing, 0, K_Smoothing_Method, pos)-50.;
  }
  else
  {
   avgMax=iMAOnArray(maxes, 0, D_Slowing, 0, MODE_SMA, pos);
   if (avgMax==0.)
   {
    K[pos]=0.;
   }
   else
   {
    avgMin=iMAOnArray(mins, 0, D_Slowing, 0, MODE_SMA, pos);
    K[pos]=100.*avgMin/avgMax-50.;
   }
  }

  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  D[pos]=iMAOnArray(K, 0, D_Length, 0, D_Smoothing_Method, pos);

  Hist[pos]=K[pos]-D[pos];
  if (Hist[pos]<Hist[pos+1])
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

