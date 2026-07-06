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

enum StochAlertType
{
   StochAlertTypeNothing, // Nothing
   StochAlertTypeAboveBelow, // Above/Below
   StochAlertTypeBetweenHighLow // Between High/Low
};

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

input string group_1_2 = ""; // === TF2 parameters ===
input ENUM_TIMEFRAMES tf1_2 = PERIOD_M30; // TF
input bool Stoch_Seq_SignalEnabled1_2 = true; // Stoch Seq Signal Enabled
input int ssd_k1_2 = 14; // %K
input int ssd_sd1_2 = 3; // %SD
input int ssd_d1_2 = 3; // %D
input double StochHigh1_2 = 80; // Stoch High
input double StochLow1_2 = 20; // Stoch Low
input StochAlertType Stoch_AlertType1_2 = StochAlertTypeBetweenHighLow; // Stoch Alert Type

input string group_1_3 = ""; // === TF3 parameters ===
input ENUM_TIMEFRAMES tf1_3 = PERIOD_H1; // TF
input bool Stoch_Seq_SignalEnabled1_3 = true; // Stoch Seq Signal Enabled
input int ssd_k1_3 = 14; // %K
input int ssd_sd1_3 = 3; // %SD
input int ssd_d1_3 = 3; // %D
input double StochHigh1_3 = 80; // Stoch High
input double StochLow1_3 = 20; // Stoch Low
input StochAlertType Stoch_AlertType1_3 = StochAlertTypeBetweenHighLow; // Stoch Alert Type

input string group_1_4 = ""; // === TF4 parameters ===
input ENUM_TIMEFRAMES tf1_4 = PERIOD_H4; // TF
input bool Stoch_Seq_SignalEnabled1_4 = true; // Stoch Seq Signal Enabled
input int ssd_k1_4 = 14; // %K
input int ssd_sd1_4 = 3; // %SD
input int ssd_d1_4 = 3; // %D
input double StochHigh1_4 = 80; // Stoch High
input double StochLow1_4 = 20; // Stoch Low
input StochAlertType Stoch_AlertType1_4 = StochAlertTypeBetweenHighLow; // Stoch Alert Type

input string group_1_5 = ""; // === TF5 parameters ===
input ENUM_TIMEFRAMES tf1_5 = PERIOD_H4; // TF
input bool Stoch_Seq_SignalEnabled1_5 = true; // Stoch Seq Signal Enabled
input int ssd_k1_5 = 14; // %K
input int ssd_sd1_5 = 3; // %SD
input int ssd_d1_5 = 3; // %D
input double StochHigh1_5 = 80; // Stoch High
input double StochLow1_5 = 20; // Stoch Low
input StochAlertType Stoch_AlertType1_5 = StochAlertTypeBetweenHighLow; // Stoch Alert Type

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

input string group_2_2 = ""; // === TF2 parameters ===
input ENUM_TIMEFRAMES tf2_2 = PERIOD_M30; // TF
input bool Stoch_Seq_SignalEnabled2_2 = true; // Stoch Seq Signal Enabled
input int ssd_k2_2 = 14; // %K
input int ssd_sd2_2 = 3; // %SD
input int ssd_d2_2 = 3; // %D
input double StochHigh2_2 = 80; // Stoch High
input double StochLow2_2 = 20; // Stoch Low
input StochAlertType Stoch_AlertType2_2 = StochAlertTypeBetweenHighLow; // Stoch Alert Type

input string group_2_3 = ""; // === TF3 parameters ===
input ENUM_TIMEFRAMES tf2_3 = PERIOD_H1; // TF
input bool Stoch_Seq_SignalEnabled2_3 = true; // Stoch Seq Signal Enabled
input int ssd_k2_3 = 14; // %K
input int ssd_sd2_3 = 3; // %SD
input int ssd_d2_3 = 3; // %D
input double StochHigh2_3 = 80; // Stoch High
input double StochLow2_3 = 20; // Stoch Low
input StochAlertType Stoch_AlertType2_3 = StochAlertTypeBetweenHighLow; // Stoch Alert Type

input string group_2_4 = ""; // === TF4 parameters ===
input ENUM_TIMEFRAMES tf2_4 = PERIOD_H4; // TF
input bool Stoch_Seq_SignalEnabled2_4 = true; // Stoch Seq Signal Enabled
input int ssd_k2_4 = 14; // %K
input int ssd_sd2_4 = 3; // %SD
input int ssd_d2_4 = 3; // %D
input double StochHigh2_4 = 80; // Stoch High
input double StochLow2_4 = 20; // Stoch Low
input StochAlertType Stoch_AlertType2_4 = StochAlertTypeBetweenHighLow; // Stoch Alert Type

input string group_2_5 = ""; // === TF5 parameters ===
input ENUM_TIMEFRAMES tf2_5 = PERIOD_H4; // TF
input bool Stoch_Seq_SignalEnabled2_5 = true; // Stoch Seq Signal Enabled
input int ssd_k2_5 = 14; // %K
input int ssd_sd2_5 = 3; // %SD
input int ssd_d2_5 = 3; // %D
input double StochHigh2_5 = 80; // Stoch High
input double StochLow2_5 = 20; // Stoch Low
input StochAlertType Stoch_AlertType2_5 = StochAlertTypeBetweenHighLow; // Stoch Alert Type

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

input string group_3_2 = ""; // === TF2 parameters ===
input ENUM_TIMEFRAMES tf3_2 = PERIOD_M30; // TF
input bool Stoch_Seq_SignalEnabled3_2 = true; // Stoch Seq Signal Enabled
input int ssd_k3_2 = 14; // %K
input int ssd_sd3_2 = 3; // %SD
input int ssd_d3_2 = 3; // %D
input double StochHigh3_2 = 80; // Stoch High
input double StochLow3_2 = 20; // Stoch Low
input StochAlertType Stoch_AlertType3_2 = StochAlertTypeBetweenHighLow; // Stoch Alert Type

input string group_3_3 = ""; // === TF3 parameters ===
input ENUM_TIMEFRAMES tf3_3 = PERIOD_H1; // TF
input bool Stoch_Seq_SignalEnabled3_3 = true; // Stoch Seq Signal Enabled
input int ssd_k3_3 = 14; // %K
input int ssd_sd3_3 = 3; // %SD
input int ssd_d3_3 = 3; // %D
input double StochHigh3_3 = 80; // Stoch High
input double StochLow3_3 = 20; // Stoch Low
input StochAlertType Stoch_AlertType3_3 = StochAlertTypeBetweenHighLow; // Stoch Alert Type

input string group_3_4 = ""; // === TF4 parameters ===
input ENUM_TIMEFRAMES tf3_4 = PERIOD_H4; // TF
input bool Stoch_Seq_SignalEnabled3_4 = true; // Stoch Seq Signal Enabled
input int ssd_k3_4 = 14; // %K
input int ssd_sd3_4 = 3; // %SD
input int ssd_d3_4 = 3; // %D
input double StochHigh3_4 = 80; // Stoch High
input double StochLow3_4 = 20; // Stoch Low
input StochAlertType Stoch_AlertType3_4 = StochAlertTypeBetweenHighLow; // Stoch Alert Type

input string group_3_5 = ""; // === TF5 parameters ===
input ENUM_TIMEFRAMES tf3_5 = PERIOD_H4; // TF
input bool Stoch_Seq_SignalEnabled3_5 = true; // Stoch Seq Signal Enabled
input int ssd_k3_5 = 14; // %K
input int ssd_sd3_5 = 3; // %SD
input int ssd_d3_5 = 3; // %D
input double StochHigh3_5 = 80; // Stoch High
input double StochLow3_5 = 20; // Stoch Low
input StochAlertType Stoch_AlertType3_5 = StochAlertTypeBetweenHighLow; // Stoch Alert Type

input string group_pivot = ""; // Pivot Parameters
input double MinDistanceBeforeLinesInPoints = 10; // Min Distance Before Lines In Pips
input double MinDistanceAfterLinesInPoints = 5; // Min Distance After Lines In Pips

#include <Trade\Trade.mqh>

enum OrderSide
{
   BuySide,
   SellSide
};

