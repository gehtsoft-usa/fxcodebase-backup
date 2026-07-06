//+------------------------------------------------------------------+
//|                                                           AB.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Red

extern int Length=20;
extern double Factor=0.001;

double Top[], Bottom[];
double Up[], Dn[];

int init()
{
 IndicatorShortName("Acceleration Bands");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Top);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Bottom);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Up);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Dn);

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
  Up[pos]=High[pos]*(1.+2.*(2000.*Factor*(High[pos]-Low[pos])/(High[pos]+Low[pos])));
  Dn[pos]=High[pos]*(1.-2.*(2000.*Factor*(High[pos]-Low[pos])/(High[pos]+Low[pos])));

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Top[pos]=iMAOnArray(Up, 0, Length, 0, MODE_SMA, pos);
  Bottom[pos]=iMAOnArray(Dn, 0, Length, 0, MODE_SMA, pos);

  pos--;
 }
   
 return(0);
}

