// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68551

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

#property description "ZigZag"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 clrRed
#property indicator_color2 clrLime

string indi_name = "ZigZag with Fibonacci";

extern int Depth     = 12;
extern int Deviation = 5;
extern int Backstep  = 3;
extern int HistoryLimit = 500;
input bool Show_lines = true; // Show Fibonacci Lines
input bool use_level_1 = true; // Use level #1
input double level_1 = -0.236; // Level #1
input bool use_level_2 = true; // Use level #2
input double level_2 = 0; // Level #2
input bool use_level_3 = true; // Use level #3
input double level_3 = 0.236; // Level #3
input bool use_level_4 = true; // Use level #4
input double level_4 = 0.382; // Level #4
input bool use_level_5 = true; // Use level #5
input double level_5 = 0.5; // Level #5
input bool use_level_6 = true; // Use level #6
input double level_6 = 0.618; // Level #6
input bool use_level_7 = true; // Use level #7
input double level_7 = 0.764; // Level #7
input bool use_level_8 = true; // Use level #8
input double level_8 = 1; // Level #8
input bool use_level_9 = true; // Use level #9
input double level_9 = 1.272; // Level #9
input bool use_level_10 = false; // Use level #10
input double level_10 = -0.236; // Level #10
input bool use_level_11 = false; // Use level #11
input double level_11 = -0.236; // Level #11
input bool use_level_12 = false; // Use level #12
input double level_12 = -0.236; // Level #12
input bool use_level_13 = false; // Use level #13
input double level_13 = -0.236; // Level #13
input bool use_level_14 = false; // Use level #14
input double level_14 = -0.236; // Level #14
input bool use_level_15 = false; // Use level #15
input double level_15 = -0.236; // Level #15
input bool use_level_16 = false; // Use level #16
input double level_16 = -0.236; // Level #16
input bool use_level_17 = false; // Use level #17
input double level_17 = -0.236; // Level #17
input bool use_level_18 = false; // Use level #18
input double level_18 = -0.236; // Level #18
input bool use_level_19 = false; // Use level #19
input double level_19 = -0.236; // Level #19
input bool use_level_20 = false; // Use level #20
input double level_20 = -0.236; // Level #20
input bool use_level_21 = false; // Use level #21
input double level_21 = -0.236; // Level #21
input bool use_level_22 = false; // Use level #22
input double level_22 = -0.236; // Level #22

input color levels_color = Red; // Levels color
//Signaler v 1.6
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
      if (direction == 0)
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

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframe();

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

private:
   string GetTimeframe()
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
};

double Zig[];
double Zag[];
double LowMap[];
double HighMap[];
double pipSize;
double buy[], sell[];

class Level
{
   double _level;
public:
   Level(double level)
   {
      _level = level;
   }

   void Draw(double min, double max, int direction, datetime start, datetime finish)
   {
      double d = max - min;
      double price = direction == -1 ? min + d * _level : max - d * _level;
      string id = IndicatorObjPrefix + DoubleToString(_level) + "Value";
      ObjectCreate(0, id, OBJ_TREND, 0, start, price, finish, price);
      ObjectSetInteger(0, id, OBJPROP_COLOR, levels_color);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);

      string labelId = IndicatorObjPrefix + DoubleToString(_level) + "Label";
      ObjectCreate(0, labelId, OBJ_TEXT, 0, finish, price);
      ObjectSetString(0, labelId, OBJPROP_TEXT, DoubleToString(_level));
      ObjectSetString(0, labelId, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, labelId, OBJPROP_FONTSIZE, 10);
      ObjectSetInteger(0, labelId, OBJPROP_COLOR, levels_color);
      ObjectSetInteger(0, labelId, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
   }
};

class Levels
{
   Level* _levels[];
public:
   ~Levels()
   {
      for (int i = 0; i < ArraySize(_levels); ++i)
      {
         Level* item = _levels[i];
         delete item;
      }
   }

   void Draw(double min, double max, int direction, datetime start, datetime finish)
   {
      for (int i = 0; i < ArraySize(_levels); ++i)
      {
         Level* item = _levels[i];
         item.Draw(min, max, direction, start, finish);
      }
   }

