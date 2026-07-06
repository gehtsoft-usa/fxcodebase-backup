//+------------------------------------------------------------------+
//|                                                         WRPC.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 5
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Blue

extern int CP=34;     // Channel Periods
extern int SP=14;     // Smoothing Period
extern double OB=70;  // Over Bought
extern double OS=30;  // Over sold
extern double UNZ=55; // Upper Neutral Zone
extern double LNZ=45; // Lower Neutral Zone
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double OverBought[], OverSold[], NeutralUp[], NeutralDown[], RSI[];

int init()
  {
   IndicatorShortName("Wilson relative price channel");
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,OverBought);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,OverSold);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,NeutralUp);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,NeutralDown);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,RSI);

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 double MA, MA0;
 if(Bars<=CP+SP) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int    limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars;
 int pos=limit;
 while(pos>=0)
 {
  RSI[pos]=iRSI(NULL, 0, CP, Price, pos);
  pos--;
 } 
 pos=limit;
 while(pos>=0)
 {
  MA=iMAOnArray(RSI, 0, SP, 0, MODE_EMA, pos);
  MA0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  OverBought[pos]=MA0*(1-(MA-OB)/100);
  OverSold[pos]=MA0*(1-(MA-OS)/100);
  NeutralUp[pos]=MA0*(1-(MA-UNZ)/100);
  NeutralDown[pos]=MA0*(1-(MA-LNZ)/100);
  pos--;
 } 
 return(0);
}

