//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76046

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4
#property indicator_type1 DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_type3 DRAW_ARROW
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_type4 DRAW_ARROW
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

// Pine-script like safe operations
// v1.2

double Nz(double val, double defaultValue = 0)
{
   return val == EMPTY_VALUE ? defaultValue : val;
}
double SafePlus(int left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
double SafePlus(double left, int right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
int SafePlus(int left, int right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return INT_MIN;
   }
   return left + right;
}
double SafePlus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
string SafePlus(string left, string right)
{
   if (left == NULL || right == NULL)
   {
      return NULL;
   }
   return left + right;
}

double SafeMinus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left - right;
}

double SafeDivide(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE || right == 0)
   {
      return EMPTY_VALUE;
   }
   return left / right;
}

double SafeMultiply(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left * right;
}

bool SafeGreater(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left > right;
}

bool SafeGE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left >= right;
}

bool SafeLess(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left < right;
}

bool SafeLE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left <= right;
}

double SafeMathExp(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathExp(value);
}

double SafeMathMax(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMax(left, right);
}

double SafeMathMax(double param1, double param2, double param3)
{
   if (param1 == EMPTY_VALUE || param2 == EMPTY_VALUE || param3 == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMax(MathMax(param1, param2), param3);
}

double SafeMathMin(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(left, right);
}

double SafeMathMin(double param1, double param2, double param3)
{
   if (param1 == EMPTY_VALUE || param2 == EMPTY_VALUE || param3 == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(MathMin(param1, param2), param3);
}

double SafeMathPow(double value, double power)
{
   if (value == EMPTY_VALUE || power == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathPow(value, power);
}

double SafeMathAbs(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathAbs(value);
}

double SafeMathRound(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathRound(value);
}

double SafeMathRound(double value, int precision)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return NormalizeDouble(value, precision);
}

double SafeMathSqrt(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathSqrt(value);
}

int SafeSign(double value)
{
   if (value == EMPTY_VALUE)
   {
      return INT_MIN;
   }
   if (value == 0)
   {
      return 0;
   }
   return value > 0 ? 1 : -1;
}

double SafeLog(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathLog(value);
}
double SafeLog10(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathLog10(value);
}
double SafeCos(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathCos(value);
}
double SafeArccos(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArccos(value);
}
double SafeSin(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathSin(value);
}
double SafeArcsin(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArcsin(value);
}
double SafeTan(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathTan(value);
}
double SafeArctan(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArctan(value);
}
double InvertSign(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return -value;
}
int SafeMathCeil(double value)
{
   if (value == EMPTY_VALUE)
   {
      return INT_MIN;
   }
   return MathCeil(value);
}

#ifndef IntStream_IMPL
#define IntStream_IMPL

// Abstract Int stream v1.0

#ifndef AIntStream_IMPL
#define AIntStream_IMPL
// Integer Stream v.1.0

#ifndef IIntStream_IMPL
#define IIntStream_IMPL

interface IIntStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValues(const int period, const int count, int &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, int &val[]) = 0;
};

#endif

class AIntStream : public IIntStream
{
   int _refs;   
public:
   AIntStream()
   {
      _refs = 1;
   }

   void AddRef()
   {
      _refs++;
   }
   void Release()
   {
      if (--_refs == 0)
      {
         delete &this;
      }
   }
};

#endif
// Int stream v1.1

class IntStream : public AIntStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _stream[];
   int _emptyValue;
public:
   IntStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int emptyValue = INT_MIN)
   {
      _emptyValue = emptyValue;
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void Init()
   {
      ArrayInitialize(_stream, _emptyValue);
   }

   virtual int Size()
   {
      return Bars(_symbol, _timeframe);
   }

   void SetValue(const int period, int value)
   {
      int totalBars = Size();
      if (period < 0 || totalBars <= period)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value;
   }

   virtual bool GetValues(const int period, const int count, int &val[])
   {
      int totalBars = Size();
      if (period - count + 1 < 0 || totalBars <= period)
      {
         return false;
      }
      EnsureStreamHasProperSize(totalBars);
      
      for (int i = 0; i < count; ++i)
      {
         val[i] = _stream[period - i];
         if (val[i] == _emptyValue)
         {
            return false;
         }
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, int &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
private:
   void EnsureStreamHasProperSize(int size)
   {
      int currentSize = ArrayRange(_stream, 0);
      if (currentSize != size) 
      {
         ArrayResize(_stream, size);
         for (int i = currentSize; i < size; ++i)
         {
            _stream[i] = _emptyValue;
         }
      }
   }
};

#endif
input int param1 = 3; // Number of bars
input bool param2 = true; // Include current bar
input int param3 = 50; // Number of bars to look back
input color param4 = Green; // Up color
input color param5 = Red; // Down color
input color param6 = Gray; // Neutral color
input int bars_limit = 1000; // Bars limit
int n;
int realtime;
class RateBar_iStream
{
   int shift;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   RateBar_iStream(int shift, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.shift = shift;
   }
   ~RateBar_iStream()
   {
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, int &__out1)
   {
      int res = 0;
      int for1_from = 1;
      int for1_to = n;
      bool for1_forward = for1_from <= for1_to;
      int for1_step = 1 * (for1_forward ? 1 : -1);
      if (for1_from == EMPTY_VALUE || for1_to == EMPTY_VALUE) { return false; }
      for (int i = for1_from; (for1_forward ? i <= for1_to : i >= for1_to); i += for1_step)
      {
         if (SafeGreater(iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos + (shift + i - 1)), iOpen(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos + (shift + i - 1))))
         {
            res = SafePlus(res, SafeMathCeil(MathPow(2, i)));
         }
      }
      __out1 = res;
      return true;
   }
};
RateBar_iStream* RateBar_i1;
int lookback;
class RateBar_iSStream
{
   IIntStream* shift;
   bool _initialized;
   string IndicatorObjPrefix;
public:
   RateBar_iSStream(IIntStream* shift, string indicatorObjPrefix)
   {
      _initialized = false;
      IndicatorObjPrefix = indicatorObjPrefix;
      this.shift = shift;
      shift.AddRef();
   }
   ~RateBar_iSStream()
   {
      shift.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, int &__out1)
   {
      int res = 0;
      int for3_from = 1;
      int for3_to = n;
      bool for3_forward = for3_from <= for3_to;
      int for3_step = 1 * (for3_forward ? 1 : -1);
      if (for3_from == EMPTY_VALUE || for3_to == EMPTY_VALUE) { return false; }
      for (int i = for3_from; (for3_forward ? i <= for3_to : i >= for3_to); i += for3_step)
      {
         int shiftValue[1];
         if (!shift.GetValues(pos, 1, shiftValue)) { shiftValue[0] = INT_MIN; }
         if (SafeGreater(iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos + (shiftValue[0] + i - 1)), iOpen(_Symbol, (ENUM_TIMEFRAMES)_Period, oldPos + (shiftValue[0] + i - 1))))
         {
            res = SafePlus(res, SafeMathCeil(MathPow(2, i)));
         }
      }
      __out1 = res;
      return true;
   }
};
IntStream* RateBar_iS2_param1;
RateBar_iSStream* RateBar_iS2;
uint up_color;
uint dn_color;
uint neutral_color;
double plot1_clr1[];
double plot1_clr2[];
double Setplot1(int pos, bool condition, double value, uint clr)
{
   if (!condition) { return EMPTY_VALUE; }
   if (clr == up_color) { plot1_clr1[pos] = value; return plot1_clr1[pos]; }
   else if (clr == neutral_color) { plot1_clr2[pos] = value; return plot1_clr2[pos]; }
   return EMPTY_VALUE;
}
double plot3_clr1[];
double plot3_clr2[];
double Setplot3(int pos, bool condition, double value, uint clr)
{
   if (!condition) { return EMPTY_VALUE; }
   if (clr == dn_color) { plot3_clr1[pos] = value; return plot3_clr1[pos]; }
   else if (clr == neutral_color) { plot3_clr2[pos] = value; return plot3_clr2[pos]; }
   return EMPTY_VALUE;
}

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
   n = param1;
   realtime = param2;
   int id = 0;
   lookback = param3;
   up_color = param4;
   dn_color = param5;
   neutral_color = param6;
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorSetString(INDICATOR_SHORTNAME, "N Candle Predictor");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   int main_shift = (realtime ? 0 : 1);
   RateBar_i1 = new RateBar_iStream(main_shift, IndicatorObjPrefix + "_1");
   id = RateBar_i1.Init(id);
   RateBar_iS2_param1 = new IntStream(_Symbol, (ENUM_TIMEFRAMES)_Period, INT_MIN);
   RateBar_iS2 = new RateBar_iSStream(RateBar_iS2_param1, IndicatorObjPrefix + "_2");
   id = RateBar_iS2.Init(id);
   SetIndexBuffer(id, plot1_clr1, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, up_color);
   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot1_clr2, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, neutral_color);
   PlotIndexSetInteger(1, PLOT_ARROW, 233);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot3_clr1, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, dn_color);
   PlotIndexSetInteger(2, PLOT_ARROW, 234);
   PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 5);
   ++id;
   SetIndexBuffer(id, plot3_clr2, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, neutral_color);
   PlotIndexSetInteger(3, PLOT_ARROW, 234);
   PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, 5);
   ++id;
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   delete RateBar_i1;
   RateBar_iS2_param1.Release();
   delete RateBar_iS2;
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
      RateBar_i1.Clear();
      RateBar_iS2_param1.Init();
      RateBar_iS2.Clear();
      ArrayInitialize(plot1_clr1, EMPTY_VALUE);
      ArrayInitialize(plot1_clr2, EMPTY_VALUE);
      ArrayInitialize(plot3_clr1, EMPTY_VALUE);
      ArrayInitialize(plot3_clr2, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      int main_shift = (realtime ? 0 : 1);
      int RateBar_i1Value;
      if (!RateBar_i1.GetValue(pos, oldPos, RateBar_i1Value)) { RateBar_i1Value = INT_MIN; }
      int current_bar = RateBar_i1Value;
      int up_count = 0;
      int down_count = 0;
      int for2_from = 1;
      int for2_to = lookback;
      bool for2_forward = for2_from <= for2_to;
      int for2_step = 1 * (for2_forward ? 1 : -1);
      if (for2_from == EMPTY_VALUE || for2_to == EMPTY_VALUE) { continue; }
      for (int i = for2_from; (for2_forward ? i <= for2_to : i >= for2_to); i += for2_step)
      {
         RateBar_iS2_param1.SetValue(pos, i + n - 1 + main_shift);
         int RateBar_iS2Value;
         if (!RateBar_iS2.GetValue(pos, oldPos, RateBar_iS2Value)) { RateBar_iS2Value = INT_MIN; }
         int rate = RateBar_iS2Value;
         if ((current_bar == rate))
         {
            if (pos - i - 1 + main_shift < 0) { continue; }
            if (pos - i - 1 + main_shift < 0) { continue; }
            if (SafeGreater(close[pos - (i - 1 + main_shift)], open[pos - (i - 1 + main_shift)]))
            {
               up_count = up_count + 1;
            }
            else
            {
               down_count = down_count + 1;
            }
         }
      }
      if (pos - main_shift < 0) { continue; }
      if (pos - main_shift < 0) { continue; }
      Setplot1(pos, (up_count > down_count), low[pos], (SafeGreater(close[pos - main_shift], open[pos - main_shift]) ? up_color : neutral_color));
      if (pos - main_shift < 0) { continue; }
      Setplot3(pos, (up_count < down_count), high[pos], (SafeLess(close[pos], open[pos - main_shift]) ? dn_color : neutral_color));
   }
   return rates_total;
}
