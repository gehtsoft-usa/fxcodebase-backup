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
#property version "1.3"

#property stacksize 16384
#property indicator_separate_window
#property indicator_level1 80
#property indicator_level2 70
#property indicator_level3 30
#property indicator_level4 20
#property indicator_level5 50
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor DarkGray
#property indicator_buffers 3
#property indicator_color1 Chartreuse
#property indicator_color2 Red
#property indicator_color3 Gold
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2

input string TimeFrame = "Current time frame";
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
input int ma_method = 0;
input int ma_shift = 0;
input int applied_price = 4;
input int mode = 0;
input int fast_ema_period = 12;
input int slow_ema_period = 26;
input int signal_period = 9;
input int Kperiod = 13;
input int Dperiod = 5;
input int slowing = 3;
input int price_field = 0;
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

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd, string Operation, string File, string Parameters, string Directory, int ShowCmd);
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

double e1, e2, e3, e4, e5, e6;
double c1, c2, c3, c4, w1, w2, b2, b3;

int time2;
double E1, E2, E3, E4, E5, E6;
//---- buffers
double Oscil[], t3_Oscil[];
double Buf1[];
double Buf2[];
//----
string Col[] = {"Êðàñíàÿ", "Ñèíÿÿ", "Ðîçîâàÿ", "Ãîëóáàÿ", "Êîðè÷íåâàÿ", "Ñàëàòíàÿ"};
int ColNum[] = {Red, DeepSkyBlue, Coral, Aqua, SaddleBrown, MediumSeaGreen};
int qPoint = 0; // ïåðåìåííàÿ äëÿ íîðìàëèçàöèè öåíû

int qBars;
double qTime = 0; // ïåðåìåííûå äëÿ ëèêâèäàöèè ãëþêîâ ïðè çàãðóçêå
string indicatorFileName;
bool returnBars;
int timeFrame;

Signaler signaler;

datetime last_buy_date;
datetime last_sell_date;

int init()
{
   BackSteph = _BackSteph;
   BackStepl = _BackStepl;
   if (BackStep > 0)
   {
      BackSteph = BackStep;
      BackStepl = BackStep;
   }
   string short_name;
   IndicatorBuffers(4);
   qBars = Bars;
   qSteps = MathMin(3, _qSteps);
   while (NormalizeDouble(Point, qPoint) == 0)
      qPoint++;
   string Rem = "";
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, t3_Oscil);
   SetIndexDrawBegin(0, 2 * T3_Period);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(1, code_buy);
   SetIndexArrow(2, code_sell);
   SetIndexBuffer(1, Buf1);
   SetIndexBuffer(2, Buf2);
   SetIndexEmptyValue(1, 0.0);
   SetIndexEmptyValue(2, 0.0);
   SetIndexLabel(1, Rem);
   SetIndexLabel(2, Rem);
   SetIndexBuffer(3, Oscil);
   indicatorFileName = WindowExpertName();
   returnBars = TimeFrame == "returnBars";
   if (returnBars)
      return (0);
   timeFrame = stringToTimeFrame(TimeFrame);
   switch (Osc)
   {
   case 1:
      short_name = "AC";
      break;
   case 2:
      short_name = "A/D";
      break;
   case 3:
      short_name = "ADX";
      break;
   case 4:
      short_name = "ATR";
      break;
   case 5:
      short_name = "AO";
      break;
   case 6:
      short_name = "Bears";
      break;
   case 7:
      short_name = "Bulls";
      break;
   case 8:
      short_name = "CCI";
      break;
   case 9:
      short_name = "DeM";
      break;
   case 10:
      short_name = "Force";
      break;
   case 11:
      short_name = "Momentum";
      break;
   case 12:
      short_name = "MFI";
      break;
   case 13:
      short_name = "MACD";
      break;
   case 14:
      short_name = "OsMA";
      break;
   case 15:
      short_name = "OBV";
      break;
   case 16:
      short_name = "RVI";
      break;
   case 17:
      short_name = "StdDev";
      break;
   case 18:
      short_name = "Stoch";
      break;
   case 19:
      short_name = "Volume";
      break;
   case 20:
      short_name = "Close";
      break;
   case 21:
      short_name = "Open";
      break;
   case 22:
      short_name = "High";
      break;
   case 23:
      short_name = "Low";
      break;
   case 24:
      short_name = "Median Price";
      break;
   case 25:
      short_name = "Typical Price";
      break;
   case 26:
      short_name = "Weighted Close Price";
      break;
   case 27:
      short_name = "(O+C+H+L)/4";
      break;
   case 28:
      short_name = "(O+C)/2";
      break;
   case 29:
      short_name = "RSI";
      break;
   case 30:
      short_name = "RBCI";
      break;
   case 31:
      short_name = "FTLM";
      break;
   case 32:
      short_name = "STLM";
      break;
   case 33:
      short_name = "JRSX Diver";
      break;
   case 34:
      short_name = "RSI";
      break;
   //case 35 : short_name="ZUP_RSI_v48"; break;
   case 35:
      short_name = "";
      break;
   default:
      short_name = "RBCI";
   }
   IndicatorShortName(short_name);
   SetIndexLabel(0, short_name);
   b2 = b * b;
   b3 = b2 * b;
   c1 = -b3;
   c2 = (3 * (b2 + b3));
   c3 = -3 * (2 * b2 + b + b3);
   c4 = (1 + 3 * b + b3 + 3 * b2);
   int n = 1 + 0.5 * (T3_Period - 1);
   w1 = 2 / (n + 1);
   w2 = 1 - w1;
   RefreshRates();
   WindowRedraw();
   showBars = _showBars;
   return (0);
}

int deinit()
{
   for (int i = 1; i <= qSteps; i++)
   {
      ObjectDelete("HL(" + Complect + ")_" + i);
      ObjectDelete("LL(" + Complect + ")_" + i);
      ObjectDelete("HCL(" + Complect + ")_" + i);
      ObjectDelete("LCL(" + Complect + ")_" + i);
      ObjectDelete("CHAh(" + Complect + ")_" + i);
      ObjectDelete("CHAl(" + Complect + ")_" + i);
      RefreshRates();
      WindowRedraw();
   }
   return (0);
}

