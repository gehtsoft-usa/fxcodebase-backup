//+------------------------------------------------------------------+
//|                              Reversal_Continuation_Indicator.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Fast_MA_Length=3;
extern int Middle_MA_Length=7;
extern int Slow_MA_Length=50;
extern int Method=0;      // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern bool Fast_Middle_Filter=true;
extern bool Middle_Slow_Filter=true;
extern bool Price_Filter=true;
extern string Type_Description="Type: 0 - Continuation, 1 - Reversal, 2 - Any";
extern int Type=1;

double UP[], DN[];

int init()
{
 IndicatorShortName("Reversal/Continuation indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,4);
 SetIndexArrow(0,119);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_ARROW,0,4);
 SetIndexArrow(1,119);
 SetIndexBuffer(1,DN);

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
 double M1, M2, M3;
 pos=limit;
 while(pos>=0)
 {
  UP[pos]=EMPTY_VALUE;
  DN[pos]=EMPTY_VALUE;
  
  if (Fast_Middle_Filter || Middle_Slow_Filter)
  {
   M1=iMA(NULL, 0, Fast_MA_Length, 0, Method, PRICE_CLOSE, pos);
   M2=iMA(NULL, 0, Middle_MA_Length, 0, Method, PRICE_CLOSE, pos);
   M3=iMA(NULL, 0, Slow_MA_Length, 0, Method, PRICE_CLOSE, pos);
   if ((M1>M2 || !Fast_Middle_Filter) && (M2>M3 || !Middle_Slow_Filter))
   {
    if (Price_Filter)
    {
     if (Close[pos]>Open[pos] && Type!=1)
     {
      UP[pos]=High[pos];
     }
     else
     {
      if (Close[pos]<Open[pos] && Type!=0)
      {
       DN[pos]=Low[pos];
      }
     }
    }
    else
    {
     UP[pos]=High[pos];
    }
   }
   else
   {
    if ((M1<M2 || !Fast_Middle_Filter) && (M2<M3 || !Middle_Slow_Filter))
    {
     if (Price_Filter)
     {
      if (Close[pos]<Open[pos] && Type!=1)
      {
       DN[pos]=Low[pos];
      }
      else
      {
       if (Close[pos]>Open[pos] && Type!=0)
       {
        UP[pos]=High[pos];
       }
      }
     }
     else
     {
      DN[pos]=Low[pos];
     }
    }
   }
  } 

  pos--;
 } 
 return(0);
}

