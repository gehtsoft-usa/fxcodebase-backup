// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=68610


//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots 1
#property indicator_color1 Green
#property indicator_label1 "VSA"

input int Depth = 12; // Depth
input int Deviation = 5; // Deviation
input int Backstep = 3; // Backstep
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
double out[], up[], down[];
int zz;

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("vsav");
   IndicatorSetString(INDICATOR_SHORTNAME, "VSA Volumeter");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, out, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, up, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, down, INDICATOR_CALCULATIONS);
   ++id;
   zz = iCustom(_Symbol, _Period, "Examples\ZigZag", Depth, Deviation, Backstep);
}

void OnDeinit(const int reason)
{
   IndicatorRelease(zz);
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
      ArrayInitialize(out, EMPTY_VALUE);
      ArrayInitialize(up, EMPTY_VALUE);
      ArrayInitialize(down, EMPTY_VALUE);
   }
   int first = 1;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      bool isUp;
      double vol;
      int first;
      int second;
      if (GetZZ(rates_total, tick_volume, pos, isUp, vol, first, second))
      {
         if (isUp)
         {
            up[second] = up[second - 1] == EMPTY_VALUE ? tick_volume[second - 1] : up[second - 1] + tick_volume[second - 1];
            down[second] = down[second - 1];
         }
         else
         {
            down[second] = down[second - 1] == EMPTY_VALUE ? tick_volume[second - 1] : down[second - 1] + tick_volume[second - 1];
            up[second] = up[second - 1];
         }
         out[second] = up[second] / (up[second] + down[second]) * 100;
         for (int i = second + 1; i <= first; ++i)
         {
            if (isUp)
            {
               up[i] = up[i - 1] + tick_volume[i];
               down[i] = down[i - 1];
            }
            else
            {
               down[i] = down[i - 1] + tick_volume[i];
               up[i] = up[i - 1];
            }
            out[i] = up[i] / (up[i] - down[i]) * 100;
         }
      }
   }
   return rates_total;
}

bool GetZZ(const int rates_total, const long &volume[], const int period, bool &isUp, double &vol, int &first, int &second)
{
   first = -1;
   double firstZZ = 0;

   int i = period;
   long volumeVal = 0;
   while (i > 0)
   {
      double zigzag[1];
      if (CopyBuffer(zz, 0, rates_total - 1 - i, 1, zigzag) == 1 && zigzag[0] != 0.0)
      {
         if (first == -1)
         {
            firstZZ = zigzag[0];
            first = i;
         }
         else
         {
            second = i;
            isUp = firstZZ > zigzag[0];
            volumeVal += volume[i];
            vol = (double)volumeVal / (first - i);
            return true;
         }
      }
      if (first != -1)
      {
         volumeVal += volume[i];
      }
      --i;
   }
   return false;
}
