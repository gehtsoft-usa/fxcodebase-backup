//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75539

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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
// ProfitRobots Dashboard template v.1.6
// You can find more templates at https://github.com/sibvic/mq4-templates

#property indicator_separate_window
#property strict

enum DisplayMode
{
   Vertical,
   Horizontal
};

input string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
input string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD";
input bool     Include_M1               = false;
input bool     Include_M5               = false;
input bool     Include_M15              = false;
input bool     Include_M30              = false;
input bool     Include_H1               = true;
input bool     Include_H4               = false;
input bool     Include_D1               = true;
input bool     Include_W1               = true;
input bool     Include_MN1              = false;
input color    Labels_Color             = clrWhite; // Labels color
input color    button_text_color        = Black; // Button text color
input int min_button_width = 30; // Min button width
#ifdef USE_HISTORIC
   input color    historical_Up_Color      = Green; // Historical up color
#else
   color    historical_Up_Color      = Green; // Historical up color
#endif
input color    Up_Color                 = Lime; // Up color
#ifdef USE_HISTORIC
   input color    historical_Dn_Color      = Red; // Historical down color
#else
   color    historical_Dn_Color      = Red; // Historical down color
#endif
input color    Dn_Color                 = Pink; // Down color
input color    neutral_color            = clrDarkGray; // Neutral color
input int x_shift = 900; // X coordinate
input ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER; // Corner
input DisplayMode display_mode = Vertical; // Display mode
input int font_size = 10; // Font Size;
input int cell_width = 80; // Cell width
input int cell_height = 30; // Cell height
input bool alert_on_close = false; // Alert on bar close

#define MAX_LOOPBACK 500

string   WindowName;

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

// Condition base v2.1

#ifndef ACondition_IMP
#define ACondition_IMP

class AConditionBase : public ICondition
{
   int _references;
   string _conditionName;
public:
   AConditionBase(string name = "")
   {
      _conditionName = name;
      _references = 1;
   }
   
   virtual void AddRef()
   {
      ++_references;
   }

   virtual void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }
   
   virtual string GetLogMessage(const int period, const datetime date)
   {
      if (_conditionName == "" || _conditionName == NULL)
      {
         return "";
      }
      return _conditionName + ": " + (IsPass(period, date) ? "true" : "false");
   }
};
#endif
// Symbol info v1.3

#ifndef InstrumentInfo_IMP
#define InstrumentInfo_IMP

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
   static double GetBid(const string symbol) { return SymbolInfoDouble(symbol, SYMBOL_BID); }
   static double GetAsk(const string symbol) { return SymbolInfoDouble(symbol, SYMBOL_ASK); }
   double GetBid() { return SymbolInfoDouble(_symbol, SYMBOL_BID); }
   double GetAsk() { return SymbolInfoDouble(_symbol, SYMBOL_ASK); }
   double GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathRound(rate / _ticksize) * _ticksize, _digit);
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

// Base condition v1.1

#ifndef ABaseCondition_IMP
#define ABaseCondition_IMP

class ACondition : public AConditionBase
{
protected:
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo* _instrument;
   string _symbol;
public:
   ACondition(const string symbol, ENUM_TIMEFRAMES timeframe, string name = NULL)
      :AConditionBase(name)
   {
      _instrument = new InstrumentInfo(symbol);
      _timeframe = timeframe;
      _symbol = symbol;
   }
   ~ACondition()
   {
      delete _instrument;
   }
};


#endif
// IBarStream v1.0

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

// Standard timeframe bar stream v1.0

class AStandardTimeframeBarStream : public IBarStream
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _references;
   AStandardTimeframeBarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _references = 1;
   }
public:
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

   virtual bool FindDatePeriod(const datetime date, int& period)
   {
      period = iBarShift(_symbol, _timeframe, date);
      return true;
   }

   virtual int Size()
   {
      return iBars(_symbol, _timeframe);
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
   
   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = Size();
      int oldIndex = bars - period - 1;
      return GetSeriesValues(oldIndex, count, val);
   }
};

// HA bar steam v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef HABarStream_IMP
#define HABarStream_IMP

class HABarStream : public AStandardTimeframeBarStream
{
   double _open[];
   double _high[];
   double _low[];
   double _close[];
   int _lastCalculated;
public:
   HABarStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStandardTimeframeBarStream(symbol, timeframe)
   {
      _lastCalculated = 0;
   }

