// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=146600#p146600

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_type1  DRAW_LINE
#property indicator_color1 Blue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_type2  DRAW_LINE
#property indicator_color2 Purple
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_type3  DRAW_LINE
#property indicator_color3 Purple
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_level1 0

enum PriceType {
  PriceClose    = PRICE_CLOSE,     // Close
  PriceOpen     = PRICE_OPEN,      // Open
  PriceHigh     = PRICE_HIGH,      // High
  PriceLow      = PRICE_LOW,       // Low
  PriceMedian   = PRICE_MEDIAN,    // Median
  PriceTypical  = PRICE_TYPICAL,   // Typical
  PriceWeighted = PRICE_WEIGHTED,  // Weighted
  PriceMedianBody,                 // Median (body)
  PriceAverage,                    // Average
  PriceTrendBiased,                // Trend biased
  PriceVolume,                     // Volume
};

input string    uPair      = "USDJPY";
input PriceType src        = PriceClose;  // Source
input int       smooth     = 1;           // Smoothing
input int       length     = 50;          // Lookback
input double    offset     = 0.85;        // ALMA Offset
input int       sigma      = 6;           // ALMA Sigma
input double    bmult      = 1;           // Band Multiplier
input bool      cblen      = false;       // Custom Band Length ? (Else same as Lookback)
input int       blen       = 20;          // Custom Band Length
input bool      highlight  = true;
input bool      fill       = true;
input bool      barcol     = false;   // Bar Color
input int       bars_limit = 100000;  // Bars limit
double          plot1[], plot2[], plot3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  //--- indicator buffers mapping
  IndicatorShortName("Trendilo | " + uPair);
  IndicatorBuffers(3);
  int id = 0;
  SetIndexBuffer(id++, plot1);
  SetIndexBuffer(id++, plot2);
  SetIndexBuffer(id++, plot3);
  //---
  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
  
	int i = rates_total - prev_calculated + 1;
  if (i >= rates_total) i = rates_total - 1;
  for (; i > 0; i--)
	{
    plot1[i] = iCustom(uPair, 0, "Trendilo.ex4", src, smooth, length, offset, sigma, bmult, cblen, blen, highlight, fill, barcol, bars_limit, 0,i);
    plot2[i] = iCustom(uPair, 0, "Trendilo.ex4", src, smooth, length, offset, sigma, bmult, cblen, blen, highlight, fill, barcol, bars_limit, 1,i);
    plot3[i] = iCustom(uPair, 0, "Trendilo.ex4", src, smooth, length, offset, sigma, bmult, cblen, blen, highlight, fill, barcol, bars_limit, 2,i);
  }
  return (rates_total);
}
//+------------------------------------------------------------------+