//+------------------------------------------------------------------+
//|                                                     MK_Combo.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Green

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

double Combo[], K[], D[];
double mins[], maxes[], FastK[], Vol[];

int init()
{
 IndicatorShortName("MK Combo");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Combo);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,K);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,D);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,mins);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,maxes);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,FastK);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,Vol);

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
  Vol[pos]=Volume[pos];
  
  pos--;
 }
  
 pos=limit;
 while(pos>=0)
 {
  minLow=Vol[ArrayMinimum(Vol, K_Length, pos)];
  maxHigh=Vol[ArrayMaximum(Vol, K_Length, pos)];
  
  mins[pos]=Vol[pos]-minLow;
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
 
 double StK, StD;
 pos=limit;
 while(pos>=0)
 {
  D[pos]=iMAOnArray(K, 0, D_Length, 0, D_Smoothing_Method, pos);
  
  StK=iStochastic(NULL, 0, K_Length, D_Length, D_Slowing, MODE_SMA, 0, MODE_MAIN, pos);
  StD=iStochastic(NULL, 0, K_Length, D_Length, D_Slowing, MODE_SMA, 0, MODE_SIGNAL, pos);
  
  Combo[pos]=(K[pos]-D[pos])*(StK-StD)/Point;

  pos--;
 }  
   
 return(0);
}

