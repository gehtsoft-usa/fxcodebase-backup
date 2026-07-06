//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73975

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property strict
#property indicator_chart_window
#property indicator_buffers 4

input int prd = 10; // Loopback Period
input int conslen = 5; // Min Consolidation Length
input bool paintcons = true; // Paint Consolidation Area 
input color zonecol = Blue; // Zone Color
input int bars_limit = 100000; // Bars limit
double zz[];
string CreateLineObject(string id, datetime x1, double y1, datetime x2, double y2, color clr, bool extend, datetime dateId)
{
   ResetLastError();
   string lineId = IndicatorObjPrefix + id + "_" 
      + IntegerToString(TimeDay(dateId)) + "_"
      + IntegerToString(TimeMonth(dateId)) + "_"
      + IntegerToString(TimeYear(dateId)) + "_"
      + IntegerToString(TimeHour(dateId)) + "_"
      + IntegerToString(TimeMinute(dateId)) + "_"
      + IntegerToString(TimeSeconds(dateId));
   
   if (ObjectFind(0, lineId) == -1 && ObjectCreate(0, lineId, OBJ_TREND, 0, x1, y1, x2, y2))
   {
      ObjectSetInteger(0, lineId, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, lineId, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, lineId, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, lineId, OBJPROP_RAY_RIGHT, extend);
   }
   ObjectSetDouble(0, lineId, OBJPROP_PRICE1, y1);
   ObjectSetDouble(0, lineId, OBJPROP_PRICE2, y2);
   ObjectSetInteger(0, lineId, OBJPROP_TIME1, x1);
   ObjectSetInteger(0, lineId, OBJPROP_TIME2, x2);
   return lineId;
}

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

// Stream v.3.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

//AOnStream v1.0

class AOnStream : public IStream
{
protected:
   IStream *_source;
   int _references;
public:
   AOnStream(IStream *source)
   {
      _references = 1;
      _source = source;
      _source.AddRef();
   }

   ~AOnStream()
   {
      _source.Release();
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

   virtual int Size()
   {
      return _source.Size();
   }
};
// Simple price stream v1.0

// Instrument info v.1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef InstrumentInfo_IMP
#define InstrumentInfo_IMP

class InstrumentInfo
{
   string _symbol;
   double _mult;
   double _point;
   double _pipSize;
   int _digits;
   double _tickSize;
public:
   InstrumentInfo(const string symbol)
   {
      _symbol = symbol;
      _point = MarketInfo(symbol, MODE_POINT);
      _digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      _mult = _digits == 3 || _digits == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
   }

   // Return < 0 when lot1 < lot2, > 0 when lot1 > lot2 and 0 owtherwise
   int CompareLots(double lot1, double lot2)
   {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
      {
         return lot1 < lot2 ? -1 : (lot1 > lot2 ? 1 : 0);
      }
      int lotSteps1 = (int)floor(lot1 / lotStep + 0.5);
      int lotSteps2 = (int)floor(lot2 / lotStep + 0.5);
      int res = lotSteps1 - lotSteps2;
      return res;
   }
   
   static double GetBid(const string symbol) { return MarketInfo(symbol, MODE_BID); }
   double GetBid() { return GetBid(_symbol); }
   static double GetAsk(const string symbol) { return MarketInfo(symbol, MODE_ASK); }
   double GetAsk() { return GetAsk(_symbol); }
   static double GetPipSize(const string symbol)
   { 
      double point = MarketInfo(symbol, MODE_POINT);
      double digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      double mult = digits == 3 || digits == 5 ? 10 : 1;
      return point * mult;
   }
   double GetPipSize() { return _pipSize; }
   double GetPointSize() { return _point; }
   string GetSymbol() { return _symbol; }
   double GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }
   int GetDigits() { return _digits; }
   double GetTickSize() { return _tickSize; }
   double GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

   double AddPips(const double rate, const double pips)
   {
      return RoundRate(rate + pips * _pipSize);
   }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathFloor(rate / _tickSize + 0.5) * _tickSize, _digits);
   }

   double RoundLots(const double lots)
   {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
      {
         return 0.0;
      }
      return floor(lots / lotStep) * lotStep;
   }

   double LimitLots(const double lots)
   {
      double minVolume = GetMinLots();
      if (minVolume > lots)
      {
         return 0.0;
      }
      double maxVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
      {
         return maxVolume;
      }
      return lots;
   }

   double NormalizeLots(const double lots)
   {
      return LimitLots(RoundLots(lots));
   }
};

