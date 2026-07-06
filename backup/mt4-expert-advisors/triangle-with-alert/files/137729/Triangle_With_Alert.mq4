// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70457

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

#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red

input bool k1 = true; // Triangle
input bool k2 = false; // Expanding Triangle
input bool k5 = false; // Wedges
input bool k6 = false; // Down Wedges
input int x = 5; // Max. Base / Side Ratio
input int y = 5; // Max. Side / Side Ratio
input int frame = 50; // Frame Size
input color top_color = Green; // Color of Top
input color bottom_color = Blue; // Color of Bottom
input int bars_limit = 100000; // Bars limit
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

string TimeframeToString(ENUM_TIMEFRAMES tf)
{
   switch (tf)
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
   return "";
}

double upy[], downy[];
Signaler signaler;

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("twa");
   IndicatorShortName("Triangle With Alert");

   IndicatorBuffers(2);
   signaler.SetMessagePrefix(_Symbol + "/" + TimeframeToString((ENUM_TIMEFRAMES)_Period) + ": ");

   int id = 0;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, upy);
   SetIndexEmptyValue(id, 0);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, downy);
   SetIndexEmptyValue(id, 0);
   ++id;

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
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

   int toSkip = frame + 5;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      double curr = high[pos + 2];
      if (curr >= high[pos + 4] && curr >= high[pos + 3] && curr >= high[pos + 1] && curr >= high[pos])
      {
         upy[pos + 2] = high[pos + 2];
      }
      curr = low[pos + 2];
      if (curr <= low[pos + 4] && curr <= low[pos + 3] && curr <= low[pos + 1] && curr <= low[pos])
      {
         downy[pos + 2] = low[pos + 2];
      }
      Draw(pos);
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}

double Distance(int x1, double y1, int x2, double y2)
{
   return MathSqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
}

void getline(int x1, double y1, int x2, double y2, double& a, double& b)
{
   a = ((y2 - y1) / (x2 - x1));
   b = (y1 - a * x1);
}

void intersect(double a1, double b1, double a2, double b2, double& x, double& y)
{
   if (a1 == a2)
   {
      return;
   }
   x = (b2 - b1) / (a1 - a2);
   y = a1 * x + b1;
}

void drawline(int x1, double y1, int x2, double y2, int ix, double iy, color clr)
{
   int lx1;
   int lx2;
   double ly1;
   double ly2;
   if (ix < x1)
   {
      lx1 = ix;
      ly1 = iy;
      lx2 = x2;
      ly2 = y2;
   }
   else if (ix >= x1 && ix <= x2)
   {
      lx1 = x1;
      ly1 = y1;
      lx2 = x2;
      ly2 = y2;
   }
   else
   {
      lx1 = x1;
      ly1 = y1;
      lx2 = ix;
      ly2 = iy;
   }

   if (lx1 > Bars - 1 || lx2 < 0)
   {
      double a, b;
      getline(lx1, ly1, lx2, ly2, a, b);
      if (lx1 > Bars - 1)
      {
         lx1 = Bars - 1;
      }
      if (lx2 < 0)
      {
         lx2 = 0;
      }
      ly1 = a * lx1 + b;
      ly2 = a * lx2 + b;
   }

   ResetLastError();
   string id = IndicatorObjPrefix + TimeToString(Time[lx1]);
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[lx1], ly1, Time[lx2], ly2))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE1, ly1);
   ObjectSetDouble(0, id, OBJPROP_PRICE2, ly2);
   ObjectSetInteger(0, id, OBJPROP_TIME1, Time[lx1]);
   ObjectSetInteger(0, id, OBJPROP_TIME2, Time[lx2]);
}

void Draw(int period)
{
   int f = 0;
   double hy1 = 0;
   int hx1 = 0;
   double hy2 = 0;
   int hx2 = 0;
   double ly1 = 0;
   int lx1 = 0;
   double ly2 = 0;
   int lx2 = 0;
   for (int i = 0; i < frame; ++i)
   {
      if (upy[period + i] != 0)
      {
         if (hy1 == 0)
         {
            hy1 = upy[period + i];
            hx1 = period + i;
            ++f;
         }
         else if (hy2 == 0)
         {
            hy2 = upy[period + i];
            hx2 = period + i;
            ++f;
         }
      }
      if (downy[period + i] != 0)
      {
         if (ly1 == 0)
         {
            ly1 = downy[period + i];
            lx1 = period + i;
            ++f;
         }
         else if (ly2 == 0)
         {
            ly2 = downy[period + i];
            lx2 = period + i;
            ++f;
         }
      }
      if (f == 4)
      {
         break;
      }
   }

   if (f == 4)
   {
      double a1, a2, b1, b2;
      getline(hx2, hy2, hx1, hy1, a1, b1);
      getline(lx2, ly2, lx1, ly1, a2, b2);
      double ix = 0;
      double iy = 0;
      intersect(a1, b1, a2, b2, ix, iy);
      if (ix == 0)
      {
         return;
      }
      double ls = Distance(lx2, ly2, ix, iy);
      double bs = Distance(hx2, hy2, lx2, ly2);
      double hs = Distance(hx2, hy2, ix, iy);
      if (ls / bs > x || hs / bs > x || bs > ls || bs > hs || ls / hs > y || hs / ls > y
         || (iy < hy1 && iy < ly1 && ix < hx1 && ix < lx1)
         || (iy > hy1 && iy > ly1 && ix < hx1 && ix < lx1)
         || (ix > hx1 && ix > lx1 && iy <= hy1 && iy >= ly1 && !k1)
         || (ix < hx1 && ix < lx1 && iy <= hy1 && iy >= ly1 && !k2)
         || (iy > hy1 && iy > ly1 && ix > hx1 && ix > lx1 && !k5)
         || (iy < hy1 && iy < ly1 && ix > hx1 && ix > lx1 && !k6))
      {
         return;
      }

      drawline(hx2, hy2, hx1, hy1, ix, iy, top_color);
      drawline(lx2, ly2, lx1, ly1, ix, iy, bottom_color);

      if (period == 0)
      {
         signaler.SendNotifications("A new triangle has formed.");
      }
   }
}
