//Available @  https://fxcodebase.com/ 

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
#property strict

#property indicator_separate_window
#property indicator_buffers 33
#property indicator_plots 13
#property indicator_label1 "RSI"
#property indicator_type1 DRAW_LINE
#property indicator_color1 0xFF6229
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label2 "Middle Line"
#property indicator_type2 DRAW_LINE
#property indicator_color2 0x867B78
#property indicator_style2 STYLE_DOT
#property indicator_width2 1
#property indicator_label3 "Overbought"
#property indicator_type3 DRAW_LINE
#property indicator_color3 0x867B78
#property indicator_style3 STYLE_DOT
#property indicator_width3 1
#property indicator_label4 "Oversold"
#property indicator_type4 DRAW_LINE
#property indicator_color4 0x867B78
#property indicator_style4 STYLE_DOT
#property indicator_width4 1
#property indicator_type5 DRAW_FILLING
#property indicator_width5 1
#property indicator_label6 "Regular Bullish"
#property indicator_type6 DRAW_COLOR_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Regular Bullish Label"
#property indicator_type7 DRAW_ARROW
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "Hidden Bullish"
#property indicator_type8 DRAW_COLOR_LINE
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_label9 "Hidden Bullish Label"
#property indicator_type9 DRAW_ARROW
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_label10 "Regular Bearish"
#property indicator_type10 DRAW_COLOR_LINE
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_label11 "Regular Bearish Label"
#property indicator_type11 DRAW_ARROW
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1
#property indicator_label12 "Hidden Bearish"
#property indicator_type12 DRAW_COLOR_LINE
#property indicator_style12 STYLE_SOLID
#property indicator_width12 1
#property indicator_label13 "Hidden Bearish Label"
#property indicator_type13 DRAW_ARROW
#property indicator_style13 STYLE_SOLID
#property indicator_width13 1

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
#ifndef PriceStreamFactory_IMPL
#define PriceStreamFactory_IMPL

// price stream factory v1.0

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

//AOnStream v2.0
class AStreamBase : public IStream
{
   int _references;
public:
   AStreamBase()
   {
      _references = 1;
   }

   ~AStreamBase()
   {
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
// AStream v1.1

class AStream : public AStreamBase
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
public:
   AStream(string symbol, ENUM_TIMEFRAMES timeframe)
      :AStreamBase()
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   ~AStream()
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
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};
// IBarStream v1.0



#ifndef IBarStream_IMP
#define IBarStream_IMP

interface IBarStream : public IStream
{
public:
   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close) = 0;

   virtual bool FindDatePeriod(const datetime date, int& period) = 0;

   virtual bool GetOpen(const int period, double &open) = 0;
   virtual bool GetHigh(const int period, double &high) = 0;
   virtual bool GetLow(const int period, double &low) = 0;
   virtual bool GetClose(const int period, double &close) = 0;
   
   virtual bool GetHighLow(const int period, double &high, double &low) = 0;
   virtual bool GetOpenClose(const int period, double &open, double &close) = 0;

   virtual bool GetDate(const int period, datetime &dt) = 0;

   virtual int Size() = 0;

   virtual void Refresh() = 0;
};
#endif


// Price stream v3.0

#ifndef PriceStream_IMP
#define PriceStream_IMP

class PriceStream : public AStreamBase
{
   PriceType _price;
   IBarStream* _source;
public:
   PriceStream(IBarStream* source, const PriceType __price)
      :AStreamBase()
   {
      _source = source;
      _source.AddRef();
      _price = __price;
   }

   ~PriceStream()
   {
      _source.Release();
   }

   int Size()
   {
      return _source.Size();
   }

   virtual bool GetSeriesValues(const int period, const int count, double &values[])
   {
      return false;
   }

   virtual bool GetValues(const int period, const int count, double &values[])
   {
      for (int i = 0; i < count; ++i)
      {
         double val;
         switch (_price)
         {
            case PriceClose:
               if (!_source.GetClose(period - i, val))
               {
                  return false;
               }
               break;
            case PriceOpen:
               if (!_source.GetOpen(period - i, val))
               {
                  return false;
               }
               break;
            case PriceHigh:
               if (!_source.GetHigh(period - i, val))
               {
                  return false;
               }
               break;
            case PriceLow:
               if (!_source.GetLow(period - i, val))
               {
                  return false;
               }
               break;
            case PriceMedian:
               {
                  double high, low;
                  if (!_source.GetHighLow(period - i, high, low))
                  {
                     return false;
                  }
                  val = (high + low) / 2.0;
               }
               break;
            case PriceTypical:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period - i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close) / 3.0;
               }
               break;
            case PriceWeighted:
               {
                  double open, high, low, close;
                  if (!_source.GetValues(period - i, open, high, low, close))
                  {
                     return false;
                  }
                  val = (high + low + close * 2) / 4.0;
               }
               break;
         case PriceMedianBody:
            {
               double open3, close3;
               if (!_source.GetOpenClose(period - i, open3, close3))
               {
                  return false;
               }
               val = (open3 + close3) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open4, high4, low4, close4;
               if (!_source.GetValues(period - i, open4, high4, low4, close4))
               {
                  return false;
               }
               val = (high4 + low4 + close4 + open4) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open5, high5, low5, close5;
               if (!_source.GetValues(period - i, open5, high5, low5, close5))
               {
                  return false;
               }
               if (open5 > close5)
                  val = (high5 + close5) / 2.0;
               else
                  val = (low5 + close5) / 2.0;
            }
            break;
         }
         values[i] = val;
      }
      return true;
   }
};

#endif
// Bar stream v2.0



#ifndef BarStream_IMP
#define BarStream_IMP

