// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70094
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
#property link "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_level1 80
#property indicator_level2 70
#property indicator_level3 30
#property indicator_level4 20
#property indicator_level5 50
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor DarkGray
#property indicator_buffers 10
#property indicator_plots 3
#property indicator_color1 Chartreuse
#property indicator_color2 Red
#property indicator_color3 Gold
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2

//input ENUM_TIMEFRAMES timeFrame = PERIOD_CURRENT; // Timeframe
input int Osc = 29; /*1=Accelerator/Decelerator, 2=Accumulation/Distribution,
                                 3=Average Directional Movement Index, 4=Average True Range,
                                 5=Awesome oscillator, 6=Bears Power, 7=Bulls Power,
                                 8=Commodity Channel Index, 9=DeMarker, 10=Force Index,
                                 11=Momentum, 12=Money Flow Index, 13=Moving Averages Convergence/Divergence,
                                 14=Moving Average of Oscillator, 15=On Balance Volume,
                                 16=Relative Vigor Index, 17=Standard Deviation,
                                 18=Stochastic Oscillator, 19=Volume,
                                 20=Close, 21=Open, 22=High, 23=Low,
                                 24=(H+L)/2, 25=(H+L+C)/3, 26=(H+L+C+C)/4, 27=(O+C+H+L)/4, 28=(O+C)/2,
                                 29=Relative Strength Index, 30=RBCI, 31=FTLM, 32=STLM, 33=JRSX,34=Relative Strength Index,
                                 //35=ZUP_RSI_v48,
                                 35=Williams' Percent Range,
                                 other=RBCI;*/

input bool TH = true;
input bool TL = true;

input bool trend = true;
input bool convergen = true;
input int Complect = 1;
int Complect10 = 10;
int Complect20 = 20;
int Complect30 = 30;
int Complect40 = 40;
int Complect50 = 50;
int Complect60 = 60;
int Complect70 = 70;
int Complect80 = 80;

int BackSteph, BackStepl;
int qSteps;
input int _BackSteph = 0; // êîëè÷åñòâî øàãîâ íàçàä h
input int _BackStepl = 0; // êîëè÷åñòâî øàãîâ íàçàä l
input int BackStep = 0;   // êîëè÷åñòâî øàãîâ íàçàä
input int _qSteps = 1;    // êîëè÷åñòâî îòîáðàæàåìûõ øàãîâ, íå áîëåå 3õ

input int LevDPl = 5; // óðîâåíü òî÷åê äåìàðêà; 2 = öåíòðàëüíûé áàð áóäåò âûøå(íèæå) 2õ áàðîâ ñëåâà
input int LevDPr = 1; // óðîâåíü òî÷åê äåìàðêà; 2 = öåíòðàëüíûé áàð áóäåò âûøå(íèæå) 2õ áàðîâ ñïðàâà
input int period = 8;
input ENUM_MA_METHOD ma_method = MODE_SMA; // Smoothing method
input int ma_shift = 0;
input int applied_price = 4;
input int mode = 0;
input int fast_ema_period = 12;
input int slow_ema_period = 26;
input int signal_period = 9;
input int Kperiod = 13;
input int Dperiod = 5;
input int slowing = 3;

input ENUM_STO_PRICE price_field = 0;
input int T3_Period = 1;
input double b = 0.7;
input int _showBars = 1000; // If = 0, then the indicator is displayed for all graphics
int showBars;

input bool LeftStrong = false;
input bool RightStrong = true;
input bool Anti = true;
input bool Trend_Down = true;
input bool Trend_Up = true;

input bool TrendLine = true; // false = trend lines will not
input bool HandyColour = true;
input color Highline = Red;
input color Lowline = DeepSkyBlue;
input bool ChannelLine = true; // true = build a parallel trend lines feeds
input int Trend = 0;           // 1 = only for UpTrendLines, -1 = only for DownTrendLines, 0 = for all TrendLines
input bool Channel = false;
input bool Regression = false;
input bool RayH = true;
input bool RayL = true;
input color ChannelH = Red;
input color ChannelL = DeepSkyBlue;
input double STDwidthH = 1.0;
input double STDwidthL = 1.0;
input int Back = -1;
input int code_buy = 159;
input int code_sell = 159;
input int bars_limit = 1000; // Bars limit
input string AlertsSection = "";       // == Alerts ==
input bool popup_alert = false;        // Popup message
input bool notification_alert = false; // Push notification
input bool email_alert = false;        // Email
input bool play_sound = false;         // Play sound on alert
input string sound_file = "";          // Sound file
input bool start_program = false;      // Start inputal program
input string program_path = "";        // Path to the inputal program executable
input bool advanced_alert = false;     // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string advanced_key = "";        // Advanced alert key
input string Comment2 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string Comment3 = "- Allow use of dll in the indicator parameters window -";
input string Comment4 = "- Install AdvancedNotificationsLib.dll -";
input int SIGNAL_BAR = 1;

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

