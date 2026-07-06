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
#property indicator_plots 5
#property indicator_buffers 6
#property indicator_minimum - 20
#property indicator_maximum 105
#property indicator_level1 50
#property indicator_levelcolor clrDodgerBlue
#property indicator_levelstyle 1
#property indicator_color5 C'155,5,16',C'16,195,5'
#property indicator_width5 1
#property indicator_style5 STYLE_SOLID

input color up_color = Green; // Up color
input color down_color = Red; // Down color

input int limit = 1000;
string ID = "Brax>";
//+------------------------------------------------------------------------------------------------------------------+
input string RS01 = "====================================================";
input string RS02 = "<<<==== [01] RSIOMA Settings ====>>>";
input string RS03 = "====================================================";
double BuyTrigger = 30.00,
       SellTrigger = 70.00,
       XardOB = 90.00,
       XardOS = 10.00;
input color BuyTriggerColor = clrHotPink,
            SellTriggerColor = clrDodgerBlue,
            MainTrendLongColor = clrDodgerBlue,
            MainTrendShortColor = clrHotPink;
input color marsiomaXupSigColor = clrAqua,
            marsiomaXdnSigColor = clrDeepPink;
double MainTrendLong = 10.00, MainTrendShort = 90.00, MajorTrend = 50;
input string SL01 = "====================================================";
input string SL02 = "<<<==== [02] Line Settings ====>>>";
input string SL03 = "====================================================";
input string LinesIdentifier = "rsioma lines";
input int LinesStyle = STYLE_DASH;
input string AL01 = "====================================================";
input string AL02 = "<<<==== [03] Alert Settings ====>>>";
input string AL03 = "====================================================";
input string TF01 = "====================================================";
input string TF02 = "<<<==== [04] TF Period Chart Settings ====>>>";
input string TF03 = "====================================================";
input string note_Choose_TimeFrames = "TF as in MT4 Periodicity bar:";
input string as_Periods = "(M1;M5;M15;M30;H1;H4;D1;W1;MN; or:)";
input string or_Minutes = "(1,5,15,30,60,240,1440,10080,43200)";
input string CurrentTF_0 = "Current TF = 0 (Zero)";
input ENUM_TIMEFRAMES Timeframe = PERIOD_CURRENT; // Timeframe
input string BT01 = "====================================================";
input string BT02 = "<<<==== [05] BOXtext on 1Hr Chart Settings ====>>>";
input string BT03 = "====================================================";
input bool showBOXtext = true;
input int PanelBorderWidth = 1;
input color PanelBorderColor = C'120,120,120';
string BOXtxt;
color BOXclr;

double b[], b_color[];
double marsioma[];

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

// Base condition v1.0

#ifndef ABaseCondition_IMP
#define ABaseCondition_IMP

// Condition base v2.0

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
// Symbol info v.1.2

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
   double GetMinVolume() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathRound(rate / _ticksize) * _ticksize, _digit);
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
// PriceStream v1.1

#ifndef PriceStream_IMP
#define PriceStream_IMP

// ABaseStream v1.0
#ifndef ABaseStream_IMP
#define ABaseStream_IMP
// IStream v.1.2
interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;
   virtual bool GetSeriesValues(const int period, const int count, double &val[]) = 0;

   virtual int Size() = 0;
};
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
#endif
class PriceStream : public ABaseStream
{
   ENUM_APPLIED_PRICE _price;
   double _pipSize;
public:
   PriceStream(string symbol, const ENUM_TIMEFRAMES timeframe, const ENUM_APPLIED_PRICE price)
      :ABaseStream(symbol, timeframe)
   {
      _price = price;

      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      int digit = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS); 
      int mult = digit == 3 || digit == 5 ? 10 : 1;
      _pipSize = point * mult;
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int bars = iBars(_symbol, _timeframe);
      int oldIndex = bars - period - 1;
      for (int i = 0; i < count; ++i)
      {
         switch (_price)
         {
            case PRICE_CLOSE:
               val[i] = iClose(_symbol, _timeframe, oldIndex + i);
               break;
            case PRICE_OPEN:
               val[i] = iOpen(_symbol, _timeframe, oldIndex + i);
               break;
            case PRICE_HIGH:
               val[i] = iHigh(_symbol, _timeframe, oldIndex + i);
               break;
            case PRICE_LOW:
               val[i] = iLow(_symbol, _timeframe, oldIndex + i);
               break;
            case PRICE_MEDIAN:
               val[i] = (iHigh(_symbol, _timeframe, oldIndex + i) + iLow(_symbol, _timeframe, oldIndex + i)) / 2.0;
               break;
            case PRICE_TYPICAL:
               val[i] = (iHigh(_symbol, _timeframe, oldIndex + i) + iLow(_symbol, _timeframe, oldIndex + i) + iClose(_symbol, _timeframe, oldIndex + i)) / 3.0;
               break;
            case PRICE_WEIGHTED:
               val[i] = (iHigh(_symbol, _timeframe, oldIndex + i) + iLow(_symbol, _timeframe, oldIndex + i) + iClose(_symbol, _timeframe, oldIndex + i) * 2) / 4.0;
               break;
         }
         val[i] += _shift * _pipSize;
      }
      return true;
   }
};