class BarStream : public IBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _referenceCount;
public:
   BarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _referenceCount = 1;
      _symbol = symbol;
      _timeframe = timeframe;
   }
   virtual void AddRef()
   {
      ++_referenceCount;
   }
   virtual void Release()
   {
      --_referenceCount;
      if (_referenceCount == 0)
         delete &this;
   }
   
   virtual bool FindDatePeriod(const datetime date, int& period)
   {
      period = Size() - iBarShift(_symbol, _timeframe, date) + 1;
      return true;
   }
   
   virtual bool GetDate(const int period, datetime &dt)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      dt = iTime(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      high = iHigh(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      low = iLow(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      high = iHigh(_symbol, _timeframe, oldPos);
      low = iLow(_symbol, _timeframe, oldPos);
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      high = iHigh(_symbol, _timeframe, oldPos);
      low = iLow(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos)
      {
         return false;
      }
      
      open = iOpen(_symbol, _timeframe, oldPos);
      close = iClose(_symbol, _timeframe, oldPos);
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      int oldPos = size - period - 1;
      if (size <= oldPos + count - 1)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = iClose(_symbol, _timeframe, oldPos + i);
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int oldPos, const int count, double &val[])
   {
      int size = Size();
      if (size <= oldPos + count - 1)
      {
         return false;
      }
      for (int i = 0; i < count; ++i)
      {
         val[i] = iClose(_symbol, _timeframe, oldPos + i);
      }
      return true;
   }
   
   virtual void Refresh() { }
};

#endif

class PriceStreamFactory
{
public:
   static IStream* Create(string symbol, ENUM_TIMEFRAMES timeframe, PriceType price)
   {
      BarStream* source = new BarStream(symbol, timeframe);
      IStream* stream = new PriceStream(source, price);
      source.Release();
      return stream;
   }
};
#endif
#define ColorRGB(red, green, blue, transp) (uint)(red + (green << 8) + (blue << 16) + ((uint)(transp * 2.55) << 24))
#define GetColorOnly(clr) (clr & 0xFFFFFF)
#define GetTranparency(clr) (int)MathRound(((clr & 0xFF000000) >> 24) / 2.55)

uint AddTransparency(color clr, int transp)
{
   return clr + ((uint)(transp * 2.55) << 24);
}

bool NumberToBool(double number)
{
   return number != EMPTY_VALUE && number != 0;
}

class FirstBarState
{
   bool _first;
public:
   FirstBarState()
   {
      _first = true;
   }
   void Clear()
   {
      _first = true;
   }
   bool IsFirst()
   {
      bool first = _first;
      _first = false;
      return first;
   }
};

color FromGradient(double value, double bottomValue, double topValue, color bottomColor, color topColor)
{
   if (value == EMPTY_VALUE || topValue == EMPTY_VALUE)
   {
      return bottomColor;
   }
   if (bottomValue == EMPTY_VALUE)
   {
      return topColor;
   }
   return value - bottomValue < topValue - value 
      ? bottomColor
      : topColor;
}
#ifndef FloatStream_IMPL
#define FloatStream_IMPL

// Abstract float stream v1.0

#ifndef AFloatStream_IMPL
#define AFloatStream_IMPL


class AFloatStream : public IStream
{
   int _refs;   
public:
   AFloatStream()
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
// Float stream v2.0

class FloatStream : public AFloatStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   FloatStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
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
      return Bars(_symbol, _timeframe);
   }

   void SetValue(const int period, double value)
   {
      int totalBars = Size();
      if (period < 0 || totalBars <= period)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
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
         if (val[i] == EMPTY_VALUE)
         {
            return false;
         }
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
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
            _stream[i] = EMPTY_VALUE;
         }
      }
   }
};

#endif


//AOnStream v2.0
class AOnStream : public AStreamBase
{
protected:
   IStream *_source;
public:
   AOnStream(IStream *source)
      :AStreamBase()
   {
      _source = source;
      _source.AddRef();
   }

   ~AOnStream()
   {
      _source.Release();
   }
   
   virtual bool GetSeriesValue(const int period, double &val) = 0;

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetSeriesValue(period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetSeriesValue(size - 1 - period + i, v))
            return false;
         val[i] = v;
      }
      return true;
   }

   virtual int Size()
   {
      return _source.Size();
   }
};


//ChangeStream v1.1
class ChangeStream : public AOnStream
{
   int _period;
public:
   ChangeStream(IStream* stream, int period = 1)
      :AOnStream(stream)
   {
      _period = period;
   }

   bool GetSeriesValue(const int period, double &val)
   {
      if (period >= Size() - 2)
      {
         return false;
      }
      int size = Size();
      double src1[1], src2[1];
      if (!_source.GetSeriesValues(period, 1, src1) || !_source.GetSeriesValues(period + _period, 1, src2))
      {
         return false;
      }
      val = src1[0] - src2[0];
      return true;
   }
};



// RSI stream v1.1

#ifndef RSIStream_IMP
#define RSIStream_IMP

class RSISimpleStream : public AOnStream
{
   int _period;
   double _pos[];
   double _neg[];
public:
   RSISimpleStream(IStream* stream, int period)
      :AOnStream(new ChangeStream(stream))
   {
      _source.Release();
      _period = period;
   }
   
   virtual bool GetSeriesValue(const int period, double &val)
   {
      return false;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period - i, value))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
   bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (ArrayRange(_pos, 0) != totalBars) 
      {
         ArrayResize(_pos, totalBars);
         ArrayResize(_neg, totalBars);
      }
      double sump = 0;
      double sumn = 0;
      double positive;
      double negative;
      double diff[1];
      if (period == 0 || _pos[period - 1] == EMPTY_VALUE)
      {
         for (int i = 0; i < _period; ++i)
         {
            if (!_source.GetValues(period - i, 1, diff))
            {
               return false;
            }
            if (diff[0] >= 0)
            {
               sump = sump + diff[0];
            }
            else
            {
               sumn = sumn - diff[0];
            }
         }
         positive = sump / _period;
         negative = sumn / _period;
      }
      else
      {
         if (!_source.GetValues(period, 1, diff))
         {
            return false;
         }
         if (diff[0] > 0)
         {
            sump = diff[0];
         }
         else
         {
            sumn = -diff[0];
         }
         positive = (_pos[period - 1] * (_period - 1) + sump) / _period;
         negative = (_neg[period - 1] * (_period - 1) + sumn) / _period;
      }
      _pos[period] = positive;
      _neg[period] = negative;
      val = negative == 0 ? 0 : 100 - (100 / (1 + positive / negative));
      return true;
   }
};