double c1, c2, c3, c4, w1, w2, b2, b3;

//---- buffers
double Oscil[], t3_Oscil[];
double Buf1[];
double Buf2[];
//----
string Col[] = {"Êðàñíàÿ", "Ñèíÿÿ", "Ðîçîâàÿ", "Ãîëóáàÿ", "Êîðè÷íåâàÿ", "Ñàëàòíàÿ"};
int ColNum[] = {Red, DeepSkyBlue, Coral, Aqua, SaddleBrown, MediumSeaGreen};
int qPoint = 0; // ïåðåìåííàÿ äëÿ íîðìàëèçàöèè öåíû
double qTime = 0; // ïåðåìåííûå äëÿ ëèêâèäàöèè ãëþêîâ ïðè çàãðóçêå
string indicatorFileName;
double e1[], e2[], e3[], e4[], e5[], e6[];

Signaler* signaler;

datetime last_buy_date;
datetime last_sell_date;

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
int indi;
void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("diverg");
   IndicatorSetString(INDICATOR_SHORTNAME, "Diverg");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   BackSteph = _BackSteph;
   BackStepl = _BackStepl;
   if (BackStep > 0)
   {
      BackSteph = BackStep;
      BackStepl = BackStep;
   }
   qSteps = MathMin(3, _qSteps);
   while (NormalizeDouble(Point(), qPoint) == 0)
      qPoint++;
   string Rem = "";
   int id = 0;
   SetIndexBuffer(id, t3_Oscil, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   ++id;

   SetIndexBuffer(id, Buf1, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, code_buy);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   PlotIndexSetDouble(id, PLOT_EMPTY_VALUE, 0.0);
   ++id;
   SetIndexBuffer(id, Buf2, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(id, PLOT_ARROW, code_sell);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   PlotIndexSetDouble(id, PLOT_EMPTY_VALUE, 0.0);
   ++id;

   SetIndexBuffer(id++, Oscil, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, e1, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, e2, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, e3, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, e4, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, e5, INDICATOR_CALCULATIONS);
   SetIndexBuffer(id++, e6, INDICATOR_CALCULATIONS);

   indicatorFileName = "diverg";
   switch (Osc)
   {
   case 1:
      indi = iAC(NULL, 0);
      break;
   case 2:
      indi = iAD(NULL, 0, VOLUME_TICK);
      break;
   case 3:
      indi = iADX(NULL, 0, period);
      break;
   case 4:
      indi = iATR(NULL, 0, period);
      break;
   case 5:
      indi = iAO(NULL, 0);
      break;
   case 6:
      indi = iBearsPower(NULL, 0, period);
      break;
   case 7:
      indi = iBullsPower(NULL, 0, period);
      break;
   case 8:
      indi = iCCI(NULL, 0, period, applied_price);
      break;
   case 9:
      indi = iDeMarker(NULL, 0, period);
      break;
   case 10:
      indi = iForce(NULL, 0, period, ma_method, VOLUME_TICK);
      break;
   case 11:
      indi = iMomentum(NULL, 0, period, applied_price);
      break;
   case 12:
      indi = iMFI(NULL, 0, period, VOLUME_TICK);
      break;
   case 13:
      indi = iMACD(NULL, 0, fast_ema_period, slow_ema_period, signal_period, applied_price);
      break;
   case 14:
      indi = iOsMA(NULL, 0, fast_ema_period, slow_ema_period, signal_period, applied_price);
      break;
   case 15:
      indi = iOBV(NULL, 0, VOLUME_TICK);
      break;
   case 16:
      indi = iRVI(NULL, 0, period);
      break;
   case 17:
      indi = iStdDev(NULL, 0, period, ma_shift, ma_method, applied_price);
      break;
   case 18:
      indi = iStochastic(NULL, 0, Kperiod, Dperiod, slowing, ma_method, price_field);
      break;
   case 19:
   case 20:
   case 21:
   case 22:
   case 23:
   case 24:
   case 25:
   case 26:
   case 27:
   case 28:
      break;
   case 29:
      indi = iRSI(NULL, 0, period, applied_price);
      break;
   case 30:
      indi = iCustom(NULL, 0, "RBCI Petr2");
      break;
   case 31:
      indi = iCustom(NULL, 0, "FTLM Petr2");
      break;
   case 32:
      indi = iCustom(NULL, 0, "STLM Petr2");
      break;
   case 33:
      indi = iCustom(NULL, 0, "JRSX Diver");
      break;
   case 34:
      indi = iRSI(NULL, 0, period, applied_price);
      break;
   case 35:
      indi = iCustom(NULL, 0, "Dynamic Cycle Explorer - simple");
      break;
   default:
      indi = iCustom(NULL, 0, "RBCI");
      break;
   }
   b2 = b * b;
   b3 = b2 * b;
   c1 = -b3;
   c2 = (3 * (b2 + b3));
   c3 = -3 * (2 * b2 + b + b3);
   c4 = (1 + 3 * b + b3 + 3 * b2);
   int n = 1 + 0.5 * (T3_Period - 1);
   w1 = 2 / (n + 1);
   w2 = 1 - w1;
   showBars = _showBars;
   //selfIndi = iCustom(NULL, timeFrame, indicatorFileName, "", Osc, TH, TL, trend, convergen, Complect, BackSteph, BackStepl, BackStep, qSteps, LevDPl, LevDPr, period, ma_method, ma_shift, applied_price, mode, fast_ema_period, slow_ema_period, signal_period, Kperiod, Dperiod, slowing, price_field, T3_Period, b, showBars, LeftStrong, RightStrong, Anti, Trend_Down, Trend_Up, TrendLine, HandyColour, Highline, Lowline, ChannelLine, Trend, Channel, Regression, RayH, RayL, ChannelH, ChannelL, STDwidthH, STDwidthL, Back);
   rsi = iRSI(NULL, 0, period, applied_price);
}

int selfIndi;
int rsi;

void OnDeinit(const int reason)
{
   IndicatorRelease(selfIndi);
   IndicatorRelease(indi);
   IndicatorRelease(rsi);
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

double CalcBuf1(int pos)
{
   if (LevDPl != 0)
   {
      for (int i = LevDPl, j = LevDPr; i > 0; i--, j--)
      {
         if (t3_Oscil[pos - i] > t3_Oscil[pos] || (t3_Oscil[pos - i] == t3_Oscil[pos] && LeftStrong))
            return 0;
         if (j > 0)
         {
            if (t3_Oscil[pos + j] > t3_Oscil[pos] || (RightStrong && t3_Oscil[pos + j] == t3_Oscil[pos]))
               return 0;
         }
      }
      return t3_Oscil[pos];
   }
   for (int j = LevDPr; j > 0; j--)
   {
      if (t3_Oscil[pos + j] > t3_Oscil[pos] || RightStrong && t3_Oscil[pos + j] == t3_Oscil[pos])
      {
         return 0;
      }
   }
   return t3_Oscil[pos];
}

double CalcBuf2(int pos)
{
   if (LevDPl != 0)
   {
      for (int i = LevDPl, j = LevDPr; i > 0; i--, j--)
      {
         if (t3_Oscil[pos - i] < t3_Oscil[pos] || (t3_Oscil[pos - i] == t3_Oscil[pos] && LeftStrong))
            return 0;
         if (j > 0)
         {
            if (t3_Oscil[pos + j] < t3_Oscil[pos] || (RightStrong && t3_Oscil[pos + j] == t3_Oscil[pos]))
               return 0;
         }
      }
      return t3_Oscil[pos];
   }
   for (int j = LevDPr; j > 0; j--)
   {
      if (t3_Oscil[pos + j] < t3_Oscil[pos] || RightStrong && t3_Oscil[pos + j] == t3_Oscil[pos])
      {
         return 0;
      }
   }
   return t3_Oscil[pos];
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
      ArrayInitialize(Buf1, 0);
      ArrayInitialize(Buf2, 0);
   }
   int first = LevDPl;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      // if (timeFrame != Period() && timeFrame != PERIOD_CURRENT)
      // {
      //    int y = iBarShift(NULL, timeFrame, time[pos]);
      //    double buffer[1];
      //    if (CopyBuffer(selfIndi, 0, y, 1, buffer) != 1)
      //    {
      //       continue;
      //    }
      //    t3_Oscil[pos] = buffer[0];
      // }
      // else
      {
         switch (Osc)
         {
         case 1:
         case 5:
         case 6:
         case 7:
         case 13:
         case 14:
         case 16:
            {
               double buffer[1];
               if (CopyBuffer(indi, mode, oldPos, 1, buffer) != 1)
               {
                  continue;
               }
               Oscil[pos] = buffer[0] + 1;
            }
            break;
         case 2:
         case 3:
         case 4:
         case 9:
         case 11:
         case 12:
         case 17:
         case 18:
         case 29:
         case 30:
         case 31:
         case 32:
         case 33:
         case 34:
         case 35:
         default:
            {
               double buffer[1];
               if (CopyBuffer(indi, mode, oldPos, 1, buffer) != 1)
               {
                  continue;
               }
               Oscil[pos] = buffer[0];
            }
            break;
         case 8:
            {
               double buffer[1];
               if (CopyBuffer(indi, mode, oldPos, 1, buffer) != 1)
               {
                  continue;
               }
               Oscil[pos] = buffer[0] + 1000;
            }
            break;
         case 10:
            {
               double buffer[1];
               if (CopyBuffer(indi, mode, oldPos, 1, buffer) != 1)
               {
                  continue;
               }
               Oscil[pos] = buffer[0] + 100;
            }
            break;
         case 15:
            {
               double buffer[1];
               if (CopyBuffer(indi, mode, oldPos, 1, buffer) != 1)
               {
                  continue;
               }
               Oscil[pos] = buffer[0] / 10000000 + 100;
            }
            break;
         case 19:
            Oscil[pos] = tick_volume[rates_total - 1];
            break;
         case 20:
            Oscil[pos] = close[rates_total - 1];
            break;
         case 21:
            Oscil[pos] = open[rates_total - 1];
            break;
         case 22:
            Oscil[pos] = high[rates_total - 1];
            break;
         case 23:
            Oscil[pos] = low[rates_total - 1];
            break;
         case 24:
            Oscil[pos] = (high[rates_total - 1] + low[rates_total - 1]) / 2;
            break;
         case 25:
            Oscil[pos] = (high[rates_total - 1] + low[rates_total - 1] + close[rates_total - 1]) / 3;
            break;
         case 26:
            Oscil[pos] = (high[rates_total - 1] + low[rates_total - 1] + close[rates_total - 1] + close[rates_total - 1]) / 4;
            break;
         case 27:
            Oscil[pos] = (open[rates_total - 1] + close[rates_total - 1] + high[rates_total - 1] + low[rates_total - 1]) / 4;
            break;
         case 28:
            Oscil[pos] = (open[rates_total - 1] + close[rates_total - 1]) / 2;
            break;
         }
         //+---+============================================+
         e1[pos] = w1 * Oscil[pos] + w2 * e1[pos - 1];
         e2[pos] = w1 * e1[pos] + w2 * e2[pos - 1];
         e3[pos] = w1 * e2[pos] + w2 * e3[pos - 1];
         e4[pos] = w1 * e3[pos] + w2 * e4[pos - 1];
         e5[pos] = w1 * e4[pos] + w2 * e5[pos - 1];
         e6[pos] = w1 * e5[pos] + w2 * e6[pos - 1];
         t3_Oscil[pos] = c1 * e6[pos] + c2 * e5[pos] + c3 * e4[pos] + c4 * e3[pos];
      }
   }
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1 - LevDPr)); pos < rates_total - LevDPr; ++pos)
   {
      Buf1[pos] = CalcBuf1(pos);
      Buf2[pos] = CalcBuf2(pos);
   }
   string Comm;
   for (int pos = 1; pos <= qSteps; pos++)
      Comm = Comm + TDMain(pos, time, open, high, low, close, rates_total);

   double buffer[2];
   if (CopyBuffer(rsi, 0, rates_total - 1 - SIGNAL_BAR, 2, buffer) != 2)
   {
      return rates_total;
   }
   double rsi0 = buffer[0];
   double rsi1 = buffer[1];
   double y0 = ObjectGetDouble(0, l_id, OBJPROP_PRICE, 0);
   double y1 = ObjectGetDouble(0, l_id, OBJPROP_PRICE, 1);
   double x0 = ObjectGetInteger(0, l_id, OBJPROP_TIME, 0);
   double x1 = ObjectGetInteger(0, l_id, OBJPROP_TIME, 1);
   if (y0 > 0 && y1 > 0 && x0 > 0 && x1 > 0)
   {
      double d1 = (y0 - y1) * time[rates_total - 1 - SIGNAL_BAR] + (x1 - x0) * rsi0 + (x0 * y1 - x1 * y0);
      double d2 = (y0 - y1) * time[rates_total - 1 - SIGNAL_BAR - 1] + (x1 - x0) * rsi1 + (x0 * y1 - x1 * y0);
      double d = d1 * d2;
      if ((d < 0 || d1 == 0) && last_buy_date != x0)
      {
         string symbol = _Symbol;
         signaler.SendNotifications(StringConcatenate(symbol, " - BUY  - ", Period(), " - ", TimeToString(TimeLocal(), TIME_SECONDS)));
         last_buy_date = x0;
      } 
   }
   
   y0 = ObjectGetDouble(0, h_id, OBJPROP_PRICE, 0);
   y1 = ObjectGetDouble(0, h_id, OBJPROP_PRICE, 1);
   x0 = ObjectGetInteger(0, h_id, OBJPROP_TIME, 0);
   x1 = ObjectGetInteger(0, h_id, OBJPROP_TIME, 1);
   if (y0 > 0 && y1 > 0 && x0 > 0 && x1 > 0)
   {
      double d1 = (y0 - y1) * time[rates_total - 1 - SIGNAL_BAR] + (x1 - x0) * rsi0 + (x0 * y1 - x1 * y0);
      double d2 = (y0 - y1) * time[rates_total - 1 - SIGNAL_BAR - 1] + (x1 - x0) * rsi1 + (x0 * y1 - x1 * y0);
      double d = d1 * d2;
      if ((d < 0 || d1 == 0) && last_sell_date != x0)
      {
         string symbol = _Symbol;
         signaler.SendNotifications(StringConcatenate(symbol, " - SELL  - ", Period(), " - ", TimeToString(TimeLocal(), TIME_SECONDS)));
         last_sell_date = x0;
      } 
   }

   return rates_total;
}

