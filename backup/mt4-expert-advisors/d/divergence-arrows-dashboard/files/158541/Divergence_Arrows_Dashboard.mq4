//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75699

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
// Implement UpCondition and DownCondition!
string IndicatorName = "Divergence Arrows Dashboard";
string IndicatorShortName = "DAD";

#property indicator_separate_window
#property strict

#define USE_HISTORIC
#define EXCLUDE_PERIOD_HEADER

enum DisplayMode
{
   Vertical,
   Horizontal
};

enum OutputMode
{
   OutputLabels, // Labels
   OutputButtonsNewWindow, // New chart buttons
   OutputButtons // Current chart buttons
};
input OutputMode output_mode            = OutputLabels; // Mode
input string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
input string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD"; // Pairs
input bool     Include_M1               = false; // Include M1
input bool     Include_M5               = false; // Include M5
input bool     Include_M15              = false; // Include M15
input bool     Include_M30              = false; // Include M30
input bool     Include_H1               = true; // Include H1
input bool     Include_H4               = false; // Include H4
input bool     Include_D1               = true; // Include D1
input bool     Include_W1               = true; // Include W1
input bool     Include_MN1              = false; // Include MN1
input color    Labels_Color             = clrWhite; // Labels color
input color    button_text_color        = Black; // Button text color
input int min_button_width              = 30; // Min button width
#ifdef USE_HISTORIC
   input color    historical_Up_Color   = Green; // Historical up color
#else
   color    historical_Up_Color         = Green; // Historical up color
#endif
input color    Up_Color                 = Lime; // Up color
input bool draw_arrows = false; // Draw arrows instead of text
#ifdef USE_HISTORIC
   input color    historical_Dn_Color   = Red; // Historical down color
#else
   color    historical_Dn_Color         = Red; // Historical down color
#endif
input color    Dn_Color                 = Pink; // Down color
input color    neutral_color            = clrDarkGray; // Neutral color
input int x_shift                       = 900; // X coordinate
input ENUM_BASE_CORNER corner           = CORNER_LEFT_UPPER; // Corner
input DisplayMode display_mode          = Vertical; // Display mode
input int font_size                     = 10; // Font Size;
input int cell_width                    = 80; // Cell width
input int cell_height                   = 30; // Cell height
input bool alert_on_close               = false; // Alert on bar close

//Signaler v2.2
// More templates and snippets on https://github.com/sibvic/mq4-templates
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

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
void AdvancedAlertCustom(string key, string text, string instrument, string timeframe, string url);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

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

      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlertCustom(advanced_key, message, "", "", advanced_server);
   }
};


#define MAX_LOOPBACK 500

string   WindowName;
int      WindowNumber;

// ACondition v2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef ACondition_IMP
#define ACondition_IMP
// Abstract condition v1.1

// ICondition v3.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef ICondition_DEF
#define ICondition_DEF

interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};
#endif

#ifndef AConditionBase_IMP
#define AConditionBase_IMP

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

class ACondition : public AConditionBase
{
protected:
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo *_instrument;
   string _symbol;
public:
   ACondition(const string symbol, ENUM_TIMEFRAMES timeframe, string name = "")
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

class UpCondition : public ACondition
{
public:
   UpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double AvgRange = 0;
      for (int counter = 0; counter <= 9; counter++)
      {
         AvgRange += MathAbs(iHigh(_Symbol, _Period, period) - iLow(_Symbol, _Period, period));
      }
      double Range = AvgRange / 10.0;
      double LPair1a      = iLow(_symbol, _timeframe, period + 2);
      double LPair1      = iLow(_symbol, _timeframe, period + 1);
      double LPairCa      = iLow(Symbol(), _Period, period + 2);
      double LPairC      = iLow(Symbol(), _Period, period + 1);
      double HPair1a      = iHigh(_symbol, _timeframe, period + 2);
      double HPair1      = iHigh(_symbol, _timeframe, period + 1);
      double HPairCa      = iHigh(Symbol(), _Period, period + 2);
      double HPairC      = iHigh(Symbol(), _Period, period + 1);
      
      return LPair1 < LPair1a && LPairC > LPairCa;
   }
};