class PineScriptRSIUpDownStream : public AStreamBase
{
   IStream* _up;
   IStream* _down;
public:
   PineScriptRSIUpDownStream(IStream* up, IStream* down)
   {
      _up = up;
      _up.AddRef();
      _down = down;
      _down.AddRef();
   }
   ~PineScriptRSIUpDownStream()
   {
      _up.Release();
      _down.Release();
   }
   
   virtual int Size()
   {
      return _up.Size();
   }
   
   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period - i, value))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
   
   bool GetValue(const int period, double &val)
   {
      double up[1];
      double down[1];
      if (!_up.GetValues(period, 1, up) || !_down.GetValues(period, 1, down))
      {
         return false;
      }
      if (down[0] == 0)
      {
         val = 0;
         return true;
      }
      double rs = up[0] / down[0];
      val = 100 - 100.0 / (1.0 + rs);
      return true;
   }
};

class RSIStream : public AStreamBase
{
   IStream* _impl;
public:
   RSIStream(IStream* stream, int period)
   {
      _impl = new RSISimpleStream(stream, period);
   }

   RSIStream(IStream* up, IStream* down)
   {
      _impl = new PineScriptRSIUpDownStream(up, down);
   }

   ~RSIStream()
   {
      _impl.Release();
   }
   
   virtual int Size()
   {
      return _impl.Size();
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      return _impl.GetValues(period, count, val);
   }
};

#endif
// Colored fill v1.1


#ifndef ColoredFill_IMP
#define ColoredFill_IMP
class ColoredFill
{
   double p1[];
   double p2[];
   int colorsCount;
   color upColor;
   color dnColor;
   int streamIndex;
   double top;
   double bottom;
public:
   ColoredFill(int streamIndex)
   {
      this.streamIndex = streamIndex;
      colorsCount = 0;
      top = EMPTY_VALUE;
      bottom = EMPTY_VALUE;
   }
   void Init()
   {
      ArrayInitialize(p1, 0);
      ArrayInitialize(p2, 0);
   }
   
   void SetTopBottom(double top, double bottom)
   {
      this.top = top;
      this.bottom = bottom;
   }
   
   void AddColor(uint clr)
   {
      int transp = GetTranparency(clr);
      if (transp == 100)
      {
         return;
      }
      clr = GetColorOnly(clr);
      dnColor = colorsCount == 0 ? clr : upColor;
      upColor = clr;
      colorsCount++;
   }
   void AddColor(double clr)
   {
      if (clr == EMPTY_VALUE)
      {
         return;
      }
      AddColor((uint)clr);
   }
   int RegisterStreams(int id)
   {
      SetIndexBuffer(id, p1, INDICATOR_DATA);
      SetIndexBuffer(id + 1, p2, INDICATOR_DATA);
      PlotIndexSetInteger(streamIndex, PLOT_SHIFT, 0);
      PlotIndexSetInteger(streamIndex, PLOT_COLOR_INDEXES, 2);
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 0, upColor); 
      PlotIndexSetInteger(streamIndex, PLOT_LINE_COLOR, 1, dnColor);
      return id + 2;
   }
   
   void Set(int period, double value1, double value2, uint clr)
   {
      int transp = GetTranparency(clr);
      if (clr == EMPTY_VALUE || value1 == EMPTY_VALUE || value2 == EMPTY_VALUE || transp == 100)
      {
         p1[period] = 0;
         p2[period] = 0;
         return;
      }
      value1 = LimitValue(value1);
      value2 = LimitValue(value2);
      if (upColor == clr)
      {
         p1[period] = MathMin(value1, value2);
         p2[period] = MathMax(value1, value2);
         return;
      }
      p1[period] = MathMax(value1, value2);
      p2[period] = MathMin(value1, value2);
   }
private:
   double LimitValue(double value)
   {
      if (top == EMPTY_VALUE || bottom == EMPTY_VALUE)
      {
         return value;
      }
      if (value > top)
      {
         return top;
      }
      if (value < bottom)
      {
         return bottom;
      }
      return value;
   }   
};
#endif
// Pivot low stream v1.0





// Simple price stream v1.0
class SimplePriceStream : public AStream
{
   PriceType _price;
   double _pipSize;
public:
   SimplePriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
      :AStream(symbol, timeframe)
   {
      _price = __price;

      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      int mult = digit == 3 || digit == 5 ? 10 : 1;
      _pipSize = point * mult;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         switch (_price)
         {
            case PriceClose:
               val[i] = iClose(_symbol, _timeframe, period + i);
               break;
            case PriceOpen:
               val[i] = iOpen(_symbol, _timeframe, period + i);
               break;
            case PriceHigh:
               val[i] = iHigh(_symbol, _timeframe, period + i);
               break;
            case PriceLow:
               val[i] = iLow(_symbol, _timeframe, period + i);
               break;
            case PriceMedian:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i)) / 2.0;
               break;
            case PriceTypical:
               val[i] = (iHigh(_symbol, _timeframe, period + i) + iLow(_symbol, _timeframe, period + i) + iClose(_symbol, _timeframe, period + i)) / 3.0;
               break;
            case PriceWeighted:
               val[i] = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) * 2) / 4.0;
               break;
            case PriceMedianBody:
               val[i] = (iOpen(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 2.0;
               break;
            case PriceAverage:
               val[i] = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) + iOpen(_symbol, _timeframe, period)) / 4.0;
               break;
            case PriceTrendBiased:
               {
                  double close = iClose(_symbol, _timeframe, period);
                  if (iOpen(_symbol, _timeframe, period) > iClose(_symbol, _timeframe, period))
                     val[i] = (iHigh(_symbol, _timeframe, period) + close) / 2.0;
                  else
                     val[i] = (iLow(_symbol, _timeframe, period) + close) / 2.0;
               }
               break;
            case PriceVolume:
               val[i] = (double)iVolume(_symbol, _timeframe, period);
               break;
         }
         val[i] += _shift * _pipSize;
      }
      return true;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};