CTrade tradeManager;

enum EntryType
{
   EntryOnClose, // Entry on candle close
   EntryLive // Entry on tick
};

enum TradingDirection
{
   LongSideOnly, // Long only
   ShortSideOnly, // Short only
   BothSides // Both
};

enum StopLimitType
{
   StopLimitDoNotUse, // Do not use
   StopLimitPercent, // Set in %
   StopLimitPips, // Set in Pips
   StopLimitDollar, // Set in $
   StopLimitRiskReward // Set in % of stop loss
};

enum PositionSizeType
{
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk // Risk in % of equity
};

enum PositionDirection
{
   DirectLogic, // Direct
   ReversalLogic // Reversal
};

enum TrailingType
{
   TrailingDontUse, // No trailing
   TrailingPips, // Use trailing in pips
   TrailingPercent // Use trailing in % of stop
};

input string GeneralSection = ""; // == General ==
input bool BTCAccount = false; // Is BTC Account?
input bool allow_trading = true; // Allow trading
input EntryType entry_type = EntryOnClose; // Entry type
input TradingDirection trading_direction = BothSides; // What trades should be taken
input double lot_size            = 0.1; // Position size
input PositionSizeType lot_type = PositionSizeContract; // Position size type
input int Slippage           = 3;
input bool close_on_opposite = true; // Close on opposite

input string SLSection            = ""; // == Stop loss/TakeProfit ==
input StopLimitType stop_loss_type = StopLimitPips; // Stop loss type
input double stop_loss_value            = 10; // Stop loss value
input TrailingType trailing_type = TrailingDontUse; // Use trailing
input double TrailingStep = 10; // Trailing step
input StopLimitType take_profit_type = StopLimitPips; // Take profit type
input double take_profit_value           = 10; // Take profit value
input StopLimitType breakeven_type = StopLimitPips; // Trigger type for the breakeven
input double breakeven_value = 10; // Trigger for the breakeven

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

input string OtherSection            = ""; // == Other ==
input int MagicNumber        = 42; // Magic number
input PositionDirection LogicType = DirectLogic; // Logic type
input string StartTime = "000000"; // Start time in hhmmss format
input string EndTime = "235959"; // End time in hhmmss format
input bool LimitWeeklyTime = false; // Weekly time
input DayOfWeek WeekStartDay = DayOfWeekSunday; // Start day
input string WeekStartTime = "000000"; // Start time in hhmmss format
input DayOfWeek WeekStopDay = DayOfWeekSaturday; // Stop day
input string WeekStopTime = "235959"; // Stop time in hhmmss format
input bool MandatoryClosing = false; // Mandatory closing for non-trading time

//Signaler v 1.4
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

// Trading time v.1.1

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

// Trades iterator v 1.1
enum CompareType
{
   CompareLessThan
};

class TradesIterator
{
   bool _useMagicNumber;
   int _magicNumber;
   int _orderType;
   bool _useSide;
   bool _isBuySide;
   int _lastIndex;
   bool _useSymbol;
   string _symbol;
   bool _useProfit;
   double _profit;
   CompareType _profitCompare;
public:
   TradesIterator()
   {
      _useMagicNumber = false;
      _useSide = false;
      _lastIndex = INT_MIN;
      _useSymbol = false;
      _useProfit = false;
   }

   void WhenSymbol(const string symbol)
   {
      _useSymbol = true;
      _symbol = symbol;
   }

   void WhenProfit(const double profit, const CompareType compare)
   {
      _useProfit = true;
      _profit = profit;
      _profitCompare = compare;
   }

   void WhenSide(const bool isBuy)
   {
      _useSide = true;
      _isBuySide = isBuy;
   }

   void WhenMagicNumber(const int magicNumber)
   {
      _useMagicNumber = true;
      _magicNumber = magicNumber;
   }
   
   ulong GetTicket() { return PositionGetTicket(_lastIndex); }
   double GetOpenPrice() { return PositionGetDouble(POSITION_PRICE_OPEN); }
   double GetStopLoss() { return PositionGetDouble(POSITION_SL); }
   double GetTakeProfit() { return PositionGetDouble(POSITION_TP); }
   ENUM_POSITION_TYPE GetPositionType() { return (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE); }

   int Count()
   {
      int count = 0;
      for (int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if (PositionSelectByTicket(ticket) && PassFilter(i))
         {
            count++;
         }
      }
      return count;
   }

   bool Next()
   {
      if (_lastIndex == INT_MIN)
      {
         _lastIndex = PositionsTotal() - 1;
      }
      else
         _lastIndex = _lastIndex - 1;
      while (_lastIndex >= 0)
      {
         ulong ticket = PositionGetTicket(_lastIndex);
         if (PositionSelectByTicket(ticket) && PassFilter(_lastIndex))
            return true;
         _lastIndex = _lastIndex - 1;
      }
      return false;
   }

   bool Any()
   {
      for (int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if (PositionSelectByTicket(ticket) && PassFilter(i))
         {
            return true;
         }
      }
      return false;
   }

private:
   bool PassFilter(const int index)
   {
      if (_useMagicNumber && PositionGetInteger(POSITION_MAGIC) != _magicNumber)
         return false;
      if (_useSymbol && PositionGetSymbol(index) != _symbol)
         return false;
      if (_useProfit)
      {
         switch (_profitCompare)
         {
            case CompareLessThan:
               if (PositionGetDouble(POSITION_PROFIT) >= _profit)
                  return false;
               break;
         }
      }
      if (_useSide)
      {
         ENUM_POSITION_TYPE positionType = GetPositionType();
         if (_isBuySide && positionType != POSITION_TYPE_BUY)
            return false;
         if (!_isBuySide && positionType != POSITION_TYPE_SELL)
            return false;
      }
      return true;
   }
};

// Trade calculator v.1.1
class TradeCalculator
{
   InstrumentInfo *_symbolInfo;
public:
   TradeCalculator(const string symbol)
   {
      _symbolInfo = new InstrumentInfo(symbol);
   }

   ~TradeCalculator()
   {
      delete _symbolInfo;
   }

   InstrumentInfo *GetSymbolInfo()
   {
      return _symbolInfo;
   }

   double GetBreakevenPrice(const bool isBuy, const int magicNumber)
   {
      string symbol = _symbolInfo.GetSymbol();
      double lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      double price = isBuy ? _symbolInfo.GetBid() : _symbolInfo.GetAsk();
      double totalPL = 0;
      double totalAmount = 0;
      TradesIterator it1();
      it1.WhenMagicNumber(magicNumber);
      it1.WhenSymbol(symbol);
      it1.WhenSide(isBuy);
      while (it1.Next())
      {
         double orderLots = PositionGetDouble(POSITION_VOLUME);
         totalAmount += orderLots / lotStep;
         double openPrice = it1.GetOpenPrice();
         if (isBuy)
            totalPL += (price - openPrice) * (orderLots / lotStep);
         else
            totalPL += (openPrice - price) * (orderLots / lotStep);
      }
      if (totalAmount == 0.0)
         return 0.0;
      double shift = -(totalPL / totalAmount);
      return isBuy ? price + shift : price - shift;
   }
   
   double CalculateTakeProfit(const bool isBuy, const double takeProfit, const StopLimitType takeProfitType, const double amount, double basePrice)
   {
      int direction = isBuy ? 1 : -1;
      switch (takeProfitType)
      {
         case StopLimitPercent:
            return basePrice + basePrice * takeProfit / 100.0 * direction;
         case StopLimitPips:
            return basePrice + takeProfit * _symbolInfo.GetPipSize() * direction;
         case StopLimitDollar:
            return basePrice + CalculateSLShift(amount, takeProfit) * direction;
      }
      return 0.0;
   }
   
   double CalculateStopLoss(const bool isBuy, const double stopLoss, const StopLimitType stopLossType, const double amount, double basePrice)
   {
      int direction = isBuy ? 1 : -1;
      switch (stopLossType)
      {
         case StopLimitPercent:
            return basePrice - basePrice * stopLoss / 100.0 * direction;
         case StopLimitPips:
            return basePrice - stopLoss * _symbolInfo.GetPipSize() * direction;
         case StopLimitDollar:
            return basePrice - CalculateSLShift(amount, stopLoss) * direction;
      }
      return 0.0;
   }

