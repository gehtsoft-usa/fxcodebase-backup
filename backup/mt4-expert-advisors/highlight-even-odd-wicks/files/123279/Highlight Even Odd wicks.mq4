// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67252

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
#property version   "1.2"
#property strict

#property indicator_chart_window

// params
extern int BarLimit = 1000; // Limit bars
extern color HighColor = Green; // High color
extern color LowColor = Red; // Low color
extern ENUM_TIMEFRAMES TF = PERIOD_CURRENT; // Timeframe

string IndicatorName;
string IndicatorObjPrefix;

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

int init()
{
   IndicatorName = GenerateIndicatorName("Highlight Even Odd wicks");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

datetime lastTime;
class HighCalc
{
   double _low;
   double _high;
   int _count;
   int _start;
   double _highestLow;
public:
   HighCalc()
   {
      _count = 0;
      _low = 0;
      _high = 0;
      _highestLow = 0;
   }
   
   void Reset()
   {
      _count = 0;
      _low = 0;
      _high = 0;
      _highestLow = 0;
   }

   bool Add(const int period)
   {
      if (_count == 0)
         return Init(period);
      if (MathMax(iOpen(_Symbol, TF, period), iClose(_Symbol, TF, period)) > _high)
      {
         if (_count % 2 == 1)
         {
            double high = iHigh(_Symbol, TF, iHighest(_Symbol, TF, MODE_HIGH, _start));
            if (high < _high)
            {
               datetime time = iTime(_Symbol, TF, period);
               ObjectCreate(IndicatorObjPrefix + TimeToStr(time), OBJ_RECTANGLE, 0, time, _high, D'2030.01.01 00:00', MathMax(high, _low));
               ObjectSetInteger(0, IndicatorObjPrefix + TimeToStr(time), OBJPROP_COLOR, _high > iClose(_Symbol, TF, 0) ? HighColor : LowColor);
            }
         }
         return false;
      }
      _count++;
      return true;
   }
private:
   bool Init(const int period)
   {
      double openCloseMax = MathMax(iOpen(_Symbol, TF, period), iClose(_Symbol, TF, period));
      if (_highestLow != 0.0 && _highestLow > openCloseMax)
      {
         _count = 0;
         return false;
      }
      _high = iHigh(_Symbol, TF, period);
      _low = openCloseMax;
      _count = 1;
      _start = period;
      if (_highestLow == 0.0 || _highestLow < _low)
         _highestLow = _low;
      return true;
   }
};

class LowCalc
{
   double _low;
   double _high;
   int _count;
   int _start;
   double _lowestHigh;
public:
   LowCalc()
   {
      _count = 0;
      _low = 0;
      _high = 0;
      _lowestHigh = 0;
   }

   void Reset()
   {
      _count = 0;
      _low = 0;
      _high = 0;
      _lowestHigh = 0;
   }

   bool Add(const int period)
   {
      if (_count == 0)
         return Init(period);
      if (MathMin(iOpen(_Symbol, TF, period), iClose(_Symbol, TF, period)) < _low)
      {
         if (_count % 2 == 1)
         {
            double low = iLow(_Symbol, TF, iLowest(_Symbol, TF, MODE_LOW, _start));
            if (low > _low)
            {
               datetime time = iTime(_Symbol, TF, period);
               ObjectCreate(IndicatorObjPrefix + TimeToStr(time), OBJ_RECTANGLE, 0, time, MathMin(low, _high), D'2030.01.01 00:00', _low);
               ObjectSetInteger(0, IndicatorObjPrefix + TimeToStr(time), OBJPROP_COLOR, _low > iClose(_Symbol, TF, 0) ? HighColor : LowColor);
            }
         }
         Init(period);
         return false;
      }
      _count++;
      return true;
   }
private:
   bool Init(const int period)
   {
      double openCloseMin = MathMin(iOpen(_Symbol, TF, period), iClose(_Symbol, TF, period));
      if (_lowestHigh != 0.0 && _lowestHigh < openCloseMin)
      {
         _count = 0;
         return false;
      }
      _low = iLow(_Symbol, TF, period);
      _high = openCloseMin;
      _count = 1;
      _start = period;
      if (_lowestHigh == 0.0 || _lowestHigh < _high)
         _lowestHigh = _high;
      return true;
   }
};

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   if (lastTime != iTime(_Symbol, TF, 0))
   {
      lastTime = iTime(_Symbol, TF, 0);
      ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   }
   int limit = iBars(_Symbol, TF) - 1;
   int pos = 1;
   HighCalc high;
   LowCalc low;
   while (pos < MathMin(limit, BarLimit))
   {
      int i = pos;
      high.Reset();
      while (high.Add(i) && i < limit)
      {
         ++i;
      }
      i = pos;
      low.Reset();
      while (low.Add(i) && i < limit)
      {
         ++i;
      }
      pos++;
   } 
   return 0;
}