   virtual bool GetSeriesValue(const int period, double &val)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      val = _close[totalBars - 1 - period];
      return true;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (iBars(_symbol, _timeframe) <= period)
         return false;
      dt = iTime(_symbol, _timeframe, period);
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      open = _open[totalBars - 1 - period];
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      high = _high[totalBars - 1 - period];
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      low = _low[totalBars - 1 - period];
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      close = _close[totalBars - 1 - period];
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      open = _open[totalBars - 1 - period];
      high = _high[totalBars - 1 - period];
      low = _low[totalBars - 1 - period];
      close = _close[totalBars - 1 - period];
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      high = _high[totalBars - 1 - period];
      low = _low[totalBars - 1 - period];
      return true;
   }

   virtual bool GetOpenClose(const int period, double& open, double& close)
   {
      int totalBars = Size();
      if (totalBars <= period)
         return false;
      open = _open[totalBars - 1 - period];
      close = _close[totalBars - 1 - period];
      return true;
   }

   virtual void Refresh()
   {
      int totalBars = Size();
      if (ArrayRange(_open, 0) != totalBars)
      {
         ArrayResize(_open, totalBars);
         ArrayResize(_high, totalBars);
         ArrayResize(_low, totalBars);
         ArrayResize(_close, totalBars);
      }
      for (int i = MathMax(0, _lastCalculated - 1); i < totalBars; ++i)
      {
         double open = iOpen(_symbol, _timeframe, totalBars - 1 - i);
         double high = iHigh(_symbol, _timeframe, totalBars - 1 - i);
         double low = iLow(_symbol, _timeframe, totalBars - 1 - i);
         double close = iClose(_symbol, _timeframe, totalBars - 1 - i);
         _open[i] = i == 0 ? (open + close) / 2 : (_open[i - 1] + _close[i - 1]) / 2;
         _close[i] = (open + high + low + close) / 4;
         _high[i] = fmax(high, fmax(_open[i], _close[i]));
         _low[i] = fmin(low,fmin(_open[i], _close[i]));
      }
      _lastCalculated = totalBars;
   }
};

#endif

class UpCondition : public ACondition
{
   HABarStream* stream;
public:
   UpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      stream = new HABarStream(symbol, timeframe);
   }
   ~UpCondition()
   {
      stream.Release();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      stream.Refresh();
      double open;
      double close;
      if (!stream.GetOpenClose(period, open, close))
      {
         return false;
      }
      return open < close;
   }
};

class DownCondition : public ACondition
{
   HABarStream* stream;
public:
   DownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      stream = new HABarStream(symbol, timeframe);
   }
   ~DownCondition()
   {
      stream.Release();
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      stream.Refresh();
      double open;
      double close;
      if (!stream.GetOpenClose(period, open, close))
      {
         return false;
      }
      return open > close;
   }
};

ICondition* CreateUpCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   return new UpCondition(symbol, timeframe);
}

ICondition* CreateDownCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   return new DownCondition(symbol, timeframe);
}

// Dashboard v.1.2
class Iterator
{
   int _initialValue; int _shift; int _current;
public:
   Iterator(int initialValue, int shift) { _initialValue = initialValue; _shift = shift; _current = _initialValue - _shift; }
   int GetNext() { _current += _shift; return _current; }
};

// Empty cell v1.0

// Interface for a cell v3.0

#ifndef ICell_IMP
#define ICell_IMP

class ICell
{
public:
   virtual void Draw(int x, int y, int width) = 0;
   virtual void HandleButtonClicks() = 0;
   virtual void Measure(int& width, int& height) = 0;
};

#endif

#ifndef EmptyCell_IMP
#define EmptyCell_IMP

class EmptyCell : public ICell
{
public:
   virtual void Draw(int x, int y, int width) { }
   virtual void HandleButtonClicks() { }
   virtual void Measure(int& width, int& height)
   {
      width = 0;
      height = 0;
   }
};

#endif


// ACell v1.0

class ACell : public ICell
{
protected:
   void Measure(string text, string font, int fontSize, int& width, int& height)
   {
      TextSetFont(font, -fontSize * 10);
      TextGetSize(text, width, height);
   }
   void ObjectMakeLabel(string nm, int xoff, int yoff, string text, color LabelColor, int LabelCorner, int Window, string Font, int FSize)
   { 
      ObjectDelete(0, nm); 
      ObjectCreate(0, nm, OBJ_LABEL, Window, 0, 0); 
      ObjectSetInteger(0, nm, OBJPROP_CORNER, LabelCorner); 
      ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, xoff); 
      ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, yoff); 
      ObjectSetInteger(0, nm, OBJPROP_BACK, false); 
      ObjectSetString(0, nm, OBJPROP_TEXT, text);
      ObjectSetString(0, nm, OBJPROP_FONT, Font);
      ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, FSize);
      ObjectSetInteger(0, nm, OBJPROP_COLOR, LabelColor);
   }
};
#define ColorRGB(red, green, blue, transp) (uint)((red) + ((green) << 8) + ((blue) << 16) + ((uint)(transp * 2.55) << 24))
#define ColorR(clr) ((clr & 0x00FF0000) >> 16)
#define ColorG(clr) ((clr & 0x0000FF00) >> 8)
#define ColorB(clr) (clr & 0x000000FF)
#define GetColorOnly(clr) (clr & 0xFFFFFF)
#define GetTranparency(clr) (int)MathRound(((clr & 0xFF000000) >> 24) / 2.55)
#define AddTransparency(clr, transp) (clr + ((uint)(transp * 2.55) << 24))

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