   double GetLots(PositionSizeType lotsType, double lotsValue, const OrderSide orderSide, const double price, double stopDistance)
   {
      switch (lotsType)
      {
         case PositionSizeAmount:
            return GetLotsForMoney(orderSide, price, lotsValue);
         case PositionSizeContract:
            return LimitLots(RoundLots(lotsValue));
         case PositionSizeEquity:
            return GetLotsForMoney(orderSide, price, AccountInfoDouble(ACCOUNT_EQUITY) * lotsValue / 100.0);
         case PositionSizeRisk:
         {
            double affordableLoss = AccountInfoDouble(ACCOUNT_EQUITY) * lotsValue / 100.0;
            double unitCost = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_VALUE);
            double tickSize = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_SIZE);
            double possibleLoss = unitCost * stopDistance / tickSize;
            if (possibleLoss <= 0.01)
               return 0;
            return LimitLots(RoundLots(affordableLoss / possibleLoss));
         }
      }
      return lotsValue;
   }

   bool IsLotsValid(const double lots, PositionSizeType lotsType, string &error)
   {
      switch (lotsType)
      {
         case PositionSizeContract:
            return IsContractLotsValid(lots, error);
      }
      return true;
   }

private:
   bool IsContractLotsValid(const double lots, string &error)
   {
      double minVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MIN);
      if (minVolume > lots)
      {
         error = "Min. allowed lot size is " + DoubleToString(minVolume);
         return false;
      }
      double maxVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
      {
         error = "Max. allowed lot size is " + DoubleToString(maxVolume);
         return false;
      }
      return true;
   }

   double GetLotsForMoney(const OrderSide orderSide, const double price, const double money)
   {
      ENUM_ORDER_TYPE orderType = orderSide != BuySide ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
      string symbol = _symbolInfo.GetSymbol();
      double minVolume = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double marginRequired;
      if (!OrderCalcMargin(orderType, symbol, minVolume, price, marginRequired))
      {
         return 0.0;
      }
      if (marginRequired <= 0.0)
      {
         Print("Margin is 0. Server misconfiguration?");
         return 0.0;
      }
      double lots = RoundLots(money / marginRequired);
      return LimitLots(lots);
   }

   double RoundLots(const double lots)
   {
      double lotStep = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
         return 0.0;
      return floor(lots / lotStep) * lotStep;
   }

   double LimitLots(const double lots)
   {
      double minVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MIN);
      if (minVolume > lots)
         return 0.0;
      double maxVolume = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
         return maxVolume;
      return lots;
   }

   double CalculateSLShift(const double amount, const double money)
   {
      double unitCost = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_symbolInfo.GetSymbol(), SYMBOL_TRADE_TICK_SIZE);
      return (money / (unitCost / tickSize)) / amount;
   }
};

// Conditions v.1.0
interface ICondition
{
public:
   virtual bool IsPass(const int period) = 0;
};

class DisabledCondition : public ICondition
{
public:
   virtual bool IsPass(const int period) { return false; }
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

class Sequence
{
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
      }
      return id;
   }
};

Sequence *sequences[];


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
      double pv, r1v, r2v, r3v, s1v, s2v, s3v;
      if (!_pivot.Get(period, pv, r1v, r2v, r3v, s1v, s2v, s3v))
         return false;
      double p = (pv - close) / pipSize;
      double r1 = (r1v - close) / pipSize;
      double r2 = (r2v - close) / pipSize;
      double r3 = (r3v - close) / pipSize;
      double s1 = (s1v - close) / pipSize;
      double s2 = (s2v - close) / pipSize;
      double s3 = (s3v - close) / pipSize;
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
      double pv, r1v, r2v, r3v, s1v, s2v, s3v;
      if (!_pivot.Get(period, pv, r1v, r2v, r3v, s1v, s2v, s3v))
         return false;
      double p = (close - pv) / pipSize;
      double r1 = (close - r1v) / pipSize;
      double r2 = (close - r2v) / pipSize;
      double r3 = (close - r3v) / pipSize;
      double s1 = (close - s1v) / pipSize;
      double s2 = (close - s2v) / pipSize;
      double s3 = (close - s3v) / pipSize;
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
public:
   Pivot(ENUM_TIMEFRAMES timeframe)
   {
      _timeframe = timeframe;
   }

   bool Get(const int i, double &p, double &s1, double &s2, double &s3, double &r1, double &r2, double &r3)
   {
      int btf_i = iBarShift(NULL, _timeframe, iTime(NULL, _Period, i));
      if (btf_i == -1)
         return false;
      if (!CalcPivot(btf_i, p, s1, s2, s3, r1, r2, r3))
         return false;
      return true;
   }
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

Pivot *_pivot;

class EntryLongCondition : public ICondition
{
   InstrumentInfo *_symbolInfo;
   ENUM_TIMEFRAMES _timeframe;
public:
   EntryLongCondition(InstrumentInfo *symbolInfo, ENUM_TIMEFRAMES timeframe)
   {
      _symbolInfo = symbolInfo;
      _timeframe = timeframe;
   }

   virtual bool IsPass(const int period)
   {
      if (sequences[0]._upCondition.IsPass(period)
         || sequences[1]._upCondition.IsPass(period)
         || sequences[2]._upCondition.IsPass(period))
      {
         if (EnoghtTimeSinceLastSignal(period))
         {
            RememberSignalTime(period);
            return true;
         }
      }
      return false;
   }
};

class EntryShortCondition : public ICondition
{
   InstrumentInfo *_symbolInfo;
   ENUM_TIMEFRAMES _timeframe;
public:
   EntryShortCondition(InstrumentInfo *symbolInfo, ENUM_TIMEFRAMES timeframe)
   {
      _symbolInfo = symbolInfo;
      _timeframe = timeframe;
   }

   virtual bool IsPass(const int period)
   {
      if (sequences[0]._downCondition.IsPass(period)
         || sequences[1]._downCondition.IsPass(period)
         || sequences[2]._downCondition.IsPass(period))
      {
         if (EnoghtTimeSinceLastSignal(period))
         {
            RememberSignalTime(period);
            return true;
         }
      }
      return false;
   }
};

// Money management strategy v.1.1
interface IMoneyManagementStrategy
{
public:
   virtual void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit) = 0;
};

class AMoneyManagementStrategy : public IMoneyManagementStrategy
{
protected:
   TradeCalculator *_calculator;
   PositionSizeType _lotsType;
   double _lots;
   StopLimitType _stopLossType;
   double _stopLoss;
   StopLimitType _takeProfitType;
   double _takeProfit;

   AMoneyManagementStrategy(TradeCalculator *calculator, PositionSizeType lotsType, double lots
      , StopLimitType stopLossType, double stopLoss, StopLimitType takeProfitType, double takeProfit)
   {
      _calculator = calculator;
      _lotsType = lotsType;
      _lots = lots;
      _stopLossType = stopLossType;
      _stopLoss = stopLoss;
      _takeProfitType = takeProfitType;
      _takeProfit = takeProfit;
   }
};

// Stream v.1.1
interface IStream
{
public:
   virtual bool GetValues(const int period, const int count, double &val[]) = 0;

   virtual int Size() = 0;
};

class AStream : public IStream
{
protected:
   InstrumentInfo *_symbolInfo;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;

   AStream(InstrumentInfo *symbolInfo, const ENUM_TIMEFRAMES timeframe)
   {
      _shift = 0.0;
      _symbolInfo = symbolInfo;
      _timeframe = timeframe;
   }

   ~AStream()
   {
   }
public:
   void SetShift(const double shift)
   {
      _shift = shift;
   }

   virtual int Size()
   {
      return iBars(_symbolInfo.GetSymbol(), _timeframe);
   }
};

