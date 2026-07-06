// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69332

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                         https://AppliedMachineLearning.systems   |
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

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

string IndicatorName;
string IndicatorObjPrefix;

input ENUM_TIMEFRAMES tf1 = PERIOD_H1; // Timeframe 1
input ENUM_TIMEFRAMES tf2 = PERIOD_D1; // Timeframe 2

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

double p1[], p2[];

class Pivot
{
   ENUM_TIMEFRAMES _timeframe;
   ENUM_TIMEFRAMES _chartTimeframe;
   string _symbol;
public:
   Pivot(string symbol, ENUM_TIMEFRAMES timeframe, ENUM_TIMEFRAMES chartTimeframe)
   {
      _chartTimeframe = chartTimeframe;
      _symbol = symbol;
      _timeframe = timeframe;
   }

   bool Get(const int i, double &p, double &s1, double &s2, double &s3, double &r1, double &r2, double &r3)
   {
      int btf_i = i == 0 ? 0 : iBarShift(_symbol, _timeframe, iTime(NULL, _chartTimeframe, i));
      if (btf_i == -1)
      {
         return false;
      }
      if (!CalcPivot(btf_i, p, s1, s2, s3, r1, r2, r3))
      {
         return false;
      }
      return true;
   }
private:
   bool CalcPivot(const int i, double &p, 
      double &s1, double &s2, double &s3,
      double &r1, double &r2, double &r3)
   {
      ResetLastError();
      double high  = iHigh(_symbol, _timeframe, i+1);
      int error = GetLastError();
      switch (error)
      {
         case ERR_HISTORY_WILL_UPDATED:
         case ERR_NO_HISTORY_DATA:
            {
               static bool ERR_HISTORY_NOT_FOUND_printed = false;
               if (!ERR_HISTORY_NOT_FOUND_printed)
               {
                  Print("No history");
                  ERR_HISTORY_NOT_FOUND_printed = true;
               }
            }
            return false;
      }
      double low   = iLow(_symbol, _timeframe, i+1);
      double open  = iOpen(_symbol, _timeframe, i+1);
      double close = iClose(_symbol, _timeframe, i+1);
      p = (high + low + close) / 3;
      r1 = (2 * p) - low;
      s1 = (2 * p) - high;
      r2 = p + (high - low);
      s2 = p - (high - low);
      r3 = p + (high - low) * 2;
      s3 = p - (high - low) * 2;
      return true;
   }
};

Pivot* pivot1;
Pivot* pivot2;

int init()
{
   IndicatorName = GenerateIndicatorName("Pivot cloud");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(2);
   pivot1 = new Pivot(_Symbol, tf1, (ENUM_TIMEFRAMES)_Period);
   pivot2 = new Pivot(_Symbol, tf2, (ENUM_TIMEFRAMES)_Period);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, p1);
   SetIndexLabel(0, "Pivot 1");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, p2);
   SetIndexLabel(1, "Pivot 2");

   return 0;
}

int deinit()
{
   delete pivot1;
   delete pivot2;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = MathMin(Bars - 1 - 0, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; i--)
   {
      double p, s1, s2, s3, r1, r2, r3;
      if (pivot1.Get(i, p, s1, s2, s3, r1, r2, r3))
      {
         p1[i] = p;
      }
      if (pivot2.Get(i, p, s1, s2, s3, r1, r2, r3))
      {
         p2[i] = p;
      }
   }
   return 0;
}
