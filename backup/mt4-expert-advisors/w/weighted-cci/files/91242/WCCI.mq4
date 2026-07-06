//+------------------------------------------------------------------+
//|                                                         WCCI.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Fast_CCI_Length=7;
extern int Slow_CCI_Length=14;
extern int Weight=1;
extern int Fast_ATR_Length=7;
extern int Slow_ATR_Length=50;
extern int Major_Overbought_Level=200;
extern int Major_Oversold_Level=-200;
extern int Minor_Overbought_Level=50;
extern int Minor_Oversold_Level=-50;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double Fast[], Slow[];

int init()
{
 IndicatorShortName("Weighted CCI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Fast);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Slow);
 
 SetLevelValue(0, Major_Overbought_Level);
 SetLevelValue(1, Major_Oversold_Level);
 SetLevelValue(2, Minor_Overbought_Level);
 SetLevelValue(3, Minor_Oversold_Level);

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
 double Kw;
 double F, S;
 double ATR1, ATR2;
 pos=limit;
 while(pos>=0)
 {
  if (Weight!=0)
  {
   ATR1=iATR(NULL, 0, Fast_ATR_Length, pos);
   ATR2=iATR(NULL, 0, Slow_ATR_Length, pos);
   if (ATR2!=0)
   {
    Kw=Weight*ATR1/ATR2;
    F=Kw*iCCI(NULL, 0, Fast_CCI_Length, Price, pos);
    S=Kw*iCCI(NULL, 0, Slow_CCI_Length, Price, pos);
   } 
   else
   {
    F=0;
    S=0;
   }
  }
  else
  {
   F=iCCI(NULL, 0, Fast_CCI_Length, Price, pos);
   S=iCCI(NULL, 0, Slow_CCI_Length, Price, pos);
  }
  
  S=MathMin(S, Major_Overbought_Level+50);
  F=MathMin(F, Major_Overbought_Level+50);
  S=MathMax(S, Major_Oversold_Level-50);
  F=MathMax(F, Major_Oversold_Level-50);
  
  Fast[pos]=F;
  Slow[pos]=S;
  
  pos--;
 } 
 return(0);
}

