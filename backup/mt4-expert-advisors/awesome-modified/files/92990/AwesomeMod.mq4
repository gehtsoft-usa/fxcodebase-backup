//+------------------------------------------------------------------+
//|                                                   AwesomeMod.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Yellow

extern int Short_Length=18;
extern int Medium_Length=40;
extern int Long_Length=200;
extern int AO_Fast_Length=12;
extern int AO_Slow_Length=18;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double AO_Slow[], AO_Slow_DN[], AO_Fast[], AO_Fast_DN[];
double AO_Slow_Tmp[], AO_Fast_Tmp[];

int init()
{
 IndicatorShortName("AwesomeMod oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,AO_Slow);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,AO_Slow_DN);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,AO_Fast);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,AO_Fast_DN);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,AO_Slow_Tmp);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,AO_Fast_Tmp);

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
 double Short_EMA, Medium_EMA, Long_EMA;
 pos=limit;
 while(pos>=0)
 {
  Short_EMA=iMA(NULL, 0, Short_Length, 0, MODE_EMA, Price, pos);
  Medium_EMA=iMA(NULL, 0, Medium_Length, 0, MODE_EMA, Price, pos);
  Long_EMA=iMA(NULL, 0, Long_Length, 0, MODE_EMA, Price, pos);
  if (Medium_EMA!=0.)
  {
   AO_Fast_Tmp[pos]=100.*(Short_EMA/Medium_EMA-1.);
  }
  if (Long_EMA!=0.) 
  {
   AO_Slow_Tmp[pos]=100.*(Medium_EMA/Long_EMA-1.);
  } 
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  AO_Slow[pos]=iMAOnArray(AO_Slow_Tmp, 0, AO_Slow_Length, 0, MODE_SMA, pos);
  if (AO_Slow[pos]<AO_Slow[pos+1])
  {
   AO_Slow_DN[pos]=AO_Slow[pos];
  }
  else
  {
   AO_Slow_DN[pos]=EMPTY_VALUE;
  }
  AO_Fast[pos]=iMAOnArray(AO_Fast_Tmp, 0, AO_Fast_Length, 0, MODE_SMA, pos);
  if (AO_Fast[pos]<AO_Fast[pos+1])
  {
   AO_Fast_DN[pos]=AO_Fast[pos];
  }
  else
  {
   AO_Fast_DN[pos]=EMPTY_VALUE;
  }
  pos--;
 }
   
 return(0);
}