class DownCondition : public ACondition
{
public:
   DownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double AvgRange = 0;
      for (int counter = 0; counter <= 9; counter++)
      {
         AvgRange += MathAbs(iHigh(_Symbol, _Period, period) - iLow(_Symbol, _Period, period));
      }
      double Range = AvgRange / 10.0;
      double LPair1a      = iLow(_symbol, _timeframe, period + 2);
      double LPair1      = iLow(_symbol, _timeframe, period + 1);
      double LPairCa      = iLow(Symbol(), _Period, period + 2);
      double LPairC      = iLow(Symbol(), _Period, period + 1);
      double HPair1a      = iHigh(_symbol, _timeframe, period + 2);
      double HPair1      = iHigh(_symbol, _timeframe, period + 1);
      double HPairCa      = iHigh(Symbol(), _Period, period + 2);
      double HPairC      = iHigh(Symbol(), _Period, period + 1);
      
      return HPair1 > HPair1a && HPairC < HPairCa;
   }
};

// Dashboard v.1.2
class Iterator
{
   int _initialValue; int _shift; int _current;
public:
   Iterator(int initialValue, int shift) { _initialValue = initialValue; _shift = shift; _current = _initialValue - _shift; }
   int GetNext() { _current += _shift; return _current; }
};

// Interface for a cell v2.0

#ifndef ICell_IMP
#define ICell_IMP

class ICell
{
public:
   virtual void Draw(int x, int y) = 0;
   virtual void HandleButtonClicks() = 0;
   virtual void Measure(int& width, int& height) = 0;
};

#endif

// ACell v1.1

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
      ObjectDelete(nm); 
      ObjectCreate(nm, OBJ_LABEL, Window, 0, 0); 
      ObjectSet(nm, OBJPROP_CORNER, LabelCorner); 
      ObjectSet(nm, OBJPROP_XDISTANCE, xoff); 
      ObjectSet(nm, OBJPROP_YDISTANCE, yoff); 
      ObjectSet(nm, OBJPROP_BACK, false); 
      ObjectSetText(nm, text, FSize, Font, LabelColor);
   }
};

// Empty cell v2.1

#ifndef EmptyCell_IMP
#define EmptyCell_IMP

class EmptyCell : public ACell
{
public:
   virtual void Draw(int x, int y) { }
   virtual void Measure(int& width, int& height)
   {
      width = 0;
      height = 0;
   }
   virtual void HandleButtonClicks() {}
};

#endif


// Label cell v4.0

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
      _color = clr;
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

   virtual void Draw(int x, int y) 
   {
      if (_withBackground)
      {
         ObjectCreate(_id + "rect", OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, _id + "rect", OBJPROP_XDISTANCE, x);
         ObjectSetInteger(0, _id + "rect", OBJPROP_YDISTANCE, y);
         ObjectSetInteger(0, _id + "rect", OBJPROP_BGCOLOR, _bgColor); 
         ObjectSetInteger(0, _id + "rect", OBJPROP_XSIZE, _width);
         ObjectSetInteger(0, _id + "rect", OBJPROP_YSIZE, _height);
         ObjectSetInteger(0, _id + "rect", OBJPROP_COLOR, _color);
         ObjectSetInteger(0, _id + "rect", OBJPROP_CORNER, _corner);
      }
      string lines[];
      int linesCount = StringSplit(_text, '\n', lines);
      for (int i = 0; i < linesCount; ++i)
      {
         int lineX = x;
         if (_textHAlign == "center")
         {
            lineX += (_width - _linesWidths[i]) / 2;
         }
         else if (_textHAlign == "right")
         {
            lineX += _width - _linesWidths[i];
         }
         ObjectMakeLabel(_id + "line" + i, lineX, y, lines[i], _color, _corner, _windowNumber, "Arial", _fontSize); 
         y += _linesHeights[i];
      }
   }
   
   bool SetBgColor(uint clr)
   {
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

// Row v2.2

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
         _cells[i].Draw(x, y);
         x += rowSizes.GetWidth(i);
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
// Interface for a cell factory v3.1



#ifndef ICellFactory_IMP
#define ICellFactory_IMP

class ICellFactory
{
public:
   virtual ICell* Create(const string id, const int x, const int y, ENUM_BASE_CORNER corner, const string symbol, const ENUM_TIMEFRAMES timeframe, bool showHistorical) = 0;
   virtual string GetHeader() = 0;
};

#endif


string TimeframeToString(ENUM_TIMEFRAMES tf)
{
   switch (tf)
   {
      case PERIOD_CURRENT: return TimeframeToString((ENUM_TIMEFRAMES)_Period);
      case PERIOD_M1: return "M1";
      case PERIOD_M5: return "M5";
      case PERIOD_D1: return "D1";
      case PERIOD_H1: return "H1";
      case PERIOD_H4: return "H4";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_MN1: return "MN1";
      case PERIOD_W1: return "W1";
   }
   return "";
}
// Interface for a value formatter v3.0

#ifndef IValueFormatter_IMP
#define IValueFormatter_IMP

class IValueFormatter
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual string FormatItem(const int period, const datetime date, color& textColor, color& bgColor, string& font) = 0;
};