class LongMoneyManagementStrategy : public AMoneyManagementStrategy
{
public:
   LongMoneyManagementStrategy(TradeCalculator *calculator, PositionSizeType lotsType, double lots
      , StopLimitType stopLossType, double stopLoss, StopLimitType takeProfitType, double takeProfit)
      : AMoneyManagementStrategy(calculator, lotsType, lots, stopLossType, stopLoss, takeProfitType, takeProfit)
   {
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      if (_lotsType == PositionSizeRisk)
      {
         stopLoss = _calculator.CalculateStopLoss(true, _stopLoss, _stopLossType, 0.0, entryPrice);
         amount = _calculator.GetLots(_lotsType, _lots, BuySide, entryPrice, entryPrice - stopLoss);
      }
      else
      {
         amount = _calculator.GetLots(_lotsType, _lots, BuySide, 0.0, 0);
         stopLoss = _calculator.CalculateStopLoss(true, _stopLoss, _stopLossType, amount, entryPrice);
      }
      if (_takeProfitType == StopLimitRiskReward)
         takeProfit = entryPrice + (entryPrice - stopLoss) * _takeProfit / 100;
      else
         takeProfit = _calculator.CalculateTakeProfit(true, _takeProfit, _takeProfitType, amount, entryPrice);
   }
};

class ShortMoneyManagementStrategy : public AMoneyManagementStrategy
{
public:
   ShortMoneyManagementStrategy(TradeCalculator *calculator, PositionSizeType lotsType, double lots
      , StopLimitType stopLossType, double stopLoss, StopLimitType takeProfitType, double takeProfit)
      : AMoneyManagementStrategy(calculator, lotsType, lots, stopLossType, stopLoss, takeProfitType, takeProfit)
   {
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      if (_lotsType == PositionSizeRisk)
      {
         stopLoss = _calculator.CalculateStopLoss(false, _stopLoss, _stopLossType, 0.0, entryPrice);
         amount = _calculator.GetLots(_lotsType, _lots, SellSide, entryPrice, stopLoss - entryPrice);
      }
      else
      {
         amount = _calculator.GetLots(_lotsType, _lots, SellSide, 0.0, 0);
         stopLoss = _calculator.CalculateStopLoss(false, _stopLoss, _stopLossType, amount, entryPrice);
      }
      if (_takeProfitType == StopLimitRiskReward)
         takeProfit = entryPrice - (entryPrice - stopLoss) * _takeProfit / 100;
      else
         takeProfit = _calculator.CalculateTakeProfit(false, _takeProfit, _takeProfitType, amount, entryPrice);
   }
};

// Orders iterator v 1.8
class OrdersIterator
{
   bool _useMagicNumber;
   int _magicNumber;
   bool _useOrderType;
   ENUM_ORDER_TYPE _orderType;
   bool _useSide;
   bool _isBuySide;
   int _lastIndex;
   bool _useSymbol;
   string _symbol;
   bool _usePendingOrder;
   bool _pendingOrder;
   bool _useComment;
   string _comment;
   CompareType _profitCompare;
public:
   OrdersIterator()
   {
      _useOrderType = false;
      _useMagicNumber = false;
      _usePendingOrder = false;
      _pendingOrder = false;
      _useSide = false;
      _lastIndex = INT_MIN;
      _useSymbol = false;
      _useComment = false;
   }

   OrdersIterator *WhenPendingOrder()
   {
      _usePendingOrder = true;
      _pendingOrder = true;
      return &this;
   }

   OrdersIterator *WhenSymbol(const string symbol)
   {
      _useSymbol = true;
      _symbol = symbol;
      return &this;
   }

   OrdersIterator *WhenSide(const OrderSide side)
   {
      _useSide = true;
      _isBuySide = side == BuySide;
      return &this;
   }

   OrdersIterator *WhenOrderType(const ENUM_ORDER_TYPE orderType)
   {
      _useOrderType = true;
      _orderType = orderType;
      return &this;
   }

   OrdersIterator *WhenMagicNumber(const int magicNumber)
   {
      _useMagicNumber = true;
      _magicNumber = magicNumber;
      return &this;
   }

   OrdersIterator *WhenComment(const string comment)
   {
      _useComment = true;
      _comment = comment;
      return &this;
   }

   long GetMagicNumger() { return OrderGetInteger(ORDER_MAGIC); }
   ENUM_ORDER_TYPE GetType() { return (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE); }
   string GetSymbol() { return OrderGetString(ORDER_SYMBOL); }
   ulong GetTicket() { return OrderGetTicket(_lastIndex); }

   int Count()
   {
      int count = 0;
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if (OrderSelect(ticket) && PassFilter())
            count++;
      }
      return count;
   }

   bool Next()
   {
      if (_lastIndex == INT_MIN)
         _lastIndex = OrdersTotal() - 1;
      else
         _lastIndex = _lastIndex - 1;
      while (_lastIndex >= 0)
      {
         ulong ticket = OrderGetTicket(_lastIndex);
         if (OrderSelect(ticket) && PassFilter())
            return true;
         _lastIndex = _lastIndex - 1;
      }
      return false;
   }

   bool Any()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if (OrderSelect(ticket) && PassFilter())
            return true;
      }
      return false;
   }

   ulong First()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if (OrderSelect(ticket) && PassFilter())
            return ticket;
      }
      return -1;
   }

private:
   bool PassFilter()
   {
      if (_useMagicNumber && GetMagicNumger() != _magicNumber)
         return false;
      if (_useOrderType && GetType() != _orderType)
         return false;
      if (_useSymbol && OrderGetString(ORDER_SYMBOL) != _symbol)
         return false;
      if (_usePendingOrder && !IsPendingOrder())
         return false;
      return true;
   }

   bool IsPendingOrder()
   {
      switch (GetType())
      {
         case ORDER_TYPE_BUY_LIMIT:
         case ORDER_TYPE_BUY_STOP:
         case ORDER_TYPE_BUY_STOP_LIMIT:
         case ORDER_TYPE_SELL_LIMIT:
         case ORDER_TYPE_SELL_STOP:
         case ORDER_TYPE_SELL_STOP_LIMIT:
            return true;
      }
      return false;
   }
};

// Trading commands v.1.1
class TradingCommands
{
public:
   static bool MoveStop(const ulong ticket, const double stopLoss, string &error)
   {
      if (!PositionSelectByTicket(ticket))
      {
         error = "Invalid ticket";
         return false;
      }
      return tradeManager.PositionModify(ticket, stopLoss, PositionGetDouble(POSITION_TP));
   }

   static void DeleteOrders(const int magicNumber, const string symbol)
   {
      OrdersIterator it();
      it.WhenMagicNumber(magicNumber);
      it.WhenSymbol(symbol);
      while (it.Next())
      {
         tradeManager.OrderDelete(it.GetTicket());
      }
   }

   static int CloseTrades(TradesIterator &it)
   {
      int close = 0;
      while (it.Next())
      {
         switch (it.GetPositionType())
         {
            case POSITION_TYPE_BUY:
               {
                  if (!tradeManager.PositionClose(it.GetTicket())) 
                     Print("LastError = ", GetLastError());
                  else
                     ++close;
               }
               break;
            case POSITION_TYPE_SELL:
               {
                  if (!tradeManager.PositionClose(it.GetTicket())) 
                     Print("LastError = ", GetLastError());
                  else
                     ++close;
               }
               break;
         }
      }
      return close;
   }
};

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1
#define EXIT_BUY_SIGNAL 2
#define EXIT_SELL_SIGNAL -2

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
         case EXIT_BUY_SIGNAL:
            alert_Subject = "Exit buy signal on " + _symbol + "/" + tf;
            alert_Body = "Exit buy signal on " + _symbol + "/" + tf;
            break;
         case EXIT_SELL_SIGNAL:
            alert_Subject = "Exit sell signal on " + _symbol + "/" + tf;
            alert_Body = "Exit sell signal on " + _symbol + "/" + tf;
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

// Trailing controller v.1.5
enum TrailingControllerType
{
   TrailingControllerTypeStandard,
   TrailingControllerTypeCustom
};

interface ITrailingController
{
public:
   virtual bool IsFinished() = 0;
   virtual void UpdateStop() = 0;
   virtual TrailingControllerType GetType() = 0;
};

