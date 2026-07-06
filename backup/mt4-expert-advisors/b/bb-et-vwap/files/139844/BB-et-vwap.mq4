// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70746

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

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 White
#property indicator_color2 Lime
#property indicator_color3 Tomato
#property indicator_color4 White
#property indicator_color5 Blue
#property indicator_width1 1
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 3
#property indicator_width5 3
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_plots 6
#property indicator_color6 White
#property indicator_width6 2
#property strict

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

#ifndef MATypes_IMP
#define MATypes_IMP

enum MATypes
{
   ma_sma,     // Simple moving average - SMA
   ma_ema,     // Exponential moving average - EMA
   //ma_dsema,   // Double smoothed exponential moving average - DSEMA
   //ma_dema,    // Double exponential moving average - DEMA
   ma_tema,    // Tripple exponential moving average - TEMA
   //ma_smma,    // Smoothed moving average - SMMA
   ma_lwma,    // Linear weighted moving average - LWMA
   //ma_pwma,    // Parabolic weighted moving average - PWMA
   //ma_alxma,   // Alexander moving average - ALXMA
   ma_vwma,    // Volume weighted moving average - VWMA
   //ma_hull,    // Hull moving average
   //ma_tma,     // Triangular moving average
   //ma_sine,    // Sine weighted moving average
   //ma_linr,    // Linear regression value
   //ma_ie2,     // IE/2
   //ma_nlma,    // Non lag moving average
   ma_zlma,    // Zero lag moving average
   //ma_lead,    // Leader exponential moving average
   //ma_ssm,     // Super smoother
   //ma_smoo,     // Smoother,
   ma_zltema, // Zero lag TEMA
   ma_rma, // RMA
   ma_jsavg // JSAverage
};

#endif

//---- input parameters
input int eintBandsPeriod = 20;
input double edblBandsDev = 2.0;
input MATypes eintMAMode = ma_sma;
input PriceType eintMAPrice = PriceClose;
input int eintMAShift = 0;
input int eintBarsBack = 1;
input bool UseSound=true;
input bool AlertSound=true;
input string SoundFileBuy ="alert2.wav";
input string SoundFileSell="email.wav";
input bool SendMailPossible = false;
input int SIGNAL_BAR =  1 ; 
bool SoundBuy  = False;
bool SoundSell = False;


//---- indicator buffers
double gadblMid[];
double gadblUpper[];
double gadblLower[];
double gadblDiv[];
double gadblDiv2[];
//******************************************************************************************************************************************************

// ajout vwap bande

input int N = 20; // Period of Volume Weight Average Price
input int Shift = 0;
input ENUM_APPLIED_PRICE Price_Type = PRICE_CLOSE; // Price Type
input double DeviationBand1 = 1; // Number of StdDevs for the 1st band
input double DeviationBand2 = 2; // Number of StdDevs for the 2nd band
input double DeviationBand3 = 2.5; // Number of StdDevs for the 3rd band
input string note_10 = "";                         //Button
input bool btn_show = true;                       //__ show
input string btn_pressed = "VWAP";                 //__ text
input int btn_offset_x = 10;                       //__ x
input int btn_offset_y = 20;                       //__ y
input int btn_width = 50;                          //__ width
input int btn_height = 20;                         //__ height
input int btn_font_size = 10;                      //__ font size
input color btn_font_clr = clrBlack;               //__ font color
input color btn_bg_color = clrGray;                //__ bg color
input color btn_border_clr = clrWhiteSmoke;        //__ border color

input int button_x = 20;
input int button_y = 30;

//Visibility controller v1.3
class VisibilityCotroller
{
   string buttonId;
   string visibilityId;
   bool show_data;
   bool recalc;
public:
   void Init(string id, string indicatorName, string caption, int x, int y)
   {
      recalc = false;
      visibilityId = indicatorName + "_visibility";
      double val;
      if (GlobalVariableGet(visibilityId, val))
         show_data = val != 0;
         
      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, caption, 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, x);
   }

   void DeInit()
   {
      ObjectDelete(ChartID(), buttonId);
   }

   bool HandleButtonClicks()
   {
      if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
      {
         ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
         show_data = !show_data;
         GlobalVariableSet(visibilityId, show_data ? 1.0 : 0.0);
         recalc = true;
         return true;
      }
      return false;
   }

   bool IsRecalcNeeded()
   {
      return recalc;
   }

   void ResetRecalc()
   {
      recalc = false;
   }

   bool IsVisible()
   {
      return show_data;
   }

