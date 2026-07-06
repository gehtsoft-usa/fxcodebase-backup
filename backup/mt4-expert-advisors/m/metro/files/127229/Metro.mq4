// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68629

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

input double threshold = 0.0012; // Threshold

#define REVERSABLE_LOGIC_FEATURE extern

#define STOP_LOSS_FEATURE extern

#define TAKE_PROFIT_FEATURE extern

#define WEEKLY_TRADING_TIME_FEATURE extern
#define TRADING_TIME_FEATURE extern

#define POSITION_CAP_FEATURE extern

enum TradingMode
{
   TradingModeLive, // Live
   TradingModeOnBarClose // On bar close
};

extern string GeneralSection = ""; // == General ==
input TradingMode trade_live = TradingModeLive; // Trade live?
enum PositionSizeType
{
   PositionSizeAmount, // $
   PositionSizeContract, // In contracts
   PositionSizeEquity, // % of equity
   PositionSizeRisk // Risk in % of equity
};
enum LogicDirection
{
   DirectLogic, // Direct
   ReversalLogic // Reversal
};
enum TradingSide
{
   LongSideOnly, // Long
   ShortSideOnly, // Short
   BothSides // Both
};
extern double lots_value = 0.1; // Position size
extern PositionSizeType lots_type = PositionSizeContract; // Position size type
extern double leverage_override = 0; // Leverage override (for bad brokers, use 0 to disable)
extern int slippage_points = 3; // Slippage, points
extern TradingSide trading_side = BothSides; // What trades should be taken
REVERSABLE_LOGIC_FEATURE LogicDirection logic_direction = DirectLogic; // Logic type
extern bool close_on_opposite = true; // Close on opposite signal

string CapSection = ""; // == Position cap ==
bool position_cap = true; // Position Cap
int no_of_positions = 1; // Max # of buy+sell positions
int no_of_buy_position = 1; // Max # of buy positions
int no_of_sell_position = 1; // Max # of sell positions

STOP_LOSS_FEATURE string StopLossSection            = ""; // == Stop loss ==
enum TrailingType
{
   TrailingDontUse, // No trailing
   TrailingPips, // Use trailing in pips
   TrailingPercent // Use trailing in % of stop
};
enum StopLimitType
{
   StopLimitDoNotUse, // Do not use
   StopLimitPercent, // Set in %
   StopLimitPips, // Set in Pips
   StopLimitDollar, // Set in $,
   StopLimitRiskReward, // Set in % of stop loss
   StopLimitAbsolute // Set in absolite value (rate)
};
STOP_LOSS_FEATURE StopLimitType stop_loss_type = StopLimitDoNotUse; // Stop loss type
STOP_LOSS_FEATURE double stop_loss_value            = 10; // Stop loss value
STOP_LOSS_FEATURE TrailingType trailing_type = TrailingDontUse; // Trailing type
STOP_LOSS_FEATURE double trailing_step = 10; // Trailing step
STOP_LOSS_FEATURE double trailing_start = 0; // Min distance to order to activate the trailing
STOP_LOSS_FEATURE StopLimitType breakeven_type = StopLimitDoNotUse; // Trigger type for the breakeven
STOP_LOSS_FEATURE double breakeven_value = 10; // Trigger for the breakeven
STOP_LOSS_FEATURE double breakeven_level = 0; // Breakeven target

TAKE_PROFIT_FEATURE string TakeProfitSection            = ""; // == Take Profit ==
TAKE_PROFIT_FEATURE StopLimitType take_profit_type = StopLimitDoNotUse; // Take profit type
TAKE_PROFIT_FEATURE double take_profit_value           = 10; // Take profit value

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

TRADING_TIME_FEATURE string OtherSection            = ""; // == Other ==
TRADING_TIME_FEATURE int magic_number        = 42; // Magic number
TRADING_TIME_FEATURE string start_time = "000000"; // Start time in hhmmss format
TRADING_TIME_FEATURE string stop_time = "000000"; // Stop time in hhmmss format
WEEKLY_TRADING_TIME_FEATURE bool use_weekly_timing = false; // Weekly time
WEEKLY_TRADING_TIME_FEATURE DayOfWeek week_start_day = DayOfWeekSunday; // Start day
WEEKLY_TRADING_TIME_FEATURE string week_start_time = "000000"; // Start time in hhmmss format
WEEKLY_TRADING_TIME_FEATURE DayOfWeek week_stop_day = DayOfWeekSaturday; // Stop day
WEEKLY_TRADING_TIME_FEATURE string week_stop_time = "235959"; // Stop time in hhmmss format
WEEKLY_TRADING_TIME_FEATURE bool mandatory_closing = false; // Mandatory closing for non-trading time

bool ecn_broker = false;

//Signaler v 1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates
extern string   AlertsSection            = ""; // == Alerts ==
extern bool     popup_alert              = true; // Popup message
extern bool     notification_alert       = false; // Push notification
extern bool     email_alert              = false; // Email
extern bool     play_sound               = false; // Play sound on alert
extern string   sound_file               = ""; // Sound file
extern bool     start_program            = false; // Start external program
extern string   program_path             = ""; // Path to the external program executable
extern bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
extern string   advanced_key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
extern string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

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
   datetime _lastDatetime;
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

// Instrument info v.1.4
// More templates and snippets on https://github.com/sibvic/mq4-templates

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
};

// ICondition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface ICondition
{
public:
   virtual bool IsPass(const int period) = 0;
};

// Condition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IConditionFactory
{
public:
   virtual ICondition *CreateCondition(const int order) = 0;
};

// ABaseCondition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

class ABaseCondition : public ICondition
{
protected:
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo *_instrument;
   string _symbol;
public:
   ABaseCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _instrument = new InstrumentInfo(symbol);
      _timeframe = timeframe;
      _symbol = symbol;
   }
   ~ABaseCondition()
   {
      delete _instrument;
   }
