// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71421


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
#property version "1.0"

#property strict

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots 1
#property indicator_label1 "Wave Volume"
#property indicator_type1 DRAW_HISTOGRAM
#property indicator_color1 Blue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

enum PriceSource
{
   PSClose, // Close
   PSOpenClose, // Open / Close
   PSHighLow // High / Low
};

enum UseTR
{
   UTRAlways, // Always
   UTRAuto, // Auto
   UTRNever //Never
};

enum Method
{
   MethATR, // ATR
   MethTraditional, // Traditional
   MethPartOfProce // Part of Price
};

input string method = MethATR; // Renko Assignment Method
input double methodvalue = 14; // Value
input PriceSource pricesource = PSClose; // Price Source
input UseTR useTrueRange = UTRAuto; // Use True Range instead of Volume
input bool isOscillating = false; // Oscillating
input bool normalize = false; // Normalize
input int bars_limit = 1000; // Bars limit
double plot1[];
double currclose[], direction[], barcount[], vol[];

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

int atr = 0;
void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("WWV");
   IndicatorSetString(INDICATOR_SHORTNAME, "Weis Wave Volume");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   SetIndexBuffer(0, plot1, INDICATOR_DATA);
   SetIndexBuffer(1, currclose, INDICATOR_CALCULATIONS);
   SetIndexBuffer(2, direction, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, barcount, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, vol, INDICATOR_CALCULATIONS);
   if (method == MethATR)
   {
      atr = iATR(_Symbol, _Period, round(methodvalue));
   }
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   if (atr != 0)
   {
      IndicatorRelease(atr);
   }
}



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
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(currclose, EMPTY_VALUE);
      ArrayInitialize(direction, EMPTY_VALUE);
      ArrayInitialize(barcount, EMPTY_VALUE);
      ArrayInitialize(vol, EMPTY_VALUE);
   }
   int first = 1;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;

      bool useClose = (pricesource == PSClose);
      bool useOpenClose = ((pricesource == PSOpenClose) || useClose);
      double hl = MathAbs(high[pos] - low[pos]);
      double hc = MathAbs(high[pos] - close[pos - 1]);
      double lc = MathAbs(low[pos] - close[pos - 1]);

      double tr = hl;
      if (tr < hc)
         tr = hc;
      if (tr < lc)
         tr = lc;
      vol[pos] = (((useTrueRange == UTRAlways) || ((useTrueRange == UTRAuto) && (tick_volume[pos]) == EMPTY_VALUE)) ? tr : tick_volume[pos]);
      double op = (useClose ? close[pos] : open[pos]);
      double hi = (useOpenClose ? ((close[pos] >= op) ? close[pos] : op) : high[pos]);
      double lo = (useOpenClose ? ((close[pos] <= op) ? close[pos] : op) : low[pos]);

      double methodvalue_ = methodvalue;
      if (method == MethATR)
      {
         double buffer[1];
         if (CopyBuffer(atr, 0, oldPos, 1, buffer) != 1)
         {
            continue;
         }
         methodvalue_ = buffer[0];
      }
      if (method == MethPartOfProce)
      {
         methodvalue_ = close[pos] / methodvalue;
      }
         
      currclose[pos] = (double)(EMPTY_VALUE);
      double prevclose = (currclose[pos - 1] == EMPTY_VALUE) ? 0 : currclose[pos - 1];
      double prevhigh = prevclose + methodvalue_;
      double prevlow = prevclose - methodvalue_;
      currclose[pos] = ((hi > prevhigh) ? hi : ((lo < prevlow) ? lo : prevclose));
      direction[pos] = ((currclose[pos] > prevclose) ? 1 : ((currclose[pos] < prevclose) ? (-1) : (direction[pos - 1] == EMPTY_VALUE) ? 0 : direction[pos - 1]));
      bool directionHasChanged = (direction[pos] != direction[pos - 1]);
      bool directionIsUp = (direction[pos] > 0);
      bool directionIsDown = (direction[pos] < 0);
      barcount[pos] = 1;
      barcount[pos] = ((!directionHasChanged && normalize) ? barcount[pos - 1] + barcount[pos] : barcount[pos]);
      vol[pos] = (!directionHasChanged ? vol[pos - 1] + vol[pos] : vol[pos]);
      double res = ((barcount[pos] > 1) ? vol[pos] / barcount[pos] : vol[pos]);
      plot1[pos] = ((isOscillating && directionIsDown) ? (-res) : res);
   }
   return rates_total;
}
