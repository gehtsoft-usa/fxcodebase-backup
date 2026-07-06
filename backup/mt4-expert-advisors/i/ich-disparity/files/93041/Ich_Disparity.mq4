//+------------------------------------------------------------------+
//|                                                Ich_Disparity.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Disp1_Component1=0;  // 0 - TL
                                // 1 - KL
                                // 2 - CS
                                // 3 - SA
                                // 4 - SB
extern int Disp1_Length1=14;
extern int Disp1_Method1=0;     // 0 - SMA
                                // 1 - EMA
                                // 2 - SMMA
                                // 3 - LWMA
extern int Disp1_Component2=1;  // 0 - TL
                                // 1 - KL
                                // 2 - CS
                                // 3 - SA
                                // 4 - SB
extern int Disp1_Length2=14;
extern int Disp1_Method2=0;     // 0 - SMA
                                // 1 - EMA
                                // 2 - SMMA
                                // 3 - LWMA
extern int Disp2_Component1=0;  // 0 - TL
                                // 1 - KL
                                // 2 - CS
                                // 3 - SA
                                // 4 - SB
extern int Disp2_Length1=14;
extern int Disp2_Method1=0;     // 0 - SMA
                                // 1 - EMA
                                // 2 - SMMA
                                // 3 - LWMA
extern int Disp2_Component2=2;  // 0 - TL
                                // 1 - KL
                                // 2 - CS
                                // 3 - SA
                                // 4 - SB
extern int Disp2_Length2=14;
extern int Disp2_Method2=0;     // 0 - SMA
                                // 1 - EMA
                                // 2 - SMMA
                                // 3 - LWMA
extern int Disp3_Component1=3;  // 0 - TL
                                // 1 - KL
                                // 2 - CS
                                // 3 - SA
                                // 4 - SB
extern int Disp3_Length1=14;
extern int Disp3_Method1=0;     // 0 - SMA
                                // 1 - EMA
                                // 2 - SMMA
                                // 3 - LWMA
extern int Disp3_Component2=4;  // 0 - TL
                                // 1 - KL
                                // 2 - CS
                                // 3 - SA
                                // 4 - SB
extern int Disp3_Length2=14;
extern int Disp3_Method2=0;     // 0 - SMA
                                // 1 - EMA
                                // 2 - SMMA
                                // 3 - LWMA
extern int Ich_Tenkan_Sen=9;
extern int Ich_Kijun_Sen=26;
extern int Ich_Senkou_Span_B=52;

double Disparity1[], Disparity2[], Disparity3[];
double Tenkansen[], Kijunsen[], Senkouspana[], Senkouspanb[], Chinkouspan[];

int init()
{
 IndicatorShortName("ICH Disparity oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Disparity1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Disparity2);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Disparity3);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Tenkansen);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Kijunsen);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,Senkouspana);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,Senkouspanb);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,Chinkouspan);

 return(0);
}

int deinit()
{

 return(0);
}

double GetMA(int IchIndex, int Method, int Length, int index)
{
 if (IchIndex==0)
 {
  return (iMAOnArray(Tenkansen, 0, Length, 0, Method, index));
 }
 if (IchIndex==1)
 {
  return (iMAOnArray(Kijunsen, 0, Length, 0, Method, index));
 }
 if (IchIndex==2)
 {
  if (index>=Ich_Kijun_Sen)
  {
   return (iMAOnArray(Chinkouspan, 0, Length, 0, Method, index));
  }
  else
  {
   return (EMPTY_VALUE);
  } 
 }
 if (IchIndex==3)
 {
  return (iMAOnArray(Senkouspana, 0, Length, 0, Method, index));
 }
 if (IchIndex==4)
 {
  return (iMAOnArray(Senkouspanb, 0, Length, 0, Method, index));
 }
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
  Tenkansen[pos]=iIchimoku(NULL, 0, Ich_Tenkan_Sen, Ich_Kijun_Sen, Ich_Senkou_Span_B, MODE_TENKANSEN, pos);
  Kijunsen[pos]=iIchimoku(NULL, 0, Ich_Tenkan_Sen, Ich_Kijun_Sen, Ich_Senkou_Span_B, MODE_KIJUNSEN, pos);
  Senkouspana[pos]=iIchimoku(NULL, 0, Ich_Tenkan_Sen, Ich_Kijun_Sen, Ich_Senkou_Span_B, MODE_SENKOUSPANA, pos);
  Senkouspanb[pos]=iIchimoku(NULL, 0, Ich_Tenkan_Sen, Ich_Kijun_Sen, Ich_Senkou_Span_B, MODE_SENKOUSPANB, pos);
  Chinkouspan[pos]=iIchimoku(NULL, 0, Ich_Tenkan_Sen, Ich_Kijun_Sen, Ich_Senkou_Span_B, MODE_CHINKOUSPAN, pos);
  pos--;
 } 

 double C11, C12, C21, C22, C31, C32; 
 pos=limit;
 while(pos>=0)
 {
  C11=GetMA(Disp1_Component1, Disp1_Method1, Disp1_Length1, pos);
  C12=GetMA(Disp1_Component2, Disp1_Method2, Disp1_Length2, pos);
  if (C11!=EMPTY_VALUE && C12!=EMPTY_VALUE)
  {
   Disparity1[pos]=(C11-C12)/Point;
  } 
  C21=GetMA(Disp2_Component1, Disp2_Method1, Disp2_Length1, pos);
  C22=GetMA(Disp2_Component2, Disp2_Method2, Disp2_Length2, pos);
  if (C21!=EMPTY_VALUE && C22!=EMPTY_VALUE)
  {
   Disparity2[pos]=(C21-C22)/Point;
  } 
  C31=GetMA(Disp3_Component1, Disp3_Method1, Disp3_Length1, pos);
  C32=GetMA(Disp3_Component2, Disp3_Method2, Disp3_Length2, pos);
  if (C31!=EMPTY_VALUE && C32!=EMPTY_VALUE)
  {
   Disparity3[pos]=(C31-C32)/Point;
  } 
  pos--;
 }
   
 return(0);
}