protected:

   double PineActivationFunctionTanh(double v)
   {
      return (MathExp(v) - MathExp(-v)) / (MathExp(v) + MathExp(-v));
   }

   double ohlc4(int period)
   {
      return (iHigh(_symbol, PERIOD_D1, period) + iLow(_symbol, PERIOD_D1, period) + iClose(_symbol, PERIOD_D1, period) + iOpen(_symbol, PERIOD_D1, period)) / 4.0;
   }

   double GetL3(int period)
   {
      double yesterday = ohlc4(period + 1);
      double today = ohlc4(period);
      double delta = today - yesterday;
      double diff = delta / yesterday;
      double l0_0 = diff;
      double l0_1 = diff;
      double l0_2 = diff;
      double l0_3 = diff;
      double l0_4 = diff;
      double l0_5 = diff;
      double l0_6 = diff;
      double l0_7 = diff;
      double l0_8 = diff;
      double l0_9 = diff;
      double l0_10 = diff;
      double l0_11 = diff;
      double l0_12 = diff;
      double l0_13 = diff;
      double l0_14 = diff;
      
      double l1_0 = PineActivationFunctionTanh(l0_0*5.040340774 + l0_1*-1.3025994088 + l0_2*19.4225543981 + l0_3*1.1796960423 + l0_4*2.4299395823 + l0_5*3.159003445 + l0_6*4.6844527551 + l0_7*-6.1079267196 + l0_8*-2.4952869198 + l0_9*-4.0966081154 + l0_10*-2.2432843111 + l0_11*-0.6105764807 + l0_12*-0.0775684605 + l0_13*-0.7984753138 + l0_14*3.4495907342);
      double l1_1 = PineActivationFunctionTanh(l0_0*5.9559031982 + l0_1*-3.1781960056 + l0_2*-1.6337491061 + l0_3*-4.3623166512 + l0_4*0.9061990402 + l0_5*-0.731285093 + l0_6*-6.2500232251 + l0_7*0.1356087758 + l0_8*-0.8570572885 + l0_9*-4.0161353298 + l0_10*1.5095552083 + l0_11*1.324789197 + l0_12*-0.1011973878 + l0_13*-2.3642090162 + l0_14*-0.7160862442);
      double l1_2 = PineActivationFunctionTanh(l0_0*4.4350881378 + l0_1*-2.8956461034 + l0_2*1.4199762607 + l0_3*-0.6436844261 + l0_4*1.1124274281 + l0_5*-4.0976954985 + l0_6*2.9317456342 + l0_7*0.0798318393 + l0_8*-5.5718144311 + l0_9*-0.6623352208 +l0_10*3.2405203222 + l0_11*-10.6253384513 + l0_12*4.7132919253 + l0_13*-5.7378151597 + l0_14*0.3164836695);
      double l1_3 = PineActivationFunctionTanh(l0_0*-6.1194605467 + l0_1*7.7935605604 + l0_2*-0.7587522153 + l0_3*9.8382495905 + l0_4*0.3274314734 + l0_5*1.8424796541 + l0_6*-1.2256355427 + l0_7*-1.5968600758 + l0_8*1.9937700922 + l0_9*5.0417809111 + l0_10*-1.9369944654 + l0_11*6.1013201778 + l0_12*1.5832910747 + l0_13*-2.148403244 + l0_14*1.5449437366);
      double l1_4 = PineActivationFunctionTanh(l0_0*3.5700040028 + l0_1*-4.4755892733 + l0_2*0.1526702072 + l0_3*-0.3553664401 + l0_4*-2.3777962662 + l0_5*-1.8098849587 + l0_6*-3.5198449134 + l0_7*-0.4369370497 + l0_8*2.3350169623 + l0_9*1.9328960346 + l0_10*1.1824141812 + l0_11*3.0565148049 + l0_12*-9.3253401534 + l0_13*1.6778555498 + l0_14*-3.045794332);
      double l1_5 = PineActivationFunctionTanh(l0_0*3.6784907623 + l0_1*1.1623683715 + l0_2*7.1366362145 + l0_3*-5.6756546585 + l0_4*12.7019884334 + l0_5*-1.2347823331 + l0_6*2.3656619827 + l0_7*-8.7191778213 + l0_8*-13.8089238753 + l0_9*5.4335943836 + l0_10*-8.1441181338 + l0_11*-10.5688113287 + l0_12*6.3964140758 + l0_13*-8.9714236223 + l0_14*-34.0255456929);
      double l1_6 = PineActivationFunctionTanh(l0_0*-0.4344517548 + l0_1*-3.8262167437 + l0_2*-0.2051098003 + l0_3*0.6844201221 + l0_4*1.1615893422 + l0_5*-0.404465314 + l0_6*-0.1465747632 + l0_7*-0.006282458 + l0_8*0.1585655487 + l0_9*1.1994484991 + l0_10*-0.9879081404 + l0_11*-0.3564970612 + l0_12*1.5814717823 + l0_13*-0.9614804676 + l0_14*0.9204822346);
      double l1_7 = PineActivationFunctionTanh(l0_0*-4.2700957175 + l0_1*9.4328591157 + l0_2*-4.3045548 + l0_3*5.0616868842 + l0_4*3.3388781058 + l0_5*-2.1885073225 + l0_6*-6.506301518 + l0_7*3.8429000108 + l0_8*-1.6872237349 + l0_9*2.4107095799 + l0_10*-3.0873985314 + l0_11*-2.8358325447 + l0_12*2.4044366491 + l0_13*0.636779082 + l0_14*-13.2173215035);
      double l1_8 = PineActivationFunctionTanh(l0_0*-8.3224697492 + l0_1*-9.4825530183 + l0_2*3.5294389835 + l0_3*0.1538618049 + l0_4*-13.5388631898 + l0_5*-0.1187936017 + l0_6*-8.4582741139 + l0_7*5.1566299292 + l0_8*10.345519938 + l0_9*2.9211759333 + l0_10*-5.0471804233 + l0_11*4.9255989983 + l0_12*-9.9626142544 + l0_13*23.0043143258 + l0_14*20.9391809343);
      double l1_9 = PineActivationFunctionTanh(l0_0*-0.9120518654 + l0_1*0.4991807488 + l0_2*-1.877244586 + l0_3*3.1416466525 + l0_4*1.063709676 + l0_5*0.5210126835 + l0_6*-4.9755780108 + l0_7*2.0336532347 + l0_8*-1.1793121093 + l0_9*-0.730664855 + l0_10*-2.3515987428 + l0_11*-0.1916546514 + l0_12*-2.2530340504 + l0_13*-0.2331829119 + l0_14*0.7216218149);
      double l1_10 = PineActivationFunctionTanh(l0_0*-5.2139618683 + l0_1*1.0663790028 + l0_2*1.8340834959 + l0_3*1.6248173447 + l0_4*-0.7663740145 + l0_5*0.1062788171 + l0_6*2.5288021501 + l0_7*-3.4066549066 + l0_8*-4.9497988755 + l0_9*-2.3060668143 + l0_10*-1.3962486274 + l0_11*0.6185583427 + l0_12*0.2625299576 + l0_13*2.0270246444 + l0_14*0.6372015811);
      double l1_11 = PineActivationFunctionTanh(l0_0*0.2020072665 + l0_1*0.3885852709 + l0_2*-0.1830248843 + l0_3*-1.2408598444 + l0_4*-0.6365798088 + l0_5*1.8736534268 + l0_6*0.656206442 + l0_7*-0.2987482678 + l0_8*-0.2017485963 + l0_9*-1.0604095303 + l0_10*0.239793356 + l0_11*-0.3614172938 + l0_12*0.2614678044 + l0_13*1.0083551762 + l0_14*-0.5473833797);
      double l1_12 = PineActivationFunctionTanh(l0_0*-0.4367517149 + l0_1*-10.0601304934 + l0_2*1.9240604838 + l0_3*-1.3192184047 + l0_4*-0.4564760159 + l0_5*-0.2965270368 + l0_6*-1.1407423613 + l0_7*2.0949647291 + l0_8*-5.8212599297 + l0_9*-1.3393321939 + l0_10*7.6624548265 + l0_11*1.1309391851 + l0_12*-0.141798054 + l0_13*5.1416736187 + l0_14*-1.8142503125);
      double l1_13 = PineActivationFunctionTanh(l0_0*1.103948336 + l0_1*-1.4592033032 + l0_2*0.6146278432 + l0_3*0.5040966421 + l0_4*-2.4276090772 + l0_5*-0.0432902426 + l0_6*-0.0044259999 + l0_7*-0.5961347308 + l0_8*0.3821026107 + l0_9*0.6169102373 +l0_10*-0.1469847611 + l0_11*-0.0717167683 + l0_12*-0.0352403695 + l0_13*1.2481310788 + l0_14*0.1339628411);
      double l1_14 = PineActivationFunctionTanh(l0_0*-9.8049980534 + l0_1*13.5481068519 + l0_2*-17.1362809025 + l0_3*0.7142100864 + l0_4*4.4759163422 + l0_5*4.5716161777 + l0_6*1.4290884628 + l0_7*8.3952862712 + l0_8*-7.1613700432 + l0_9*-3.3249489518+ l0_10*-0.7789587912 + l0_11*-1.7987628873 + l0_12*13.364752545 + l0_13*5.3947219678 + l0_14*12.5267547127);
      double l1_15 = PineActivationFunctionTanh(l0_0*0.9869461803 + l0_1*1.9473351905 + l0_2*2.032925759 + l0_3*7.4092080633 + l0_4*-1.9257741399 + l0_5*1.8153585328 + l0_6*1.1427866392 + l0_7*-0.3723167449 + l0_8*5.0009927384 + l0_9*-0.2275103411 + l0_10*2.8823012914 + l0_11*-3.0633141934 + l0_12*-2.785334815 + l0_13*2.727981E-4 + l0_14*-0.1253009512);
      double l1_16 = PineActivationFunctionTanh(l0_0*4.9418118585 + l0_1*-2.7538199876 + l0_2*-16.9887588104 + l0_3*8.8734475297 + l0_4*-16.3022734814 + l0_5*-4.562496601 + l0_6*-1.2944373699 + l0_7*-9.6022946986 + l0_8*-1.018393866 + l0_9*-11.4094515429 + l0_10*24.8483091382 + l0_11*-3.0031522277 + l0_12*0.1513114555 + l0_13*-6.7170487021 + l0_14*-14.7759227576);
      double l1_17 = PineActivationFunctionTanh(l0_0*5.5931454656 + l0_1*2.22272078 + l0_2*2.603416897 + l0_3*1.2661196599 + l0_4*-2.842826446 + l0_5*-7.9386099121 + l0_6*2.8278849111 + l0_7*-1.2289445238 + l0_8*4.571484248 + l0_9*0.9447425595 + l0_10*4.2890688351 + l0_11*-3.3228258483 + l0_12*4.8866215526 + l0_13*1.0693412194 + l0_14*-1.963203112);
      double l1_18 = PineActivationFunctionTanh(l0_0*0.2705520264 + l0_1*0.4002328199 + l0_2*0.1592515845 + l0_3*0.371893552 + l0_4*-1.6639467871 + l0_5*2.2887318884 + l0_6*-0.148633664 + l0_7*-0.6517792263 + l0_8*-0.0993032992 + l0_9*-0.964940376 + l0_10*0.1286342935 + l0_11*0.4869943595 + l0_12*1.4498648166 + l0_13*-0.3257333384 + l0_14*-1.3496419812);
      double l1_19 = PineActivationFunctionTanh(l0_0*-1.3223200798 + l0_1*-2.2505204324 + l0_2*0.8142804525 + l0_3*-0.848348177 + l0_4*0.7208860589 + l0_5*1.2033423756 + l0_6*-0.1403005786 + l0_7*0.2995941644 + l0_8*-1.1440473062 + l0_9*1.067752916 + l0_10*-1.2990534679 + l0_11*1.2588583869 + l0_12*0.7670409455 + l0_13*2.7895972983 + l0_14*-0.5376152512);
      double l1_20 = PineActivationFunctionTanh(l0_0*0.7382351572 + l0_1*-0.8778865631 + l0_2*1.0950766363 + l0_3*0.7312146997 + l0_4*2.844781386 + l0_5*2.4526730903 + l0_6*-1.9175165077 + l0_7*-0.7443755288 + l0_8*-3.1591419438 + l0_9*0.8441602697 + l0_10*1.1979484448 + l0_11*2.138098544 + l0_12*0.9274159536 + l0_13*-2.1573448803 + l0_14*-3.7698356464);
      double l1_21 = PineActivationFunctionTanh(l0_0*5.187120117 + l0_1*-7.7525670576 + l0_2*1.9008346975 + l0_3*-1.2031603996 + l0_4*5.917669142 + l0_5*-3.1878682719 + l0_6*1.0311747828 + l0_7*-2.7529484612 + l0_8*-1.1165884578 + l0_9*2.5524942323 + l0_10*-0.38623241 + l0_11*3.7961317445 + l0_12*-6.128820883 + l0_13*-2.1470707709 + l0_14*2.0173792965);
      double l1_22 = PineActivationFunctionTanh(l0_0*-6.0241676562 + l0_1*0.7474455584 + l0_2*1.7435724844 + l0_3*0.8619835076 + l0_4*-0.1138406797 + l0_5*6.5979359352 + l0_6*1.6554154348 + l0_7*-3.7969458806 + l0_8*1.1139097376 + l0_9*-1.9588417 + l0_10*3.5123392221 + l0_11*9.4443103128 + l0_12*-7.4779291395 + l0_13*3.6975940671 + l0_14*8.5134262747);
      double l1_23 = PineActivationFunctionTanh(l0_0*-7.5486576471 + l0_1*-0.0281420865 + l0_2*-3.8586839454 + l0_3*-0.5648792233 + l0_4*-7.3927282026 + l0_5*-0.3857538046 + l0_6*-2.9779885698 + l0_7*4.0482279965 + l0_8*-1.1522499578 + l0_9*-4.1562500212 + l0_10*0.7813134307 + l0_11*-1.7582667612 + l0_12*1.7071109988 + l0_13*6.9270873208 + l0_14*-4.5871357362);
      double l1_24 = PineActivationFunctionTanh(l0_0*-5.3603442228 + l0_1*-9.5350611629 + l0_2*1.6749984422 + l0_3*-0.6511065892 + l0_4*-0.8424823239 + l0_5*1.9946675213 + l0_6*-1.1264361638 + l0_7*0.3228676616 + l0_8*5.3562230396 + l0_9*-1.6678168952+ l0_10*1.2612580068 + l0_11*-3.5362671399 + l0_12*-9.3895191366 + l0_13*2.0169228673 + l0_14*-3.3813191557);
      double l1_25 = PineActivationFunctionTanh(l0_0*1.1362866429 + l0_1*-1.8960071702 + l0_2*5.7047307243 + l0_3*-1.6049785053 + l0_4*-4.8353898931 + l0_5*-1.4865381145 + l0_6*-0.2846893475 + l0_7*2.2322095997 + l0_8*2.0930488668 + l0_9*1.7141411002 + l0_10*-3.4106032176 + l0_11*3.0593289612 + l0_12*-5.0894813904 + l0_13*-0.5316299133 + l0_14*0.4705265416);
      double l1_26 = PineActivationFunctionTanh(l0_0*-0.9401400975 + l0_1*-0.9136086957 + l0_2*-3.3808688582 + l0_3*4.7200776773 + l0_4*3.686296919 + l0_5*14.2133723935 + l0_6*1.5652940954 + l0_7*-0.2921139433 + l0_8*1.0244504511 + l0_9*-7.6918299134 + l0_10*-0.594936135 + l0_11*-1.4559914156 + l0_12*2.8056435224 + l0_13*2.6103905733 + l0_14*2.3412348872);
      double l1_27 = PineActivationFunctionTanh(l0_0*1.1573980186 + l0_1*2.9593661909 + l0_2*0.4512594325 + l0_3*-0.9357210858 + l0_4*-1.2445804495 + l0_5*4.2716471631 + l0_6*1.5167912375 + l0_7*1.5026853293 + l0_8*1.3574772038 + l0_9*-1.9754386842 + l0_10*6.727671436 + l0_11*8.0145772889 + l0_12*7.3108970663 + l0_13*-2.5005627841 + l0_14*8.9604502277);
      double l1_28 = PineActivationFunctionTanh(l0_0*6.3576350212 + l0_1*-2.9731672725 + l0_2*-2.7763558082 + l0_3*-3.7902984555 + l0_4*-1.0065574585 + l0_5*-0.7011836061 + l0_6*-1.0298068578 + l0_7*1.201007784 + l0_8*-0.7835862254 + l0_9*-3.9863597435 + l0_10*6.7851825502 + l0_11*1.1120256721 + l0_12*-2.263287351 + l0_13*1.8314374104 + l0_14*-2.279102097);
      double l1_29 = PineActivationFunctionTanh(l0_0*-7.8741911036 + l0_1*-5.3370618518 + l0_2*11.9153868964 + l0_3*-4.1237170553 + l0_4*2.9491152758 + l0_5*1.0317132502 + l0_6*2.2992199883 + l0_7*-2.0250502364 + l0_8*-11.0785995839 + l0_9*-6.3615588554 + l0_10*-1.1687644976 + l0_11*6.3323478015 + l0_12*6.0195076962 + l0_13*-2.8972208702 + l0_14*3.6107747183);
      
      double l2_0 = PineActivationFunctionTanh(l1_0*-0.590546797 + l1_1*0.6608304658 + l1_2*-0.3358268839 + l1_3*-0.748530283 + l1_4*-0.333460383 + l1_5*-0.3409307681 + l1_6*0.1916558198 + l1_7*-0.1200399453 + l1_8*-0.5166151854 + l1_9*-0.8537164676 +l1_10*-0.0214448647 + l1_11*-0.553290271 + l1_12*-1.2333302892 + l1_13*-0.8321813811 + l1_14*-0.4527761741 + l1_15*0.9012545631 + l1_16*0.415853215 + l1_17*0.1270548319 + l1_18*0.2000460279 + l1_19*-0.1741942671 + l1_20*0.419830522 + l1_21*-0.059839291 + l1_22*-0.3383001769 + l1_23*0.1617814073 + l1_24*0.3071848006 + l1_25*-0.3191182045 + l1_26*-0.4981831822 + l1_27*-1.467478375 + l1_28*-0.1676432563 + l1_29*1.2574849126);
      double l2_1 = PineActivationFunctionTanh(l1_0*-0.5514235841 + l1_1*0.4759190049 + l1_2*0.2103576983 + l1_3*-0.4754377924 + l1_4*-0.2362941295 + l1_5*0.1155082119 + l1_6*0.7424215794 + l1_7*-0.3674198672 + l1_8*0.8401574461 + l1_9*0.6096563193 + l1_10*0.7437935674 + l1_11*-0.4898638101 + l1_12*-0.4168668092 + l1_13*-0.0365111095 + l1_14*-0.342675224 + l1_15*0.1870268765 + l1_16*-0.5843050987 + l1_17*-0.4596547471 + l1_18*0.452188522 + l1_19*-0.6737126684 + l1_20*0.6876072741 + l1_21*-0.8067776704 + l1_22*0.7592979467 + l1_23*-0.0768239468 + l1_24*0.370536097 + l1_25*-0.4363884671 + l1_26*-0.419285676 + l1_27*0.4380251141 + l1_28*0.0822528948 + l1_29*-0.2333910809);
      double l2_2 = PineActivationFunctionTanh(l1_0*-0.3306539521 + l1_1*-0.9382247194 + l1_2*0.0746711276 + l1_3*-0.3383838985 + l1_4*-0.0683232217 + l1_5*-0.2112358049 + l1_6*-0.9079234054 + l1_7*0.4898595603 + l1_8*-0.2039825863 + l1_9*1.0870698641+ l1_10*-1.1752901237 + l1_11*1.1406403923 + l1_12*-0.6779626786 + l1_13*0.4281048906 + l1_14*-0.6327670055 + l1_15*-0.1477678844 + l1_16*0.2693637584 + l1_17*0.7250738509 + l1_18*0.7905904504 + l1_19*-1.6417250883 + l1_20*-0.2108095534 +l1_21*-0.2698557472 + l1_22*-0.2433656685 + l1_23*-0.6289943273 + l1_24*0.436428207 + l1_25*-0.8243825184 + l1_26*-0.8583496686 + l1_27*0.0983131026 + l1_28*-0.4107462518 + l1_29*0.5641683087);
      double l2_3 = PineActivationFunctionTanh(l1_0*1.7036869992 + l1_1*-0.6683507666 + l1_2*0.2589197112 + l1_3*0.032841148 + l1_4*-0.4454796342 + l1_5*-0.6196149423 + l1_6*-0.1073622976 + l1_7*-0.1926393101 + l1_8*1.5280232458 + l1_9*-0.6136527036 +l1_10*-1.2722934357 + l1_11*0.2888655811 + l1_12*-1.4338638512 + l1_13*-1.1903556863 + l1_14*-1.7659663905 + l1_15*0.3703086867 + l1_16*1.0409140889 + l1_17*0.0167382209 + l1_18*0.6045646461 + l1_19*4.2388788116 + l1_20*1.4399738234 + l1_21*0.3308571935 + l1_22*1.4501137667 + l1_23*0.0426123724 + l1_24*-0.708479795 + l1_25*-1.2100800732 + l1_26*-0.5536278651 + l1_27*1.3547250573 + l1_28*1.2906250286 + l1_29*0.0596007114);
      double l2_4 = PineActivationFunctionTanh(l1_0*-0.462165126 + l1_1*-1.0996742176 + l1_2*1.0928262999 + l1_3*1.806407067 + l1_4*0.9289147669 + l1_5*0.8069022793 + l1_6*0.2374237802 + l1_7*-2.7143979019 + l1_8*-2.7779203877 + l1_9*0.214383903 + l1_10*-1.3111536623 + l1_11*-2.3148813568 + l1_12*-2.4755355804 + l1_13*-0.6819733236 + l1_14*0.4425615226 + l1_15*-0.1298218043 + l1_16*-1.1744832824 + l1_17*-0.395194848 + l1_18*-0.2803397703 + l1_19*-0.4505071197 + l1_20*-0.8934956598 + l1_21*3.3232916348 + l1_22*-1.7359534851 + l1_23*3.8540421743 + l1_24*1.4424032523 + l1_25*0.2639823693 + l1_26*0.3597053634 + l1_27*-1.0470693728 + l1_28*1.4133480357 + l1_29*0.6248098695);
      double l2_5 = PineActivationFunctionTanh(l1_0*0.2215807411 + l1_1*-0.5628295071 + l1_2*-0.8795982905 + l1_3*0.9101585104 + l1_4*-1.0176831976 + l1_5*-0.0728884401 + l1_6*0.6676331658 + l1_7*-0.7342174108 + l1_8*9.4428E-4 + l1_9*0.6439774272 + l1_10*-0.0345236026 + l1_11*0.5830977027 + l1_12*-0.4058921837 + l1_13*-0.3991888077 + l1_14*-1.0090426973 + l1_15*-0.9324780698 + l1_16*-0.0888749165 + l1_17*0.2466351736 + l1_18*0.4993304601 + l1_19*-1.115408696 + l1_20*0.9914246705 + l1_21*0.9687743445 + l1_22*0.1117130875 + l1_23*0.7825109733 + l1_24*0.2217023612 + l1_25*0.3081256411 + l1_26*-0.1778007966 + l1_27*-0.3333287743 + l1_28*1.0156352461 + l1_29*-0.1456257813);
      double l2_6 = PineActivationFunctionTanh(l1_0*-0.5461783383 + l1_1*0.3246015999 + l1_2*0.1450605434 + l1_3*-1.3179944349 + l1_4*-1.5481775261 + l1_5*-0.679685633 + l1_6*-0.9462335139 + l1_7*-0.6462399371 + l1_8*0.0991658683 + l1_9*0.1612892194 +l1_10*-1.037660602 + l1_11*-0.1044778824 + l1_12*0.8309203243 + l1_13*0.7714766458 + l1_14*0.2566767663 + l1_15*0.8649416329 + l1_16*-0.5847461285 + l1_17*-0.6393969272 + l1_18*0.8014049359 + l1_19*0.2279568228 + l1_20*1.0565217821 + l1_21*0.134738029 + l1_22*0.3420395576 + l1_23*-0.2417397219 + l1_24*0.3083072038 + l1_25*0.6761739059 + l1_26*-0.4653817053 + l1_27*-1.0634057566 + l1_28*-0.5658892281 + l1_29*-0.6947283681);
      double l2_7 = PineActivationFunctionTanh(l1_0*-0.5450410944 + l1_1*0.3912849372 + l1_2*-0.4118641117 + l1_3*0.7124695074 + l1_4*-0.7510266122 + l1_5*1.4065673913 + l1_6*0.9870731545 + l1_7*-0.2609363107 + l1_8*-0.3583639958 + l1_9*0.5436375706 +l1_10*0.4572450099 + l1_11*-0.4651538878 + l1_12*-0.2180218212 + l1_13*0.5241262959 + l1_14*-0.8529323253 + l1_15*-0.4200378937 + l1_16*0.4997885721 + l1_17*-1.1121528189 + l1_18*0.5992411048 + l1_19*-1.0263270781 + l1_20*-1.725160642 + l1_21*-0.2653995722 + l1_22*0.6996703032 + l1_23*0.348549086 + l1_24*0.6522482482 + l1_25*-0.7931928436 + l1_26*-0.5107994359 + l1_27*0.0509642698 + l1_28*0.8711187423 + l1_29*0.8999449627);
      double l2_8 = PineActivationFunctionTanh(l1_0*-0.7111081522 + l1_1*0.4296245062 + l1_2*-2.0720732038 + l1_3*-0.4071818684 + l1_4*1.0632721681 + l1_5*0.8463224325 + l1_6*-0.6083948423 + l1_7*1.1827669608 + l1_8*-0.9572307844 + l1_9*-0.9080517673 + l1_10*-0.0479029057 + l1_11*-1.1452853213 + l1_12*0.2884352688 + l1_13*0.1767851586 + l1_14*-1.089314461 + l1_15*1.2991763966 + l1_16*1.6236630806 + l1_17*-0.7720263697 + l1_18*-0.5011541755 + l1_19*-2.3919413568 + l1_20*0.0084018338 + l1_21*0.9975216139 + l1_22*0.4193541029 + l1_23*1.4623834571 + l1_24*-0.6253069691 + l1_25*0.6119677341 + l1_26*0.5423948388 + l1_27*1.0022450377 + l1_28*-1.2392984069 + l1_29*1.5021529822);
      
      return PineActivationFunctionTanh(l2_0*0.3385061186 + l2_1*0.6218531956 + l2_2*-0.7790340983 + l2_3*0.1413078332 + l2_4*0.1857010624 + l2_5*-0.1769456351 + l2_6*-0.3242337911 + l2_7*-0.503944883 + l2_8*0.1540568869);
   }
};

