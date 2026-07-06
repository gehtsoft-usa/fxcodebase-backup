//+------------------------------------------------------------------+
//|                                                       WEVOMO.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=14;
extern bool Show_VOMOMA=true;
extern bool Show_WEVOMO=true;

double VOMOMA[], WEVOMO[];
double Difference[], Vol[];
double LSum;

int init()
{
 IndicatorShortName("Weight Volume Move-Adjusted Moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,WEVOMO);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,VOMOMA);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Difference);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Vol);
 
 LSum=(Length+1.)*Length/2.;

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
  Difference[pos]=MathAbs(Close[pos]-Close[pos+1]);
  Vol[pos]=Volume[pos];

  pos--;
 } 

 double DifferenceSum, VolumeSum;
 int i;
 double VOMA, MOMA, WMA;
 pos=limit;
 while(pos>=0)
 {
  DifferenceSum=iMAOnArray(Difference, 0, Length, 0, MODE_SMA, pos)*Length;  
  VolumeSum=iMAOnArray(Vol, 0, Length, 0, MODE_SMA, pos)*Length;
  if (DifferenceSum!=0. && VolumeSum!=0.)
  {
   VOMA=0.;
   MOMA=0.;
   WMA=0.;
   for (i=1;i<=Length;i++)  
   {
    MOMA+=Close[pos+Length-i]*Difference[pos+Length-i]/DifferenceSum;
    VOMA+=Close[pos+Length-i]*Vol[pos+Length-i]/VolumeSum;
    WMA+=Close[pos+Length-i]*i;
   }
   WMA=WMA/LSum;
  
   if (Show_VOMOMA)
   {
    VOMOMA[pos]=(MOMA+VOMA)/2.;
   }
   if (Show_WEVOMO)
   {
    WEVOMO[pos]=(MOMA+VOMA+WMA)/3.;
   } 
  }

  pos--;
 } 
 return(0);
}

