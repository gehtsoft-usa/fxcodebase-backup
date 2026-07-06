// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=27&t=70158
// -------------------------------------------------------------------------------------------
// 
//     BERLIN Renegade
//     ACTION Locator
//     Version 2.8
// 
// -------------------------------------------------------------------------------------------
// 
// This is the volatility and range identifying part of a larger algorithm called the
// "BERLIN Renegade". It is based on the NNFX way of trading, with some modifications.
// 
// The indicator is based on making the standard deviation (where the mean is a moving
// average) a two-lines cross indicator, by applying an MA over it.
// 
// When the standard deviation is above the MA, there is considered to be enough volatility
// in the market for trends to form. This is the middle blue bars.
// 
// Included is also two other parts. The upper bars consist of the BERLIN Range Index.
// It is used to identify choppiness and is originally based on the choppiness index, but
// improved using an ATR filter.
// 
// The lower green (teal) bars check when there is force behind the ACTION by applying a
// moving average on a selected volatility index (VIX), and plotting teal bars when the
// VIX crosses above the moving average, indicating that the market the VIX is measuring is
// getting more volatile.
// 
// Included in this indicator is also basic trade management tools using the ATR. It helps you
// find suitable stoploss and take profit distances for trades using the ATR. The ATR is also
// used to find what VP from NNFX calls 'FU-candles'. These are candles that are very big and
// what happens next after candles like these is very hard to predict, and therefore it is
// safer to avoid trading them.
// 
// Yellow bars (upper row) = Trending
// Orange bars (upper row) = Exhausted trend (could potentially reverse, so if trend trading,
//                           use less risk)
// Red bars (upper row)    = Exhausted trend is losing momentum (reversal or pullback is very
//                           likely ahead, use less risk)
// Gray bars (upper row)   = Ranging - DO NOT TRADE!
// 
// Blue bars (mid row) = There is ACTION in the market -- signals it should be safe to trade
// Gray bars (mid row) = No ACTION - DO NOT TRADE!
// 
// Teal bars (lower row) = There is force behind the ACTION!
// Gray bars (lower row) = Less volatility in the market, be careful!
// 
// -------------------------------------------------------------------------------------------
// 
// Changelog:
// 
// - Version 2.8 -
//    * Added a custom VIX that is calculated in a similar waythat the Bitcoin Historical
//      Volatility Index (BVOL24H) is calculated, to make a kind of "adaptive" VIX that works
//      on any market.
//    * Cleaned up a code a bit with line breaks.
// - Version 2.7 -
//    * Made some options more clear and added dummy checkboxes to divide the settings into
//      categories.
//    * Added more VIX tickers to the VIX ticker list to cover more markets.
//    * Added an option to adapt colors to bright mode (the TradingView color theme).
// - Version 2.6 -
//    * Added option to alert for orange bars in the BERLIN Range Index (upper row).
// - Version 2.5 -
//    * Changed name to include the name of the algo this indicator is part of.
//    * Added licensing information in the comments.
//    * Added more information in the header comment to make the indicator easier to
//      understand.
// - Version 2.4 -
//    * Changed out the choppiness index for the BERLIN Range Index, as it is less laggy.
// - Version 2.3 -
//    * Added a choppiness index filter as a third confirmation for volatility.
// - Version 2.2 -
//    * Added checks against volatility indices in order to indicate whether or not there is
//      volatility in the market. You can choose between a volatility index for Forex (EVZ)
//      and two stock indices (VIX). The idea is that if there is volatility in the overall
//      market, there is a higher probability that the market will take ACTION.
// - Version 2.1 -
//    * Added the Average Sigma Price Build-up signal to the indicator. This is usually quite
//      a strong indication of possible ACTION in the market. Whenever this signals the
//      upper bar is brighter, signaling a stronger volatility and a higher probability
//      that the market will take ACTION.
//    * Corrected a bug in the LSMA calculation.
// - Version 2.0 -
//    * Initial release.
// 
// -------------------------------------------------------------------------------------------
// 
// Licensed under CC BY-NC.
// https://creativecommons.org/licenses/by-nc/4.0/
// 
// Copyright © Anton "lejmer" Berlin, 2020.
// 
// -------------------------------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"
#property strict
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_color1 clrRed
#property indicator_minimum 0
#property indicator_maximum 5

