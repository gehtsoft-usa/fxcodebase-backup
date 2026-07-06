//+------------------------------------------------------------------+
//|                                                  RSI_OnChart.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Yellow

extern int RSI_Period=14;
extern int RSI_Price=0;    // Applied price
                           // 0 - Close
                           // 1 - Open
                           // 2 - High
                           // 3 - Low
                           // 4 - Median
                           // 5 - Typical
                           // 6 - Weighted  
extern int MA_Period=20;
extern int MA_Method=0;
extern int MA_Price=0;     // Applied price
                           // 0 - Close
                           // 1 - Open
                           // 2 - High
                           // 3 - Low
                           // 4 - Median
                           // 5 - Typical
                           // 6 - Weighted  
extern int OverBought=70;
extern int OverSold=30;
extern double ATR_Coeff=5;                           

double Upper[], Lower[], Middle[], RSI[];

int init()
  {
   IndicatorShortName("RSI on chart");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Middle);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Upper);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Lower);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,RSI);

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
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 double ATR;
 while(pos>=0)
 {
  ATR=iATR(NULL, 0, MA_Period, pos);
  Middle[pos]=iMA(NULL, 0, MA_Period, 0, MA_Method, MA_Price, pos);
  Upper[pos]=Middle[pos]+ATR*ATR_Coeff*(OverBought-50)/100;
  Lower[pos]=Middle[pos]-ATR*ATR_Coeff*(50-OverSold)/100;
  RSI[pos]=Middle[pos]+ATR*ATR_Coeff*(iRSI(NULL, 0, RSI_Period, RSI_Price, pos)-50)/100;
  pos--;
 } 
 return(0);
}