class LongCondition : public ABaseCondition
{
public:
   LongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      return GetL3(period) > threshold && GetL3(period + 1) <= threshold;
   }
};

class ShortCondition : public ABaseCondition
{
public:
   ShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      return GetL3(period) < -threshold && GetL3(period + 1) >= threshold;
   }
};

class ExitLongCondition : public ABaseCondition
{
public:
   ExitLongCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }
   
   bool IsPass(const int period)
   {
      //TODO: implement
      return false;
   }
};

class ExitShortCondition : public ABaseCondition
{
public:
   ExitShortCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }
   
   bool IsPass(const int period)
   {
      //TODO: implement
      return false;
   }
};

class DisabledCondition : public ICondition
{
public:
   bool IsPass(const int period) { return false; }
};

class NoCondition : public ICondition
{
public:
   bool IsPass(const int period) { return true; }
};

class AndCondition : public ICondition
{
   ICondition *_conditions[];
public:
   ~AndCondition()
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

class OrCondition : public ICondition
{
   ICondition *_conditions[];
public:
   ~OrCondition()
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
         if (_conditions[i].IsPass(period))
            return true;
      }
      return false;
   }
};

struct CandleData
{
   double Open;
   double High;
   double Low;
   double Close;
   datetime Date;
};

interface IBarStreamIterator
{
public:
   virtual bool Next() = 0;
   virtual IBarStreamIterator *CreateForwardIterator() = 0;
   virtual IBarStreamIterator *CreateReverseIterator() = 0;

   virtual datetime GetDate() = 0;

   virtual double GetOpen() = 0;
   virtual double GetHigh() = 0;
   virtual double GetLow() = 0;
   virtual double GetClose() = 0;
   virtual void GetData(CandleData &candle) = 0;
};

class BarStreamIterator : public IBarStreamIterator 
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _index;
   bool _forward;
public:
   BarStreamIterator(const string symbol, const ENUM_TIMEFRAMES timeframe, const bool forward)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _index = -1;
      _forward = forward;
   }

   virtual datetime GetDate()
   {
      return iTime(_symbol, _timeframe, _index);
   }

   virtual double GetOpen()
   {
      return iOpen(_symbol, _timeframe, _index);
   }

   virtual double GetHigh()
   {
      return iHigh(_symbol, _timeframe, _index);
   }

   virtual double GetLow()
   {
      return iLow(_symbol, _timeframe, _index);
   }

   virtual double GetClose()
   {
      return iClose(_symbol, _timeframe, _index);
   }

   virtual void GetData(CandleData &candle)
   {
      candle.Date = iTime(_symbol, _timeframe, _index);
      candle.Open = iOpen(_symbol, _timeframe, _index);
      candle.High = iHigh(_symbol, _timeframe, _index);
      candle.Low = iLow(_symbol, _timeframe, _index);
      candle.Close = iClose(_symbol, _timeframe, _index);
   }

   virtual IBarStreamIterator *CreateForwardIterator()
   {
      BarStreamIterator *copy = new BarStreamIterator(_symbol, _timeframe, true);
      copy._index = _index;
      if (!copy.MoveBackward())
         copy._index = -1;
      return copy;
   }
   virtual IBarStreamIterator *CreateReverseIterator()
   {
      BarStreamIterator *copy = new BarStreamIterator(_symbol, _timeframe, false);
      copy._index = _index;
      if (!copy.MoveForward())
         copy._index = -1;
      return copy;
   }
   
   virtual bool Next()
   {
      if (_forward)
         return MoveForward();
      return MoveBackward();
   }
private:
   bool MoveForward()
   {
      if (_index == 0)
         return false;
      if (_index == -1)
         _index = iBars(_symbol, _timeframe) - 1;
      else
         --_index;
      return true;
   }

   bool MoveBackward()
   {
      if (iBars(_symbol, _timeframe) - 1 <= _index)
         return false;
      ++_index;
      return true;
   }
};

// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

interface IBarStream : public IStream
{
public:
   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close) = 0;

   virtual double GetOpen(const int period, double &open) = 0;
   virtual double GetHigh(const int period, double &high) = 0;
   virtual double GetLow(const int period, double &low) = 0;
   virtual double GetClose(const int period, double &close) = 0;
   
   virtual bool GetHighLow(const int period, double &high, double &low) = 0;

   virtual bool GetIsAscending(const int period, bool &res) = 0;

   virtual bool GetIsDescending(const int period, bool &res) = 0;

   virtual bool GetDate(const int period, datetime &dt) = 0;

   virtual int Size() = 0;

   virtual void Refresh() = 0;
};

class CandleBodyBarStream : public IBarStream
{
   IBarStream *_source;
public:
   CandleBodyBarStream(IBarStream *source)
   {
      _source = source;
   }

   virtual bool GetValue(const int period, double &val)
   {
      return _source.GetValue(period, val);
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      if (!_source.GetValues(period, open, high, low, close))
         return false;

      high = MathMax(open, close);
      low = MathMin(open, close);
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      double open, close;
      if (!_source.GetValues(period, open, high, low, close))
         return false;
      
      high = MathMax(open, close);
      low = MathMin(open, close);
      return true;
   }

   virtual bool GetIsAscending(const int period, bool &res)
   {
      return _source.GetIsAscending(period, res);
   }

   virtual bool GetIsDescending(const int period, bool &res)
   {
      return _source.GetIsDescending(period, res);
   }
};

