//+------------------------------------------------------------------+
//|                                                     WILL_VAL.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern string Instrument="EURJPY";
extern int Length1=22;
extern int Length2=2;
extern int Length3=365;
extern double Overbought_Level=75.;
extern double Oversold_Level=25.;

double WV[];
double Price[], Value[];

int init()
{
 IndicatorShortName("WILL VAL oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,WV);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Price);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Value);
 
 SetLevelValue(0, Overbought_Level);
 SetLevelValue(1, Oversold_Level);

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
 int IPos;
 double IPr;
 pos=limit;
 while(pos>=0)
 {
  IPos=iBarShift(Instrument, 0, Time[pos], false);
  if (IPos>=0)
  {
   IPr=iClose(Instrument, 0, IPos);
   if (IPr!=0.)
   {
    Price[pos]=Close[pos]/IPr;
   }
  }

  pos--;
 } 
 
 double MA1, MA2;
 pos=limit;
 while(pos>=0)
 {
  MA1=iMAOnArray(Price, 0, Length1, 0, MODE_EMA, pos);
  MA2=iMAOnArray(Price, 0, Length2, 0, MODE_EMA, pos);
  Value[pos]=MA1-MA2;

  pos--;
 }
 
 double Min, Max;
 pos=limit;
 while(pos>=0)
 {
  Min=Value[ArrayMinimum(Value, Length3, pos)];
  Max=Value[ArrayMaximum(Value, Length3, pos)];
  
  if (Max!=Min)
  {
   WV[pos]=100.*(Value[pos]-Min)/(Max-Min);
  }
  else
  {
   WV[pos]=EMPTY_VALUE;
  }

  pos--;
 }  
   
 return(0);
}