class PivotLowStream : public AOnStream
{
   int _leftBars;
   int _rightBars;
public:
   PivotLowStream(IStream *source, int leftBars, int rightBars)
      :AOnStream(source)
   {
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   PivotLowStream(string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
      :AOnStream(NULL)
   {
      _source = new SimplePriceStream(symbol, timeframe, PriceLow);
      _leftBars = leftBars;
      _rightBars = rightBars;
   }
   
   static bool GetValues(const int period, const int count, double &val[], string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceLow);
      bool result = GetValues(period, count, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }
   
   static bool GetValues(const int period, const int count, double &val[], IStream* source, int leftBars, int rightBars)
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, source, leftBars, rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }

   static bool GetValue(const int period, double &val, IStream* source, int leftBars, int rightBars)
   {
      double center[1];
      if (!source.GetValues(period - rightBars, 1, center))
      {
         return false;
      }
      double value[1];
      for (int i = 0; i < rightBars; ++i)
      {
         if (!source.GetValues(period - i, 1, value))
         {
            return false;
         }
         if (center[0] > value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < leftBars; ++ii)
      {
         if (!source.GetValues(period - ii - rightBars, 1, value))
         {
            return false;
         }
         if (center[0] > value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center[0];
      return true;
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, _source, _leftBars, _rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
};
// Pivot high stream v1.0





class PivotHighStream : public AOnStream
{
   int _leftBars;
   int _rightBars;
public:
   PivotHighStream(IStream *source, int leftBars, int rightBars)
      :AOnStream(source)
   {
      _leftBars = leftBars;
      _rightBars = rightBars;
   }

   PivotHighStream(string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
      :AOnStream(NULL)
   {
      _source = new SimplePriceStream(symbol, timeframe, PriceHigh);
      _leftBars = leftBars;
      _rightBars = rightBars;
   }
   
      
   static bool GetValues(const int period, const int count, double &val[], string symbol, ENUM_TIMEFRAMES timeframe, int leftBars, int rightBars)
   {
      SimplePriceStream* stream = new SimplePriceStream(symbol, timeframe, PriceHigh);
      bool result = GetValues(period, count, val, stream, leftBars, rightBars);
      stream.Release();
      return result;
   }
   
   static bool GetValues(const int period, const int count, double &val[], IStream* source, int leftBars, int rightBars)
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, source, leftBars, rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }

   static bool GetValue(const int period, double &val, IStream* source, int leftBars, int rightBars)
   {
      double center[1];
      if (!source.GetValues(period - rightBars, 1, center))
      {
         return false;
      }
      double value[1];
      for (int i = 0; i < rightBars; ++i)
      {
         if (!source.GetValues(period - i, 1, value))
         {
            return false;
         }
         if (center[0] < value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      for (int ii = 0; ii < leftBars; ++ii)
      {
         if (!source.GetValues(period - ii - rightBars, 1, value))
         {
            return false;
         }
         if (center[0] < value[0])
         {
            val = EMPTY_VALUE;
            return true;
         }
      }
      val = center[0];
      return true;
   }

   bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double value;
         if (!GetValue(period, value, _source, _leftBars, _rightBars))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
};
// Pine-script like safe operations
// v1.1

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
      return EMPTY_VALUE;
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

double SafeMathMin(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(left, right);
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
      return EMPTY_VALUE;
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
// Value when stream (condition as a parameter) v1.0


// ICondition v3.0

#ifndef ICondition_IMP
#define ICondition_IMP
interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};
#endif

class ValueWhenSimpleStream : public AStream
{
   datetime _periods[];
   double _values[];
   int _shift;
public:
   double _stream[];

   ValueWhenSimpleStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int shift)
      :AStream(symbol, timeframe)
   {
      _shift = shift;
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _stream, INDICATOR_CALCULATIONS);
      return id + 1;
   }

   double Update(const int period, datetime date, bool condition, double val)
   {
      if (condition)
      {
         int size = ArraySize(_periods);
         if (size == 0 || _periods[size - 1] != date)
         {
            ArrayResize(_periods, size + 1);
            ArrayResize(_values, size + 1);
            _values[size] = val;
            _periods[size] = date;
            ++size;
         }
         else
         {
            _values[size - 1] = val;
         }
         if (size - 1 - _shift >= 0)
         {
            _stream[period] = _values[size - 1 - _shift];
         }
         else
         {
            _stream[period] = EMPTY_VALUE;
         }
      }
      else if (period > 0)
      {
         _stream[period] = _stream[period - 1];
      }
      return _stream[period];
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; i++)
      {
         if (_stream[period - i] == EMPTY_VALUE)
         {
            return false;
         }
         val[i] = _stream[period - i];
      }
      return true;
   }
};
#ifndef BoolStream_IMPL
#define BoolStream_IMPL

// Abstract boolean stream v1.0

#ifndef ABoolStream_IMPL
#define ABoolStream_IMPL
// Boolean Stream v.1.0

#ifndef IBoolStream_IMPL
#define IBoolStream_IMPL

interface IBoolStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValues(const int period, const int count, bool &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, bool &val[]) = 0;
};

#endif

class ABoolStream : public IBoolStream
{
   int _refs;   
public:
   ABoolStream()
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
// Bool stream v2.0

class BoolStream : public ABoolStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _stream[];
public:
   BoolStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
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
      return Bars(_symbol, _timeframe);
   }

   void SetValue(const int period, bool value)
   {
      int totalBars = Size();
      if (period < 0 || totalBars <= period)
      {
         return;
      }
      EnsureStreamHasProperSize(totalBars);
      _stream[period] = value;
   }

   virtual bool GetValues(const int period, const int count, bool &val[])
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
         if (val[i] == EMPTY_VALUE)
         {
            return false;
         }
      }
      return true;
   }
   
   virtual bool GetSeriesValues(const int period, const int count, bool &val[])
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
            _stream[i] = EMPTY_VALUE;
         }
      }
   }
};

#endif
#ifndef BarsSinceStreamV2_IMPL
#define BarsSinceStreamV2_IMPL

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


