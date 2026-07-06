// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71470


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


#property indicator_separate_window
#property strict

enum DisplayMode
{
   Vertical,
   Horizontal
};

input int FastSMA = 6;
input int SlowSMA = 15;
input int WPRPeriod = 13;
input int FastMACD = 12;
input int SlowMACD = 26;
input int SignalMACD = 9;
input int FastPeriod = 12;
input int SlowPeriod = 26;
input int SignalPeriod = 9;
input int CCIPeriod = 14;
input int MOMPeriod = 14;
input int RSIPeriod = 14;
input int ADXPeriod = 14;
input string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
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

// Base condition v1.1

#ifndef ABaseCondition_IMP
#define ABaseCondition_IMP

// Condition base v2.1

#ifndef ACondition_IMP
#define ACondition_IMP

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

class MAUpCondition : public ACondition
{
   int _fast;
   int _slow;
public:
   MAUpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _fast = iMA(_symbol, _timeframe, FastSMA, 0, MODE_SMA, PRICE_CLOSE);
      _slow = iMA(_symbol, _timeframe, SlowSMA, 0, MODE_SMA, PRICE_CLOSE);
   }

   ~MAUpCondition()
   {
      IndicatorRelease(_fast);
      IndicatorRelease(_slow);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double fast[1];
      if (CopyBuffer(_fast, 0, period, 1, fast) != 1)
      {
         return false;
      }
      double slow[1];
      if (CopyBuffer(_slow, 0, period, 1, slow) != 1)
      {
         return false;
      }
      return fast[0] > slow[0];
   }
};

class MADownCondition : public ACondition
{
   int _fast;
   int _slow;
public:
   MADownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _fast = iMA(_symbol, _timeframe, FastSMA, 0, MODE_SMA, PRICE_CLOSE);
      _slow = iMA(_symbol, _timeframe, SlowSMA, 0, MODE_SMA, PRICE_CLOSE);
   }

   ~MADownCondition()
   {
      IndicatorRelease(_fast);
      IndicatorRelease(_slow);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double fast[1];
      if (CopyBuffer(_fast, 0, period, 1, fast) != 1)
      {
         return false;
      }
      double slow[1];
      if (CopyBuffer(_slow, 0, period, 1, slow) != 1)
      {
         return false;
      }
      return fast[0] < slow[0];
   }
};

class WPRUpCondition : public ACondition
{
   int _indi;
public:
   WPRUpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iWPR(_symbol, _timeframe, WPRPeriod);
   }

   ~WPRUpCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer[1];
      if (CopyBuffer(_indi, 0, period, 1, buffer) != 1)
      {
         return false;
      }
      return buffer[0] < 20;
   }
};

class WPRDownCondition : public ACondition
{
   int _indi;
public:
   WPRDownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iWPR(_symbol, _timeframe, WPRPeriod);
   }

   ~WPRDownCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer[1];
      if (CopyBuffer(_indi, 0, period, 1, buffer) != 1)
      {
         return false;
      }
      return buffer[0] > 80;
   }
};

class SARUpCondition : public ACondition
{
   int _indi;
public:
   SARUpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iSAR(_symbol, _timeframe, 0.02, 0.2);
   }

   ~SARUpCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer[1];
      if (CopyBuffer(_indi, 0, period, 1, buffer) != 1)
      {
         return false;
      }
      return buffer[0] < iClose(_symbol, _timeframe, period);
   }
};

class SARDownCondition : public ACondition
{
   int _indi;
public:
   SARDownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iSAR(_symbol, _timeframe, 0.02, 0.2);
   }

   ~SARDownCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer[1];
      if (CopyBuffer(_indi, 0, period, 1, buffer) != 1)
      {
         return false;
      }
      return buffer[0] > iClose(_symbol, _timeframe, period);
   }
};

class MACDUpCondition : public ACondition
{
   int _indi;
public:
   MACDUpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iMACD(_symbol, _timeframe, FastMACD, SlowMACD, SignalMACD, PRICE_CLOSE);
   }

   ~MACDUpCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer[2];
      if (CopyBuffer(_indi, 0, period, 2, buffer) != 2)
      {
         return false;
      }
      return buffer[0] - buffer[1] > 0;
   }
};

class MACDDownCondition : public ACondition
{
   int _indi;
public:
   MACDDownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iMACD(_symbol, _timeframe, FastMACD, SlowMACD, SignalMACD, PRICE_CLOSE);
   }

   ~MACDDownCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer[2];
      if (CopyBuffer(_indi, 0, period, 2, buffer) != 2)
      {
         return false;
      }
      return buffer[0] - buffer[1] < 0;
   }
};

class OsMAUpCondition : public ACondition
{
   int _indi;
public:
   OsMAUpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iOsMA(_symbol, _timeframe, FastPeriod, SlowPeriod, SignalPeriod, PRICE_CLOSE);
   }

   ~OsMAUpCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer[1];
      if (CopyBuffer(_indi, 0, period, 1, buffer) != 1)
      {
         return false;
      }
      return buffer[0] > 0;
   }
};

