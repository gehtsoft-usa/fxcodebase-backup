//+------------------------------------------------------------------+
//|                                             Candle_Amplitude.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern string Method_Str="Method: 0 - High-Low, 1 - Close-Open";
extern int Method=0;  // 0 - High-Low, 1 - Close-Open
extern int Signal_Length=10;

double Main[], Signal[];

int init()
{
 IndicatorShortName("Candle Amplitude");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Main);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);

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
  if (Method==0)
  {
   Main[pos]=High[pos]-Low[pos];
  }
  else
  {
   Main[pos]=Close[pos]-Open[pos];
  }

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(Main, 0, Signal_Length, 0, MODE_SMA, pos);

  pos--;
 }
   
 return(0);
}

