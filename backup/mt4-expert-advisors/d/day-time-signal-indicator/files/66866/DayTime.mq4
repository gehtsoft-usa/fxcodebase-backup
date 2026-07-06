//+------------------------------------------------------------------+
//|                                                      DayTime.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Yellow

extern int IndDay=1; // 0 - Sunday
                     // 1 - Monday
                     // 2 - Tuesday
                     // 3 - Wednesday
                     // 4 - Thursday
                     // 5 - Saturday
                     // 6 - Sunday
extern int IndHour=11;

double UpArrow[], DnArrow[];

int init()
{
 SetIndexBuffer(0,UpArrow);
 SetIndexBuffer(1,DnArrow);   
 SetIndexStyle(0,DRAW_ARROW,0,4);
 SetIndexArrow(0,233);
 SetIndexStyle(1,DRAW_ARROW,0,4);
 SetIndexArrow(1,234);
 SetIndexEmptyValue(0,0.0);
 SetIndexEmptyValue(1,0.0);
 SetIndexLabel(0,"Up");
 SetIndexLabel(1,"Down");

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 if (ExtCountedBars>0) ExtCountedBars--;
 int    pos=Bars+1;
 if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
 while(pos>=0)
  {
   if (TimeDayOfWeek(Time[pos])==IndDay && TimeHour(Time[pos])==IndHour && TimeHour(Time[pos+1])!=IndHour)
   {
    int index=iBarShift(NULL, PERIOD_D1, Time[pos]); 
    double PrevDayOpen=iOpen(NULL, PERIOD_D1, index+1);
    if (Close[pos+1]<PrevDayOpen)
    {
     UpArrow[pos]=Low[pos];
    }
    else
    {
     if (Close[pos+1]>PrevDayOpen)
     {
      DnArrow[pos]=High[pos];
     }
    }
   }
   pos--;
  }
 return(0);
}

