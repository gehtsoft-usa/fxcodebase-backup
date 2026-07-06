//+------------------------------------------------------------------+
//|                                                          Rex.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Smoothing_Length=14;
extern int Smoothing_Method=0;  // 0 - SMA
                                // 1 - EMA
                                // 2 - SMMA
                                // 3 - LWMA
extern int Signal_Length=14;
extern int Signal_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA

double Rex[], Signal[];
double TVB[];

int init()
{
 IndicatorShortName("Rex oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Rex);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,TVB);

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
  TVB[pos]=3.*Close[pos]-(Low[pos]+Open[pos]+High[pos]);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Rex[pos]=iMAOnArray(TVB, 0, Smoothing_Length, 0, Smoothing_Method, pos)/Point;

  pos--;
 }
   
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(Rex, 0, Signal_Length, 0, Signal_Method, pos);

  pos--;
 }
   
 return(0);
}

