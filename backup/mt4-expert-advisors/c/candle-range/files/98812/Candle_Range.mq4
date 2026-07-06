//+------------------------------------------------------------------+
//|                                                 Candle_Range.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern double Level=50.;
extern bool Invert_Indicator=false;
extern int Dot_Size=1;

double CR[];

int init()
{
 IndicatorShortName("Candle Range indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,Dot_Size);
 SetIndexArrow(0,108);
 SetIndexBuffer(0,CR);

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
 double Range;
 pos=limit;
 while(pos>=0)
 {
  if (High[pos]-Low[pos]!=0.)
  {
   Range=100.*MathAbs(Open[pos]-Close[pos])/(High[pos]-Low[pos]);
   if ((!Invert_Indicator && Range<Level) || (Invert_Indicator && Range>=Level))
   {
    CR[pos]=(Open[pos]+Close[pos])/2.;
   }
   else
   {
    CR[pos]=EMPTY_VALUE;
   }
  } 

  pos--;
 } 
 return(0);
}

