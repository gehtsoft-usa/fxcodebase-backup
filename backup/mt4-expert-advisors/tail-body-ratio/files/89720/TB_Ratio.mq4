//+------------------------------------------------------------------+
//|                                                     TB_Ratio.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

extern double Multiplier=1;
extern int Mode=0; // 0 - Tail/Body, 1 - Tail/Candle

double U[], D[];

int init()
{
 IndicatorShortName("Tail/Body ratio");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,4);
 SetIndexBuffer(0,U);
 SetIndexArrow(0,119);
 SetIndexStyle(1,DRAW_ARROW,0,4);
 SetIndexBuffer(1,D);
 SetIndexArrow(1,119);

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
 double Bar, Up, Down;
 pos=limit;
 while(pos>=0)
 {
  Bar=MathAbs(Open[pos]-Close[pos]);
  Up=High[pos]-MathMax(Open[pos], Close[pos]);
  Down=MathMin(Open[pos], Close[pos])-Low[pos];
  
  U[pos]=EMPTY_VALUE;
  D[pos]=EMPTY_VALUE;
  
  if (Mode==0)
  {
   if (Bar*Multiplier<Up)
   {
    U[pos]=High[pos];
   }
   if (Bar*Multiplier<Down)
   {
    D[pos]=Low[pos];
   }
  }
  else
  {
   if ((Bar+Down)*Multiplier<Up)
   {
    U[pos]=High[pos];
   }
   if ((Bar+Up)*Multiplier<Down)
   {
    D[pos]=Low[pos];
   }
  }
  
  pos--;
 } 
 return(0);
}