void CreateTrend(string id, int period1, int period2, color clr, int width, bool trace = true)
{
   ObjectCreate(0, id, OBJ_TREND, ChartWindowFind(), 0, 0, 0, 0);
   ObjectSetInteger(0, id, OBJPROP_TIME, 0, iTime(_Symbol, _Period, iBars(_Symbol, _Period) - 1 - period1));
   ObjectSetInteger(0, id, OBJPROP_TIME, 1, iTime(_Symbol, _Period, iBars(_Symbol, _Period) - 1 - period2));
   ObjectSetDouble(0, id, OBJPROP_PRICE, 0, t3_Oscil[period1]);
   ObjectSetDouble(0, id, OBJPROP_PRICE, 1, t3_Oscil[period2]);
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, id, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, trace);
}

bool HConditionConv(int &H[], int count, const double& high[])
{
   if (H[count - 1] < 0)
   {
      return false;
   }
   for (int i = 1; i < count - 1; ++i)
   {
      if (Oscil[H[i]] >= Oscil[H[0]]
         || high[H[i]] >= high[H[0]] 
         || high[H[count - 1]] <= high[H[i]] 
         || Oscil[H[count - 1]] <= Oscil[H[i]] 
         )
      {
         return false;
      }
   }
   return Oscil[H[count - 1]] < Oscil[H[0]] && high[H[count - 1]] > high[H[0]];
}

