//+------------------------------------------------------------------+
//|                                                          VLM.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Lime
#property indicator_color3 Green
#property indicator_color4 Blue

extern int Length=30;

double V1[], V2[], V3[], V4[];
double Vol[];

int init()
{
 IndicatorShortName("VLM");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,V1);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,V2);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,V3);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,V4);
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
 pos=limit;
 while(pos>=0)
 {
  Vol[pos]=Volume[pos];

  pos--;
 } 
 
 double VolAvg;
 double res;
 int H;
 pos=limit;
 while(pos>=0)
 {
  VolAvg=iMAOnArray(Vol, 0, Length, 0, MODE_SMA, pos);
  if (VolAvg!=0.)
  {
   res=Volume[pos]/(VolAvg*Point);
  }
  else
  {
   res=0.;
  }
   
  V1[pos]=0.;
  V2[pos]=0.;
  V3[pos]=0.;
  V4[pos]=0.;
  
  H=TimeHour(Time[pos]);
  
  if (H>=8 && H<14)
  {
   V1[pos]=res;
  }
  else
  {
   if (H>=18 && H<=21)
   {
    V1[pos]=res;
   }
   else
   {
    if (H>=14 && H<18)
    {
     V2[pos]=res;
    }
    else
    {
     if (H>=22)
     {
      V3[pos]=res;
     }
     else
     {
      V4[pos]=res;
     }
    }
   }
  } 

  pos--;
 }
   
 return(0);
}

