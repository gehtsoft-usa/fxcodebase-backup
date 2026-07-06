//+------------------------------------------------------------------+
//|                                                          TDI.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Blue

extern int Length=20;
extern bool JustSignal=false;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double TDI[], Direction[], Signal[];
double MomBuffer[], MomAbsBuffer[];

int init()
{
 IndicatorShortName("Trend detection index");
 IndicatorDigits(Digits);
 SetIndexBuffer(0,TDI);
 SetIndexBuffer(1,Direction);
 SetIndexBuffer(2,Signal);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,MomBuffer);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,MomAbsBuffer);
 
 if (JustSignal)
 {
  SetIndexStyle(0,DRAW_NONE);
  SetIndexStyle(1,DRAW_NONE);
  SetIndexStyle(2,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(0,DRAW_LINE);
  SetIndexStyle(1,DRAW_LINE);
  SetIndexStyle(2,DRAW_NONE);
 }

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
 pos=limit;
 while(pos>=0)
 {
  MomBuffer[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos)-iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+Length);
  MomAbsBuffer[pos]=MathAbs(MomBuffer[pos]);
  pos--;
 } 
 
 pos=limit;
 double F, H, G;
 while(pos>=0)
 {
  Direction[pos]=iMAOnArray(MomBuffer, 0, Length, 0, MODE_SMA, pos)*Length;
  F=MathAbs(Direction[pos]);
  H=iMAOnArray(MomAbsBuffer, 0, Length, 0, MODE_SMA, pos)*Length;
  G=iMAOnArray(MomAbsBuffer, 0, 2*Length, 0, MODE_SMA, pos)*2*Length;
  TDI[pos]=F+H-G;
  if (TDI[pos]>0)
  {
   if (Direction[pos]>0)
   {
    Signal[pos]=0.1;
   }
   else
   {
    Signal[pos]=-0.1;
   }
  }
  else
  {
   Signal[pos]=Signal[pos+1];
  }
  pos--;
 } 

 return(0);
}