#endif

// Abstract stream v1.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP

class AStream : public IStream
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
   InstrumentInfo *_instrument;
   int _references;

   AStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _references = 1;
      _shift = 0.0;
      _symbol = symbol;
      _timeframe = timeframe;
      _instrument = new InstrumentInfo(_symbol);
   }

   ~AStream()
   {
      delete _instrument;
   }
public:
   void SetShift(const double shift)
   {
      _shift = shift;
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

   int Size()
   {
      return iBars(_symbol, _timeframe);
   }
};
#define AStream_IMP
#endif
enum PriceType
{
   PriceClose = PRICE_CLOSE, // Close
   PriceOpen = PRICE_OPEN, // Open
   PriceHigh = PRICE_HIGH, // High
   PriceLow = PRICE_LOW, // Low
   PriceMedian = PRICE_MEDIAN, // Median
   PriceTypical = PRICE_TYPICAL, // Typical
   PriceWeighted = PRICE_WEIGHTED, // Weighted
   PriceMedianBody, // Median (body)
   PriceAverage, // Average
   PriceTrendBiased, // Trend biased
   PriceVolume, // Volume
};

class SimplePriceStream : public AStream
{
   PriceType _price;
public:
   SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
      :AStream(symbol, timeframe)
   {
      _price = __price;
   }

   bool GetValue(const int period, double &val)
   {
      switch (_price)
      {
         case PriceClose:
            val = iClose(_symbol, _timeframe, period);
            break;
         case PriceOpen:
            val = iOpen(_symbol, _timeframe, period);
            break;
         case PriceHigh:
            val = iHigh(_symbol, _timeframe, period);
            break;
         case PriceLow:
            val = iLow(_symbol, _timeframe, period);
            break;
         case PriceMedian:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period)) / 2.0;
            break;
         case PriceTypical:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 3.0;
            break;
         case PriceWeighted:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) * 2) / 4.0;
            break;
         case PriceMedianBody:
            val = (iOpen(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 2.0;
            break;
         case PriceAverage:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) + iOpen(_symbol, _timeframe, period)) / 4.0;
            break;
         case PriceTrendBiased:
            {
               double close = iClose(_symbol, _timeframe, period);
               if (iOpen(_symbol, _timeframe, period) > iClose(_symbol, _timeframe, period))
                  val = (iHigh(_symbol, _timeframe, period) + close) / 2.0;
               else
                  val = (iLow(_symbol, _timeframe, period) + close) / 2.0;
            }
            break;
         case PriceVolume:
            val = (double)iVolume(_symbol, _timeframe, period);
            break;
      }
      val += _shift * _instrument.GetPipSize();
      return true;
   }
};


// Highest bars stream v1.0

class HighestBarsStream : public AOnStream
{
   int _loopback;
public:
   HighestBarsStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceHigh))
   {
      _source.Release();
      _loopback = loopback;
   }
   HighestBarsStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   bool GetValue(const int period, double &val)
   {
      double current;
      if (!_source.GetValue(period, current))
         return false;
      int index = 0;
      for (int i = 1; i < _loopback; ++i)
      {
         double value;
         if (!_source.GetValue(period + i, value))
            return false;
         if (current < value)
         {
            current = value;
            index = i;
         }
      }
      val = index;
      return true;
   }
};




// Lowest bars stream v1.0

class LowestBarsStream : public AOnStream
{
   int _loopback;
public:
   LowestBarsStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceLow))
   {
      _source.Release();
      _loopback = loopback;
   }
   LowestBarsStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   bool GetValue(const int period, double &val)
   {
      double current;
      if (!_source.GetValue(period, current))
         return false;
      int index = 0;
      for (int i = 1; i < _loopback; ++i)
      {
         double value;
         if (!_source.GetValue(period + i, value))
            return false;
         if (current > value)
         {
            current = value;
            index = i;
         }
      }
      val = index;
      return true;
   }
};




// Highest high stream v1.3