#endif
// Alert signal v1.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AlertSignal_IMP
#define AlertSignal_IMP





class AlertSignal
{
   double _signals[];
   ICondition* _condition;
   IStream* _price;
   Signaler* _signaler;
   string _message;
   datetime _lastSignal;
public:
   AlertSignal(ICondition* condition, Signaler* signaler)
   {
      _condition = condition;
      _price = NULL;
      _signaler = signaler;
   }

   ~AlertSignal()
   {
      if (_price != NULL)
         _price.Release();
      if (_condition != NULL)
         _condition.Release();
   }

   void Init()
   {
      ArrayInitialize(_signals, EMPTY_VALUE);
   }

   int RegisterStreams(int id, string name, int code, color clr, IStream* price)
   {
      _message = name;
      _price = price;
      _price.AddRef();
      SetIndexBuffer(id, _signals, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, clr);
      PlotIndexSetString(id, PLOT_LABEL, name);
      PlotIndexSetInteger(id, PLOT_ARROW, code);
      ArraySetAsSeries(_signals, true);
      
      return id + 1;
   }

   void Update(int period, datetime date)
   {
      if (!_condition.IsPass(period, date))
      {
         _signals[period] = EMPTY_VALUE;
         return;
      }

      if (period == 0)
      {
         string symbol = _signaler.GetSymbol();
         datetime dt = iTime(symbol, _signaler.GetTimeframe(), 0);
         if (_lastSignal != dt)
         {
            _signaler.SendNotifications(symbol + "/" + _signaler.GetTimeframeStr() + ": " + _message);
            _lastSignal = dt;
         }
      }

      double price[1];
      if (!_price.GetSeriesValues(period, 1, price))
         return;

      _signals[period] = price[0];
   }
};

#endif

AlertSignal* up;
AlertSignal* down;
Signaler* mainSignaler;

class UpAlertCondition : public ACondition
{
public:
   UpAlertCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      bool series1 = ArrayGetAsSeries(outputStream._data); 
      bool series2 = ArrayGetAsSeries(marsioma); 
      ArraySetAsSeries(outputStream._data, true);
      ArraySetAsSeries(marsioma, true);
      bool result = outputStream._data[period + 1] <= marsioma[period + 1] && outputStream._data[period] > marsioma[period];
      ArraySetAsSeries(outputStream._data, series1);
      ArraySetAsSeries(marsioma, series2);
      return result;
   }
};

class DownAlertCondition : public ACondition
{
public:
   DownAlertCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period, const datetime date)
   {
      
      bool series1 = ArrayGetAsSeries(outputStream._data); 
      bool series2 = ArrayGetAsSeries(marsioma); 
      ArraySetAsSeries(outputStream._data, true);
      ArraySetAsSeries(marsioma, true);
      bool result = outputStream._data[period + 1] >= marsioma[period + 1] && outputStream._data[period] < marsioma[period];
      ArraySetAsSeries(outputStream._data, series1);
      ArraySetAsSeries(marsioma, series2);
      return result;
   }
};

// IndicatorOutputStream v1.1
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
      PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id + 0, PLOT_LINE_COLOR, clr);
      PlotIndexSetString(id + 0, PLOT_LABEL, name);
      return id + 1;
   }

   void Clear(double value)
   {
      ArrayInitialize(_data, value);
   }

   virtual bool GetValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < MathMin(count, size - period); ++i)
      {
         if (_data[period - i] == EMPTY_VALUE)
            return false;
         val[i] = _data[period + i];
      }
      return true;
   }

   virtual bool GetSeriesValues(const int period, const int count, double &val[])
   {
      int size = Size();
      for (int i = 0; i < MathMin(count, size - period); ++i)
      {
         if (_data[size - 1 - period - i] == EMPTY_VALUE)
            return false;
         val[i] = _data[size - 1 - period - i];
      }
      return true;
   }
};

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