   void Add(double level)
   {
      int size = ArraySize(_levels);
      ArrayResize(_levels, size + 1);
      _levels[size] = new Level(level);
   }
};

Levels levels;
Signaler* signaler;

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

int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }

   int mult = SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) % 2 == 1 ? 10 : 1;
   pipSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * mult;
   IndicatorName = GenerateIndicatorName("ZigZag with Fibonacci");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorBuffers(8);
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Zig);
   SetIndexLabel(0, "Down Swing");
   
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Zag);
   SetIndexLabel(1, "Up Swing");
   
   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, LowMap);
   SetIndexLabel(2, "Low Map");
   
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, HighMap);
   SetIndexLabel(3, "High Map");

   SetIndexBuffer(4, SearchMode);
   SetIndexLabel(4, "Search mode");
   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, Peak);
   SetIndexLabel(5, "Peak");
   
   SetIndexStyle(6, DRAW_ARROW, 0, 2);
   SetIndexArrow(6, 217);
   SetIndexBuffer(6, buy);
   SetIndexStyle(7, DRAW_ARROW, 0, 2);
   SetIndexArrow(7, 218);
   SetIndexBuffer(7, sell);

   if (use_level_1)
      levels.Add(level_1);
   if (use_level_2)
      levels.Add(level_2);
   if (use_level_3)
      levels.Add(level_3);
   if (use_level_4)
      levels.Add(level_4);
   if (use_level_5)
      levels.Add(level_5);
   if (use_level_6)
      levels.Add(level_6);
   if (use_level_7)
      levels.Add(level_7);
   if (use_level_8)
      levels.Add(level_8);
   if (use_level_9)
      levels.Add(level_9);
   if (use_level_10)
      levels.Add(level_10);
   if (use_level_11)
      levels.Add(level_11);
   if (use_level_12)
      levels.Add(level_12);
   if (use_level_13)
      levels.Add(level_13);
   if (use_level_14)
      levels.Add(level_14);
   if (use_level_15)
      levels.Add(level_15);
   if (use_level_16)
      levels.Add(level_16);
   if (use_level_17)
      levels.Add(level_17);
   if (use_level_18)
      levels.Add(level_18);
   if (use_level_19)
      levels.Add(level_19);
   if (use_level_20)
      levels.Add(level_20);
   if (use_level_21)
      levels.Add(level_21);
   if (use_level_22)
      levels.Add(level_22);

   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);

   return(0);
}

