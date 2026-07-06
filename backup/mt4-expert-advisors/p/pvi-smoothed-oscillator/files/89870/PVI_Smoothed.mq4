//+------------------------------------------------------------------+
//|                                                 PVI_Smoothed.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Red

extern int Smooth_Length=5;
extern int Signal_Length=15;

double PVI[], Signal[];
double PVI_St[];

int init()
{
 IndicatorShortName("Smoothed Positive Volume Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PVI);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,PVI_St);

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
  if (pos==Bars-2)
  {
   PVI_St[pos]=1;
  }
  else
  {
   if (Volume[pos]>Volume[pos+1])
   {
    PVI_St[pos]=PVI_St[pos+1]*(1+((Close[pos]-Close[pos+1])/Close[pos+1]));
   }
   else
   {
    PVI_St[pos]=PVI_St[pos+1];
   }
  }
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  PVI[pos]=iMAOnArray(PVI_St, 0, Smooth_Length, 0, MODE_SMA, pos);
  pos--;
 }
   
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(PVI, 0, Signal_Length, 0, MODE_EMA, pos);
  pos--;
 }
   
 return(0);
}