class CustomLevelController : public ITrailingController
{
   Signaler *_signaler;
   ulong _order;
   bool _finished;
   double _stop;
   double _trigger;
   TradeCalculator *_tradeCalculator;
public:
   CustomLevelController(TradeCalculator *tradeCalculator, Signaler *signaler = NULL)
   {
      _tradeCalculator = tradeCalculator;
      _finished = true;
      _order = 0;
      _signaler = signaler;
      _trigger = 0;
      _stop = 0;
   }
   
   bool IsFinished()
   {
      return _finished;
   }

   bool SetOrder(const ulong order, const double stop, const double trigger)
   {
      if (!_finished)
      {
         return false;
      }
      if (!OrderSelect(order))
      {
         return false;
      }
      _trigger = trigger;
      _finished = false;
      _order = order;
      _stop = stop;
      
      return true;
   }

   void UpdateStop()
   {
      if (_finished)
         return;
      if (!PositionSelectByTicket(_order))
      {
         if (!OrderSelect(_order))
            _finished = true;
         return;
      }

      int type = (int)PositionGetInteger(POSITION_TYPE);
      double newStop = PositionGetDouble(POSITION_SL);
      if (type == POSITION_TYPE_BUY)
      {
         if (_trigger < _tradeCalculator.GetSymbolInfo().GetAsk()) 
         {
            if (_signaler != NULL)
            {
               string message = "Trailing stop loss for " + IntegerToString(_order) + " to " + DoubleToString(_stop);
               _signaler.SendNotifications(message);
            }
            string error;
            if (!TradingCommands::MoveStop(_order, _stop, error))
            {
               Print(error);
               return;
            }
            _finished = true;
         }
      }
      else if (type == POSITION_TYPE_SELL) 
      {
         if (_trigger > _tradeCalculator.GetSymbolInfo().GetBid()) 
         {
            if (_signaler != NULL)
            {
               string message = "Trailing stop loss for " + IntegerToString(_order) + " to " + DoubleToString(_stop);
               _signaler.SendNotifications(message);
            }
            string error;
            if (!TradingCommands::MoveStop(_order, _stop, error))
            {
               Print(error);
               return;
            }
            _finished = true;
         }
      }
   }

   TrailingControllerType GetType()
   {
      return TrailingControllerTypeCustom;
   }
};

class TrailingController : public ITrailingController
{
   Signaler *_signaler;
   ulong _order;
   bool _finished;
   double _stop;
   double _trailingStep;
   TradeCalculator *_tradeCalculator;
public:
   TrailingController(TradeCalculator *tradeCalculator, Signaler *signaler = NULL)
   {
      _tradeCalculator = tradeCalculator;
      _finished = true;
      _order = 0;
      _signaler = signaler;
   }
   
   bool IsFinished()
   {
      return _finished;
   }

   bool SetOrder(const ulong order, const double stop, const double trailingStep)
   {
      if (!_finished)
      {
         return false;
      }
      if (!OrderSelect(order))
      {
         return false;
      }
      _trailingStep = _tradeCalculator.GetSymbolInfo().RoundRate(trailingStep);
      if (_trailingStep == 0)
         return false;

      _finished = false;
      _order = order;
      _stop = stop;
      
      return true;
   }

   void UpdateStop()
   {
      if (_finished)
         return;
      if (!PositionSelectByTicket(_order))
      {
         if (!OrderSelect(_order))
            _finished = true;
         return;
      }

      int type = (int)PositionGetInteger(POSITION_TYPE);
      double originalStop = PositionGetDouble(POSITION_SL);
      double newStop = originalStop;
      if (type == POSITION_TYPE_BUY)
      {
         while (_tradeCalculator.GetSymbolInfo().RoundRate(newStop + _trailingStep) < _tradeCalculator.GetSymbolInfo().RoundRate(_tradeCalculator.GetSymbolInfo().GetAsk() - _stop))
         {
            newStop = _tradeCalculator.GetSymbolInfo().RoundRate(newStop + _trailingStep);
         }
         if (newStop != originalStop) 
         {
            if (_signaler != NULL)
            {
               string message = "Trailing stop loss for " + IntegerToString(_order) + " to " + DoubleToString(newStop, _tradeCalculator.GetSymbolInfo().GetDigits());
               _signaler.SendNotifications(message);
            }
            string error;
            if (!TradingCommands::MoveStop(_order, newStop, error))
            {
               Print(error);
               _finished = true;
               return;
            }
         }
      } 
      else if (type == POSITION_TYPE_SELL) 
      {
         while (_tradeCalculator.GetSymbolInfo().RoundRate(newStop - _trailingStep) > _tradeCalculator.GetSymbolInfo().RoundRate(_tradeCalculator.GetSymbolInfo().GetBid() + _stop))
         {
            newStop = _tradeCalculator.GetSymbolInfo().RoundRate(newStop - _trailingStep);
         }
         if (newStop != originalStop) 
         {
            if (_signaler != NULL)
            {
               string message = "Trailing stop loss for " + IntegerToString(_order) + " to " + DoubleToString(newStop, _tradeCalculator.GetSymbolInfo().GetDigits());
               _signaler.SendNotifications(message);
            }
            string error;
            if (!TradingCommands::MoveStop(_order, newStop, error))
            {
               Print(error);
               _finished = true;
               return;
            }
         }
      } 
   }

   TrailingControllerType GetType()
   {
      return TrailingControllerTypeStandard;
   }
};

class TrailingLogic
{
   ITrailingController *_trailing[];
   TradeCalculator *_calculator;
   TrailingType _trailingType;
   double _trailingStep;
   double _atrTrailingMultiplier;
   ENUM_TIMEFRAMES _timeframe;
public:
   TrailingLogic(TradeCalculator *calculator, TrailingType trailing, 
      double trailingStep, double atrTrailingMultiplier, ENUM_TIMEFRAMES timeframe)
   {
      _calculator = calculator;
      _trailingType = trailing;
      _trailingStep = trailingStep;
      _atrTrailingMultiplier = atrTrailingMultiplier;
      _timeframe = timeframe;
   }

   ~TrailingLogic()
   {
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         delete _trailing[i];
      }
   }

   void DoLogic()
   {
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         _trailing[i].UpdateStop();
      }
   }

   void CreateCustom(const ulong order, const double stop, const bool isBuy, const double triggerLevel)
   {
      if (!OrderSelect(order))
         return;

      string symbol = OrderGetString(ORDER_SYMBOL);
      if (symbol != _calculator.GetSymbolInfo().GetSymbol())
      {
         Print("Error in trailing usage");
         return;
      }

      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         if (_trailing[i].GetType() != TrailingControllerTypeCustom)
            continue;
         CustomLevelController *trailingController = (CustomLevelController *)_trailing[i];
         if (trailingController.SetOrder(order, stop, triggerLevel))
         {
            return;
         }
      }

      CustomLevelController *trailingController = new CustomLevelController(_calculator);
      trailingController.SetOrder(order, stop, triggerLevel);
      
      ArrayResize(_trailing, i_count + 1);
      _trailing[i_count] = trailingController;
   }

   void Create(const ulong order, const double stop, const bool isBuy)
   {
      if (!OrderSelect(order))
         return;

      string symbol = OrderGetString(ORDER_SYMBOL);
      if (symbol != _calculator.GetSymbolInfo().GetSymbol())
      {
         Print("Error in trailing usage");
         return;
      }
      double stopDiff = isBuy ? _calculator.GetSymbolInfo().GetAsk() - stop : stop - _calculator.GetSymbolInfo().GetBid();
      switch (_trailingType)
      {
         case TrailingPips:
            CreateTrailing(order, stopDiff, _trailingStep * _calculator.GetSymbolInfo().GetPipSize());
            break;
         case TrailingPercent:
            CreateTrailing(order, stopDiff, stopDiff * _trailingStep / 100.0);
            break;
      }
   }
private:
   void CreateTrailing(const ulong order, const double stop, const double trailingStep)
   {
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         if (_trailing[i].GetType() != TrailingControllerTypeStandard)
            continue;
         TrailingController *trailingController = (TrailingController *)_trailing[i];
         if (trailingController.SetOrder(order, stop, trailingStep))
         {
            return;
         }
      }

      TrailingController *trailingController = new TrailingController(_calculator);
      trailingController.SetOrder(order, stop, trailingStep);
      
      ArrayResize(_trailing, i_count + 1);
      _trailing[i_count] = trailingController;
   }
};