#endif


// Trend value cell v7.0

#ifndef TrendValueCell_IMP
#define TrendValueCell_IMP

class TrendValueCell : public ACell
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
public:
   TrendValueCell(const string id, ENUM_BASE_CORNER corner, const string symbol, 
      const ENUM_TIMEFRAMES timeframe, int alertShift, 
      IValueFormatter* defaultValue, OutputMode outputMode)
   {
      _corner = corner;
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
      datetime date = iTime(_symbol, _timeframe, _alertShift);
      for (int i = 0; i < ArraySize(_conditions); ++i)
      {
         if (_conditions[i].IsPass(_alertShift, date))
         {
            color textColor, bgColor;
            string font;
            string text = _valueFormatters[i].FormatItem(_alertShift, date, textColor, bgColor, font);
            MeasureItem(text, font, width, height);
            return;
         }
      }
      if (_historicalMode)
      {
         MeasureHistoricalValue(width, height);
         return;
      }
      color textColor, bgColor;
      string font;
      string text = _defaultValue.FormatItem(_alertShift, date, textColor, bgColor, font);
      MeasureItem(text, font, width, height);
   }

   virtual void Draw(int x, int y)
   {
      datetime date = iTime(_symbol, _timeframe, _alertShift);
      for (int i = 0; i < ArraySize(_conditions); ++i)
      {
         if (_conditions[i].IsPass(_alertShift, date))
         {
            color textColor, bgColor;
            string font;
            string text = _valueFormatters[i].FormatItem(_alertShift, date, textColor, bgColor, font);
            DrawItem(x, y, text, textColor, bgColor, font);
            if (_signalFormatters[i] != NULL)
            {
               text = _signalFormatters[i].FormatItem(_alertShift, date, textColor, bgColor, font);
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
      string font;
      string text = _defaultValue.FormatItem(_alertShift, date, textColor, bgColor, font);
      DrawItem(x, y, text, textColor, bgColor, font);
   }

private:
   void MeasureHistoricalValue(int& width, int& height)
   {
      for (int period = _alertShift + 1; period < 1000; ++period)
      {
         datetime date = iTime(_symbol, _timeframe, period);
         for (int i = 0; i < ArraySize(_conditions); ++i)
         {
            if (_conditions[i].IsPass(period, date))
            {
               color textColor, bgColor;
               string font;
               string text = _historyValueFormatters[i].FormatItem(period, date, textColor, bgColor, font);
               MeasureItem(text, font, width, height);
               return;
            }
         }
      }
   }
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
               string font;
               string text = _historyValueFormatters[i].FormatItem(period, date, textColor, bgColor, font);
               DrawItem(x, y, text, textColor, bgColor, font);
               return;
            }
         }
      }
   }
   void MeasureItem(string text, string font, int& width, int& height)
   {
      string id = _id + "B";
      if (_outputMode == OutputLabels)
      {
         ObjectDelete(id);
         Measure(text, font, font_size, width, height); 
         return;
      }
      
      TextSetFont(font, -font_size * 10);
      TextGetSize(text, width, height);
      width += 5;
      height += 5;
   }

   void DrawItem(int x, int y, string text, color textColor, color bgColor, string font)
   {
      string id = _id + "B";
      if (_outputMode == OutputLabels)
      {
         ObjectDelete(id);
         ObjectMakeLabel(id, x, y, text, textColor, _corner, WindowNumber, font, font_size); 
      }
      else
      {
         ObjectDelete(id);
         if (ObjectFind(id) < 0)
         {
            ObjectCreate(id, OBJ_BUTTON, WindowNumber, 0, 0);
         }
         
         ObjectSet(id, OBJPROP_CORNER, _corner);
         ObjectSet(id, OBJPROP_XDISTANCE, x);
         ObjectSet(id, OBJPROP_YDISTANCE, y);
         ObjectSetString(0, id, OBJPROP_FONT, font);
         ObjectSetString(0, id, OBJPROP_TEXT, text);
         ObjectSetInteger(0, id, OBJPROP_COLOR, textColor);
         ObjectSetInteger(0, id, OBJPROP_BGCOLOR, bgColor);
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, font_size);
         TextSetFont(font, -font_size * 10);
         int w, h;
         TextGetSize(text, w, h);
         w += 5;
         h += 5;
         ObjectSetInteger(0, id, OBJPROP_XSIZE, w);
         ObjectSetInteger(0, id, OBJPROP_YSIZE, h);
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
// Fixed text and color formatter v3.0

// Abstract value formatter v1.1



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

#ifndef FixedTextFormatter_IMP
#define FixedTextFormatter_IMP
class FixedTextFormatter : public AValueFormatter
{
   string _text;
   color _clr;
   color _bgClr;
   string _font;
public:
   FixedTextFormatter(string text, color clr, color bgClr, string font)
   {
      _bgClr = bgClr;
      _text = text;
      _clr = clr;
      _font = font;
   }

   virtual string FormatItem(const int period, const datetime date, color& clr, color& bgColor, string& font)
   {
      clr = _clr;
      bgColor = _bgClr;
      font = _font;
      return _text;
   }
};
#endif
// Condition factory interface v1.0



#ifndef IConditionFactory_IMPL
#define IConditionFactory_IMPL
interface IConditionFactory
{
public:
   virtual ICondition* CreateUpCondition(const string symbol, const ENUM_TIMEFRAMES timeframe) = 0;
   virtual ICondition* CreateDownCondition(const string symbol, const ENUM_TIMEFRAMES timeframe) = 0;
};
#endif

// Trend value cell factory v7.1

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
   string _buyText;
   string _buyFont;
   string _sellText;
   string _sellFont;
   IConditionFactory* _conditionFactory;
public:
   TrendValueCellFactory(IConditionFactory* conditionFactory, int alertShift = 0, color upColor = Green, color downColor = Red, color historicalUpColor = Lime, color historicalDownColor = Pink)
   {
      _conditionFactory = conditionFactory;
      _buyFont = "Arial";
      _sellFont = "Arial";
      _buyText = "Buy";
      _sellText = "Sell";
      _alertShift = alertShift;
      _upColor = upColor;
      _downColor = downColor;
      _historicalUpColor = historicalUpColor;
      _historicalDownColor = historicalDownColor;
   }

   void SetBuyText(string text, string font)
   {
      _buyText = text;
      _buyFont = font;
   }
   void SetSellText(string text, string font)
   {
      _sellText = text;
      _sellFont = font;
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

   virtual ICell* Create(const string id, const int x, const int y, ENUM_BASE_CORNER corner, const string symbol, 
      const ENUM_TIMEFRAMES timeframe, bool showHistorical)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", GetTextColor(_neutralColor), GetBackgroundColor(_neutralColor), "Arial");
      TrendValueCell* cell = new TrendValueCell(id, corner, symbol, timeframe, _alertShift, defaultValue, output_mode);
      defaultValue.Release();

      ICondition* upCondition = _conditionFactory.CreateUpCondition(symbol, timeframe);
      IValueFormatter* upValue = new FixedTextFormatter(_buyText, GetTextColor(_upColor), GetBackgroundColor(_upColor), _buyFont);
      IValueFormatter* historyUpValue = NULL;
      if (showHistorical)
      {
         historyUpValue = new FixedTextFormatter(_buyText, GetTextColor(_historicalUpColor), GetBackgroundColor(_historicalUpColor), _buyFont);
      }
      cell.AddCondition(upCondition, upValue, historyUpValue, upValue);
      upCondition.Release();
      upValue.Release();
      if (historyUpValue != NULL)
      {
         historyUpValue.Release();
      }

      ICondition* downCondition = _conditionFactory.CreateDownCondition(symbol, timeframe);
      IValueFormatter* downValue = new FixedTextFormatter(_sellText, GetTextColor(_downColor), GetBackgroundColor(_downColor), _sellFont);
      IValueFormatter* historyDownValue = NULL;
      if (showHistorical)
      {
         historyDownValue = new FixedTextFormatter(_sellText, GetTextColor(_historicalDownColor), GetBackgroundColor(_historicalDownColor), _sellFont);
      }
      cell.AddCondition(downCondition, downValue, historyDownValue, downValue);
      downCondition.Release();
      downValue.Release();
      if (historyDownValue != NULL)
      {
         historyDownValue.Release();
      }

      return cell;
   }
private:
   color GetTextColor(color clr)
   {
      return output_mode == OutputLabels ? clr : _buttonTextColor;
   }
   color GetBackgroundColor(color clr)
   {
      return output_mode != OutputLabels ? clr : _buttonTextColor;
   }
};
#endif

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