// Counts number of bars since last condition.
// v1.0

class BarsSinceStreamV2 : public AIntStream
{
   IBoolStream* _condition;
   int _bars[];
public:
   BarsSinceStreamV2(IBoolStream* condition)
   {
      _condition = condition;
      _condition.AddRef();
   }

   ~BarsSinceStreamV2()
   {
      _condition.Release();
   }

   int Size()
   {
      return _condition.Size();
   }

   virtual bool GetSeriesValues(const int period, const int count, int &val[])
   {
      return GetValues(Size() - period - 1, count, val);
   }
   virtual bool GetValues(const int period, const int count, int &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         int value;
         if (!GetValue(period - i, value))
         {
            return false;
         }
         val[i] = value;
      }
      return true;
   }
   virtual bool GetValue(const int period, int &val)
   {
      int size = Size();
      if (period >= size)
      {
         return false;
      }
      int currentBufferSize = ArrayRange(_bars, 0);
      if (currentBufferSize != size) 
      {
         ArrayResize(_bars, size);
         for (int i = currentBufferSize; i < size; ++i)
         {
            _bars[i] = (int)EMPTY_VALUE;
         }
      }
      if (_bars[period] == (int)EMPTY_VALUE)
      {
         FillHistory(period);
      }
      val = _bars[period];
      return true;
   }
private:
   void FillHistory(int period)
   {
      int size = Size();
      for (int periodIndex = period; periodIndex > 0; --periodIndex)
      {
         bool val[1];
         if (_condition.GetValues(periodIndex, 1, val) && val[0] == true)
         {
            _bars[periodIndex] = 0;
            for (int ii = periodIndex + 1; ii <= period; ++ii)
            {
               _bars[ii] = _bars[ii - 1] + 1;
            }
            return;
         }
      }
   }
};
#endif
// Colored plor v1.0


class ColoredPlot
{
   int plotIndex;
   double values[];
   double colors[];
   double buffer[];
   
   uint initColors[];
   int offset;
public:
   ColoredPlot(int plotIndex)
   {
      this.plotIndex = plotIndex;
      offset = INT_MIN;
   }
   
   void AddColor(uint clr)
   {
      int transp = GetTranparency(clr);
      if (transp == 100)
      {
         return;
      }
      int colorsCount = ArraySize(initColors);
      ArrayResize(initColors, colorsCount + 1);
      initColors[colorsCount] = GetColorOnly(clr);
   }
   
   void SetOffset(int offset)
   {
      this.offset = offset;
   }
   
   int RegisterStreams(int id)
   {
      SetIndexBuffer(id, values, INDICATOR_DATA);
      int colorsCount = ArraySize(initColors);
      PlotIndexSetInteger(plotIndex, PLOT_COLOR_INDEXES, colorsCount);
      for (int i = 0; i < colorsCount; ++i)
      {
         PlotIndexSetInteger(plotIndex, PLOT_LINE_COLOR, i, initColors[i]);
      }
      if (offset != INT_MIN)
      {
         PlotIndexSetInteger(plotIndex, PLOT_SHIFT, offset);
      }
      id += 1;
      SetIndexBuffer(id++, colors, INDICATOR_COLOR_INDEX);
      return id;
   }
   int RegisterInternalStreams(int id)
   {
      SetIndexBuffer(id++, buffer, INDICATOR_CALCULATIONS);
      return id;
   }
   
   void Init()
   {
      ArrayInitialize(values, EMPTY_VALUE);
      ArrayInitialize(colors, EMPTY_VALUE);
      ArrayInitialize(buffer, EMPTY_VALUE);
   }
   
   void Set(int pos, double value, uint clr)
   {
      int transp = GetTranparency(clr);
      buffer[pos] = value;
      values[pos] = value;
      colors[pos] = FindColorIndex(clr);
      if (value == EMPTY_VALUE)
      {
         values[pos] = EMPTY_VALUE;
         colors[pos] = EMPTY_VALUE;
         buffer[pos] = EMPTY_VALUE;
         return;
      }
      int prevValueIndex = FindPrevValueIndex(pos);
      if (prevValueIndex == -1)
      {
         return;
      }
      int length = pos - prevValueIndex + 1;
      if (colors[pos] == -1)
      {
         for (int i = 1; i < length; ++i)
         {
            values[prevValueIndex + i] = EMPTY_VALUE;
            colors[prevValueIndex + i] = EMPTY_VALUE;
         }
         return;
      }
      double diff = buffer[pos] - buffer[prevValueIndex];
      double step = diff / (length - 1);
      for (int i = 0; i < length; ++i)
      {
         values[prevValueIndex + i] = buffer[prevValueIndex] + step * i;
         colors[prevValueIndex + i] = colors[pos];
      }
   }
private:
   int FindPrevValueIndex(int pos)
   {
      for (int i = pos - 1; i >= 0; --i)
      {
         if (buffer[i] != EMPTY_VALUE)
         {
            return i;
         }
      }
      return -1;
   }
   int FindColorIndex(uint clr)
   {
      int transp = GetTranparency(clr);
      if (transp == 100)
      {
         return -1;
      }
      color searchingColor = GetColorOnly(clr);
      int colorsCount = ArraySize(initColors);
      for (int i = 0; i < colorsCount; ++i)
      {
         if (initColors[i] == searchingColor)
         {
            return i;
         }
      }
      return -1;
   }
};
//Signaler v5.0
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start external program
input string   program_path             = ""; // Path to the external program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key
input string   advanced_server          = "https://profitrobots.com"; // Advanced alert server url
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

#ifdef ADVANCED_ALERTS
// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
void AdvancedAlertCustom(string key, string text, string instrument, string timeframe, string url);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import
#endif

enum SignalerFrequency
{
   SignalsAll,
   SignalsOncePerBarClose,
   SignalsOncePerBar
};

