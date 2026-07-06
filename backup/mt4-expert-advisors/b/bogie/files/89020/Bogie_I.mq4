//+------------------------------------------------------------------+
//|                                                      Bogie_I.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Short_Length=7;
extern int Long_Length=14;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Bogie[];

int init()
{
 IndicatorShortName("Bogie");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Bogie);

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
 double Left, Right, Bottom;
 double Pr;
 pos=limit;
 while(pos>=0)
 {
  Left=iMA(NULL, 0, Short_Length-1, 0, MODE_SMA, Price, pos+1)*(Short_Length-1)*Long_Length;
  Right=iMA(NULL, 0, Long_Length-1, 0, MODE_SMA, Price, pos+1)*(Long_Length-1)*Short_Length;
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Bottom=Short_Length-Long_Length;
  Bogie[pos]=(Left-Right)/Bottom;
  pos--;
 } 
 return(0);
}