uint FromGradient(double value, double bottomValue, double topValue, uint bottomColor, uint topColor)
{
   if (value == EMPTY_VALUE || topValue == EMPTY_VALUE)
   {
      return bottomColor;
   }
   if (bottomValue == EMPTY_VALUE)
   {
      return topColor;
   }
   double range = topValue - bottomValue;
   double rate = (value - bottomValue) / range;
   if (rate > 1)
   {
      return bottomColor;
   }
   if (rate < 0)
   {
      return topColor;
   }
   uint bottomR = ColorR(bottomColor);
   uint bottomG = ColorG(bottomColor);
   uint bottomB = ColorB(bottomColor);
   uint topR = ColorR(topColor);
   uint topG = ColorG(topColor);
   uint topB = ColorB(topColor);
   return ColorRGB(bottomR + int(rate * (topR - bottomR)), bottomG + int(rate * (topG - bottomG)), bottomB + int(rate * (topB - bottomB)), 0);
}

double SetStream(double &stream[], int pos, double value, double defaultValue)
{
   stream[pos] = value == EMPTY_VALUE ? defaultValue : value;
   return stream[pos];
}

// Label cell v4.1

#ifndef LabelCell_IMP
#define LabelCell_IMP

class LabelCell : public ACell
{
   string _id;
   string _text; 
   ENUM_BASE_CORNER _corner;
   int _fontSize;
   uint _color;
   int _windowNumber;
   string _textHAlign;
   bool _withBackground;
   uint _bgColor;
   int _width;
   int _height;
   int _linesHeights[];
   int _linesWidths[];
public:
   LabelCell(const string id, const string text, ENUM_BASE_CORNER corner, int fontSize, uint clr, int windowNumber)
   { 
      _withBackground = false;
      _textHAlign = "cental";
      _corner = corner;
      _id = id; 
      _text = text;
      _fontSize = fontSize;
      _color = GetColorOnly(clr);
      _windowNumber = windowNumber;
   }

   virtual void Measure(int& width, int& height)
   {
      _width = 0;
      _height = 0;
      string lines[];
      int linesCount = StringSplit(_text, '\n', lines);
      ArrayResize(_linesHeights, linesCount);
      ArrayResize(_linesWidths, linesCount);
      for (int i = 0; i < linesCount; ++i)
      {
         int w, h;
         Measure(lines[i], "Arial", _fontSize, w, h);
         _height += h;
         _width = MathMax(_width, w);
         _linesHeights[i] = h;
         _linesWidths[i] = w;
      }
      width = _width;
      height = _height;
   }

   virtual void Draw(int x, int y, int width)
   {
      if (_withBackground)
      {
         if (ObjectFind(0, _id + "rect") == -1 && !ObjectCreate(0, _id + "rect", OBJ_RECTANGLE_LABEL, 0, 0, 0))
         {
            return;
         }
         ObjectSetInteger(0, _id + "rect", OBJPROP_XDISTANCE, x);
         ObjectSetInteger(0, _id + "rect", OBJPROP_YDISTANCE, y);
         ObjectSetInteger(0, _id + "rect", OBJPROP_BGCOLOR, _bgColor);
         ObjectSetInteger(0, _id + "rect", OBJPROP_XSIZE, width);
         ObjectSetInteger(0, _id + "rect", OBJPROP_YSIZE, _height);
         ObjectSetInteger(0, _id + "rect", OBJPROP_COLOR, _color);
         ObjectSetInteger(0, _id + "rect", OBJPROP_CORNER, _corner);
         ObjectSetInteger(0, _id + "rect", OBJPROP_BACK, true);
      }
      string lines[];
      int linesCount = StringSplit(_text, '\n', lines);
      for (int i = 0; i < linesCount; ++i)
      {
         int lineX = x;
         if (_textHAlign == "center")
         {
            lineX += (width - _linesWidths[i]) / 2;
         }
         else if (_textHAlign == "right")
         {
            lineX += width - _linesWidths[i];
         }
         ObjectMakeLabel(_id + "line" + i, lineX, y, lines[i], _color, _corner, _windowNumber, "Arial", _fontSize); 
         y += _linesHeights[i];
      }
   }
   
   bool SetBgColor(uint clr)
   {
      clr = GetColorOnly(clr);
      if (_bgColor == clr)
      {
         return false;
      }
      _bgColor = clr;
      _withBackground = true;
      return true;
   }

