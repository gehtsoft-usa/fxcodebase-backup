// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70919


//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                 http://fxcodebase.com  |
//+------------------------------------------------------------------------+
//|                                      Support our efforts by donating   | 
//|                                         Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------+
//|                                           Developed by : Mario Jemic   |                    
//|                                               mario.jemic@gmail.com    |
//|                                https://AppliedMachineLearning.systems  |
//|                                     Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |  
//|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
//|Binance MEMO (BEP2 only)   : 107152697                                  |   
//|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |  
//+------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots 1
#property indicator_color1 Green

#property indicator_level1 0
      
#property indicator_levelcolor Red
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT
 
#property indicator_label1 "Volume Accumulation Oscillator" 
 
double VAO[];
double Median[]; 

input int bars_limit = 1000; // Bars limit

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

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("Volume Accumulation Oscillator");
   IndicatorSetString(INDICATOR_SHORTNAME, "Volume Accumulation Oscillator");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, VAO, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;

   SetIndexBuffer(id++, Median, INDICATOR_CALCULATIONS);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
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
      ArrayInitialize(VAO, EMPTY_VALUE);
      ArrayInitialize(Median, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      Median[pos] = (close[pos] - ((high[pos] + low[pos]) / 2)) * tick_volume[pos];
      VAO[pos] = Calculate(pos, rates_total); 
   }
   return rates_total;
}
double Calculate(int pos, int rates_total)
{
   double Sum = 0;
   int limit = 0;
   for(int i = pos; i >= rates_total - 1 - bars_limit; i--)  
   {
      Sum= Sum + Median[i];
   }

   return (Sum);
}

