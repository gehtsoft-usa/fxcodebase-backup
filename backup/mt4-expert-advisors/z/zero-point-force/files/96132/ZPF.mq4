//+------------------------------------------------------------------+
//|                                                          ZPF.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Green

extern int Short_Length=12;
extern int Short_Method=0;  // 0 - SMA
                            // 1 - EMA
                            // 2 - SMMA
                            // 3 - LWMA
extern int Long_Length=24;
extern int Long_Method=0;  // 0 - SMA
                           // 1 - EMA
                           // 2 - SMMA
                           // 3 - LWMA
extern int Volume_Length=12;
extern int Volume_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA

double ZPF1[], ZPF2[], ZPF3[], ZPF4[];
double Vol[];

int init()
{
 IndicatorShortName("Zero Point Force");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ZPF1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,ZPF2);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,ZPF3);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,ZPF4);
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
 double V, S, L;
 double ZPF;
 pos=limit;
 while(pos>=0)
 {
  Vol[pos]=Volume[pos];

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  V=iMAOnArray(Vol, 0, Volume_Length, 0, Volume_Method, pos);
  S=iMA(NULL, 0, Short_Length, 0, Short_Method, PRICE_CLOSE, pos);
  L=iMA(NULL, 0, Long_Length, 0, Long_Method, PRICE_CLOSE, pos);
  
  ZPF=V*(S-L)/(2.*Point);
  
  if (ZPF<0.)
  {
   ZPF1[pos]=ZPF;
   ZPF2[pos]=-ZPF;
   ZPF3[pos]=EMPTY_VALUE;
   ZPF4[pos]=EMPTY_VALUE;
  }
  else
  {
   ZPF3[pos]=ZPF;
   ZPF4[pos]=-ZPF;
   ZPF1[pos]=EMPTY_VALUE;
   ZPF2[pos]=EMPTY_VALUE;
  }

  pos--;
 }
   
 return(0);
}

