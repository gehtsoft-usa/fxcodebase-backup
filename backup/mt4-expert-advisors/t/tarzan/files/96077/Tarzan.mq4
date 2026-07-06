//+------------------------------------------------------------------+
//|                                                       Tarzan.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 Yellow
#property indicator_color5 Yellow

extern int RSI_Length=5;
extern int MA_Length=50;
extern int MA_Method=0;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
extern int Koridor=20;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int Symbol_Size=2;                       


double RSI[], MA_Up[], MA_Dn[], Top[], Bottom[];

int init()
{
 IndicatorShortName("Tarzan");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,RSI);
 SetIndexBuffer(1,MA_Up);
 SetIndexStyle(1,DRAW_ARROW,0,Symbol_Size);
 SetIndexArrow(1,119);
 SetIndexBuffer(2,MA_Dn);
 SetIndexStyle(2,DRAW_ARROW,0,Symbol_Size);
 SetIndexArrow(2,119);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,Top);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,Bottom);

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
 double MA;
 pos=limit;
 while(pos>=0)
 {
  RSI[pos]=iRSI(NULL, 0, RSI_Length, Price, pos);
  
  pos--;
 }
  
 pos=limit;
 while(pos>=0)
 {
  MA=iMAOnArray(RSI, 0, MA_Length, 0, MA_Method, pos);
  Top[pos]=MA+Koridor;
  Bottom[pos]=MA-Koridor;
  if (RSI[pos]>MA)
  {
   MA_Up[pos]=MA;
   MA_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   MA_Up[pos]=EMPTY_VALUE;
   MA_Dn[pos]=MA;
  }

  pos--;
 } 
 return(0);
}

