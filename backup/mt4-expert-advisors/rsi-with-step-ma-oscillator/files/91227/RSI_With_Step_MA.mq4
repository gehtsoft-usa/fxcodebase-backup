//+------------------------------------------------------------------+
//|                                             RSI_With_Step_MA.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int RSI_Length=14;
extern int Step=5;
extern int MA_Length=6;
extern int Method=0;     // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
                      
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double RSI[];
double P[], N[];

int init()
{
 IndicatorShortName("RSI with step MA oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,RSI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,P);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,N);
 
 SetLevelValue(0, 0);
 SetLevelValue(1, 30);
 SetLevelValue(2, 50);
 SetLevelValue(3, 70);
 SetLevelValue(4, 100);
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
 int limit=Bars-RSI_Length-Step-1;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 int i;
 double sump;
 double sumn;
 double positive;
 double negative;
 double diff;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-RSI_Length-Step-1)
  {
   sump=0;
   sumn=0;
   for (i=pos+RSI_Length-1;i>=pos;i--)
   {
    diff=iMA(NULL, 0, MA_Length, 0, Method, Price, i)-iMA(NULL, 0, MA_Length, 0, Method, Price, i+Step);
    if (diff>=0)
    {
     sump=sump+diff;
    }
    else
    {
     sumn=sumn-diff;
    }
   }
   positive=sump/RSI_Length;
   negative=sumn/RSI_Length;
  }
  else
  {
   diff=iMA(NULL, 0, MA_Length, 0, Method, Price, pos)-iMA(NULL, 0, MA_Length, 0, Method, Price, pos+Step);
   if (diff>=0)
   {
    sump=diff;
   }
   else
   {
    sumn=-diff;
   }
   positive=(P[pos+1]*(RSI_Length-1)+sump)/RSI_Length;
   negative=(N[pos+1]*(RSI_Length-1)+sumn)/RSI_Length;
  }
  P[pos]=positive;
  N[pos]=negative;
  if (negative==0)
  {
   RSI[pos]=0;
  }
  else
  {
   RSI[pos]=100.-(100./(1.+positive/negative));
  }
  
  pos--;
 } 
 return(0);
}

