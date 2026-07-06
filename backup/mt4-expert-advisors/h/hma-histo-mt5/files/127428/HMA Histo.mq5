// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68680

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
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers    2
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1     LimeGreen

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
//#import "AdvancedNotificationsLib.dll"
//void AdvancedAlert(string key, string text, string instrument, string timeframe);
//#import

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SendNotifications(const string subject, const string message, const string symbol, const string timeframe)
   {
      if (Popup_Alert)
         Alert(message);
      if (Email_Alert)
         SendMail(subject, message);
      if (Play_Sound)
         PlaySound(Sound_File);
      if (Notification_Alert)
         SendNotification(message);
      //if (Advanced_Alert && Advanced_Key != "")
      //   AdvancedAlert(Advanced_Key, message, symbol, timeframe);
   }

   void SendNotifications(const string message)
   {
      SendNotifications("Alert", message, _symbol, GetTimeframeStr());
   }

   string GetTimeframeStr()
   {
      switch (_timeframe)
      {
         case PERIOD_M1: return "M1";
         case PERIOD_M2: return "M2";
         case PERIOD_M3: return "M3";
         case PERIOD_M4: return "M4";
         case PERIOD_M5: return "M5";
         case PERIOD_M6: return "M6";
         case PERIOD_M10: return "M10";
         case PERIOD_M12: return "M12";
         case PERIOD_M15: return "M15";
         case PERIOD_M20: return "M20";
         case PERIOD_M30: return "M30";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H2: return "H2";
         case PERIOD_H3: return "H3";
         case PERIOD_H4: return "H4";
         case PERIOD_H6: return "H6";
         case PERIOD_H8: return "H8";
         case PERIOD_H12: return "H12";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }
};

input ENUM_TIMEFRAMES TimeFrame        = PERIOD_CURRENT;
input int               HMAPeriod             = 15;               // Hma Period to use
input ENUM_APPLIED_PRICE HMAPrice = PRICE_OPEN; // Price type
input int                HistoWidth            = 3;                // Histogram bars width
input color              UpHistoColor          = clrLimeGreen;     // Up histogram color
input color              DnHistoColor          = clrRed;           // Down histogram color

input bool               verticalLinesVisible  = false;            // Show vertical lines
input bool               linesOnNewest         = false;            // Vertical lines drawn on newest bar of higher time frame bar?
input color              verticalLinesUpColor  = clrDeepSkyBlue;   // Lines up color 
input color              verticalLinesDnColor  = clrPaleVioletRed; // Lines down color
input ENUM_LINE_STYLE    verticalLinesStyle    = STYLE_DOT;        // Lines style
input int                verticalLinesWidth    = 0;                // lines width
input string  __              = "arrows settings";
input bool   ShowArrows       = true;
input color  arrowsUpColor    = Lime;
input color  arrowsDnColor    = Orange;
//Signaler v 1.6
input string AlertsSection = ""; // == Alerts ==
input bool     Popup_Alert              = true; // Popup message
input bool     Notification_Alert       = false; // Push notification
input bool     Email_Alert              = false; // Email
input bool     Play_Sound               = false; // Play sound on alert
input string   Sound_File               = ""; // Sound file
input bool     Advanced_Alert           = false; // Advanced alert
input string   Advanced_Key             = ""; // Advanced alert key
input string   Comment5                 = "- DISABLED IN THIS VERSION -";
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll and cpprest141_2_10.dll -";

double hma[],trend[];

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

// Symbol info v.1.2
class InstrumentInfo
{
   string _symbol;
   double _mult;
   double _point;
   double _pipSize;
   int _digit;
   double _ticksize;
public:
   InstrumentInfo(const string symbol)
   {
      _symbol = symbol;
      _point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      _digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      _mult = _digit == 3 || _digit == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _ticksize = NormalizeDouble(SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE), _digit);
   }

   static double GetPipSize(const string symbol)
   {
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      double digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      double mult = digit == 3 || digit == 5 ? 10 : 1;
      return point * mult;
   }
   double GetPointSize() { return _point; }
   double GetPipSize() { return _pipSize; }
   int GetDigits() { return _digit; }
   string GetSymbol() { return _symbol; }
   double GetBid() { return SymbolInfoDouble(_symbol, SYMBOL_BID); }
   double GetAsk() { return SymbolInfoDouble(_symbol, SYMBOL_ASK); }
   double GetMinVolume() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathRound(rate / _ticksize) * _ticksize, _digit);
   }
};

