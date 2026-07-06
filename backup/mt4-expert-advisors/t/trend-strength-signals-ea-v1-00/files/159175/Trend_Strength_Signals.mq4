// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75915

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2025, Gehtsoft USA LLC  |
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

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 |
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2

#property indicator_label1  "Bullish Trend"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLime
#property indicator_width1  2

#property indicator_label2  "Bearish Trend"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_width2  2


extern int    inpPeriod      = 20;     // Period
extern double Multiplier  = 2.5;    // StdDev multipler
extern color  UpColor     = clrLime; // Arrow up color
extern color  DownColor   = clrRed;  // Arrow down color
extern double Offset      = 10;     // Arrow Distance

double ArrowUpBuffer[];
double ArrowDownBuffer[];
int    trendBuffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ArrowUpBuffer);
   SetIndexBuffer(1, ArrowDownBuffer);
   ArraySetAsSeries(ArrowUpBuffer, true);
   ArraySetAsSeries(ArrowDownBuffer, true);
   ArraySetAsSeries(trendBuffer, true);
   SetIndexArrow(0, 233);
   SetIndexArrow(1, 234);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
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
   ArrayResize(trendBuffer, rates_total);
   if(prev_calculated == 0)
      trendBuffer[rates_total - 1] = 0;
   for(int i = rates_total - 1; i >= 0; i--)
     {
      double basis = iMA(NULL, 0, inpPeriod, 0, MODE_SMA, PRICE_CLOSE, i);
      double stdev  = iStdDev(NULL, 0, inpPeriod, 0, MODE_SMA, PRICE_CLOSE, i);
      double upper  = basis + stdev;
      double lower  = basis - stdev;
      //
      int trend;
      if(close[i] > basis && close[i] > upper)
         trend = 1;
      else
         if(close[i] < basis && close[i] < lower)
            trend = -1;
         else
            trend = (i < rates_total - 1) ? trendBuffer[i + 1] : 0;
      trendBuffer[i] = trend;
      //
      ArrowUpBuffer[i]   = EMPTY_VALUE;
      ArrowDownBuffer[i] = EMPTY_VALUE;
      //
      if(i < rates_total - 1)
        {
         if(trendBuffer[i] > 0 && trendBuffer[i + 1] <= 0)
            ArrowUpBuffer[i] = low[i] - Offset * Point;
         else
            if(trendBuffer[i] < 0 && trendBuffer[i + 1] >= 0)
               ArrowDownBuffer[i] = high[i] + Offset * Point;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75915

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2025, Gehtsoft USA LLC  |
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

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 |
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |
//+------------------------------------------------------------------------------------------------+