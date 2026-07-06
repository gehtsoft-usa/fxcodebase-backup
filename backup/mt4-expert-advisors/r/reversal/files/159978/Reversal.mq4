//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76172

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_label1 "V Up"
#property indicator_type1 DRAW_ARROW
#property indicator_color1 Lime
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "V Dn"
#property indicator_type2 DRAW_ARROW
#property indicator_color2 Red
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#define ColorRGB(red, green, blue, transp) (uint)(red + (green << 8) + (blue << 16) + ((uint)(transp * 2.55) << 24))
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

class NewBarState
{
   datetime _last;
public:
   NewBarState()
   {
      _last = 0;
   }
   void Clear()
   {
      _last = 0;
   }
   bool IsNew(datetime date)
   {
      bool isnew = _last != date;
      _last = date;
      return isnew;
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
   return value - bottomValue < topValue - value 
      ? bottomColor
      : topColor;
}

double SetStream(double &stream[], int pos, double value, double defaultValue)
{
   stream[pos] = value == EMPTY_VALUE ? defaultValue : value;
   return stream[pos];
}

datetime Timestamp(int year, int month, int day, int hour, int minute, int second)
{
   MqlDateTime time;
   time.year = year;
   time.mon = month;
   time.day = day;
   time.hour = hour;
   time.min = minute;
   time.sec = second;
   return StructToTime(time);
}

class Runtime
{
public:
   static void Error(string message)
   {
      Print(message);
      ExpertRemove();
   }
};
// Pine-script like safe operations
// v.1.2

double Nz(double val, double defaultValue = 0)
{
   return val == EMPTY_VALUE ? defaultValue : val;
}
double SafePlus(int left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
double SafePlus(double left, int right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
int SafePlus(int left, int right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
double SafePlus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left + right;
}
string SafePlus(string left, string right)
{
   if (left == NULL || right == NULL)
   {
      return NULL;
   }
   return left + right;
}

double SafeMinus(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left - right;
}

double SafeDivide(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE || right == 0)
   {
      return EMPTY_VALUE;
   }
   return left / right;
}

double SafeMultiply(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return left * right;
}

bool SafeGreater(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left > right;
}

bool SafeGE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left >= right;
}

bool SafeLess(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left < right;
}

bool SafeLE(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return false;
   }
   return left <= right;
}

double SafeMathExp(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathExp(value);
}

double SafeMathMax(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMax(left, right);
}

double SafeMathMin(double left, double right)
{
   if (left == EMPTY_VALUE || right == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathMin(left, right);
}

double SafeMathPow(double value, double power)
{
   if (value == EMPTY_VALUE || power == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathPow(value, power);
}

double SafeMathAbs(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathAbs(value);
}

double SafeMathRound(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathRound(value);
}

double SafeMathRound(double value, int precision)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return NormalizeDouble(value, precision);
}

double SafeMathSqrt(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathSqrt(value);
}

int SafeSign(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   if (value == 0)
   {
      return 0;
   }
   return value > 0 ? 1 : -1;
}

double SafeLog(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathLog(value);
}
double SafeLog10(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathLog10(value);
}
double SafeCos(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathCos(value);
}
double SafeArccos(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArccos(value);
}
double SafeSin(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathSin(value);
}
double SafeArcsin(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArcsin(value);
}
double SafeTan(double value) 
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathTan(value);
}
double SafeArctan(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathArctan(value);
}
double InvertSign(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return -value;
}
double SafeMathFloor(double value)
{
   if (value == EMPTY_VALUE)
   {
      return EMPTY_VALUE;
   }
   return MathFloor(value);
}
int SafeMathCeil(double value)
{
   if (value == EMPTY_VALUE)
   {
      return INT_MIN;
   }
   return MathCeil(value);
}
// PlotShape v1.2
#ifndef PlotShape_IMPL
#define PlotShape_IMPL

class PlotShape
{
private:
   static void SetNA(double& plot[], int period)
   {
      plot[period] = EMPTY_VALUE;
   }
   
