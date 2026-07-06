// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69709

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
//#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

input int rb = 10; // Period for Pivot Points
input int prd = 284; // Loopback Period
input int nump = 2; // S/R strength
input int ChannelW = 10; // Channel Width %
input bool drawhl = true; // Draw Highest/Lowest Pivots in Period
input bool showpp = false; // Show Point Points
input color LineColor = Red; // Line color
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
Signaler* _signaler;
bool ppavailable[40];
datetime lastSignal[40];
double ph[], pl[];
int init()
{
   IndicatorName = GenerateIndicatorName("Support Resistance Dynamic");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   _signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _signaler.SetMessagePrefix(_Symbol + "/" + _signaler.GetTimeframeStr() + ": ");

   IndicatorBuffers(2);
   SetIndexStyle(0, showpp ? DRAW_ARROW : DRAW_NONE, 0, 2);
   SetIndexBuffer(0, ph);
   SetIndexLabel(0, "PH");
   SetIndexArrow(0, 233);

   SetIndexStyle(1, showpp ? DRAW_ARROW : DRAW_NONE, 0, 2);
   SetIndexBuffer(1, pl);
   SetIndexLabel(1, "PL");
   SetIndexArrow(1, 234);

   for (int i = 0; i < 40; ++i)
   {
      ppavailable[i] = true;
   }

   return 0;
}