int deinit()
{
   delete signaler;
   signaler = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int searchBoth = 0;
int searchPeak = 1;
int searchLawn = -1;
int peak_count = 0;

double SearchMode[];
double Peak[];
double dummy[];

void RegisterPeak(const int period, const double mode, const double peak)
{
   peak_count = peak_count + 1;
   if (ArraySize(dummy) < peak_count)
      ArrayResize(dummy, peak_count);
   dummy[peak_count - 1] = period;
   SearchMode[period] = mode;
   Peak[period] = peak;
}

void ReplaceLastPeak(const int period, const double mode, const double peak)
{
   dummy[peak_count - 1] = period;
   SearchMode[period] = mode;
   Peak[period] = peak;
}

int GetPeak(const int offset)
{
   int peak = peak_count + offset;
   if (peak < 3)
      return -1;
   
   peak = dummy[peak];
   if (peak < 0)
      return -1;
   return peak;
}

int lastperiod = -1;
double lastlow = 0.0;
double lasthigh = 0.0;
int TEMP;

int GetLastZag(const int period)
{
   int last = -1;
   int from = period;
   for (; from < Bars; ++from)
   {
      if (Zag[from] != EMPTY_VALUE)
      {
         if (from == Bars || Zag[from + 1] != EMPTY_VALUE)
            return from;
         last = from;
      }
   }
   return last;
}

int GetLastZig(const int period)
{
   int last = -1;
   int from = period;
   for (; from < Bars; ++from)
   {
      if (Zig[from] != EMPTY_VALUE)
      {
         if (from == Bars || Zig[from + 1] != EMPTY_VALUE)
            return from;
         last = from;
      }
   }
   return last;
}

void SetZig(const int to, const double val_to)
{
   int from = GetLastZag(to);
   if (from == -1 || from == to)
   {
      Zig[to] = val_to;
      return;
   }
      
   double increment = (val_to - Zag[from]) / (double)(from - to);
   for (int i = from; i >= to; --i)
   {
      Zig[i] = Zag[from] + increment * (from - i);
      if (i != from)
         Zag[i] = EMPTY_VALUE;
   }
}

void SetZag(const int to, const double val_to)
{
   int from = GetLastZig(to);
   if (from == -1 || from == to)
   {
      Zag[to] = val_to;
      return;
   }
   double increment = (val_to - Zig[from]) / (double)(from - to);
   for (int i = from; i >= to; --i)
   {
      Zag[i] = Zig[from] + increment * (from - i);
      if (i != from)
         Zig[i] = EMPTY_VALUE;
   }
}

double GetZZ(int index)
{
   if (Zig[index] != EMPTY_VALUE)
      return Zig[index];
   return Zag[index];
}

int GetNextCrest(int index)
{
   if (GetZZ(index) == EMPTY_VALUE)
   {
      while (index < Bars && GetZZ(index) == EMPTY_VALUE)
      {
         ++index;
      }
      return index;
   }
   bool isascending = GetZZ(index + 1) < GetZZ(index);
   while (index < Bars && (GetZZ(index + 1) < GetZZ(index)) == isascending)
   {
      ++index;
   }
   return index;
}

bool IsABCUp(int index)
{
   if (index == 0)
      return false;
   if (Close[index - 1] >= Open[index])
      return false;
   double d = GetZZ(index);
   if (d == EMPTY_VALUE)
      return false;
   index = GetNextCrest(index);
   double c = GetZZ(index);
   if (c == EMPTY_VALUE)
      return false;
   index = GetNextCrest(index);
   double b = GetZZ(index);
   if (b == EMPTY_VALUE)
      return false;
   index = GetNextCrest(index);
   double a = GetZZ(index);
   if (a == EMPTY_VALUE)
      return false;
   return d < b && c < a;
}

bool IsABCDown(int index)
{
   if (index == 0)
      return false;
   if (Close[index - 1] <= Open[index])
      return false;
   double d = GetZZ(index);
   if (d == EMPTY_VALUE)
      return false;
   index = GetNextCrest(index);
   double c = GetZZ(index);
   if (c == EMPTY_VALUE)
      return false;
   index = GetNextCrest(index);
   double b = GetZZ(index);
   if (b == EMPTY_VALUE)
      return false;
   index = GetNextCrest(index);
   double a = GetZZ(index);
   if (a == EMPTY_VALUE)
      return false;
   return d > b && c > a;
}

datetime last_date;

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if (rates_total < Depth || Backstep >= Depth)
      return(0);
                  
   int limit = MathMin(HistoryLimit, Bars - Depth);
   for (int period = limit; period >= 0; period--)
   {
      // calculate zigzag for the completed candle ONLY
      if (period == lastperiod)
         continue;
      if (period > lastperiod)
      {
         lastlow = EMPTY_VALUE;
         lasthigh = EMPTY_VALUE;
         peak_count = 0;
      }
      lastperiod = period;
      if (limit < period + Depth)
         continue;
         
      UpdateLowMap(period);
      UpdateHighMap(period);

      int peak_3 = GetPeak(-3);
      if (peak_3 == -1)
         DoSearch(period, period + Depth, searchBoth,  EMPTY_VALUE);
      else
         DoSearch(period, peak_3, SearchMode[peak_3], Peak[peak_3]);
   }
   int index = GetNextCrest(0);
   if (index == Bars)
      return rates_total;
   if (IsABCDown(index) && last_date != Time[0])
   {
      buy[0] = High[0];
      sell[0] = EMPTY_VALUE;
      signaler.SendNotifications("New ABCD Down");
      last_date = Time[0];
   }
   else if (IsABCUp(index) && last_date != Time[0])
   {
      sell[0] = Low[0];
      buy[0] = EMPTY_VALUE;
      signaler.SendNotifications("New ABCD Up");
      last_date = Time[0];
   }
   int nextIndex = GetNextCrest(index);
   if (index == Bars)
      return rates_total;
   double zz = GetZZ(index);
   double nextZZ = GetZZ(nextIndex);
   levels.Draw(MathMin(zz, nextZZ), MathMax(zz, nextZZ), zz > nextZZ ? 1 : -1, Time[index], Time[nextIndex]);
   return rates_total;
}

