// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71187


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
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property indicator_separate_window
#property strict

#define USE_HISTORIC

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
input int ma_period = 14; // MA Period
input ENUM_MA_METHOD ma_method = MODE_SMA; // Smoothing method
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

//Signaler v2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start inputal program
input string   program_path             = ""; // Path to the inputal program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

class Signaler
{
   string _prefix;
public:
   Signaler()
   {
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
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
         AdvancedAlert(advanced_key, message, "", "");
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

interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};

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

bool IsRed(string symbol, ENUM_TIMEFRAMES tf, int period)
{
   return iClose(symbol, tf, period) < iOpen(symbol, tf, period);
}

class UpCondition : public ACondition
{
public:
   UpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      return !IsRed(_symbol, _timeframe, period)
         && !IsRed(_symbol, _timeframe, period + 1)
         && IsRed(_symbol, _timeframe, period + 2)
         && iMA(_symbol, _timeframe, ma_period, 0, ma_method, PRICE_CLOSE, period) < iClose(_symbol, _timeframe, period);
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
      return IsRed(_symbol, _timeframe, period)
         && IsRed(_symbol, _timeframe, period + 1)
         && !IsRed(_symbol, _timeframe, period + 2)
         && iMA(_symbol, _timeframe, ma_period, 0, ma_method, PRICE_CLOSE, period) > iClose(_symbol, _timeframe, period);
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

// Empty cell v1.1

// Interface for a cell v1.1

#ifndef ICell_IMP
#define ICell_IMP

class ICell
{
public:
   virtual void Draw() = 0;
   virtual void HandleButtonClicks() = 0;
protected:
   void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 )
   { 
      ObjectDelete(nm); 
      ObjectCreate(nm, OBJ_LABEL, Window, 0, 0); 
      ObjectSet(nm, OBJPROP_CORNER, LabelCorner); 
      ObjectSet(nm, OBJPROP_XDISTANCE, xoff); 
      ObjectSet(nm, OBJPROP_YDISTANCE, yoff); 
      ObjectSet(nm, OBJPROP_BACK, false); 
      ObjectSetText(nm, LabelTexto, FSize, Font, LabelColor);
   }
};

#endif

#ifndef EmptyCell_IMP
#define EmptyCell_IMP

class EmptyCell : public ICell
{
public:
   virtual void Draw() { }
   virtual void HandleButtonClicks() {}
};

#endif
// Label cell v2.0



#ifndef LabelCell_IMP
#define LabelCell_IMP

class LabelCell : public ICell
{
   string _id;
   string _text; 
   int _x; 
   int _y;
   ENUM_BASE_CORNER _corner;
public:
   LabelCell(const string id, const string text, const int x, const int y, ENUM_BASE_CORNER corner) 
   { 
      _corner = corner;
      _id = id; 
      _text = text; 
      _x = x; 
      _y = y; 
   } 
   virtual void Draw() 
   { 
      ObjectMakeLabel(_id, _x, _y, _text, Labels_Color, _corner, WindowNumber, "Arial", font_size); 
   }

   virtual void HandleButtonClicks()
   {
      
   }
};

#endif
// Grid v1.1

// Row v1.1

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

   void Draw() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         _cells[i].Draw(); 
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

   void Add(ICell *cell) 
   {
      int count = ArraySize(_cells); 
      ArrayResize(_cells, count + 1); 
      _cells[count] = cell; 
   } 
};


#endif

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
   
   void Draw()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].Draw();
      }
   }

   void HandleButtonClicks()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].HandleButtonClicks();
      }
   }
};

#endif
// Interface for a cell factory v3.0



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
// Interface for a value formatter v2.0

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


// Trend value cell v5.2

#ifndef TrendValueCell_IMP
#define TrendValueCell_IMP