int start()
{
   int i, j, counted_bars = IndicatorCounted();
   int shift, limit;
   //----
   if (counted_bars < 0)
      return (-1);
   if (counted_bars < 1)
      limit = Bars - 1;
   else
      limit = Bars - counted_bars;
   if (returnBars)
   {
      t3_Oscil[0] = limit + 1;
      return (0);
   }
   if (timeFrame != Period())
   {
      limit = MathMax(limit, MathMin(Bars - 1, iCustom(NULL, timeFrame, indicatorFileName, "returnBars", 0, 0) * timeFrame / Period()));

      for (i = limit; i >= 0; i--)
      {
         int y = iBarShift(NULL, timeFrame, Time[i]);
         t3_Oscil[i] = iCustom(NULL, timeFrame, indicatorFileName, "", Osc, TH, TL, trend, convergen, Complect, BackSteph, BackStepl, BackStep, qSteps, LevDPl, LevDPr, period, ma_method, ma_shift, applied_price, mode, fast_ema_period, slow_ema_period, signal_period, Kperiod, Dperiod, slowing, price_field, T3_Period, b, showBars, LeftStrong, RightStrong, Anti, Trend_Down, Trend_Up, TrendLine, HandyColour, Highline, Lowline, ChannelLine, Trend, Channel, Regression, RayH, RayL, ChannelH, ChannelL, STDwidthH, STDwidthL, Back, 0, y);
         Buf1[i] = iCustom(NULL, timeFrame, indicatorFileName, "", Osc, TH, TL, trend, convergen, Complect, BackSteph, BackStepl, BackStep, qSteps, LevDPl, LevDPr, period, ma_method, ma_shift, applied_price, mode, fast_ema_period, slow_ema_period, signal_period, Kperiod, Dperiod, slowing, price_field, T3_Period, b, showBars, LeftStrong, RightStrong, Anti, Trend_Down, Trend_Up, TrendLine, HandyColour, Highline, Lowline, ChannelLine, Trend, Channel, Regression, RayH, RayL, ChannelH, ChannelL, STDwidthH, STDwidthL, Back, 1, y);
         Buf2[i] = iCustom(NULL, timeFrame, indicatorFileName, "", Osc, TH, TL, trend, convergen, Complect, BackSteph, BackStepl, BackStep, qSteps, LevDPl, LevDPr, period, ma_method, ma_shift, applied_price, mode, fast_ema_period, slow_ema_period, signal_period, Kperiod, Dperiod, slowing, price_field, T3_Period, b, showBars, LeftStrong, RightStrong, Anti, Trend_Down, Trend_Up, TrendLine, HandyColour, Highline, Lowline, ChannelLine, Trend, Channel, Regression, RayH, RayL, ChannelH, ChannelL, STDwidthH, STDwidthL, Back, 2, y);
      }
      return (0);
   }

   for (shift = 0; shift <= limit; shift++)
   {
      switch (Osc)
      {
      case 1:
         Oscil[shift] = iAC(NULL, 0, shift) + 1;
         break;
      case 2:
         Oscil[shift] = iAD(NULL, 0, shift);
         break;
      case 3:
         Oscil[shift] = iADX(NULL, 0, period, applied_price, mode, shift);
         break;
      case 4:
         Oscil[shift] = iATR(NULL, 0, period, shift);
         break;
      case 5:
         Oscil[shift] = iAO(NULL, 0, shift) + 1;
         break;
      case 6:
         Oscil[shift] = iBearsPower(NULL, 0, period, applied_price, shift) + 1;
         break;
      case 7:
         Oscil[shift] = iBullsPower(NULL, 0, period, applied_price, shift) + 1;
         break;
      case 8:
         Oscil[shift] = iCCI(NULL, 0, period, applied_price, shift) + 1000;
         break;
      case 9:
         Oscil[shift] = iDeMarker(NULL, 0, period, shift);
         break;
      case 10:
         Oscil[shift] = iForce(NULL, 0, period, ma_method, applied_price, shift) + 100;
         break;
      case 11:
         Oscil[shift] = iMomentum(NULL, 0, period, applied_price, shift);
         break;
      case 12:
         Oscil[shift] = iMFI(NULL, 0, period, shift);
         break;
      case 13:
         Oscil[shift] = iMACD(NULL, 0, fast_ema_period, slow_ema_period, signal_period, applied_price, mode, shift) + 1;
         break;
      case 14:
         Oscil[shift] = iOsMA(NULL, 0, fast_ema_period, slow_ema_period, signal_period, applied_price, shift) + 1;
         break;
      case 15:
         Oscil[shift] = iOBV(NULL, 0, applied_price, shift) / 10000000 + 100;
         break;
      case 16:
         Oscil[shift] = iRVI(NULL, 0, period, mode, shift) + 1;
         break;
      case 17:
         Oscil[shift] = iStdDev(NULL, 0, period, ma_shift, ma_method, applied_price, shift);
         break;
      case 18:
         Oscil[shift] = iStochastic(NULL, 0, Kperiod, Dperiod, slowing, ma_method, price_field, mode, shift);
         break;
      case 19:
         Oscil[shift] = Volume[shift];
         break;
      case 20:
         Oscil[shift] = Close[shift];
         break;
      case 21:
         Oscil[shift] = Open[shift];
         break;
      case 22:
         Oscil[shift] = High[shift];
         break;
      case 23:
         Oscil[shift] = Low[shift];
         break;
      case 24:
         Oscil[shift] = (High[shift] + Low[shift]) / 2;
         break;
      case 25:
         Oscil[shift] = (High[shift] + Low[shift] + Close[shift]) / 3;
         break;
      case 26:
         Oscil[shift] = (High[shift] + Low[shift] + Close[shift] + Close[shift]) / 4;
         break;
      case 27:
         Oscil[shift] = (Open[shift] + Close[shift] + High[shift] + Low[shift]) / 4;
         break;
      case 28:
         Oscil[shift] = (Open[shift] + Close[shift]) / 2;
         break;
      case 29:
         Oscil[shift] = iRSI(NULL, 0, period, applied_price, shift);
         break;
      case 30:
         Oscil[shift] = iCustom(NULL, 0, "RBCI Petr2", 0, shift);
         break;
      case 31:
         Oscil[shift] = iCustom(NULL, 0, "FTLM Petr2", 0, shift);
         break;
      case 32:
         Oscil[shift] = iCustom(NULL, 0, "STLM Petr2", 0, shift);
         break;
      case 33:
         Oscil[shift] = iCustom(NULL, 0, "JRSX Diver", 0, shift);
         break;
      case 34:
         Oscil[shift] = iRSI(NULL, 0, period, applied_price, shift);
         break;
      //case 35: Oscil[shift] =iCustom(NULL,0,"ZUP_RSI_v48",0,shift); break;
      //case 35: Oscil[shift] =iWPR(NULL,0,period,shift); break;
      case 35:
         Oscil[shift] = iCustom(NULL, 0, "Dynamic Cycle Explorer - simple", 0, shift);
         break;
         //Dynamic Cycle Explorer - simple
      default:
         Oscil[shift] = iCustom(NULL, 0, "RBCI", 0, shift);
         break;
      }
      RefreshRates();
      WindowRedraw();
   }
   //----
   if (Bars - 1 < T3_Period)
      return (0);
   //----
   int MaxBar, counted_bars1 = IndicatorCounted();
   //----
   if (counted_bars1 > 0)
      counted_bars1--;
   //----
   MaxBar = Bars - 1 - T3_Period;
   //----
   limit = (Bars - 1 - counted_bars1);
   //----
   if (limit > MaxBar)
   {
      for (int bar = Bars - 1; bar >= MaxBar; bar--)
         t3_Oscil[bar] = 0.0;
      limit = MaxBar;
   }
   //---
   int Tnew = Time[limit + 1];
   if (limit < MaxBar)
      if (Tnew == time2)
      {
         e1 = E1;
         e2 = E2;
         e3 = E3;
         e4 = E4;
         e5 = E5;
         e6 = E6;
      }
      else
      {
         if (Tnew > time2)
            Print("ERROR01");
         else
            Print("ERROR02");
         return (-1);
      }
   //---
   for (bar = limit; bar >= 0; bar--)
   {
      if (bar == 1)
         if (((limit == 1) && (time2 != Time[2])) || (limit > 1))
         {
            time2 = Time[2];
            E1 = e1;
            E2 = e2;
            E3 = e3;
            E4 = e4;
            E5 = e5;
            E6 = e6;
         }
      //+---+============================================+
      e1 = w1 * Oscil[bar] + w2 * e1;
      e2 = w1 * e1 + w2 * e2;
      e3 = w1 * e2 + w2 * e3;
      e4 = w1 * e3 + w2 * e4;
      e5 = w1 * e4 + w2 * e5;
      e6 = w1 * e5 + w2 * e6;
      t3_Oscil[bar] = c1 * e6 + c2 * e5 + c3 * e4 + c4 * e3;
      RefreshRates();
      WindowRedraw();
   }
   //----
   if (qBars != Bars)
   {
      deinit();
      Sleep(1000);
      qBars = Bars;
      qTime = 0;
      return (0);
   }
   if (qTime == Time[0])
      return (0);
   qTime = Time[0]; // çàïóñêàåöà òîêà íà 1ì òèêå
   if (showBars > Bars - LevDPl - 1)
      showBars = Bars - LevDPl - 1;
   if (showBars == 0)
      showBars = Bars - LevDPl - 1;
   // çàïîëíèëè è îòîáðàçèëè òî÷êè äåìàðêà
   for (int cnt = showBars + Back; cnt > LevDPr + Back; cnt--)
   {
      int mx = 1, mmx = 1, mxx = 1;
      if (LevDPl != 0)
      {
         for (i = LevDPl, j = LevDPr; i > 0; i--, j--)
         {
            if (LeftStrong)
            {
               if (t3_Oscil[cnt + i] >= t3_Oscil[cnt])
                  mx = 0;
            }
            else
            {
               if (t3_Oscil[cnt + i] > t3_Oscil[cnt])
                  mx = 0;
            }
            if (j > 0)
            {
               if (RightStrong)
               {
                  if (t3_Oscil[cnt - j] >= t3_Oscil[cnt])
                     mmx = 0;
               }
               else
               {
                  if (t3_Oscil[cnt - j] > t3_Oscil[cnt])
                     mmx = 0;
               }
            }
            mxx = mx * mmx * mxx;
         }
         if (mxx > 0)
            Buf1[cnt] = t3_Oscil[cnt];
         else
            Buf1[cnt] = 0;
      }
      else
      {
         for (j = LevDPr; j > 0; j--)
         {
            if (RightStrong)
            {
               if (t3_Oscil[cnt - j] >= t3_Oscil[cnt])
                  mmx = 0;
            }
            else
            {
               if (t3_Oscil[cnt - j] > t3_Oscil[cnt])
                  mmx = 0;
            }
            mxx = mmx * mxx;
         }
         if (mxx > 0)
            Buf1[cnt] = t3_Oscil[cnt];
         else
            Buf1[cnt] = 0;
         RefreshRates();
         WindowRedraw();
      }
      //----
      int mn = 1, mmn = 1, mnn = 1;
      if (LevDPl != 0)
      {
         for (i = LevDPl, j = LevDPr; i > 0; i--, j--)
         {
            if (LeftStrong)
            {
               if (t3_Oscil[cnt + i] <= t3_Oscil[cnt])
                  mn = 0;
            }
            else
            {
               if (t3_Oscil[cnt + i] < t3_Oscil[cnt])
                  mn = 0;
            }
            if (j > 0)
            {
               if (RightStrong)
               {
                  if (t3_Oscil[cnt - j] <= t3_Oscil[cnt])
                     mmn = 0;
               }
               else
               {
                  if (t3_Oscil[cnt - j] < t3_Oscil[cnt])
                     mmn = 0;
               }
            }
            mnn = mn * mmn * mnn;
         }
         if (mnn > 0)
            Buf2[cnt] = t3_Oscil[cnt];
         else
            Buf2[cnt] = 0;
      }
      else
      {
         for (j = LevDPr; j > 0; j--)
         {
            if (RightStrong)
            {
               if (t3_Oscil[cnt - j] <= t3_Oscil[cnt])
                  mmn = 0;
            }
            else
            {
               if (t3_Oscil[cnt - j] < t3_Oscil[cnt])
                  mmn = 0;
            }
            mnn = mmn * mnn;
         }
         if (mnn > 0)
            Buf2[cnt] = t3_Oscil[cnt];
         else
            Buf2[cnt] = 0;
         RefreshRates();
         WindowRedraw();
      }
      //----
   }
   string Comm;
   for (cnt = 1; cnt <= qSteps; cnt++)
      Comm = Comm + (TDMain(cnt));

   double rsi0 = iRSI(NULL, 0, period, applied_price, SIGNAL_BAR);
   double rsi1 = iRSI(NULL, 0, period, applied_price, SIGNAL_BAR + 1);

   double y0 = ObjectGetDouble(0, l_id, OBJPROP_PRICE, 0);
   double y1 = ObjectGetDouble(0, l_id, OBJPROP_PRICE, 1);
   double x0 = ObjectGetInteger(0, l_id, OBJPROP_TIME, 0);
   double x1 = ObjectGetInteger(0, l_id, OBJPROP_TIME, 1);
   if (y0 > 0 && y1 > 0 && x0 > 0 && x1 > 0)
   {
      double d1 = (y0 - y1) * Time[SIGNAL_BAR] + (x1 - x0) * rsi0 + (x0 * y1 - x1 * y0);
      double d2 = (y0 - y1) * Time[SIGNAL_BAR + 1] + (x1 - x0) * rsi1 + (x0 * y1 - x1 * y0);
      double d = d1 * d2;
      if ((d < 0 || d1 == 0) && last_buy_date != x0)
      {
         signaler.SendNotifications(StringConcatenate(Symbol() + "", " -", " ", "BUY", " ", " -", " ", Period(), " ", "-", " ", TimeToStr(TimeLocal(), TIME_SECONDS)));
         last_buy_date = x0;
      } 
   }
   
   y0 = ObjectGetDouble(0, h_id, OBJPROP_PRICE, 0);
   y1 = ObjectGetDouble(0, h_id, OBJPROP_PRICE, 1);
   x0 = ObjectGetInteger(0, h_id, OBJPROP_TIME, 0);
   x1 = ObjectGetInteger(0, h_id, OBJPROP_TIME, 1);
   if (y0 > 0 && y1 > 0 && x0 > 0 && x1 > 0)
   {
      d1 = (y0 - y1) * Time[SIGNAL_BAR] + (x1 - x0) * rsi0 + (x0 * y1 - x1 * y0);
      d2 = (y0 - y1) * Time[SIGNAL_BAR + 1] + (x1 - x0) * rsi1 + (x0 * y1 - x1 * y0);
      d = d1 * d2;
      if ((d < 0 || d1 == 0) && last_sell_date != x0)
      {
         signaler.SendNotifications(StringConcatenate(Symbol() + "", " -", " ", "SELL", " ", " -", " ", Period(), " ", "-", " ", TimeToStr(TimeLocal(), TIME_SECONDS)));
         last_sell_date = x0;
      } 
   }
   return (0);
}