class CustomTimeframeBarStreamIterator : public IBarStreamIterator
{
private:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _timeframeMult;
   int _startIndex;
   int _endIndex;
   bool _forward;
public:
   CustomTimeframeBarStreamIterator(const string symbol, const ENUM_TIMEFRAMES timeframe, const int timeframeMult, const bool forward)
   {
      _forward = forward;
      _symbol = symbol;
      _timeframe = timeframe;
      _timeframeMult = timeframeMult;
      _startIndex = -1;
      _endIndex = -1;
   }

   virtual datetime GetDate()
   {
      return iTime(_symbol, _timeframe, _startIndex);
   }

   virtual double GetOpen()
   {
      return iOpen(_symbol, _timeframe, _startIndex);
   }

   virtual double GetHigh()
   {
      return iHigh(_symbol, _timeframe, iHighest(_symbol, _timeframe, MODE_HIGH, _endIndex - _startIndex, _endIndex));
   }

   virtual double GetLow()
   {
      return iLow(_symbol, _timeframe, iLowest(_symbol, _timeframe, MODE_LOW, _endIndex - _startIndex, _endIndex));
   }

   virtual double GetClose()
   {
      return iClose(_symbol, _timeframe, _endIndex);
   }

   virtual void GetData(CandleData &candle)
   {
      candle.Date = GetDate();
      candle.Open = GetOpen();
      candle.High = GetHigh();
      candle.Low = GetLow();
      candle.Close = GetClose();
   }

   virtual IBarStreamIterator *CreateForwardIterator()
   {
      CustomTimeframeBarStreamIterator *copy = new CustomTimeframeBarStreamIterator(_symbol, _timeframe, _timeframeMult, true);
      copy._startIndex = _startIndex;
      copy._endIndex = _endIndex;
      if (!copy.MoveBackward())
      {
         copy._startIndex = -1;
         copy._endIndex = -1;
      }
      return copy;
   }
   virtual IBarStreamIterator *CreateReverseIterator()
   {
      CustomTimeframeBarStreamIterator *copy = new CustomTimeframeBarStreamIterator(_symbol, _timeframe, _timeframeMult, false);
      copy._startIndex = _startIndex;
      copy._endIndex = _endIndex;
      if (!copy.MoveBackward())
      {
         copy._startIndex = -1;
         copy._endIndex = -1;
      }
      return copy;
   }

   virtual bool Next()
   {
      if (_forward)
         return MoveForward();
      return MoveBackward();
   }
private:
   bool MoveForward()
   {
      if (_endIndex == 0)
         return false;
      int periodLength = ((int)_timeframe * _timeframeMult * 60);
      if (_startIndex == -1)
      {
         datetime barStart = (Time[iBars(_symbol, _timeframe)] / periodLength) * periodLength;
         _startIndex = iBarShift(_symbol, _timeframe, barStart);
         if (_startIndex == -1)
         {
            barStart += periodLength;
            _startIndex = iBarShift(_symbol, _timeframe, barStart);
            if (_startIndex == -1)
               return false;
         }
         _endIndex = iBarShift(_symbol, _timeframe, barStart + periodLength) + 1;
         return true;
      }
      --_endIndex;
      
      datetime barStart = (Time[_endIndex] / periodLength) * periodLength;
      _startIndex = iBarShift(_symbol, _timeframe, barStart);
      _endIndex = iBarShift(_symbol, _timeframe, barStart + periodLength) + 1;
      return true;
   }

   bool MoveBackward()
   {
      int maxIndex = iBars(_symbol, _timeframe) - 1;
      if (maxIndex <= _startIndex)
         return false;
      ++_startIndex;

      int periodLength = ((int)_timeframe * _timeframeMult * 60);
      datetime barStart = (Time[_startIndex] / periodLength) * periodLength;
      _startIndex = iBarShift(_symbol, _timeframe, barStart);
      if (_startIndex == -1)
      {
         _startIndex = maxIndex;
         return false;
      }
      _endIndex = iBarShift(_symbol, _timeframe, barStart + periodLength) + 1;
      return true;
   }
};

interface IStreamFactory
{
public:
   virtual IStream *Create(const int order) = 0;
};

class StreamFactory : public IStreamFactory
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
public:
   StreamFactory(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   virtual IStream *Create(const int order)
   {
      return NULL;
   }
};

enum OrderSide
{
   BuySide,
   SellSide
};

// Orders iterator v 1.9
// More templates and snippets on https://github.com/sibvic/mq4-templates
enum CompareType
{
   CompareLessThan
};

class OrdersIterator
{
   bool _useMagicNumber;
   int _magicNumber;
   bool _useOrderType;
   int _orderType;
   bool _trades;
   bool _useSide;
   bool _isBuySide;
   int _lastIndex;
   bool _useSymbol;
   string _symbol;
   bool _useProfit;
   double _profit;
   bool _useComment;
   string _comment;
   CompareType _profitCompare;
   bool _orders;
public:
   OrdersIterator()
   {
      _useOrderType = false;
      _useMagicNumber = false;
      _useSide = false;
      _lastIndex = INT_MIN;
      _trades = false;
      _useSymbol = false;
      _useProfit = false;
      _orders = false;
      _useComment = false;
   }

   OrdersIterator *WhenSymbol(const string symbol)
   {
      _useSymbol = true;
      _symbol = symbol;
      return &this;
   }

   OrdersIterator *WhenProfit(const double profit, const CompareType compare)
   {
      _useProfit = true;
      _profit = profit;
      _profitCompare = compare;
      return &this;
   }

   OrdersIterator *WhenTrade()
   {
      _trades = true;
      return &this;
   }

   OrdersIterator *WhenOrder()
   {
      _orders = true;
      return &this;
   }

   OrdersIterator *WhenSide(const OrderSide side)
   {
      _useSide = true;
      _isBuySide = side == BuySide;
      return &this;
   }

   OrdersIterator *WhenOrderType(const int orderType)
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

   int GetOrderType() { return OrderType(); }
   double GetProfit() { return OrderProfit(); }
   double IsBuy() { return OrderType() == OP_BUY; }
   double IsSell() { return OrderType() == OP_SELL; }
   int GetTicket() { return OrderTicket(); }

   int Count()
   {
      int count = 0;
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && PassFilter())
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
         if (OrderSelect(_lastIndex, SELECT_BY_POS, MODE_TRADES) && PassFilter())
            return true;
         _lastIndex = _lastIndex - 1;
      }
      return false;
   }

   bool Any()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && PassFilter())
            return true;
      }
      return false;
   }

   int First()
   {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && PassFilter())
            return OrderTicket();
      }
      return -1;
   }

   void Reset()
   {
      _lastIndex = INT_MIN;
   }

private:
   bool PassFilter()
   {
      if (_useMagicNumber && OrderMagicNumber() != _magicNumber)
         return false;
      if (_useOrderType && OrderType() != _orderType)
         return false;
      if (_trades && !IsTrade())
         return false;
      if (_orders && IsTrade())
         return false;
      if (_useSymbol && OrderSymbol() != _symbol)
         return false;
      if (_useProfit)
      {
         switch (_profitCompare)
         {
            case CompareLessThan:
               if (OrderProfit() >= _profit)
                  return false;
               break;
         }
      }
      if (_useSide)
      {
         if (_trades)
         {
            if (_isBuySide && !IsBuy())
               return false;
            if (!_isBuySide && !IsSell())
               return false;
         }
         else
         {
            //TODO: IMPLEMENT!!!!
         }
      }
      if (_useComment && OrderComment() != _comment)
         return false;
      return true;
   }

   bool IsTrade()
   {
      return (OrderType() == OP_BUY || OrderType() == OP_SELL) && OrderCloseTime() == 0.0;
   }
};

// Trade calculator v.1.16
// More templates and snippets on https://github.com/sibvic/mq4-templates

class TradeCalculator
{
   InstrumentInfo *_symbol;

   TradeCalculator(const string symbol)
   {
      _symbol = new InstrumentInfo(symbol);
   }
public:
   static TradeCalculator *Create(const string symbol)
   {
      ResetLastError();
      double temp = MarketInfo(symbol, MODE_POINT); 
      if (GetLastError() != 0)
         return NULL;

      return new TradeCalculator(symbol);
   }

   ~TradeCalculator()
   {
      delete _symbol;
   }

   double GetPipSize() { return _symbol.GetPipSize(); }
   string GetSymbol() { return _symbol.GetSymbol(); }
   double GetBid() { return _symbol.GetBid(); }
   double GetAsk() { return _symbol.GetAsk(); }
   int GetDigits() { return _symbol.GetDigits(); }
   double GetSpread() { return _symbol.GetSpread(); }

   static bool IsBuyOrder()
   {
      switch (OrderType())
      {
         case OP_BUY:
         case OP_BUYLIMIT:
         case OP_BUYSTOP:
            return true;
      }
      return false;
   }

   double GetBreakevenPrice(OrdersIterator &it1, const OrderSide side, double &totalAmount)
   {
      totalAmount = 0.0;
      double lotStep = SymbolInfoDouble(_symbol.GetSymbol(), SYMBOL_VOLUME_STEP);
      double price = side == BuySide ? _symbol.GetBid() : _symbol.GetAsk();
      double totalPL = 0;
      while (it1.Next())
      {
         double orderLots = OrderLots();
         totalAmount += orderLots / lotStep;
         if (side == BuySide)
            totalPL += (price - OrderOpenPrice()) * (OrderLots() / lotStep);
         else
            totalPL += (OrderOpenPrice() - price) * (OrderLots() / lotStep);
      }
      if (totalAmount == 0.0)
         return 0.0;
      double shift = -(totalPL / totalAmount);
      return side == BuySide ? price + shift : price - shift;
   }

   double GetBreakevenPrice(const int side, const int magicNumber, double &totalAmount)
   {
      totalAmount = 0.0;
      OrdersIterator it1();
      it1.WhenMagicNumber(magicNumber);
      it1.WhenSymbol(_symbol.GetSymbol());
      it1.WhenOrderType(side);
      return GetBreakevenPrice(it1, side == OP_BUY ? BuySide : SellSide, totalAmount);
   }
   
   double CalculateTakeProfit(const bool isBuy, const double takeProfit, const StopLimitType takeProfitType, const double amount, double basePrice)
   {
      int direction = isBuy ? 1 : -1;
      switch (takeProfitType)
      {
         case StopLimitPercent:
            return RoundRate(basePrice + basePrice * takeProfit / 100.0 * direction);
         case StopLimitPips:
            return RoundRate(basePrice + takeProfit * _symbol.GetPipSize() * direction);
         case StopLimitDollar:
            return RoundRate(basePrice + CalculateSLShift(amount, takeProfit) * direction);
         case StopLimitAbsolute:
            return takeProfit;
      }
      return 0.0;
   }
   
   double CalculateStopLoss(const bool isBuy, const double stopLoss, const StopLimitType stopLossType, const double amount, double basePrice)
   {
      int direction = isBuy ? 1 : -1;
      switch (stopLossType)
      {
         case StopLimitPercent:
            return RoundRate(basePrice - basePrice * stopLoss / 100.0 * direction);
         case StopLimitPips:
            return RoundRate(basePrice - stopLoss * _symbol.GetPipSize() * direction);
         case StopLimitDollar:
            return RoundRate(basePrice - CalculateSLShift(amount, stopLoss) * direction);
         case StopLimitAbsolute:
            return stopLoss;
      }
      return 0.0;
   }

