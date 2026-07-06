//+------------------------------------------------------------------+
//|                                                    VAMA_MACD.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Lime
#property indicator_color4 Green
#property indicator_color5 DarkOrange
#property indicator_color6 Red

extern bool Show_Histogram=true;
extern bool Show_MACD=true;
extern bool Show_Signal=true;
extern int Short_Length=12;
extern int Long_Length=26;
extern int Signal_Length=9;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted


double MACD[], Signal[], H_UU[], H_UD[], H_DU[], H_DD[];

int init()
{
 IndicatorShortName("VAMA MACD");
 IndicatorDigits(Digits);
 if (Show_MACD)
 {
  SetIndexStyle(0,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(0,DRAW_NONE);
 } 
 SetIndexBuffer(0,MACD);
 if (Show_Signal)
 {
  SetIndexStyle(1,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(1,DRAW_NONE);
 } 
 SetIndexBuffer(1,Signal);
 if (Show_Histogram)
 {
  SetIndexStyle(2,DRAW_HISTOGRAM);
  SetIndexStyle(3,DRAW_HISTOGRAM);
  SetIndexStyle(4,DRAW_HISTOGRAM);
  SetIndexStyle(5,DRAW_HISTOGRAM);
 }
 else
 {
  SetIndexStyle(2,DRAW_NONE);
  SetIndexStyle(3,DRAW_NONE);
  SetIndexStyle(4,DRAW_NONE);
  SetIndexStyle(5,DRAW_NONE);
 } 
 SetIndexBuffer(2,H_UU);
 SetIndexBuffer(3,H_UD);
 SetIndexBuffer(4,H_DU);
 SetIndexBuffer(5,H_DD);

 return(0);
}

int deinit()
{

 return(0);
}

double SumPrVolume(int index, int Length)
{
 int i;
 double Pr;
 double Sum=0.;
 for (i=index;i<=index+Length-1;i++)
 {
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, i);
  Sum=Sum+Pr*Volume[i];
 }
 return (Sum);
}

double SumMACDVolume(int index, int Length)
{
 int i;
 double Sum=0.;
 for (i=index;i<=index+Length-1;i++)
 {
  Sum=Sum+MACD[i]*Volume[i];
 }
 return (Sum);
}

double SumVolume(int index, int Length)
{
 int i;
 double Sum=0.;
 for (i=index;i<=index+Length-1;i++)
 {
  Sum=Sum+Volume[i];
 }
 return (Sum);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double S_PV_Short, S_PV_Long, S_V_Short, S_V_Long;
 double MAS, MAL;
 pos=limit;
 while(pos>=0)
 {
  S_PV_Short=SumPrVolume(pos, Short_Length);
  S_PV_Long=SumPrVolume(pos, Long_Length);
  S_V_Short=SumVolume(pos, Short_Length);
  S_V_Long=SumVolume(pos, Long_Length);
  
  if (S_V_Long!=0. && S_V_Short!=0.)
  {
   MAS=S_PV_Short/S_V_Short;
   MAL=S_PV_Long/S_V_Long;
   MACD[pos]=MAS-MAL;
  }

  pos--;
 } 
 
 double S_MACD, S_V;
 pos=limit;
 while(pos>=0)
 {
  S_MACD=SumMACDVolume(pos, Signal_Length);
  S_V=SumVolume(pos, Signal_Length);
  if (S_V!=0.)
  {
   Signal[pos]=S_MACD/S_V;
   H_UU[pos]=MACD[pos]-Signal[pos];
   if (H_UU[pos]>0.)
   {
    if (H_UU[pos]<H_UU[pos+1])
    {
     H_UD[pos]=H_UU[pos];
    }
   }
   else
   {
    if (H_UU[pos]>=H_UU[pos+1])
    {
     H_DU[pos]=H_UU[pos];
    }
    else
    {
     H_DD[pos]=H_UU[pos];
    }
   }
  }

  pos--;
 }
   
 return(0);
}

