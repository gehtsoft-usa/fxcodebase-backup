// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68404

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

#property indicator_separate_window
#property indicator_buffers 39
#property indicator_plots 39
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_label1 "BUY"
#property indicator_label2 "SELL"

#property indicator_color3 Gray
#property indicator_width3 1
#property indicator_style3 STYLE_SOLID
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_color7 Green
#property indicator_color8 Green
#property indicator_color9 Green
#property indicator_label3 "P"
#property indicator_label4 "S1"
#property indicator_label5 "S2"
#property indicator_label6 "S3"
#property indicator_label7 "R1"
#property indicator_label8 "R2"
#property indicator_label9 "R3"

// Trading arrow with alert template v.1.1

string IndicatorName = "Black_Wall_Street_18_900 indi x3";

enum StochAlertType
{
   StochAlertTypeNothing, // Nothing
   StochAlertTypeAboveBelow, // Above/Below
   StochAlertTypeBetweenHighLow // Between High/Low
};

input int bars_limit = 1000; // Bars limit
input bool show_pivot = true; // Show Pivot indicators
input bool show_ssd = true; // Show SSD indicators
input double ssd_scale = 1; // SSD Scale
input double ssd_start = 0; // SSD Start Value
input ENUM_LINE_STYLE k_style = STYLE_SOLID; // SSD K Line style
input ENUM_LINE_STYLE d_style = STYLE_DOT; // SSD D Line style
input int min_distance = 0; // Min. time between signals

input string label_sequence_1 = "==="; // === Sequence 1 ===
input string StartTime1 = "000000"; // Start Time
input string StopTime1 = "240000"; // Stop Time

input string group_1_1 = ""; // === TF1 parameters ===
input ENUM_TIMEFRAMES tf1_1 = PERIOD_M15; // TF
input bool Stoch_Seq_SignalEnabled1_1 = true; // Stoch Seq Signal Enabled
input int ssd_k1_1 = 14; // %K
input int ssd_sd1_1 = 3; // %SD
input int ssd_d1_1 = 3; // %D
input double StochHigh1_1 = 80; // Stoch High
input double StochLow1_1 = 20; // Stoch Low
input StochAlertType Stoch_AlertType1_1 = StochAlertTypeBetweenHighLow; // Stoch Alert Type
input color tf1_1_ssd_color = Red; // SSD color

input string group_1_2 = ""; // === TF2 parameters ===
input ENUM_TIMEFRAMES tf1_2 = PERIOD_M30; // TF
input bool Stoch_Seq_SignalEnabled1_2 = true; // Stoch Seq Signal Enabled
input int ssd_k1_2 = 14; // %K
input int ssd_sd1_2 = 3; // %SD
input int ssd_d1_2 = 3; // %D
input double StochHigh1_2 = 80; // Stoch High
input double StochLow1_2 = 20; // Stoch Low
input StochAlertType Stoch_AlertType1_2 = StochAlertTypeBetweenHighLow; // Stoch Alert Type
input color tf1_2_ssd_color = Green; // SSD color

input string group_1_3 = ""; // === TF3 parameters ===
input ENUM_TIMEFRAMES tf1_3 = PERIOD_H1; // TF
input bool Stoch_Seq_SignalEnabled1_3 = true; // Stoch Seq Signal Enabled
input int ssd_k1_3 = 14; // %K
input int ssd_sd1_3 = 3; // %SD
input int ssd_d1_3 = 3; // %D
input double StochHigh1_3 = 80; // Stoch High
input double StochLow1_3 = 20; // Stoch Low
input StochAlertType Stoch_AlertType1_3 = StochAlertTypeBetweenHighLow; // Stoch Alert Type
input color tf1_3_ssd_color = Blue; // SSD color

input string group_1_4 = ""; // === TF4 parameters ===
input ENUM_TIMEFRAMES tf1_4 = PERIOD_H4; // TF
input bool Stoch_Seq_SignalEnabled1_4 = true; // Stoch Seq Signal Enabled
input int ssd_k1_4 = 14; // %K
input int ssd_sd1_4 = 3; // %SD
input int ssd_d1_4 = 3; // %D
input double StochHigh1_4 = 80; // Stoch High
input double StochLow1_4 = 20; // Stoch Low
input StochAlertType Stoch_AlertType1_4 = StochAlertTypeBetweenHighLow; // Stoch Alert Type
input color tf1_4_ssd_color = Maroon; // SSD color

input string group_1_5 = ""; // === TF5 parameters ===
input ENUM_TIMEFRAMES tf1_5 = PERIOD_H4; // TF
input bool Stoch_Seq_SignalEnabled1_5 = true; // Stoch Seq Signal Enabled
input int ssd_k1_5 = 14; // %K
input int ssd_sd1_5 = 3; // %SD
input int ssd_d1_5 = 3; // %D
input double StochHigh1_5 = 80; // Stoch High
input double StochLow1_5 = 20; // Stoch Low
input StochAlertType Stoch_AlertType1_5 = StochAlertTypeBetweenHighLow; // Stoch Alert Type
input color tf1_5_ssd_color = Lime; // SSD color

input string label_sequence_2 = "==="; // === Sequence 2 ===
input string StartTime2 = "000000"; // Start Time
input string StopTime2 = "240000"; // Stop Time