class HighestHighStream : public AOnStream
{
   int _loopback;
public:
   HighestHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceHigh))
   {
      _source.Release();
   }
   HighestHighStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   bool GetValue(const int period, double &val)
   {
      if (!_source.GetValue(period, val))
         return false;

      for (int i = 1; i < _loopback; ++i)
      {
         double value;
         if (!_source.GetValue(period + i, value))
            return false;
         val = MathMax(val, value);
      }
      return true;
   }
};




// Lowest low stream v1.3

class LowestLowStream : public AOnStream
{
   int _loopback;
public:
   LowestLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int loopback)
      :AOnStream(new SimplePriceStream(symbol, timeframe, PriceLow))
   {
      _source.Release();
   }
   LowestLowStream(IStream* source, int loopback)
      :AOnStream(source)
   {
      _loopback = loopback;
   }

   bool GetValue(const int period, double &val)
   {
      if (!_source.GetValue(period, val))
         return false;

      for (int i = 1; i < _loopback; ++i)
      {
         double value;
         if (!_source.GetValue(period + i, value))
            return false;
         val = MathMin(val, value);
      }
      return true;
   }
};
IStream* highestbars1;
IStream* lowestbars2;
IStream* highest3;
IStream* lowest4;
// Stream base v1.0



#ifndef AStreamBase_IMP
#define AStreamBase_IMP

class AStreamBase : public IStream
{
   int _references;
public:
   AStreamBase()
   {
      _references = 1;
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
};
#endif
// Custom stream v2.2

class CustomStream : public AStreamBase
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void Init()
   {
      ArrayInitialize(_stream, EMPTY_VALUE);
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[index] = value;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Size();
      int index = totalBars - period - 1;
      if (index < 0 || totalBars <= index)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      val = _stream[index];
      return _stream[index] != EMPTY_VALUE;
   }
private:
   void EnsureStreamHasProperSize(int size)
   {
      if (ArrayRange(_stream, 0) != size) 
      {
         ArrayResize(_stream, size);
      }
   }
};



// Change stream v1.0

#ifndef ChangeStream_IMP
#define ChangeStream_IMP

class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(IStream* stream, int period = 1)
      :AOnStream(stream)
   {
      _period = period;
   }
   
   virtual bool GetValue(const int period, double &val)
   {
      double src1, src2;
      if (!_source.GetValue(period, src1) || !_source.GetValue(period + _period, src2))
      {
         return false;
      }
      val = src1 - src2;
      return true;
   }
};