// Net stop loss v 1.0
interface INetStopLossStrategy
{
public:
   virtual void DoLogic() = 0;
};

// Disabled net stop loss
class NoNetStopLossStrategy : public INetStopLossStrategy
{
public:
   void DoLogic()
   {
      // Do nothing
   }
};

class NetStopLossStrategy : public INetStopLossStrategy
{
   TradeCalculator *_calculator;
   int _magicNumber;
   double _stopLossPips;
   Signaler *_signaler;
public:
   NetStopLossStrategy(TradeCalculator *calculator, const double stopLossPips, Signaler *signaler, const int magicNumber)
   {
      _calculator = calculator;
      _stopLossPips = stopLossPips;
      _signaler = signaler;
      _magicNumber = magicNumber;
   }

   void DoLogic()
   {
      MoveStopLoss(true);
      MoveStopLoss(false);
   }
private:
   void MoveStopLoss(const bool isBuy)
   {
      TradesIterator it();
      it.WhenMagicNumber(MagicNumber);
      it.WhenSide(isBuy);
      if (it.Count() <= 1)
         return;
      double averagePrice = _calculator.GetBreakevenPrice(isBuy, _magicNumber);
      if (averagePrice == 0.0)
         return;
         
      double pipSize = _calculator.GetSymbolInfo().GetPipSize();
      double stopLoss = isBuy ? _calculator.GetSymbolInfo().RoundRate(averagePrice - _stopLossPips * pipSize)
         : _calculator.GetSymbolInfo().RoundRate(averagePrice + _stopLossPips * pipSize);
      if (isBuy)
      {
         if (stopLoss >= _calculator.GetSymbolInfo().GetBid())
            return;
      }
      else
      {
         if (stopLoss <= _calculator.GetSymbolInfo().GetAsk())
            return;
      }
      
      TradesIterator it1();
      it1.WhenMagicNumber(_magicNumber);
      it1.WhenSymbol(_calculator.GetSymbolInfo().GetSymbol());
      it1.WhenSide(isBuy);
      int count = 0;
      while (it1.Next())
      {
         if (it1.GetStopLoss() != stopLoss)
         {
            string error = "";
            if (!TradingCommands::MoveStop(it1.GetTicket(), stopLoss, error))
            {
               if (error != "")
                  Print(error);
            }
            else
               ++count;
         }
      }
      if (_signaler != NULL && count > 0)
         _signaler.SendNotifications("Moving net stop loss to " + DoubleToString(stopLoss, _calculator.GetSymbolInfo().GetDigits()));
   }
};

// Breakeven controller v. 1.2
class BreakevenController
{
   ulong _order;
   bool _finished;
   double _trigger;
   double _target;
public:
   BreakevenController()
   {
      _finished = false;
   }
   
   bool SetOrder(const ulong order, const double trigger, const double target)
   {
      if (!_finished)
      {
         return false;
      }
      _finished = false;
      _trigger = trigger;
      _target = target;
      _order = order;
      return true;
   }

   void DoLogic()
   {
      if (_finished || !OrderSelect(_order))
      {
         _finished = true;
         return;
      }

      string symbol = OrderGetString(ORDER_SYMBOL);
      int type = (int)OrderGetInteger(ORDER_TYPE);
      if (type == ORDER_TYPE_BUY)
      {
         if (SymbolInfoDouble(symbol, SYMBOL_ASK) >= _trigger)
         {
            string error;
            bool res = TradingCommands::MoveStop(_order, _target, error);
            if (!res)
            {
               return;
            }
            _finished = true;
         }
      } 
      else if (type == ORDER_TYPE_SELL) 
      {
         if (SymbolInfoDouble(symbol, SYMBOL_BID) < _trigger) 
         {
            string error;
            bool res = TradingCommands::MoveStop(_order, _target, error);
            if (!res)
            {
               return;
            }
            _finished = true;
         }
      } 
   }
};

// Market order builder
// v.1.2
class MarketOrderBuilder
{
   OrderSide _orderSide;
   string _instrument;
   double _amount;
   double _rate;
   int _slippage;
   double _stop;
   double _limit;
   int _magicNumber;
   string _comment;
public:
   MarketOrderBuilder *SetComment(const string comment) { _comment = comment; return &this; }
   MarketOrderBuilder *SetSide(const OrderSide orderSide) { _orderSide = orderSide; return &this; }
   MarketOrderBuilder *SetInstrument(const string instrument) { _instrument = instrument; return &this; }
   MarketOrderBuilder *SetAmount(const double amount) { _amount = amount; return &this; }
   MarketOrderBuilder *SetSlippage(const int slippage) { _slippage = slippage; return &this; }
   MarketOrderBuilder *SetStopLoss(const double stop) { _stop = stop; return &this; }
   MarketOrderBuilder *SetTakeProfit(const double limit) { _limit = limit; return &this; }
   MarketOrderBuilder *SetMagicNumber(const int magicNumber) { _magicNumber = magicNumber; return &this; }
   
   ulong Execute(string &error)
   {
      int tradeMode = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_MODE);
      switch (tradeMode)
      {
         case SYMBOL_TRADE_MODE_DISABLED:
            error = "Trading is disbled";
            return 0;
         case SYMBOL_TRADE_MODE_CLOSEONLY:
            error = "Only close is allowed";
            return 0;
         case SYMBOL_TRADE_MODE_SHORTONLY:
            if (_orderSide == BuySide)
            {
               error = "Only short are allowed";
               return 0;
            }
         case SYMBOL_TRADE_MODE_LONGONLY:
            if (_orderSide == SellSide)
            {
               error = "Only long are allowed";
               return 0;
            }
      }
      ENUM_ORDER_TYPE orderType = _orderSide == BuySide ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
      int digits = (int)SymbolInfoInteger(_instrument, SYMBOL_DIGITS);
      double rate = _orderSide == BuySide ? SymbolInfoDouble(_instrument, SYMBOL_ASK) : SymbolInfoDouble(_instrument, SYMBOL_BID);
      double ticksize = SymbolInfoDouble(_instrument, SYMBOL_TRADE_TICK_SIZE);
      
      MqlTradeRequest request;
      ZeroMemory(request);
      request.action = TRADE_ACTION_DEAL;
      request.symbol = _instrument;
      request.type = orderType;
      request.volume = _amount;
      request.price = MathRound(rate / ticksize) * ticksize;
      request.deviation = _slippage;
      request.sl = MathRound(_stop / ticksize) * ticksize;
      request.tp = MathRound(_limit / ticksize) * ticksize;
      request.magic = _magicNumber;
      if (_comment != "")
         request.comment = _comment;
      if (BTCAccount)
         request.type_filling = SYMBOL_FILLING_FOK;
      MqlTradeResult result;
      ZeroMemory(result);
      bool res = OrderSend(request, result);
      switch (result.retcode)
      {
         case TRADE_RETCODE_INVALID_FILL:
            error = "Invalid order filling type";
            return 0;
         case TRADE_RETCODE_LONG_ONLY:
            error = "Only long trades are allowed for " + _instrument;
            return 0;
         case TRADE_RETCODE_INVALID_VOLUME:
            {
               double minVolume = SymbolInfoDouble(_instrument, SYMBOL_VOLUME_MIN);
               error = "Invalid volume in the request. Min volume is: " + DoubleToString(minVolume);
            }
            return 0;
         case TRADE_RETCODE_INVALID_PRICE:
            error = "Invalid price in the request";
            return 0;
         case TRADE_RETCODE_INVALID_STOPS:
            {
               int filling = (int)SymbolInfoInteger(_instrument, SYMBOL_ORDER_MODE); 
               if ((filling & SYMBOL_ORDER_SL) != SYMBOL_ORDER_SL)
               {
                  error = "Stop loss in now allowed for " + _instrument;
                  return 0;
               }

               int minStopDistancePoints = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_STOPS_LEVEL);
               double point = SymbolInfoDouble(_instrument, SYMBOL_POINT);
               double price = request.stoplimit > 0.0 ? request.stoplimit : request.price;
               if (MathRound(MathAbs(price - request.sl) / point) < minStopDistancePoints)
               {
                  error = "Your stop level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
               }
               else
               {
                  error = "Invalid stops in the request";
               }
            }
            return 0;
      }
      return result.order;
   }
};