   double GetLots(const PositionSizeType lotsType, const double lotsValue, const double stopDistance, const double leverageOverride = 0)
   {
      switch (lotsType)
      {
         case PositionSizeAmount:
            return GetLotsForMoney(lotsValue, leverageOverride);
         case PositionSizeContract:
            return LimitLots(RoundLots(lotsValue));
         case PositionSizeEquity:
            return GetLotsForMoney(AccountEquity() * lotsValue / 100.0, leverageOverride);
         case PositionSizeRisk:
         {
            double affordableLoss = AccountEquity() * lotsValue / 100.0;
            double unitCost = MarketInfo(_symbol.GetSymbol(), MODE_TICKVALUE);
            double tickSize = _symbol.GetTickSize();
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

   double NormalizeLots(const double lots)
   {
      return LimitLots(RoundLots(lots));
   }

   double RoundRate(const double rate)
   {
      return _symbol.RoundRate(rate);
   }

private:
   bool IsContractLotsValid(const double lots, string &error)
   {
      double minVolume = _symbol.GetMinLots();
      if (minVolume > lots)
      {
         error = "Min. allowed lot size is " + DoubleToString(minVolume);
         return false;
      }
      double maxVolume = SymbolInfoDouble(_symbol.GetSymbol(), SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
      {
         error = "Max. allowed lot size is " + DoubleToString(maxVolume);
         return false;
      }
      return true;
   }

   double GetLotsForMoney(const double money, const double leverageOverride = 0)
   {
      if (leverageOverride != 0)
      {
         double lotSize = MarketInfo(_symbol.GetSymbol(), MODE_LOTSIZE);
         double lots = RoundLots(money * leverageOverride / lotSize);
         return LimitLots(lots);
      }
      double marginRequired = MarketInfo(_symbol.GetSymbol(), MODE_MARGINREQUIRED);
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
      double lotStep = SymbolInfoDouble(_symbol.GetSymbol(), SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
         return 0.0;
      return floor(lots / lotStep) * lotStep;
   }

   double LimitLots(const double lots)
   {
      double minVolume = _symbol.GetMinLots();
      if (minVolume > lots)
         return 0.0;
      double maxVolume = SymbolInfoDouble(_symbol.GetSymbol(), SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
         return maxVolume;
      return lots;
   }

   double CalculateSLShift(const double amount, const double money)
   {
      double unitCost = MarketInfo(_symbol.GetSymbol(), MODE_TICKVALUE);
      double tickSize = _symbol.GetTickSize();
      return (money / (unitCost / tickSize)) / amount;
   }
};

// Order v1.0

interface IOrder
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool Select() = 0;
};

class OrderByMagicNumber : public IOrder
{
   int _magicMumber;
   int _references;
public:
   OrderByMagicNumber(int magicNumber)
   {
      _magicMumber = magicNumber;
      _references = 1;
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

   virtual bool Select()
   {
      OrdersIterator it();
      it.WhenMagicNumber(_magicMumber);
      int ticketId = it.First();
      return OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES);
   }
};

class OrderByTicketId : public IOrder
{
   int _ticket;
   int _references;
public:
   OrderByTicketId(int ticket)
   {
      _ticket = ticket;
      _references = 1;
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

   virtual bool Select()
   {
      return OrderSelect(_ticket, SELECT_BY_TICKET, MODE_TRADES);
   }
};

// Breakeven logic v. 2.0
interface IBreakevenLogic
{
public:
   virtual void CreateBreakeven(const int order, const int period) = 0;
};

class DisabledBreakevenLogic : public IBreakevenLogic
{
public:
   void DoLogic(const int period) {}
   void CreateBreakeven(const int order, const int period) {}
};

class BreakevenController
{
   IOrder *_order;
   bool _finished;
   double _trigger;
   double _target;
   Signaler *_signaler;
   InstrumentInfo *_instrument;
   ICondition *_condition;
   string _name;
public:
   BreakevenController(Signaler *signaler)
   {
      _order = NULL;
      _condition = NULL;
      _instrument = NULL;
      _signaler = signaler;
      _finished = true;
   }

   ~BreakevenController()
   {
      delete _order;
      delete _condition;
      delete _instrument;
   }
   
   bool SetOrder(IOrder *order, const double trigger, const double target, ICondition *condition)
   {
      return SetOrder(order, trigger, target, condition, "");
   }

   bool SetOrder(IOrder *order, const double trigger, const double target, ICondition *condition, const string name)
   {
      if (!_finished)
         return false;
      if (!order.Select())
         return false;

      string symbol = OrderSymbol();
      if (_instrument == NULL || symbol != _instrument.GetSymbol())
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
      _finished = false;
      _trigger = trigger;
      _target = target;
      delete _order;
      _order = order;
      delete _condition;
      _name = name;
      _condition = condition;
      return true;
   }

   void DoLogic(const int period)
   {
      if (_finished || !_order.Select())
      {
         _finished = true;
         return;
      }

      int type = OrderType();
      if (type == OP_BUY)
      {
         if (_instrument.GetAsk() >= _trigger || (_condition != NULL && _condition.IsPass(period)))
         {
            int ticket = OrderTicket();
            if (_signaler != NULL)
               _signaler.SendNotifications(GetNamePrefix() + "Trade " + IntegerToString(ticket) + " has reached " 
                  + DoubleToString(_trigger, _instrument.GetDigits()) + ". Stop loss moved to " 
                  + DoubleToString(_target, _instrument.GetDigits()));
            int res = OrderModify(ticket, OrderOpenPrice(), _target, OrderTakeProfit(), 0, CLR_NONE);
            _finished = true;
         }
      }
      else if (type == OP_SELL)
      {
         if (_instrument.GetBid() < _trigger || (_condition != NULL && _condition.IsPass(period)))
         {
            int ticket = OrderTicket();
            if (_signaler != NULL)
               _signaler.SendNotifications(GetNamePrefix() + "Trade " + IntegerToString(ticket) + " has reached " 
                  + DoubleToString(_trigger, _instrument.GetDigits()) + ". Stop loss moved to " 
                  + DoubleToString(_target, _instrument.GetDigits()));
            int res = OrderModify(ticket, OrderOpenPrice(), _target, OrderTakeProfit(), 0, CLR_NONE);
            _finished = true;
         }
      }
   }
private:
   string GetNamePrefix()
   {
      if (_name == "")
         return "";
      return _name + ". ";
   }
};

// Action v1.0
interface IAction
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool DoAction() = 0;
};

class ActionOnConditionController
{
   bool _finished;
   ICondition *_condition;
   IAction* _action;
public:
   ActionOnConditionController()
   {
      _action = NULL;
      _condition = NULL;
      _finished = true;
   }

   ~ActionOnConditionController()
   {
      delete _action;
      delete _condition;
   }
   
   bool SetOrder(IAction* action, ICondition *condition)
   {
      if (!_finished || action == NULL)
         return false;

      if (_action != NULL)
         _action.Release();
      _action = action;
      _action.AddRef();
      _finished = false;
      delete _condition;
      _condition = condition;
      return true;
   }

   void DoLogic(const int period)
   {
      if (_finished)
         return;

      if ( _condition.IsPass(period))
      {
         if (_action.DoAction())
            _finished = true;
      }
   }
};

class ActionOnConditionLogic
{
   ActionOnConditionController* _controllers[];
public:
   ~ActionOnConditionLogic()
   {
      int count = ArraySize(_controllers);
      for (int i = 0; i < count; ++i)
      {
         delete _controllers[i];
      }
   }

   void DoLogic(const int period)
   {
      int count = ArraySize(_controllers);
      for (int i = 0; i < count; ++i)
      {
         _controllers[i].DoLogic(period);
      }
   }

   bool AddActionOnCondition(IAction* action, ICondition* condition)
   {
      int count = ArraySize(_controllers);
      for (int i = 0; i < count; ++i)
      {
         if (_controllers[i].SetOrder(action, condition))
            return true;
      }

      ArrayResize(_controllers, count + 1);
      _controllers[count] = new ActionOnConditionController();
      return _controllers[count].SetOrder(action, condition);
   }
};

class HitProfitCondition : public ICondition
{
   IOrder* _order;
   double _trigger;
   InstrumentInfo *_instrument;
public:
   HitProfitCondition()
   {
      _order = NULL;
      _instrument = NULL;
   }

   ~HitProfitCondition()
   {
      delete _instrument;
      if (_order != NULL)
         _order.Release();
   }

   void Set(IOrder* order, double trigger)
   {
      if (!order.Select())
         return;

      _order = order;
      _order.AddRef();
      _trigger = trigger;
      string symbol = OrderSymbol();
      if (_instrument == NULL || symbol != _instrument.GetSymbol())
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
   }

   virtual bool IsPass(const int period)
   {
      if (_order == NULL || !_order.Select())
         return false;

      int type = OrderType();
      if (type == OP_BUY)
         return _instrument.GetAsk() >= _trigger;
      else if (type == OP_SELL)
         return _instrument.GetBid() <= _trigger;
      return false;
   }
};

class AAction : public IAction
{
protected:
   int _references;
   AAction()
   {
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
};

class MoveToBreakevenAction : public AAction
{
   Signaler* _signaler;
   double _trigger;
   double _target;
   InstrumentInfo *_instrument;
   IOrder* _order;
   string _name;
public:
   MoveToBreakevenAction(double trigger, double target, string name, IOrder* order, Signaler *signaler)
   {
      _signaler = signaler;
      _trigger = trigger;
      _target = target;
      _name = name;

      _order = order;
      _order.AddRef();
      _order.Select();
      string symbol = OrderSymbol();
      if (_instrument == NULL || symbol != _instrument.GetSymbol())
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
   }

   ~MoveToBreakevenAction()
   {
      delete _instrument;
      _order.Release();
   }

   virtual bool DoAction()
   {
      if (!_order.Select())
         return false;
      int ticket = OrderTicket();
      string error;
      if (!TradingCommands::MoveSL(ticket, _target, error))
      {
         Print(error);
         return false;
      }
      if (_signaler != NULL)
      {
         _signaler.SendNotifications(GetNamePrefix() + "Trade " + IntegerToString(ticket) + " has reached " 
            + DoubleToString(_trigger, _instrument.GetDigits()) + ". Stop loss moved to " 
            + DoubleToString(_target, _instrument.GetDigits()));
      }
      return true;
   }
private:
   string GetNamePrefix()
   {
      if (_name == "")
         return "";
      return _name + ". ";
   }
};

class BreakevenLogic : public IBreakevenLogic
{
   StopLimitType _triggerType;
   double _trigger;
   double _target;
   TradeCalculator *_calculator;
   Signaler *_signaler;
   ActionOnConditionLogic* _actions;
public:
   BreakevenLogic(const StopLimitType triggerType, const double trigger,
      const double target, Signaler *signaler, ActionOnConditionLogic* actions)
   {
      Init();
      _signaler = signaler;
      _triggerType = triggerType;
      _trigger = trigger;
      _target = target;
      _actions = actions;
   }

   BreakevenLogic()
   {
      Init();
   }

   ~BreakevenLogic()
   {
      delete _calculator;
   }

   void CreateBreakeven(const int order, const int period, const StopLimitType triggerType, 
      const double trigger, const double target)
   {
      if (triggerType == StopLimitDoNotUse)
         return;
      
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
         return;

      string symbol = OrderSymbol();
      if (_calculator == NULL || symbol != _calculator.GetSymbol())
      {
         delete _calculator;
         _calculator = TradeCalculator::Create(symbol);
         if (_calculator == NULL)
            return;
      }
      int isBuy = TradeCalculator::IsBuyOrder();
      double basePrice = OrderOpenPrice();
      double targetValue = _calculator.CalculateTakeProfit(isBuy, target, StopLimitPips, OrderLots(), basePrice);
      double triggerValue = _calculator.CalculateTakeProfit(isBuy, trigger, triggerType, OrderLots(), basePrice);
      CreateBreakeven(order, triggerValue, targetValue, "");
   }

   void CreateBreakeven(const int orderId, const int period)
   {
      CreateBreakeven(orderId, period, _triggerType, _trigger, _target);
   }
private:
   void Init()
   {
      _calculator = NULL;
      _signaler = NULL;
      _triggerType = StopLimitDoNotUse;
      _trigger = 0;
      _target = 0;
   }

   void CreateBreakeven(const int ticketId, const double trigger, const double target, const string name)
   {
      if (!OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES))
         return;
      IOrder *order = new OrderByMagicNumber(OrderMagicNumber());
      HitProfitCondition* condition = new HitProfitCondition();
      condition.Set(order, trigger);
      IAction* action = new MoveToBreakevenAction(trigger, target, name, order, _signaler);
      if (!_actions.AddActionOnCondition(action, condition))
      {
         delete action;
         delete condition;
      }
   }
};

// Trailing controller v.2.6
interface ITrailingLogic
{
public:
   virtual void DoLogic() = 0;
   virtual void Create(const int order, const double stop) = 0;
};

class DisabledTrailingLogic : public ITrailingLogic
{
public:
   void DoLogic() {};
   void Create(const int order, const double stop) {};
};

enum TrailingControllerType
{
   TrailingControllerTypeStandard
   ,TrailingControllerTypeStream
};

interface ITrailingController
{
public:
   virtual bool IsFinished() = 0;
   virtual void UpdateStop() = 0;
   virtual TrailingControllerType GetType() = 0;
};

class StreamTrailingController : public ITrailingController
{
   Signaler *_signaler;
   int _order;
   bool _finished;
   double _distance;
   IStream *_stream;
   InstrumentInfo *_instrument;
public:
   StreamTrailingController(Signaler *signaler = NULL)
   {
      _instrument = NULL;
      _stream = NULL;
      _finished = true;
      _order = -1;
      _signaler = signaler;
   }

   ~StreamTrailingController()
   {
      delete _stream;
      delete _instrument;
   }
   
   bool IsFinished()
   {
      return _finished;
   }

   bool SetOrder(const int order, IStream *stream)
   {
      if (!_finished)
      {
         return false;
      }
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         return false;
      }
      string symbol = OrderSymbol();
      if (_instrument == NULL || _instrument.GetSymbol() != symbol)
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
      delete _stream;
      _stream = stream;

      _finished = false;
      _order = order;
      
      return true;
   }

   void UpdateStop()
   {
      if (_finished || !OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         _finished = true;
         return;
      }

      double newStop;
      if (!_stream.GetValue(0, newStop))
         return;
      newStop = _instrument.RoundRate(newStop);

      if (newStop == OrderStopLoss()) 
         return;

      if (_signaler != NULL)
      {
         string message = "Trailing stop loss for " + IntegerToString(_order) + " to " + DoubleToString(newStop, _instrument.GetDigits());
         _signaler.SendNotifications(message);
      }
      int res = OrderModify(_order, OrderOpenPrice(), newStop, OrderTakeProfit(), 0, CLR_NONE);
      if (res == 0)
      {
         int error = GetLastError();
         switch (error)
         {
            case ERR_INVALID_TICKET:
               _finished = true;
               break;
         }
      }
   }

   TrailingControllerType GetType()
   {
      return TrailingControllerTypeStream;
   }
};

class IndicatorTrailingLogic : public ITrailingLogic
{
   ITrailingController *_trailing[];
   InstrumentInfo *_instrument;
   IStreamFactory *_streamFactory;
   Signaler *_signaler;
public:
   IndicatorTrailingLogic(IStreamFactory *streamFactory, Signaler *signaler)
   {
      _streamFactory = streamFactory;
      _signaler = signaler;
      _instrument = NULL;
   }

   ~IndicatorTrailingLogic()
   {
      delete _streamFactory;
      delete _instrument;
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

   void Create(const int order, const double stop)
   {
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
         return;

      string symbol = OrderSymbol();
      if (_instrument == NULL)
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
      if (symbol != _instrument.GetSymbol())
      {
         return;
      }
      IStream *stream = _streamFactory.Create(order);
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         if (_trailing[i].GetType() != TrailingControllerTypeStream)
            continue;
         StreamTrailingController *trailingController = (StreamTrailingController *)_trailing[i];
         if (trailingController.SetOrder(order, stream))
         {
            return;
         }
      }

      StreamTrailingController *trailingController = new StreamTrailingController(_signaler);
      trailingController.SetOrder(order, stream);
      
      ArrayResize(_trailing, i_count + 1);
      _trailing[i_count] = trailingController;
   }
};

class TrailingController : public ITrailingController
{
   Signaler *_signaler;
   int _order;
   bool _finished;
   double _distance;
   double _trailingStep;
   double _trailingStart;
   InstrumentInfo *_instrument;
public:
   TrailingController(Signaler *signaler = NULL)
   {
      _finished = true;
      _order = -1;
      _signaler = signaler;
      _instrument = NULL;
   }

   ~TrailingController()
   {
      delete _instrument;
   }
   
   bool IsFinished()
   {
      return _finished;
   }

   bool SetOrder(const int order, const double distance, const double trailingStep, const double trailingStart = 0)
   {
      if (!_finished)
      {
         return false;
      }
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         return false;
      }
      string symbol = OrderSymbol();
      if (_instrument == NULL || _instrument.GetSymbol() != symbol)
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
      _trailingStep = _instrument.RoundRate(trailingStep);
      if (_trailingStep == 0)
         return false;

      _trailingStart = trailingStart;

      _finished = false;
      _order = order;
      _distance = distance;
      
      return true;
   }

   void UpdateStop()
   {
      if (_finished || !OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
      {
         _finished = true;
         return;
      }
      int type = OrderType();
      if (type == OP_BUY)
      {
         UpdateStopForLong();
      } 
      else if (type == OP_SELL) 
      {
         UpdateStopForShort();
      } 
   }

   TrailingControllerType GetType()
   {
      return TrailingControllerTypeStandard;
   }
private:
   void UpdateStopForLong()
   {
      double initialStop = OrderStopLoss();
      if (initialStop == 0.0)
         return;
      double ask = _instrument.GetAsk();
      double openPrice = OrderOpenPrice();
      if (openPrice > ask + _trailingStart * _instrument.GetPipSize())
         return;
      double newStop = initialStop;
      int digits = _instrument.GetDigits();
      while (NormalizeDouble(newStop + _trailingStep, digits) < NormalizeDouble(ask - _distance, digits))
      {
         newStop = NormalizeDouble(newStop + _trailingStep, digits);
      }
      if (newStop == initialStop) 
         return;
      if (_signaler != NULL)
      {
         string message = "Trailing stop for " + IntegerToString(_order) + " to " + DoubleToString(newStop, digits);
         _signaler.SendNotifications(message);
      }
      int res = OrderModify(OrderTicket(), openPrice, newStop, OrderTakeProfit(), 0, CLR_NONE);
      if (res == 0)
      {
         int error = GetLastError();
         switch (error)
         {
            case ERR_INVALID_TICKET:
               _finished = true;
               break;
         }
      }
   }

   void UpdateStopForShort()
   {
      double initialStop = OrderStopLoss();
      if (initialStop == 0.0)
         return;
      double bid = _instrument.GetBid();
      double openPrice = OrderOpenPrice();
      if (openPrice < bid - _trailingStart * _instrument.GetPipSize())
         return;
      double newStop = initialStop;
      int digits = _instrument.GetDigits();
      while (NormalizeDouble(newStop - _trailingStep, digits) > NormalizeDouble(bid + _distance, digits))
      {
         newStop = NormalizeDouble(newStop - _trailingStep, digits);
      }
      if (newStop == initialStop) 
         return;
         
      if (_signaler != NULL)
      {
         string message = "Trailing stop for " + IntegerToString(_order) + " to " + DoubleToString(newStop, digits);
         _signaler.SendNotifications(message);
      }
      int res = OrderModify(OrderTicket(), openPrice, newStop, OrderTakeProfit(), 0, CLR_NONE);
      if (res == 0)
      {
         int error = GetLastError();
         switch (error)
         {
            case ERR_INVALID_TICKET:
               _finished = true;
               break;
         }
      }
   }
};

class TrailingLogic : public ITrailingLogic
{
   ITrailingController *_trailing[];
   TrailingType _trailingType;
   double _trailingStep;
   double _atrTrailingMultiplier;
   double _trailingStart;
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo *_instrument;
   Signaler *_signaler;
public:
   TrailingLogic(TrailingType trailing, double trailingStep, double atrTrailingMultiplier
      , double trailingStart, ENUM_TIMEFRAMES timeframe, Signaler *signaler)
   {
      _signaler = signaler;
      _instrument = NULL;
      _trailingStart = trailingStart;
      _trailingType = trailing;
      _trailingStep = trailingStep;
      _atrTrailingMultiplier = atrTrailingMultiplier;
      _timeframe = timeframe;
   }

   ~TrailingLogic()
   {
      delete _instrument;
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

   void Create(const int order, const double distancePips, const TrailingType trailingType, const double trailingStep
      , const double trailingStart)
   {
      if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES) || OrderCloseTime() != 0.0)
         return;

      string symbol = OrderSymbol();
      if (_instrument == NULL || symbol != _instrument.GetSymbol())
      {
         delete _instrument;
         _instrument = new InstrumentInfo(symbol);
      }
      double distance = distancePips * _instrument.GetPipSize();
      switch (trailingType)
      {
         case TrailingPips:
            CreateTrailing(order, distance, trailingStep * _instrument.GetPipSize(), trailingStart);
            break;
         case TrailingPercent:
            CreateTrailing(order, distance, distance * trailingStep / 100.0, trailingStart);
            break;
      }
   }

   void Create(const int order, const double distancePips)
   {
      Create(order, distancePips, _trailingType, _trailingStep, _trailingStart);
   }
private:

   void CreateTrailing(const int order, const double distance, const double trailingStep, const double trailingStart)
   {
      int i_count = ArraySize(_trailing);
      for (int i = 0; i < i_count; ++i)
      {
         if (_trailing[i].GetType() != TrailingControllerTypeStandard)
            continue;
         TrailingController *trailingController = (TrailingController *)_trailing[i];
         if (trailingController.SetOrder(order, distance, trailingStep, trailingStart))
         {
            return;
         }
      }

      TrailingController *trailingController = new TrailingController(_signaler);
      trailingController.SetOrder(order, distance, trailingStep, trailingStart);
      
      ArrayResize(_trailing, i_count + 1);
      _trailing[i_count] = trailingController;
   }
};

// Trading time v.1.5

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

   void GetStartEndTime(const datetime date, datetime &start, datetime &end)
   {
      MqlDateTime current_time;
      if (!TimeToStruct(date, current_time))
         return;

      current_time.hour = 0;
      current_time.min = 0;
      current_time.sec = 0;
      datetime referece = StructToTime(current_time);

      start = referece + _startTime;
      end = referece + _endTime;
      if (_startTime > _endTime)
      {
         start -= 86400;
      }
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
      int hours;
      int minutes;
      int seconds;
      if (StringFind(time, ":") == -1)
      {
         //hh:mm:ss
         int time_parsed = (int)StringToInteger(time);
         seconds = time_parsed % 100;
         time_parsed /= 100;
         minutes = time_parsed % 100;
         time_parsed /= 100;
         hours = time_parsed % 100;
      }
      else
      {
         //hhmmss
         int time_parsed = (int)StringToInteger(time);
         hours = time_parsed % 100;
         
         time_parsed /= 100;
         minutes = time_parsed % 100;
         time_parsed /= 100;
         seconds = time_parsed % 100;
      }
      if (hours > 24)
      {
         error = "Incorrect number of hours in " + time;
         return -1;
      }
      if (minutes > 59)
      {
         error = "Incorrect number of minutes in " + time;
         return -1;
      }
      if (seconds > 59)
      {
         error = "Incorrect number of seconds in " + time;
         return -1;
      }
      if (hours == 24 && (minutes != 0 || seconds != 0))
      {
         error = "Incorrect date";
         return -1;
      }
      return (hours * 60 + minutes) * 60 + seconds;
   }
};

// Money management strategy v.1.4
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
   double _leverageOverride;

   AMoneyManagementStrategy(TradeCalculator *calculator, PositionSizeType lotsType, double lots
      , StopLimitType stopLossType, double stopLoss, StopLimitType takeProfitType, double takeProfit
      , const double leverageOverride)
   {
      _calculator = calculator;
      _lotsType = lotsType;
      _lots = lots;
      _stopLossType = stopLossType;
      _stopLoss = stopLoss;
      _takeProfitType = takeProfitType;
      _takeProfit = takeProfit;
      _leverageOverride = leverageOverride;
   }
};

class LongMoneyManagementStrategy : public AMoneyManagementStrategy
{
public:
   LongMoneyManagementStrategy(TradeCalculator *calculator, PositionSizeType lotsType, double lots
      , StopLimitType stopLossType, double stopLoss, StopLimitType takeProfitType, double takeProfit
      , const double leverageOverride = 0)
      : AMoneyManagementStrategy(calculator, lotsType, lots, stopLossType, stopLoss, takeProfitType, takeProfit, leverageOverride)
   {
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      if (_lotsType == PositionSizeRisk)
      {
         stopLoss = _calculator.CalculateStopLoss(true, _stopLoss, _stopLossType, 0.0, entryPrice);
         amount = _calculator.GetLots(_lotsType, _lots, entryPrice - stopLoss, _leverageOverride);
      }
      else
      {
         amount = _calculator.GetLots(_lotsType, _lots, 0.0, _leverageOverride);
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
      , StopLimitType stopLossType, double stopLoss, StopLimitType takeProfitType, double takeProfit
      , const double leverageOverride = 0)
      : AMoneyManagementStrategy(calculator, lotsType, lots, stopLossType, stopLoss, takeProfitType, takeProfit, leverageOverride)
   {
   }

   void Get(const int period, const double entryPrice, double &amount, double &stopLoss, double &takeProfit)
   {
      if (_lotsType == PositionSizeRisk)
      {
         stopLoss = _calculator.CalculateStopLoss(false, _stopLoss, _stopLossType, 0.0, entryPrice);
         amount = _calculator.GetLots(_lotsType, _lots, stopLoss - entryPrice, _leverageOverride);
      }
      else
      {
         amount = _calculator.GetLots(_lotsType, _lots, 0.0, _leverageOverride);
         stopLoss = _calculator.CalculateStopLoss(false, _stopLoss, _stopLossType, amount, entryPrice);
      }
      if (_takeProfitType == StopLimitRiskReward)
         takeProfit = entryPrice - (entryPrice - stopLoss) * _takeProfit / 100;
      else
         takeProfit = _calculator.CalculateTakeProfit(false, _takeProfit, _takeProfitType, amount, entryPrice);
   }
};

// Trading commands v.2.8
// More templates and snippets on https://github.com/sibvic/mq4-templates

class TradingCommands
{
public:
   static bool MoveSLTP(const int ticketId, const double newStopLoss, const double newTakeProfit, string &error)
   {
      if (!OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES))
      {
         error = "Trade not found";
         return false;
      }