class Signaler
{
   string _prefix;
   SignalerFrequency _frequency;
   datetime _lastSignal;
public:
   Signaler(string frequency)
   {
      if (frequency == "all")
      {
         _frequency = SignalsAll;
      }
      else if (frequency == "once_per_bar_close")
      {
         _frequency = SignalsOncePerBarClose;
      }
      else if (frequency == "once_per_bar")
      {
         _frequency = SignalsOncePerBar;
      }
      _lastSignal = 0;
   }
   Signaler()
   {
      _lastSignal = 0;
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   void Alert(string message, int position, datetime time)
   {
      if (position != 0)
      {
         return;
      }
      if (_frequency != SignalsAll)
      {
         if (_lastSignal == time)
         {
            return;
         }
      }
      _lastSignal = time;
      SendNotifications("", message);
   }

   void SendNotifications(const string subject, string message = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;

#ifdef ADVANCED_ALERTS
      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
#endif
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
#ifdef ADVANCED_ALERTS
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlertCustom(advanced_key, message, "", "", advanced_server);
#endif
   }
};

input int param1 = 14; // RSI Period
input PriceType param2 = PriceClose; // RSI Source
input int param3 = 5; // Pivot Lookback Right
input int param4 = 5; // Pivot Lookback Left
input int param5 = 60; // Max of Lookback Range
input int param6 = 5; // Min of Lookback Range
input bool param7 = true; // Plot Bullish
input bool param8 = false; // Plot Hidden Bullish
input bool param9 = true; // Plot Bearish
input bool param10 = false; // Plot Hidden Bearish
input int bars_limit = 1000; // Bars limit
int len;
IStream* param2Stream;
IStream* src;
int lbR;
int lbL;
int rangeUpper;
int rangeLower;
bool plotBull;
bool plotHiddenBull;
bool plotBear;
bool plotHiddenBear;
FloatStream* rsi1X;
RSIStream* rsi1;
double plot1[];
double plot2[];
double plot3[];
double plot4[];
ColoredFill* fill5;
FloatStream* lowestpivot1Source;
FloatStream* highestpivot1Source;
double osc[];
ValueWhenSimpleStream* valuewhen1;
class _inRange_bSStream
{
   IBoolStream* cond;
   BoolStream* barssince1Condition;
   BarsSinceStreamV2* barssince1;
   bool _initialized;
public:
   _inRange_bSStream(IBoolStream* cond)
   {
      _initialized = false;
      this.cond = cond;
      cond.AddRef();
      barssince1Condition = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
      barssince1 = new BarsSinceStreamV2(barssince1Condition);
   }
   ~_inRange_bSStream()
   {
      cond.Release();
      barssince1Condition.Release();
      barssince1.Release();
   }
   int Init(int id)
   {
      return id;
   }
   void Clear()
   {
      _initialized = false;
   }
   bool GetValue(const int pos, const int oldPos, bool &__out1)
   {
      if (!_initialized)
      {
         barssince1Condition.Init();
         _initialized = true;
      }
      bool condValue[1];
      if (!cond.GetValues(pos, 1, condValue)) { condValue[0] = EMPTY_VALUE; }
      barssince1Condition.SetValue(pos, (condValue[0] == true));
      int barssince1Value[1];
      if (!barssince1.GetValues(pos, 1, barssince1Value)) { barssince1Value[0] = EMPTY_VALUE; }
      int bars = barssince1Value[0];
      __out1 = SafeLE(rangeLower, bars) && SafeLE(bars, rangeUpper);
      return true;
   }
};
double plFound[];
BoolStream* _inRange_bS1_param1;
_inRange_bSStream* _inRange_bS1;
ValueWhenSimpleStream* valuewhen2;
ColoredPlot* plot6;
double plot7[];
ValueWhenSimpleStream* valuewhen3;
BoolStream* _inRange_bS2_param1;
_inRange_bSStream* _inRange_bS2;
ValueWhenSimpleStream* valuewhen4;
ColoredPlot* plot8;
double plot9[];
ValueWhenSimpleStream* valuewhen5;
double phFound[];
BoolStream* _inRange_bS3_param1;
_inRange_bSStream* _inRange_bS3;
ValueWhenSimpleStream* valuewhen6;
ColoredPlot* plot10;
double plot11[];
ValueWhenSimpleStream* valuewhen7;
BoolStream* _inRange_bS4_param1;
_inRange_bSStream* _inRange_bS4;
ValueWhenSimpleStream* valuewhen8;
ColoredPlot* plot12;
double plot13[];
Signaler* _signaler;

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
   int id = 0;
   len = param1;
   param2Stream = PriceStreamFactory::Create(_Symbol, (ENUM_TIMEFRAMES)_Period, param2);
   src = param2Stream;
   lbR = param3;
   lbL = param4;
   rangeUpper = param5;
   rangeLower = param6;
   plotBull = param7;
   plotHiddenBull = param8;
   plotBear = param9;
   plotHiddenBear = param10;
   rsi1X = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   rsi1 = new RSIStream(rsi1X, len);
   SetIndexBuffer(id++, plot1, INDICATOR_DATA);
   SetIndexBuffer(id, plot2, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, 0x867B78);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(id++, PLOT_LINE_STYLE, STYLE_DOT);
   SetIndexBuffer(id, plot3, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, 0x867B78);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(id++, PLOT_LINE_STYLE, STYLE_DOT);
   SetIndexBuffer(id, plot4, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, 0x867B78);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(id++, PLOT_LINE_STYLE, STYLE_DOT);
   fill5 = new ColoredFill(4);
   fill5.AddColor(ColorRGB(33, 150, 243, 90));
   id = fill5.RegisterStreams(id);
   lowestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   highestpivot1Source = new FloatStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   plot6 = new ColoredPlot(5);
   plot6.AddColor(Green);
   plot6.AddColor(AddTransparency(White, 100));
   plot6.SetOffset((-lbR));
   id = plot6.RegisterStreams(id);
   SetIndexBuffer(id, plot7, INDICATOR_DATA);
   PlotIndexSetInteger(7, PLOT_SHIFT, (-lbR));
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, Green);
   PlotIndexSetInteger(id, PLOT_ARROW, 241);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   plot8 = new ColoredPlot(7);
   plot8.AddColor(AddTransparency(Green, 80));
   plot8.AddColor(AddTransparency(White, 100));
   plot8.SetOffset((-lbR));
   id = plot8.RegisterStreams(id);
   SetIndexBuffer(id, plot9, INDICATOR_DATA);
   PlotIndexSetInteger(9, PLOT_SHIFT, (-lbR));
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, Green);
   PlotIndexSetInteger(id, PLOT_ARROW, 241);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   plot10 = new ColoredPlot(9);
   plot10.AddColor(Red);
   plot10.AddColor(AddTransparency(White, 100));
   plot10.SetOffset((-lbR));
   id = plot10.RegisterStreams(id);
   SetIndexBuffer(id, plot11, INDICATOR_DATA);
   PlotIndexSetInteger(11, PLOT_SHIFT, (-lbR));
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, Red);
   PlotIndexSetInteger(id, PLOT_ARROW, 242);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   plot12 = new ColoredPlot(11);
   plot12.AddColor(AddTransparency(Red, 80));
   plot12.AddColor(AddTransparency(White, 100));
   plot12.SetOffset((-lbR));
   id = plot12.RegisterStreams(id);
   SetIndexBuffer(id, plot13, INDICATOR_DATA);
   PlotIndexSetInteger(13, PLOT_SHIFT, (-lbR));
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, Red);
   PlotIndexSetInteger(id, PLOT_ARROW, 242);
   PlotIndexSetInteger(id++, PLOT_ARROW_SHIFT, 5);
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorSetString(INDICATOR_SHORTNAME, "RSI Divergence Indicator");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   SetIndexBuffer(id++, osc, INDICATOR_CALCULATIONS);
   valuewhen1 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen1.RegisterInternalStream(id);
   SetIndexBuffer(id++, plFound, INDICATOR_CALCULATIONS);
   _inRange_bS1_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRange_bS1 = new _inRange_bSStream(_inRange_bS1_param1);
   id = _inRange_bS1.Init(id);
   valuewhen2 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen2.RegisterInternalStream(id);
   id = plot6.RegisterInternalStreams(id);
   valuewhen3 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen3.RegisterInternalStream(id);
   _inRange_bS2_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRange_bS2 = new _inRange_bSStream(_inRange_bS2_param1);
   id = _inRange_bS2.Init(id);
   valuewhen4 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen4.RegisterInternalStream(id);
   id = plot8.RegisterInternalStreams(id);
   valuewhen5 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen5.RegisterInternalStream(id);
   SetIndexBuffer(id++, phFound, INDICATOR_CALCULATIONS);
   _inRange_bS3_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRange_bS3 = new _inRange_bSStream(_inRange_bS3_param1);
   id = _inRange_bS3.Init(id);
   valuewhen6 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen6.RegisterInternalStream(id);
   id = plot10.RegisterInternalStreams(id);
   valuewhen7 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen7.RegisterInternalStream(id);
   _inRange_bS4_param1 = new BoolStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _inRange_bS4 = new _inRange_bSStream(_inRange_bS4_param1);
   id = _inRange_bS4.Init(id);
   valuewhen8 = new ValueWhenSimpleStream(_Symbol, (ENUM_TIMEFRAMES)_Period, 1);
   id = valuewhen8.RegisterInternalStream(id);
   id = plot12.RegisterInternalStreams(id);
   _signaler = new Signaler();
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   param2Stream.Release();
   rsi1X.Release();
   rsi1.Release();
   delete fill5;
   lowestpivot1Source.Release();
   highestpivot1Source.Release();
   valuewhen1.Release();
   _inRange_bS1_param1.Release();
   delete _inRange_bS1;
   valuewhen2.Release();
   delete plot6;
   valuewhen3.Release();
   _inRange_bS2_param1.Release();
   delete _inRange_bS2;
   valuewhen4.Release();
   delete plot8;
   valuewhen5.Release();
   _inRange_bS3_param1.Release();
   delete _inRange_bS3;
   valuewhen6.Release();
   delete plot10;
   valuewhen7.Release();
   _inRange_bS4_param1.Release();
   delete _inRange_bS4;
   valuewhen8.Release();
   delete plot12;
   delete _signaler;
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
      rsi1X.Init();
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, 50);
      ArrayInitialize(plot3, 70);
      ArrayInitialize(plot4, 30);
      fill5.Init();
      lowestpivot1Source.Init();
      highestpivot1Source.Init();
      ArrayInitialize(osc, EMPTY_VALUE);
      ArrayInitialize(plFound, EMPTY_VALUE);
      _inRange_bS1_param1.Init();
      _inRange_bS1.Clear();
      plot6.Init();
      ArrayInitialize(plot7, EMPTY_VALUE);
      _inRange_bS2_param1.Init();
      _inRange_bS2.Clear();
      plot8.Init();
      ArrayInitialize(plot9, EMPTY_VALUE);
      ArrayInitialize(phFound, EMPTY_VALUE);
      _inRange_bS3_param1.Init();
      _inRange_bS3.Clear();
      plot10.Init();
      ArrayInitialize(plot11, EMPTY_VALUE);
      _inRange_bS4_param1.Init();
      _inRange_bS4.Clear();
      plot12.Init();
      ArrayInitialize(plot13, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      uint bearColor = Red;
      uint bullColor = Green;
      uint hiddenBullColor = AddTransparency(Green, 80);
      uint hiddenBearColor = AddTransparency(Red, 80);
      uint textColor = White;
      uint noneColor = AddTransparency(White, 100);
      double srcValue[1];
      if (!src.GetValues(pos, 1, srcValue)) { srcValue[0] = EMPTY_VALUE; }
      rsi1X.SetValue(pos, srcValue[0]);
      double rsi1Value[1];
      if (!rsi1.GetValues(pos, 1, rsi1Value)) { rsi1Value[0] = EMPTY_VALUE; }
      osc[pos] = rsi1Value[0];
      plot1[pos] = osc[pos];
      double obLevel = plot3[pos];
      double osLevel = plot4[pos];
      fill5.Set(pos, obLevel, osLevel, ColorRGB(33, 150, 243, 90));
      lowestpivot1Source.SetValue(pos, osc[pos]);
      double lowestpivot1Value[1];
      if (!PivotLowStream::GetValues(pos, 1, lowestpivot1Value, lowestpivot1Source, lbL, lbR)) { lowestpivot1Value[0] = EMPTY_VALUE; }
      plFound[pos] = (((lowestpivot1Value[0]) == EMPTY_VALUE) ? false : true);
      highestpivot1Source.SetValue(pos, osc[pos]);
      double highestpivot1Value[1];
      if (!PivotHighStream::GetValues(pos, 1, highestpivot1Value, highestpivot1Source, lbL, lbR)) { highestpivot1Value[0] = EMPTY_VALUE; }
      phFound[pos] = (((highestpivot1Value[0]) == EMPTY_VALUE) ? false : true);
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      _inRange_bS1_param1.SetValue(pos, plFound[pos - 1]);
      bool _inRange_bS1Value;
      if (!_inRange_bS1.GetValue(pos, oldPos, _inRange_bS1Value)) { _inRange_bS1Value = EMPTY_VALUE; }
      bool oscHL = SafeGreater(osc[pos - lbR], valuewhen1.Update(pos, time[pos], plFound[pos], osc[pos - lbR])) && _inRange_bS1Value;
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      bool priceLL = SafeLess(low[pos - lbR], valuewhen2.Update(pos, time[pos], plFound[pos], low[pos - lbR]));
      bool bullCondAlert = priceLL && oscHL && plFound[pos];
      bool bullCond = plotBull && bullCondAlert;
      if (pos - lbR < 0) { continue; }
      plot6.Set(pos, (plFound[pos] ? osc[pos - lbR] : EMPTY_VALUE), ((bullCond ? bullColor : noneColor)));
      if (pos - lbR < 0) { continue; }
      plot7[pos] = (bullCond ? osc[pos - lbR] : EMPTY_VALUE);
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      _inRange_bS2_param1.SetValue(pos, plFound[pos - 1]);
      bool _inRange_bS2Value;
      if (!_inRange_bS2.GetValue(pos, oldPos, _inRange_bS2Value)) { _inRange_bS2Value = EMPTY_VALUE; }
      bool oscLL = SafeLess(osc[pos - lbR], valuewhen3.Update(pos, time[pos], plFound[pos], osc[pos - lbR])) && _inRange_bS2Value;
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      bool priceHL = SafeGreater(low[pos - lbR], valuewhen4.Update(pos, time[pos], plFound[pos], low[pos - lbR]));
      bool hiddenBullCondAlert = priceHL && oscLL && plFound[pos];
      bool hiddenBullCond = plotHiddenBull && hiddenBullCondAlert;
      if (pos - lbR < 0) { continue; }
      plot8.Set(pos, (plFound[pos] ? osc[pos - lbR] : EMPTY_VALUE), ((hiddenBullCond ? hiddenBullColor : noneColor)));
      if (pos - lbR < 0) { continue; }
      plot9[pos] = (hiddenBullCond ? osc[pos - lbR] : EMPTY_VALUE);
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      _inRange_bS3_param1.SetValue(pos, phFound[pos - 1]);
      bool _inRange_bS3Value;
      if (!_inRange_bS3.GetValue(pos, oldPos, _inRange_bS3Value)) { _inRange_bS3Value = EMPTY_VALUE; }
      bool oscLH = SafeLess(osc[pos - lbR], valuewhen5.Update(pos, time[pos], phFound[pos], osc[pos - lbR])) && _inRange_bS3Value;
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      bool priceHH = SafeGreater(high[pos - lbR], valuewhen6.Update(pos, time[pos], phFound[pos], high[pos - lbR]));
      bool bearCondAlert = priceHH && oscLH && phFound[pos];
      bool bearCond = plotBear && bearCondAlert;
      if (pos - lbR < 0) { continue; }
      plot10.Set(pos, (phFound[pos] ? osc[pos - lbR] : EMPTY_VALUE), ((bearCond ? bearColor : noneColor)));
      if (pos - lbR < 0) { continue; }
      plot11[pos] = (bearCond ? osc[pos - lbR] : EMPTY_VALUE);
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      if (pos - 1 < 0) { continue; }
      _inRange_bS4_param1.SetValue(pos, phFound[pos - 1]);
      bool _inRange_bS4Value;
      if (!_inRange_bS4.GetValue(pos, oldPos, _inRange_bS4Value)) { _inRange_bS4Value = EMPTY_VALUE; }
      bool oscHH = SafeGreater(osc[pos - lbR], valuewhen7.Update(pos, time[pos], phFound[pos], osc[pos - lbR])) && _inRange_bS4Value;
      if (pos - lbR < 0) { continue; }
      if (pos - lbR < 0) { continue; }
      bool priceLH = SafeLess(high[pos - lbR], valuewhen8.Update(pos, time[pos], phFound[pos], high[pos - lbR]));
      bool hiddenBearCondAlert = priceLH && oscHH && phFound[pos];
      bool hiddenBearCond = plotHiddenBear && hiddenBearCondAlert;
      if (pos - lbR < 0) { continue; }
      plot12.Set(pos, (phFound[pos] ? osc[pos - lbR] : EMPTY_VALUE), ((hiddenBearCond ? hiddenBearColor : noneColor)));
      if (pos - lbR < 0) { continue; }
      plot13[pos] = (hiddenBearCond ? osc[pos - lbR] : EMPTY_VALUE);
      if (bullCondAlert) { _signaler.SendNotifications("Regular Bullish Divergence", "Found a new Regular Bullish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar"); }
      if (hiddenBullCondAlert) { _signaler.SendNotifications("Hidden Bullish Divergence", "Found a new Hidden Bullish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar"); }
      if (bearCondAlert) { _signaler.SendNotifications("Regular Bearish Divergence", "Found a new Regular Bearish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar"); }
      if (hiddenBearCondAlert) { _signaler.SendNotifications("Hidden Bearisn Divergence", "Found a new Hidden Bearisn Divergence, `Pivot Lookback Right` number of bars to the left of the current bar"); }
   }
   return rates_total;
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 