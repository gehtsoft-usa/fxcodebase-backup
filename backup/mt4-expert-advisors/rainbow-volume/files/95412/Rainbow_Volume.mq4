//+------------------------------------------------------------------+
//|                                               Rainbow_Volume.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Blue
#property indicator_color3 Red
#property indicator_color4 Yellow

extern int Length=10;

double V1[], V2[], V3[], V4[];

int init()
{
 IndicatorShortName("Rainbow Volume");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,V1);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,V2);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,V3);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,V4);

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
  V1[pos]=Volume[pos];
  V2[pos]=EMPTY_VALUE;
  V3[pos]=EMPTY_VALUE;
  V4[pos]=EMPTY_VALUE;
  
  if (Close[pos]>Close[pos+Length] && Volume[pos]<Volume[pos+Length])
  {
   V2[pos]=V1[pos];
  }
  else
  {
   if (Close[pos]<Close[pos+Length] && Volume[pos]<Volume[pos+Length])
   {
    V3[pos]=V1[pos];
   }
   else
   {
    if (Close[pos]<Close[pos+Length] && Volume[pos]>Volume[pos+Length])
    {
     V4[pos]=V1[pos];
    }
   }
  }
  
  pos--;
 } 
 return(0);
}

