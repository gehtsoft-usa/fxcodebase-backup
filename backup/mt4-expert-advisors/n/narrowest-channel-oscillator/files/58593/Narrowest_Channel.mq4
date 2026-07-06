//+------------------------------------------------------------------+
//|                                            Narrowest_Channel.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Yellow

extern int RangeLength=3;
extern int Length=10;

double Range[], MinRange[], Signal[];

int init()
  {
   IndicatorShortName("Narrowest channel");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Range);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MinRange);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,119);
   SetIndexBuffer(2,Signal);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=MathMax(RangeLength, Length)) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int i;
 int limit=Bars-2;
 double Max, Min;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  Max=High[iHighest(NULL, 0, MODE_HIGH, RangeLength, pos)];
  Min=Low[iLowest(NULL, 0, MODE_LOW, RangeLength, pos)];
  Range[pos]=Max-Min;
  pos--;
 }
 pos=limit;
 while(pos>=0)
 {
  MinRange[pos]=Range[ArrayMinimum(Range, Length, pos+1)];
  if (Range[pos]<MinRange[pos] && Range[pos+1]>=MinRange[pos+1])
  {
   Signal[pos]=MinRange[pos];
  }
  else
  {
   Signal[pos]=EMPTY_VALUE;
  }
  pos--;
 }
 return(0);
}