      int res = OrderModify(ticketId, OrderOpenPrice(), newStopLoss, newTakeProfit, 0, CLR_NONE);
      if (res == 0)
      {
         int errorCode = GetLastError();
         switch (errorCode)
         {
            case ERR_INVALID_TICKET:
               error = "Trade not found";
               return false;
            default:
               error = "Last error: " + IntegerToString(errorCode);
               break;
         }
      }
      return true;
   }

   static bool MoveSL(const int ticketId, const double newStopLoss, string &error)
   {
      if (!OrderSelect(ticketId, SELECT_BY_TICKET, MODE_TRADES))
      {
         error = "Trade not found";
         return false;
      }

      int res = OrderModify(ticketId, OrderOpenPrice(), newStopLoss, OrderTakeProfit(), 0, CLR_NONE);
      if (res == 0)
      {
         int errorCode = GetLastError();
         switch (errorCode)
         {
            case ERR_INVALID_TICKET:
               error = "Trade not found";
               return false;
            default:
               error = "Last error: " + IntegerToString(errorCode);
               break;
         }
      }
      return true;
   }

   static void DeleteOrders(const int magicNumber)
   {
      OrdersIterator it1();
      it1.WhenMagicNumber(magicNumber);
      it1.WhenOrder();
      while (it1.Next())
      {
         int ticket = OrderTicket();
         if (!OrderDelete(ticket))
            Print("Failed to delete the order " + IntegerToString(ticket));
      }
   }

