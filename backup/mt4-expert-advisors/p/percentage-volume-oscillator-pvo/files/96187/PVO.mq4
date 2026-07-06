//+------------------------------------------------------------------+
//|                                                          PVO.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Magenta
#property indicator_color2 Blue
#property indicator_color3 Green
#property indicator_color4 Red

extern bool Enable_Histogram=true;
extern bool Enable_PVO=true;
extern bool Enable_Signal=true;
extern int Short_Length=12;
extern int Short_Method=1;  // 0 - SMA
                            // 1 - EMA
                            // 2 - SMMA
                            // 3 - LWMA
extern int Long_Length=26;
extern int Long_Method=1;  // 0 - SMA
                           // 1 - EMA
                           // 2 - SMMA
                           // 3 - LWMA
extern int Signal_Length=9;
extern int Signal_Method=1;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern string Mode_Str="Mode: 1 - Absolute, 2 - Relative";                             
extern int Mode=1;   // 1 - Absolute, 2 - Relative

double PVO[], Signal[], Hist[], Hist_Dn[];
double Vol[];

int init()
{
 IndicatorShortName("Percentage Volume Oscillator");
 IndicatorDigits(Digits);
 if (Enable_PVO)
 {
  SetIndexStyle(0,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(0,DRAW_NONE);
 } 
 SetIndexBuffer(0,PVO);
 if (Enable_Signal)
 {
  SetIndexStyle(1,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(1,DRAW_NONE);
 } 
 SetIndexBuffer(1,Signal);
 if (Enable_Histogram)
 {
  SetIndexStyle(2,DRAW_HISTOGRAM);
  SetIndexStyle(3,DRAW_HISTOGRAM);
 }
 else
 {
  SetIndexStyle(2,DRAW_NONE);
  SetIndexStyle(3,DRAW_NONE);
 } 
 SetIndexBuffer(2,Hist);
 SetIndexBuffer(3,Hist_Dn);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Vol);

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
  Vol[pos]=Volume[pos]/1000.;

  pos--;
 } 
 
 double Short_MA, Long_MA;
 pos=limit;
 while(pos>=0)
 {
  Short_MA=1000.*iMAOnArray(Vol, 0, Short_Length, 0, Short_Method, pos);
  Long_MA=1000.*iMAOnArray(Vol, 0, Long_Length, 0, Long_Method, pos);
  if (Mode==1)
  {
   PVO[pos]=Short_MA-Long_MA;
  }
  else
  {
   if (Long_MA!=0.)
   {
    PVO[pos]=100.*(Short_MA-Long_MA)/Long_MA;
   } 
  } 

  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(PVO, 0, Signal_Length, 0, Signal_Method, pos);
  Hist[pos]=PVO[pos]-Signal[pos];
  
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