   virtual void HandleButtonClicks()
   {
      
   }
   
   bool SetColor(uint clr)
   {
      clr = GetColorOnly(clr);
      if (_color == clr)
      {
         return false;
      }
      _color = clr;
      return true;
   }
   
   bool SetText(string text)
   {
      if (_text == text)
      {
         return false;
      }
      _text = text;
      return true;
   }
   
   bool SetFontSize(int fontSize)
   {
      if (_fontSize == fontSize)
      {
         return false;
      }
      _fontSize = fontSize;
      return true;
   }
   
   bool SetTextHAlign(string textHAlign)
   {
      if (_textHAlign == textHAlign)
      {
         return false;
      }
      _textHAlign = textHAlign;
      return true;
   }
};

#endif

//Row size v1.0

class RowSize
{
   int _widths[];
   int _maxHeight;
public:
   void Add(int index, int width, int height)
   {
      int size = ArraySize(_widths);
      if (size <= index)
      {
         ArrayResize(_widths, index + 1);
         for (int i = size; i < index + 1; ++i)
         {
            _widths[i] = 0;
         }
      }
      _maxHeight = MathMax(_maxHeight, height);
      _widths[index] = MathMax(_widths[index], width);
   }

   int GetWidth(int index)
   {
      return _widths[index];
   }

   int GetMaxHeight()
   {
      return _maxHeight;
   }
};

// Row v2.1

#ifndef Row_IMP
#define Row_IMP

class Row
{
   ICell *_cells[];
public:
   ~Row() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         delete _cells[i]; 
      } 
   }

   void Measure(RowSize* rowSizes)
   {
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         int w, h;
         _cells[i].Measure(w, h);
         rowSizes.Add(i, w + 5, h + 5);
      } 
   }
   
   int GetColumnsCount()
   {
      return ArraySize(_cells);
   }

   void Draw(int x, int y, RowSize* rowSizes) 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         int width = rowSizes.GetWidth(i);
         _cells[i].Draw(x, y, width);
         x += width;
      } 
   }

   void HandleButtonClicks() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         _cells[i].HandleButtonClicks(); 
      } 
   }
   
   ICell* GetCell(int index)
   {
      if (index < 0)
      {
         return NULL;
      }
      int count = ArraySize(_cells);
      if (index >= count)
      {
         return NULL;
      }
      return _cells[index];
   }

   void Add(ICell *cell) 
   {
      int count = ArraySize(_cells); 
      ArrayResize(_cells, count + 1); 
      _cells[count] = cell; 
   } 
};


#endif


// Grid v2.1

#ifndef Grid_IMP
#define Grid_IMP

class Grid
{
   Row *_rows[];
public:
   ~Grid()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         delete _rows[i];
      }
   }

   Row *AddRow()
   {
      int count = ArraySize(_rows);
      ArrayResize(_rows, count + 1);
      _rows[count] = new Row();
      return _rows[count];
   }
   
   Row *GetRow(const int index)
   {
      if (index == INT_MIN)
      {
         return NULL;
      }
      return _rows[index];
   }
   
   int GetRowsCount()
   {
      return ArraySize(_rows);
   }
   
   void Draw(int x, int y)
   {
      RowSize* widths = MeasureColumns();
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         int w, h;
         _rows[i].Draw(x, y, widths);
         y += widths.GetMaxHeight();
      }
      delete widths;
   }

   void HandleButtonClicks()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].HandleButtonClicks();
      }
   }
private:
   RowSize* MeasureColumns()
   {
      RowSize* widths = new RowSize();
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].Measure(widths);
      }
      return widths;
   }
};

#endif
// Trend value cell factory v2.0

// Interface for a cell factory v2.0



#ifndef ICellFactory_IMP
#define ICellFactory_IMP

class ICellFactory
{
public:
   virtual ICell* Create(const string id, ENUM_BASE_CORNER corner, const string symbol, const ENUM_TIMEFRAMES timeframe) = 0;
   virtual string GetHeader() = 0;
};

#endif

// Interface for a value formatter v1.0

#ifndef IValueFormatter_IMP
#define IValueFormatter_IMP

class IValueFormatter
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual string FormatItem(const int period, const datetime date, color& textColor, color& bgColor) = 0;
};

#endif
//Signaler v5.1
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
   bool startProgram;
   string startProgramPath;
   bool popup_alert;
   bool email_alert;
   bool play_sound;
   string sound_file;
   bool notification_alert;
   bool advanced_alert;
   string advanced_key;
   string advanced_server;
