//+------------------------------------------------------------------+
//|                                                  Hurst_Bands.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 LightBlue
#property indicator_color3 LightBlue
#property indicator_color4 Gray
#property indicator_color5 Gray
#property indicator_color6 Yellow
#property indicator_color7 Yellow

#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID
#property indicator_style6 STYLE_SOLID
#property indicator_style7 STYLE_SOLID

extern int Length=10;
extern double Inner_Value=1.6;
extern double Outer_Value=2.6;
extern double Extreme_Value=4.2;
extern bool Show_Extreme_Bands=true;
extern bool Show_Outer_Bands=true;
extern bool Show_Inner_Bands=true;

double Center[], UExtreme[], LExtreme[], UOuter[], LOuter[], UInner[], LInner[];
int displacement;

int init()
{
 IndicatorShortName("Hurst Bands indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Center);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,UExtreme);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,LExtreme);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,UOuter);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,LOuter);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,UInner);
 SetIndexStyle(6,DRAW_LINE);
 SetIndexBuffer(6,LInner);
 
 displacement=Length/2.+1.;

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
 double Extreme_Band, Outer_Band, Inner_Band;
 pos=limit;
 while(pos>=0)
 {
  Center[pos]=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_MEDIAN, pos+displacement);
  
  Extreme_Band=Center[pos]*Extreme_Value/100.;
  Outer_Band=Center[pos]*Outer_Value/100.;
  Inner_Band=Center[pos]*Inner_Value/100.;
  
  UExtreme[pos]=Center[pos]+Extreme_Band;
  LExtreme[pos]=Center[pos]-Extreme_Band;
  UOuter[pos]=Center[pos]+Outer_Band;
  LOuter[pos]=Center[pos]-Outer_Band;
  UInner[pos]=Center[pos]+Inner_Band;
  LInner[pos]=Center[pos]-Inner_Band;
  
  pos--;
 } 
 return(0);
}