Grid *grid;






// Grid builder v7.0

#ifndef GridBuilder_IMP
#define GridBuilder_IMP

class GridBuilder
{
   string _symbols[];
   int _symbolsCount;
   Grid *grid;
   int _originalX;
   int _originalY;
   bool _verticalMode;
   ICellFactory* _cellFactory[];
   ENUM_BASE_CORNER _corner;
   bool _showHistorical;
   string prefix;
   int windowNumber;
public:
   GridBuilder(int x, int y, bool verticalMode, ENUM_BASE_CORNER __corner, bool showHistorical, string prefix, int windowNumber)
   {
      this.windowNumber = windowNumber;
      this.prefix = prefix;
      _showHistorical = showHistorical;
      _corner = __corner;
      _verticalMode = verticalMode;
      _originalY = y;
      _originalX = x;
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

   void SetSymbols(const string symbols)
   {
      StringSplit(symbols, ',', _symbols);
      _symbolsCount = ArraySize(_symbols);

      int cellFactorySize = ArraySize(_cellFactory);
      if (_verticalMode)
      {
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         if (cellFactorySize > 1)
         {
            row = grid.AddRow();
            row.Add(new EmptyCell());
         }
         for (int i = 0; i < _symbolsCount; i++)
         {
            row = grid.AddRow();
            string id = prefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], _corner, 12, clrGray, windowNumber));
         }
      }
      else
      {
         //TODO: add support of multiple values
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = prefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], _corner, 12, clrGray, windowNumber));
         }
      }
   }

   void AddTimeframe(const string label, const ENUM_TIMEFRAMES timeframe)
   {
      int cellFactorySize = ArraySize(_cellFactory);
      if (_verticalMode)
      {
         int startIndex = 1;
         Row* header = grid.GetRow(0);
         header.Add(new LabelCell(prefix + label + "_h", label, _corner, 12, clrGray, windowNumber));
         if (cellFactorySize > 1)
         {
            ++startIndex;
            Row* subHeader = grid.GetRow(1);
            for (int i = 0; i < cellFactorySize; ++i)
            {
               if (i > 0)
               {
                  header.Add(new EmptyCell());
               }
               subHeader.Add(new LabelCell(prefix + label + "_sh" + IntegerToString(i), _cellFactory[i].GetHeader(), _corner, 12, clrGray, windowNumber));
            }
         }
         
         for (int i = 0; i < _symbolsCount; i++)
         {
            Row* row = grid.GetRow(startIndex + i);
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               string id = prefix + _symbols[i] + "_" + label + IntegerToString(ii);
               row.Add(_cellFactory[ii].Create(id, 0, 0, _corner, _symbols[i], timeframe, _showHistorical));
            }
         }
      }
      else
      {
         //TODO: add support of multiple values
         Row* row = grid.AddRow();
         #ifndef EXCLUDE_PERIOD_HEADER
            row.Add(new LabelCell(prefix + label + "_Label", label, _corner, 12, clrGray, 0));
         #endif
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = prefix + _symbols[i] + "_" + label;
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               row.Add(_cellFactory[ii].Create(id, 0, 0, _corner, _symbols[i], timeframe, _showHistorical));
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

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   grid.HandleButtonClicks();
}