input string group_2_1 = ""; // === TF1 parameters ===
input ENUM_TIMEFRAMES tf2_1 = PERIOD_M15; // TF
input bool Stoch_Seq_SignalEnabled2_1 = true; // Stoch Seq Signal Enabled
input int ssd_k2_1 = 14; // %K
input int ssd_sd2_1 = 3; // %SD
input int ssd_d2_1 = 3; // %D
input double StochHigh2_1 = 80; // Stoch High
input double StochLow2_1 = 20; // Stoch Low
input StochAlertType Stoch_AlertType2_1 = StochAlertTypeBetweenHighLow; // Stoch Alert Type
input color tf2_1_ssd_color = Red; // SSD color

input string group_2_2 = ""; // === TF2 parameters ===
input ENUM_TIMEFRAMES tf2_2 = PERIOD_M30; // TF
input bool Stoch_Seq_SignalEnabled2_2 = true; // Stoch Seq Signal Enabled
input int ssd_k2_2 = 14; // %K
input int ssd_sd2_2 = 3; // %SD
input int ssd_d2_2 = 3; // %D
input double StochHigh2_2 = 80; // Stoch High
input double StochLow2_2 = 20; // Stoch Low
input StochAlertType Stoch_AlertType2_2 = StochAlertTypeBetweenHighLow; // Stoch Alert Type
input color tf2_2_ssd_color = Green; // SSD color

input string group_2_3 = ""; // === TF3 parameters ===
input ENUM_TIMEFRAMES tf2_3 = PERIOD_H1; // TF
input bool Stoch_Seq_SignalEnabled2_3 = true; // Stoch Seq Signal Enabled
input int ssd_k2_3 = 14; // %K
input int ssd_sd2_3 = 3; // %SD
input int ssd_d2_3 = 3; // %D
input double StochHigh2_3 = 80; // Stoch High
input double StochLow2_3 = 20; // Stoch Low
input StochAlertType Stoch_AlertType2_3 = StochAlertTypeBetweenHighLow; // Stoch Alert Type
input color tf2_3_ssd_color = Blue; // SSD color

input string group_2_4 = ""; // === TF4 parameters ===
input ENUM_TIMEFRAMES tf2_4 = PERIOD_H4; // TF
input bool Stoch_Seq_SignalEnabled2_4 = true; // Stoch Seq Signal Enabled
input int ssd_k2_4 = 14; // %K
input int ssd_sd2_4 = 3; // %SD
input int ssd_d2_4 = 3; // %D
input double StochHigh2_4 = 80; // Stoch High
input double StochLow2_4 = 20; // Stoch Low
input StochAlertType Stoch_AlertType2_4 = StochAlertTypeBetweenHighLow; // Stoch Alert Type
input color tf2_4_ssd_color = Maroon; // SSD color

input string group_2_5 = ""; // === TF5 parameters ===
input ENUM_TIMEFRAMES tf2_5 = PERIOD_H4; // TF
input bool Stoch_Seq_SignalEnabled2_5 = true; // Stoch Seq Signal Enabled
input int ssd_k2_5 = 14; // %K
input int ssd_sd2_5 = 3; // %SD
input int ssd_d2_5 = 3; // %D
input double StochHigh2_5 = 80; // Stoch High
input double StochLow2_5 = 20; // Stoch Low
input StochAlertType Stoch_AlertType2_5 = StochAlertTypeBetweenHighLow; // Stoch Alert Type
input color tf2_5_ssd_color = Lime; // SSD color

input string label_sequence_3 = "==="; // === Sequence 3 ===
input string StartTime3 = "000000"; // Start Time
input string StopTime3 = "240000"; // Stop Time

input string group_3_1 = ""; // === TF1 parameters ===
input ENUM_TIMEFRAMES tf3_1 = PERIOD_M15; // TF
input bool Stoch_Seq_SignalEnabled3_1 = true; // Stoch Seq Signal Enabled
input int ssd_k3_1 = 14; // %K
input int ssd_sd3_1 = 3; // %SD
input int ssd_d3_1 = 3; // %D
input double StochHigh3_1 = 80; // Stoch High
input double StochLow3_1 = 20; // Stoch Low
input StochAlertType Stoch_AlertType3_1 = StochAlertTypeBetweenHighLow; // Stoch Alert Type
input color tf3_1_ssd_color = Red; // SSD color

input string group_3_2 = ""; // === TF2 parameters ===
input ENUM_TIMEFRAMES tf3_2 = PERIOD_M30; // TF
input bool Stoch_Seq_SignalEnabled3_2 = true; // Stoch Seq Signal Enabled
input int ssd_k3_2 = 14; // %K
input int ssd_sd3_2 = 3; // %SD
input int ssd_d3_2 = 3; // %D
input double StochHigh3_2 = 80; // Stoch High
input double StochLow3_2 = 20; // Stoch Low
input StochAlertType Stoch_AlertType3_2 = StochAlertTypeBetweenHighLow; // Stoch Alert Type
input color tf3_2_ssd_color = Green; // SSD color

input string group_3_3 = ""; // === TF3 parameters ===
input ENUM_TIMEFRAMES tf3_3 = PERIOD_H1; // TF
input bool Stoch_Seq_SignalEnabled3_3 = true; // Stoch Seq Signal Enabled
input int ssd_k3_3 = 14; // %K
input int ssd_sd3_3 = 3; // %SD
input int ssd_d3_3 = 3; // %D
input double StochHigh3_3 = 80; // Stoch High
input double StochLow3_3 = 20; // Stoch Low
input StochAlertType Stoch_AlertType3_3 = StochAlertTypeBetweenHighLow; // Stoch Alert Type
input color tf3_3_ssd_color = Blue; // SSD color

