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
#property version   "1.0"

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
input color    Labels_Color             = clrWhite;
input color    Confirmed_Up_Color       = Green; // Confirmed up color
//input color    Unconfirmed_Up_Color     = Lime; // Unconfirmed up color
input color    Confirmed_Dn_Color       = Red; // Confirmed down color
//input color    Unconfirmed_Dn_Color     = Pink; // Unconfirmed down color
input color    Neutral_Color            = clrDarkGray;
input int x_shift = 900; // X coordinate
input DisplayMode display_mode = Vertical; // Display mode
input int font_size = 10; // Font Size;
input int cell_width = 80; // Cell width
input int cell_height = 30; // Cell height
input bool alert_on_close = false; // Alert of bar close

//Signaler v 1.7
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
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   string _prefix;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   string GetSymbol()
   {
      return _symbol;
   }

   ENUM_TIMEFRAMES GetTimeframe()
   {
      return _timeframe;
   }

   string GetTimeframeStr()
   {
      switch (_timeframe)
      {
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
      return "M1";
   }

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframeStr();

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
         AdvancedAlert(advanced_key, message, symbol, timeframe);
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
public:
   AConditionBase()
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

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "";
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
   ACondition(const string symbol, ENUM_TIMEFRAMES timeframe)
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

bool IsUpDirection(int period, string symbol, ENUM_TIMEFRAMES timeframe)
{
   double first = 0;
   double second = 0;
   for (int i = period; i < 1000; ++i)
   {
      double value = iCustom(symbol, timeframe, "GannSwing", 0, i);
      if (value != EMPTY_VALUE && value != 0)
      {
         if (first == 0)
         {
            first = value;
         }
         else
         {
            second = value;
            break;
         }
      }
   }
   return first > second;
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
      return IsUpDirection(period, _symbol, _timeframe);
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
      return !IsUpDirection(period, _symbol, _timeframe);
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
// Label cell v1.1



#ifndef LabelCell_IMP
#define LabelCell_IMP

class LabelCell : public ICell
{
   string _id;
   string _text; 
   int _x; 
   int _y;
public:
   LabelCell(const string id, const string text, const int x, const int y) 
   { 
      _id = id; 
      _text = text; 
      _x = x; 
      _y = y; 
   } 
   virtual void Draw() 
   { 
      ObjectMakeLabel(_id, _x, _y, _text, Labels_Color, 1, WindowNumber, "Arial", font_size); 
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
// Interface for a cell factory v1.0



#ifndef ICellFactory_IMP
#define ICellFactory_IMP

class ICellFactory
{
public:
   virtual ICell* Create(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe) = 0;
   virtual string GetHeader() = 0;
};

#endif
// Trend value cell v2.3

#ifndef TrendValueCell_IMP
#define TrendValueCell_IMP



// Interface for a value formatter v1.0

#ifndef IValueFormatter_IMP
#define IValueFormatter_IMP

class IValueFormatter
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual string FormatItem(const int period, const datetime date, color& clr) = 0;
};

#endif


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
   Signaler* _signaler;
   datetime _lastSignalDate;
   int _lastSignal;
   int _alertShift;
   IValueFormatter* _defaultValue;
public:
   TrendValueCell(const string id, const int x, const int y, const string symbol, 
      const ENUM_TIMEFRAMES timeframe, int alertShift, 
      IValueFormatter* defaultValue)
   { 
      _lastSignal = 0;
      _alertShift = alertShift;
      _signaler = new Signaler(symbol, timeframe);
      _signaler.SetMessagePrefix(symbol + "/" + _signaler.GetTimeframeStr() + ": ");
      _id = id; 
      _x = x; 
      _y = y; 
      _symbol = symbol;
      _timeframe = timeframe;
      _defaultValue = defaultValue;
      _defaultValue.AddRef();
   }

   ~TrendValueCell()
   {
      delete _signaler;
      _defaultValue.Release();
      for (int i = 0; i < ArraySize(_conditions); ++i)
      {
         _conditions[i].Release();
         _valueFormatters[i].Release();
      }
      ArrayResize(_conditions, 0);
      ArrayResize(_valueFormatters, 0);
   }

   void AddCondition(ICondition* condition, IValueFormatter* value)
   {
      int size = ArraySize(_conditions);
      ArrayResize(_conditions, size + 1);
      ArrayResize(_valueFormatters, size + 1);
      _conditions[size] = condition;
      condition.AddRef();
      _valueFormatters[size] = value;
      value.AddRef();
   }

   virtual void HandleButtonClicks()
   {
      for (int i = 0; i < ArraySize(_conditions); ++i)
      {
         string id = _id + "B";
         if (ObjectGetInteger(0, id, OBJPROP_STATE))
         {
            ObjectSetInteger(0, id, OBJPROP_STATE, false);
            ChartOpen(_symbol, _timeframe);
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
            color clr;
            string text = _valueFormatters[i].FormatItem(_alertShift, date, clr);
            DrawItem(text, clr, true);
            SendAlert(text, i);
            return;
         }
      }
      color clr;
      string text = _defaultValue.FormatItem(_alertShift, date, clr);
      DrawItem(text, clr, true);
   }

private:
   void DrawItem(string text, color clr, bool simpleLabel)
   {
      string id = _id + "B";
      if (simpleLabel)
      {
         ObjectDelete(id);
         ObjectMakeLabel(id, _x, _y, text, clr, 1, WindowNumber, "Arial", font_size); 
      }
      else
      {
         ObjectDelete(id);
         if (ObjectFind(id) < 0)
         {
            ObjectCreate(id, OBJ_BUTTON, WindowNumber, 0, 0);
         }
         ObjectSet(id, OBJPROP_XDISTANCE, _x);
         ObjectSet(id, OBJPROP_YDISTANCE, _y);
         ObjectSet(id, OBJPROP_CORNER, 1); 
         ObjectSetString(0, id, OBJPROP_FONT, "Arial");
         ObjectSetString(0, id, OBJPROP_TEXT, text);
         ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, font_size);
         TextSetFont("Arial", -font_size * 10);
         int width, height;
         TextGetSize(text, width, height);
         ObjectSetInteger(0, id, OBJPROP_XSIZE, width + 5);
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
// Fixed text and color formatter v1.0

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
public:
   FixedTextFormatter(string text, color clr)
   {
      _text = text;
      _clr = clr;
   }

   virtual string FormatItem(const int period, const datetime date, color& clr)
   {
      clr = _clr;
      return _text;
   }
};
#endif

// Trend value cell factory v2.0

#ifndef TrendValueCellFactory_IMP
#define TrendValueCellFactory_IMP

class TrendValueCellFactory : public ICellFactory
{
   int _alertShift;
   color _upColor;
   color _downColor;
public:
   TrendValueCellFactory(int alertShift = 0, color upColor = Green, color downColor = Red)
   {
      _alertShift = alertShift;
      _upColor = upColor;
      _downColor = downColor;
   }

   virtual string GetHeader()
   {
      return "Value";
   }

   virtual ICell* Create(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", Neutral_Color);
      TrendValueCell* cell = new TrendValueCell(id, x, y, symbol, timeframe, _alertShift, defaultValue);
      defaultValue.Release();

      ICondition* upCondition = new UpCondition(symbol, timeframe);
      IValueFormatter* upValue = new FixedTextFormatter("Buy", _upColor);
      cell.AddCondition(upCondition, upValue);
      upCondition.Release();
      upValue.Release();

      ICondition* downCondition = new DownCondition(symbol, timeframe);
      IValueFormatter* downValue = new FixedTextFormatter("Sell", _downColor);
      cell.AddCondition(downCondition, downValue);
      downCondition.Release();
      downValue.Release();

      return cell;
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

// Grid builder v2.1



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
public:
   GridBuilder(int x, int y, int headerHeight, int cellHeight, bool verticalMode)
      :_xIterator(x, -cell_width), _yIterator(y, cellHeight)
   {
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
            row.Add(new LabelCell(id, _symbols[i], _originalX + cell_width, yIterator.GetNext()));
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
            row.Add(new LabelCell(id, _symbols[i], xIterator.GetNext(), _originalY - _headerHeight));
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
            if (ii > 0)
            {
               column[ii].Add(new EmptyCell());
            }
            else
            {
               column[ii].Add(new LabelCell(IndicatorObjPrefix + label + "_h", label, x[0], _headerHeight));
            }
         }
         
         Iterator yIterator(_originalY, _cellHeight);
         if (cellFactorySize > 1)
         {
            int y = yIterator.GetNext();
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               string index = IntegerToString(ii + 1);
               column[ii].Add(new LabelCell(IndicatorObjPrefix + label + "_sh" + index, _cellFactory[ii].GetHeader(), x[ii], y));
            }
         }

         for (int i = 0; i < _symbolsCount; i++)
         {
            int y = yIterator.GetNext();
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               string id = IndicatorObjPrefix + _symbols[i] + "_" + label + IntegerToString(ii);
               column[ii].Add(_cellFactory[ii].Create(id, x[ii], y, _symbols[i], timeframe));
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
         row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, _originalX, y[0]));
         Iterator xIterator(_originalX - cell_width, -cell_width);
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            int x = xIterator.GetNext();
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               row.Add(_cellFactory[ii].Create(id, x, y[ii], _symbols[i], timeframe));
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

// void handleButtonClicks()
// {
//    int pair_num = ArraySize(pairs) - 1;
//    for (int p = 0; p < pair_num; p++)
//    {
//       string pair = pairs[p];
//       for (int t = 0; t < ArraySize(iTF); t++)
//       {  
//          if (!bTF[t])
//             continue;
      
//          string arrow_id = Pref + "AO direction " + pair + " " + sTF[t];
//          if (ObjectGetInteger(0, arrow_id, OBJPROP_STATE))
//          {
//             ObjectSetInteger(0, arrow_id, OBJPROP_STATE, false);
//             ChartSetSymbolPeriod(0, pair, iTF[t]);
//             return;
//          }
//       }
//       string symbolId = "ADR " + pair;
//       if (ObjectGetInteger(0, symbolId, OBJPROP_STATE))
//       {
//          ObjectSetInteger(0, symbolId, OBJPROP_STATE, false);
//          ChartOpen(pair, _Period);
//          return;
//       }
//    }
// }

// void DrawSymbolButton(string name, int corn, int x, int y, int width, int height, string symbol, color Clr=Green, int Win=0, int FSize=10)
// {
//    int Error = ObjectFind(name);
//    if (Error != Win)
//       ObjectCreate(name, OBJ_BUTTON, Win, 0, 0);
     
//    ObjectSet(name, OBJPROP_CORNER, corn);
//    ObjectSet(name, OBJPROP_XDISTANCE, x);
//    ObjectSet(name, OBJPROP_YDISTANCE, y);
//    ObjectSetString(0, name, OBJPROP_FONT, "Arial");
//    ObjectSetString(0, name, OBJPROP_TEXT, symbol);
//    ObjectSetInteger(0, name, OBJPROP_COLOR, Clr);
//    ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
//    ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
//    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FSize);
// }

int init()
{
   double temp = iCustom(NULL, 0, "GannSwing", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'GannSwing' indicator");
      return INIT_FAILED;
   }
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }

   IndicatorObjPrefix = GenerateIndicatorPrefix("gsd");
   IndicatorShortName("GannSwing Dashboard");

   GridBuilder builder(x_shift, 50, cell_height, cell_height, display_mode == Vertical);
   builder.AddCell(new TrendValueCellFactory(alert_on_close ? 1 : 0, Confirmed_Up_Color, Confirmed_Dn_Color));
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

   //ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);

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
   //handleButtonClicks();
   WindowNumber = MathMax(0, WindowFind("GannSwing Dashboard"));
   grid.HandleButtonClicks();
   grid.Draw();
   
   return 0;
}
