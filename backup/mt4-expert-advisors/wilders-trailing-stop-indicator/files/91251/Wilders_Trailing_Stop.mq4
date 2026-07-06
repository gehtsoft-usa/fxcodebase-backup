//+------------------------------------------------------------------+
//|                                        Wilders_Trailing_Stop.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=5;
extern double Coeff=3.5;

double WTS[], WTSDn[];

int init()
{
 IndicatorShortName("Wilders Trailing Stop indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,WTS);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,WTSDn);

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
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double loss;
 pos=limit;
 while(pos>=0)
 {
  loss=iATR(NULL, 0, Length, pos)*Coeff;
  if (Close[pos]>WTS[pos+1] && Close[pos+1]>WTS[pos+1])
  {
   WTS[pos]=MathMax(WTS[pos+1], Close[pos]-loss);
   WTSDn[pos]=WTS[pos];
   WTSDn[pos+1]=WTS[pos+1];
  }
  else
  {
   if (Close[pos]<WTS[pos+1] && Close[pos+1]<WTS[pos+1])
   {
    WTS[pos]=MathMin(WTS[pos+1], Close[pos]+loss);
   }
   else
   {
    if (Close[pos]>WTS[pos+1])
    {
     WTS[pos]=Close[pos]-loss;
     WTSDn[pos]=WTS[pos];
     WTSDn[pos+1]=WTS[pos+1];
    }
    else
    {
     WTS[pos]=Close[pos]+loss;
    }
   }
  }
  pos--;
 } 
 return(0);
}