input string group_3_4 = ""; // === TF4 parameters ===
input ENUM_TIMEFRAMES tf3_4 = PERIOD_H4; // TF
input bool Stoch_Seq_SignalEnabled3_4 = true; // Stoch Seq Signal Enabled
input int ssd_k3_4 = 14; // %K
input int ssd_sd3_4 = 3; // %SD
input int ssd_d3_4 = 3; // %D
input double StochHigh3_4 = 80; // Stoch High
input double StochLow3_4 = 20; // Stoch Low
input StochAlertType Stoch_AlertType3_4 = StochAlertTypeBetweenHighLow; // Stoch Alert Type
input color tf3_4_ssd_color = Maroon; // SSD color

input string group_3_5 = ""; // === TF5 parameters ===
input ENUM_TIMEFRAMES tf3_5 = PERIOD_H4; // TF
input bool Stoch_Seq_SignalEnabled3_5 = true; // Stoch Seq Signal Enabled
input int ssd_k3_5 = 14; // %K
input int ssd_sd3_5 = 3; // %SD
input int ssd_d3_5 = 3; // %D
input double StochHigh3_5 = 80; // Stoch High
input double StochLow3_5 = 20; // Stoch Low
input StochAlertType Stoch_AlertType3_5 = StochAlertTypeBetweenHighLow; // Stoch Alert Type
input color tf3_5_ssd_color = Lime; // SSD color

input string group_pivot = ""; // Pivot Parameters
input double MinDistanceBeforeLinesInPoints = 10; // Min Distance Before Lines In Pips
input double MinDistanceAfterLinesInPoints = 5; // Min Distance After Lines In Pips
input color pivot_color = Lime; // Pivot color

//Signaler v 1.2.1
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

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
//#import "AdvancedNotificationsLib.dll"
//void AdvancedAlert(string key, string text, string instrument, string timeframe);
//#import
#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDatetime;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SendNotifications(const int direction)
   {
      if (direction == 0 || MQLInfoInteger(MQL_TESTER))
         return;

      datetime currentTime = iTime(_symbol, _timeframe, 0);
      if (_lastDatetime == currentTime)
         return;

      _lastDatetime = currentTime;
      string tf = GetTimeframe();
      string alert_Subject;
      string alert_Body;
      switch (direction)
      {
         case ENTER_BUY_SIGNAL:
            alert_Subject = "Buy signal on " + _symbol + "/" + tf;
            alert_Body = "Buy signal on " + _symbol + "/" + tf;
            break;
         case ENTER_SELL_SIGNAL:
            alert_Subject = "Sell signal on " + _symbol + "/" + tf;
            alert_Body = "Sell signal on " + _symbol + "/" + tf;
            break;
            break;
      }
      SendNotifications(alert_Subject, alert_Body, _symbol, tf);
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
      SendNotifications("Alert", message, _symbol, GetTimeframe());
   }

private:
   string GetTimeframe()
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

// Symbol info v.1.1
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
   double GetPipSize() { return _pipSize; }
   int GetDigits() { return _digit; }
   string GetSymbol() { return _symbol; }
   double GetBid() { return SymbolInfoDouble(_symbol, SYMBOL_BID); }
   double GetAsk() { return SymbolInfoDouble(_symbol, SYMBOL_ASK); }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathRound(rate / _ticksize) * _ticksize, _digit);
   }
};

// Trading time v.1.1

enum DayOfWeek
{
   DayOfWeekSunday = 0, // Sunday
   DayOfWeekMonday = 1, // Monday
   DayOfWeekTuesday = 2, // Tuesday
   DayOfWeekWednesday = 3, // Wednesday
   DayOfWeekThursday = 4, // Thursday
   DayOfWeekFriday = 5, // Friday
   DayOfWeekSaturday = 6 // Saturday
};

class TradingTime
{
   int _startTime;
   int _endTime;
   bool _useWeekTime;
   int _weekStartTime;
   int _weekStartDay;
   int _weekStopTime;
   int _weekStopDay;
public:
   TradingTime()
   {
      _startTime = 0;
      _endTime = 0;
      _useWeekTime = false;
   }

   bool SetWeekTradingTime(const DayOfWeek startDay, const string startTime, const DayOfWeek stopDay, 
      const string stopTime, string &error)
   {
      _useWeekTime = true;
      _weekStartTime = ParseTime(startTime, error);
      if (_weekStartTime == -1)
         return false;
      _weekStopTime = ParseTime(stopTime, error);
      if (_weekStopTime == -1)
         return false;
      
      _weekStartDay = (int)startDay;
      _weekStopDay = (int)stopDay;
      return true;
   }

   bool Init(const string startTime, const string endTime, string &error)
   {
      _startTime = ParseTime(startTime, error);
      if (_startTime == -1)
         return false;
      _endTime = ParseTime(endTime, error);
      if (_endTime == -1)
         return false;

      return true;
   }

   bool IsTradingTime(datetime dt)
   {
      if (_startTime == _endTime && !_useWeekTime)
         return true;
      MqlDateTime current_time;
      if (!TimeToStruct(dt, current_time))
         return false;
      if (!IsIntradayTradingTime(current_time))
         return false;
      return IsWeeklyTradingTime(current_time);
   }
private:
   bool IsIntradayTradingTime(const MqlDateTime &current_time)
   {
      if (_startTime == _endTime)
         return true;
      int current_t = TimeToInt(current_time);
      if (_startTime > _endTime)
         return current_t >= _startTime || current_t <= _endTime;
      return current_t >= _startTime && current_t <= _endTime;
   }