   static bool DeleteCurrentOrder(string &error)
   {
      int ticket = OrderTicket();
      if (!OrderDelete(ticket))
      {
         error = "Failed to delete the order " + IntegerToString(ticket);
         return false;
      }
      return true;
   }

   static bool CloseCurrentOrder(const int slippage, const double amount, string &error)
   {
      int orderType = OrderType();
      if (orderType == OP_BUY)
         return CloseCurrentOrder(InstrumentInfo::GetBid(OrderSymbol()), slippage, amount, error);
      if (orderType == OP_SELL)
         return CloseCurrentOrder(InstrumentInfo::GetAsk(OrderSymbol()), slippage, amount, error);
      return false;
   }
   
   static bool CloseCurrentOrder(const int slippage, string &error)
   {
      return CloseCurrentOrder(slippage, OrderLots(), error);
   }

   static bool CloseCurrentOrder(const double price, const int slippage, string &error)
   {
      return CloseCurrentOrder(price, slippage, OrderLots(), error);
   }
   
   static bool CloseCurrentOrder(const double price, const int slippage, const double amount, string &error)
   {
      bool closed = OrderClose(OrderTicket(), amount, price, slippage);
      if (closed)
         return true;
      int lastError = GetLastError();
      switch (lastError)
      {
         case ERR_TRADE_NOT_ALLOWED:
            error = "Trading is not allowed";
            break;
         case ERR_INVALID_PRICE:
            error = "Invalid closing price: " + DoubleToStr(price);
            break;
         case ERR_INVALID_TRADE_VOLUME:
            error = "Invalid trade volume: " + DoubleToStr(amount);
            break;
         case ERR_TRADE_PROHIBITED_BY_FIFO:
            error = "Prohibited by FIFO";
            break;
         default:
            error = "Last error: " + IntegerToString(lastError);
            break;
      }
      return false;
   }

   static int CloseTrades(OrdersIterator &it, const int slippage)
   {
      int failed = 0;
      return CloseTrades(it, slippage, failed);
   }

   static int CloseTrades(OrdersIterator &it, const int slippage, int& failed)
   {
      int closedPositions = 0;
      failed = 0;
      while (it.Next())
      {
         string error;
         if (!CloseCurrentOrder(slippage, error))
         {
            ++failed;
            Print("Failed to close positoin. ", error);
         }
         else
            ++closedPositions;
      }
      return closedPositions;
   }
};

// Close on opposite v.1.1
interface ICloseOnOppositeStrategy
{
public:
   virtual void DoClose(const OrderSide side) = 0;
};

class DontCloseOnOppositeStrategy : public ICloseOnOppositeStrategy
{
public:
   void DoClose(const OrderSide side)
   {
      // do nothing
   }
};

class DoCloseOnOppositeStrategy : public ICloseOnOppositeStrategy
{
   int _magicNumber;
   int _slippage;
public:
   DoCloseOnOppositeStrategy(const int slippage, const int magicNumber)
   {
      _magicNumber = magicNumber;
      _slippage = slippage;
   }

   void DoClose(const OrderSide side)
   {
      OrdersIterator toClose();
      toClose.WhenSide(side).WhenMagicNumber(_magicNumber).WhenTrade();
      TradingCommands::CloseTrades(toClose, _slippage);
   }
};

// Position cap v.1.1
interface IPositionCapStrategy
{
public:
   virtual bool IsLimitHit() = 0;
};

class PositionCapStrategy : public IPositionCapStrategy
{
   int _magicNumber;
   int _maxSidePositions;
   int _totalPositions;
   string _symbol;
   OrderSide _side;
public:
   PositionCapStrategy(const OrderSide side, const int magicNumber, const int maxSidePositions, const int totalPositions,
      const string symbol = "")
   {
      _symbol = symbol;
      _side = side;
      _magicNumber = magicNumber;
      _maxSidePositions = maxSidePositions;
      _totalPositions = totalPositions;
   }

   bool IsLimitHit()
   {
      OrdersIterator sideSpecificIterator();
      sideSpecificIterator.WhenMagicNumber(_magicNumber).WhenTrade().WhenSide(_side);
      if (_symbol != "")
         sideSpecificIterator.WhenSymbol(_symbol);
      int side_positions = sideSpecificIterator.Count();
      if (side_positions >= _maxSidePositions)
         return true;

      OrdersIterator it();
      it.WhenMagicNumber(_magicNumber).WhenTrade();
      if (_symbol != "")
         it.WhenSymbol(_symbol);
      int positions = it.Count();
      return positions >= _totalPositions;
   }
};

class NoPositionCapStrategy : public IPositionCapStrategy
{
public:
   bool IsLimitHit()
   {
      return false;
   }
};

// Market order builder v 1.5
// More templates and snippets on https://github.com/sibvic/mq4-templates

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
   MarketOrderBuilder *SetSide(const OrderSide orderSide)
   {
      _orderSide = orderSide;
      return &this;
   }
   
   MarketOrderBuilder *SetInstrument(const string instrument)
   {
      _instrument = instrument;
      return &this;
   }
   
   MarketOrderBuilder *SetAmount(const double amount)
   {
      _amount = amount;
      return &this;
   }
   
   MarketOrderBuilder *SetSlippage(const int slippage)
   {
      _slippage = slippage;
      return &this;
   }
   
   MarketOrderBuilder *SetStopLoss(const double stop)
   {
      _stop = NormalizeDouble(stop, Digits);
      return &this;
   }
   
   MarketOrderBuilder *SetTakeProfit(const double limit)
   {
      _limit = NormalizeDouble(limit, Digits);
      return &this;
   }
   
   MarketOrderBuilder *SetMagicNumber(const int magicNumber)
   {
      _magicNumber = magicNumber;
      return &this;
   }

   MarketOrderBuilder *SetComment(const string comment)
   {
      _comment = comment;
      return &this;
   }
   
   int Execute(string &errorMessage)
   {
      int orderType = _orderSide == BuySide ? OP_BUY : OP_SELL;
      double minstoplevel = MarketInfo(_instrument, MODE_STOPLEVEL); 
      
      double rate = _orderSide == BuySide ? MarketInfo(_instrument, MODE_ASK) : MarketInfo(_instrument, MODE_BID);
      int order = OrderSend(_instrument, orderType, _amount, rate, _slippage, _stop, _limit, _comment, _magicNumber);
      if (order == -1)
      {
         int error = GetLastError();
         switch (error)
         {
            case ERR_NOT_ENOUGH_MONEY:
               errorMessage = "Not enought money";
               return -1;
            case ERR_INVALID_TRADE_VOLUME:
               {
                  double minVolume = SymbolInfoDouble(_instrument, SYMBOL_VOLUME_MIN);
                  if (_amount < minVolume)
                  {
                     errorMessage = "Volume of the lot is too low: " + DoubleToStr(_amount) + " Min lot is: " + DoubleToStr(minVolume);
                     return -1;
                  }
                  double maxVolume = SymbolInfoDouble(_instrument, SYMBOL_VOLUME_MAX);
                  if (_amount > maxVolume)
                  {
                     errorMessage = "Volume of the lot is too high: " + DoubleToStr(_amount) + " Max lot is: " + DoubleToStr(maxVolume);
                     return -1;
                  }
                  errorMessage = "Invalid volume: " + DoubleToStr(_amount);
               }
               return -1;
            case ERR_OFF_QUOTES:
               errorMessage = "No quotes";
               return -1;
            case ERR_TRADE_NOT_ALLOWED:
               errorMessage = "Trading is not allowed";
               return -1;
            case ERR_TRADE_HEDGE_PROHIBITED:
               errorMessage = "Trade hedge prohibited";
               return -1;
            case ERR_INVALID_STOPS:
               {
                  double point = SymbolInfoDouble(_instrument, SYMBOL_POINT);
                  int minStopDistancePoints = (int)SymbolInfoInteger(_instrument, SYMBOL_TRADE_STOPS_LEVEL);
                  if (_stop != 0.0)
                  {
                     if (MathRound(MathAbs(rate - _stop) / point) < minStopDistancePoints)
                        errorMessage = "Your stop loss level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                     else
                        errorMessage = "Invalid stop loss in the request";
                  }
                  else if (_limit != 0.0)
                  {
                     if (MathRound(MathAbs(rate - _limit) / point) < minStopDistancePoints)
                        errorMessage = "Your take profit level is too close. The minimal distance allowed is " + IntegerToString(minStopDistancePoints) + " points";
                     else
                        errorMessage = "Invalid take profit in the request";
                  }
                  else
                     errorMessage = "Invalid take profit in the request";
               }
               return -1;
            case ERR_INVALID_PRICE:
               errorMessage = "Invalid price";
               return -1;
            default:
               errorMessage = "Failed to create order: " + IntegerToString(error);
               return -1;
         }
      }
      return order;
   }
};

// Entry strategy v.1.2
interface IEntryStrategy
{
public:
   virtual int OpenPosition(const int period, OrderSide side, IMoneyManagementStrategy *moneyManagement, const string comment, double &stopLoss) = 0;

   virtual int Exit(const OrderSide side) = 0;
};

class MarketEntryStrategy : public IEntryStrategy
{
   string _symbol;
   int _magicMumber;
   int _slippagePoints;
public:
   MarketEntryStrategy(const string symbol, const int magicMumber, const int slippagePoints)
   {
      _magicMumber = magicMumber;
      _slippagePoints = slippagePoints;
      _symbol = symbol;
   }

   int OpenPosition(const int period, OrderSide side, IMoneyManagementStrategy *moneyManagement, const string comment, double &stopLoss)
   {
      double entryPrice = side == BuySide ? InstrumentInfo::GetAsk(_symbol) : InstrumentInfo::GetBid(_symbol);
      double amount;
      double takeProfit;
      moneyManagement.Get(period, entryPrice, amount, stopLoss, takeProfit);
      if (amount == 0.0)
         return -1;
      string error;
      MarketOrderBuilder *orderBuilder = new MarketOrderBuilder();
      int order = orderBuilder
         .SetSide(side)
         .SetInstrument(_symbol)
         .SetAmount(amount)
         .SetSlippage(_slippagePoints)
         .SetMagicNumber(_magicMumber)
         .SetStopLoss(stopLoss)
         .SetTakeProfit(takeProfit)
         .SetComment(comment)
         .Execute(error);
      delete orderBuilder;
      if (order == -1)
      {
         Print("Failed to open position: " + error);
      }
      return order;
   }

   int Exit(const OrderSide side)
   {
      OrdersIterator toClose();
      toClose.WhenSide(side).WhenMagicNumber(_magicMumber).WhenTrade();
      return TradingCommands::CloseTrades(toClose, _slippagePoints);
   }
};

// Mandatory closing v.2.0
interface IMandatoryClosingLogic
{
public:
   virtual void DoLogic() = 0;
};

class NoMandatoryClosing : public IMandatoryClosingLogic
{
public:
   void DoLogic()
   {

   }
};

class DoMandatoryClosing : public IMandatoryClosingLogic
{
   int _magicNumber;
   int _slippagePoints;
   Signaler *_signaler;
public:
   DoMandatoryClosing(const int magicNumber, int slippagePoints)
   {
      _slippagePoints = slippagePoints;
      _magicNumber = magicNumber;
      _signaler = NULL;
   }

   void SetSignaler(Signaler *signaler)
   {
      _signaler = signaler;
   }

   void DoLogic()
   {
      OrdersIterator toClose();
      toClose.WhenMagicNumber(_magicNumber).WhenTrade();
      int positionsClosed = TradingCommands::CloseTrades(toClose, _slippagePoints);
      TradingCommands::DeleteOrders(_magicNumber);
      if (positionsClosed > 0 && _signaler != NULL)
         _signaler.SendNotifications("Mandatory closing");
   }
};

