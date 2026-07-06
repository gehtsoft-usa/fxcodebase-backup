//+------------------------------------------------------------------+
//|                                                         HiLo.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

double Hi[], Lo[];

int init()
{
 IndicatorShortName("HiLo oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Hi);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Lo);

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
   Hi[pos]=0.;
   Lo[pos]=0.;
  }
  else
  {
   if (High[pos]>High[pos+1])
   {
    Hi[pos]=Hi[pos+1]+1.;
   }
   else
   {
    Hi[pos]=0.;
   }
   
   if (Low[pos]<Low[pos+1])
   {
    Lo[pos]=Lo[pos+1]+1.;
   }
   else
   {
    Lo[pos]=0.;
   }
  }

  pos--;
 } 
 return(0);
}