bool HCondition(int &H[], int count, const double& high[])
{
   if (H[count - 1] < 0)
   {
      return false;
   }
   for (int i = 1; i < count - 1; ++i)
   {
      if (Oscil[H[i]] >= Oscil[H[0]]
         || high[H[i]] >= high[H[0]] 
         || high[H[count - 1]] <= high[H[i]] 
         )
      {
         return false;
      }
   }
   return Oscil[H[count - 1]] > Oscil[H[0]] && high[H[count - 1]] < high[H[0]];
}

bool LConditionConv(int &L[], int count, const double& low[])
{
   if (L[count - 1] < 0)
   {
      return false;
   }
   for (int i = 1; i < count - 1; ++i)
   {
      if (Oscil[L[i]] <= Oscil[L[0]]
         || low[L[i]] <= low[L[0]] 
         || low[L[count - 1]] <= low[L[i]] 
         || Oscil[L[count - 1]] <= Oscil[L[i]] 
         )
      {
         return false;
      }
   }
   return Oscil[L[count - 1]] > Oscil[L[0]] && low[L[count - 1]] < low[L[0]];
}

bool LCondition(int& L[], int count, const double& low[])
{
   if (L[count - 1] < 0)
   {
      return false;
   }
   for (int i = 1; i < count - 1; ++i)
   {
      if (Oscil[L[i]] <= Oscil[L[0]]
         || low[L[i]] <= low[L[0]] 
         || low[L[count - 1]] >= low[L[i]] 
         )
      {
         return false;
      }
   }
   return Oscil[L[count - 1]] < Oscil[L[0]] && low[L[count - 1]] > low[L[0]];
}