   int TimeToInt(const MqlDateTime &current_time)
   {
      return (current_time.hour * 60 + current_time.min) * 60 + current_time.sec;
   }

   bool IsWeeklyTradingTime(const MqlDateTime &current_time)
   {
      if (!_useWeekTime)
         return true;
      if (current_time.day_of_week < _weekStartDay || current_time.day_of_week > _weekStopDay)
         return false;

      if (current_time.day_of_week == _weekStartDay)
      {
         int current_t = TimeToInt(current_time);
         return current_t >= _weekStartTime;
      }
      if (current_time.day_of_week == _weekStopDay)
      {
         int current_t = TimeToInt(current_time);
         return current_t < _weekStopTime;
      }

      return true;
   }

   int ParseTime(const string time, string &error)
   {
      int time_parsed = (int)StringToInteger(time);
      int seconds = time_parsed % 100;
      if (seconds > 59)
      {
         error = "Incorrect number of seconds in " + time;
         return -1;
      }
      time_parsed /= 100;
      int minutes = time_parsed % 100;
      if (minutes > 59)
      {
         error = "Incorrect number of minutes in " + time;
         return -1;
      }
      time_parsed /= 100;
      int hours = time_parsed % 100;
      if (hours > 24 || (hours == 24 && (minutes > 0 || seconds > 0)))
      {
         error = "Incorrect number of hours in " + time;
         return -1;
      }
      return (hours * 60 + minutes) * 60 + seconds;
   }
};

// Conditions v.1.0
interface ICondition
{
public:
   virtual bool IsPass(const int period) = 0;
};

class TradingTimeCondition : public ICondition
{
   TradingTime *_tradingTime;
   ENUM_TIMEFRAMES _timeframe;
public:
   TradingTimeCondition(ENUM_TIMEFRAMES timeframe)
   {
      _timeframe = timeframe;
      _tradingTime = new TradingTime();
   }

   ~TradingTimeCondition()
   {
      delete _tradingTime;
   }

   bool Init(const string startTime, const string endTime, string &error)
   {
      return _tradingTime.Init(startTime, endTime, error);
   }

   virtual bool IsPass(const int period)
   {
      datetime time = iTime(_Symbol, _timeframe, period);
      return _tradingTime.IsTradingTime(time);
   }
};

class MultiCondition : public ICondition
{
   ICondition *_conditions[];
public:
   ~MultiCondition()
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         delete _conditions[i];
      }
   }

   void Add(ICondition *condition)
   {
      int size = ArraySize(_conditions);
      ArrayResize(_conditions, size + 1);
      _conditions[size] = condition;
   }

   virtual bool IsPass(const int period)
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         if (!_conditions[i].IsPass(period))
            return false;
      }
      return true;
   }
};

double buy[], sell[];

class AStochasticCondition : public ICondition
{
protected:
   int _handle;
   ENUM_TIMEFRAMES _timeframe;
   StochAlertType _alertType;
   double _stochLow;
   double _stochHigh;
   double _k[];
   double _d[];

   AStochasticCondition(ENUM_TIMEFRAMES timeframe, int k, int sd, int d, StochAlertType alertType, double stochLow, double stochHigh)
   {
      _stochHigh = stochHigh;
      _stochLow = stochLow;
      _alertType = alertType;
      _timeframe = timeframe;
      _handle = iStochastic(_Symbol, timeframe, k, sd, d, MODE_SMA, STO_CLOSECLOSE);
   }

   ~AStochasticCondition()
   {
      IndicatorRelease(_handle);
   }

   string GetTimeframe()
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
public:
   int RegisterStreams(const int id, color clr)
   {
      if (!show_ssd)
         return id;

      string tf = GetTimeframe();
      SetIndexBuffer(id + 0, _k, INDICATOR_DATA);
      PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, k_style);
      PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
      PlotIndexSetInteger(id + 0, PLOT_LINE_COLOR, clr);
      PlotIndexSetString(id + 0, PLOT_LABEL, tf + " SSD.K");
      ArraySetAsSeries(_k, true);

      SetIndexBuffer(id + 1, _d, INDICATOR_DATA);
      PlotIndexSetInteger(id + 1, PLOT_LINE_STYLE, d_style);
      PlotIndexSetInteger(id + 1, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id + 1, PLOT_LINE_WIDTH, 1);
      PlotIndexSetInteger(id + 1, PLOT_LINE_COLOR, clr);
      PlotIndexSetString(id + 1, PLOT_LABEL, tf + " SSD.D");
      ArraySetAsSeries(_d, true);
      return id + 2;
   }

   void Clean()
   {
      if (!show_ssd)
         return;
      ArrayInitialize(_k, EMPTY_VALUE);
      ArrayInitialize(_d, EMPTY_VALUE);
   }

   bool Update(int period)
   {
      if (!show_ssd)
         return true;
      datetime time = iTime(_Symbol, _Period, period);
      int index = iBarShift(_Symbol, _timeframe, time);
      if (index < 0)
         return true;

      ResetLastError();
      double K[1], D[1];
      if (CopyBuffer(_handle, MAIN_LINE, index, 1, K) != 1 || CopyBuffer(_handle, SIGNAL_LINE, index, 1, D) != 1)
      {
         int error = GetLastError();
         switch (error)
         {
            case ERR_HISTORY_NOT_FOUND:
               return false;
         }
         return false;
      }

      _k[period] = ssd_start + K[0] / ssd_scale;
      _d[period] = ssd_start + D[0] / ssd_scale;
      return true;
   }
};

