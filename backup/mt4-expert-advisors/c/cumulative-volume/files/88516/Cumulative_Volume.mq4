//+------------------------------------------------------------------+
//|                                            Cumulative_Volume.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Green

extern int Length=14;
extern bool Combined=true;
extern bool Relative=false;

double Positive[], Negative[], Cumulative[];
double APos[], ANeg[];

int init()
{
 IndicatorShortName("Cumulative Volume");
 IndicatorDigits(Digits);
 if (Combined)
 {
  SetIndexStyle(0,DRAW_HISTOGRAM);
  SetIndexBuffer(0,Cumulative);
  SetIndexStyle(1,DRAW_NONE);
  SetIndexBuffer(1,Positive);
  SetIndexStyle(2,DRAW_NONE);
  SetIndexBuffer(2,Negative);
  SetIndexStyle(3,DRAW_NONE);
  SetIndexBuffer(3,APos);
  SetIndexStyle(4,DRAW_NONE);
  SetIndexBuffer(4,ANeg);
 }
 else
 {
  SetIndexStyle(0,DRAW_HISTOGRAM);
  SetIndexBuffer(0,Positive);
  SetIndexStyle(1,DRAW_HISTOGRAM);
  SetIndexBuffer(1,Negative);
  SetIndexStyle(2,DRAW_NONE);
  SetIndexBuffer(2,APos);
  SetIndexStyle(3,DRAW_NONE);
  SetIndexBuffer(3,ANeg);
 }
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double SVolume;
 double p, n;
 int i;
 pos=limit;
 while(pos>=0)
 {
  if (Close[pos]>Close[pos+1])
  {
   APos[pos]=Volume[pos]/100;
   ANeg[pos]=0;
  }
  else
  {
   APos[pos]=0;
   ANeg[pos]=Volume[pos]/100;
  }
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  p=iMAOnArray(APos, 0, Length, 0, MODE_SMA, pos)*Length;
  n=iMAOnArray(ANeg, 0, Length, 0, MODE_SMA, pos)*Length;
  SVolume=0.;
  for (i=0;i<Length;i++)
  {
   SVolume=SVolume+Volume[pos+i];
  }
  SVolume=SVolume/100;
  if (Combined)
  {
   if (Relative)
   {
    Cumulative[pos]=(p-n)*1000/SVolume;
   }
   else
   {
    Cumulative[pos]=p-n;
   }
  }
  else
  {
   if (Relative)
   {
    Positive[pos]=p*1000/SVolume;
    Negative[pos]=-n*1000/SVolume;
   }
   else
   {
    Positive[pos]=p;
    Negative[pos]=-n;
   }
  }
  pos--;
 }
   
 return(0);
}