IndicatorOutputStream* outputStream;
int ma, rsi, marsi;
int OnInit(void)
{
   ma = iMA(_Symbol, Timeframe, 10, 0, MODE_LWMA, PRICE_CLOSE);
   rsi = iRSI(_Symbol, Timeframe, 10, ma);
   marsi = iMA(_Symbol, Timeframe, 14, 0, MODE_SMA, rsi);
   outputStream = new IndicatorOutputStream(_Symbol, _Period);

   IndicatorObjPrefix = GenerateIndicatorPrefix("xrsioma");
   IndicatorSetString(INDICATOR_SHORTNAME, "X-RSIOMA");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   
   //register outputs

   ENUM_TIMEFRAMES timeframe = (ENUM_TIMEFRAMES)_Period;
   mainSignaler = new Signaler(_Symbol, timeframe);
   mainSignaler.SetMessagePrefix(_Symbol + "/" + mainSignaler.GetTimeframeStr() + ": ");
   ICondition* upCondition = new UpAlertCondition(_Symbol, timeframe);
   ICondition* downCondition = new DownAlertCondition(_Symbol, timeframe);
   up = new AlertSignal(upCondition, mainSignaler);
   down = new AlertSignal(downCondition, mainSignaler);
      
   int id = 0;
   id = outputStream.RegisterStream(id, clrDodgerBlue, "RSI");
   SetIndexBuffer(id, marsioma, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id++, PLOT_LINE_COLOR, Red);
   id = up.RegisterStreams(id, "Up", 217, up_color, outputStream);
   id = down.RegisterStreams(id, "Down", 218, down_color, outputStream);
   SetIndexBuffer(id, b, INDICATOR_DATA);
   PlotIndexSetInteger(id++, PLOT_DRAW_TYPE, DRAW_COLOR_HISTOGRAM);
   SetIndexBuffer(id++, b_color, INDICATOR_COLOR_INDEX);
   
   return INIT_SUCCEEDED;//INIT_FAILED
}

void OnDeinit(const int reason)
{
   outputStream.Release();
   outputStream = NULL;
   IndicatorRelease(ma);
   IndicatorRelease(rsi);
   IndicatorRelease(marsi);
   delete mainSignaler;
   mainSignaler = NULL;
   delete up;
   up = NULL;
   delete down;
   down = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}

int OnCalculate(const int rates_total,       // size of input time series
                const int prev_calculated,   // number of handled bars at the previous call
                const datetime& time[],      // Time array
                const double& open[],        // Open array
                const double& high[],        // High array
                const double& low[],         // Low array
                const double& close[],       // Close array
                const long& tick_volume[],   // Tick Volume array
                const long& volume[],        // Real Volume array
                const int& spread[]          // Spread array
)
{
   static bool init = false;
   if (!init)
   {
      init = true;
      drawLine(BuyTrigger, IndicatorObjPrefix + "BuyTrigger", BuyTriggerColor);
      drawLine(SellTrigger, IndicatorObjPrefix + "SellTrigger", SellTriggerColor);
      drawLine(XardOB, IndicatorObjPrefix + "XardOB", MainTrendShortColor);
      drawLine(XardOS, IndicatorObjPrefix + "XardOS", MainTrendLongColor);
   }

   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      outputStream.Clear(EMPTY_VALUE);
      ArrayInitialize(b, EMPTY_VALUE);
      ArrayInitialize(b_color, EMPTY_VALUE);
      ArrayInitialize(marsioma, EMPTY_VALUE);
      up.Init();
      down.Init();
   }
   int first = 10;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldIndex = rates_total - 1 - pos;

      int index = iBarShift(_Symbol, Timeframe, time[pos]);
      if (index > iBars(_Symbol, Timeframe) - first)
      {
         continue;
      }
      double RSIBuffer1[1];
      if (CopyBuffer(rsi, 0, oldIndex, 1, RSIBuffer1) != 1)
      {
         continue;
      }
      double marsioma1[1];
      if (CopyBuffer(marsi, 0, oldIndex, 1, marsioma1) != 1)
      {
         continue;
      }
      outputStream._data[pos] = RSIBuffer1[0];
      marsioma[pos] = marsioma1[0];
      if (outputStream._data[pos] <= 50.)
      {
         b[pos] = -12;
         b_color[pos] = 0;
      }
      if (outputStream._data[pos] > 50.)
      {
         b[pos] = 12;
         b_color[pos] = 1;
      }
      BOXtxt = "  WAITING...";
      BOXclr = C'40,40,40';
      if (outputStream._data[pos] <= marsioma[pos] && outputStream._data[pos] < 50.)
      {
         BOXtxt = "SELLS ONLY";
         BOXclr = clrRed;
      }
      if (outputStream._data[pos] >= marsioma[pos] && outputStream._data[pos] > 50.)
      {
         BOXtxt = " BUYS ONLY";
         BOXclr = clrBlue;
      }
      if (Period() <= PERIOD_W1)
      {
         if (showBOXtext)
         {
            SetPanel(0, IndicatorObjPrefix + ID + "Brax1", 1, 0, 4, 6, 140, 22, BOXclr, PanelBorderColor, PanelBorderWidth, false);
            ObjectSetInteger(0, IndicatorObjPrefix + ID + "Brax1", OBJPROP_BGCOLOR, BOXclr);
            SetLabel(0, IndicatorObjPrefix + ID + "Brax2", 1, 0, 8, 6, BOXtxt, 16, "Arial Bold", clrSilver, 0, false, true, 0, ANCHOR_LEFT_UPPER);
         }
      }
      up.Update(oldIndex, time[pos]);
      down.Update(oldIndex, time[pos]);
   }
   return rates_total;
}

