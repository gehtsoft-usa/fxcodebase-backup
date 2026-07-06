//+------------------------------------------------------------------+
//|                                                          III.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=21;
extern bool Use_Normalization=true;

double III[];
double Raw[], Vol[];

int init()
{
 IndicatorShortName("Intraday Intensity Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,III);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Raw);
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
  Raw[pos]=((2.*Close[pos]-High[pos]-Low[pos])/(High[pos]-Low[pos]))*Volume[pos];
  Vol[pos]=Volume[pos];

  pos--;
 } 
 
 double Avg1, Avg2;
 pos=limit;
 while(pos>=0)
 {
  Avg1=iMAOnArray(Raw, 0, Length, 0, MODE_SMA, pos);
  if (Use_Normalization)
  {
   Avg2=iMAOnArray(Vol, 0, Length, 0, MODE_SMA, pos);
   if (Avg2!=0.)
   {
    III[pos]=100.*Avg1/(Avg2*Point);
   }
   else
   {
    III[pos]=EMPTY_VALUE;
   }
  }
  else
  {
   III[pos]=Avg1*Length/Point;
  }

  pos--;
 }
   
 return(0);
}

