//+------------------------------------------------------------------+
//|                                             Position_Of_Open.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern double MinPos=75; // Min. position, from Low to High, %
extern double MaxPos=100; // Max. position, from Low to High, %

double Buff[];
double MinPosAbs, MaxPosAbs;

int init()
{
 IndicatorShortName("Position of Open");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,4);
 SetIndexArrow(0,242);
 SetIndexBuffer(0,Buff);

 MinPosAbs=MinPos/100.;
 MaxPosAbs=MaxPos/100.;
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
 double Range, MinPrice, MaxPrice;
 pos=limit;
 while(pos>=0)
 {
  Range=High[pos]-Low[pos];
  MinPrice=Low[pos]+Range*MinPosAbs;
  MaxPrice=Low[pos]+Range*MaxPosAbs;
  
  if (Open[pos]>=MinPrice && Open[pos]<=MaxPrice)
  {
   Buff[pos]=High[pos];
  }
  
  pos--;
 } 
 return(0);
}

