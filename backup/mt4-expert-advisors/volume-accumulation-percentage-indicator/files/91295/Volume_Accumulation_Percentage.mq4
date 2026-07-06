//+------------------------------------------------------------------+
//|                               Volume_Accumulation_Percentage.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red

extern int Length=14;

double VACC[];
double VA[], Vol[];

int init()
{
 IndicatorShortName("Volume Accumulation Percentage indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,VACC);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,VA);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Vol);

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
   VA[pos]=Point*Volume[pos]*(2*Close[pos]-High[pos]-Low[pos])/(High[pos]-Low[pos]);
  }
  Vol[pos]=Volume[pos]*Point;
  pos--;
 } 
 
 double TVA, TV;
 pos=limit;
 while(pos>=0)
 {
  TVA=iMAOnArray(VA, 0, Length, 0, MODE_SMA, pos);
  TV=iMAOnArray(Vol, 0, Length, 0, MODE_SMA, pos);
  if (TV!=0)
  {
   VACC[pos]=100.*TVA/TV;
  } 
  pos--;
 } 
   
 return(0);
}

