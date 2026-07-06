// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71220


//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

#property  indicator_separate_window
#property  indicator_buffers 4
#property  indicator_color1   Lime
#property  indicator_color2   Red
#property  indicator_color3   SlateGray
#property  indicator_color4   Magenta

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 1

#property indicator_level1  0
#property indicator_levelcolor Silver

extern int fast_ema_period=12;
extern int slow_ema_period=26;
extern int signal_period=9;

double UpBuffer[];
double DownBuffer[];
double ZeroBuffer[];
double SigMABuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexStyle(3,DRAW_LINE);

   SetIndexBuffer(0,UpBuffer);
   SetIndexBuffer(1,DownBuffer);
   SetIndexBuffer(2,ZeroBuffer);
   SetIndexBuffer(3,SigMABuffer);

   SetIndexDrawBegin(0,0);

   IndicatorShortName("MACD ("+IntegerToString (fast_ema_period)+", "+IntegerToString (slow_ema_period)+", "+IntegerToString (signal_period)+") ");

   IndicatorDigits ((int)MarketInfo(Symbol(),MODE_DIGITS)+2);

   SetIndexLabel(0,"UpBuffer");
   SetIndexLabel(1,"DownBuffer");
   SetIndexLabel(2,"ZeroBuffer");
   SetIndexLabel(3,"SigMABuffer");

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

   double myMACDmain,myMACDsignal;
   int limit,i;

   if(prev_calculated>0)

      limit=rates_total-prev_calculated;
   else
      limit=rates_total;

   for(i=0; i<limit; i++)
     {
      myMACDmain=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_CLOSE,MODE_MAIN,i);
      myMACDsignal=iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,PRICE_CLOSE,MODE_SIGNAL,i);

      SigMABuffer[i]=myMACDsignal;

      if((myMACDmain>0) && (myMACDmain>myMACDsignal))
        {
         UpBuffer[i]=myMACDmain;
        }
      else
        {
         if((myMACDmain<0) && (myMACDmain<myMACDsignal))
           {
            DownBuffer[i]=myMACDmain;
           }
         else
           {
            ZeroBuffer[i]=myMACDmain;
           }
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
