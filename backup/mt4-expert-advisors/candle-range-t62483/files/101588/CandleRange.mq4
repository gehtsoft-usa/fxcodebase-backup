//+------------------------------------------------------------------+
//|                                                  CandleRange.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern double Range=25;
extern int Arrow_Size=3;

double Up[], Dn[];

int init()
{
 IndicatorShortName("Candle Range");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,Arrow_Size);
 SetIndexArrow(0,233);
 SetIndexBuffer(0,Up);
 SetIndexStyle(1,DRAW_ARROW,0,Arrow_Size);
 SetIndexArrow(1,234);
 SetIndexBuffer(1,Dn);

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
 double Delta;
 pos=limit;
 while(pos>=0)
 {
  Delta=Range*(High[pos]-Low[pos])/100.;
  if (Close[pos]>High[pos]-Delta)
  {
   Up[pos]=Low[pos];
   Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   if (Close[pos]<Low[pos]+Delta)
   {
    Up[pos]=EMPTY_VALUE;
    Dn[pos]=High[pos];
   }
   else
   {
    Up[pos]=EMPTY_VALUE;
    Dn[pos]=EMPTY_VALUE;
   }
  }

  pos--;
 } 
 return(0);
}

