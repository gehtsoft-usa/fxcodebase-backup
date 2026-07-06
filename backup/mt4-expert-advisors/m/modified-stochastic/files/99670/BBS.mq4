//+------------------------------------------------------------------+
//|                                                          BBS.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red

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
extern double Overbought_Level=80.;
extern double Oversold_Level=20.;                                  

double K[], D[];
double mins[], maxes[], FastK[];

int init()
{
 IndicatorShortName("Bar Based Stochastic");
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
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,mins);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,maxes);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,FastK);
 
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
  minLow=Low[iLowest(NULL, 0, MODE_LOW, K_Length, pos)];
  maxHigh=High[iHighest(NULL, 0, MODE_HIGH, K_Length, pos)];
  
  mins[pos]=Close[pos]-minLow;
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
   K[pos]=iMAOnArray(FastK, 0, D_Slowing, 0, K_Smoothing_Method, pos);
  }
  else
  {
   avgMax=iMAOnArray(maxes, 0, D_Slowing, 0, MODE_SMA, pos);
   if (avgMax==0.)
   {
    K[pos]=50.;
   }
   else
   {
    avgMin=iMAOnArray(mins, 0, D_Slowing, 0, MODE_SMA, pos);
    K[pos]=100.*avgMin/avgMax;
   }
  }

  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  D[pos]=iMAOnArray(K, 0, D_Length, 0, D_Smoothing_Method, pos);

  pos--;
 }  
   
 return(0);
}

