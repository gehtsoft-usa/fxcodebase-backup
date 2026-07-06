//+------------------------------------------------------------------+
//|                                                          MIT.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

extern int Start_Hour=0;
extern int Start_Min=0;

double MIT[], Start[];

int init()
{
 IndicatorShortName("Momentum In Time");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MIT);
 SetIndexStyle(1,DRAW_ARROW,0,4);
 SetIndexArrow(1,119);
 SetIndexBuffer(1,Start);

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
 datetime T, DayIndex, Index;
 pos=limit;
 while(pos>=0)
 {
  if (Period()<1440)
  {
   DayIndex=iBarShift(NULL, PERIOD_D1, Time[pos], false);
   T=iTime(NULL, PERIOD_D1, DayIndex);
   T=T+3600*Start_Hour+60*Start_Min;
   if (Period()==1)
   {
    Index=iBarShift(NULL, 0, T, true);
   }
   else
   {
    Index=iBarShift(NULL, 0, T, false);
   }
   MIT[pos]=Close[pos]-Open[Index];
   if (pos==Index)
   {
    Start[pos]=0;
   }
  }
  else
  {
   MIT[pos]=Close[pos]-Open[pos+1];
  }
  pos--;
 } 
 return(0);
}