// IStream v.1.2
interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;

   virtual int Size() = 0;
};

// ABaseStream v1.0
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
};

// StdMAStream v1.0

class StdMAStream : public ABaseStream
{
   int _maHandle;
public:
   StdMAStream(string symbol, ENUM_TIMEFRAMES timeframe, const int length, const ENUM_MA_METHOD method, int priceOrHandle)
      :ABaseStream(symbol, timeframe)
   {
      _maHandle = iMA(_symbol, _timeframe, length, 0, method, priceOrHandle);
   }
   ~StdMAStream()
   {
      IndicatorRelease(_maHandle);
   }

   int GetHandle()
   {
      return _maHandle;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      return CopyBuffer(_maHandle, 0, period, count, val) == count;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
   }
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

   virtual bool GetValue(const int period, double &val) = 0;

   bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         double v;
         if (!GetValue(period + i, v))
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

// TemaOnStream v1.0

class TemaOnStream : public AOnStream
{
   double _alpha;
   double _buffer1[];
   double _buffer2[];
   double _buffer3[];
public:
   TemaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _source = source;
      _alpha = 2.0 / (1.0 + length);
   }

   bool GetValue(const int period, double &val)
   {
      double price[1];
      if (!_source.GetValues(period, 1, price))
         return false;

      int size = Size();
      if (ArrayRange(_buffer1, 0) < size) 
         ArrayResize(_buffer1, size);
      if (ArrayRange(_buffer2, 0) < size) 
         ArrayResize(_buffer2, size);
      if (ArrayRange(_buffer3, 0) < size) 
         ArrayResize(_buffer3, size);

      _buffer1[size - 1 - period] = _buffer1[size - 1 - period - 1] + _alpha * (price[0] - _buffer1[size - 1 - period - 1]);
      _buffer2[size - 1 - period] = _buffer2[size - 1 - period - 1] + _alpha * (_buffer1[size - 1 - period] - _buffer2[size - 1 - period - 1]);
      _buffer3[size - 1 - period] = _buffer3[size - 1 - period - 1] + _alpha * (_buffer2[size - 1 - period] - _buffer3[size - 1 - period - 1]);
      val = (_buffer3[size - 1 - period] + 3.0 * (_buffer1[size - 1 - period] - _buffer2[size - 1 - period]));
      return true;
   }
};

// VwmaOnStream v1.0
class VwmaOnStream : public AOnStream
{
   IStream *_volumeSource;
   int _length;
public:
   VwmaOnStream(IStream *source, IStream *volumeSource, const int length)
      :AOnStream(source)
   {
      _source = source;
      _volumeSource = volumeSource;
      _length = length;
   }

   bool GetValue(const int period, double &val)
   {
      double price[1];
      double volume[1];
      double sumw = 0;
      double sum = 0;
      for (int k = 0; k < _length; k++)
      {
         if (!_source.GetValues(period + k, 1, price) || !_volumeSource.GetValues(period + k, 1, volume))
            return false;
         sumw += volume[0];
         sum += volume[0] * price[0];
      }
      val = sum / sumw;
      return true;
   }
};

//RmaOnStream v1.0
class RmaOnStream : public AOnStream
{
   double _alpha;
   double _buffer[];
public:
   RmaOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _source = source;
      _alpha = 2.0 / (1.0 + length);
   }

   bool GetValue(const int period, double &val)
   {
      int size = Size();
      double price[1];
      if (!_source.GetValues(period, 1, price))
         return false;

      if (ArrayRange(_buffer, 0) < size) 
         ArrayResize(_buffer, size);

      if (period == size - 1)
         _buffer[size - 1 - period] = _alpha * price[0];
      else
         _buffer[size - 1 - period] = _alpha * price[0] + (1 - _alpha) * (price[0] - _buffer[size - 1 - period - 1]);
      val = _buffer[size - 1 - period];
      return true;
   }
};

// CustomStream v1.0

class CustomStream : public IStream
{
protected:
   int _references;
public:
   double _data[];

   CustomStream()
   {
      _references = 1;
   }

