//+------------------------------------------------------------------+
//|                                             Psychology_Index.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=12;

double PI[];
double UpDay[];

int init()
{
 IndicatorShortName("Psychology Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,UpDay);

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
 pos=limit;
 while(pos>=0)
 {
  if (Close[pos]>Close[pos+1])
  {
   UpDay[pos]=1;
  }
  else
  {
   UpDay[pos]=0;
  }
  pos--;
 } 


 pos=limit;
 while(pos>=0)
 {
  PI[pos]=iMAOnArray(UpDay, 0, Length, 0, MODE_SMA, pos);
  pos--;
 }
 
 return(0);
}