input string dummy_brx = ""; // ------------ BERLIN Range Index (BRX) ------------
input int range_length = 9; // Length
input int range_max_val = 40; // Max value
input int range_min_val = 10; // Min value
input int af_atr_length = 14; // ATR Filter: Period
input int af_low_lookback = 14; // ATR Filter: Low Lookback Period
input bool af_use_normalized = true; // ATR Filter: Used normalized true range?
input int af_stddev_length = 14; // ATR Filter: Standard Deviation - Length
input bool alert_orange_bmx = true; // Alert for orange bars?
input bool range_bypass = true; // Skip BERLIN Range Index?
input string dummy_stddev = ""; // ------------ Standard Deviation ------------
input int stddev_length = 14; // Length
input bool stddev_use_ha_src = false; // Use Heikin Ashi as source?
input bool stddev_bypass = false; // Skip standard deviation?
input int ma_length = 6; // Threshold MA - Length
input ENUM_MA_METHOD ma_type = MODE_SMA; // Threshold MA - Type
input string dummy_asp = ""; // ------------ Average Sigma Price Build-up ------------
input int asp_length = 7; // Period
input ENUM_MA_METHOD asp_smoothing_ma_type = MODE_SMA; // Smoothing MA
input int asp_smoothing = 1; // Smoothing period
input ENUM_MA_METHOD asp_signal_ma_type = MODE_SMA; // Signal MA
input int asp_signal_ma_length = 14; // Signal MA length
input double asp_threshold = 0.02; // Threshold
input bool asp_use_ha_src = false; // Use Heikin Ashi as source?
input bool asp_bypass = false; // Skip Average Sigma Price Build-up?
input string dummy_vix = ""; // ------------ Volatility Index (VIX) ------------
input ENUM_MA_METHOD vix_ma_type = MODE_SMA; // Threshold MA Type
input int vix_ma_length = 20; // Threshold MA Period
input string dummy_fu_atrf = ""; // ------------ FU Candle ATR Filter ------------
input int fu_atr_length = 14; // ATR Length
input double fu_atr_max_mult = 2.0; // ATR Threshold Factor
input bool fu_atr_bypass = false; // Skip FU Candle ATR Filter?
input string dummy_atr_tm = ""; // ------------ ATR Trade management ------------
input int atr_len = 14; // ATR Length
input double atr_sl_factor = 1.5; // SL multiplier
input double atr_tp_factor = 1.0; // TP multiplier
input bool atr_bypass = false; // Skip ATR Trade management?

// Yellow bars (upper row) = Trending
// Orange bars (upper row) = Exhausted trend (could potentially reverse, so if trend trading,
//                           use less risk)
// Red bars (upper row)    = Exhausted trend is losing momentum (reversal or pullback is very
//                           likely ahead, use less risk)
// Gray bars (upper row)   = Ranging - DO NOT TRADE!
// 
// Blue bars (mid row) = There is ACTION in the market -- signals it should be safe to trade
// Gray bars (mid row) = No ACTION - DO NOT TRADE!
// 
// Teal bars (lower row) = There is force behind the ACTION!
// Gray bars (lower row) = Less volatility in the market, be careful!


input color range_clr                    = clrDimGray;
input color range_trend_clr              = 0xEFDB2B;
input color range_strong_trend_clr       = clrOrange;
input color range_weakening_trend_clr    = clrRed;
input color LowerRowColor_ActionForce    = clrTeal;
input color LowerRowColor_LessVolatility = clrDimGray;

//+------------------------------------------------------------------------------------------------------------------+
double StDev(double& data[], int period, int pos)
{
   return MathSqrt(Variance(data, period, pos));
}
//+------------------------------------------------------------------------------------------------------------------+
double Variance(double& data[], int period, int pos)
{
   double sum = 0;
   double ssum = 0;
   for (int i = 0; i < period; i++)
   {
      sum += data[pos + i];
      ssum += MathPow(data[pos + i], 2);
   }
   return (ssum * period - sum * sum) / (period * (period - 1));
}
//+------------------------------------------------------------------------------------------------------------------+
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
//+------------------------------------------------------------------------------------------------------------------+
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
//+------------------------------------------------------------------------------------------------------------------+
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

// Colored stream v3.2

#ifndef ColoredStream_IMP
#define ColoredStream_IMP

class ColoredStreamData
{
public:
   double Stream[];
};
//+------------------------------------------------------------------------------------------------------------------+
class ColoredStream : public AStream
{
public:
   ColoredStreamData _streams[];
   double _data[];

   ColoredStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   void Init(double defaultValue)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         ArrayInitialize(_streams[i].Stream, defaultValue);
      }
      ArrayInitialize(_data, defaultValue);
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id + 0, _data);
      SetIndexStyle(id + 0, DRAW_NONE);
      return id + 1;
   }

   int RegisterStream(int id, color clr, string label = "", int lineType = DRAW_LINE, ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      SetIndexStyle(id, lineType, lineStyle, width, clr);
      SetIndexBuffer(id, _streams[size].Stream);
      SetIndexEmptyValue(id, EMPTY_VALUE);
      if (label != "")
         SetIndexLabel(id, label);
      return id + 1;
   }

   int GetColorIndex(int period)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].Stream[period] != EMPTY_VALUE)
            return i;
      }
      return -1;
   }

   void Set(double value, int period, int colorIndex)
   {
      _data[period] = value;
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (colorIndex == i)
         {
            _streams[i].Stream[period] = value;
            if (period + 1 < iBars(_symbol, _timeframe) && _streams[i].Stream[period + 1] == EMPTY_VALUE)
               _streams[i].Stream[period + 1] = _data[period + 1];   
         }
         else
            _streams[i].Stream[period] = EMPTY_VALUE;
      }
   }

   bool GetValue(const int period, double &val)
   {
      if (period >= iBars(_symbol, _timeframe))
      {
         return false;
      }
      val = _data[period];
      return _data[period] != EMPTY_VALUE;
   }
};

#endif
ColoredStream* al_lowerbar;
ColoredStream* al_upperbar;
ColoredStream* al_rangebar;
double tr_val[], atr_val[], af_stddev[], range_index[], stddev_src[], stddev_val[], asp_src[], asp_src_stdev[], asp_pval[], asp_price_stdev[], acc_ln_price[], adaptive_vix_val[];
//+------------------------------------------------------------------------------------------------------------------+
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("al");
   IndicatorShortName("Action Locator");

   IndicatorBuffers(24);
   
   int id = 0; SetIndexArrow(id,110);
   al_lowerbar = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
// Teal bars (lower row) = There is force behind the ACTION!
// Gray bars (lower row) = Less volatility in the market, be careful!
   id = al_lowerbar.RegisterStream(id, LowerRowColor_ActionForce,"", DRAW_ARROW,STYLE_SOLID,0); SetIndexArrow(id,110); 
   id = al_lowerbar.RegisterStream(id, LowerRowColor_LessVolatility,"",DRAW_ARROW,STYLE_SOLID,0); SetIndexArrow(id,110);

   al_rangebar = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
// Yellow bars (upper row) = Trending
// Orange bars (upper row) = Exhausted trend (could potentially reverse, so if trend trading,
//                           use less risk)
// Red bars (upper row)    = Exhausted trend is losing momentum (reversal or pullback is very
//                           likely ahead, use less risk)
// Gray bars (upper row)   = Ranging - DO NOT TRADE!
   id = al_rangebar.RegisterStream(id, range_clr,"", DRAW_ARROW,STYLE_SOLID,0); SetIndexArrow(id,110);
   id = al_rangebar.RegisterStream(id, range_trend_clr,"", DRAW_ARROW,STYLE_SOLID,0); SetIndexArrow(id,110);
   id = al_rangebar.RegisterStream(id, range_strong_trend_clr,"", DRAW_ARROW,STYLE_SOLID,0); SetIndexArrow(id,110);
   id = al_rangebar.RegisterStream(id, range_weakening_trend_clr,"", DRAW_ARROW,STYLE_SOLID,0); SetIndexArrow(id,110);

   al_upperbar = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
// Blue bars (mid row) = There is ACTION in the market -- signals it should be safe to trade
// Gray bars (mid row) = No ACTION - DO NOT TRADE!
   id = al_upperbar.RegisterStream(id, clrBlue,"", DRAW_ARROW,STYLE_SOLID,0); SetIndexArrow(id,110);
   id = al_upperbar.RegisterStream(id, 0x115193,"", DRAW_ARROW,STYLE_SOLID,0); SetIndexArrow(id,110);
   id = al_upperbar.RegisterStream(id, clrDimGray,"", DRAW_ARROW,STYLE_SOLID,0); SetIndexArrow(id,110);

   id = al_lowerbar.RegisterInternalStream(id);
   id = al_rangebar.RegisterInternalStream(id);
   id = al_upperbar.RegisterInternalStream(id);

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, tr_val);
   SetIndexEmptyValue(id, EMPTY_VALUE);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, atr_val);
   SetIndexEmptyValue(id, EMPTY_VALUE);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, af_stddev);
   SetIndexEmptyValue(id, EMPTY_VALUE);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, range_index);
   SetIndexEmptyValue(id, EMPTY_VALUE);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, stddev_src);
   SetIndexEmptyValue(id, EMPTY_VALUE);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, stddev_val);
   SetIndexEmptyValue(id, EMPTY_VALUE);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, asp_src);
   SetIndexEmptyValue(id, EMPTY_VALUE);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, asp_src_stdev);
   SetIndexEmptyValue(id, EMPTY_VALUE);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, asp_pval);
   SetIndexEmptyValue(id, 0);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, asp_price_stdev);
   SetIndexEmptyValue(id, EMPTY_VALUE);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, acc_ln_price);
   SetIndexEmptyValue(id, EMPTY_VALUE);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, adaptive_vix_val);
   SetIndexEmptyValue(id, EMPTY_VALUE);
   ++id;

   return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------------------------------------------------------+
