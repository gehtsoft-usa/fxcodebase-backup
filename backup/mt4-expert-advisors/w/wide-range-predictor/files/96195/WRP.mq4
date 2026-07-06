//+------------------------------------------------------------------+
//|                                                          WRP.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 DarkRed
#property indicator_color3 Green
#property indicator_color4 DarkGreen
#property indicator_color5 Blue
#property indicator_color6 Blue

extern int Length=10;

double RangeUp[], RangeDn[], RangeMA[], BodyUp[], BodyDn[], BodyMA[];
double Body[];

int init()
{
 IndicatorShortName("Wide Range Predictor");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,RangeUp);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,RangeDn);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,BodyUp);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,BodyDn);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,RangeMA);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,BodyMA);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,Body);

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
  Body[pos]=MathAbs(Close[pos]-Open[pos]);

  pos--;
 } 
 
 double MA_High, MA_Low;
 double Range;
 pos=limit;
 while(pos>=0)
 {
  MA_High=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_HIGH, pos);
  MA_Low=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_LOW, pos);
  RangeMA[pos]=MA_High-MA_Low;
  BodyMA[pos]=iMAOnArray(Body, 0, Length, 0, MODE_SMA, pos);
  Range=High[pos]-Low[pos];
  
  if (Range>RangeMA[pos])
  {
   RangeUp[pos]=Range;
   RangeDn[pos]=EMPTY_VALUE;
  }
  else
  {
   RangeUp[pos]=EMPTY_VALUE;
   RangeDn[pos]=Range;
  }
  
  if (Body[pos]>BodyMA[pos])
  {
   BodyUp[pos]=Body[pos];
   BodyDn[pos]=EMPTY_VALUE;
  }
  else
  {
   BodyUp[pos]=EMPTY_VALUE;;
   BodyDn[pos]=Body[pos];
  }

  pos--;
 }
   
 return(0);
}