void DoLConditions(int& L[], int count, string id, const double& low[])
{
   if (TrendLine && LCondition(L, count, low)) // ñîáñòâåííî diver
   {
      CreateTrend(id, L[count - 1], L[0], Red, 2, false);
   }
   else if (convergen == true && TrendLine && LConditionConv(L, count, low))
   {
      CreateTrend(id, L[count - 1], L[0], Gold, 2, false);
   }
   else
      ObjectDelete(0, id);
}
void DoHConditions(int& H[], int count, string id, const double& high[])
{
   if (TrendLine && HCondition(H, count, high)) // ñîáñòâåííî diver
   {
      CreateTrend(id, H[count - 1], H[0], Red, 2, false);
   }
   else if (convergen == true && TrendLine && HConditionConv(H, count, high))
   {
      CreateTrend(id, H[count - 1], H[0], Gold, 2, false);
   }
   else
      ObjectDelete(0, id);
}

string TDMain(int Step, 
            const datetime &time[],
               const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                int rates_total)
{
   int L[14];
   string Comm = "»—»—» Øàã " + Step + " èç " + qSteps + " (BackStep " + BackStep + ")\n", Rem, Rem1, Rem2, Rem3, Rem4, Rem5, Rem6, Rem7, Rem8;
   double Complect1, Complect2, Complect3, Complect4, Complect5, Complect6, Complect7, Complect8;
   if (Complect > 0)
   {
      Complect1 = Complect + Complect10;
      Complect2 = Complect + Complect20;
      Complect3 = Complect + Complect30;
      Complect4 = Complect + Complect40;
      Complect5 = Complect + Complect50;
      Complect6 = Complect + Complect60;
      Complect7 = Complect + Complect70;
      Complect8 = Complect + Complect80;
   }
   int col;
   if (Trend <= 0)
   {
      Comm = Comm + "» " + Col[Step * 2 - 2] + " DownTrendLine ";
      if (HandyColour)
         col = Highline;
      else
         col = ColNum[Step * 2 - 2];
      int H[14];
      H[0] = GetTD(rates_total - 1, Buf1, Step);
      for (int i = 1; i < 14; ++i)
      {
         H[i] = GetNextHighTD(H[i - 1]);
      }

      int n, sn;
      int qExt = H[0] - 1;
      for (n = 1; qExt < rates_total && n < H[0] - H[1] - 1; n++)
      {
         sn = H[0] - 1 - n;
         if (sn < 0)
         {
            break;
         }
         if (t3_Oscil[qExt] >= t3_Oscil[sn])
            qExt = sn;
      }

      Comm = Comm + "\n";
      Rem = IndicatorObjPrefix + "HL(" + DoubleToString(Complect) + ")_" + Step;
      Rem1 = IndicatorObjPrefix + "HL(" + DoubleToString(Complect8) + ")_" + Step;
      Rem2 = IndicatorObjPrefix + "HL(" + DoubleToString(Complect1) + ")_" + Step;
      Rem3 = IndicatorObjPrefix + "HL(" + DoubleToString(Complect2) + ")_" + Step;
      Rem4 = IndicatorObjPrefix + "HL(" + DoubleToString(Complect3) + ")_" + Step;
      Rem5 = IndicatorObjPrefix + "HL(" + DoubleToString(Complect4) + ")_" + Step;
      Rem6 = IndicatorObjPrefix + "HL(" + DoubleToString(Complect5) + ")_" + Step;
      Rem7 = IndicatorObjPrefix + "HL(" + DoubleToString(Complect6) + ")_" + Step;
      Rem8 = IndicatorObjPrefix + "HL(" + DoubleToString(Complect7) + ")_" + Step;
      bool created = false;
      bool firstHighest = true;
      if (trend)
      {
         for (int i = 1; i < 13; ++i)
         {
            if (H[i] < 0)
            {
               continue;
            }
            if (Oscil[H[i]] > Oscil[H[0]]) // ñîáñòâåííî ëèíèÿ òðåíäà
            {
               CreateTrend(Rem, H[i], H[0], SkyBlue, 3 - MathMax(4, Step));
               created = true;
               break;
            }
            else
            {
               firstHighest = false;
            }
         }
      }
      if (!created)
      {
         if (trend == true && firstHighest)
         {
            CreateTrend(Rem, H[0], H[0], SkyBlue, 3 - MathMax(4, Step));
         }
         else
            ObjectDelete(0, Rem);
      }

      DoHConditions(H, 2, Rem1, high);
      DoHConditions(H, 3, Rem2, high);
      DoHConditions(H, 4, Rem3, high);
      DoHConditions(H, 5, Rem4, high);
      DoHConditions(H, 6, Rem5, high);
      DoHConditions(H, 7, Rem6, high);
      DoHConditions(H, 8, Rem7, high);

      int count = 9;
      if (TrendLine && TH == true && HCondition(H, 9, high))
      {
         CreateTrend(Rem8, H[8], H[0], Red, 2, false);
      }
      else
         ObjectDelete(0, Rem8);

      if (Trend_Down == false)
         ObjectDelete(0, Rem);

      h_id = IndicatorObjPrefix + "HCL(" + Complect + ")_" + Step; // ëèíèÿ êàíàëà
      if (ChannelLine)
      {
         ObjectCreate(0, h_id, OBJ_TREND, ChartWindowFind(), 0, 0, 0, 0);
         ObjectSetInteger(0, h_id, OBJPROP_TIME, 0, time[qExt]);
         ObjectSetInteger(0, h_id, OBJPROP_TIME, 1, time[rates_total - 1]);
         ObjectSetDouble(0, h_id, OBJPROP_PRICE, 0, t3_Oscil[qExt]);
         double qTL = 0;
         if ((H[1] - H[0]) != 0 && H[1] > 0)
            qTL = (t3_Oscil[H[1]] - t3_Oscil[H[0]]) / (H[0] - H[1]);
         ObjectSetDouble(0, h_id, OBJPROP_PRICE, 1, t3_Oscil[qExt] - qTL * (rates_total - 1 - qExt));
         ObjectSetInteger(0, h_id, OBJPROP_COLOR, col);
         ObjectSetInteger(0, h_id, OBJPROP_RAY_RIGHT, true);
      }
      else
         ObjectDelete(0, h_id);
      if (HandyColour)
         col = ChannelH;
      else
         col = ColNum[Step * 2 - 2];
      Rem = IndicatorObjPrefix + "CHAh(" + Complect + ")_" + Step;
      if (Channel)
      {
         if (Regression)
         {
            ObjectCreate(0, Rem, OBJ_REGRESSION, ChartWindowFind(), time[H[1]], t3_Oscil[H[1]], time[H[0]], t3_Oscil[H[0]]);
            ObjectSetInteger(0, Rem, OBJPROP_COLOR, col);
            ObjectSetInteger(0, Rem, OBJPROP_RAY_RIGHT, RayH);
         }
         else
         {
            ObjectCreate(0, Rem, OBJ_STDDEVCHANNEL, ChartWindowFind(), time[H[1]], t3_Oscil[H[1]], time[H[0]], t3_Oscil[H[0]]);
            ObjectSetDouble(0, Rem, OBJPROP_DEVIATION, STDwidthH);
            ObjectSetInteger(0, Rem, OBJPROP_COLOR, col);
            ObjectSetInteger(0, Rem, OBJPROP_RAY_RIGHT, RayH);
         }
      }
      else
         ObjectDelete(0, Rem);
      return Comm;
   }

   Comm = Comm + "» " + Col[Step * 2 - 1] + " UpTrendLine ";
   if (HandyColour)
      col = Lowline;
   else
      col = ColNum[Step * 2 - 1];
   L[0] = GetTD(rates_total - 1, Buf2, Step);
   for (int i = 1; i < 14; ++i)
   {
      L[i] = GetNextLowTD(L[i - 1]);
   }

   int qExt = L[0] - 1;
   for (int n = 1; qExt < rates_total && n < L[0] - L[1] - 1; n++)
   {
      int sn = L[0] - 1 - n;
      if (sn < 0)
      {
         break;
      }
      if (t3_Oscil[qExt] <= t3_Oscil[sn])
         qExt = sn;
   }
   Comm = Comm + "\n";
   Rem = IndicatorObjPrefix + "LL(" + DoubleToString(Complect) + ")_" + Step;
   Rem1 = IndicatorObjPrefix + "LL(" + DoubleToString(Complect8) + ")_" + Step;
   Rem2 = IndicatorObjPrefix + "LL(" + DoubleToString(Complect1) + ")_" + Step;
   Rem3 = IndicatorObjPrefix + "LL(" + DoubleToString(Complect2) + ")_" + Step;
   Rem4 = IndicatorObjPrefix + "LL(" + DoubleToString(Complect3) + ")_" + Step;
   Rem5 = IndicatorObjPrefix + "LL(" + DoubleToString(Complect4) + ")_" + Step;
   Rem6 = IndicatorObjPrefix + "LL(" + DoubleToString(Complect5) + ")_" + Step;
   Rem7 = IndicatorObjPrefix + "LL(" + DoubleToString(Complect6) + ")_" + Step;
   Rem8 = IndicatorObjPrefix + "LL(" + DoubleToString(Complect7) + ")_" + Step;

   bool created = false;
   bool firstLowest = true;
   if (trend)
   {
      for (int i = 1; i < 13; ++i)
      {
         if (L[i] < 0)
         {
            continue;
         }
         if (Oscil[L[i]] < Oscil[L[0]]) // ñîáñòâåííî ëèíèÿ òðåíäà
         {
            CreateTrend(Rem, L[i], L[0], SkyBlue, 3 - MathMax(4, Step));
            created = true;
            break;
         }
         else
         {
            firstLowest = false;
         }
      }
   }
   if (!created)
   {
      if (trend == true && firstLowest)
      {
         CreateTrend(Rem, L[0], L[0], SkyBlue, 3 - MathMax(4, Step));
      }
      else
         ObjectDelete(0, Rem);
   }

   DoLConditions(L, 2, Rem1, low);
   DoLConditions(L, 3, Rem2, low);
   DoLConditions(L, 4, Rem3, low);
   DoLConditions(L, 5, Rem4, low);
   DoLConditions(L, 6, Rem5, low);
   DoLConditions(L, 7, Rem6, low);
   DoLConditions(L, 8, Rem7, low);
   
   if (TrendLine && TL == true && LCondition(L, 9, low))
   {
      CreateTrend(Rem8, L[8], L[0], Red, 2, false);
   }
   else
      ObjectDelete(0, Rem8);

   //////////////////////////

   if (Trend_Up == false)
      ObjectDelete(0, Rem);

   l_id = IndicatorObjPrefix + "LCL(" + Complect + ")_" + Step; // ëèíèÿ êàíàëà

   if (ChannelLine)
   {
      ObjectCreate(0, l_id, OBJ_TREND, ChartWindowFind(), 0, 0, 0, 0);
      ObjectSetInteger(0, l_id, OBJPROP_TIME, 0, time[qExt]);
      ObjectSetInteger(0, l_id, OBJPROP_TIME, 1, time[rates_total - 1]);
      ObjectSetDouble(0, l_id, OBJPROP_PRICE, 0, t3_Oscil[qExt]);
      double qTL = 0;
      if ((L[1] - L[0]) != 0)
         qTL = (t3_Oscil[L[0]] - t3_Oscil[L[1]]) / (L[0] - L[1]);
      ObjectSetDouble(0, l_id, OBJPROP_PRICE, 1, t3_Oscil[qExt] + qTL * (rates_total - 1 - qExt));
      ObjectSetInteger(0, l_id, OBJPROP_COLOR, col);
      ObjectSetInteger(0, l_id, OBJPROP_RAY_RIGHT, true);
   }
   else
      ObjectDelete(0, l_id);
   if (HandyColour)
      col = ChannelL;
   else
      col = ColNum[Step * 2 - 1];
   Rem = IndicatorObjPrefix + "CHAl(" + Complect + ")_" + Step;
   if (Channel)
   {
      if (Regression)
      {
         ObjectCreate(0, Rem, OBJ_REGRESSION, ChartWindowFind(), time[L[1]], t3_Oscil[L[1]], time[L[0]], t3_Oscil[L[0]]);
         ObjectSetInteger(0, Rem, OBJPROP_COLOR, col);
         ObjectSetInteger(0, Rem, OBJPROP_RAY_RIGHT, RayL);
      }
      else
      {
         ObjectCreate(0, Rem, OBJ_STDDEVCHANNEL, ChartWindowFind(), time[L[1]], t3_Oscil[L[1]], time[L[0]], t3_Oscil[L[0]]);
         ObjectSetDouble(0, Rem, OBJPROP_DEVIATION, STDwidthL);
         ObjectSetInteger(0, Rem, OBJPROP_COLOR, col);
         ObjectSetInteger(0, Rem, OBJPROP_RAY_RIGHT, RayL);
      }
   }
   else
      ObjectDelete(0, Rem);
   return (Comm);
}

string l_id, h_id;

int GetTD(int P, double &Arr[], int Step)
{
   int count = 0;
   for (int i = P - 1; i > 0; --i)
   {
      if (Arr[i] != 0)
      {
         ++count;
         if (count == Step + BackSteph)
         {
            return i;
         }
      }
   }
   return -1;
}
int GetNextHighTD(int P)
{
   int i = P - 1;
   while (i > 0)
   {
      if (Buf1[i] != 0)
      {
         return i;
      }
      i--;
   }
   return -1;
}
int GetNextLowTD(int P)
{
   int i = P - 1;
   while (i > 0)
   {
      if (Buf2[i] != 0)
      {
         return i;
      }
      i--;
   }
   return -1;
}