// Trading controller v2.15
class TradingController
{
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastbartime;
   double _lastLot;
   IBreakevenLogic *_breakeven;
   ActionOnConditionLogic* actions;
   ITrailingLogic *_trailing;
   Signaler *_signaler;
   datetime _lastBarDate;
   TradeCalculator *_calculator;
   TradingTime *_tradingTime;
   ICondition *_longCondition;
   ICondition *_shortCondition;
   ICondition *_exitAllCondition;
   ICondition *_exitLongCondition;
   ICondition *_exitShortCondition;
   IMoneyManagementStrategy *_longMoneyManagement[];
   IMoneyManagementStrategy *_shortMoneyManagement[];
   ICloseOnOppositeStrategy *_closeOnOpposite;
   IPositionCapStrategy *_longPositionCap;
   IPositionCapStrategy *_shortPositionCap;
   IEntryStrategy *_entryStrategy;
   IMandatoryClosingLogic *_mandatoryClosing;
   string _algorithmId;
   ActionOnConditionLogic* _actions;
public:
   TradingController(TradeCalculator *calculator, ENUM_TIMEFRAMES timeframe, Signaler *signaler, const string algorithmId = "")
   {
      _actions = NULL;
      _algorithmId = algorithmId;
      _longPositionCap = NULL;
      _shortPositionCap = NULL;
      _closeOnOpposite = NULL;
      _longCondition = NULL;
      _shortCondition = NULL;
      _calculator = calculator;
      _signaler = signaler;
      _timeframe = timeframe;
      _lastLot = lots_value;
      _exitAllCondition = NULL;
      _exitLongCondition = NULL;
      _exitShortCondition = NULL;
      _tradingTime = NULL;
      _mandatoryClosing = NULL;
   }

   ~TradingController()
   {
      delete _actions;
      delete _mandatoryClosing;
      delete _entryStrategy;
      delete _longPositionCap;
      delete _shortPositionCap;
      delete _closeOnOpposite;
      for (int i = 0; i < ArraySize(_longMoneyManagement); ++i)
      {
         delete _longMoneyManagement[i];
      }
      for (int i = 0; i < ArraySize(_shortMoneyManagement); ++i)
      {
         delete _shortMoneyManagement[i];
      }
      delete _exitAllCondition;
      delete _exitLongCondition;
      delete _exitShortCondition;
      delete _calculator;
      delete _signaler;
      delete _breakeven;
      delete _trailing;
      delete _longCondition;
      delete _shortCondition;
      delete _tradingTime;
   }

   void SetActions(ActionOnConditionLogic* __actions) { _actions = __actions; }
   void SetTradingTime(TradingTime *tradingTime) { _tradingTime = tradingTime; }
   void SetBreakeven(IBreakevenLogic *breakeven) { _breakeven = breakeven; }
   void SetTrailing(ITrailingLogic *trailing) { _trailing = trailing; }
   void SetLongCondition(ICondition *condition) { _longCondition = condition; }
   void SetShortCondition(ICondition *condition) { _shortCondition = condition; }
   void SetExitAllCondition(ICondition *condition) { _exitAllCondition = condition; }
   void SetExitLongCondition(ICondition *condition) { _exitLongCondition = condition; }
   void SetExitShortCondition(ICondition *condition) { _exitShortCondition = condition; }
   void AddLongMoneyManagement(IMoneyManagementStrategy *moneyManagement)
   {
      int count = ArraySize(_longMoneyManagement);
      ArrayResize(_longMoneyManagement, count + 1);
      _longMoneyManagement[count] = moneyManagement;
   }
   void AddShortMoneyManagement(IMoneyManagementStrategy *moneyManagement)
   {
      int count = ArraySize(_shortMoneyManagement);
      ArrayResize(_shortMoneyManagement, count + 1);
      _shortMoneyManagement[count] = moneyManagement;
   }
   void SetCloseOnOpposite(ICloseOnOppositeStrategy *closeOnOpposite) { _closeOnOpposite = closeOnOpposite; }
   void SetLongPositionCap(IPositionCapStrategy *positionCap) { _longPositionCap = positionCap; }
   void SetShortPositionCap(IPositionCapStrategy *positionCap) { _shortPositionCap = positionCap; }
   void SetEntryStrategy(IEntryStrategy *entryStrategy) { _entryStrategy = entryStrategy; }
   void SetMandatoryClosing(IMandatoryClosingLogic *mandatoryClosing) { _mandatoryClosing = mandatoryClosing; }

   void DoTrading()
   {
      int tradePeriod = trade_live == TradingModeLive ? 0 : 1;
      datetime current_time = iTime(_calculator.GetSymbol(), _timeframe, tradePeriod);
      _actions.DoLogic(tradePeriod);
      _trailing.DoLogic();
      if (trade_live == TradingModeOnBarClose)
      {
         if (_lastBarDate != current_time)
            _lastBarDate = current_time;
         else
            return;
      }
      bool exitAll = _exitAllCondition.IsPass(tradePeriod);
      if (exitAll || (_exitLongCondition.IsPass(tradePeriod) && !_exitLongCondition.IsPass(tradePeriod + 1)))
      {
         if (_entryStrategy.Exit(BuySide) > 0)
            _signaler.SendNotifications("Exit Buy");
      }
      if (exitAll || (_exitShortCondition.IsPass(tradePeriod) && !_exitShortCondition.IsPass(tradePeriod + 1)))
      {
         if (_entryStrategy.Exit(SellSide) > 0)
            _signaler.SendNotifications("Exit Sell");
      }

      if (_tradingTime != NULL && !_tradingTime.IsTradingTime(TimeCurrent()))
      {
         _mandatoryClosing.DoLogic();
         return;
      }
      if (current_time == _lastbartime)
         return;

      if (_longCondition.IsPass(tradePeriod) && !_longCondition.IsPass(tradePeriod + 1))
      {
         if (_longPositionCap.IsLimitHit())
         {
            _signaler.SendNotifications("Positions limit has been reached");
            return;
         }
         _closeOnOpposite.DoClose(SellSide);
         for (int i = 0; i < ArraySize(_longMoneyManagement); ++i)
         {
            double stopLoss = 0.0;
            int order = _entryStrategy.OpenPosition(tradePeriod, BuySide, _longMoneyManagement[i], _algorithmId, stopLoss);
            if (order >= 0)
            {
               _lastbartime = current_time;
               _breakeven.CreateBreakeven(order, tradePeriod);
               _trailing.Create(order, (_calculator.GetAsk() - stopLoss) / _calculator.GetPipSize());
            }
         }
         _signaler.SendNotifications("Buy");
      }
      if (_shortCondition.IsPass(tradePeriod) && !_shortCondition.IsPass(tradePeriod + 1))
      {
         if (_shortPositionCap.IsLimitHit())
         {
            _signaler.SendNotifications("Positions limit has been reached");
            return;
         }
         _closeOnOpposite.DoClose(BuySide);

         for (int i = 0; i < ArraySize(_shortMoneyManagement); ++i)
         {
            double stopLoss = 0.0;
            int order = _entryStrategy.OpenPosition(tradePeriod, SellSide, _shortMoneyManagement[i], _algorithmId, stopLoss);
            if (order >= 0)
            {
               _lastbartime = current_time;
               _breakeven.CreateBreakeven(order, tradePeriod);
               _trailing.Create(order, (stopLoss - _calculator.GetBid()) / _calculator.GetPipSize());
            }
         }
         _signaler.SendNotifications("Sell");
      }
   }
private:
};

TradingController *controllers[];

ICondition* CreateLongCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == ShortSideOnly)
      return (ICondition *)new DisabledCondition();

   return (ICondition *)new LongCondition(symbol, timeframe);
}

ICondition* CreateShortCondition(string symbol, ENUM_TIMEFRAMES timeframe)
{
   if (trading_side == ShortSideOnly)
      return (ICondition *)new DisabledCondition();

   return (ICondition *)new ShortCondition(symbol, timeframe);
}

TradingController *CreateController(const string symbol, const ENUM_TIMEFRAMES timeframe, string &error)
{
   TradingTime *tradingTime = new TradingTime();
   if (!tradingTime.Init(start_time, stop_time, error))
   {
      delete tradingTime;
      return NULL;
   }
   if (use_weekly_timing && !tradingTime.SetWeekTradingTime(week_start_day, week_start_time, week_stop_day, week_stop_time, error))
   {
      delete tradingTime;
      return NULL;
   }

   TradeCalculator *tradeCalculator = TradeCalculator::Create(symbol);
   if (!tradeCalculator.IsLotsValid(lots_value, lots_type, error))
   {
      delete tradeCalculator;
      delete tradingTime;
      return NULL;
   }
   Signaler *signaler = new Signaler(symbol, timeframe);
   signaler.SetMessagePrefix(symbol + "/" + signaler.GetTimeframeStr() + ": ");
   ActionOnConditionLogic* actions = new ActionOnConditionLogic();
   TradingController *controller = new TradingController(tradeCalculator, timeframe, signaler);
   controller.SetActions(actions);
   if (breakeven_type == StopLimitDoNotUse)
      controller.SetBreakeven(new DisabledBreakevenLogic());
   else
      controller.SetBreakeven(new BreakevenLogic(breakeven_type, breakeven_value, breakeven_level, signaler, actions));

   if (trailing_type == TrailingDontUse)
      controller.SetTrailing(new DisabledTrailingLogic());
   else
      controller.SetTrailing(new TrailingLogic(trailing_type, trailing_step, 0, trailing_start, timeframe, signaler));

   controller.SetTradingTime(tradingTime);

   ICondition *longCondition = CreateLongCondition(symbol, timeframe);
   ICondition *shortCondition = CreateShortCondition(symbol, timeframe);
   IMoneyManagementStrategy *longMoneyManagement = new LongMoneyManagementStrategy(tradeCalculator, lots_type, lots_value, stop_loss_type, stop_loss_value, take_profit_type, take_profit_value, leverage_override);
   IMoneyManagementStrategy *shortMoneyManagement = new ShortMoneyManagementStrategy(tradeCalculator, lots_type, lots_value, stop_loss_type, stop_loss_value, take_profit_type, take_profit_value, leverage_override);
   ICondition *exitLongCondition = new ExitLongCondition(symbol, timeframe);
   ICondition *exitShortCondition = new ExitShortCondition(symbol, timeframe);
   switch (logic_direction)
   {
      case DirectLogic:
         controller.SetLongCondition(longCondition);
         controller.SetShortCondition(shortCondition);
         controller.SetExitLongCondition(exitLongCondition);
         controller.SetExitShortCondition(exitShortCondition);
         break;
      case ReversalLogic:
         controller.SetLongCondition(shortCondition);
         controller.SetShortCondition(longCondition);
         controller.SetExitLongCondition(exitShortCondition);
         controller.SetExitShortCondition(exitLongCondition);
         break;
   }
   controller.AddLongMoneyManagement(longMoneyManagement);
   controller.AddShortMoneyManagement(shortMoneyManagement);

   controller.SetExitAllCondition(new DisabledCondition());
   if (close_on_opposite)
      controller.SetCloseOnOpposite(new DoCloseOnOppositeStrategy(slippage_points, magic_number));
   else
      controller.SetCloseOnOpposite(new DontCloseOnOppositeStrategy());

   if (position_cap)
   {
      controller.SetLongPositionCap(new PositionCapStrategy(BuySide, magic_number, no_of_buy_position, no_of_positions, symbol));
      controller.SetShortPositionCap(new PositionCapStrategy(SellSide, magic_number, no_of_sell_position, no_of_positions, symbol));
   }
   else
   {
      controller.SetLongPositionCap(new NoPositionCapStrategy());
      controller.SetShortPositionCap(new NoPositionCapStrategy());
   }

   controller.SetEntryStrategy(new MarketEntryStrategy(symbol, magic_number, slippage_points));
   if (mandatory_closing)
      controller.SetMandatoryClosing(new DoMandatoryClosing(magic_number, slippage_points));
   else
      controller.SetMandatoryClosing(new NoMandatoryClosing());

   return controller;
}

int OnInit()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }

   string error;
   TradingController *controller = CreateController(_Symbol, (ENUM_TIMEFRAMES)_Period, error);
   if (controller == NULL)
   {
      Print(error);
      return INIT_FAILED;
   }
   int controllersCount = 0;
   ArrayResize(controllers, controllersCount + 1);
   controllers[controllersCount++] = controller;
   
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   int i_count = ArraySize(controllers);
   for (int i = 0; i < i_count; ++i)
   {
      delete controllers[i];
   }
}

void OnTick()
{
   int i_count = ArraySize(controllers);
   for (int i = 0; i < i_count; ++i)
   {
      controllers[i].DoTrading();
   }
}