private:
   void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
   {
      ObjectDelete(0,buttonID);
      ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString(0,buttonID,OBJPROP_FONT,font);
      ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,2);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
   }
};
VisibilityCotroller visibility;

// Indicator buffers
double ExtMapBuffer1[], UpperDev1[], LowerDev1[], UpperDev2[], LowerDev2[], UpperDev3[], LowerDev3[], ExtStdDevBuffer[];
// Price stream v2.0

#ifndef PriceStream_IMP
#define PriceStream_IMP
// Stream base v1.0

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
// IBarStream v2.1



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

   virtual void Refresh() = 0;
};
#endif


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

   bool GetValue(const int period, double &val)
   {
      switch (_price)
      {
         case PriceClose:
            if (!_source.GetClose(period, val))
            {
               return false;
            }
            break;
         case PriceOpen:
            if (!_source.GetOpen(period, val))
            {
               return false;
            }
            break;
         case PriceHigh:
            if (!_source.GetHigh(period, val))
            {
               return false;
            }
            break;
         case PriceLow:
            if (!_source.GetLow(period, val))
            {
               return false;
            }
            break;
         case PriceMedian:
            {
               double high, low;
               if (!_source.GetHighLow(period, high, low))
               {
                  return false;
               }
               val = (high + low) / 2.0;
            }
            break;
         case PriceTypical:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               val = (high + low + close) / 3.0;
            }
            break;
         case PriceWeighted:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               val = (high + low + close * 2) / 4.0;
            }
            break;
         case PriceMedianBody:
            {
               double open, close;
               if (!_source.GetOpenClose(period, open, close))
               {
                  return false;
               }
               val = (open + close) / 2.0;
            }
            break;
         case PriceAverage:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               val = (high + low + close + open) / 4.0;
            }
            break;
         case PriceTrendBiased:
            {
               double open, high, low, close;
               if (!_source.GetValues(period, open, high, low, close))
               {
                  return false;
               }
               if (open > close)
                  val = (high + close) / 2.0;
               else
                  val = (low + close) / 2.0;
            }
            break;
         // case PriceVolume:
         //    if (!_source.GetVolume(period, val))
         //    {
         //       return false;
         //    }
         //    break;
      }
      return true;
   }
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
#endif
// Averages stream factory v1.0





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

// SMA on stream v1.0

#ifndef SmaOnStream_IMP
#define SmaOnStream_IMP

class SmaOnStream : public AOnStream
{
   int _length;
   double _buffer[];
public:
   SmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);
      
      if (period > totalBars - _length)
         return false;

      int bufferIndex = totalBars - 1 - period;
      if (period > totalBars - _length && _buffer[bufferIndex - 1] != EMPTY_VALUE)
      {
         double current;
         double last;
         if (!_source.GetValue(period, current) || !_source.GetValue(period + _length, last))
            return false;
         _buffer[bufferIndex] = _buffer[bufferIndex - 1] + (current - last) / _length;
      }
      else 
      {
         _buffer[bufferIndex] = EMPTY_VALUE; 
         double summ = 0;
         for(int i = 0; i < _length; i++) 
         {
            double current;
            if (!_source.GetValue(period + i, current))
               return false;

           summ += current;
         }
         _buffer[bufferIndex] = summ / _length;
      }
      val = _buffer[bufferIndex];
      return true;
   }
};

class JsavgOnStream : public AOnStream
{
   int Alpha;
   int Alpha2;
   int Alpha12;
   double A1[];
   double A2[];
   double A3[];
   double A4[];
   double JSmooth[];
public:
   JsavgOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      Alpha = 0.45 * (length - 1.) / (0.45 * (length - 1) + 2);
      Alpha2 = Alpha * Alpha;
      Alpha12 = (1 - Alpha) * (1 - Alpha);
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (ArrayRange(A1, 0) != totalBars) 
      {
         ArrayResize(A1, totalBars);
         ArrayResize(A2, totalBars);
         ArrayResize(A3, totalBars);
         ArrayResize(A4, totalBars);
         ArrayResize(JSmooth, totalBars);
      }