// Trade controller v.1.14

#include <Trade\Trade.mqh>

class TradeController
{   
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastbartime;
   datetime _lastEntry;
   EntryType _entryType;
   Signaler *_signaler;
   TradingTime *_tradingTime;
   BreakevenController *_breakeven[];
   INetStopLossStrategy *_netStopLoss;
   TradeCalculator *_calculator;
   TrailingLogic *_trailing;
   ICondition *_longCondition;
   ICondition *_shortCondition;
   IMoneyManagementStrategy *_longMoneyManagementStrategy;
   IMoneyManagementStrategy *_shortMoneyManagementStrategy;
   bool _allowTrading;
public:
   TradeController(Signaler *signaler, TradeCalculator *calculator, ENUM_TIMEFRAMES timeframe, EntryType entryType, bool allowTrading)
   {
      _allowTrading = allowTrading;
      _longCondition = NULL;
      _shortCondition = NULL;
      _longMoneyManagementStrategy = NULL;
      _shortMoneyManagementStrategy = NULL;
      _netStopLoss = NULL;
      _signaler = signaler;
      _entryType = entryType;
      _timeframe = timeframe;
      _calculator = calculator;
      _tradingTime = NULL;
      _trailing = NULL;
   }

   ~TradeController()
   {
      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         delete _breakeven[i];
      }
      
      delete _longMoneyManagementStrategy;
      delete _shortMoneyManagementStrategy;
      delete _longCondition;
      delete _shortCondition;
      delete _trailing;
      delete _calculator;
      delete _signaler;
      delete _tradingTime;
      delete _netStopLoss;
   }

   TradeController *SetLongCondition(ICondition *condition) { _longCondition = condition; return &this; }
   TradeController *SetShortCondition(ICondition *condition) { _shortCondition = condition; return &this; }
   TradeController *SetTradingTime(TradingTime *tradingTime) { _tradingTime = tradingTime; return &this; }
   TradeController *SetTrailing(TrailingLogic *trailing) { _trailing = trailing; return &this; }
   TradeController *SetNetStopLossStrategy(INetStopLossStrategy *strategy) { _netStopLoss = strategy; return &this; }
   TradeController *SetLongMoneyManagementStrategy(IMoneyManagementStrategy *moneyManagementStrategy) { _longMoneyManagementStrategy = moneyManagementStrategy; return &this; }
   TradeController *SetShortMoneyManagementStrategy(IMoneyManagementStrategy *moneyManagementStrategy) { _shortMoneyManagementStrategy = moneyManagementStrategy; return &this; }

   void DoTrading()
   {
      _netStopLoss.DoLogic();
      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         _breakeven[i].DoLogic();
      }
      _trailing.DoLogic();

      string symbol = _calculator.GetSymbolInfo().GetSymbol();
      datetime current_time = iTime(symbol, _timeframe, 0);
      if (_tradingTime != NULL && !_tradingTime.IsTradingTime(current_time))
      {
         if (MandatoryClosing && _allowTrading)
         {
            TradesIterator it;
            it.WhenSymbol(symbol);
            it.WhenMagicNumber(MagicNumber);
            int closedCount = TradingCommands::CloseTrades(it);
            TradingCommands::DeleteOrders(MagicNumber, symbol);
            if (closedCount)
               _signaler.SendNotifications("Mandatory closing");
         }
         return;
      }

      int shift = 0;
      if (_entryType == EntryOnClose)
      {
         if (_lastEntry == current_time)
            return;
         _lastEntry = current_time;
         shift = 1;
      }
      current_time = iTime(symbol, _timeframe, shift);
      if (current_time == _lastbartime)
         return;
      if (_longCondition.IsPass(shift))
      {
         if (_allowTrading)
            GoLong(_longMoneyManagementStrategy, shift);
         _signaler.SendNotifications(ENTER_BUY_SIGNAL);
         _lastbartime = current_time;
      }
      if (_shortCondition.IsPass(shift))
      {
         if (_allowTrading)
            GoShort(_shortMoneyManagementStrategy, shift);
         _signaler.SendNotifications(ENTER_SELL_SIGNAL);
         _lastbartime = current_time;
      }
   }
private:
   ulong GoLong(IMoneyManagementStrategy *moneyManagementStrategy, const int period)
   {
      string symbol = _calculator.GetSymbolInfo().GetSymbol();
      if (close_on_opposite)
      {
         TradesIterator it();
         it.WhenMagicNumber(MagicNumber);
         it.WhenSide(SellSide);
         it.WhenSymbol(symbol);
         TradingCommands::CloseTrades(it);
      }

      double ask = _calculator.GetSymbolInfo().GetAsk();
      double amount = 0.0;
      double stopLoss = 0.0;
      double takeProfit = 0.0;
      moneyManagementStrategy.Get(period, ask, amount, stopLoss, takeProfit);
      if (amount == 0.0)
         return 0;
      
      string error;
      MarketOrderBuilder *orderBuilder = new MarketOrderBuilder();
      ulong order = orderBuilder
         .SetStopLoss(stopLoss)
         .SetSide(BuySide)
         .SetInstrument(symbol)
         .SetAmount(amount)
         .SetSlippage(Slippage)
         .SetMagicNumber(MagicNumber)
         .SetTakeProfit(takeProfit)
         .SetComment("")
         .Execute(error);
      delete orderBuilder;
      if (order != 0)
      {
         _lastbartime = iTime(symbol, _timeframe, 0);
         _trailing.Create(order, stopLoss, true);
         if (breakeven_type != StopLimitDoNotUse)
            CreateBreakeven(order);
      }
      else
         Print("Failed to open long position: " + error);
      return order;
   }

   ulong GoShort(IMoneyManagementStrategy *moneyManagementStrategy, const int period)
   {
      string symbol = _calculator.GetSymbolInfo().GetSymbol();
      if (close_on_opposite)
      {
         TradesIterator it();
         it.WhenMagicNumber(MagicNumber);
         it.WhenSide(BuySide);
         it.WhenSymbol(symbol);
         TradingCommands::CloseTrades(it);
      }

      double bid = _calculator.GetSymbolInfo().GetBid();
      double amount = 0.0;
      double stopLoss = 0.0;
      double takeProfit = 0.0;
      moneyManagementStrategy.Get(period, bid, amount, stopLoss, takeProfit);
      if (amount == 0.0)
         return 0;

      string error;
      MarketOrderBuilder *orderBuilder = new MarketOrderBuilder();
      ulong order = orderBuilder
         .SetStopLoss(stopLoss)
         .SetSide(SellSide)
         .SetInstrument(symbol)
         .SetAmount(amount)
         .SetSlippage(Slippage)
         .SetMagicNumber(MagicNumber)
         .SetTakeProfit(takeProfit)
         .SetComment("")
         .Execute(error);
      delete orderBuilder;
      if (order != 0)
      {
         _lastbartime = iTime(symbol, _timeframe, 0);
         _trailing.Create(order, stopLoss, false);
         if (breakeven_type != StopLimitDoNotUse)
            CreateBreakeven(order);
      }
      else
         Print("Failed to open short position: " + error);
      return order;
   }

   void CreateBreakeven(const ulong order)
   {
      if (!OrderSelect(order))
         return;
      ulong orderType = OrderGetInteger(ORDER_TYPE);
      string symbol = _calculator.GetSymbolInfo().GetSymbol();
      bool isBuy = orderType == ORDER_TYPE_BUY;
      double basePrice = isBuy ? _calculator.GetSymbolInfo().GetAsk() : _calculator.GetSymbolInfo().GetBid();
      double target = 0;
      double targetValue = isBuy 
         ? basePrice - target * _calculator.GetSymbolInfo().GetPipSize()
         : basePrice + target * _calculator.GetSymbolInfo().GetPipSize();
      double triggerValue = _calculator.CalculateTakeProfit(isBuy, breakeven_value, breakeven_type, OrderGetDouble(ORDER_VOLUME_CURRENT), basePrice);

      int i_count = ArraySize(_breakeven);
      for (int i = 0; i < i_count; ++i)
      {
         if (_breakeven[i].SetOrder(order, triggerValue, targetValue))
         {
            return;
         }
      }

      ArrayResize(_breakeven, i_count + 1);
      _breakeven[i_count] = new BreakevenController();
      _breakeven[i_count].SetOrder(order, triggerValue, targetValue);
   }
};