#endif
double dir[];
double conscnt[];
double condhigh[];
double condlow[];
string upline;
string dnline;
bool breakoutup;
bool breakoutdown;
CustomStream* change1Source;
IStream* change1;
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("Consolidation Zones - Live");
   IndicatorShortName("Consolidation Zones - Live");
   IndicatorBuffers(5);
   int id = 0;
   SetIndexBuffer(id++, dir);
   SetIndexBuffer(id++, conscnt);
   SetIndexBuffer(id++, condhigh);
   SetIndexBuffer(id++, condlow);
   SetIndexBuffer(id++, zz);
   breakoutup = false;
   breakoutdown = false;
   change1Source = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   change1 = new ChangeStream(change1Source, 1);
   highestbars1 = new HighestBarsStream(_Symbol, (ENUM_TIMEFRAMES)_Period, prd);
   lowestbars2 = new LowestBarsStream(_Symbol, (ENUM_TIMEFRAMES)_Period, prd);
   highest3 = new HighestHighStream(_Symbol, (ENUM_TIMEFRAMES)_Period, conslen);
   lowest4 = new LowestLowStream(_Symbol, (ENUM_TIMEFRAMES)_Period, conslen);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   highestbars1.Release();
   lowestbars2.Release();
   highest3.Release();
   lowest4.Release();
   change1Source.Release();
   change1.Release();
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
      ArrayInitialize(dir, 0);
      ArrayInitialize(conscnt, 0);
      ArrayInitialize(condhigh, EMPTY_VALUE);
      ArrayInitialize(condlow, EMPTY_VALUE);
      ArrayInitialize(zz, EMPTY_VALUE);
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

   int toSkip = 1000;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      double highestbars1Value;
      if (!highestbars1.GetValue(pos, highestbars1Value))
      {
         continue;
      }
      double hb_ = ((highestbars1Value == 0) ? high[pos] : EMPTY_VALUE);
      double lowestbars2Value;
      if (!lowestbars2.GetValue(pos, lowestbars2Value))
      {
         continue;
      }
      double lb_ = ((lowestbars2Value == 0) ? low[pos] : EMPTY_VALUE);
      dir[pos] = pos < rates_total - 1 ? dir[pos + 1] : 1;
      zz[pos] = EMPTY_VALUE;
      double pp = EMPTY_VALUE;
      dir[pos] = ((hb_ != EMPTY_VALUE && (lb_) == EMPTY_VALUE) ? 1 : ((lb_ != EMPTY_VALUE && (hb_) == EMPTY_VALUE) ? (-1) : dir[pos]));
      if ((hb_ != EMPTY_VALUE && lb_ != EMPTY_VALUE))
      {
         if ((dir[pos] == 1))
         {
            zz[pos] = hb_;
         }
         else
         {
            zz[pos] = lb_;
         };
      }
      else
      {
         zz[pos] = (hb_ != EMPTY_VALUE ? hb_ : (lb_ != EMPTY_VALUE ? lb_ : EMPTY_VALUE));
      }
      for (int x = 0; x <= 1000; ++x)
      {
         if (((close[pos]) == EMPTY_VALUE || (dir[pos] != dir[pos + x])))
         {
break;
         };
         if (zz[pos + x] != EMPTY_VALUE)
         {
            if ((pp) == EMPTY_VALUE)
            {
               pp = zz[pos + x];
            }
            else
            {
               if (((dir[pos + x] == 1) && (zz[pos + x] > pp)))
               {
                  pp = zz[pos + x];
               };
               if (((dir[pos + x] == (-1)) && (zz[pos + x] < pp)))
               {
                  pp = zz[pos + x];
               };
            };
         };
      }
      conscnt[pos] = pos < rates_total - 1 ? conscnt[pos + 1] : 1;
      condhigh[pos] = pos < rates_total - 1 ? condhigh[pos + 1] : 1;
      condlow[pos] = pos < rates_total - 1 ? condlow[pos + 1] : 1;
      double highest3Value;
      if (!highest3.GetValue(pos, highest3Value))
      {
         continue;
      }
      double H_ = highest3Value;
      double lowest4Value;
      if (!lowest4.GetValue(pos, lowest4Value))
      {
         continue;
      }
      double L_ = lowest4Value;
      change1Source.SetValue(pos, pp);
      double change1Value;
      if (!change1.GetValue(pos, change1Value))
      {
         continue;
      }
      if (change1Value != 0)
      {
         if ((conscnt[pos] > conslen))
         {
            if ((pp > condhigh[pos]))
            {
               breakoutup = true;
            };
            if ((pp < condlow[pos]))
            {
               breakoutdown = true;
            };
         };
         if ((((conscnt[pos] > 0) && (pp <= condhigh[pos])) && (pp >= condlow[pos])))
         {
            conscnt[pos] = conscnt[pos] + 1;
         }
         else
         {
            conscnt[pos] = 0;
         };
      }
      else
      {
         conscnt[pos] = conscnt[pos] + 1;
      }
      if ((conscnt[pos] >= conslen))
      {
         if ((conscnt[pos] == conslen))
         {
            condhigh[pos] = H_;
            condlow[pos] = L_;
         }
         else
         {
            ObjectDelete(upline);
            ObjectDelete(dnline);
            condhigh[pos] = MathMax(condhigh[pos], high[pos]);
            condlow[pos] = MathMin(condlow[pos], low[pos]);
         };
         upline = CreateLineObject("line_1_id", time[rates_total - 1 - (int)((rates_total - 1 - pos))], condhigh[pos], time[rates_total - 1 - (int)((rates_total - 1 - pos) - conscnt[pos])], condhigh[pos], Red, false, time[pos]);
         dnline = CreateLineObject("line_2_id", time[rates_total - 1 - (int)((rates_total - 1 - pos))], condlow[pos], time[rates_total - 1 - (int)((rates_total - 1 - pos) - conscnt[pos])], condlow[pos], Lime, false, time[pos]);
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
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

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