//+------------------------------------------------------------------------------------------------------------------+
void drawLine(double lvl, string name, color Col)
{
   ResetLastError();
   if (ObjectFind(0, name) == -1)
   {
      if (!ObjectCreate(0, name, OBJ_HLINE, 0, 0, lvl))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, name, OBJPROP_COLOR, Col);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
   }
   ObjectSetDouble(0, name, OBJPROP_PRICE, lvl);
}

//+----SetPanel Function---------------------------------------------------------------------------------------------+
void SetPanel(long IDchart = 0, string name = "Panel", int window = 0, int corner = 0, int PosX = 0, int PosY = 0, int width = 0, int height = 0,
              int bg_color = 0, int border_color = 0, int border_width = 1, bool bg = true, bool del = false)
{
   if (StringLen(name) < 1)
   {
      return;
   }
   if (del)
   {
      ObjectDelete(IDchart, name);
   }
   window = MathMax(window, 0);
   if (bg_color < 0)
      bg_color = White;
   if (border_color < 0)
      border_color = White;

   if (ObjectFind(IDchart, name) == -1)
   {
      if (ObjectCreate(IDchart, name, OBJ_RECTANGLE_LABEL, window, 0, 0))
      {
         ObjectSetInteger(IDchart, name, OBJPROP_BGCOLOR, bg_color);
         ObjectSetInteger(IDchart, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
         ObjectSetInteger(IDchart, name, OBJPROP_CORNER, corner);
         ObjectSetInteger(IDchart, name, OBJPROP_COLOR, border_color);
         ObjectSetInteger(IDchart, name, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSetInteger(IDchart, name, OBJPROP_WIDTH, border_width);
         ObjectSetInteger(IDchart, name, OBJPROP_SELECTABLE, 0);
         ObjectSetInteger(IDchart, name, OBJPROP_SELECTED, 0);
         ObjectSetInteger(IDchart, name, OBJPROP_HIDDEN, true);
         ObjectSetInteger(IDchart, name, OBJPROP_ZORDER, 0);
      }
   }
   ObjectSetInteger(IDchart, name, OBJPROP_XDISTANCE, PosX);
   ObjectSetInteger(IDchart, name, OBJPROP_YDISTANCE, PosY);
   ObjectSetInteger(IDchart, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(IDchart, name, OBJPROP_YSIZE, height);
}
//+----SetLabel Function---------------------------------------------------------------------------------------------+
void SetLabel(long IDchart = 0, string name = "Label", int window = 0, int corner = 0, int PosX = 0, int PosY = 0, string thetext = " ",
              int fontsize = 12, string fontname = "Arial", int colour = 0, double angle = 0, bool back = true, bool del = false, int vis = 0,
              int align = ANCHOR_LEFT_UPPER, bool HideObjects = true)
{
   if (del)
      ObjectDelete(IDchart, name);
   corner = MathMax(corner, 0);
   window = MathMax(window, 0);
   if (colour < 0)
      colour = White;
   if (fontsize == 0)
      fontsize = 8;
   if (fontname == "")
      fontname = "Arial";
   if (ObjectFind(IDchart, name) < 0)
      ObjectCreate(IDchart, name, OBJ_LABEL, window, 0, 0, 0, 0);
   ObjectSetInteger(IDchart, name, OBJPROP_CORNER, corner);
   ObjectSetInteger(IDchart, name, OBJPROP_XDISTANCE, PosX);
   ObjectSetInteger(IDchart, name, OBJPROP_YDISTANCE, PosY);
   ObjectSetString(IDchart, name, OBJPROP_TEXT, thetext);
   ObjectSetInteger(IDchart, name, OBJPROP_FONTSIZE, fontsize);
   ObjectSetString(IDchart, name, OBJPROP_FONT, fontname);
   ObjectSetInteger(IDchart, name, OBJPROP_COLOR, colour);
   ObjectSetDouble(IDchart, name, OBJPROP_ANGLE, angle);
   ObjectSetInteger(IDchart, name, OBJPROP_BACK, back);
   ObjectSetInteger(IDchart, name, OBJPROP_ANCHOR, align);
}