//+------------------------------------------------------------------+
//|                                          Trading_Day_Average.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

extern string BeginTime="03:00";

#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Green

double CloudBuff[], LowBuff[], HighBuff[];

int init()
  {
   IndicatorShortName("Trading day average");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,CloudBuff);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,LowBuff);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,HighBuff);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   if(Bars<=2) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>=0)
   {
    datetime LastBegin=StrToTime(TimeToStr(Time[pos],TIME_DATE)+" "+BeginTime);
    if (LastBegin>Time[pos]) LastBegin-=86400;
    int LastBeginBar=iBarShift(NULL, 0, LastBegin, false);
    int Length=LastBeginBar-pos+1;
    CloudBuff[pos]=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_HIGH, pos);
    HighBuff[pos]=CloudBuff[pos];
    LowBuff[pos]=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_LOW, pos);
    pos--;
   } 

   return(0);
  }