public:
   Signaler(string frequency)
   {
      startProgram = false;
      popup_alert = true;
      email_alert = false;
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

   void EnablePopupAlert(bool enable)
   {
      popup_alert = enable;
   }
   void EnableEmailAlert(bool enable)
   {
      email_alert = enable;
   }
   void SetStartProgram(bool start, string path)
   {
      startProgram = start;
      startProgramPath = path;
   }
   void EnableSound(bool enabled, string soundFile)
   {
      play_sound = enabled;
      sound_file = soundFile;
   }
   void EnableNotificationAlert(bool enabled)
   {
      notification_alert = enabled;
   }
   void EnableAdvanced(bool enabled, string key, string server)
   {
      advanced_alert = enabled;
      advanced_key = key;
      advanced_server = server;
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
      if (startProgram)
         ShellExecuteW(0, "open", startProgramPath, "", "", 1);
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
      if (advanced_alert && advanced_key != "")
         AdvancedAlertCustom(advanced_key, message, "", "", advanced_server);
#endif
   }
};


#ifndef CellUtilsIMPL
#define CellUtilsIMPL

void ObjectMakeLabel(string nm, int xoff, int yoff, string text, color LabelColor, int LabelCorner, int Window, string Font, int FSize)
{ 
   ObjectDelete(0, nm); 
   ObjectCreate(0, nm, OBJ_LABEL, Window, 0, 0); 
   ObjectSetInteger(0, nm, OBJPROP_CORNER, LabelCorner); 
   ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, xoff); 
   ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, yoff); 
   ObjectSetInteger(0, nm, OBJPROP_BACK, false); 
   ObjectSetString(0, nm, OBJPROP_TEXT, text);
   ObjectSetString(0, nm, OBJPROP_FONT, Font);
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, FSize);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, LabelColor);
}
#endif

// Trend value cell v2.1

#ifndef TrendValueCell_IMP
#define TrendValueCell_IMP

#ifndef ENTER_BUY_SIGNAL
#define ENTER_BUY_SIGNAL 1
#endif
#ifndef ENTER_SELL_SIGNAL
#define ENTER_SELL_SIGNAL -1
#endif
enum OutputMode
{
   OutputLabels, // Labels
   OutputButtonsNewWindow, // New chart buttons
   OutputButtons // Current chart buttons
};
input OutputMode output_mode = OutputLabels; // Mode