class OsMADownCondition : public ACondition
{
   int _indi;
public:
   OsMADownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iOsMA(_symbol, _timeframe, FastPeriod, SlowPeriod, SignalPeriod, PRICE_CLOSE);
   }

   ~OsMADownCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer[1];
      if (CopyBuffer(_indi, 0, period, 1, buffer) != 1)
      {
         return false;
      }
      return buffer[0] < 0;
   }
};

class CCIUpCondition : public ACondition
{
   int _indi;
public:
   CCIUpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iCCI(_symbol, _timeframe, CCIPeriod, PRICE_CLOSE);
   }

   ~CCIUpCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer[1];
      if (CopyBuffer(_indi, 0, period, 1, buffer) != 1)
      {
         return false;
      }
      return buffer[0] > 0;
   }
};

class CCIDownCondition : public ACondition
{
   int _indi;
public:
   CCIDownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iCCI(_symbol, _timeframe, CCIPeriod, PRICE_CLOSE);
   }

   ~CCIDownCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer[1];
      if (CopyBuffer(_indi, 0, period, 1, buffer) != 1)
      {
         return false;
      }
      return buffer[0] < 0;
   }
};

class MOMUpCondition : public ACondition
{
   int _indi;
public:
   MOMUpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iMomentum(_symbol, _timeframe, MOMPeriod, PRICE_CLOSE);
   }

   ~MOMUpCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer[1];
      if (CopyBuffer(_indi, 0, period, 1, buffer) != 1)
      {
         return false;
      }
      return buffer[0] > 100;
   }
};

class MOMDownCondition : public ACondition
{
   int _indi;
public:
   MOMDownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iMomentum(_symbol, _timeframe, MOMPeriod, PRICE_CLOSE);
   }

   ~MOMDownCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer[1];
      if (CopyBuffer(_indi, 0, period, 1, buffer) != 1)
      {
         return false;
      }
      return buffer[0] < 100;
   }
};

class RSIUpCondition : public ACondition
{
   int _indi;
public:
   RSIUpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iRSI(_symbol, _timeframe, RSIPeriod, PRICE_CLOSE);
   }

   ~RSIUpCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer[1];
      if (CopyBuffer(_indi, 0, period, 1, buffer) != 1)
      {
         return false;
      }
      return buffer[0] > 50;
   }
};

class RSIDownCondition : public ACondition
{
   int _indi;
public:
   RSIDownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iRSI(_symbol, _timeframe, RSIPeriod, PRICE_CLOSE);
   }

   ~RSIDownCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer[1];
      if (CopyBuffer(_indi, 0, period, 1, buffer) != 1)
      {
         return false;
      }
      return buffer[0] < 50;
   }
};

class ADXUpCondition : public ACondition
{
   int _indi;
public:
   ADXUpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iADX(_symbol, _timeframe, ADXPeriod);
   }

   ~ADXUpCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer1[1];
      if (CopyBuffer(_indi, 1, period, 1, buffer1) != 1)
      {
         return false;
      }
      double buffer2[1];
      if (CopyBuffer(_indi, 2, period, 1, buffer2) != 1)
      {
         return false;
      }
      return buffer1[0] > buffer2[0];
   }
};

class ADXDownCondition : public ACondition
{
   int _indi;
public:
   ADXDownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {
      _indi = iADX(_symbol, _timeframe, ADXPeriod);
   }

   ~ADXDownCondition()
   {
      IndicatorRelease(_indi);
   }