      double price;
      if (!_source.GetValue(period, price) || period > totalBars - 1)
      {
         return false;
      }
      int bufferIndex = totalBars - 1 - period;

      A1[bufferIndex] = (1 - Alpha) * price + Alpha * A1[bufferIndex - 1];
      A2[bufferIndex] = (1 - Alpha) * (price - A1[bufferIndex]) + Alpha * A2[bufferIndex - 1];
      A3[bufferIndex] = A1[bufferIndex] + A2[bufferIndex];
      A4[bufferIndex] = (A3[bufferIndex] - JSmooth[bufferIndex - 1]) * Alpha12 + Alpha2 * A4[bufferIndex - 1];
      JSmooth[bufferIndex] = JSmooth[bufferIndex - 1] + A4[bufferIndex];
      val = JSmooth[bufferIndex];
      return true;
   }
};
#endif


// EMA on stream v1.0

#ifndef EMAOnStream_IMP
#define EMAOnStream_IMP

class EMAOnStream : public IStream
{
   IStream *_source;
   int _length;
   double _k;
   double _buffer[];
   int _references;
public:
   EMAOnStream(IStream *source, const int length)
   {
      _source = source;
      _source.AddRef();
      _length = length;
      _references = 1;
      _k = 2.0 / (_length + 1.0);
   }

   ~EMAOnStream()
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
      {
         delete &this;
      }
   }
   
   virtual int Size()
   {
      return _source.Size();
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = _source.Size();
      if (ArrayRange(_buffer, 0) != totalBars) 
      {
         ArrayResize(_buffer, totalBars);
      }
      
      if (period > totalBars - _length)
      {
         return false;
      }

      int bufferIndex = totalBars - 1 - period;
      double current;
      if (!_source.GetValue(period, current))
      {
         return false;
      }
      double last = _buffer[bufferIndex - 1] != EMPTY_VALUE ? _buffer[bufferIndex - 1] : current;
      _buffer[bufferIndex] = (1 - _k) * last + _k * current;
      val = _buffer[bufferIndex];
      return true;
   }
};
#endif



// TEMA on stream v1.0

#ifndef TemaOnStream_IMP
#define TemaOnStream_IMP

class TemaOnStream : public AStreamBase
{
   EMAOnStream *_ema1;
   EMAOnStream *_ema2;
   EMAOnStream *_ema3;
public:
   TemaOnStream(IStream *source, const int length)
   {
      _ema1 = new EMAOnStream(source, length);
      _ema2 = new EMAOnStream(_ema1, length);
      _ema3 = new EMAOnStream(_ema2, length);
   }

   ~TemaOnStream()
   {
      delete _ema3;
      delete _ema2;
      delete _ema1;
   }

   int Size()
   {
      return _ema3.Size();
   }

   bool GetValue(const int period, double &val)
   {
      double ema1, ema2, ema3;
      if (!_ema1.GetValue(period + 1, ema1) || !_ema2.GetValue(period, ema2) || !_ema3.GetValue(period, ema3))
         return false;
         
      val = ema3 + 3.0 * (ema1 - ema2);
      return true;
   }
};

#endif


// LWMA on stream v1.0

#ifndef LwmaOnStream_IMP
#define LwmaOnStream_IMP

class LwmaOnStream : public AOnStream
{
   int _length;
public:
   LwmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      double price;
      if (!_source.GetValue(period, price))
         return false;

      double sumw = _length;
      double sum = _length * price;
      for(int i = 1; i < _length; i++)
      {
         double weight = _length - i;
         sumw += weight;
         if (!_source.GetValue(period + i, price))
            return false;
         sum += weight * price;
      }
      val = sum / sumw;
      return true;
   }
};

#endif


#ifndef VwmaOnStream_IMP
#define VwmaOnStream_IMP