string TimeframeToString(ENUM_TIMEFRAMES timeframe)
{
   switch (timeframe)
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

class TrendValueCell : public ICell
{
   string _id;
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDatetime;
   ICondition* _conditions[];
   IValueFormatter* _valueFormatters[];
   IValueFormatter* _signalFormatters[];
   IValueFormatter* _historyValueFormatters[];
   Signaler* _signaler;
   datetime _lastSignalDate;
   int _lastSignal;
   int _alertShift;
   IValueFormatter* _defaultValue;
   bool _historicalMode;
   OutputMode _outputMode;
   ENUM_BASE_CORNER _corner;
   int _fontSize;
   int _cellWidth;
public:
   TrendValueCell(const string id, ENUM_BASE_CORNER __corner, const string symbol, 
      const ENUM_TIMEFRAMES timeframe, int alertShift, 
      IValueFormatter* defaultValue, OutputMode outputMode, int fontSize, int cellWidth)
   { 
      _cellWidth = cellWidth;
      _fontSize = fontSize;
      _corner = __corner;
      _outputMode = outputMode;
      _lastSignal = 0;
      _alertShift = alertShift;
      _signaler = new Signaler();
      _signaler.SetMessagePrefix(symbol + "/" + TimeframeToString(timeframe) + ": ");
      _id = id; 
      _symbol = symbol;
      _timeframe = timeframe;
      _defaultValue = defaultValue;
      _defaultValue.AddRef();
      _historicalMode = true;
   }

   ~TrendValueCell()
   {
      delete _signaler;
      _defaultValue.Release();
      for (int i = 0; i < ArraySize(_conditions); ++i)
      {
         _conditions[i].Release();
         _valueFormatters[i].Release();
         if (_signalFormatters[i] != NULL)
         {
            _signalFormatters[i].Release();
         }
         if (_historyValueFormatters[i] != NULL)
         {
            _historyValueFormatters[i].Release();
         }
      }
      ArrayResize(_conditions, 0);
      ArrayResize(_valueFormatters, 0);
      ArrayResize(_historyValueFormatters, 0);
      ArrayResize(_signalFormatters, 0);
   }

   void AddCondition(ICondition* condition, IValueFormatter* value, IValueFormatter* historyValue, IValueFormatter* signal)
   {
      int size = ArraySize(_conditions);
      ArrayResize(_conditions, size + 1);
      ArrayResize(_valueFormatters, size + 1);
      ArrayResize(_historyValueFormatters, size + 1);
      ArrayResize(_signalFormatters, size + 1);
      _conditions[size] = condition;
      condition.AddRef();
      _valueFormatters[size] = value;
      value.AddRef();
      _historyValueFormatters[size] = historyValue;
      if (historyValue != NULL)
      {
         historyValue.AddRef();
      }
      else
      {
         _historicalMode = false;
      }
      _signalFormatters[size] = signal;
      if (signal != NULL)
      {
         signal.AddRef();
      }
   }

   virtual void HandleButtonClicks()
   {
      for (int i = 0; i < ArraySize(_conditions); ++i)
      {
         string id = _id + "B";
         if (ObjectGetInteger(0, id, OBJPROP_STATE))
         {
            ObjectSetInteger(0, id, OBJPROP_STATE, false);
            if (_outputMode == OutputButtonsNewWindow)
            {
               ChartOpen(_symbol, _timeframe);
            }
            else
            {
               ChartSetSymbolPeriod(0, _symbol, _timeframe);
            }
         }
      }
   }
   virtual void Measure(int& width, int& height)
   {
      for (int i = 0; i < ArraySize(_conditions); ++i)
      {
         if (_conditions[i].IsPass(_alertShift, 0))
         {
            color textColor, bgColor;
            string text = _valueFormatters[i].FormatItem(_alertShift, 0, textColor, bgColor);
            TextSetFont("Arial", -_fontSize * 10);
            TextGetSize(text, width, height);
            return;
         }
      }
      if (!_historicalMode)
      {
         width = 0;
         height = 0;
         return;
      }
      for (int period = _alertShift + 1; period < 1000; ++period)
      {
         datetime date = iTime(_symbol, _timeframe, period);
         for (int i = 0; i < ArraySize(_conditions); ++i)
         {
            if (_conditions[i].IsPass(period, date))
            {
               color textColor, bgColor;
               string text = _historyValueFormatters[i].FormatItem(period, date, textColor, bgColor);
               TextSetFont("Arial", -_fontSize * 10);
               TextGetSize(text, width, height);
               return;
            }
         }
      }
      width = 0;
      height = 0;
   }

   virtual void Draw(int x, int y, int width)
   {
      datetime date = iTime(_symbol, _timeframe, _alertShift);
      for (int i = 0; i < ArraySize(_conditions); ++i)
      {
         if (_conditions[i].IsPass(_alertShift, date))
         {
            color textColor, bgColor;
            string text = _valueFormatters[i].FormatItem(_alertShift, date, textColor, bgColor);
            DrawItem(text, textColor, bgColor, x, y);
            if (_signalFormatters[i] != NULL)
            {
               text = _signalFormatters[i].FormatItem(_alertShift, date, textColor, bgColor);
               SendAlert(text, i);
            }
            return;
         }
      }
      if (_historicalMode)
      {
         DrawHistoricalValue(x, y);
         return;
      }
      color textColor, bgColor;
      string text = _defaultValue.FormatItem(_alertShift, date, textColor, bgColor);
      DrawItem(text, textColor, bgColor, x, y);
   }

private:
   void DrawHistoricalValue(int x, int y)
   {
      for (int period = _alertShift + 1; period < 1000; ++period)
      {
         datetime date = iTime(_symbol, _timeframe, period);
         for (int i = 0; i < ArraySize(_conditions); ++i)
         {
            if (_conditions[i].IsPass(period, date))
            {
               color textColor, bgColor;
               string text = _historyValueFormatters[i].FormatItem(period, date, textColor, bgColor);
               DrawItem(text, textColor, bgColor, x, y);
               return;
            }
         }
      }
   }
   void DrawItem(string text, color textColor, color bgColor, int x, int y)
   {
      string id = _id + "B";
      if (_outputMode == OutputLabels)
      {
         ObjectDelete(0, id);
         ObjectMakeLabel(id, x, y, text, textColor, _corner, ChartWindowFind(), "Arial", _fontSize); 
      }
      else
      {
         ObjectDelete(0, id);
         if (ObjectFind(0, id) < 0)
         {
            ObjectCreate(0, id, OBJ_BUTTON, ChartWindowFind(), 0, 0);
         }
         
         
         ObjectSetInteger(0, id, OBJPROP_CORNER, _corner);
         ObjectSetInteger(0, id, OBJPROP_XDISTANCE, x);
         ObjectSetInteger(0, id, OBJPROP_YDISTANCE, y);
         ObjectSetString(0, id, OBJPROP_FONT, "Arial");
         ObjectSetString(0, id, OBJPROP_TEXT, text);
         ObjectSetInteger(0, id, OBJPROP_COLOR, textColor);
         ObjectSetInteger(0, id, OBJPROP_BGCOLOR, bgColor);
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, _fontSize);
         TextSetFont("Arial", -_fontSize * 10);
         int width, height;
         TextGetSize(text, width, height);
         ObjectSetInteger(0, id, OBJPROP_XSIZE, MathMax(_cellWidth, width + 5));
         ObjectSetInteger(0, id, OBJPROP_YSIZE, height + 5);
      }
   }

   void SendAlert(string text, int direction)
   {
      if (iTime(_symbol, _timeframe, 0) != _lastSignalDate && _lastSignal != direction)
      {
         _signaler.SendNotifications(text);
         _lastSignalDate = iTime(_symbol, _timeframe, 0);
         _lastSignal = direction;
      }
   }
};
#endif

