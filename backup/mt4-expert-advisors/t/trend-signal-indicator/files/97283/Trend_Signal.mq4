//+------------------------------------------------------------------+
//|                                                 Trend_Signal.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=9;
extern int Risk=30;
extern int LabelSize=3;

double Up[], Dn[];
double Range[], Trend[];

int init()
{
 IndicatorShortName("Trend signal");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW, 0, LabelSize);
 SetIndexBuffer(0,Up);
 SetIndexArrow(0,233);
 SetIndexStyle(1,DRAW_ARROW, 0, LabelSize);
 SetIndexBuffer(1,Dn);
 SetIndexArrow(1,234);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Range);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Trend);

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
  Range[pos]=High[pos]-Low[pos];

  pos--;
 } 
 
 double Min, Max;
 double _Min, _Max;
 double Avg_Range;
 pos=limit;
 while(pos>=0)
 {
  Avg_Range=iMAOnArray(Range, 0, Length, 0, MODE_SMA, pos);
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos+1)];
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos+1)];
  _Max=Max-(Max-Min)*Risk/100.;
  _Min=Min+(Max-Min)*Risk/100.;
  
  if (Close[pos+1]<_Max && Close[pos]>_Max && Trend[pos+1]!=1.)
  {
   Trend[pos]=1.;
   Up[pos]=Low[pos]-Avg_Range/2.;
  }
  else
  {
   if (Close[pos+1]>_Min && Close[pos]<_Min && Trend[pos+1]!=-1.)
   {
    Trend[pos]=-1.;
    Dn[pos]=High[pos]+Avg_Range/2.;
   }
   else
   {
    Trend[pos]=Trend[pos+1];
   }
  }

  pos--;
 }
   
 return(0);
}

