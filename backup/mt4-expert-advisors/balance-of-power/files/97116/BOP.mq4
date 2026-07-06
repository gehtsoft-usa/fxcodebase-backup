//+------------------------------------------------------------------+
//|                                                          BOP.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Price_Action=14;
extern int Range_Length=28;
extern bool Use_Last_Period=true;

double BOP[], BOP_Dn[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,BOP);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,BOP_Dn);

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
 double Min, Max;
 pos=limit;
 while(pos>=0)
 {
  if (Use_Last_Period)
  {
   Max=High[iHighest(NULL, 0, MODE_HIGH, Range_Length, pos)];
   Min=Low[iLowest(NULL, 0, MODE_LOW, Range_Length, pos)];
  }
  else
  {
   Max=High[iHighest(NULL, 0, MODE_HIGH, Range_Length, pos+1)];
   Min=Low[iLowest(NULL, 0, MODE_LOW, Range_Length, pos+1)];
  }
  
  if (Max!=Min)
  {
   BOP[pos]=(Close[pos]-Open[pos+Price_Action-1])/(Max-Min);
  }
  else
  {
   BOP[pos]=EMPTY_VALUE;
  }
  
  if (Close[pos]>Min+(Max-Min)/2.)
  {
   BOP_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   BOP_Dn[pos]=BOP[pos];
  }

  pos--;
 } 
 return(0);
}