// Abstrace value formatter v1.0

#ifndef AValueFormatter_IMP
#define AValueFormatter_IMP

class AValueFormatter : public IValueFormatter
{
   int _references;
public:
   AValueFormatter()
   {
      _references = 1;
   }

   virtual void AddRef()
   {
      ++_references;
   }

   virtual void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }
};

#endif
// Formats value as a contant/fixed text value v1.0

#ifndef FixedTextFormatter_IMP
#define FixedTextFormatter_IMP

class FixedTextFormatter : public AValueFormatter
{
   string _text;
   color _clr;
   color _bgClr;
public:
   FixedTextFormatter(string text, color clr, color bgClr)
   {
      _bgClr = bgClr;
      _text = text;
      _clr = clr;
   }

   virtual string FormatItem(const int period, const datetime date, color& clr, color& bgColor)
   {
      clr = _clr;
      bgColor = _bgClr;
      return _text;
   }
};

#endif

#ifndef TrendValueCellFactory_IMP
#define TrendValueCellFactory_IMP

class TrendValueCellFactory : public ICellFactory
{
   int _alertShift;
   color _upColor;
   color _downColor;
   color _historicalUpColor;
   color _historicalDownColor;
   color _neutralColor;
   color _buttonTextColor;
   OutputMode _outputMode;
   int _fontSize;
   int _cellWidth;
public:
   TrendValueCellFactory(int alertShift = 0, color upColor = Green, color downColor = Red, color historicalUpColor = Lime, color historicalDownColor = Pink, int fontSize = 10, int cellWidth = 80)
   {
      _fontSize = fontSize;
      _cellWidth = cellWidth;
      _outputMode = OutputLabels;
      _alertShift = alertShift;
      _upColor = upColor;
      _downColor = downColor;
      _historicalUpColor = historicalUpColor;
      _historicalDownColor = historicalDownColor;
   }

   void SetNeutralColor(color clr)
   {
      _neutralColor = clr;
   }

   void SetButtonTextColor(color clr)
   {
      _buttonTextColor = clr;
   }

   virtual string GetHeader()
   {
      return "Value";
   }

   virtual ICell* Create(const string id, ENUM_BASE_CORNER corner, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", GetTextColor(_neutralColor), GetBackgroundColor(_neutralColor));
      TrendValueCell* cell = new TrendValueCell(id, corner, symbol, timeframe, _alertShift, defaultValue, _outputMode, _fontSize, _cellWidth);
      defaultValue.Release();

      ICondition* upCondition = new UpCondition(symbol, timeframe);
      IValueFormatter* upValue = new FixedTextFormatter("Buy", GetTextColor(_upColor), GetBackgroundColor(_upColor));
      IValueFormatter* historyUpValue = new FixedTextFormatter("Buy", GetTextColor(_historicalUpColor), GetBackgroundColor(_historicalUpColor));
      cell.AddCondition(upCondition, upValue, historyUpValue, upValue);
      upCondition.Release();
      upValue.Release();
      historyUpValue.Release();

      ICondition* downCondition = new DownCondition(symbol, timeframe);
      IValueFormatter* downValue = new FixedTextFormatter("Sell", GetTextColor(_downColor), GetBackgroundColor(_downColor));
      IValueFormatter* historyDownValue = new FixedTextFormatter("Sell", GetTextColor(_historicalDownColor), GetBackgroundColor(_historicalDownColor));
      cell.AddCondition(downCondition, downValue, historyDownValue, downValue);
      downCondition.Release();
      downValue.Release();
      historyDownValue.Release();

      return cell;
   }
private:
   color GetTextColor(color clr)
   {
      return _outputMode == OutputLabels ? clr : _buttonTextColor;
   }
   color GetBackgroundColor(color clr)
   {
      return _outputMode != OutputLabels ? clr : _buttonTextColor;
   }
};
#endif

Grid *grid;

// Grid builder v2.0




#ifndef GridBuilder_IMP
#define GridBuilder_IMP

class GridBuilder
{
   string _symbols[];
   int _symbolsCount;
   Grid *grid;
   bool _verticalMode;
   int _cellHeight;
   int _headerHeight;
   ICellFactory* _cellFactory[];
   ENUM_BASE_CORNER _corner;
   int _fontSize;
   color _headerColor;
   int _windowNumber;
public:
   GridBuilder(int headerHeight, int cellHeight, bool verticalMode, ENUM_BASE_CORNER __corner, int fontSize, color headerColor, int windowNumber)
   {
      _windowNumber = windowNumber;
      _fontSize = fontSize;
      _corner = __corner;
      _cellHeight = cellHeight;
      _headerHeight = headerHeight;
      _verticalMode = verticalMode;
      _headerColor = headerColor;
      grid = new Grid();
   }

