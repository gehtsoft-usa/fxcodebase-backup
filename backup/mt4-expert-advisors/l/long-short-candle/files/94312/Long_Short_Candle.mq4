//+------------------------------------------------------------------+
//|                                            Long_Short_Candle.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Yellow

extern int Length=10;
extern bool UseBody=true; // true - Body
                          // false - Wick
extern bool ReversalFilter=false;
extern bool ShowLongShort=true;
extern int ArrowSize=2;

double UpArrow[], DnArrow[], Long[], Short[];
double Raw[];

int init()
{
 IndicatorShortName("Long Short Candle");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(0,233);
 SetIndexBuffer(0,UpArrow);
 SetIndexStyle(1,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(1,234);
 SetIndexBuffer(1,DnArrow);
 SetIndexStyle(2,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(2,225);
 SetIndexBuffer(2,Long);
 SetIndexStyle(3,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(3,226);
 SetIndexBuffer(3,Short);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Raw);

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
  if (UseBody)
  {
   Raw[pos]=MathAbs(Close[pos]-Open[pos]);
  }
  else
  {
   Raw[pos]=High[pos]-Low[pos];
  }
  
  pos--;
 } 
 
 double Min, Max;
 pos=limit;
 while(pos>=0)
 {
  Min=Raw[ArrayMinimum(Raw, Length, pos+1)];
  Max=Raw[ArrayMaximum(Raw, Length, pos+1)];
  
  if (ReversalFilter && !((Open[pos]<Close[pos] && Open[pos+1]>Close[pos+1]) || (Open[pos]>Close[pos] && Open[pos+1]<Close[pos+1])))
  {
  
  }
  else
  {
   if (Raw[pos]>Max || Raw[pos]<Min)
   {
    if (Open[pos]<Close[pos])
    {
     UpArrow[pos]=Low[pos];
    }
    else
    {
     DnArrow[pos]=Low[pos];
    }
   }
   if (ShowLongShort)
   {
    if (Raw[pos]>Max)
    {
     Long[pos]=High[pos];
    }
    else
    {
     if (Raw[pos]<Min)
     {
      Short[pos]=High[pos];
     }
    }
   }
  }

  pos--;
 }
   
 return(0);
}

