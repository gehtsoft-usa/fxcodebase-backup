// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69018

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_buffers 6
#property indicator_plots   6
#property indicator_separate_window

input int RSIPeriod1 = 14; // Fast RSI Period
input int RSIPeriod2 = 50; // Slow RSI Period
input int Level=50; // Signal Level
input int bar=0; // Bar
input color activeUp=clrRed; // OverBuy Color
input color activeDown=clrGreen; // OverSell Color
input color passive=clrGray; // No Signal Color
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TypeGraph
  {
   Histogram=0,// Full Histogram
   Cute=1,// Cute Histogram
  };
//--- input parameters
input TypeGraph TypeGr=Histogram; // Type graph
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT; // Timeframe

double rsi1[];
double rsi2[];
double delta[];
double UP[];
double Down[];
double Pass[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0,rsi1);
   SetIndexBuffer(1,rsi2);
   SetIndexBuffer(2,delta);
   SetIndexBuffer(3,UP);
   SetIndexBuffer(4,Down);
   SetIndexBuffer(5,Pass);
   IndicatorShortName("Delta RSI");
   SetIndexStyle(0,DRAW_NONE,STYLE_SOLID,1,clrYellow);
   SetIndexStyle(1,DRAW_NONE,STYLE_SOLID,1,clrOrange);
   if(TypeGr==1)
   {
      SetIndexStyle(2,DRAW_NONE,STYLE_SOLID,1,clrGray);
      SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID,2,activeUp);
      SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID,2,activeDown);
      SetIndexStyle(5,DRAW_HISTOGRAM,STYLE_SOLID,1,passive);
      IndicatorSetDouble(INDICATOR_MINIMUM,0);
      IndicatorSetDouble(INDICATOR_MAXIMUM,1);
   }
   else
   {
      SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1,clrGray);
      SetIndexStyle(3,DRAW_HISTOGRAM,STYLE_SOLID,2,activeUp);
      SetIndexStyle(4,DRAW_HISTOGRAM,STYLE_SOLID,2,activeDown);
      SetIndexStyle(5,DRAW_HISTOGRAM,STYLE_SOLID,1,passive);
   }
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---
   int limit;
   static bool alrt=false;
   static datetime altime=0;
   int maxLevel = 100-(100-Level);
   int minLevel = 100-Level;

//---
   if(rates_total<=1)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit=limit+1;

   for(int x=limit-1; x>=0; x--)
   {
      if (timeframe == PERIOD_CURRENT || timeframe == _Period)
      {
         rsi1[x] = iRSI(Symbol(), 0, RSIPeriod1, PRICE_CLOSE, x+bar);
         rsi2[x] = iRSI(Symbol(), 0, RSIPeriod2, PRICE_CLOSE, x+bar);
         delta[x] = rsi1[x]-rsi2[x];
         Pass[x] = TypeGr==1 ? 1 : delta[x];
         if(rsi2[x]>maxLevel && rsi1[x]>rsi2[x])
         {
            UP[x] = TypeGr==1 ? 1 : delta[x];
            Pass[x]=EMPTY_VALUE;
         }
         if(rsi2[x]<minLevel && rsi1[x]<rsi2[x])
         {
            Down[x] = TypeGr==1 ? 1 : delta[x];
            Pass[x]=EMPTY_VALUE;
         }
      }
      else
      {
         int index = iBarShift(_Symbol, timeframe, Time[x]);
         rsi1[x] = iRSI(Symbol(), 0, RSIPeriod1, PRICE_CLOSE, index + bar);
         rsi2[x] = iRSI(Symbol(), 0, RSIPeriod2, PRICE_CLOSE, index + bar);
         delta[x] = rsi1[x]-rsi2[x];
         Pass[x] = TypeGr==1 ? 1 : delta[x];
         if(rsi2[x]>maxLevel && rsi1[x]>rsi2[x])
         {
            UP[x] = TypeGr==1 ? 1 : delta[x];
            Pass[x]=EMPTY_VALUE;
         }
         if(rsi2[x]<minLevel && rsi1[x]<rsi2[x])
         {
            Down[x] = TypeGr==1 ? 1 : delta[x];
            Pass[x]=EMPTY_VALUE;
         }
      }
   }
   return(rates_total);
}