class StochasticUpCondition : public AStochasticCondition
{
public:
   StochasticUpCondition(ENUM_TIMEFRAMES timeframe, int k, int sd, int d, StochAlertType alertType, double stochLow, double stochHigh)
      :AStochasticCondition(timeframe, k, sd, d, alertType, stochLow, stochHigh)
   {
   }

   bool IsPass(const int period)
   {
      datetime time = iTime(_Symbol, _Period, period);
      int index = iBarShift(_Symbol, _timeframe, time);
      if (index < 0)
         return false;
      double K[1], D[1];
      if (CopyBuffer(_handle, MAIN_LINE, index, 1, K) != 1 || CopyBuffer(_handle, SIGNAL_LINE, index, 1, D) != 1)
         return false;
      if (K[0] <= D[0])
         return false;
      if (_alertType == StochAlertTypeBetweenHighLow)
      {
         if (K[0] <= _stochLow || K[0] >= _stochHigh)
            return false;
      }
      else if (_alertType == StochAlertTypeAboveBelow)
      {
         if (K[0] < _stochHigh)
            return false;
      }
      return true;
   }
};

class StochasticDownCondition : public AStochasticCondition
{
public:
   StochasticDownCondition(ENUM_TIMEFRAMES timeframe, int k, int sd, int d, StochAlertType alertType, double stochLow, double stochHigh)
      :AStochasticCondition(timeframe, k, sd, d, alertType, stochLow, stochHigh)
   {
   }

   bool IsPass(const int period)
   {
      datetime time = iTime(_Symbol, _Period, period);
      int index = iBarShift(_Symbol, _timeframe, time);
      if (index < 0)
         return false;
      double K[1], D[1];
      if (CopyBuffer(_handle, MAIN_LINE, index, 1, K) != 1 || CopyBuffer(_handle, SIGNAL_LINE, index, 1, D) != 1)
         return false;
      if (K[0] >= D[0])
         return false;
      if (_alertType == StochAlertTypeBetweenHighLow)
      {
         if (K[0] <= _stochLow || K[0] >= _stochHigh)
            return false;
      }
      else if (_alertType == StochAlertTypeAboveBelow)
      {
         if (K[0] > _stochLow)
            return false;
      }
      return true;
   }
};

class PivotUpCondition : public ICondition
{
   ENUM_TIMEFRAMES _timeframe;
public:
   PivotUpCondition(ENUM_TIMEFRAMES timeframe)
   {
      _timeframe = timeframe;
   }

   bool IsPass(const int period)
   {
      datetime time = iTime(_Symbol, _Period, period);
      int index = iBarShift(_Symbol, _timeframe, time);
      if (index < 0)
         return false;
      double pipSize = InstrumentInfo::GetPipSize(_Symbol);
      double close = iClose(_Symbol, _timeframe, index);
      double p = (_pivot.GetP(index) - close) / pipSize;
      double r1 = (_pivot.GetR1(index) - close) / pipSize;
      double r2 = (_pivot.GetR2(index) - close) / pipSize;
      double r3 = (_pivot.GetR3(index) - close) / pipSize;
      double s1 = (_pivot.GetS1(index) - close) / pipSize;
      double s2 = (_pivot.GetS2(index) - close) / pipSize;
      double s3 = (_pivot.GetS3(index) - close) / pipSize;
      return (p > MinDistanceBeforeLinesInPoints || -p > MinDistanceAfterLinesInPoints)
         && (r1 > MinDistanceBeforeLinesInPoints || -r1 > MinDistanceAfterLinesInPoints)
         && (r2 > MinDistanceBeforeLinesInPoints || -r2 > MinDistanceAfterLinesInPoints)
         && (r3 > MinDistanceBeforeLinesInPoints || -r3 > MinDistanceAfterLinesInPoints)
         && (s1 > MinDistanceBeforeLinesInPoints || -s1 > MinDistanceAfterLinesInPoints)
         && (s2 > MinDistanceBeforeLinesInPoints || -s2 > MinDistanceAfterLinesInPoints)
         && (s3 > MinDistanceBeforeLinesInPoints || -s3 > MinDistanceAfterLinesInPoints);
   }
};

class PivotDownCondition : public ICondition
{
   ENUM_TIMEFRAMES _timeframe;
public:
   PivotDownCondition(ENUM_TIMEFRAMES timeframe)
   {
      _timeframe = timeframe;
   }

   bool IsPass(const int period)
   {
      datetime time = iTime(_Symbol, _Period, period);
      int index = iBarShift(_Symbol, _timeframe, time);
      if (index < 0)
         return false;
      double pipSize = InstrumentInfo::GetPipSize(_Symbol);
      double close = iClose(_Symbol, _timeframe, index);
      double p = (close - _pivot.GetP(index)) / pipSize;
      double r1 = (close - _pivot.GetR1(index)) / pipSize;
      double r2 = (close - _pivot.GetR2(index)) / pipSize;
      double r3 = (close - _pivot.GetR3(index)) / pipSize;
      double s1 = (close - _pivot.GetS1(index)) / pipSize;
      double s2 = (close - _pivot.GetS2(index)) / pipSize;
      double s3 = (close - _pivot.GetS3(index)) / pipSize;
      return (-p > MinDistanceBeforeLinesInPoints || p > MinDistanceAfterLinesInPoints)
         && (-r1 > MinDistanceBeforeLinesInPoints || r1 > MinDistanceAfterLinesInPoints)
         && (-r2 > MinDistanceBeforeLinesInPoints || r2 > MinDistanceAfterLinesInPoints)
         && (-r3 > MinDistanceBeforeLinesInPoints || r3 > MinDistanceAfterLinesInPoints)
         && (-s1 > MinDistanceBeforeLinesInPoints || s1 > MinDistanceAfterLinesInPoints)
         && (-s2 > MinDistanceBeforeLinesInPoints || s2 > MinDistanceAfterLinesInPoints)
         && (-s3 > MinDistanceBeforeLinesInPoints || s3 > MinDistanceAfterLinesInPoints);
   }
};