class VwmaOnStream : public AOnStream
{
   int _length;
public:
   VwmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (period > totalBars - _length)
         return false;
      double price;
      if (!_source.GetValue(period, price))
         return false;

      long sumw = Volume[period];
      double sum = sumw * price;
      for (int k = 1; k < _length; k++)
      {
         long weight = Volume[period + k];
         sumw += weight;
         if (!_source.GetValue(period + k, price))
            return false;
         sum += weight * price;  
      }
      val = sum / sumw;
      return true;
   }
};

#endif


//RmaOnStream v1.0

#ifndef RmaOnStream_IMP
#define RmaOnStream_IMP

class RmaOnStream : public AOnStream
{
   double _length;
   double _buffer[];
public:
   RmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      int size = Size();
      double price;
      if (!_source.GetValue(period, price))
         return false;

      if (ArrayRange(_buffer, 0) < size) 
         ArrayResize(_buffer, size);

      int index = size - 1 - period;
      if (index == 0)
      {
         _buffer[index] = price;
      }
      else
      {
         _buffer[index] = (_buffer[index - 1] * (_length - 1) + price) / _length;
      }
      val = _buffer[index];
      return true;
   }
};

#endif
// Zero lag TEMA on stream v1.0

#ifndef ZeroLagTEMAOnStream_IMP
#define ZeroLagTEMAOnStream_IMP

class ZeroLagTEMAOnStream : public AStreamBase
{
   TemaOnStream *_tema1;
   TemaOnStream *_tema2;
public:
   ZeroLagTEMAOnStream(IStream *source, const int length)
   {
      _tema1 = new TemaOnStream(source, length);
      _tema2 = new TemaOnStream(_tema1, length);
   }

   ~ZeroLagTEMAOnStream()
   {
      delete _tema2;
      delete _tema1;
   }

   int Size()
   {
      return _tema2.Size();
   }

   bool GetValue(const int period, double &val)
   {
      double tema1, tema2;
      if (!_tema1.GetValue(period, tema1) || !_tema2.GetValue(period, tema2))
         return false;

      val = (2.0 * tema1 - tema2);
      return true;
   }
};

#endif


// Zero lag MA on stream v1.0

#ifndef ZeroLagMAOnStream_IMP
#define ZeroLagMAOnStream_IMP

class ZeroLagMAOnStream : public AOnStream
{
   int _length;
   double _buffer[];
   double _alpha;
public:
   ZeroLagMAOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _length = length;
      _alpha = 2.0 / (1.0 + _length);
   }

   bool GetValue(const int period, double &val)
   {
      int totalBars = Bars;
      if (ArrayRange(_buffer, 0) != totalBars) 
         ArrayResize(_buffer, totalBars);
      
      if (period > totalBars - 1)
         return false;

      double price;
      if (!_source.GetValue(period, price))
         return false;

      int bufferIndex = totalBars - 1 - period;
      int shift = (int)((_length - 1.0) / 2.0);
      double prevPrice;
      if (period < shift || !_source.GetValue(period - shift, prevPrice))
      {
         _buffer[bufferIndex] = price;
         return true;
      }

      _buffer[bufferIndex] = _buffer[bufferIndex - 1] + _alpha * (2.0 * price - prevPrice - _buffer[bufferIndex - 1]);
      val = _buffer[bufferIndex];
      return true;
   }
};

#endif

#ifndef AveragesStreamFactory_IMP
#define AveragesStreamFactory_IMP

// Averages v. 1.1

