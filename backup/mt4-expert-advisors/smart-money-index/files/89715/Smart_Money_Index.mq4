//+------------------------------------------------------------------+
//|                                            Smart_Money_Index.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int OpenHour=3;
extern int SessionLength=8;

double SMI[];

int init()
{
 IndicatorShortName("Smart money index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,SMI);

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
 datetime t, sfrom, sto;
 int X1, X2;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2) SMI[pos+1]=0;
  t=Time[pos];
  t=t-OpenHour*3600;
  t=MathFloor(t/86400+0.5)*86400;
  t=t+OpenHour*3600;
  sfrom=t;
  sto=sfrom+SessionLength*3600;
  X1=iBarShift(NULL, 0, sfrom, false);
  X2=iBarShift(NULL, 0, sto, false);
  if (X1==pos || X2==pos)
  {
   SMI[pos]=SMI[pos+1]-(Close[X1]-Open[X1])+(Close[X2]-Open[X2]);
  }
  else
  {
   SMI[pos]=SMI[pos+1];
  }
  pos--;
 } 
 return(0);
}