   static void SetValue(double& plot[], int period, string location, double seriesValue, const double& high[], const double& low[], int shift)
   {
      if (location == "abovebar" || location == "top")
      {
         plot[period] = high[period + shift];
         return;
      }
      if (location == "belowbar" || location == "bottom")
      {
         plot[period] = low[period + shift];
         return;
      }
      plot[period] = seriesValue;
   }
public:
   static void Set(double& plot[], int period, string location, double seriesValue, const double& high[], const double& low[], int shift, uint clr = INT_MAX)
   {
      if (seriesValue == EMPTY_VALUE)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
   
   static void Set(double& plot[], int period, string location, int seriesValue, const double& high[], const double& low[], int shift, uint clr = INT_MAX)
   {
      if (seriesValue == INT_MIN)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
   
   static void SetBool(double& plot[], int period, string location, int seriesValue, const double& high[], const double& low[], int shift, uint clr = INT_MAX)
   {
      if (seriesValue == -1 || seriesValue == 0)
      {
         SetNA(plot, period);
         return;
      }
      SetValue(plot, period, location, seriesValue, high, low, shift);
   }
};

#endif
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

input int param1 = 20; // Candle Lookback
input int param2 = 3; // Confirm Within
input bool param3 = false; // Non-Repainting Mode
input int bars_limit = 100000; // Bars limit
Signaler* _signaler;
int lookback;
int confirmation;
int nonRepaint;
double bullActiveCandle[];
double bullActiveCandle_DEFAULT_VALUE;
double bullActiveCandleLow[];
double bullActiveCandleLow_DEFAULT_VALUE;
double bullActiveCandleHigh[];
double bullActiveCandleHigh_DEFAULT_VALUE;
double bullSignalActive[];
double bullSignalActive_DEFAULT_VALUE;
double bullCandleCount[];
double bullCandleCount_DEFAULT_VALUE;
double bearActiveCandle[];
double bearActiveCandle_DEFAULT_VALUE;
double bearActiveCandleLow[];
double bearActiveCandleLow_DEFAULT_VALUE;
double bearActiveCandleHigh[];
double bearActiveCandleHigh_DEFAULT_VALUE;
double bearSignalActive[];
double bearSignalActive_DEFAULT_VALUE;
double bearCandleCount[];
double bearCandleCount_DEFAULT_VALUE;
double plot1[];
double plot2[];

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

int init()
{
   IndicatorBuffers(12);
   lookback = param1;
   confirmation = param2;
   nonRepaint = param3;
   int id = 0;
   SetIndexBuffer(id, plot1);
   SetIndexArrow(id++, 217);
   SetIndexBuffer(id, plot2);
   SetIndexArrow(id++, 218);
   _signaler = new Signaler();
   IndicatorObjPrefix = GenerateIndicatorPrefix("");
   IndicatorShortName("Reversal");
   SetIndexBuffer(id++, bullActiveCandle);
   SetIndexBuffer(id++, bullActiveCandleLow);
   SetIndexBuffer(id++, bullActiveCandleHigh);
   SetIndexBuffer(id++, bullSignalActive);
   SetIndexBuffer(id++, bullCandleCount);
   SetIndexBuffer(id++, bearActiveCandle);
   SetIndexBuffer(id++, bearActiveCandleLow);
   SetIndexBuffer(id++, bearActiveCandleHigh);
   SetIndexBuffer(id++, bearSignalActive);
   SetIndexBuffer(id++, bearCandleCount);
   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete _signaler;
   return 0;
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
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      bullActiveCandle_DEFAULT_VALUE = false;
      ArrayInitialize(bullActiveCandle, bullActiveCandle_DEFAULT_VALUE);
      bullActiveCandleLow_DEFAULT_VALUE = 0.0;
      ArrayInitialize(bullActiveCandleLow, bullActiveCandleLow_DEFAULT_VALUE);
      bullActiveCandleHigh_DEFAULT_VALUE = 0.0;
      ArrayInitialize(bullActiveCandleHigh, bullActiveCandleHigh_DEFAULT_VALUE);
      bullSignalActive_DEFAULT_VALUE = false;
      ArrayInitialize(bullSignalActive, bullSignalActive_DEFAULT_VALUE);
      bullCandleCount_DEFAULT_VALUE = 0;
      ArrayInitialize(bullCandleCount, bullCandleCount_DEFAULT_VALUE);
      bearActiveCandle_DEFAULT_VALUE = false;
      ArrayInitialize(bearActiveCandle, bearActiveCandle_DEFAULT_VALUE);
      bearActiveCandleLow_DEFAULT_VALUE = 0.0;
      ArrayInitialize(bearActiveCandleLow, bearActiveCandleLow_DEFAULT_VALUE);
      bearActiveCandleHigh_DEFAULT_VALUE = 0.0;
      ArrayInitialize(bearActiveCandleHigh, bearActiveCandleHigh_DEFAULT_VALUE);
      bearSignalActive_DEFAULT_VALUE = false;
      ArrayInitialize(bearSignalActive, bearSignalActive_DEFAULT_VALUE);
      bearCandleCount_DEFAULT_VALUE = 0;
      ArrayInitialize(bearCandleCount, bearCandleCount_DEFAULT_VALUE);
      ArrayInitialize(plot1, EMPTY_VALUE);
      ArrayInitialize(plot2, EMPTY_VALUE);
   }
   bool timeSeries = ArrayGetAsSeries(time);
   bool openSeries = ArrayGetAsSeries(open);
   bool highSeries = ArrayGetAsSeries(high);
   bool lowSeries = ArrayGetAsSeries(low);
   bool closeSeries = ArrayGetAsSeries(close);
   bool tickVolumeSeries = ArrayGetAsSeries(tick_volume);
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   int toSkip = 0;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      bullActiveCandle[pos] = pos < (rates_total - 1) ? bullActiveCandle[pos + 1] : false;
      bullActiveCandleLow[pos] = pos < (rates_total - 1) ? bullActiveCandleLow[pos + 1] : 0.0;
      bullActiveCandleHigh[pos] = pos < (rates_total - 1) ? bullActiveCandleHigh[pos + 1] : 0.0;
      bullSignalActive[pos] = pos < (rates_total - 1) ? bullSignalActive[pos + 1] : false;
      bullCandleCount[pos] = pos < (rates_total - 1) ? bullCandleCount[pos + 1] : 0;
      bearActiveCandle[pos] = pos < (rates_total - 1) ? bearActiveCandle[pos + 1] : false;
      bearActiveCandleLow[pos] = pos < (rates_total - 1) ? bearActiveCandleLow[pos + 1] : 0.0;
      bearActiveCandleHigh[pos] = pos < (rates_total - 1) ? bearActiveCandleHigh[pos + 1] : 0.0;
      bearSignalActive[pos] = pos < (rates_total - 1) ? bearSignalActive[pos + 1] : false;
      bearCandleCount[pos] = pos < (rates_total - 1) ? bearCandleCount[pos + 1] : 0;
      int bullCandle = 0;
      int bearCandle = 0;
      int vup = false;
      int vdn = false;
      int for1_from = 0;
      int for1_to = (lookback - 1);
      bool for1_forward = for1_from <= for1_to;
      int for1_step = 1 * (for1_forward ? 1 : -1);
      if (for1_from == EMPTY_VALUE || for1_to == EMPTY_VALUE) { continue; }
      for (int i = for1_from; (for1_forward ? i <= for1_to : i >= for1_to); i += for1_step)
      {
         if (pos + i > (rates_total - 1)) { continue; }
         if (SafeLess(close[pos], low[pos + i]))
         {
            bullCandle = bullCandle + 1;
         }
         if (pos + i > (rates_total - 1)) { continue; }
         if (SafeGreater(close[pos], high[pos + i]))
         {
            bearCandle = bearCandle + 1;
         }
      }
      if ((bullCandle == (lookback - 1)))
      {
         SetStream(bullActiveCandle, pos, true, bullActiveCandle_DEFAULT_VALUE);
         SetStream(bullActiveCandleLow, pos, low[pos], bullActiveCandleLow_DEFAULT_VALUE);
         SetStream(bullActiveCandleHigh, pos, high[pos], bullActiveCandleHigh_DEFAULT_VALUE);
         SetStream(bullSignalActive, pos, false, bullSignalActive_DEFAULT_VALUE);
         SetStream(bullCandleCount, pos, 0, bullCandleCount_DEFAULT_VALUE);
      }
      if (bullActiveCandle[pos])
      {
         SetStream(bullCandleCount, pos, bullCandleCount[pos] + 1, bullCandleCount_DEFAULT_VALUE);
      }
      if ((bearCandle == (lookback - 1)))
      {
         SetStream(bearActiveCandle, pos, true, bearActiveCandle_DEFAULT_VALUE);
         SetStream(bearActiveCandleLow, pos, low[pos], bearActiveCandleLow_DEFAULT_VALUE);
         SetStream(bearActiveCandleHigh, pos, high[pos], bearActiveCandleHigh_DEFAULT_VALUE);
         SetStream(bearSignalActive, pos, false, bearSignalActive_DEFAULT_VALUE);
         SetStream(bearCandleCount, pos, 0, bearCandleCount_DEFAULT_VALUE);
      }
      if (bearActiveCandle[pos])
      {
         SetStream(bearCandleCount, pos, bearCandleCount[pos] + 1, bearCandleCount_DEFAULT_VALUE);
      }
      if ((close[pos] < bullActiveCandleLow[pos]))
      {
         SetStream(bullActiveCandle, pos, false, bullActiveCandle_DEFAULT_VALUE);
      }
      if ((close[pos] > bearActiveCandleHigh[pos]))
      {
         SetStream(bearActiveCandle, pos, false, bearActiveCandle_DEFAULT_VALUE);
      }
      if (nonRepaint)
      {
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if ((bullActiveCandle[pos + 1] == true) && SafeGreater(close[pos + 1], bullActiveCandleHigh[pos + 1]) && (bullSignalActive[pos + 1] == false) && SafeLE(bullCandleCount[pos + 1], (confirmation + 1)))
         {
            SetStream(bullSignalActive, pos, true, bullSignalActive_DEFAULT_VALUE);
            vup = true;
         }
      }
      else if ((bullActiveCandle[pos] == true) && (close[pos] > bullActiveCandleHigh[pos]) && (bullSignalActive[pos] == false) && (bullCandleCount[pos] <= (confirmation + 1)))
      {
         SetStream(bullSignalActive, pos, true, bullSignalActive_DEFAULT_VALUE);
         vup = true;
      }
      if (nonRepaint)
      {
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if (pos + 1 > (rates_total - 1)) { continue; }
         if ((bearActiveCandle[pos + 1] == true) && SafeLess(close[pos], bearActiveCandleLow[pos + 1]) && (bearSignalActive[pos + 1] == false) && SafeLE(bearCandleCount[pos + 1], (confirmation + 1)))
         {
            SetStream(bearSignalActive, pos, true, bearSignalActive_DEFAULT_VALUE);
            vdn = true;
         }
      }
      else if ((bearActiveCandle[pos] == true) && (close[pos] < bearActiveCandleLow[pos]) && (bearSignalActive[pos] == false) && (bearCandleCount[pos] <= (confirmation + 1)))
      {
         SetStream(bearSignalActive, pos, true, bearSignalActive_DEFAULT_VALUE);
         vdn = true;
      }
      PlotShape::SetBool(plot1, pos, "belowbar", vup, high, low, 0);
      PlotShape::SetBool(plot2, pos, "abovebar", vdn, high, low, 0);
      if (vup) { _signaler.SendNotifications("Bullish Revarsal", "Bullish Revarsal"); }
      if (vdn) { _signaler.SendNotifications("Bearish Revarsal", "Bearish Revarsal"); }
   }

   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76172

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+