class ConditionFactory : public IConditionFactory
{
public:
   ICondition* CreateUpCondition(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      return new UpCondition(symbol, timeframe);
   }
   ICondition* CreateDownCondition(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      return new DownCondition(symbol, timeframe);
   }
};

TrendValueCellFactory* Create(IConditionFactory* conditionFactory)
{
   TrendValueCellFactory* factory = new TrendValueCellFactory(conditionFactory, alert_on_close ? 1 : 0, Up_Color, Dn_Color, historical_Up_Color, historical_Dn_Color);
   if (draw_arrows)
   {
      factory.SetBuyText(CharToStr(225), "Wingdings");
      factory.SetSellText(CharToStr(226), "Wingdings"); 
   }
   factory.SetNeutralColor(neutral_color);
   factory.SetButtonTextColor(button_text_color);
   return factory;
}

int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }

   IndicatorObjPrefix = GenerateIndicatorPrefix(IndicatorShortName);
   IndicatorShortName(IndicatorName);

   #ifdef USE_HISTORIC
   bool showHistorical = true;
   #else
   bool showHistorical = false;
   #endif
   GridBuilder builder(x_shift, 50, display_mode == Vertical, corner, showHistorical, IndicatorObjPrefix, ChartWindowFind());
   builder.AddCell(Create(new ConditionFactory()));
   builder.SetSymbols(Pairs);

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

   if (output_mode != OutputLabels)
   {
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
   }

   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete grid;
   grid = NULL;
   return 0;
}

int start()
{
   WindowNumber = MathMax(0, WindowFind(IndicatorName));
   grid.HandleButtonClicks();
   grid.Draw(cell_height, cell_height);
   
   return 0;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75699

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