double GetZigZagVal(const int period)
{
   if (Zig[period] != EMPTY_VALUE)
      return Zig[period];
   return Zag[period];
}

void CreateLabel(string name, datetime time, double price, string text, color col, int fontSize)
{
   ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
   ObjectSetString(0, name, OBJPROP_TEXT, text); 
   ObjectSetString(0, name, OBJPROP_FONT, "Arial"); 
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize); 
   ObjectSetInteger(0, name, OBJPROP_COLOR, col); 
}

double CoreMin(const int period, const int count)
{
   double min = DBL_MAX;
   for (int i = period; i <= period + count; ++i)
   {
      if (Low[i] < min)
         min = Low[i];
   }
   return min;
}

double CoreMax(const int period, const int count)
{
   double max = -DBL_MAX;
   for (int i = period; i <= period + count; ++i)
   {
      if (High[i] > max)
         max = High[i];
   }
   return max;
}

void UpdateLowMap(const int period)
{
   double val = CoreMin(period, Depth);
   if (val == lastlow)
      return;

   lastlow = val;
   // if current low is higher for more than Deviation pips, ignore
   if ((Low[period] - val) <= (pipSize * Deviation))
   {
      // check for the previous backstep lows
      for (int i = period + 1; i < period + Backstep - 1; i++)
      {
         if (LowMap[i] != EMPTY_VALUE && LowMap[i] > val)
            LowMap[i] = EMPTY_VALUE;
      }
      LowMap[period] = Low[period] == val ? val : EMPTY_VALUE;
   }
}

void UpdateHighMap(const int period)
{
   double val = CoreMax(period, Depth);
   if (val == lasthigh)
      return;

   lasthigh = val;
   // if current low is higher for more than Deviation pips, ignore
   if ((val - High[period]) <= (pipSize * Deviation))
   {
      // check for the previous backstep lows
      for (int i = period + 1; i < period + Backstep - 1; i++)
      {
         if (HighMap[i] != EMPTY_VALUE && HighMap[i] < val)
            HighMap[i] = EMPTY_VALUE;
      }
      HighMap[period] = High[period] == val ? val : EMPTY_VALUE;
   }
}

void DoSearch(const int period, const int start, int searchMode, double last_peak)
{
   for (int i = start; i > period; --i)
   {
      if (searchMode == searchBoth)
      {
         if (HighMap[i] != EMPTY_VALUE)
         {
            last_peak = HighMap[i];
            searchMode = searchLawn;
            RegisterPeak(i, searchMode, HighMap[i]);
         }
         else if (LowMap[i] != EMPTY_VALUE)
         {
            last_peak = LowMap[i];
            searchMode = searchPeak;
            RegisterPeak(i, searchMode, LowMap[i]);
         }
      }
      else if (searchMode == searchPeak)
      {
         if (LowMap[i] != EMPTY_VALUE && (last_peak == EMPTY_VALUE || LowMap[i] < last_peak))
         {
            last_peak = LowMap[i];
            SetZig(i, LowMap[i]);
            TEMP = i;
            ReplaceLastPeak(i, searchMode, last_peak);
         }
         if (HighMap[i] != EMPTY_VALUE && LowMap[i] == EMPTY_VALUE)
         {
            SetZag(i, HighMap[i]);
            TEMP = i;
            last_peak = HighMap[i];
            searchMode = searchLawn;
            RegisterPeak(i, searchMode, HighMap[i]);
         }
      }
      else if (searchMode == searchLawn)
      {
         if ((HighMap[i] != EMPTY_VALUE && (last_peak == EMPTY_VALUE || HighMap[i] > last_peak)))
         {
            last_peak = HighMap[i];
            SetZag(i, HighMap[i]);
            TEMP = i;
            ReplaceLastPeak(i, searchMode, HighMap[i]);
         }
         if (LowMap[i] != EMPTY_VALUE && HighMap[i] == EMPTY_VALUE)
         {
            SetZig(i, LowMap[i]);
            TEMP = i;
            last_peak = LowMap[i];
            searchMode = searchPeak;
            RegisterPeak(i, searchMode, LowMap[i]);
         }
      }
   }
}
