//+------------------------------------------------------------------+
//|                                             Period_Open_Line.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern string Description="Time frame: 1-m1, 2-m5, 3-m15, 4-m30, 5-H1, 6-H4, 7-D1, 8-W1, 9-MN, 10-Y1";
extern int TimeFrame=7;

double POL[];
int TF;

int ConvertPeriod(int TF)
{
 if (TF==1) return (PERIOD_M1);
 if (TF==2) return (PERIOD_M5);
 if (TF==3) return (PERIOD_M15);
 if (TF==4) return (PERIOD_M30);
 if (TF==5) return (PERIOD_H1);
 if (TF==6) return (PERIOD_H4);
 if (TF==7) return (PERIOD_D1);
 if (TF==8) return (PERIOD_W1);
 return (PERIOD_MN1);
}

int init()
{
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,POL);
 TF=ConvertPeriod(TimeFrame);
 return(0);
}

int deinit()
  {

   return(0);
  }
  
datetime BeginOfYear(datetime T)
{
 return (StrToTime(TimeYear(T)+".1.1 00:00"));
}  

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 int index;
 pos=limit;
 while(pos>=0)
 {
  if (TimeFrame<10)
  {
   index=iBarShift(NULL, TF, Time[pos], false);
  }
  else
  {
   index=iBarShift(NULL, TF, BeginOfYear(Time[pos]), false);
  } 
  POL[pos]=iOpen(NULL, TF, index);
  pos--;
 } 

 return(0);
}