class AveragesStreamFactory
{
public:
   static IStream *Create(IStream *source, const int length, const MATypes type)
   {
      switch (type)
      {
         case ma_jsavg:
            return new JsavgOnStream(source, length);
         case ma_sma:
            return new SmaOnStream(source, length);
         case ma_ema:
            return new EMAOnStream(source, length);
         //case 2  : return(iDsema(price,length,r,instanceNo));
         // case 3  : return(iDema(price,length,r,instanceNo));
         case ma_tema:
            return new TemaOnStream(source, length);
         // case 5  : return(iSmma(price,length,r,instanceNo));
         case ma_lwma:
            return new LwmaOnStream(source, length);
         // case 7  : return(iLwmp(price,length,r,instanceNo));
         // case 8  : return(iAlex(price,length,r,instanceNo));
         case ma_vwma:
            return new VwmaOnStream(source, length);
         // case 10 : return(iHull(price,length,r,instanceNo));
         // case 11 : return(iTma(price,length,r,instanceNo));
         // case 12 : return(iSineWMA(price,(int)length,r,instanceNo));
         // case 13 : return(iLinr(price,length,r,instanceNo));
         // case 14 : return(iIe2(price,length,r,instanceNo));
         // case 15 : return(iNonLagMa(price,length,r,instanceNo));
         case ma_zlma:
            return new ZeroLagMAOnStream(source, length);
         case ma_rma:
            return new RmaOnStream(source, length);
         case ma_zltema:
            return new ZeroLagTEMAOnStream(source, length);
         // case 17 : return(iLeader(price,length,r,instanceNo));
         // case 18 : return(iSsm(price,length,r,instanceNo));
         // case 19 : return(iSmooth(price,(int)length,r,instanceNo));
         // default : return(0);
      }
      return NULL;
   }
};

#endif

SimplePriceStream* price;
IStream* ma;
//+------------------------------------------------------------------+
//| init()                                                           |
//+------------------------------------------------------------------+
int init()
{
   visibility.Init("bbetvwap", "bbetvwap", "Show/Hide", button_x, button_y);
   
   if (N < 1)
   {
   	Alert("Period must be >= 1.");
   	return(INIT_FAILED);
   }
   IndicatorDigits(Digits);
   price = new SimplePriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, eintMAPrice);
   ma = AveragesStreamFactory::Create(price, eintBandsPeriod, eintMAMode);
   
   SetIndexBuffer( 0, gadblMid );
   SetIndexStyle( 0, DRAW_LINE );
   SetIndexLabel( 0, "BB-Mid" );
   
   SetIndexBuffer( 1, gadblUpper );
   SetIndexStyle( 1, DRAW_LINE );
   SetIndexLabel( 1, "BB-Upper" );
   
   SetIndexBuffer( 2, gadblLower );
   SetIndexStyle( 2, DRAW_LINE );
   SetIndexLabel( 2, "BB-Lower" );
   
   SetIndexBuffer( 3, gadblDiv );
   SetIndexStyle( 3, DRAW_ARROW );
   SetIndexArrow( 3, 108 ); 
   SetIndexLabel( 3, NULL );
   SetIndexEmptyValue( 3, 0.0 );
   
   SetIndexBuffer( 4, gadblDiv2 );
   SetIndexStyle( 4, DRAW_ARROW );
   SetIndexArrow( 4, 108 ); 
   SetIndexLabel( 4, NULL );
   SetIndexEmptyValue( 4, 0.0 );
   
   SetIndexBuffer(5 , ExtMapBuffer1);
   SetIndexBuffer(6, ExtStdDevBuffer);
   SetIndexLabel( 5, "VWAP" );

   IndicatorShortName( "Fiji BB" );
   IndicatorDigits( Digits );
   
   return( 0 );
}

//+------------------------------------------------------------------+
//| deinit()                                                         |
//+------------------------------------------------------------------+
int deinit()
{
   price.Release();
   price = NULL;
   ma.Release();
   ma = NULL;
   visibility.DeInit();
   return( 0 );
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
   {
      start();
   }
}

