//+------------------------------------------------------------------+
//|                                                          DBB.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

extern int Length=20;
extern double Deviation=2.;
extern string MethodStr="Method: 0 - Percentage, 1 - Pips";
extern int Method=0;  // 0 - Percentage, 1 - Pips
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted

double Top[], Bottom[];

int init()
{
 IndicatorShortName("Distance from Bollinger Band");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Top);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Bottom);

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
 double TL, BL;
 double Pr;
 pos=limit;
 while(pos>=0)
 {
  TL=iBands(NULL, 0, Length, Deviation, 0, Price, MODE_UPPER, pos);
  BL=iBands(NULL, 0, Length, Deviation, 0, Price, MODE_LOWER, pos);
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  
  if (Method==0)
  {
   if (TL!=BL)
   {
    Top[pos]=100.*(TL-Pr)/(TL-BL);
    Bottom[pos]=100.*(Pr-BL)/(TL-BL);
   }
  }
  else
  {
   Top[pos]=(TL-Pr)/Point;
   Bottom[pos]=(Pr-BL)/Point;
  }

  pos--;
 } 
 return(0);
}

