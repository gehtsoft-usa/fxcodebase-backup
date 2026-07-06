// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68827

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
#property version   "1.2"
#property strict

#property indicator_separate_window

extern int  Tenkan_Sen_Period                = 9;
extern int  Kijun_Sen_Period                 = 26;
extern int  Senkou_Span_B_Period             = 52;

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
input color    Up_Color                 = clrLime;
input color    Dn_Color                 = clrRed;
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
// Instrument info v.1.6
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

class UpCondition : public ACondition
{
public:
   UpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double TENKANSEN_0 = iIchimoku(_symbol, _timeframe, Tenkan_Sen_Period, Kijun_Sen_Period, Senkou_Span_B_Period, 1, period);
      double KIJUNSEN_0 = iIchimoku(_symbol, _timeframe, Tenkan_Sen_Period, Kijun_Sen_Period, Senkou_Span_B_Period, 2, period);
      double TENKANSEN_1 = iIchimoku(_symbol, _timeframe, Tenkan_Sen_Period, Kijun_Sen_Period, Senkou_Span_B_Period, 1, period + 1);
      double KIJUNSEN_1 = iIchimoku(_symbol, _timeframe, Tenkan_Sen_Period, Kijun_Sen_Period, Senkou_Span_B_Period, 2, period + 1);
      
      return TENKANSEN_0 > KIJUNSEN_0 && TENKANSEN_1 <= KIJUNSEN_1;
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
      double TENKANSEN_0 = iIchimoku(_symbol, _timeframe, Tenkan_Sen_Period, Kijun_Sen_Period, Senkou_Span_B_Period, 1, period);
      double KIJUNSEN_0 = iIchimoku(_symbol, _timeframe, Tenkan_Sen_Period, Kijun_Sen_Period, Senkou_Span_B_Period, 2, period);
      double TENKANSEN_1 = iIchimoku(_symbol, _timeframe, Tenkan_Sen_Period, Kijun_Sen_Period, Senkou_Span_B_Period, 1, period + 1);
      double KIJUNSEN_1 = iIchimoku(_symbol, _timeframe, Tenkan_Sen_Period, Kijun_Sen_Period, Senkou_Span_B_Period, 2, period + 1);
      
      return TENKANSEN_0 < KIJUNSEN_0 && TENKANSEN_1 >= KIJUNSEN_1;
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

// Interface for a cell v1.0

#ifndef ICell_IMP
#define ICell_IMP

class ICell
{
public:
   virtual void Draw() = 0;
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
};

#endif
// Label cell v1.0



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
};

#endif
// Grid v1.0

// Row v1.0

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
};

#endif
// Trend value cell factory v1.1

// Interface for a cell factory v1.0



#ifndef ICellFactory_IMP
#define ICellFactory_IMP

class ICellFactory
{
public:
   virtual ICell* Create(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe) = 0;
};

#endif
// Trend value cell v1.3

#ifndef TrendValueCell_IMP
#define TrendValueCell_IMP




#ifndef ENTER_BUY_SIGNAL
#define ENTER_BUY_SIGNAL 1
#endif
#ifndef ENTER_SELL_SIGNAL
#define ENTER_SELL_SIGNAL -1
#endif

class TrendValueCell : public ICell
{
   string _id; int _x; int _y; string _symbol; ENUM_TIMEFRAMES _timeframe; datetime _lastDatetime;
   ICondition* _upCondition;
   ICondition* _downCondition;
   Signaler* _signaler;
   datetime _lastSignalDate;
   int _lastSignal;
   int _alertShift;
public:
   TrendValueCell(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe, int alertShift)
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
      _upCondition = CreateUpCondition(_symbol, _timeframe);
      _downCondition = CreateDownCondition(_symbol, _timeframe);
   }

   ~TrendValueCell()
   {
      delete _signaler;
      delete _upCondition;
      delete _downCondition;
   }

   virtual void Draw()
   { 
      int direction = GetDirection(); 
      ObjectMakeLabel(_id, _x, _y, GetDirectionSymbol(direction), GetDirectionColor(direction), 1, WindowNumber, "Arial", font_size); 
      if (Time[0] != _lastSignalDate && _lastSignal != direction)
      {
         switch (direction)
         {
            case ENTER_BUY_SIGNAL:
               _signaler.SendNotifications("Buy");
               _lastSignalDate = Time[0];
               break;
            case ENTER_SELL_SIGNAL:
               _signaler.SendNotifications("Sell");
               _lastSignalDate = Time[0];
               break;
         }
         _lastSignal = direction;
      }
   }

