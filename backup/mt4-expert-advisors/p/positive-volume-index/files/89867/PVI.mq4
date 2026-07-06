//+------------------------------------------------------------------+
//|                                                          PVI.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

double PVI[];

int init()
{
 IndicatorShortName("Positive Volume Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PVI);

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
   PVI[pos]=1;
  }
  else
  {
   if (Volume[pos]>Volume[pos+1])
   {
    PVI[pos]=PVI[pos+1]*(1+((Close[pos]-Close[pos+1])/Close[pos+1]));
   }
   else
   {
    PVI[pos]=PVI[pos+1];
   }
  }
  pos--;
 } 
 return(0);
}