   virtual int Size()
   {
      return ArrayRange(_data, 0);
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
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         if (_data[size - 1 - period + i] == EMPTY_VALUE)
            return false;
         val[i] = _data[size - 1 - period + i];
      }
      return true;
   }

   void SetSize(int size)
   {
      if (ArrayRange(_data, 0) < size) 
         ArrayResize(_data, size);
   }
};
// HullOnStream v1.0
class HullOnStream : public AOnStream
{
   int _length;
   CustomStream* _buffer;
   IStream* _half;
   IStream* _full;
   IStream* _hull;
public:
   HullOnStream(IStream *source, const int length)
      :AOnStream(source)
   {
      _source = source;
      _half = new RmaOnStream(source, (int)MathFloor(length / 2));
      _full = new RmaOnStream(source, length);
      _buffer = new CustomStream();
      _hull = new RmaOnStream(_buffer, (int)MathFloor(MathSqrt(length)));
   }

   ~HullOnStream()
   {
      _hull.Release();
      _buffer.Release();
      _half.Release();
      _full.Release();
   }

   bool GetValue(const int period, double &val)
   {
      int size = Size();
      _buffer.SetSize(size);
      double half[1];
      double full[1];
      if (!_half.GetValues(period, 1, half) || !_full.GetValues(period, 1, full))
         return false;
      
      _buffer._data[period] = half[0] * 2 - full[0];
      double res[1];
      if (!_hull.GetValues(period, 1, res))
         return false;
      val = res[0];
      return true;
   }
};

// VolumeStream v1.0

class VolumeStream : public ABaseStream
{
public:
   VolumeStream(string symbol, const ENUM_TIMEFRAMES timeframe)
      :ABaseStream(symbol, timeframe)
   {
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      for (int i = 0; i < count; ++i)
      {
         val[i] = (double)iVolume(_symbol, _timeframe, period + i);
      }
      return true;
   }
};

// IndicatorOutputStream v1.0

class IndicatorOutputStream : public ABaseStream
{
public:
   double _data[];

   IndicatorOutputStream(string symbol, const ENUM_TIMEFRAMES timeframe)
      :ABaseStream(symbol, timeframe)
   {
   }

   int RegisterStream(int id, color clr, string name)
   {
      SetIndexBuffer(id + 0, _data, INDICATOR_DATA);
      PlotIndexSetInteger(id - 1, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id - 1, PLOT_LINE_COLOR, clr);
      PlotIndexSetString(id - 1, PLOT_LABEL, name);
      return id + 1;
   }

   void Clear(double value)
   {
      ArrayInitialize(_data, value);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < count; ++i)
      {
         if (_data[size - 1 - period + i] == EMPTY_VALUE)
            return false;
         val[i] = _data[size - 1 - period + i];
      }
      return true;
   }
};

// PriceStream v1.0

class PriceStream : public ABaseStream
{
   ENUM_APPLIED_PRICE _price;
   double _pipSize;
public:
   PriceStream(string symbol, const ENUM_TIMEFRAMES timeframe, const ENUM_APPLIED_PRICE price)
      :ABaseStream(symbol, timeframe)
   {
      _price = price;
      _pipSize = InstrumentInfo::GetPipSize(symbol);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      string symbol = _symbol;
      for (int i = 0; i < count; ++i)
      {
         switch (_price)
         {
            case PRICE_CLOSE:
               val[i] = iClose(symbol, _timeframe, period + i);
               break;
            case PRICE_OPEN:
               val[i] = iOpen(symbol, _timeframe, period + i);
               break;
            case PRICE_HIGH:
               val[i] = iHigh(symbol, _timeframe, period + i);
               break;
            case PRICE_LOW:
               val[i] = iLow(symbol, _timeframe, period + i);
               break;
            case PRICE_MEDIAN:
               val[i] = (iHigh(symbol, _timeframe, period + i) + iLow(symbol, _timeframe, period + i)) / 2.0;
               break;
            case PRICE_TYPICAL:
               val[i] = (iHigh(symbol, _timeframe, period + i) + iLow(symbol, _timeframe, period + i) + iClose(symbol, _timeframe, period + i)) / 3.0;
               break;
            case PRICE_WEIGHTED:
               val[i] = (iHigh(symbol, _timeframe, period + i) + iLow(symbol, _timeframe, period + i) + iClose(symbol, _timeframe, period + i) * 2) / 4.0;
               break;
         }
         val[i] += _shift * _pipSize;
      }
      return true;
   }
};

Signaler* signaler;
int itself;

IStream* avg;

ENUM_TIMEFRAMES TF;

