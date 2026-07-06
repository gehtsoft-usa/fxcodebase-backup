//+------------------------------------------------------------------+
//|                                          Volume_Accumulation.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

double VA[];

int init()
{
 IndicatorShortName("Volume Accumulation");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,VA);

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
  if (High[pos]-Low[pos]==0)
  {
   VA[pos]=0;
  }
  else
  {
   VA[pos]=Volume[pos]*(2*Close[pos]-High[pos]-Low[pos])/(High[pos]-Low[pos]);
  }
  
  pos--;
 } 
 return(0);
}