TradeController *tradeController;

int OnInit()
{
   TradingTime *tradingTime = new TradingTime();
   string error;
   if (!tradingTime.Init(StartTime, EndTime, error))
   {
      delete tradingTime;
      Print(error);
      return INIT_FAILED;
   }
   if (LimitWeeklyTime && !tradingTime.SetWeekTradingTime(WeekStartDay, WeekStartTime, WeekStopDay, WeekStopTime, error))
   {
      delete tradingTime;
      Print(error);
      return INIT_FAILED;
   }
   _pivot = new Pivot(PERIOD_D1);

   ArrayResize(sequences, 3);
   sequences[0] = new Sequence();
   sequences[1] = new Sequence();
   sequences[2] = new Sequence();
   if (!sequences[0].Init(StartTime1, StopTime1, error))
   {
      Print(error);
      return INIT_FAILED;
   }
   int id = sequences[0].AddTF(0, Stoch_Seq_SignalEnabled1_1, tf1_1, ssd_k1_1, ssd_sd1_1, ssd_d1_1, 
      Stoch_AlertType1_1, StochLow1_1, StochHigh1_1, 0);
   id = sequences[0].AddTF(id, Stoch_Seq_SignalEnabled1_2, tf1_2, ssd_k1_2, ssd_sd1_2, ssd_d1_2, 
      Stoch_AlertType1_2, StochLow1_2, StochHigh1_2, 0);
   id = sequences[0].AddTF(id, Stoch_Seq_SignalEnabled1_3, tf1_3, ssd_k1_3, ssd_sd1_3, ssd_d1_3, 
      Stoch_AlertType1_3, StochLow1_3, StochHigh1_3, 0);
   id = sequences[0].AddTF(id, Stoch_Seq_SignalEnabled1_4, tf1_4, ssd_k1_4, ssd_sd1_4, ssd_d1_4, 
      Stoch_AlertType1_4, StochLow1_4, StochHigh1_4, 0);
   id = sequences[0].AddTF(id, Stoch_Seq_SignalEnabled1_5, tf1_5, ssd_k1_5, ssd_sd1_5, ssd_d1_5, 
      Stoch_AlertType1_5, StochLow1_5, StochHigh1_5, 0);

   if (!sequences[1].Init(StartTime2, StopTime2, error))
   {
      Print(error);
      return INIT_FAILED;
   }
   id = sequences[1].AddTF(id, Stoch_Seq_SignalEnabled2_1, tf2_1, ssd_k2_1, ssd_sd2_1, ssd_d2_1, 
      Stoch_AlertType2_1, StochLow2_1, StochHigh2_1, 0);
   id = sequences[1].AddTF(id, Stoch_Seq_SignalEnabled2_2, tf2_2, ssd_k2_2, ssd_sd2_2, ssd_d2_2, 
      Stoch_AlertType2_2, StochLow2_2, StochHigh2_2, 0);
   id = sequences[1].AddTF(id, Stoch_Seq_SignalEnabled2_3, tf2_3, ssd_k2_3, ssd_sd2_3, ssd_d2_3, 
      Stoch_AlertType2_3, StochLow2_3, StochHigh2_3, 0);
   id = sequences[1].AddTF(id, Stoch_Seq_SignalEnabled2_4, tf2_4, ssd_k2_4, ssd_sd2_4, ssd_d2_4, 
      Stoch_AlertType2_4, StochLow2_4, StochHigh2_4, 0);
   id = sequences[1].AddTF(id, Stoch_Seq_SignalEnabled2_5, tf2_5, ssd_k2_5, ssd_sd2_5, ssd_d2_5, 
      Stoch_AlertType2_5, StochLow2_5, StochHigh2_5, 0);

   if (!sequences[2].Init(StartTime3, StopTime3, error))
   {
      Print(error);
      return INIT_FAILED;
   }
   id = sequences[2].AddTF(id, Stoch_Seq_SignalEnabled3_1, tf3_1, ssd_k3_1, ssd_sd3_1, ssd_d3_1, 
      Stoch_AlertType3_1, StochLow3_1, StochHigh3_1, 0);
   id = sequences[2].AddTF(id, Stoch_Seq_SignalEnabled3_2, tf3_2, ssd_k3_2, ssd_sd3_2, ssd_d3_2, 
      Stoch_AlertType3_2, StochLow3_2, StochHigh3_2, 0);
   id = sequences[2].AddTF(id, Stoch_Seq_SignalEnabled3_3, tf3_3, ssd_k3_3, ssd_sd3_3, ssd_d3_3, 
      Stoch_AlertType3_3, StochLow3_3, StochHigh3_3, 0);
   id = sequences[2].AddTF(id, Stoch_Seq_SignalEnabled3_4, tf3_4, ssd_k3_4, ssd_sd3_4, ssd_d3_4, 
      Stoch_AlertType3_4, StochLow3_4, StochHigh3_4, 0);
   id = sequences[2].AddTF(id, Stoch_Seq_SignalEnabled3_5, tf3_5, ssd_k3_5, ssd_sd3_5, ssd_d3_5, 
      Stoch_AlertType3_5, StochLow3_5, StochHigh3_5, 0);

   ENUM_TIMEFRAMES tf = (ENUM_TIMEFRAMES)_Period;
   TradeCalculator *tradeCalculator = new TradeCalculator(_Symbol);
   Signaler *signaler = new Signaler(_Symbol, _Period);
   tradeController = new TradeController(signaler, tradeCalculator, _Period, entry_type, allow_trading);
   tradeController.SetTradingTime(tradingTime);
   tradeController.SetTrailing(new TrailingLogic(tradeCalculator, trailing_type, TrailingStep, 0, tf));
   tradeController.SetNetStopLossStrategy(new NoNetStopLossStrategy());

   ICondition *longCondition = trading_direction != ShortSideOnly ? (ICondition *)new EntryLongCondition(tradeCalculator.GetSymbolInfo(), tf) : (ICondition *)new DisabledCondition();
   ICondition *shortCondition = trading_direction != LongSideOnly ? (ICondition *)new EntryShortCondition(tradeCalculator.GetSymbolInfo(), tf) : (ICondition *)new DisabledCondition();
   IMoneyManagementStrategy *longMoneyManagement = new LongMoneyManagementStrategy(tradeCalculator
      , lot_type, lot_size, stop_loss_type, stop_loss_value, take_profit_type, take_profit_value);
   IMoneyManagementStrategy *shortMoneyManagement = new ShortMoneyManagementStrategy(tradeCalculator
      , lot_type, lot_size, stop_loss_type, stop_loss_value, take_profit_type, take_profit_value);
   if (LogicType == DirectLogic)
   {
      tradeController.SetLongCondition(longCondition);
      tradeController.SetShortCondition(shortCondition);
      tradeController.SetLongMoneyManagementStrategy(longMoneyManagement);
      tradeController.SetShortMoneyManagementStrategy(shortMoneyManagement);
   }
   else
   {
      tradeController.SetLongCondition(shortCondition);
      tradeController.SetShortCondition(longCondition);
      tradeController.SetLongMoneyManagementStrategy(shortMoneyManagement);
      tradeController.SetShortMoneyManagementStrategy(longMoneyManagement);
   }

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   delete tradeController;
   int size = ArraySize(sequences);
   for (int i = 0; i < size; ++i)
   {
      delete sequences[i];
   }
   delete _pivot;
}

void OnTick()
{
   tradeController.DoTrading();
}
