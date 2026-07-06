//+------------------------------------------------------------------+
//|                                           Range_Volume_Ratio.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Method=0; // 0 - Open/Close method
                     // 1 - High/Low method

double RVR[];

int init()
{
 IndicatorShortName("Range Volume Ratio oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,RVR);

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
  if (Method==0)
  {
   RVR[pos]=MathAbs(Open[pos]-Close[pos])/(Volume[pos]*Point);
  }
  else
  {
   RVR[pos]=(High[pos]-Low[pos])/(Volume[pos]*Point);
  }
  
  pos--;
 } 
 return(0);
}

