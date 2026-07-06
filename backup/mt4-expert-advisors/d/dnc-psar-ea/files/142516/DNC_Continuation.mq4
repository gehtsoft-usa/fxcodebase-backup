// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71273

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
#property indicator_label1  "Up"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  Green
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_label2  "Down"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  Red
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

input int n = 20; // Number of periods
input bool AC = true; // Analyze the current period

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

double UpTrend[], DownTrend[], dn[], du[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("dncc");
   IndicatorShortName("DNC Continuation");

   IndicatorBuffers(4);
   int id = 0;
   SetIndexBuffer(id, UpTrend);
   ++id;
   SetIndexBuffer(id, DownTrend);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, du);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, dn);
   ++id;

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
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
      ArrayInitialize(UpTrend, EMPTY_VALUE);
      ArrayInitialize(DownTrend, EMPTY_VALUE);
      ArrayInitialize(du, EMPTY_VALUE);
      ArrayInitialize(dn, EMPTY_VALUE);
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

   int toSkip = n;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      if (AC)
      {
         int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, n, pos);
         du[pos] = iHigh(_Symbol, _Period, highestIndex);
         int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, n, pos);
         dn[pos] = iLow(_Symbol, _Period, lowestIndex);
      }
		else
      {
			int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, n - 1, pos);
         du[pos] = iHigh(_Symbol, _Period, highestIndex);
         int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, n - 1, pos);
         dn[pos] = iLow(_Symbol, _Period, lowestIndex);
		}
		if (du[pos] > du[pos + 1])
   		UpTrend[pos] = 1;	
      else if (du[pos] < du[pos + 1])
	   	UpTrend[pos] = 0;	
		else
		   UpTrend[pos] = UpTrend[pos + 1];
		
		if (dn[pos] < dn[pos + 1])
		   DownTrend[pos] = -1;
		else if (dn[pos] > dn[pos + 1])
		   DownTrend[pos] = 0;	
		else
		   DownTrend[pos] = DownTrend[pos + 1];
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