datetime last_signal_global = 0;

bool EnoghtTimeSinceLastSignal(const int period)
{
   if (last_signal_global != 0)
   {
      double minutes_since_last_signal = ((double)iTime(_Symbol, _Period, 0) - last_signal_global) / 60;
      return minutes_since_last_signal >= min_distance;
   }
   return true;
}

void RememberSignalTime(const int period)
{
   last_signal_global = iTime(_Symbol, _Period, 0);
}

// Pivot v1.0
class Pivot
{
   ENUM_TIMEFRAMES _timeframe;
   double p_arr[];
   double s1_arr[];
   double s2_arr[];
   double s3_arr[];
   double r1_arr[];
   double r2_arr[];
   double r3_arr[];
public:
   Pivot(ENUM_TIMEFRAMES timeframe)
   {
      _timeframe = timeframe;
   }

   int RegisterStreams(const int id)
   {
      SetIndexBuffer(id + 0, p_arr, show_pivot ? INDICATOR_DATA : INDICATOR_CALCULATIONS);
      PlotIndexSetInteger(id + 0, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetInteger(id + 0, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id + 0, PLOT_LINE_WIDTH, 1);
      ArraySetAsSeries(p_arr, true);
      SetIndexBuffer(id + 1, s1_arr, show_pivot ? INDICATOR_DATA : INDICATOR_CALCULATIONS);
      PlotIndexSetInteger(id + 1, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetInteger(id + 1, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id + 1, PLOT_LINE_WIDTH, 1);
      ArraySetAsSeries(s1_arr, true);
      SetIndexBuffer(id + 2, s2_arr, show_pivot ? INDICATOR_DATA : INDICATOR_CALCULATIONS);
      PlotIndexSetInteger(id + 2, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetInteger(id + 2, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id + 2, PLOT_LINE_WIDTH, 1);
      ArraySetAsSeries(s2_arr, true);
      SetIndexBuffer(id + 3, s3_arr, show_pivot ? INDICATOR_DATA : INDICATOR_CALCULATIONS);
      PlotIndexSetInteger(id + 3, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetInteger(id + 3, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id + 3, PLOT_LINE_WIDTH, 1);
      ArraySetAsSeries(s3_arr, true);
      SetIndexBuffer(id + 4, r1_arr, show_pivot ? INDICATOR_DATA : INDICATOR_CALCULATIONS);
      PlotIndexSetInteger(id + 4, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetInteger(id + 4, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id + 4, PLOT_LINE_WIDTH, 1);
      ArraySetAsSeries(r1_arr, true);
      SetIndexBuffer(id + 5, r2_arr, show_pivot ? INDICATOR_DATA : INDICATOR_CALCULATIONS);
      PlotIndexSetInteger(id + 5, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetInteger(id + 5, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id + 5, PLOT_LINE_WIDTH, 1);
      ArraySetAsSeries(r2_arr, true);
      SetIndexBuffer(id + 6, r3_arr, show_pivot ? INDICATOR_DATA : INDICATOR_CALCULATIONS);
      PlotIndexSetInteger(id + 6, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetInteger(id + 6, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id + 6, PLOT_LINE_WIDTH, 1);
      ArraySetAsSeries(r3_arr, true);
      return id + 7;
   }

   void Clean()
   {
      ArrayInitialize(p_arr, EMPTY_VALUE);
      ArrayInitialize(s1_arr, EMPTY_VALUE);
      ArrayInitialize(r1_arr, EMPTY_VALUE);
      ArrayInitialize(s2_arr, EMPTY_VALUE);
      ArrayInitialize(r2_arr, EMPTY_VALUE);
      ArrayInitialize(s3_arr, EMPTY_VALUE);
      ArrayInitialize(r3_arr, EMPTY_VALUE);
   }

   bool Update(const int i)
   {
      double p, s1, s2, s3, r1, r2, r3;
      int btf_i = iBarShift(NULL, _timeframe, iTime(NULL, _Period, i));
      if (btf_i == -1)
         return false;
      if (!CalcPivot(btf_i, p, s1, s2, s3, r1, r2, r3))
         return false;
      p_arr[i] = p;
      s1_arr[i] = s1;
      r1_arr[i] = r1;
      s2_arr[i] = s2;
      r2_arr[i] = r2;
      s3_arr[i] = s3;
      r3_arr[i] = r3;
      return true;
   }

   double GetP(const int period) { return p_arr[period]; }
   double GetR1(const int period) { return r1_arr[period]; }
   double GetR2(const int period) { return r2_arr[period]; }
   double GetR3(const int period) { return r3_arr[period]; }
   double GetS1(const int period) { return s1_arr[period]; }
   double GetS2(const int period) { return s2_arr[period]; }
   double GetS3(const int period) { return s3_arr[period]; }
   
private:
   bool CalcPivot(const int i, double &p, 
      double &s1, double &s2, double &s3,
      double &r1, double &r2, double &r3)
   {
      ResetLastError();
      double high  = iHigh(NULL, _timeframe, i+1);
      int error = GetLastError();
      switch (error)
      {
         case ERR_HISTORY_NOT_FOUND:
            {
               static bool ERR_HISTORY_NOT_FOUND_printed = false;
               if (!ERR_HISTORY_NOT_FOUND_printed)
               {
                  Print("No history");
                  ERR_HISTORY_NOT_FOUND_printed = true;
               }
            }
            return false;
      }
      double low   = iLow(NULL, _timeframe, i+1);
      double open  = iOpen(NULL, _timeframe, i+1);
      double close = iClose(NULL, _timeframe, i+1);
      p = (high + low + close) / 3;
      r1 = (2 * p) - low;
      s1 = (2 * p) - high;
      r2 = p + (high - low);
      s2 = p - (high - low);
      r3 = p + (high - low) * 2;
      s3 = p - (high - low) * 2;
      return true;
   }
};

Signaler *_signaler;
Pivot *_pivot;

class Sequence
{
   AStochasticCondition *_conditions[];
public:
   MultiCondition *_upCondition;
   MultiCondition *_downCondition;

   Sequence()
   {
      _upCondition = new MultiCondition();
      _downCondition = new MultiCondition();
   }

   ~Sequence()
   {
      delete _upCondition;
      delete _downCondition;
   }

   bool Init(string startTime, string stopTime, string &error)
   {
      TradingTimeCondition *upTimeCondition = new TradingTimeCondition((ENUM_TIMEFRAMES)_Period);
      TradingTimeCondition *downTimeCondition = new TradingTimeCondition((ENUM_TIMEFRAMES)_Period);
      if (!upTimeCondition.Init(startTime, stopTime, error) || !downTimeCondition.Init(startTime, stopTime, error))
      {
         delete upTimeCondition;
         delete downTimeCondition;
         return false;
      }
      _upCondition.Add(upTimeCondition);
      _downCondition.Add(downTimeCondition);

      _upCondition.Add(new PivotUpCondition((ENUM_TIMEFRAMES)_Period));
      _downCondition.Add(new PivotDownCondition((ENUM_TIMEFRAMES)_Period));
      return true;
   }

   int AddTF(int id, bool useStoch, ENUM_TIMEFRAMES tf, int k, int sd, int d, StochAlertType alertType,
      double low, double high, color clr)
   {
      if (useStoch)
      {
         StochasticUpCondition *upCondition = new StochasticUpCondition(tf, k, sd, d, alertType, low, high);
         _upCondition.Add(upCondition);
         StochasticDownCondition *downCondition = new StochasticDownCondition(tf, k, sd, d, alertType, low, high);
         _downCondition.Add(downCondition);
         id = upCondition.RegisterStreams(id, clr);

         int size = ArraySize(_conditions);
         ArrayResize(_conditions, size + 1);
         _conditions[size] = upCondition;
      }
      return id;
   }

   void Clean()
   {
      int size = ArraySize(_conditions);
      for (int i = 0; i < size; ++i)
      {
         _conditions[i].Clean();
      }
   }

   bool Update(int pos)
   {
      int size = ArraySize(_conditions);
      bool success = true;
      for (int i = 0; i < size; ++i)
      {
         if (!_conditions[i].Update(pos))
            success = false;
      }
      return success;
   }
};

Sequence *sequences[];

void OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   SetIndexBuffer(0, buy, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, 217);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 10);
   ArraySetAsSeries(buy, true);

   SetIndexBuffer(1, sell, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_ARROW, 218);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, 10);
   ArraySetAsSeries(sell, true);
   
   _pivot = new Pivot(PERIOD_D1);
   int id = _pivot.RegisterStreams(2);

   ArrayResize(sequences, 3);
   sequences[0] = new Sequence();
   sequences[1] = new Sequence();
   sequences[2] = new Sequence();
   string error;
   if (!sequences[0].Init(StartTime1, StopTime1, error))
   {
      Print(error);
      return;
   }
   id = sequences[0].AddTF(id, Stoch_Seq_SignalEnabled1_1, tf1_1, ssd_k1_1, ssd_sd1_1, ssd_d1_1, 
      Stoch_AlertType1_1, StochLow1_1, StochHigh1_1, tf1_1_ssd_color);
   id = sequences[0].AddTF(id, Stoch_Seq_SignalEnabled1_2, tf1_2, ssd_k1_2, ssd_sd1_2, ssd_d1_2, 
      Stoch_AlertType1_2, StochLow1_2, StochHigh1_2, tf1_2_ssd_color);
   id = sequences[0].AddTF(id, Stoch_Seq_SignalEnabled1_3, tf1_3, ssd_k1_3, ssd_sd1_3, ssd_d1_3, 
      Stoch_AlertType1_3, StochLow1_3, StochHigh1_3, tf1_3_ssd_color);
   id = sequences[0].AddTF(id, Stoch_Seq_SignalEnabled1_4, tf1_4, ssd_k1_4, ssd_sd1_4, ssd_d1_4, 
      Stoch_AlertType1_4, StochLow1_4, StochHigh1_4, tf1_4_ssd_color);
   id = sequences[0].AddTF(id, Stoch_Seq_SignalEnabled1_5, tf1_5, ssd_k1_5, ssd_sd1_5, ssd_d1_5, 
      Stoch_AlertType1_5, StochLow1_5, StochHigh1_5, tf1_5_ssd_color);

   if (!sequences[1].Init(StartTime2, StopTime2, error))
   {
      Print(error);
      return;
   }
   id = sequences[1].AddTF(id, Stoch_Seq_SignalEnabled2_1, tf2_1, ssd_k2_1, ssd_sd2_1, ssd_d2_1, 
      Stoch_AlertType2_1, StochLow2_1, StochHigh2_1, tf2_2_ssd_color);
   id = sequences[1].AddTF(id, Stoch_Seq_SignalEnabled2_2, tf2_2, ssd_k2_2, ssd_sd2_2, ssd_d2_2, 
      Stoch_AlertType2_2, StochLow2_2, StochHigh2_2, tf2_2_ssd_color);
   id = sequences[1].AddTF(id, Stoch_Seq_SignalEnabled2_3, tf2_3, ssd_k2_3, ssd_sd2_3, ssd_d2_3, 
      Stoch_AlertType2_3, StochLow2_3, StochHigh2_3, tf2_3_ssd_color);
   id = sequences[1].AddTF(id, Stoch_Seq_SignalEnabled2_4, tf2_4, ssd_k2_4, ssd_sd2_4, ssd_d2_4, 
      Stoch_AlertType2_4, StochLow2_4, StochHigh2_4, tf2_4_ssd_color);
   id = sequences[1].AddTF(id, Stoch_Seq_SignalEnabled2_5, tf2_5, ssd_k2_5, ssd_sd2_5, ssd_d2_5, 
      Stoch_AlertType2_5, StochLow2_5, StochHigh2_5, tf2_5_ssd_color);

   if (!sequences[2].Init(StartTime3, StopTime3, error))
   {
      Print(error);
      return;
   }
   id = sequences[2].AddTF(id, Stoch_Seq_SignalEnabled3_1, tf3_1, ssd_k3_1, ssd_sd3_1, ssd_d3_1, 
      Stoch_AlertType3_1, StochLow3_1, StochHigh3_1, tf3_3_ssd_color);
   id = sequences[2].AddTF(id, Stoch_Seq_SignalEnabled3_2, tf3_2, ssd_k3_2, ssd_sd3_2, ssd_d3_2, 
      Stoch_AlertType3_2, StochLow3_2, StochHigh3_2, tf3_2_ssd_color);
   id = sequences[2].AddTF(id, Stoch_Seq_SignalEnabled3_3, tf3_3, ssd_k3_3, ssd_sd3_3, ssd_d3_3, 
      Stoch_AlertType3_3, StochLow3_3, StochHigh3_3, tf3_3_ssd_color);
   id = sequences[2].AddTF(id, Stoch_Seq_SignalEnabled3_4, tf3_4, ssd_k3_4, ssd_sd3_4, ssd_d3_4, 
      Stoch_AlertType3_4, StochLow3_4, StochHigh3_4, tf3_4_ssd_color);
   id = sequences[2].AddTF(id, Stoch_Seq_SignalEnabled3_5, tf3_5, ssd_k3_5, ssd_sd3_5, ssd_d3_5, 
      Stoch_AlertType3_5, StochLow3_5, StochHigh3_5, tf3_5_ssd_color);

   _signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   
   return;
}

void OnDeinit(const int reason)
{
   int size = ArraySize(sequences);
   for (int i = 0; i < size; ++i)
   {
      delete sequences[i];
   }
   delete _signaler;
   delete _pivot;
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
   if (rates_total <= 1) 
      return 0;
   if (prev_calculated < 0) 
      return -1;
   int limit = rates_total - 1;
   int size = ArraySize(sequences);
   if(prev_calculated > 1) 
      limit = rates_total - prev_calculated - 1;
   else
   {
      ArrayInitialize(buy, EMPTY_VALUE);
      ArrayInitialize(sell, EMPTY_VALUE);
      _pivot.Clean();
      for (int i = 0; i < size; ++i)
      {
         sequences[i].Clean();
      }
   }
   bool success = true;
   int pos = MathMin(bars_limit, limit);
   while (pos >= 0)
   {
      if (!_pivot.Update(pos))
         success = false;
      for (int i = 0; i < size; ++i)
      {
         if (!sequences[i].Update(pos))
            success = false;
         int direction = GetDirection(pos, sequences[i]);
         switch (direction)
         {
            case ENTER_BUY_SIGNAL:
               buy[pos] = low[rates_total - 1 - pos];
               sell[pos] = EMPTY_VALUE;
               break;
            case ENTER_SELL_SIGNAL:
               buy[pos] = EMPTY_VALUE;
               sell[pos] = high[rates_total - 1 - pos];
               break;
         }
         if (pos == 0)
            _signaler.SendNotifications(direction);
      }
      
      pos--;
   } 
   return success ? rates_total : 0;
}

int GetDirection(const int period, Sequence *sequence)
{
   if (sequence._upCondition.IsPass(period))
   {
      if (EnoghtTimeSinceLastSignal(period))
      {
         RememberSignalTime(period);
         return ENTER_BUY_SIGNAL;
      }
   }
   else if (sequence._downCondition.IsPass(period))
   {
      if (EnoghtTimeSinceLastSignal(period))
      {
         RememberSignalTime(period);
         return ENTER_SELL_SIGNAL;
      }
   }
   return 0;
}