void OnInit()
{
   TF = TimeFrame == PERIOD_CURRENT ? (ENUM_TIMEFRAMES)_Period : TimeFrame;
   signaler = new Signaler(_Symbol, TF);
   if (TF != _Period)
      itself = iCustom(_Symbol, TF, "test", PERIOD_CURRENT, HMAPeriod, HMAPrice);

   IndicatorName = GenerateIndicatorName(signaler.GetTimeframeStr()+" HMA of " + (string)HMAPeriod);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   
   SetIndexBuffer(0, hma, INDICATOR_DATA);
   SetIndexBuffer(1, trend, INDICATOR_CALCULATIONS);

   IStream* source = new PriceStream(_Symbol, TF, HMAPrice);
   avg = new HullOnStream(source, HMAPeriod);
   source.Release();
}

void OnDeinit(const int reason)
{
   if (TF != _Period)
      IndicatorRelease(itself);
   delete signaler;
   signaler = NULL;
   avg.Release();
   avg = NULL;
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

void Calculate(int i)
{
   double priceVals[1];
   if (avg.GetValues(i, 1, priceVals) != 1)
      return;
   hma[i] = priceVals[0];
   if (i < 1)
      return;
      
   trend[i] = trend[i - 1]; 
   if (hma[i] > hma[i - 1]) 
      trend[i] = 1; 
   if (hma[i] < hma[i - 1]) 
      trend[i] = -1;
}

void drawLine(int i, color theColor, datetime time)
{
   string name = IndicatorObjPrefix + TimeToString(time);

   if (linesOnNewest) 
      time += _Period * 60 - 1;    
   ObjectCreate(0, name, OBJ_VLINE, 0, time, 0);
   ObjectSetInteger(0, name, OBJPROP_COLOR, theColor);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, verticalLinesWidth);
   ObjectSetInteger(0, name, OBJPROP_STYLE, verticalLinesStyle);
}

datetime _lastAlert;

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
      ArrayInitialize(hma, EMPTY_VALUE);
      ArrayInitialize(trend, EMPTY_VALUE);
   }
   for (int pos = prev_calculated; pos < rates_total; ++pos)
   {
      if (TF == _Period)
      {
         Calculate(pos);
         if (verticalLinesVisible)
         {
            string tlookFor = IndicatorObjPrefix + TimeToString(time[pos]);
            ObjectDelete(0, tlookFor);  
            if (pos > 0 && trend[pos] != trend[pos - 1])
            {
               if (trend[pos] == 1) 
                  drawLine(pos, verticalLinesUpColor, time[pos]);
               if (trend[pos] == -1) 
                  drawLine(pos, verticalLinesDnColor, time[pos]);
            }
         }
      }
      else
      {
         int index = iBarShift(_Symbol, TF, time[pos]);
         if (index < 0)
            return 0;
         double val[1];
         if (CopyBuffer(itself, 0, index, 1, val) == 1)
            hma[pos] = val[0];
         else
            return 0;
         if (CopyBuffer(itself, 1, index, 1, val) == 1)
            trend[pos] = val[0];
         else
            return 0;
      }
      manageArrow(pos, time[pos], high[pos], low[pos]);
   }

   if (_lastAlert != time[rates_total - 1])
   {
      if (trend[rates_total - 1] != trend[rates_total - 2])
      {
         if (trend[rates_total - 1] == 1) 
            signaler.SendNotifications(_Symbol + "/" + signaler.GetTimeframeStr() + ": Up");
         if (trend[rates_total - 1] ==-1) 
            signaler.SendNotifications(_Symbol + "/" + signaler.GetTimeframeStr() + ": Down");
         _lastAlert = time[rates_total - 1];
      }
   }
      
   return rates_total;
}

void manageArrow(int i, datetime dt, double high, double low)
{
   if (!ShowArrows || i == 0)
      return;
   if (trend[i] != trend[i - 1])
   {
      if (trend[i] == 1) 
         drawArrow(dt, arrowsUpColor, 221, high);
      if (trend[i] ==-1) 
         drawArrow(dt, arrowsDnColor, 222, low);
   }
}               

void drawArrow(datetime dt, color theColor,int theCode, double price)
{
   string name = IndicatorObjPrefix + ":" + TimeToString(dt);
   ObjectCreate(0, name, OBJ_ARROW, 0, dt, price);
   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, theCode);
   ObjectSetInteger(0, name, OBJPROP_COLOR, theColor);
   ObjectSetDouble(0, name, OBJPROP_PRICE, price);
}