//+------------------------------------------------------------------+
//| start()                                                          |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   visibility.HandleButtonClicks();

   if (visibility.IsRecalcNeeded())
   {
      if (visibility.IsVisible())
      {
         counted_bars = 0;
      }
      else
      {
         ArrayInitialize(ExtMapBuffer1, EMPTY_VALUE);
         ArrayInitialize(ExtStdDevBuffer, EMPTY_VALUE);
         ArrayInitialize(gadblMid, EMPTY_VALUE);
         ArrayInitialize(gadblUpper, EMPTY_VALUE);
         ArrayInitialize(gadblLower, EMPTY_VALUE);
         ArrayInitialize(gadblDiv, 0);
         ArrayInitialize(gadblDiv2, 0);
      }
      visibility.ResetRecalc();
   }
   if (!visibility.IsVisible())
   {
      return 0;
   }
   
   int bar = Bars - counted_bars + N;
   if (bar >= Bars - N) 
      bar = Bars - N - 1;

	for (int i = 0; i <= bar; i++)
	{
		double sum1 = 0, sum2 = 0;
		for (int ntmp = 0; ntmp <= N; ntmp++)
		{
			switch(Price_Type)
			{
				case PRICE_CLOSE: 	sum1 += Close[i + ntmp] * Volume[i + ntmp]; break;
				case PRICE_OPEN: 		sum1 += Open[i + ntmp] * Volume[i + ntmp]; break;
				case PRICE_HIGH: 		sum1 += High[i + ntmp] * Volume[i + ntmp]; break;
				case PRICE_LOW: 		sum1 += Low[i + ntmp] * Volume[i + ntmp]; break;
				case PRICE_MEDIAN: 	sum1 += (High[i + ntmp] + Low[i + ntmp]) / 2 * Volume[i + ntmp]; break;
				case PRICE_TYPICAL:  sum1 += (High[i + ntmp] + Low[i + ntmp] + Close[i + ntmp]) / 3 * Volume[i + ntmp]; break;
				case PRICE_WEIGHTED: sum1 += (High[i + ntmp] + Low[i + ntmp] + Close[i + ntmp] + Close[i + ntmp]) / 4 * Volume[i + ntmp]; break;
			} 
			sum2 += (double)Volume[i + ntmp];
		}
		if (sum2 != 0) ExtMapBuffer1[i] = sum1 / sum2;
		else ExtMapBuffer1[i] = EMPTY_VALUE;
	
		if (ExtMapBuffer1[i] != EMPTY_VALUE)
		{
			ExtStdDevBuffer[i] = StdDev_Func(i, ExtMapBuffer1, N);
		} 
	}
   
   //**********************************
   
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   int intLimit = Bars - counted_bars;
        
   int intTrueShift, inx, jnx;
   double dblSum, dblNewRes, dblDeviation, dblCurrMA;

   for (inx = intLimit; inx >= 0; inx-- )
   {
      intTrueShift = inx + eintMAShift;
      dblSum = 0.0;
      if (!ma.GetValue(inx + intTrueShift, dblCurrMA))
      {
         continue;
      }
      for ( jnx = intTrueShift + eintBandsPeriod - 1; jnx >= intTrueShift; jnx-- )
      {
         dblNewRes = Close[jnx] - dblCurrMA;
         dblSum += ( dblNewRes * dblNewRes );
      }
   
      dblDeviation = edblBandsDev * MathSqrt( dblSum / eintBandsPeriod );
      gadblMid[inx] = dblCurrMA;
      gadblUpper[inx] = dblCurrMA + dblDeviation;
      gadblLower[inx] = dblCurrMA - dblDeviation; 
      gadblDiv[inx] = 0.0;
      gadblDiv2[inx] = 0.0;
   }
 
   return( 0 );
}

double StdDev_Func(const int position, const double &MAprice[], int period)
{
	double StdDev_dTmp = 0, price = 0;
	for (int i = 0; i < period; i++)
	{
		switch(Price_Type)
		{
			case PRICE_CLOSE: 	price = Close[position + i]; break;
			case PRICE_OPEN: 		price = Open[position + i]; break;
			case PRICE_HIGH: 		price = High[position + i]; break;
			case PRICE_LOW: 		price = Low[position + i]; break;
			case PRICE_MEDIAN: 	price = (High[position + i] + Low[position + i]) / 2; break;
			case PRICE_TYPICAL: 	price = (High[position + i] + Low[position + i] + Close[position + i]) / 3; break;
			case PRICE_WEIGHTED: price = (High[position + i] + Low[position + i] + Close[position + i] + Close[position + i]) / 4; break;
		} 
		StdDev_dTmp += MathPow(price - MAprice[position], 2);
	}       
	StdDev_dTmp = MathSqrt(StdDev_dTmp / period);
	return(StdDev_dTmp);
}