private:
   int GetDirection()
   {
      datetime date = iTime(_symbol, _timeframe, _alertShift);
      if (_upCondition.IsPass(_alertShift, date))
         return ENTER_BUY_SIGNAL;
      if (_downCondition.IsPass(_alertShift, date))
         return ENTER_SELL_SIGNAL;
      return 0;
   }

   color GetDirectionColor(const int direction) { if (direction >= 1) { return Up_Color; } else if (direction <= -1) { return Dn_Color; } return Neutral_Color; }
   string GetDirectionSymbol(const int direction)
   {
      if (direction == ENTER_BUY_SIGNAL)
         return "BUY";
      else if (direction == ENTER_SELL_SIGNAL)
         return "SELL";
      return "-";
   }
};
#endif

#ifndef TrendValueCellFactory_IMP
#define TrendValueCellFactory_IMP

class TrendValueCellFactory : public ICellFactory
{
   int _alertShift;
public:
   TrendValueCellFactory(int alertShift = 0)
   {
      _alertShift = alertShift;
   }

   virtual ICell* Create(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      return new TrendValueCell(id, x, y, symbol, timeframe, _alertShift);
   }
};
#endif

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

Grid *grid;

// Grid builder v2.0



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
   ICellFactory* _cellFactory;
public:
   GridBuilder(int x, int y, int headerHeight, int cellHeight, bool verticalMode, ICellFactory* cellFactory)
      :_xIterator(x, -cell_width), _yIterator(y, cellHeight)
   {
      _cellHeight = cellHeight;
      _headerHeight = headerHeight;
      _cellFactory = cellFactory;
      _verticalMode = verticalMode;
      _originalY = y;
      _originalX = x;
      grid = new Grid();
   }

   ~GridBuilder()
   {
      delete _cellFactory;
   }

   void SetSymbols(const string symbols)
   {
      split(_symbols, symbols, ",");
      _symbolsCount = ArraySize(_symbols);

      if (_verticalMode)
      {
         Iterator yIterator(_originalY, _cellHeight);
         Row *row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], _originalX + cell_width, yIterator.GetNext()));
         }
      }
      else
      {
         Iterator xIterator(_originalX - cell_width, -cell_width);
         Row *row = grid.AddRow();
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
      if (_verticalMode)
      {
         int x = _xIterator.GetNext();
         Row *row = grid.AddRow();
         row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, x, _headerHeight));
         Iterator yIterator(_originalY, _cellHeight);
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            row.Add(_cellFactory.Create(id, x, yIterator.GetNext(), _symbols[i], timeframe));
         }
      }
      else
      {
         int y = _yIterator.GetNext();
         Row *row = grid.AddRow();
         row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, _originalX, y));
         Iterator xIterator(_originalX - cell_width, -cell_width);
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            row.Add(_cellFactory.Create(id, xIterator.GetNext(), y, _symbols[i], timeframe));
         }
      }
   }

   Grid* Build()
   {
      return grid;
   }

private:
   void split(string& arr[], string str, string sym) 
   {
      ArrayResize(arr, 0);
      int len = StringLen(str);
      for (int i=0; i < len;)
      {
         int pos = StringFind(str, sym, i);
         if (pos == -1)
            pos = len;
   
         string item = StringSubstr(str, i, pos-i);
         item = StringTrimLeft(item);
         item = StringTrimRight(item);
   
         int size = ArraySize(arr);
         ArrayResize(arr, size+1);
         arr[size] = item;
   
         i = pos+1;
      }
   }
};
#endif

// void OnChartEvent(const int id,
//                   const long &lparam,
//                   const double &dparam,
//                   const string &sparam)
// {
//    handleButtonClicks();
// }

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
 
// void DrawButton(string name, int corn, int x, int y, int code=0, color Clr=Green, int Win=0, int FSize=10)
// {
//    int Error = ObjectFind(name);
//    if (Error != Win)
//       ObjectCreate(name, OBJ_BUTTON, Win, 0, 0);
     
//    ObjectSet(name, OBJPROP_CORNER, corn);
//    ObjectSet(name, OBJPROP_XDISTANCE, x);
//    ObjectSet(name, OBJPROP_YDISTANCE, y);
//    ObjectSetString(0, name, OBJPROP_FONT, "Wingdings");
//    ObjectSetString(0, name, OBJPROP_TEXT, CharToStr(code));
//    ObjectSetInteger(0, name, OBJPROP_COLOR, Clr);
//    ObjectSetInteger(0, name, OBJPROP_XSIZE, 13);
//    ObjectSetInteger(0, name, OBJPROP_YSIZE, 13);
//    ObjectSetInteger(0, name, OBJPROP_FONTSIZE, FSize);
// }


int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }

   IndicatorName = GenerateIndicatorName("Ichimoku Scanner");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   GridBuilder builder(x_shift, 50, cell_height, cell_height, display_mode == Vertical, new TrendValueCellFactory(alert_on_close ? 1 : 0));
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
   WindowNumber = MathMax(0, WindowFind(IndicatorName));
   grid.Draw();
   
   return 0;
}
