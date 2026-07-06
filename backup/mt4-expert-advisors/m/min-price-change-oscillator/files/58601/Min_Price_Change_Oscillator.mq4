//+------------------------------------------------------------------+
//|                                  Min_Price_Change_Oscillator.mq4 |
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

extern int ChangesLength=4;
extern int CheckLength=10;
extern bool AbsChange=false;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Ind[], Min[], Signal[];

int init()
  {
   IndicatorShortName("Min price change oscillator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Ind);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Min);
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
 if(Bars<=MathMax(ChangesLength, CheckLength)) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int i;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  double Sum=0;
  for (i=0;i<ChangesLength;i++)
  {
   if (AbsChange)
   {
    Sum=Sum+MathAbs(iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+i)-iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+i+1));
   }
   else
   {
    Sum=Sum+iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+i)-iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+i+1);
   }
  }
  Ind[pos]=MathAbs(Sum);
  pos--;
 }
 pos=limit;
 while(pos>=0)
 {
  Min[pos]=Ind[ArrayMinimum(Ind, CheckLength, pos+1)];
  if (Ind[pos]<Min[pos] && Ind[pos+1]>=Min[pos+1])
  {
   Signal[pos]=Min[pos];
  }
  else
  {
   Signal[pos]=EMPTY_VALUE;
  }
  pos--;
 }
 return(0);
}