   ~GridBuilder()
   {
      for (int i = 0; i < ArraySize(_cellFactory); ++i)
      {
         delete _cellFactory[i];
      }
      ArrayResize(_cellFactory, 0);
   }

   void AddCell(ICellFactory* cellFactory)
   {
      int size = ArraySize(_cellFactory);
      ArrayResize(_cellFactory, size + 1);
      _cellFactory[size] = cellFactory;
   }

   void SetSymbols(const string symbols, int x, int y)
   {
      StringSplit(symbols, ',', _symbols);
      _symbolsCount = ArraySize(_symbols);

      int cellFactorySize = ArraySize(_cellFactory);
      if (_verticalMode)
      {
         Iterator yIterator(y, _cellHeight);
         if (cellFactorySize > 1)
         {
            yIterator.GetNext();
         }
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], _corner, _fontSize, _headerColor, _windowNumber));
         }
      }
      else
      {
         //TODO: add support of multiple values
         Iterator xIterator(x - cell_width, -cell_width);
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], _corner, _fontSize, _headerColor, _windowNumber));
         }
      }
   }

   void AddTimeframe(const string label, const ENUM_TIMEFRAMES timeframe)
   {
      int cellFactorySize = ArraySize(_cellFactory);
      if (_verticalMode)
      {
         Row* column[];
         ArrayResize(column, cellFactorySize);
         for (int ii = 0; ii < cellFactorySize; ++ii)
         {
            column[ii] = grid.AddRow();
            #ifndef EXCLUDE_PERIOD_HEADER
            if (ii > 0)
            {
               column[ii].Add(new EmptyCell());
            }
            else
            {
               column[ii].Add(new LabelCell(IndicatorObjPrefix + label + "_h", label, _corner, _fontSize, _headerColor, _windowNumber));
            }
            #endif
         }
         
         if (cellFactorySize > 1)
         {
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               string index = IntegerToString(ii + 1);
               column[ii].Add(new LabelCell(IndicatorObjPrefix + label + "_sh" + index, _cellFactory[ii].GetHeader(), _corner, _fontSize, _headerColor, _windowNumber));
            }
         }

         for (int i = 0; i < _symbolsCount; i++)
         {
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               string id = IndicatorObjPrefix + _symbols[i] + "_" + label + IntegerToString(ii);
               column[ii].Add(_cellFactory[ii].Create(id, _corner, _symbols[i], timeframe));
            }
         }
      }
      else
      {
         //TODO: add support of multiple values
         Row* row = grid.AddRow();
         #ifndef EXCLUDE_PERIOD_HEADER
            row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, _corner, _fontSize, _headerColor, _windowNumber));
         #endif
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               row.Add(_cellFactory[ii].Create(id, _corner, _symbols[i], timeframe));
            }
         }
      }
   }

   Grid* Build()
   {
      return grid;
   }
};
#endif
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

int OnInit(void)
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("HAD");
   IndicatorSetString(INDICATOR_SHORTNAME, "Heikin Ashi Sashboard");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   GridBuilder builder(cell_height, cell_height, display_mode == Vertical, corner, font_size, neutral_color, ChartWindowFind());
   TrendValueCellFactory* factory = new TrendValueCellFactory(alert_on_close ? 1 : 0, Up_Color, Dn_Color, historical_Up_Color, historical_Dn_Color);
   factory.SetNeutralColor(neutral_color);
   factory.SetButtonTextColor(button_text_color);
   builder.AddCell(factory);
   builder.SetSymbols(Pairs, x_shift, 50);

   if (Include_M1)
      builder.AddTimeframe("M1", PERIOD_M1);
   if (Include_M5)
      builder.AddTimeframe("M5", PERIOD_M5);
   if (Include_M15)
      builder.AddTimeframe("M15", PERIOD_M15);
   if (Include_M30)
      builder.AddTimeframe("M30", PERIOD_M30);
   if (Include_H1)
      builder.AddTimeframe("H1", PERIOD_H1);
   if (Include_H4)
      builder.AddTimeframe("H4", PERIOD_H4);
   if (Include_D1)
      builder.AddTimeframe("D1", PERIOD_D1);
   if (Include_W1)
      builder.AddTimeframe("W1", PERIOD_W1);
   if (Include_MN1)
      builder.AddTimeframe("MN1", PERIOD_MN1);

   grid = builder.Build();

   return(0);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete grid;
   grid = NULL;
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
   grid.Draw(x_shift, 50);
   
   return 0;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75539

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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