string TDMain(int Step)
{
   int H1, H2, H3, H4, H5, H6, H7, H8, H9, H10, H11, H12, H13, H14, L1, L2, L3, L4, L5, L6, L7, L8, L9, L10, L11, L12, L13, L14, qExt, col;
   double qTL;
   string Comm = "»—»—» Øàã " + Step + " èç " + qSteps + " (BackStep " + BackStep + ")\n", Rem, Rem1, Rem2, Rem3, Rem4, Rem5, Rem6, Rem7, Rem8;
   string Short_name;
   switch (Osc)
   {
   case 1:
      Short_name = "AC";
      break;
   case 2:
      Short_name = "A/D";
      break;
   case 3:
      Short_name = "ADX";
      break;
   case 4:
      Short_name = "ATR";
      break;
   case 5:
      Short_name = "AO";
      break;
   case 6:
      Short_name = "Bears";
      break;
   case 7:
      Short_name = "Bulls";
      break;
   case 8:
      Short_name = "CCI";
      break;
   case 9:
      Short_name = "DeM";
      break;
   case 10:
      Short_name = "Force";
      break;
   case 11:
      Short_name = "Momentum";
      break;
   case 12:
      Short_name = "MFI";
      break;
   case 13:
      Short_name = "MACD";
      break;
   case 14:
      Short_name = "OsMA";
      break;
   case 15:
      Short_name = "OBV";
      break;
   case 16:
      Short_name = "RVI";
      break;
   case 17:
      Short_name = "StdDev";
      break;
   case 18:
      Short_name = "Stoch";
      break;
   case 19:
      Short_name = "Volume";
      break;
   case 20:
      Short_name = "Close";
      break;
   case 21:
      Short_name = "Open";
      break;
   case 22:
      Short_name = "High";
      break;
   case 23:
      Short_name = "Low";
      break;
   case 24:
      Short_name = "Median Price";
      break;
   case 25:
      Short_name = "Typical Price";
      break;
   case 26:
      Short_name = "Weighted Close Price";
      break;
   case 27:
      Short_name = "(O+C+H+L)/4";
      break;
   case 29:
      Short_name = "RSI";
      break;
   case 30:
      Short_name = "RBCI";
      break;
   case 31:
      Short_name = "FTLM";
      break;
   case 32:
      Short_name = "STLM";
      break;
   case 33:
      Short_name = "JRSX Diver";
      break;
   case 34:
      Short_name = "RSI";
      break;
   //case 35 : Short_name="ZUP_RSI_v48"; break;
   case 35:
      Short_name = "WPR";
      break;
   default:
      Short_name = "RBCI";
   }
   // äëÿ DownTrendLines
   if (Trend <= 0)
   {
      Comm = Comm + "» " + Col[Step * 2 - 2] + " DownTrendLine ";
      if (HandyColour)
         col = Highline;
      else
         col = ColNum[Step * 2 - 2];
      H1 = GetTD(Step + BackSteph, Buf1);
      H2 = GetNextHighTD(H1);
      H3 = GetNextHighTD(H2);
      H4 = GetNextHighTD(H3);
      H5 = GetNextHighTD(H4);
      H6 = GetNextHighTD(H5);
      H7 = GetNextHighTD(H6);
      H8 = GetNextHighTD(H7);
      H9 = GetNextHighTD(H8);
      H10 = GetNextHighTD(H9);
      H11 = GetNextHighTD(H10);
      H12 = GetNextHighTD(H11);
      H13 = GetNextHighTD(H12);
      H14 = GetNextHighTD(H13);

      if ((H2 - H1) != 0)
         qTL = (t3_Oscil[H2] - t3_Oscil[H1]) / (H2 - H1);
      int n, sn, r, result;
      for (n = 1, r = H1 + 1; n < H2 - H1 - 1; n++)
      {
         sn = H1 + 1 + n;
         if (t3_Oscil[r] < t3_Oscil[sn])
            result = r;
         else
            result = sn;
         r = result;
         RefreshRates();
         WindowRedraw();
      }
      double Complect1, Complect2, Complect3, Complect4, Complect5, Complect6, Complect7, Complect8, buy, sell;
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

      qExt = r; // ëîêàëüíûé ìèíèìóì ìåæäó òî÷êàìè

      Comm = Comm + "\n";
      int indicatorWindow = WindowFind(Short_name);
      Rem = "HL(" + Complect + ")_" + Step;
      Rem1 = "HL(" + Complect8 + ")_" + Step;
      Rem2 = "HL(" + Complect1 + ")_" + Step;
      Rem3 = "HL(" + Complect2 + ")_" + Step;
      Rem4 = "HL(" + Complect3 + ")_" + Step;
      Rem5 = "HL(" + Complect4 + ")_" + Step;
      Rem6 = "HL(" + Complect5 + ")_" + Step;
      Rem7 = "HL(" + Complect6 + ")_" + Step;
      Rem8 = "HL(" + Complect7 + ")_" + Step;
      //if (BuyStop==true && SellLimit==false) {
      //Rem="BuyStop   "+Step+Step;
      //}
      //else if (BuyStop==false && SellLimit==true) {
      //Rem="SellLimit   "+Step+Step;
      //}
      //else Rem="Trendh   "+Step+Step;

      if (trend == true && Oscil[H2] > Oscil[H1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[H2]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[H2]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
         RefreshRates();
         WindowRedraw();
      }

      else if (trend == true && Oscil[H3] > Oscil[H1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[H3]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[H3]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
         RefreshRates();
         WindowRedraw();
      }

      else if (trend == true && Oscil[H4] > Oscil[H1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[H4]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[H4]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
         RefreshRates();
         WindowRedraw();
      }

      else if (trend == true && Oscil[H5] > Oscil[H1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[H5]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[H5]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
         RefreshRates();
         WindowRedraw();
      }

      else if (trend == true && Oscil[H6] > Oscil[H1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[H6]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[H6]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
      }

      else if (trend == true && Oscil[H7] > Oscil[H1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[H7]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[H7]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
         RefreshRates();
         WindowRedraw();
      }

      else if (trend == true && Oscil[H8] > Oscil[H1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[H8]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[H8]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
         RefreshRates();
         WindowRedraw();
      }

      else if (trend == true && Oscil[H9] > Oscil[H1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[H9]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[H9]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
         RefreshRates();
         WindowRedraw();
      }

      else if (trend == true && Oscil[H10] > Oscil[H1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[H10]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[H10]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
         RefreshRates();
         WindowRedraw();
      }

      else if (trend == true && Oscil[H11] > Oscil[H1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[H11]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[H11]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
         RefreshRates();
         WindowRedraw();
      }

      else if (trend == true && Oscil[H12] > Oscil[H1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[H12]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[H12]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
         RefreshRates();
         WindowRedraw();
      }

      else if (trend == true && Oscil[H13] > Oscil[H1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[H13]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[H13]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
         RefreshRates();
         WindowRedraw();
      }

      else if (trend == true && Oscil[H14] > Oscil[H1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[H14]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[H14]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
         RefreshRates();
         WindowRedraw();
      }
      else if (trend == true && Oscil[H2] < Oscil[H1] && Oscil[H3] < Oscil[H1] && Oscil[H4] < Oscil[H1] && Oscil[H5] < Oscil[H1] &&
               Oscil[H6] < Oscil[H1] && Oscil[H7] < Oscil[H1] && Oscil[H8] < Oscil[H1] && Oscil[H9] < Oscil[H1] && Oscil[H10] < Oscil[H1] &&
               Oscil[H11] < Oscil[H1] && Oscil[H12] < Oscil[H1] && Oscil[H13] < Oscil[H1] && Oscil[H14] < Oscil[H1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[H1]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[H1]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
         RefreshRates();
         WindowRedraw();
      }
      else
         ObjectDelete(Rem);

      if (TrendLine && Oscil[H2] > Oscil[H1] && High[H2] < High[H1]) // ñîáñòâåííî diver
      {
         ObjectCreate(Rem1, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem1, OBJPROP_TIME1, Time[H2]);
         ObjectSet(Rem1, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem1, OBJPROP_PRICE1, t3_Oscil[H2]);
         ObjectSet(Rem1, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem1, OBJPROP_COLOR, Red);
         ObjectSet(Rem1, OBJPROP_WIDTH, 2);
         ObjectSet(Rem1, OBJPROP_RAY, false);
         sell = true;
         RefreshRates();
         WindowRedraw();
      }

      else if (convergen == true && TrendLine && Oscil[H2] < Oscil[H1] && High[H2] > High[H1])
      {
         ObjectCreate(Rem1, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem1, OBJPROP_TIME1, Time[H2]);
         ObjectSet(Rem1, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem1, OBJPROP_PRICE1, t3_Oscil[H2]);
         ObjectSet(Rem1, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem1, OBJPROP_COLOR, Gold);
         ObjectSet(Rem1, OBJPROP_WIDTH, 2);
         ObjectSet(Rem1, OBJPROP_RAY, false);
         sell = true;
         RefreshRates();
         WindowRedraw();
      }
      else
         ObjectDelete(Rem1);

      //////////////////////////////
      if (TrendLine && TH == true && Oscil[H2] < Oscil[H1] && High[H2] < High[H1] &&
          Oscil[H3] > Oscil[H1] && High[H3] < High[H1] && High[H3] > High[H2])
      {
         ObjectCreate(Rem2, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem2, OBJPROP_TIME1, Time[H3]);
         ObjectSet(Rem2, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem2, OBJPROP_PRICE1, t3_Oscil[H3]);
         ObjectSet(Rem2, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem2, OBJPROP_COLOR, Red);
         ObjectSet(Rem2, OBJPROP_WIDTH, 2);
         ObjectSet(Rem2, OBJPROP_RAY, false);
         RefreshRates();
         WindowRedraw();
      }
      else if (convergen == true && TrendLine && TH == true && Oscil[H2] < Oscil[H1] && High[H2] < High[H1] &&
               Oscil[H3] < Oscil[H1] && High[H3] > High[H1] && High[H3] > High[H2] && Oscil[H3] > Oscil[H2])
      {
         ObjectCreate(Rem2, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem2, OBJPROP_TIME1, Time[H3]);
         ObjectSet(Rem2, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem2, OBJPROP_PRICE1, t3_Oscil[H3]);
         ObjectSet(Rem2, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem2, OBJPROP_COLOR, Gold);
         ObjectSet(Rem2, OBJPROP_WIDTH, 2);
         ObjectSet(Rem2, OBJPROP_RAY, false);
         RefreshRates();
         WindowRedraw();
      }

      else
         ObjectDelete(Rem2);

      if (TrendLine && TH == true && Oscil[H2] < Oscil[H1] && High[H2] < High[H1] && Oscil[H3] < Oscil[H1] &&
          High[H3] < High[H1] && Oscil[H4] > Oscil[H1] &&
          High[H4] < High[H1] && High[H4] > High[H3] && High[H4] > High[H2])
      {
         ObjectCreate(Rem3, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem3, OBJPROP_TIME1, Time[H4]);
         ObjectSet(Rem3, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem3, OBJPROP_PRICE1, t3_Oscil[H4]);
         ObjectSet(Rem3, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem3, OBJPROP_COLOR, Red);
         ObjectSet(Rem3, OBJPROP_WIDTH, 2);
         ObjectSet(Rem3, OBJPROP_RAY, false);
         RefreshRates();
         WindowRedraw();
      }
      else if (convergen == true && TrendLine && TH == true && Oscil[H2] < Oscil[H1] && High[H2] < High[H1] && Oscil[H3] < Oscil[H1] &&
               High[H3] < High[H1] && Oscil[H4] < Oscil[H1] &&
               High[H4] > High[H1] && High[H4] > High[H3] && High[H4] > High[H2] && Oscil[H4] > Oscil[H2] && Oscil[H4] > Oscil[H3])
      {
         ObjectCreate(Rem3, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem3, OBJPROP_TIME1, Time[H4]);
         ObjectSet(Rem3, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem3, OBJPROP_PRICE1, t3_Oscil[H4]);
         ObjectSet(Rem3, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem3, OBJPROP_COLOR, Gold);
         ObjectSet(Rem3, OBJPROP_WIDTH, 2);
         ObjectSet(Rem3, OBJPROP_RAY, false);
         RefreshRates();
         WindowRedraw();
      }

      else
         ObjectDelete(Rem3);

      if (TrendLine && TH == true && Oscil[H2] < Oscil[H1] && High[H2] < High[H1] && Oscil[H3] < Oscil[H1] &&
          High[H3] < High[H1] &&
          Oscil[H4] < Oscil[H1] && High[H4] < High[H1] &&
          Oscil[H5] > Oscil[H1] && High[H5] < High[H1] && High[H5] > High[H4] && High[H5] > High[H3] && High[H5] > High[H2])
      {
         ObjectCreate(Rem4, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem4, OBJPROP_TIME1, Time[H5]);
         ObjectSet(Rem4, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem4, OBJPROP_PRICE1, t3_Oscil[H5]);
         ObjectSet(Rem4, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem4, OBJPROP_COLOR, Red);
         ObjectSet(Rem4, OBJPROP_WIDTH, 2);
         ObjectSet(Rem4, OBJPROP_RAY, false);
         RefreshRates();
         WindowRedraw();
      }
      else if (convergen == true && TrendLine && TH == true && Oscil[H2] < Oscil[H1] && High[H2] < High[H1] && Oscil[H3] < Oscil[H1] &&
               High[H3] < High[H1] &&
               Oscil[H4] < Oscil[H1] && High[H4] < High[H1] &&
               Oscil[H5] < Oscil[H1] && High[H5] > High[H1] && High[H5] > High[H4] && High[H5] > High[H3] && High[H5] > High[H2] &&
               Oscil[H5] > Oscil[H2] && Oscil[H5] > Oscil[H3] && Oscil[H5] > Oscil[H4])
      {
         ObjectCreate(Rem4, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem4, OBJPROP_TIME1, Time[H5]);
         ObjectSet(Rem4, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem4, OBJPROP_PRICE1, t3_Oscil[H5]);
         ObjectSet(Rem4, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem4, OBJPROP_COLOR, Gold);
         ObjectSet(Rem4, OBJPROP_WIDTH, 2);
         ObjectSet(Rem4, OBJPROP_RAY, false);
         RefreshRates();
         WindowRedraw();
      }

      else
         ObjectDelete(Rem4);

      if (TrendLine && TH == true && Oscil[H2] < Oscil[H1] && High[H2] < High[H1] && Oscil[H3] < Oscil[H1] && High[H3] < High[H1] &&
          Oscil[H4] < Oscil[H1] && High[H4] < High[H1] && Oscil[H5] < Oscil[H1] && High[H5] < High[H1] &&
          Oscil[H6] > Oscil[H1] && High[H6] < High[H1] && High[H6] > High[H5] && High[H6] > High[H4] && High[H6] > High[H3] && High[H6] > High[H2])
      {
         ObjectCreate(Rem5, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem5, OBJPROP_TIME1, Time[H6]);
         ObjectSet(Rem5, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem5, OBJPROP_PRICE1, t3_Oscil[H6]);
         ObjectSet(Rem5, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem5, OBJPROP_COLOR, Red);
         ObjectSet(Rem5, OBJPROP_WIDTH, 2);
         ObjectSet(Rem5, OBJPROP_RAY, false);
         RefreshRates();
         WindowRedraw();
      }

      else if (convergen == true && TrendLine && TH == true && Oscil[H2] < Oscil[H1] && High[H2] < High[H1] && Oscil[H3] < Oscil[H1] && High[H3] < High[H1] &&
               Oscil[H4] < Oscil[H1] && High[H4] < High[H1] && Oscil[H5] < Oscil[H1] && High[H5] < High[H1] &&
               Oscil[H6] < Oscil[H1] && High[H6] > High[H1] && High[H6] > High[H5] && High[H6] > High[H4] && High[H6] > High[H3] && High[H6] > High[H2] &&
               Oscil[H6] > Oscil[H2] && Oscil[H6] > Oscil[H3] && Oscil[H6] > Oscil[H4] && Oscil[H6] > Oscil[H5])
      {
         ObjectCreate(Rem5, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem5, OBJPROP_TIME1, Time[H6]);
         ObjectSet(Rem5, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem5, OBJPROP_PRICE1, t3_Oscil[H6]);
         ObjectSet(Rem5, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem5, OBJPROP_COLOR, Gold);
         ObjectSet(Rem5, OBJPROP_WIDTH, 2);
         ObjectSet(Rem5, OBJPROP_RAY, false);
         RefreshRates();
         WindowRedraw();
      }
      else
         ObjectDelete(Rem5);

      //////////////
      if (TrendLine && TH == true && Oscil[H2] < Oscil[H1] && High[H2] < High[H1] && Oscil[H3] < Oscil[H1] && High[H3] < High[H1] &&
          Oscil[H4] < Oscil[H1] && High[H4] < High[H1] && Oscil[H5] < Oscil[H1] && High[H5] < High[H1] &&
          Oscil[H6] < Oscil[H1] && High[H6] < High[H1] &&
          Oscil[H7] > Oscil[H1] && High[H7] < High[H1] && High[H7] > High[H6] && High[H7] > High[H5] && High[H7] > High[H4] &&
          High[H7] > High[H3] && High[H7] > High[H2])
      {
         ObjectCreate(Rem6, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem6, OBJPROP_TIME1, Time[H7]);
         ObjectSet(Rem6, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem6, OBJPROP_PRICE1, t3_Oscil[H7]);
         ObjectSet(Rem6, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem6, OBJPROP_COLOR, Red);
         ObjectSet(Rem6, OBJPROP_WIDTH, 2);
         ObjectSet(Rem6, OBJPROP_RAY, false);
         RefreshRates();
         WindowRedraw();
      }

      else if (convergen == true && TrendLine && TH == true && Oscil[H2] < Oscil[H1] && High[H2] < High[H1] && Oscil[H3] < Oscil[H1] && High[H3] < High[H1] &&
               Oscil[H4] < Oscil[H1] && High[H4] < High[H1] && Oscil[H5] < Oscil[H1] && High[H5] < High[H1] &&
               Oscil[H6] < Oscil[H1] && High[H6] < High[H1] &&
               Oscil[H7] < Oscil[H1] && High[H7] > High[H1] && High[H7] > High[H6] && High[H7] > High[H5] && High[H7] > High[H4] &&
               High[H7] > High[H3] && High[H7] > High[H2] &&
               Oscil[H7] > Oscil[H2] && Oscil[H7] > Oscil[H3] && Oscil[H7] > Oscil[H4] && Oscil[H7] > Oscil[H5] && Oscil[H7] > Oscil[H6])
      {
         ObjectCreate(Rem6, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem6, OBJPROP_TIME1, Time[H7]);
         ObjectSet(Rem6, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem6, OBJPROP_PRICE1, t3_Oscil[H7]);
         ObjectSet(Rem6, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem6, OBJPROP_COLOR, Gold);
         ObjectSet(Rem6, OBJPROP_WIDTH, 2);
         ObjectSet(Rem6, OBJPROP_RAY, false);
      }
      else
         ObjectDelete(Rem6);

      if (TrendLine && TH == true && Oscil[H2] < Oscil[H1] && High[H2] < High[H1] && Oscil[H3] < Oscil[H1] && High[H3] < High[H1] &&
          Oscil[H4] < Oscil[H1] && High[H4] < High[H1] && Oscil[H5] < Oscil[H1] && High[H5] < High[H1] &&
          Oscil[H6] < Oscil[H1] && High[H6] < High[H1] && Oscil[H7] < Oscil[H1] && High[H7] < High[H1] &&
          Oscil[H8] > Oscil[H1] && High[H8] < High[H1] && High[H8] > High[H7] && High[H8] > High[H6] && High[H8] > High[H5] &&
          High[H8] > High[H4] && High[H8] > High[H3] && High[H8] > High[H2])
      {
         ObjectCreate(Rem7, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem7, OBJPROP_TIME1, Time[H8]);
         ObjectSet(Rem7, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem7, OBJPROP_PRICE1, t3_Oscil[H8]);
         ObjectSet(Rem7, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem7, OBJPROP_COLOR, Red);
         ObjectSet(Rem7, OBJPROP_WIDTH, 2);
         ObjectSet(Rem7, OBJPROP_RAY, false);
      }

      else if (convergen == true && TrendLine && TH == true && Oscil[H2] < Oscil[H1] && High[H2] < High[H1] && Oscil[H3] < Oscil[H1] && High[H3] < High[H1] &&
               Oscil[H4] < Oscil[H1] && High[H4] < High[H1] && Oscil[H5] < Oscil[H1] && High[H5] < High[H1] &&
               Oscil[H6] < Oscil[H1] && High[H6] < High[H1] && Oscil[H7] < Oscil[H1] && High[H7] < High[H1] &&
               Oscil[H8] < Oscil[H1] && High[H8] > High[H1] && High[H8] > High[H7] && High[H8] > High[H6] && High[H8] > High[H5] &&
               High[H8] > High[H4] && High[H8] > High[H3] && High[H8] > High[H2] &&
               Oscil[H8] > Oscil[H2] && Oscil[H8] > Oscil[H3] && Oscil[H8] > Oscil[H4] && Oscil[H8] > Oscil[H5] && Oscil[H8] > Oscil[H6] && Oscil[H8] > Oscil[H7])
      {
         ObjectCreate(Rem7, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem7, OBJPROP_TIME1, Time[H8]);
         ObjectSet(Rem7, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem7, OBJPROP_PRICE1, t3_Oscil[H8]);
         ObjectSet(Rem7, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem7, OBJPROP_COLOR, Gold);
         ObjectSet(Rem7, OBJPROP_WIDTH, 2);
         ObjectSet(Rem7, OBJPROP_RAY, false);
      }
      else
         ObjectDelete(Rem7);

      if (TrendLine && TH == true && Oscil[H2] < Oscil[H1] && High[H2] < High[H1] && Oscil[H3] < Oscil[H1] && High[H3] < High[H1] &&
          Oscil[H4] < Oscil[H1] && High[H4] < High[H1] && Oscil[H5] < Oscil[H1] && High[H5] < High[H1] &&
          Oscil[H6] < Oscil[H1] && High[H6] < High[H1] && Oscil[H7] < Oscil[H1] && High[H7] < High[H1] &&
          Oscil[H8] < Oscil[H1] && High[H8] < High[H1] &&
          Oscil[H9] > Oscil[H1] && High[H9] < High[H1] && High[H9] > High[H8] && High[H9] > High[H7] && High[H9] > High[H6] &&
          High[H9] > High[H5] && High[H9] > High[H4] && High[H9] > High[H3] && High[H9] > High[H2])
      {
         ObjectCreate(Rem8, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem8, OBJPROP_TIME1, Time[H9]);
         ObjectSet(Rem8, OBJPROP_TIME2, Time[H1]);
         ObjectSet(Rem8, OBJPROP_PRICE1, t3_Oscil[H9]);
         ObjectSet(Rem8, OBJPROP_PRICE2, t3_Oscil[H1]);
         ObjectSet(Rem8, OBJPROP_COLOR, Red);
         ObjectSet(Rem8, OBJPROP_WIDTH, 2);
         ObjectSet(Rem8, OBJPROP_RAY, false);
      }

      else
         ObjectDelete(Rem8);

      //////////////////////

      if (Trend_Down == false)
         ObjectDelete(Rem);

      h_id = "HCL(" + Complect + ")_" + Step; // ëèíèÿ êàíàëà
      if (ChannelLine)
      {
         ObjectCreate(h_id, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(h_id, OBJPROP_TIME1, Time[qExt]);
         ObjectSet(h_id, OBJPROP_TIME2, Time[0]);
         ObjectSet(h_id, OBJPROP_PRICE1, t3_Oscil[qExt]);
         ObjectSet(h_id, OBJPROP_PRICE2, t3_Oscil[qExt] - qTL * qExt);
         ObjectSet(h_id, OBJPROP_COLOR, col);
      }
      else
         ObjectDelete(h_id);
      if (HandyColour)
         col = ChannelH;
      else
         col = ColNum[Step * 2 - 2];
      Rem = "CHAh(" + Complect + ")_" + Step;
      if (Channel)
      {
         if (Regression)
         {
            ObjectCreate(Rem, OBJ_REGRESSION, indicatorWindow, Time[H2], t3_Oscil[H2], Time[H1], t3_Oscil[H1]);
            ObjectSet(Rem, OBJPROP_COLOR, col);
            ObjectSet(Rem, OBJPROP_RAY, RayH);
         }
         else
         {
            ObjectCreate(Rem, OBJ_STDDEVCHANNEL, indicatorWindow, Time[H2], t3_Oscil[H2], Time[H1], t3_Oscil[H1]);
            ObjectSet(Rem, OBJPROP_DEVIATION, STDwidthH);
            ObjectSet(Rem, OBJPROP_COLOR, col);
            ObjectSet(Rem, OBJPROP_RAY, RayH);
         }
      }
      else
         ObjectDelete(Rem);
   }

   // äëÿ UpTrendLines
   if (Trend >= 0)
   {
      Comm = Comm + "» " + Col[Step * 2 - 1] + " UpTrendLine ";
      if (HandyColour)
         col = Lowline;
      else
         col = ColNum[Step * 2 - 1];
      L1 = GetTD(Step + BackStepl, Buf2);
      L2 = GetNextLowTD(L1);
      L3 = GetNextLowTD(L2);
      L4 = GetNextLowTD(L3);
      L5 = GetNextLowTD(L4);
      L6 = GetNextLowTD(L5);
      L7 = GetNextLowTD(L6);
      L8 = GetNextLowTD(L7);
      L9 = GetNextLowTD(L8);
      L10 = GetNextLowTD(L9);
      L11 = GetNextLowTD(L10);
      L12 = GetNextLowTD(L11);
      L13 = GetNextLowTD(L12);
      L14 = GetNextLowTD(L13);

      if ((L2 - L1) != 0)
         qTL = (t3_Oscil[L1] - t3_Oscil[L2]) / (L2 - L1);
      for (n = 1, r = L1 + 1; n < L2 - L1 - 1; n++)
      {
         sn = L1 + 1 + n;
         if (t3_Oscil[r] > t3_Oscil[sn])
            result = r;
         else
            result = sn;
         r = result;
      }
      qExt = r; // ëîêàëüíûé ìàêñèìóì ìåæäó òî÷êàìè
      Comm = Comm + "\n";
      indicatorWindow = WindowFind(Short_name);
      Rem = "LL(" + Complect + ")_" + Step;
      Rem1 = "LL(" + Complect8 + ")_" + Step;
      Rem2 = "LL(" + Complect1 + ")_" + Step;
      Rem3 = "LL(" + Complect2 + ")_" + Step;
      Rem4 = "LL(" + Complect3 + ")_" + Step;
      Rem5 = "LL(" + Complect4 + ")_" + Step;
      Rem6 = "LL(" + Complect5 + ")_" + Step;
      Rem7 = "LL(" + Complect6 + ")_" + Step;
      Rem8 = "LL(" + Complect7 + ")_" + Step;

      //if (SellStop==true && BuyLimit==false) {
      //Rem="SellStop   "+Step+Step;
      //}
      //else if (SellStop==false && BuyLimit==true) {
      //Rem="BuyLimit   "+Step+Step;
      //}
      //else Rem="Trendl   "+Step+Step;

      if (trend == true && Oscil[L2] < Oscil[L1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[L2]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[L2]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
      }

      else if (trend == true && Oscil[L3] < Oscil[L1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[L3]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[L3]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
      }

      else if (trend == true && Oscil[L4] < Oscil[L1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[L4]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[L4]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
      }

      else if (trend == true && Oscil[L5] < Oscil[L1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[L5]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[L5]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
      }

      else if (trend == true && Oscil[L6] < Oscil[L1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[L6]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[L6]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
      }

      else if (trend == true && Oscil[L7] < Oscil[L1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[L7]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[L7]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
      }

      else if (trend == true && Oscil[L8] < Oscil[L1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[L8]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[L8]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
      }

      else if (trend == true && Oscil[L9] < Oscil[L1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[L9]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[L9]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
      }

      else if (trend == true && Oscil[L10] < Oscil[L1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[L10]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[L10]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
      }

      else if (trend == true && Oscil[L11] < Oscil[L1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[L11]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[L11]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
      }

      else if (trend == true && Oscil[L12] < Oscil[L1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[L12]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[L12]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
      }

      else if (trend == true && Oscil[L13] < Oscil[L1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[L13]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[L13]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
      }

      else if (trend == true && Oscil[L14] < Oscil[L1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[L14]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[L14]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
      }
      else if (trend == true && Oscil[L2] < Oscil[L1] && Oscil[L3] < Oscil[L1] && Oscil[L4] < Oscil[L1] && Oscil[L5] < Oscil[L1] &&
               Oscil[L6] < Oscil[L1] && Oscil[L7] < Oscil[L1] && Oscil[L8] < Oscil[L1] && Oscil[L9] < Oscil[L1] && Oscil[L10] < Oscil[L1] &&
               Oscil[L11] < Oscil[L1] && Oscil[L12] < Oscil[L1] && Oscil[L13] < Oscil[L1] && Oscil[L14] < Oscil[L1]) // ñîáñòâåííî ëèíèÿ òðåíäà
      {
         ObjectCreate(Rem, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem, OBJPROP_TIME1, Time[L1]);
         ObjectSet(Rem, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem, OBJPROP_PRICE1, t3_Oscil[L1]);
         ObjectSet(Rem, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem, OBJPROP_COLOR, SkyBlue);
         ObjectSet(Rem, OBJPROP_WIDTH, 3 - MathMax(4, Step));
      }
      else
         ObjectDelete(Rem);

      if (TrendLine && Oscil[L2] < Oscil[L1] && Low[L2] > Low[L1]) // ñîáñòâåííî diver Up
      {
         ObjectCreate(Rem1, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem1, OBJPROP_TIME1, Time[L2]);
         ObjectSet(Rem1, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem1, OBJPROP_PRICE1, t3_Oscil[L2]);
         ObjectSet(Rem1, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem1, OBJPROP_COLOR, Red);
         ObjectSet(Rem1, OBJPROP_WIDTH, 2);
         ObjectSet(Rem1, OBJPROP_RAY, false);
         buy = true;
      }

      else if (convergen == true && TrendLine && Oscil[L2] > Oscil[L1] && Low[L2] < Low[L1]) // ñîáñòâåííî diver Up
      {
         ObjectCreate(Rem1, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem1, OBJPROP_TIME1, Time[L2]);
         ObjectSet(Rem1, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem1, OBJPROP_PRICE1, t3_Oscil[L2]);
         ObjectSet(Rem1, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem1, OBJPROP_COLOR, Gold);
         ObjectSet(Rem1, OBJPROP_WIDTH, 2);
         ObjectSet(Rem1, OBJPROP_RAY, false);
         buy = true;
      }

      else
         ObjectDelete(Rem1);

      ///////////////////////////

      if (TrendLine && TL == true && Oscil[L2] > Oscil[L1] && Low[L2] > Low[L1] && Oscil[L3] < Oscil[L1] &&
          Low[L3] > Low[L1] && Low[L3] < Low[L2])
      {
         ObjectCreate(Rem2, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem2, OBJPROP_TIME1, Time[L3]);
         ObjectSet(Rem2, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem2, OBJPROP_PRICE1, t3_Oscil[L3]);
         ObjectSet(Rem2, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem2, OBJPROP_COLOR, Red);
         ObjectSet(Rem2, OBJPROP_WIDTH, 2);
         ObjectSet(Rem2, OBJPROP_RAY, false);
      }

      else if (convergen == true && TrendLine && TL == true && Oscil[L2] > Oscil[L1] && Low[L2] > Low[L1] &&
               Oscil[L3] > Oscil[L1] && Low[L3] < Low[L1] && Low[L3] < Low[L2] && Oscil[L3] < Oscil[L2])
      {
         ObjectCreate(Rem2, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem2, OBJPROP_TIME1, Time[L3]);
         ObjectSet(Rem2, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem2, OBJPROP_PRICE1, t3_Oscil[L3]);
         ObjectSet(Rem2, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem2, OBJPROP_COLOR, Gold);
         ObjectSet(Rem2, OBJPROP_WIDTH, 2);
         ObjectSet(Rem2, OBJPROP_RAY, false);
      }
      else
         ObjectDelete(Rem2);

      if (TrendLine && TL == true && Oscil[L2] > Oscil[L1] && Low[L2] > Low[L1] && Oscil[L3] > Oscil[L1] &&
          Low[L3] > Low[L1] && Oscil[L4] < Oscil[L1] &&
          Low[L4] > Low[L1] && Low[L4] < Low[L3] && Low[L4] < Low[L2])
      {
         ObjectCreate(Rem3, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem3, OBJPROP_TIME1, Time[L4]);
         ObjectSet(Rem3, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem3, OBJPROP_PRICE1, t3_Oscil[L4]);
         ObjectSet(Rem3, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem3, OBJPROP_COLOR, Red);
         ObjectSet(Rem3, OBJPROP_WIDTH, 2);
         ObjectSet(Rem3, OBJPROP_RAY, false);
      }

      else if (convergen == true && TrendLine && TL == true && Oscil[L2] > Oscil[L1] && Low[L2] > Low[L1] && Oscil[L3] > Oscil[L1] &&
               Low[L3] > Low[L1] && Oscil[L4] > Oscil[L1] &&
               Low[L4] < Low[L1] && Low[L4] < Low[L3] && Low[L4] < Low[L2] && Oscil[L4] < Oscil[L3] && Oscil[L4] < Oscil[L2])
      {
         ObjectCreate(Rem3, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem3, OBJPROP_TIME1, Time[L4]);
         ObjectSet(Rem3, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem3, OBJPROP_PRICE1, t3_Oscil[L4]);
         ObjectSet(Rem3, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem3, OBJPROP_COLOR, Gold);
         ObjectSet(Rem3, OBJPROP_WIDTH, 2);
         ObjectSet(Rem3, OBJPROP_RAY, false);
      }
      else
         ObjectDelete(Rem3);

      if (TrendLine && TL == true && Oscil[L2] > Oscil[L1] && Low[L2] > Low[L1] && Oscil[L3] > Oscil[L1] && Low[L3] > Low[L1] &&
          Oscil[L4] > Oscil[L1] && Low[L4] > Low[L1] &&
          Oscil[L5] < Oscil[L1] && Low[L5] > Low[L1] && Low[L5] < Low[L4] && Low[L5] < Low[L3] && Low[L5] < Low[L2])
      {
         ObjectCreate(Rem4, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem4, OBJPROP_TIME1, Time[L5]);
         ObjectSet(Rem4, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem4, OBJPROP_PRICE1, t3_Oscil[L5]);
         ObjectSet(Rem4, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem4, OBJPROP_COLOR, Red);
         ObjectSet(Rem4, OBJPROP_WIDTH, 2);
         ObjectSet(Rem4, OBJPROP_RAY, false);
      }

      else if (convergen == true && TrendLine && TL == true && Oscil[L2] > Oscil[L1] && Low[L2] > Low[L1] && Oscil[L3] > Oscil[L1] && Low[L3] > Low[L1] &&
               Oscil[L4] > Oscil[L1] && Low[L4] > Low[L1] &&
               Oscil[L5] > Oscil[L1] && Low[L5] < Low[L1] && Low[L5] < Low[L4] && Low[L5] < Low[L3] && Low[L5] < Low[L2] &&
               Oscil[L5] < Oscil[L4] && Oscil[L5] < Oscil[L3] && Oscil[L5] < Oscil[L2])
      {
         ObjectCreate(Rem4, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem4, OBJPROP_TIME1, Time[L5]);
         ObjectSet(Rem4, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem4, OBJPROP_PRICE1, t3_Oscil[L5]);
         ObjectSet(Rem4, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem4, OBJPROP_COLOR, Gold);
         ObjectSet(Rem4, OBJPROP_WIDTH, 2);
         ObjectSet(Rem4, OBJPROP_RAY, false);
      }
      else
         ObjectDelete(Rem4);

      if (TrendLine && TL == true && Oscil[L2] > Oscil[L1] && Low[L2] > Low[L1] && Oscil[L3] > Oscil[L1] && Low[L3] > Low[L1] &&
          Oscil[L4] > Oscil[L1] && Low[L4] > Low[L1] && Oscil[L5] > Oscil[L1] && Low[L5] > Low[L1] &&
          Oscil[L6] < Oscil[L1] && Low[L6] > Low[L1] && Low[L6] < Low[L5] && Low[L6] < Low[L4] && Low[L6] < Low[L3] && Low[L6] < Low[L2])
      {
         ObjectCreate(Rem5, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem5, OBJPROP_TIME1, Time[L6]);
         ObjectSet(Rem5, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem5, OBJPROP_PRICE1, t3_Oscil[L6]);
         ObjectSet(Rem5, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem5, OBJPROP_COLOR, Red);
         ObjectSet(Rem5, OBJPROP_WIDTH, 2);
         ObjectSet(Rem5, OBJPROP_RAY, false);
      }

      else if (convergen == true && TrendLine && TL == true && Oscil[L2] > Oscil[L1] && Low[L2] > Low[L1] && Oscil[L3] > Oscil[L1] && Low[L3] > Low[L1] &&
               Oscil[L4] > Oscil[L1] && Low[L4] > Low[L1] && Oscil[L5] > Oscil[L1] && Low[L5] > Low[L1] &&
               Oscil[L6] > Oscil[L1] && Low[L6] < Low[L1] && Low[L6] < Low[L5] && Low[L6] < Low[L4] && Low[L6] < Low[L3] && Low[L6] < Low[L2] &&
               Oscil[L6] < Oscil[L5] && Oscil[L6] < Oscil[L4] && Oscil[L6] < Oscil[L3] && Oscil[L6] < Oscil[L2])
      {
         ObjectCreate(Rem5, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem5, OBJPROP_TIME1, Time[L6]);
         ObjectSet(Rem5, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem5, OBJPROP_PRICE1, t3_Oscil[L6]);
         ObjectSet(Rem5, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem5, OBJPROP_COLOR, Gold);
         ObjectSet(Rem5, OBJPROP_WIDTH, 2);
         ObjectSet(Rem5, OBJPROP_RAY, false);
      }
      else
         ObjectDelete(Rem5);

      /////////////////////////
      if (TrendLine && TL == true && Oscil[L2] > Oscil[L1] && Low[L2] > Low[L1] && Oscil[L3] > Oscil[L1] && Low[L3] > Low[L1] &&
          Oscil[L4] > Oscil[L1] && Low[L4] > Low[L1] && Oscil[L5] > Oscil[L1] && Low[L5] > Low[L1] &&
          Oscil[L6] > Oscil[L1] && Low[L6] > Low[L1] &&
          Oscil[L7] < Oscil[L1] && Low[L7] > Low[L1] && Low[L7] < Low[L6] && Low[L7] < Low[L5] && Low[L7] < Low[L4] &&
          Low[L7] < Low[L3] && Low[L7] < Low[L2])
      {
         ObjectCreate(Rem6, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem6, OBJPROP_TIME1, Time[L7]);
         ObjectSet(Rem6, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem6, OBJPROP_PRICE1, t3_Oscil[L7]);
         ObjectSet(Rem6, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem6, OBJPROP_COLOR, Red);
         ObjectSet(Rem6, OBJPROP_WIDTH, 2);
         ObjectSet(Rem6, OBJPROP_RAY, false);
      }

      else if (convergen == true && TrendLine && TL == true && Oscil[L2] > Oscil[L1] && Low[L2] > Low[L1] && Oscil[L3] > Oscil[L1] && Low[L3] > Low[L1] &&
               Oscil[L4] > Oscil[L1] && Low[L4] > Low[L1] && Oscil[L5] > Oscil[L1] && Low[L5] > Low[L1] &&
               Oscil[L6] > Oscil[L1] && Low[L6] > Low[L1] &&
               Oscil[L7] > Oscil[L1] && Low[L7] < Low[L1] && Low[L7] < Low[L6] && Low[L7] < Low[L5] && Low[L7] < Low[L4] &&
               Low[L7] < Low[L3] && Low[L7] < Low[L2] &&
               Oscil[L7] < Oscil[L6] && Oscil[L7] < Oscil[L5] && Oscil[L7] < Oscil[L4] && Oscil[L7] < Oscil[L3] && Oscil[L7] < Oscil[L2])
      {
         ObjectCreate(Rem6, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem6, OBJPROP_TIME1, Time[L7]);
         ObjectSet(Rem6, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem6, OBJPROP_PRICE1, t3_Oscil[L7]);
         ObjectSet(Rem6, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem6, OBJPROP_COLOR, Gold);
         ObjectSet(Rem6, OBJPROP_WIDTH, 2);
         ObjectSet(Rem6, OBJPROP_RAY, false);
      }
      else
         ObjectDelete(Rem6);

      if (TrendLine && TL == true && Oscil[L2] > Oscil[L1] && Low[L2] > Low[L1] && Oscil[L3] > Oscil[L1] && Low[L3] > Low[L1] &&
          Oscil[L4] > Oscil[L1] && Low[L4] > Low[L1] && Oscil[L5] > Oscil[L1] && Low[L5] > Low[L1] &&
          Oscil[L6] > Oscil[L1] && Low[L6] > Low[L1] && Oscil[L7] > Oscil[L1] && Low[L7] > Low[L1] &&
          Oscil[L8] < Oscil[L1] && Low[L8] > Low[L1] && Low[L8] < Low[L7] && Low[L8] < Low[L6] && Low[L8] < Low[L5] &&
          Low[L8] < Low[L4] && Low[L8] < Low[L3] && Low[L8] < Low[L2])
      {
         ObjectCreate(Rem7, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem7, OBJPROP_TIME1, Time[L8]);
         ObjectSet(Rem7, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem7, OBJPROP_PRICE1, t3_Oscil[L8]);
         ObjectSet(Rem7, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem7, OBJPROP_COLOR, Red);
         ObjectSet(Rem7, OBJPROP_WIDTH, 2);
         ObjectSet(Rem7, OBJPROP_RAY, false);
      }

      else if (convergen == true && TrendLine && TL == true && Oscil[L2] > Oscil[L1] && Low[L2] > Low[L1] && Oscil[L3] > Oscil[L1] && Low[L3] > Low[L1] &&
               Oscil[L4] > Oscil[L1] && Low[L4] > Low[L1] && Oscil[L5] > Oscil[L1] && Low[L5] > Low[L1] &&
               Oscil[L6] > Oscil[L1] && Low[L6] > Low[L1] && Oscil[L7] > Oscil[L1] && Low[L7] > Low[L1] &&
               Oscil[L8] > Oscil[L1] && Low[L8] < Low[L1] && Low[L8] < Low[L7] && Low[L8] < Low[L6] && Low[L8] < Low[L5] &&
               Low[L8] < Low[L4] && Low[L8] < Low[L3] && Low[L8] < Low[L2] &&
               Oscil[L8] < Oscil[L7] && Oscil[L8] < Oscil[L6] && Oscil[L8] < Oscil[L5] && Oscil[L8] < Oscil[L4] &&
               Oscil[L8] < Oscil[L3] && Oscil[L8] < Oscil[L2])
      {
         ObjectCreate(Rem7, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem7, OBJPROP_TIME1, Time[L8]);
         ObjectSet(Rem7, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem7, OBJPROP_PRICE1, t3_Oscil[L8]);
         ObjectSet(Rem7, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem7, OBJPROP_COLOR, Gold);
         ObjectSet(Rem7, OBJPROP_WIDTH, 2);
         ObjectSet(Rem7, OBJPROP_RAY, false);
      }
      else
         ObjectDelete(Rem7);

      if (TrendLine && TL == true && Oscil[L2] > Oscil[L1] && Low[L2] > Low[L1] && Oscil[L3] > Oscil[L1] && Low[L3] > Low[L1] &&
          Oscil[L4] > Oscil[L1] && Low[L4] > Low[L1] && Oscil[L5] > Oscil[L1] && Low[L5] > Low[L1] &&
          Oscil[L6] > Oscil[L1] && Low[L6] > Low[L1] && Oscil[L7] > Oscil[L1] && Low[L7] > Low[L1] &&
          Oscil[L8] > Oscil[L1] && Low[L8] > Low[L1] &&
          Oscil[L9] < Oscil[L1] && Low[L9] > Low[L1] && Low[L9] < Low[L8] && Low[L9] < Low[L7] && Low[L9] < Low[L6] &&
          Low[L9] < Low[L5] && Low[L9] < Low[L4] && Low[L9] < Low[L3] && Low[L9] < Low[L2])
      {
         ObjectCreate(Rem8, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(Rem8, OBJPROP_TIME1, Time[L9]);
         ObjectSet(Rem8, OBJPROP_TIME2, Time[L1]);
         ObjectSet(Rem8, OBJPROP_PRICE1, t3_Oscil[L9]);
         ObjectSet(Rem8, OBJPROP_PRICE2, t3_Oscil[L1]);
         ObjectSet(Rem8, OBJPROP_COLOR, Red);
         ObjectSet(Rem8, OBJPROP_WIDTH, 2);
      }

      else
         ObjectDelete(Rem8);

      //////////////////////////

      if (Trend_Up == false)
         ObjectDelete(Rem);

      l_id = "LCL(" + Complect + ")_" + Step; // ëèíèÿ êàíàëà

      if (ChannelLine)
      {
         ObjectCreate(l_id, OBJ_TREND, indicatorWindow, 0, 0, 0, 0);
         ObjectSet(l_id, OBJPROP_TIME1, Time[qExt]);
         ObjectSet(l_id, OBJPROP_TIME2, Time[0]);
         ObjectSet(l_id, OBJPROP_PRICE1, t3_Oscil[qExt]);
         ObjectSet(l_id, OBJPROP_PRICE2, t3_Oscil[qExt] + qTL * qExt);
         ObjectSet(l_id, OBJPROP_COLOR, col);
      }
      else
         ObjectDelete(l_id);
      if (HandyColour)
         col = ChannelL;
      else
         col = ColNum[Step * 2 - 1];
      Rem = "CHAl(" + Complect + ")_" + Step;
      if (Channel)
      {
         if (Regression)
         {
            ObjectCreate(Rem, OBJ_REGRESSION, indicatorWindow, Time[L2], t3_Oscil[L2], Time[L1], t3_Oscil[L1]);
            ObjectSet(Rem, OBJPROP_COLOR, col);
            ObjectSet(Rem, OBJPROP_RAY, RayL);
         }
         else
         {
            ObjectCreate(Rem, OBJ_STDDEVCHANNEL, indicatorWindow, Time[L2], t3_Oscil[L2], Time[L1], t3_Oscil[L1]);
            ObjectSet(Rem, OBJPROP_DEVIATION, STDwidthL);
            ObjectSet(Rem, OBJPROP_COLOR, col);
            ObjectSet(Rem, OBJPROP_RAY, RayL);
         }
      }
      else
         ObjectDelete(Rem);
   }
   return (Comm);
}

string l_id, h_id;

int GetTD(int P, double &Arr[])
{
   int i = 0, j = 0;
   while (j < P)
   {
      i++;
      while (Arr[i] == 0)
      {
         i++;
         if (i > showBars - 2)
            return (-1);
      }
      j++;
   }
   return (i);
}
int GetNextHighTD(int P)
{
   int i = P + 1;
   while (Buf1[i] == 0)
   {
      i++;
      if (i > showBars - 2)
         return (-1);
   }
   return (i);
}
int GetNextLowTD(int P)
{
   int i = P + 1;
   while (Buf2[i] == 0)
   {
      i++;
      if (i > showBars - 2)
         return (-1);
   }
   return (i);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

int stringToTimeFrame(string tfs)
{
   StringToUpper(tfs);
   for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if (tfs == sTfTable[i] || tfs == "" + iTfTable[i])
         return (MathMax(iTfTable[i], Period()));
   return (Period());
}
string timeFrameToString(int tf)
{
   for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if (tf == iTfTable[i])
         return (sTfTable[i]);
   return ("");
}