int deinit()
{
   delete _signaler;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

double pivothigh(int period, int left, int right)
{
   for (int i = 0; i < right; ++i)
   {
      if (High[period + right] <= High[period + i])
      {
         return EMPTY_VALUE;
      }
   }
   for (int i = 0; i < left; ++i)
   {
      if (High[period + right] <= High[period + right + 1 + i])
      {
         return EMPTY_VALUE;
      }
   }
   return High[period + right];
}

double pivotlow(int period, int left, int right)
{
   for (int i = 0; i < right; ++i)
   {
      if (Low[period + right] <= Low[period + i])
      {
         return EMPTY_VALUE;
      }
   }
   for (int i = 0; i < left; ++i)
   {
      if (Low[period + right] <= Low[period + right + 1 + i])
      {
         return EMPTY_VALUE;
      }
   }
   return Low[period + right];
}

double sr[40];

int start()
{
   int minBars = MathMax(prd, rb * 2 + 1);
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      ph[i] = pivothigh(i, rb, rb);
      pl[i] = pivotlow(i, rb, rb);
      if (ph[i] != EMPTY_VALUE || pl[i] != EMPTY_VALUE)
      {
         for (int ii = 0; ii < 40; ++ii)
         {
            sr[ii] = EMPTY_VALUE;
         }
         int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, prd, i);
         double prdhighest = iHigh(_Symbol, _Period, highestIndex);
         int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, prd, i);
         double prdlowest = iLow(_Symbol, _Period, lowestIndex);
         double cwidth = (prdhighest - prdlowest) * ChannelW / 100;
         double highestph = 0.0;
         double lowestpl = 0.0;

         highestph = prdlowest;
         lowestpl = prdhighest;
         int countpp = 0; // keep position of the PP
         for (int x = 0; x <= MathMin(Bars - 1 - minBars - i, prd); ++x)
         {
            if (ph[i + x] != EMPTY_VALUE || pl[i + x] != EMPTY_VALUE)
            {
               highestph = MathMax(MathMax(highestph, ph[i + x] == EMPTY_VALUE ? prdlowest : ph[i + x]), pl[i + x] == EMPTY_VALUE ? prdlowest : pl[i + x]);
               lowestpl = MathMin(MathMin(lowestpl, ph[i + x] == EMPTY_VALUE ? prdhighest : ph[i + x]), pl[i + x] == EMPTY_VALUE ? prdhighest : pl[i + x]);
               countpp = countpp + 1;
               if (ppavailable[countpp])
               {
                  double upl = (ph[i + x] != EMPTY_VALUE ? High[i + x + rb] : Low[i + x + rb]) + cwidth;
                  double dnl = (ph[i + x] != EMPTY_VALUE ? High[i + x + rb] : Low[i + x + rb]) - cwidth;
                  bool t[40];
                  for (int ii = 0; ii < 40; ++ii)
                  {
                     t[ii] = true;
                  }
                  int cnt = 0;
                  int tpoint = 0;
                  for (int xx = 0; xx <= MathMin(Bars - 1 - minBars - i, prd); ++xx)
                  {
                     if (ph[i + xx] != EMPTY_VALUE || pl[i + xx] != EMPTY_VALUE)
                     {
                        cnt = cnt + 1;
                        if (ppavailable[cnt])
                        {
                           if (ph[i + xx] != EMPTY_VALUE)
                           {
                              if (High[i + xx + rb] <= upl && High[i + xx + rb] >= dnl)
                              {
                                 tpoint = tpoint + 1;
                                 t[cnt] = false;
                              }
                           }  
                           if (pl[i + xx] != EMPTY_VALUE)
                           {
                              if (Low[i + xx + rb] <= upl && Low[i + xx + rb] >= dnl)
                              {
                                 tpoint = tpoint + 1;
                                 t[cnt] = false;
                              }
                           }
                        }
                     }
                  }
                  if (tpoint >= nump)
                  {
                     sr[countpp] = ph[i + x] == EMPTY_VALUE ? High[i + x + rb] : Low[i + x + rb];
                  }
               }
            }
         }
         if (drawhl)
         {
            ResetLastError();
            string id = IndicatorObjPrefix + "h";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[i + prd], highestph, Time[i], highestph))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
                  continue;
               }
               ObjectSetInteger(0, id, OBJPROP_COLOR, Blue);
               ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
               ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
            }
            ObjectSetDouble(0, id, OBJPROP_PRICE1, highestph);
            ObjectSetDouble(0, id, OBJPROP_PRICE2, highestph);
            ObjectSetInteger(0, id, OBJPROP_TIME1, Time[i + prd]);
            ObjectSetInteger(0, id, OBJPROP_TIME2, Time[i]);
            string lblId = IndicatorObjPrefix + "hl";
            if (ObjectFind(0, lblId) == -1)
            {
               if (!ObjectCreate(0, lblId, OBJ_TEXT, 0, Time[i], highestph))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
                  continue;
               }
               ObjectSetString(0, lblId, OBJPROP_FONT, "Arial");
               ObjectSetInteger(0, lblId, OBJPROP_FONTSIZE, 10);
               ObjectSetInteger(0, lblId, OBJPROP_COLOR, Silver);
               ObjectSetInteger(0, lblId, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
            }
            ObjectSetInteger(0, lblId, OBJPROP_TIME, Time[i]);
            ObjectSetDouble(0, lblId, OBJPROP_PRICE1, highestph);
            ObjectSetString(0, lblId, OBJPROP_TEXT, DoubleToString(highestph, Digits));
            id = IndicatorObjPrefix + "l";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[i + prd], lowestpl, Time[i], lowestpl))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
                  continue;
               }
               ObjectSetInteger(0, id, OBJPROP_COLOR, Blue);
               ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
               ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
            }
            ObjectSetDouble(0, id, OBJPROP_PRICE1, lowestpl);
            ObjectSetDouble(0, id, OBJPROP_PRICE2, lowestpl);
            ObjectSetInteger(0, id, OBJPROP_TIME1, Time[i + prd]);
            ObjectSetInteger(0, id, OBJPROP_TIME2, Time[i]);
            lblId = IndicatorObjPrefix + "l";
            if (ObjectFind(0, lblId) == -1)
            {
               if (!ObjectCreate(0, lblId, OBJ_TEXT, 0, Time[i], lowestpl))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
                  continue;
               }
               ObjectSetString(0, lblId, OBJPROP_FONT, "Arial");
               ObjectSetInteger(0, lblId, OBJPROP_FONTSIZE, 10);
               ObjectSetInteger(0, lblId, OBJPROP_COLOR, Silver);
               ObjectSetInteger(0, lblId, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
            }
            ObjectSetInteger(0, lblId, OBJPROP_TIME, Time[i]);
            ObjectSetDouble(0, lblId, OBJPROP_PRICE1, lowestpl);
            ObjectSetString(0, lblId, OBJPROP_TEXT, DoubleToString(lowestpl, Digits));
         }
         for (int ii = 0; ii < 40; ++ii)
         {
            if (sr[ii] != EMPTY_VALUE)
            {
               setline(ii, i, sr[ii]);
            }
         }
      }
   }
   for (int i = 0; i < 40; ++i)
   {
      if (sr[i] != EMPTY_VALUE && lastSignal[i] != Time[0] && ((Close[0] > sr[i] && Close[1] < sr[i]) || (Close[0] < sr[i] && Close[1] > sr[i])))
      {
         _signaler.SendNotifications(DoubleToString(sr[i]) + " level touched");
         lastSignal[i] = Time[0];
      }
   }
   return 0;
}

void setline(int i, int pos, double level)
{
   ResetLastError();
   string id = IndicatorObjPrefix + IntegerToString(i);
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[pos + prd], level, Time[pos], level))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, LineColor);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, true);
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE1, level);
   ObjectSetDouble(0, id, OBJPROP_PRICE2, level);
   ObjectSetInteger(0, id, OBJPROP_TIME1, Time[pos + prd]);
   ObjectSetInteger(0, id, OBJPROP_TIME2, Time[pos]);

   ResetLastError();
   string lblId = IndicatorObjPrefix + IntegerToString(i) + "l";
   if (ObjectFind(0, lblId) == -1)
   {
      if (!ObjectCreate(0, lblId, OBJ_TEXT, 0, Time[pos], level))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetString(0, lblId, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, lblId, OBJPROP_FONTSIZE, 10);
      ObjectSetInteger(0, lblId, OBJPROP_COLOR, Lime);
      ObjectSetInteger(0, lblId, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   }
   ObjectSetInteger(0, lblId, OBJPROP_TIME, Time[pos]);
   ObjectSetDouble(0, lblId, OBJPROP_PRICE1, level);
   ObjectSetString(0, lblId, OBJPROP_TEXT, DoubleToString(level, Digits));
}
