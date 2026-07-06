//+------------------------------------------------------------------+
//|                                                   RangeRatio.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 1
#property indicator_buffers 1
#property indicator_color1 Green

extern int Length=3;

double RangeRatio[];

int init()
  {
   IndicatorShortName("Range ratio oscillator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RangeRatio);
   SetLevelValue(1, 0.3);
   SetLevelValue(2, 0.5);
   SetLevelValue(3, 0.7);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos=Bars-2;
 if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
 int i;
 while(pos>=0)
 {
  double MinP=Low[ArrayMinimum(Low, Length, pos)];
  double MaxP=High[ArrayMaximum(High, Length, pos)];
  double sum=0;
  for (i=0;i<Length;i++)
  {
   sum+=High[pos+i]-Low[pos+i];
  }
  if (sum==0)
  {
   RangeRatio[pos]=0;
  }
  else
  {
   RangeRatio[pos]=(MaxP-MinP)/sum;
  }
  pos--;
 } 

 return(0);
}