int deinit()
{
   al_lowerbar.Release();
   al_lowerbar = NULL;
   al_rangebar.Release();
   al_rangebar = NULL;
   al_upperbar.Release();
   al_upperbar = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

double TrueRange(const int p)
{
   double hl = MathAbs(High[p] - Low[p]);
   double hc = MathAbs(High[p] - Close[p + 1]);
   double lc = MathAbs(Low[p] - Close[p + 1]);

   double tr = hl;
   if (tr < hc)
      tr = hc;
   if (tr < lc)
      tr = lc;
   return tr;
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
      ArrayInitialize(tr_val, EMPTY_VALUE);
      ArrayInitialize(atr_val, EMPTY_VALUE);
      ArrayInitialize(af_stddev, EMPTY_VALUE);
      ArrayInitialize(range_index, EMPTY_VALUE);
      ArrayInitialize(stddev_src, EMPTY_VALUE);
      ArrayInitialize(stddev_val, EMPTY_VALUE);
      ArrayInitialize(asp_src, EMPTY_VALUE);
      ArrayInitialize(asp_src_stdev, EMPTY_VALUE);
      ArrayInitialize(asp_pval, 0);
      ArrayInitialize(asp_price_stdev, EMPTY_VALUE);
      ArrayInitialize(acc_ln_price, EMPTY_VALUE);
      ArrayInitialize(adaptive_vix_val, EMPTY_VALUE);
      al_lowerbar.Init(EMPTY_VALUE);
      al_rangebar.Init(EMPTY_VALUE);
      al_upperbar.Init(EMPTY_VALUE);
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

   int toSkip = fu_atr_length + 1;
   int first = rates_total - 1 - toSkip;
   int stddev_val_first = first - stddev_length;
   int atr_val_first = first - af_atr_length;
   int af_stddev_first = atr_val_first - af_stddev_length;
   int range_index_first = af_stddev_first - af_low_lookback;
   int asp_src_stdev_first = first - asp_length;
   int asp_price_stdev_first = asp_src_stdev_first - asp_smoothing;
   int al_upperbar_first = MathMin(asp_price_stdev_first - asp_signal_ma_length, stddev_val_first - ma_length);
   int adaptive_vix_val_first = first - 10;
   int vix_ma_first = adaptive_vix_val_first - vix_ma_length;
   for (int pos = rates_total - 1 - MathMax(prev_calculated, toSkip); pos >= 0 && !IsStopped(); --pos)
   {
      double tr = TrueRange(pos);
      double fu_atr_val = iATR(_Symbol, _Period, fu_atr_length, pos + 1);
      bool fu_atr_filter = fu_atr_bypass ? false : tr >= (fu_atr_val * fu_atr_max_mult);
      
      double chop_str = tr;
      double chop_ltl = Low[pos] <= Close[pos + 1] ? Low[pos] : Close[pos + 1];
      double chop_hth = High[pos] >= Close[pos + 1] ? High[pos] : Close[pos + 1];
      for (int i = 1; i < range_length; ++i)
      {
         chop_str += TrueRange(pos + i);
         chop_ltl = MathMin(chop_ltl, Low[pos + i] <= Close[pos + i + 1] ? Low[pos + i] : Close[pos + i + 1]);
         chop_hth = MathMax(chop_hth, High[pos + i] >= Close[pos + i + 1] ? High[pos + i] : Close[pos + i + 1]);
      }
      double chop_height = chop_hth - chop_ltl;
      double chop_value = chop_height == 0 ? 0 : 100 * (MathLog10(chop_str / chop_height) / MathLog10(range_length));
      tr_val[pos] = af_use_normalized ? MathMax(MathMax(tr, High[pos] - Close[pos]), Close[pos] - Low[pos]) / Close[pos] : tr;

      double stddev_ha_close = iCustom(NULL, 0, "Heiken Ashi", 2, pos);
      asp_src[pos] = asp_use_ha_src ? stddev_ha_close : Close[pos];
      stddev_src[pos] = stddev_use_ha_src ? stddev_ha_close : Close[pos];
      
      acc_ln_price[pos] = 0.0;
      for (int i = 0; i < 9; ++i)
      {
         acc_ln_price[pos] += MathLog(Close[pos + i + 1]) / MathLog(Close[pos + i]);
      }

      if (pos < atr_val_first)
      {
         atr_val[pos] = iMAOnArray(tr_val, 0, af_atr_length, 0, MODE_SMA, pos);
         if (pos < af_stddev_first)
         {
            af_stddev[pos] = StDev(atr_val, af_stddev_length, pos);
            if (pos < range_index_first)
            {
               int lowestIndex = ArrayMinimum(af_stddev, af_low_lookback, pos);
               double af_stddev_lo = af_stddev[lowestIndex];
               double af_stddev_factor = af_stddev_lo / af_stddev[pos];
               range_index[pos] = chop_value * af_stddev_factor;
               bool range_strong_trend_condition = range_index[pos] < range_min_val;
               bool range_weakening_trend_condition = range_index[pos + 1] < range_min_val && range_index[pos] > range_min_val;
               bool range_trend_condition = range_index[pos + 1] > range_min_val && range_index[pos] < range_max_val && range_index[pos] > range_min_val;
               al_rangebar.Set(3, pos, range_index[pos] > range_max_val 
                  ? 0 : range_trend_condition 
                  ? 1 : range_strong_trend_condition 
                  ? 2 : range_weakening_trend_condition 
                  ? 3 : 0);
            }
         }
      }
      if (pos < asp_src_stdev_first)
      {
         asp_src_stdev[pos] = StDev(asp_src, asp_length, pos);
      }
      if (pos < asp_price_stdev_first)
      {
         asp_price_stdev[pos] = iMAOnArray(asp_src_stdev, 0, asp_smoothing, 0, asp_smoothing_ma_type, pos);
         asp_pval[pos] = MathMax(asp_pval[pos + 1] + (asp_price_stdev[pos] - asp_price_stdev[pos + asp_length]) / asp_length, 0);
      }
      if (pos < stddev_val_first)
      {
         stddev_val[pos] = StDev(stddev_src, stddev_length, pos);
      }
      if (pos < al_upperbar_first)
      {
         double asp_signal_base_p = iMAOnArray(asp_pval, 0, asp_signal_ma_length, 0, asp_signal_ma_type, pos);
         double asp_diff = MathMax(asp_pval[pos] - asp_signal_base_p, 0);
         double asp_factor = asp_pval[pos] == 0 ? 0 : asp_diff / asp_pval[pos];
         double asp_val = 1.0 / (1.0 - asp_factor) - 1.0;
         double asp_main_out = asp_bypass ? 0 : MathMax(asp_val - asp_threshold, 0);
         double threshold_ma = iMAOnArray(stddev_val, 0, ma_length, 0, ma_type, pos);
         double stddev_main_out = fu_atr_filter || stddev_bypass ? 0 : MathMax(0, stddev_val[pos] - threshold_ma);
         al_upperbar.Set(2, pos, asp_main_out > 0 ? 0 : (stddev_main_out > 0 && asp_main_out == 0) ? 1 : 2);
      }
      if (pos < adaptive_vix_val_first)
      {
         adaptive_vix_val[pos] = StDev(acc_ln_price, 10, pos) * MathSqrt(10);
      }
      if (pos < vix_ma_first)
      {
         double vix_ma = iMAOnArray(adaptive_vix_val, 0, vix_ma_length, 0, vix_ma_type, pos);
         al_lowerbar.Set(1, pos, adaptive_vix_val[pos] > vix_ma ? 0 : 1);
      }
      
      // double atr = iATR(_Symbol, _Period, atr_len, pos);
      // double atr_sl_val = atr * atr_sl_factor;
      // double atr_tp_val = atr * atr_tp_factor;
      // plotshape(title = "SL Value",
      //    series = atr_bypass ? na : atr_sl_val,
      //    color = color.orange,
      //    location = location.bottom,
      //    size = size.tiny,
      //    transp = 100)

      // plotshape(title = "TP Value",
      //    series = atr_bypass ? na : atr_tp_val,
      //    color = color.purple,
      //    location = location.bottom,
      //    size = size.tiny,
      //    transp = 100)

      // // -------------------------------------------------------------------------------------------
      // //    Alerts
      // // -------------------------------------------------------------------------------------------

      // alertcondition(alert_orange_bmx and range_strong_trend_condition and range_trend_condition[1],
      //    "Orange bar detected",
      //    "Red bar approaching")
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}

