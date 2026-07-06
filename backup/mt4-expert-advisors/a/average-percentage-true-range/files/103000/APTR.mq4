//+------------------------------------------------------------------+
//|                                                         APTR.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=14;

double APTR[];
double PTR[];

int init()
{
 IndicatorShortName("Average Percentage True Range");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,APTR);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,PTR);

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
 double S1, S2, S3;
 pos=limit;
 while(pos>=0)
 {
  S1=2.*(High[pos]-Low[pos])/(High[pos]+Low[pos]);
  S2=2.*(High[pos]-Close[pos+1])/(High[pos]+Close[pos+1]);
  S3=2.*(Low[pos]-Close[pos+1])/(3.*Low[pos]-Close[pos+1]);
  
  PTR[pos]=MathMax(S1, MathMax(S2, S3));

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  APTR[pos]=100.*iMAOnArray(PTR, 0, Length, 0, MODE_SMA, pos);

  pos--;
 }
   
 return(0);
}

