//+------------------------------------------------------------------+
//|                                                         III2.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Blue

extern int Length=21;
extern int Smoothing_Length=14;

double III[], Signal[];
double Raw[], Vol[];

int init()
{
 IndicatorShortName("Intraday Intensity oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,III);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Raw);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Vol);

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
  if (High[pos]!=Low[pos])
  {
   Raw[pos]=Volume[pos]*(2.*Close[pos]-High[pos]-Low[pos])/(High[pos]-Low[pos]);
  } 
  Vol[pos]=Volume[pos];

  pos--;
 } 
 
 double Avg, AvgVol;
 pos=limit;
 while(pos>=0)
 {
  Avg=iMAOnArray(Raw, 0, Length, 0, MODE_SMA, pos);
  AvgVol=iMAOnArray(Vol, 0, Length, 0, MODE_SMA, pos);
  if (AvgVol!=0.)
  {
   III[pos]=100.*Avg/(AvgVol*Point);
  }

  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(III, 0, Smoothing_Length, 0, MODE_SMA, pos);

  pos--;
 }  
   
 return(0);
}