   virtual bool IsPass(const int period, const datetime date)
   {
      double buffer1[1];
      if (CopyBuffer(_indi, 1, period, 1, buffer1) != 1)
      {
         return false;
      }
      double buffer2[1];
      if (CopyBuffer(_indi, 2, period, 1, buffer2) != 1)
      {
         return false;
      }
      return buffer1[0] < buffer2[0];
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

// Empty cell v1.0

// Interface for a cell v1.0

#ifndef ICell_IMP
#define ICell_IMP

class ICell
{
public:
   virtual void Draw() = 0;
protected:
   void ObjectMakeLabel(string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8)
   { 
      ObjectDelete(0, nm); 
      ObjectCreate(0, nm, OBJ_LABEL, Window, 0, 0); 
      ObjectSetInteger(0, nm, OBJPROP_CORNER, LabelCorner); 
      ObjectSetInteger(0, nm, OBJPROP_XDISTANCE, xoff); 
      ObjectSetInteger(0, nm, OBJPROP_YDISTANCE, yoff); 
      ObjectSetInteger(0, nm, OBJPROP_BACK, false); 
      ObjectSetString(0, nm, OBJPROP_TEXT, LabelTexto); 
      ObjectSetInteger(0, nm, OBJPROP_BACK, false);
      ObjectSetString(0, nm, OBJPROP_LEVELTEXT,LabelTexto);
      ObjectSetString(0, nm, OBJPROP_FONT, Font);
      ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, FSize);
      ObjectSetInteger(0, nm, OBJPROP_COLOR, LabelColor);
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
   LabelCell(const string id, const string text, const int x, const int y, ENUM_BASE_CORNER __corner) 
   { 
      _corner = __corner;
      _id = id; 
      _text = text; 
      _x = x; 
      _y = y; 
   } 
   virtual void Draw() 
   { 
      ObjectMakeLabel(_id, _x, _y, _text, Labels_Color, _corner, ChartWindowFind(), "Arial", font_size); 
   }

   virtual void HandleButtonClicks()
   {
      
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
// Trend value cell factory v2.0

// Interface for a cell factory v2.0



#ifndef ICellFactory_IMP
#define ICellFactory_IMP

class ICellFactory
{
public:
   virtual ICell* Create(const string id, const int x, const int y, ENUM_BASE_CORNER corner, const string symbol, const ENUM_TIMEFRAMES timeframe) = 0;
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
//Signaler v 4.0

#ifdef ADVANCED_ALERTS
// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#endif

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   string _prefix;
   bool _popupAlert;
   bool _emailAlert;
   bool _playSound;
   string _soundFile;
   bool _notificationAlert;
   bool _advancedAlert;
   string _advancedKey;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _popupAlert = false;
      _emailAlert = false;
      _playSound = false;
      _notificationAlert = false;
      _advancedAlert = false;
   }

   void SetPopupAlert(bool isEnabled) { _popupAlert = isEnabled; }
   void SetEmailAlert(bool isEnabled) { _emailAlert = isEnabled; }
   void SetPlaySound(bool isEnabled, string fileName) 
   { 
      _playSound = isEnabled;
      _soundFile = fileName;
   }
   void SetNotificationAlert(bool isEnabled) { _notificationAlert = isEnabled; }
   void SetAdvancedAlert(bool isEnabled, string key)
   {
      _advancedAlert = isEnabled;
      _advancedKey = key;
   }

   void SendNotifications(string message, string subject = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (subject == NULL)
         subject = message;

      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframeStr();

      if (_popupAlert)
         Alert(message);
      if (_emailAlert)
         SendMail(subject, message);
      if (_playSound)
         PlaySound(_soundFile);
      if (_notificationAlert)
         SendNotification(message);
#ifdef ADVANCED_ALERTS
      if (_advancedAlert && _advancedKey != "")
         AdvancedAlert(_advancedKey, message, symbol, timeframe);
#endif
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
   TrendValueCell(const string id, const int x, const int y, ENUM_BASE_CORNER __corner, const string symbol, 
      const ENUM_TIMEFRAMES timeframe, int alertShift, 
      IValueFormatter* defaultValue, OutputMode outputMode)
   { 
      _corner = __corner;
      _outputMode = outputMode;
      _lastSignal = 0;
      _alertShift = alertShift;
      _signaler = new Signaler(symbol, timeframe);
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
         ObjectDelete(0, id);
         ObjectMakeLabel(id, _x, _y, text, textColor, _corner, ChartWindowFind(), "Arial", font_size); 
      }
      else
      {
         ObjectDelete(0, id);
         if (ObjectFind(0, id) < 0)
         {
            ObjectCreate(0, id, OBJ_BUTTON, ChartWindowFind(), 0, 0);
         }
         
         
         ObjectSetInteger(0, id, OBJPROP_CORNER, _corner);
         ObjectSetInteger(0, id, OBJPROP_XDISTANCE, _x);
         ObjectSetInteger(0, id, OBJPROP_YDISTANCE, _y);
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

class MATrendValueCellFactory : public ICellFactory
{
   int _alertShift;
   color _upColor;
   color _downColor;
   color _historicalUpColor;
   color _historicalDownColor;
   color _neutralColor;
   color _buttonTextColor;
   OutputMode _outputMode;
public:
   MATrendValueCellFactory(int alertShift = 0, color upColor = Green, color downColor = Red, color historicalUpColor = Lime, color historicalDownColor = Pink)
   {
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

   virtual ICell* Create(const string id, const int x, const int y, ENUM_BASE_CORNER __corner, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", GetTextColor(_neutralColor), GetBackgroundColor(_neutralColor));
      TrendValueCell* cell = new TrendValueCell(id, x, y, __corner, symbol, timeframe, _alertShift, defaultValue, _outputMode);
      defaultValue.Release();

      ICondition* upCondition = new MAUpCondition(symbol, timeframe);
      IValueFormatter* upValue = new FixedTextFormatter("Buy", GetTextColor(_upColor), GetBackgroundColor(_upColor));
      IValueFormatter* historyUpValue = new FixedTextFormatter("Buy", GetTextColor(_historicalUpColor), GetBackgroundColor(_historicalUpColor));
      cell.AddCondition(upCondition, upValue, historyUpValue, upValue);
      upCondition.Release();
      upValue.Release();
      historyUpValue.Release();

      ICondition* downCondition = new MADownCondition(symbol, timeframe);
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

class WPRTrendValueCellFactory : public ICellFactory
{
   int _alertShift;
   color _upColor;
   color _downColor;
   color _historicalUpColor;
   color _historicalDownColor;
   color _neutralColor;
   color _buttonTextColor;
   OutputMode _outputMode;
public:
   WPRTrendValueCellFactory(int alertShift = 0, color upColor = Green, color downColor = Red, color historicalUpColor = Lime, color historicalDownColor = Pink)
   {
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

   virtual ICell* Create(const string id, const int x, const int y, ENUM_BASE_CORNER __corner, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", GetTextColor(_neutralColor), GetBackgroundColor(_neutralColor));
      TrendValueCell* cell = new TrendValueCell(id, x, y, __corner, symbol, timeframe, _alertShift, defaultValue, _outputMode);
      defaultValue.Release();

      ICondition* upCondition = new WPRUpCondition(symbol, timeframe);
      IValueFormatter* upValue = new FixedTextFormatter("Buy", GetTextColor(_upColor), GetBackgroundColor(_upColor));
      IValueFormatter* historyUpValue = new FixedTextFormatter("Buy", GetTextColor(_historicalUpColor), GetBackgroundColor(_historicalUpColor));
      cell.AddCondition(upCondition, upValue, historyUpValue, upValue);
      upCondition.Release();
      upValue.Release();
      historyUpValue.Release();

      ICondition* downCondition = new WPRDownCondition(symbol, timeframe);
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

class SARTrendValueCellFactory : public ICellFactory
{
   int _alertShift;
   color _upColor;
   color _downColor;
   color _historicalUpColor;
   color _historicalDownColor;
   color _neutralColor;
   color _buttonTextColor;
   OutputMode _outputMode;
public:
   SARTrendValueCellFactory(int alertShift = 0, color upColor = Green, color downColor = Red, color historicalUpColor = Lime, color historicalDownColor = Pink)
   {
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

   virtual ICell* Create(const string id, const int x, const int y, ENUM_BASE_CORNER __corner, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", GetTextColor(_neutralColor), GetBackgroundColor(_neutralColor));
      TrendValueCell* cell = new TrendValueCell(id, x, y, __corner, symbol, timeframe, _alertShift, defaultValue, _outputMode);
      defaultValue.Release();

      ICondition* upCondition = new SARUpCondition(symbol, timeframe);
      IValueFormatter* upValue = new FixedTextFormatter("Buy", GetTextColor(_upColor), GetBackgroundColor(_upColor));
      IValueFormatter* historyUpValue = new FixedTextFormatter("Buy", GetTextColor(_historicalUpColor), GetBackgroundColor(_historicalUpColor));
      cell.AddCondition(upCondition, upValue, historyUpValue, upValue);
      upCondition.Release();
      upValue.Release();
      historyUpValue.Release();

      ICondition* downCondition = new SARDownCondition(symbol, timeframe);
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

class MACDTrendValueCellFactory : public ICellFactory
{
   int _alertShift;
   color _upColor;
   color _downColor;
   color _historicalUpColor;
   color _historicalDownColor;
   color _neutralColor;
   color _buttonTextColor;
   OutputMode _outputMode;
public:
   MACDTrendValueCellFactory(int alertShift = 0, color upColor = Green, color downColor = Red, color historicalUpColor = Lime, color historicalDownColor = Pink)
   {
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

   virtual ICell* Create(const string id, const int x, const int y, ENUM_BASE_CORNER __corner, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", GetTextColor(_neutralColor), GetBackgroundColor(_neutralColor));
      TrendValueCell* cell = new TrendValueCell(id, x, y, __corner, symbol, timeframe, _alertShift, defaultValue, _outputMode);
      defaultValue.Release();

      ICondition* upCondition = new MACDUpCondition(symbol, timeframe);
      IValueFormatter* upValue = new FixedTextFormatter("Buy", GetTextColor(_upColor), GetBackgroundColor(_upColor));
      IValueFormatter* historyUpValue = new FixedTextFormatter("Buy", GetTextColor(_historicalUpColor), GetBackgroundColor(_historicalUpColor));
      cell.AddCondition(upCondition, upValue, historyUpValue, upValue);
      upCondition.Release();
      upValue.Release();
      historyUpValue.Release();

      ICondition* downCondition = new MACDDownCondition(symbol, timeframe);
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

class OsMATrendValueCellFactory : public ICellFactory
{
   int _alertShift;
   color _upColor;
   color _downColor;
   color _historicalUpColor;
   color _historicalDownColor;
   color _neutralColor;
   color _buttonTextColor;
   OutputMode _outputMode;
public:
   OsMATrendValueCellFactory(int alertShift = 0, color upColor = Green, color downColor = Red, color historicalUpColor = Lime, color historicalDownColor = Pink)
   {
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

   virtual ICell* Create(const string id, const int x, const int y, ENUM_BASE_CORNER __corner, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", GetTextColor(_neutralColor), GetBackgroundColor(_neutralColor));
      TrendValueCell* cell = new TrendValueCell(id, x, y, __corner, symbol, timeframe, _alertShift, defaultValue, _outputMode);
      defaultValue.Release();

      ICondition* upCondition = new OsMAUpCondition(symbol, timeframe);
      IValueFormatter* upValue = new FixedTextFormatter("Buy", GetTextColor(_upColor), GetBackgroundColor(_upColor));
      IValueFormatter* historyUpValue = new FixedTextFormatter("Buy", GetTextColor(_historicalUpColor), GetBackgroundColor(_historicalUpColor));
      cell.AddCondition(upCondition, upValue, historyUpValue, upValue);
      upCondition.Release();
      upValue.Release();
      historyUpValue.Release();

      ICondition* downCondition = new OsMADownCondition(symbol, timeframe);
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

class CCITrendValueCellFactory : public ICellFactory
{
   int _alertShift;
   color _upColor;
   color _downColor;
   color _historicalUpColor;
   color _historicalDownColor;
   color _neutralColor;
   color _buttonTextColor;
   OutputMode _outputMode;
public:
   CCITrendValueCellFactory(int alertShift = 0, color upColor = Green, color downColor = Red, color historicalUpColor = Lime, color historicalDownColor = Pink)
   {
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

   virtual ICell* Create(const string id, const int x, const int y, ENUM_BASE_CORNER __corner, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", GetTextColor(_neutralColor), GetBackgroundColor(_neutralColor));
      TrendValueCell* cell = new TrendValueCell(id, x, y, __corner, symbol, timeframe, _alertShift, defaultValue, _outputMode);
      defaultValue.Release();

      ICondition* upCondition = new CCIUpCondition(symbol, timeframe);
      IValueFormatter* upValue = new FixedTextFormatter("Buy", GetTextColor(_upColor), GetBackgroundColor(_upColor));
      IValueFormatter* historyUpValue = new FixedTextFormatter("Buy", GetTextColor(_historicalUpColor), GetBackgroundColor(_historicalUpColor));
      cell.AddCondition(upCondition, upValue, historyUpValue, upValue);
      upCondition.Release();
      upValue.Release();
      historyUpValue.Release();

      ICondition* downCondition = new CCIDownCondition(symbol, timeframe);
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

class MOMTrendValueCellFactory : public ICellFactory
{
   int _alertShift;
   color _upColor;
   color _downColor;
   color _historicalUpColor;
   color _historicalDownColor;
   color _neutralColor;
   color _buttonTextColor;
   OutputMode _outputMode;
public:
   MOMTrendValueCellFactory(int alertShift = 0, color upColor = Green, color downColor = Red, color historicalUpColor = Lime, color historicalDownColor = Pink)
   {
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

   virtual ICell* Create(const string id, const int x, const int y, ENUM_BASE_CORNER __corner, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", GetTextColor(_neutralColor), GetBackgroundColor(_neutralColor));
      TrendValueCell* cell = new TrendValueCell(id, x, y, __corner, symbol, timeframe, _alertShift, defaultValue, _outputMode);
      defaultValue.Release();

      ICondition* upCondition = new MOMUpCondition(symbol, timeframe);
      IValueFormatter* upValue = new FixedTextFormatter("Buy", GetTextColor(_upColor), GetBackgroundColor(_upColor));
      IValueFormatter* historyUpValue = new FixedTextFormatter("Buy", GetTextColor(_historicalUpColor), GetBackgroundColor(_historicalUpColor));
      cell.AddCondition(upCondition, upValue, historyUpValue, upValue);
      upCondition.Release();
      upValue.Release();
      historyUpValue.Release();

      ICondition* downCondition = new MOMDownCondition(symbol, timeframe);
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

class RSITrendValueCellFactory : public ICellFactory
{
   int _alertShift;
   color _upColor;
   color _downColor;
   color _historicalUpColor;
   color _historicalDownColor;
   color _neutralColor;
   color _buttonTextColor;
   OutputMode _outputMode;
public:
   RSITrendValueCellFactory(int alertShift = 0, color upColor = Green, color downColor = Red, color historicalUpColor = Lime, color historicalDownColor = Pink)
   {
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

   virtual ICell* Create(const string id, const int x, const int y, ENUM_BASE_CORNER __corner, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", GetTextColor(_neutralColor), GetBackgroundColor(_neutralColor));
      TrendValueCell* cell = new TrendValueCell(id, x, y, __corner, symbol, timeframe, _alertShift, defaultValue, _outputMode);
      defaultValue.Release();

      ICondition* upCondition = new RSIUpCondition(symbol, timeframe);
      IValueFormatter* upValue = new FixedTextFormatter("Buy", GetTextColor(_upColor), GetBackgroundColor(_upColor));
      IValueFormatter* historyUpValue = new FixedTextFormatter("Buy", GetTextColor(_historicalUpColor), GetBackgroundColor(_historicalUpColor));
      cell.AddCondition(upCondition, upValue, historyUpValue, upValue);
      upCondition.Release();
      upValue.Release();
      historyUpValue.Release();

      ICondition* downCondition = new RSIDownCondition(symbol, timeframe);
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

class ADXTrendValueCellFactory : public ICellFactory
{
   int _alertShift;
   color _upColor;
   color _downColor;
   color _historicalUpColor;
   color _historicalDownColor;
   color _neutralColor;
   color _buttonTextColor;
   OutputMode _outputMode;
public:
   ADXTrendValueCellFactory(int alertShift = 0, color upColor = Green, color downColor = Red, color historicalUpColor = Lime, color historicalDownColor = Pink)
   {
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

   virtual ICell* Create(const string id, const int x, const int y, ENUM_BASE_CORNER __corner, const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      IValueFormatter* defaultValue = new FixedTextFormatter("-", GetTextColor(_neutralColor), GetBackgroundColor(_neutralColor));
      TrendValueCell* cell = new TrendValueCell(id, x, y, __corner, symbol, timeframe, _alertShift, defaultValue, _outputMode);
      defaultValue.Release();

      ICondition* upCondition = new ADXUpCondition(symbol, timeframe);
      IValueFormatter* upValue = new FixedTextFormatter("Buy", GetTextColor(_upColor), GetBackgroundColor(_upColor));
      IValueFormatter* historyUpValue = new FixedTextFormatter("Buy", GetTextColor(_historicalUpColor), GetBackgroundColor(_historicalUpColor));
      cell.AddCondition(upCondition, upValue, historyUpValue, upValue);
      upCondition.Release();
      upValue.Release();
      historyUpValue.Release();

      ICondition* downCondition = new ADXDownCondition(symbol, timeframe);
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

class GridRowData
{
public:
   GridRowData(int count, string label)
   {
      this.count = count;
      this.label = label;
      ArrayResize(x, count);
      ArrayResize(column, count);
   }
   int x[];
   int count;
   string label;
   Row* column[];
};

class GridBuilder
{
   string _symbols[];
   int _symbolsCount;
   ENUM_TIMEFRAMES _timeframes[];
   int _timeframesCount;

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
public:
   GridBuilder(int x, int y, int headerHeight, int cellHeight, bool verticalMode, ENUM_BASE_CORNER __corner)
      :_xIterator(x, -cell_width), _yIterator(y, cellHeight)
   {
      _timeframesCount = 0;
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

   void SetTimeframes(ENUM_TIMEFRAMES& timeframes[])
   {
      _timeframesCount = ArraySize(timeframes);
      ArrayResize(_timeframes, _timeframesCount);
      for (int i = 0; i < _timeframesCount; ++i)
      {
         _timeframes[i] = timeframes[i];
      }
      if (_verticalMode)
      {
         Iterator yIterator(_originalY, _cellHeight);
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _timeframesCount; i++)
         {
            string tf = TimeframeToString(_timeframes[i]);
            string id = IndicatorObjPrefix + tf + "_Name";
            row.Add(new LabelCell(id, tf, _originalX + cell_width, yIterator.GetNext(), _corner));
         }
      }
      else
      {
         //TODO: add support of multiple values
         Iterator xIterator(_originalX - cell_width, -cell_width);
         Row* row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _timeframesCount; i++)
         {
            string tf = TimeframeToString(_timeframes[i]);
            string id = IndicatorObjPrefix + tf + "_Name";
            row.Add(new LabelCell(id, tf, xIterator.GetNext(), _originalY - _headerHeight, _corner));
         }
      }
   }

   void SetSymbol(const string symbol)
   {
      _symbolsCount = 1;
      ArrayResize(_symbols, 1);
      _symbols[0] = symbol;
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

   void AddValue(const string label, ICellFactory* factory, const ENUM_TIMEFRAMES timeframe)
   {
      if (_verticalMode)
      {
         GridRowData data(1, label);
         FillXColumn(data);
         
         Iterator yIterator(_originalY, _cellHeight);
         for (int i = 0; i < _symbolsCount; i++)
         {
            int y = yIterator.GetNext();
            AddVerticalCells(_symbols[i], timeframe, data, _symbols[i], yIterator, factory, 0, y);
         }
      }
      else
      {
         //TODO: add support of multiple values
         int y[];
         ArrayResize(y, 1);
         for (int ii = 0; ii < 1; ++ii)
         {
            y[ii] = _yIterator.GetNext();
         }
         Row* row = grid.AddRow();
         #ifndef EXCLUDE_PERIOD_HEADER
            row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, _originalX, y[0], _corner));
         #endif
         Iterator xIterator(_originalX - cell_width, -cell_width);
         for (int i = 0; i < _timeframesCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            int x = xIterator.GetNext();
            for (int ii = 0; ii < 1; ++ii)
            {
               row.Add(factory.Create(id, x, y[ii], _corner, _symbols[i], timeframe));
            }
         }
      }
   }

   void AddValue(const string label, ICellFactory* factory, string symbol)
   {
      if (_verticalMode)
      {
         GridRowData data(1, label);
         FillXColumn(data);
         
         Iterator yIterator(_originalY, _cellHeight);
         for (int i = 0; i < _timeframesCount; i++)
         {
            int y = yIterator.GetNext();
            AddVerticalCells(symbol, _timeframes[i], data, TimeframeToString(_timeframes[i]), yIterator, factory, 0, y);
         }
      }
      else
      {
         //TODO: add support of multiple values
         int y[];
         ArrayResize(y, 1);
         for (int ii = 0; ii < 1; ++ii)
         {
            y[ii] = _yIterator.GetNext();
         }
         Row* row = grid.AddRow();
         #ifndef EXCLUDE_PERIOD_HEADER
            row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, _originalX, y[0], _corner));
         #endif
         Iterator xIterator(_originalX - cell_width, -cell_width);
         for (int i = 0; i < _timeframesCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            int x = xIterator.GetNext();
            for (int ii = 0; ii < 1; ++ii)
            {
               row.Add(factory.Create(id, x, y[ii], _corner, symbol, _timeframes[i]));
            }
         }
      }
   }

   void AddTimeframe(const string label, const ENUM_TIMEFRAMES timeframe)
   {
      int cellFactorySize = ArraySize(_cellFactory);
      if (_verticalMode)
      {
         GridRowData data(cellFactorySize, label);
         FillXColumn(data);

         Iterator yIterator(_originalY, _cellHeight);
         if (cellFactorySize > 1)
         {
            int y = yIterator.GetNext();
            for (int ii = 0; ii < cellFactorySize; ++ii)
            {
               string index = IntegerToString(ii + 1);
               data.column[ii].Add(new LabelCell(IndicatorObjPrefix + data.label + "_sh" + index, _cellFactory[ii].GetHeader(), data.x[ii], y, _corner));
            }
         }

         for (int i = 0; i < _symbolsCount; i++)
         {
            AddVerticalCells(_symbols[i], timeframe, data, _symbols[i], yIterator);
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
               row.Add(_cellFactory[ii].Create(id, x, y[ii], _corner, _symbols[i], timeframe));
            }
         }
      }
   }

   Grid* Build()
   {
      return grid;
   }
private:
   void FillXColumn(GridRowData& data)
   {
      for (int ii = 0; ii < data.count; ++ii)
      {
         data.x[ii] = _xIterator.GetNext();
         data.column[ii] = grid.AddRow();
         AddVerticalHeaderVell(data.column[ii], data.label, data.x[0], ii);
      }
   }

   void AddVerticalCells(string symbol, ENUM_TIMEFRAMES timeframe, GridRowData& data, string generalId, Iterator& yIterator, ICellFactory* factory, int ii, int y)
   {
      string id = IndicatorObjPrefix + generalId + "_" + data.label + IntegerToString(ii);
      data.column[ii].Add(factory.Create(id, data.x[ii], y, _corner, symbol, timeframe));
   }

   void AddVerticalCells(string symbol, ENUM_TIMEFRAMES timeframe, GridRowData& data, string generalId, Iterator& yIterator)
   {
      int y = yIterator.GetNext();
      for (int ii = 0; ii < data.count; ++ii)
      {
         AddVerticalCells(symbol, timeframe, data, generalId, yIterator, _cellFactory[ii], ii, y);
      }
   }

   void AddVerticalHeaderVell(Row* row, string label, int x, int ii)
   {
      #ifndef EXCLUDE_PERIOD_HEADER
      if (ii > 0)
      {
         row.Add(new EmptyCell());
      }
      else
      {
         row.Add(new LabelCell(IndicatorObjPrefix + label + "_h", label, x, _headerHeight, _corner));
      }
      #endif
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
   IndicatorObjPrefix = GenerateIndicatorPrefix("Multi Trend signal Indicator");
   IndicatorSetString(INDICATOR_SHORTNAME, "Multi Trend signal Indicator");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   GridBuilder builder(x_shift, 50, cell_height, cell_height, display_mode == Vertical, corner);
   builder.SetSymbol(_Symbol);
   ENUM_TIMEFRAMES tfs[];
   if (Include_M1)
   {
      int size = ArraySize(tfs);
      ArrayResize(tfs, size + 1);
      tfs[size] = PERIOD_M1;
   }
   if (Include_M5)
   {
      int size = ArraySize(tfs);
      ArrayResize(tfs, size + 1);
      tfs[size] = PERIOD_M5;
   }
   if (Include_M15)
   {
      int size = ArraySize(tfs);
      ArrayResize(tfs, size + 1);
      tfs[size] = PERIOD_M15;
   }
   if (Include_M30)
   {
      int size = ArraySize(tfs);
      ArrayResize(tfs, size + 1);
      tfs[size] = PERIOD_M30;
   }
   if (Include_H1)
   {
      int size = ArraySize(tfs);
      ArrayResize(tfs, size + 1);
      tfs[size] = PERIOD_H1;
   }
   if (Include_H4)
   {
      int size = ArraySize(tfs);
      ArrayResize(tfs, size + 1);
      tfs[size] = PERIOD_H4;
   }
   if (Include_D1)
   {
      int size = ArraySize(tfs);
      ArrayResize(tfs, size + 1);
      tfs[size] = PERIOD_D1;
   }
   if (Include_W1)
   {
      int size = ArraySize(tfs);
      ArrayResize(tfs, size + 1);
      tfs[size] = PERIOD_W1;
   }
   if (Include_MN1)
   {
      int size = ArraySize(tfs);
      ArrayResize(tfs, size + 1);
      tfs[size] = PERIOD_MN1;
   }
   builder.SetTimeframes(tfs);

   MATrendValueCellFactory* factory = new MATrendValueCellFactory(alert_on_close ? 1 : 0, Up_Color, Dn_Color, historical_Up_Color, historical_Dn_Color);
   factory.SetNeutralColor(neutral_color);
   factory.SetButtonTextColor(button_text_color);
   builder.AddValue("MA", factory, _Symbol);
   delete factory;

   WPRTrendValueCellFactory* factory2 = new WPRTrendValueCellFactory(alert_on_close ? 1 : 0, Up_Color, Dn_Color, historical_Up_Color, historical_Dn_Color);
   factory2.SetNeutralColor(neutral_color);
   factory2.SetButtonTextColor(button_text_color);
   builder.AddValue("WPR", factory2, _Symbol);
   delete factory2;

   SARTrendValueCellFactory* factory3 = new SARTrendValueCellFactory(alert_on_close ? 1 : 0, Up_Color, Dn_Color, historical_Up_Color, historical_Dn_Color);
   factory3.SetNeutralColor(neutral_color);
   factory3.SetButtonTextColor(button_text_color);
   builder.AddValue("SAR", factory3, _Symbol);
   delete factory3;

   MACDTrendValueCellFactory* factory4 = new MACDTrendValueCellFactory(alert_on_close ? 1 : 0, Up_Color, Dn_Color, historical_Up_Color, historical_Dn_Color);
   factory4.SetNeutralColor(neutral_color);
   factory4.SetButtonTextColor(button_text_color);
   builder.AddValue("MACD", factory4, _Symbol);
   delete factory4;

   OsMATrendValueCellFactory* factory5 = new OsMATrendValueCellFactory(alert_on_close ? 1 : 0, Up_Color, Dn_Color, historical_Up_Color, historical_Dn_Color);
   factory5.SetNeutralColor(neutral_color);
   factory5.SetButtonTextColor(button_text_color);
   builder.AddValue("OsMA", factory5, _Symbol);
   delete factory5;

   CCITrendValueCellFactory* factory6 = new CCITrendValueCellFactory(alert_on_close ? 1 : 0, Up_Color, Dn_Color, historical_Up_Color, historical_Dn_Color);
   factory6.SetNeutralColor(neutral_color);
   factory6.SetButtonTextColor(button_text_color);
   builder.AddValue("CCI", factory6, _Symbol);
   delete factory6;

   MOMTrendValueCellFactory* factory7 = new MOMTrendValueCellFactory(alert_on_close ? 1 : 0, Up_Color, Dn_Color, historical_Up_Color, historical_Dn_Color);
   factory7.SetNeutralColor(neutral_color);
   factory7.SetButtonTextColor(button_text_color);
   builder.AddValue("MOM", factory7, _Symbol);
   delete factory7;

   RSITrendValueCellFactory* factory8 = new RSITrendValueCellFactory(alert_on_close ? 1 : 0, Up_Color, Dn_Color, historical_Up_Color, historical_Dn_Color);
   factory8.SetNeutralColor(neutral_color);
   factory8.SetButtonTextColor(button_text_color);
   builder.AddValue("RSI", factory8, _Symbol);
   delete factory8;

   ADXTrendValueCellFactory* factory9 = new ADXTrendValueCellFactory(alert_on_close ? 1 : 0, Up_Color, Dn_Color, historical_Up_Color, historical_Dn_Color);
   factory9.SetNeutralColor(neutral_color);
   factory9.SetButtonTextColor(button_text_color);
   builder.AddValue("ADX", factory9, _Symbol);
   delete factory9;

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
   grid.Draw();
   
   return 0;
}