class TrendValueCell : public ICell
{
   string _id;
   int _x;
   int _y;
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
   TrendValueCell(const string id, const int x, const int y, ENUM_BASE_CORNER corner, const string symbol, 
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
      _x = x; 
      _y = y; 
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

   virtual void Draw()
   {
      datetime date = iTime(_symbol, _timeframe, _alertShift);
      for (int i = 0; i < ArraySize(_conditions); ++i)
      {
         if (_conditions[i].IsPass(_alertShift, date))
         {
            color textColor, bgColor;
            string text = _valueFormatters[i].FormatItem(_alertShift, date, textColor, bgColor);
            DrawItem(text, textColor, bgColor);
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
         DrawHistoricalValue();
         return;
      }
      color textColor, bgColor;
      string text = _defaultValue.FormatItem(_alertShift, date, textColor, bgColor);
      DrawItem(text, textColor, bgColor);
   }

private:
   void DrawHistoricalValue()
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
               DrawItem(text, textColor, bgColor);
               return;
            }
         }
      }
   }
   void DrawItem(string text, color textColor, color bgColor)
   {
      string id = _id + "B";
      if (_outputMode == OutputLabels)
      {
         ObjectDelete(id);
         ObjectMakeLabel(id, _x, _y, text, textColor, _corner, WindowNumber, "Arial", font_size); 
      }
      else
      {
         ObjectDelete(id);
         if (ObjectFind(id) < 0)
         {
            ObjectCreate(id, OBJ_BUTTON, WindowNumber, 0, 0);
         }
         
         ObjectSet(id, OBJPROP_CORNER, _corner);
         ObjectSet(id, OBJPROP_XDISTANCE, _x);
         ObjectSet(id, OBJPROP_YDISTANCE, _y);
         ObjectSetString(0, id, OBJPROP_FONT, "Arial");
         ObjectSetString(0, id, OBJPROP_TEXT, text);
         ObjectSetInteger(0, id, OBJPROP_COLOR, textColor);
         ObjectSetInteger(0, id, OBJPROP_BGCOLOR, bgColor);
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, font_size);
         TextSetFont("Arial", -font_size * 10);
         int width, height;
         TextGetSize(text, width, height);
         ObjectSetInteger(0, id, OBJPROP_XSIZE, MathMax(cell_width, width + 5));
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
// Fixed text and color formatter v2.0

// Abstract value formatter v1.0



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

// Trend value cell factory v6.0

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
public:
   TrendValueCellFactory(int alertShift = 0, color upColor = Green, color downColor = Red, color historicalUpColor = Lime, color historicalDownColor = Pink)
   {
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

   virtual ICell* Create(const string id, const int x, const int y, ENUM_BASE_CORNER corner, const string symbol, const ENUM_TIMEFRAMES timeframe, bool showHistorical)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", GetTextColor(_neutralColor), GetBackgroundColor(_neutralColor));
      TrendValueCell* cell = new TrendValueCell(id, x, y, corner, symbol, timeframe, _alertShift, defaultValue, output_mode);
      defaultValue.Release();

      ICondition* upCondition = new UpCondition(symbol, timeframe);
      IValueFormatter* upValue = new FixedTextFormatter("Buy", GetTextColor(_upColor), GetBackgroundColor(_upColor));
      IValueFormatter* historyUpValue = NULL;
      if (showHistorical)
      {
         historyUpValue = new FixedTextFormatter("Buy", GetTextColor(_historicalUpColor), GetBackgroundColor(_historicalUpColor));
      }
      cell.AddCondition(upCondition, upValue, historyUpValue, upValue);
      upCondition.Release();
      upValue.Release();
      if (historyUpValue != NULL)
      {
         historyUpValue.Release();
      }

      ICondition* downCondition = new DownCondition(symbol, timeframe);
      IValueFormatter* downValue = new FixedTextFormatter("Sell", GetTextColor(_downColor), GetBackgroundColor(_downColor));
      IValueFormatter* historyDownValue = NULL;
      if (showHistorical)
      {
         historyDownValue = new FixedTextFormatter("Sell", GetTextColor(_historicalDownColor), GetBackgroundColor(_historicalDownColor));
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

// Grid builder v4.0



#ifndef GridBuilder_IMP
#define GridBuilder_IMP

class GridBuilder
{
   string _symbols[];
   int _symbolsCount;
   Grid *grid;
   int _originalX;
   int _originalY;
   Iterator _xIterator;
   Iterator _yIterator;
   bool _verticalMode;
   int _cellHeight;
   int _headerHeight;
   ICellFactory* _cellFactory[];
   ENUM_BASE_CORNER _corner;
   bool _showHistorical;
public:
   GridBuilder(int x, int y, int headerHeight, int cellHeight, bool verticalMode, ENUM_BASE_CORNER __corner, bool showHistorical)
      :_xIterator(x, -cell_width), _yIterator(y, cellHeight)
   {
      _showHistorical = showHistorical;
      _corner = __corner;
      _cellHeight = cellHeight;
      _headerHeight = headerHeight;
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
         Iterator yIterator(_originalY, _cellHeight);
         if (cellFactorySize > 1)
         {
            yIterator.GetNext();
         }
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], _originalX + cell_width, yIterator.GetNext(), _corner));
         }
      }
      else
      {
         //TODO: add support of multiple values
         Iterator xIterator(_originalX - cell_width, -cell_width);
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], xIterator.GetNext(), _originalY - _headerHeight, _corner));
         }
      }
   }

   void AddTimeframe(const string label, const ENUM_TIMEFRAMES timeframe)
   {
      int cellFactorySize = ArraySize(_cellFactory);
      if (_verticalMode)
      {
         int x[];
         ArrayResize(x, cellFactorySize);
         for (int ii = 0; ii < cellFactorySize; ++ii)
         {
            x[ii] = _xIterator.GetNext();
         }

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
               column[ii].Add(new LabelCell(IndicatorObjPrefix + label + "_h", label, x[0], _headerHeight, _corner));
            }
            #endif
         }
         
         Iterator yIterator(_originalY, _cellHeight);
         if (cellFactorySize > 1)
         {
            int y = yIterator.GetNext();
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               string index = IntegerToString(ii + 1);
               column[ii].Add(new LabelCell(IndicatorObjPrefix + label + "_sh" + index, _cellFactory[ii].GetHeader(), x[ii], y, _corner));
            }
         }

         for (int i = 0; i < _symbolsCount; i++)
         {
            int y = yIterator.GetNext();
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               string id = IndicatorObjPrefix + _symbols[i] + "_" + label + IntegerToString(ii);
               column[ii].Add(_cellFactory[ii].Create(id, x[ii], y, _corner, _symbols[i], timeframe, _showHistorical));
            }
         }
      }
      else
      {
         //TODO: add support of multiple values
         int y[];
         ArrayResize(y, cellFactorySize);
         for (int ii = 0; ii < cellFactorySize; ++ii)
         {
            y[ii] = _yIterator.GetNext();
         }
         Row* row = grid.AddRow();
         #ifndef EXCLUDE_PERIOD_HEADER
            row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, _originalX, y[0], _corner));
         #endif
         Iterator xIterator(_originalX - cell_width, -cell_width);
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            int x = xIterator.GetNext();
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               row.Add(_cellFactory[ii].Create(id, x, y[ii], _corner, _symbols[i], timeframe, _showHistorical));
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

string IndicatorName = "...";
int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }

   IndicatorObjPrefix = GenerateIndicatorPrefix("indi_short");
   IndicatorShortName(IndicatorName);

   #ifdef USE_HISTORIC
   bool showHistorical = true;
   #else
   bool showHistorical = false;
   #endif
   GridBuilder builder(x_shift, 50, cell_height, cell_height, display_mode == Vertical, corner, showHistorical);
   TrendValueCellFactory* factory = new TrendValueCellFactory(alert_on_close ? 1 : 0, Up_Color, Dn_Color, historical_Up_Color, historical_Dn_Color);
   factory.SetNeutralColor(neutral_color);
   factory.SetButtonTextColor(button_text_color);
   builder.AddCell(factory);
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
   grid.Draw();
   
   return 0;
}
