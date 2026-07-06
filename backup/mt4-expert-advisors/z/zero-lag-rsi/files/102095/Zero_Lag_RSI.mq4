//+------------------------------------------------------------------+
//|                                                 Zero_Lag_RSI.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 DarkGreen
#property indicator_color3 Red
#property indicator_color4 DarkRed

extern int Smoothing1=15;
extern int Smoothing2=7;
extern double Factor1=0.05;
extern int RSI_Length1=8;
extern double Factor2=0.1;
extern int RSI_Length2=21;
extern double Factor3=0.16;
extern int RSI_Length3=34;
extern double Factor4=0.26;
extern int RSI_Length4=55;
extern double Factor5=0.43;
extern int RSI_Length5=89;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  


double UU[], UD[], DU[], DD[];
double FastTrend[], SlowTrend[];
double SmoothConst1, SmoothConst2;

int init()
{
 IndicatorShortName("Zero Lag RSI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UU);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,UD);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,DU);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,DD);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,FastTrend);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,SlowTrend);
 
 SmoothConst1=(Smoothing1-1.)/Smoothing1;
 SmoothConst2=(Smoothing2-1.)/Smoothing2;

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
 double RSI1, RSI2, RSI3, RSI4, RSI5;
 double Osc1, Osc2, Osc3, Osc4, Osc5;
 pos=limit;
 while(pos>=0)
 {
  RSI1=iRSI(NULL, 0, RSI_Length1, Price, pos);
  RSI2=iRSI(NULL, 0, RSI_Length2, Price, pos);
  RSI3=iRSI(NULL, 0, RSI_Length3, Price, pos);
  RSI4=iRSI(NULL, 0, RSI_Length4, Price, pos);
  RSI5=iRSI(NULL, 0, RSI_Length5, Price, pos);
  
  Osc1=Factor1*RSI1;
  Osc2=Factor1*RSI2;
  Osc3=Factor1*RSI3;
  Osc4=Factor1*RSI4;
  Osc5=Factor1*RSI5;
  
  FastTrend[pos]=Osc1+Osc2+Osc3+Osc4+Osc5;
  
  SlowTrend[pos]=FastTrend[pos]/Smoothing1+SlowTrend[pos+1]*SmoothConst1;
  
  UU[pos]=(FastTrend[pos]-SlowTrend[pos])/(Smoothing2*Point)+UU[pos+1]*SmoothConst2;
  
  UD[pos]=EMPTY_VALUE;
  DU[pos]=EMPTY_VALUE;
  DD[pos]=EMPTY_VALUE;
  
  if (UU[pos]>0.)
  {
   if (UU[pos]<UU[pos+1])
   {
    UD[pos]=UU[pos];
   }
  }
  else
  {
   if (UU[pos]>UU[pos+1])
   {
    DU[pos]=UU[pos];
   }
   else
   {
    DD[pos]=UU[pos];
   }
  }

  pos--;
 } 
 return(0);
}

