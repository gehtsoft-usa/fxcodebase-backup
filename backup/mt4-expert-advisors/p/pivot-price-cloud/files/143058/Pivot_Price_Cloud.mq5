// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71390

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
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 1
#property indicator_width1 5
#property indicator_type1  DRAW_COLOR_HISTOGRAM2
#property indicator_color1 Green,Red

input int bars_limit = 1000; // Bars limit

//Pivot stream v1.0

// ABaseStream v1.1
#ifndef ABaseStream_IMP
#define ABaseStream_IMP
// IStream v.2.0
interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, double &val[]) = 0;

   virtual int Size() = 0;
};
class ABaseStream : public IStream
{
protected:
   int _references;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
public:
   ABaseStream(string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _references = 1;
   }

   ~ABaseStream()
   {
   }

   void SetShift(const double shift)
   {
      _shift = shift;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }
   
   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};
#endif

enum PivotStreamType
{
   PivotStreamP,
   PivotStreamS1,
   PivotStreamS2,
   PivotStreamS3,
   PivotStreamR1,
   PivotStreamR2,
   PivotStreamR3
};

class PivotStream : public ABaseStream
{
   ENUM_TIMEFRAMES _chartTimeframe;
   PivotStreamType _stream;
public:
   PivotStream(string symbol, ENUM_TIMEFRAMES timeframe, ENUM_TIMEFRAMES chartTimeframe, PivotStreamType stream)
      :ABaseStream(symbol, timeframe)
   {
      _chartTimeframe = chartTimeframe;
      _stream = stream;
   }

   bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         int btf_i = iBarShift(_symbol, _timeframe, iTime(NULL, _chartTimeframe, i + period));
         if (btf_i == -1)
         {
            return false;
         }
         double p, s1, s2, s3, r1, r2, r3;
         if (!CalcPivot(btf_i, p, s1, s2, s3, r1, r2, r3))
         {
            return false;
         }
         switch (_stream)
         {
            case PivotStreamP:
               val[i] = p;
               break;
            case PivotStreamS1:
               val[i] = s1;
               break;
            case PivotStreamS2:
               val[i] = s2;
               break;
            case PivotStreamS3:
               val[i] = s3;
               break;
            case PivotStreamR1:
               val[i] = r1;
               break;
            case PivotStreamR2:
               val[i] = r2;
               break;
            case PivotStreamR3:
               val[i] = r3;
               break;
         }
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
         case ERR_HISTORY_NOT_FOUND:
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

double outup[], outdn[], clr[];

PivotStream* pivot;

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("PPC");
   IndicatorSetString(INDICATOR_SHORTNAME, "Pivot Price Cloud");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, outup, INDICATOR_DATA);
   ++id;
   SetIndexBuffer(id, outdn, INDICATOR_DATA);
   ++id;
   SetIndexBuffer(id, clr, INDICATOR_COLOR_INDEX);
   ++id;
   pivot = new PivotStream(_Symbol, PERIOD_D1, (ENUM_TIMEFRAMES)_Period, PivotStreamP);
}

void OnDeinit(const int reason)
{
   pivot.Release();
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
      ArrayInitialize(outup, EMPTY_VALUE);
      ArrayInitialize(outdn, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double p[1];
      if (!pivot.GetValues(pos, 1, p))
      {
         continue;
      }
      outup[pos] = p[0];
      outdn[pos] = close[pos];
      clr[pos] = close[pos] > p[0] ? 0 : 1;
   }
   return rates_total;
}