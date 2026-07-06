// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71161

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
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Blue
#property indicator_color4 Yellow

input int Period = 30; // VP Period
input int SMOOTH = 3; // SMOOTH
input int VPNCRIT = 10; // VPNCRIT
input double Multiplier = 0.1; // Multiplier
input bool On1 = true; // Show This Slot 1
input ENUM_TIMEFRAMES TF1 = PERIOD_CURRENT; // Timeframe 1
input string Instrument1 = "EURUSD"; // Instrument 1

input bool On2 = true; // Show This Slot 2
input ENUM_TIMEFRAMES TF2 = PERIOD_CURRENT; // Timeframe 2
input string Instrument2 = "USDJPY"; // Instrument 2

input bool On3 = true; // Show This Slot 3
input ENUM_TIMEFRAMES TF3 = PERIOD_CURRENT; // Timeframe 3
input string Instrument3 = "GBPUSD"; // Instrument 3

input int bars_limit = 100000; // Bars limit

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
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

double osc[], line1[], line2[], line3[];
int init()
{
   double temp = iCustom(NULL, 0, "Multipair VPN", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Multipair VPN' indicator");
      return INIT_FAILED;
   }
   IndicatorObjPrefix = GenerateIndicatorPrefix("avpn");
   IndicatorShortName("Average VPN");

   IndicatorBuffers(4);

   int id = 0;
   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(id, osc);
   SetIndexLabel(id, "Oscillator");
   ++id;
   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(id, line1);
   SetIndexLabel(id, "Line 1");
   ++id;
   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(id, line2);
   SetIndexLabel(id, "Line 2");
   ++id;
   SetIndexStyle(id, DRAW_LINE, STYLE_SOLID);
   SetIndexBuffer(id, line3);
   SetIndexLabel(id, "Line 3");
   ++id;

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

double GetValue(datetime date, string symbol, ENUM_TIMEFRAMES tf, bool on)
{
   if (!on)
   {
      return EMPTY_VALUE;
   }
   int index = iBarShift(symbol, tf, date);
   if (index < 0)
   {
      return EMPTY_VALUE;
   }

   return iCustom(symbol, tf, "Multipair VPN", Period, SMOOTH, VPNCRIT, 30, Multiplier, 0, index);
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
      ArrayInitialize(line1, EMPTY_VALUE);
      ArrayInitialize(line2, EMPTY_VALUE);
      ArrayInitialize(line3, EMPTY_VALUE);
      ArrayInitialize(osc, EMPTY_VALUE);
   }
   bool timeSeries = ArrayGetAsSeries(time); 
   bool openSeries = ArrayGetAsSeries(open); 
   bool highSeries = ArrayGetAsSeries(high); 
   bool lowSeries = ArrayGetAsSeries(low); 
   bool closeSeries = ArrayGetAsSeries(close); 
   bool tickVolumeSeries = ArrayGetAsSeries(tick_volume); 
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   int toSkip = 0;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      line1[pos] = GetValue(time[pos], Instrument1, TF1, On1);
      line2[pos] = GetValue(time[pos], Instrument2, TF2, On2);
      line3[pos] = GetValue(time[pos], Instrument3, TF3, On3);
      double sum = 0;
      int count = 0;
      if (line1[pos] != EMPTY_VALUE)
      {
         sum += line1[pos];
         ++count;
      }
      if (line2[pos] != EMPTY_VALUE)
      {
         sum += line2[pos];
         ++count;
      }
      if (line3[pos] != EMPTY_VALUE)
      {
         sum += line3[pos];
         ++count;
      }
      if (count > 0)
      {
         osc[pos] = sum / count;
      }
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
