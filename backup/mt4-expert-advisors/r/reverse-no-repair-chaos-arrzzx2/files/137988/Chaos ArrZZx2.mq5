// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=27&t=70492

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

// based on Bookkeeper, 2007, yuzefovich@gmail.com, Andriy Moraru, EarnForex.com
// https://www.earnforex.com/forum/threads/how-do-you-convert-mt4-indicators-to-mt5.23198/

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   6
#property indicator_color1  clrWhite
#property indicator_type1   DRAW_ARROW
#property indicator_width1  5
#property indicator_color2  clrLime
#property indicator_width2  2
#property indicator_color3  clrBlue //C'0,128,255'
#property indicator_width3  7
#property indicator_type3   DRAW_ARROW
#property indicator_color4  clrRed //C'192,0,192'
#property indicator_width4  7
#property indicator_type4   DRAW_ARROW
#property indicator_color5  clrDodgerBlue //C'0,128,255'
#property indicator_width5  3
#property indicator_type5   DRAW_ARROW
#property indicator_color6  clrMediumVioletRed //C'192,0,192'
#property indicator_width6  3
#property indicator_type6   DRAW_ARROW

int    SR     = 3; // = 3..4   Xard settings (3, 21, 20, 21, 3, false, 0)
// 60, 36, 24, 13, 4..12..20..12
input int    SRZZ = 60;
input string AlertsSection = ""; // == Alerts ==
input bool     Popup_Alert              = true; // Popup message
input bool     Notification_Alert       = false; // Push notification
input bool     Email_Alert              = false; // Email
input bool     Play_Sound               = false; // Play sound on alert
input string   Sound_File               = ""; // Sound file
#ifdef ADVANCED_ALERTS
input bool     Advanced_Alert           = false; // Advanced alert
input string   Advanced_Key             = ""; // Advanced alert key
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib using ProfitRobots installer -";
#endif

int    MainRZZ = 20; // 20, 12..20..54..20
int    FP     = 21;
int    SMF    = 3; // 1..5
bool   DrawZZ = false;
ENUM_APPLIED_PRICE PriceConst = PRICE_CLOSE;

// Buffers:
double Lmt[];
double LZZ[];
double SA[];
double SM[];
double Up[];
double Dn[];
double pUp[];
double pDn[];

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

int LTF[6] = {0, 0, 0, 0, 0, 0}, STF[5] = {0, 0, 0, 0, 0};
int MaxBar, nSBZZ, nLBZZ, SBZZ, LBZZ;
bool First = true;
int prevBars = 0;
int handle_ma;

void MainCalculation(const int Pos, const int bars, const double& Open[], const double& High[], const double& Low[], const double& Close[])
{
   if ((bars - Pos) > (SR + 1)) SACalc(Pos, Open, High, Low, Close);
   else SA[Pos] = 0;

   if ((bars - Pos) > (FP + SR + 2)) SMCalc(Pos);
   else SM[Pos] = 0;
}

void SACalc(const int Pos, const double& Open[], const double& High[], const double& Low[], const double& Close[])
{
   int sw, i, w, ww, Shift;
   double sum;

   double MA[1];
   CopyBuffer(handle_ma, 0, Pos, 1, MA);
   SA[Pos] = MA[0];

   for (Shift = Pos + SR + 2; Shift > Pos; Shift--)
   {
      sum = 0.0;
      sw = 0;
      i = 0;
      w = Shift + SR;
      ww = Shift - SR;
      if (ww < Pos) ww = Pos;
      while (w >= Shift)
      {
         i++;
         sum = sum + i * SnakePrice(w, Open, High, Low, Close);
         sw = sw + i;
         w--;
      }
      while(w >= ww)
      {
         i--;
         sum = sum + i * SnakePrice(w, Open, High, Low, Close);
         sw = sw + i;
         w--;
      }
      SA[Shift] = sum / sw;
   }
}

double SnakePrice(const int Shift, const double& Open[], const double& High[], const double& Low[], const double& Close[])
{
   switch(PriceConst)
   {
   case PRICE_CLOSE:
      return(Close[Shift]);
   case PRICE_OPEN:
      return(Open[Shift]);
   case PRICE_HIGH:
      return(High[Shift]);
   case PRICE_LOW:
      return(Low[Shift]);
   case PRICE_MEDIAN:
      return((High[Shift] + Low[Shift]) / 2);
   case PRICE_TYPICAL:
      return((Close[Shift] + High[Shift] + Low[Shift]) / 3);
   case PRICE_WEIGHTED:
      return((2 * Close[Shift] + High[Shift] + Low[Shift]) / 4);
   default:
      return(Open[Shift]);
   }
}

void SMCalc(const int i)
{
   double t, b;
   for (int Shift = i + SR + 2; Shift >= i; Shift--)
   {
      t = SA[ArrayMaximum(SA, Shift, FP)];
      b = SA[ArrayMinimum(SA, Shift, FP)];
      SM[Shift] = (2 * (2 + SMF) * SA[Shift] - (t + b)) / 2 / (1 + SMF);
   }
}

void LZZCalc(const int Pos, const int bars)
{
   int i, RBar, LBar, ZZ = 0, NZZ, NZig, NZag;
   i = Pos - 1;
   NZig = 0;
   NZag = 0;
   while ((i < MaxBar) && (ZZ == 0))
   {
      i++;
      LZZ[i] = 0;
      RBar = i - MainRZZ;
      if (RBar < Pos) RBar = Pos;
      LBar = i + MainRZZ;
      if (i == ArrayMinimum(SM, RBar, LBar - RBar + 1))
      {
         ZZ = -1;
         NZig = i;
      }
      if(i == ArrayMaximum(SM, RBar, LBar - RBar + 1))
      {
         ZZ = 1;
         NZag = i;
      }
   }
   
   if (ZZ == 0) return;
   
   NZZ = 0;
   if (i > Pos)
   {
      if (SM[i] > SM[Pos])
      {
         if (ZZ == 1)
         {
            if ((i >= Pos + MainRZZ) && (NZZ < 5))
            {
               NZZ++;
               LTF[NZZ] = i;
            }
            NZag = i;
            LZZ[i] = SM[i];
         }
      }
      else
      {
         if (ZZ == -1)
         {
            if ((i >= Pos + MainRZZ) && (NZZ < 5))
            {
               NZZ++;
               LTF[NZZ] = i;
            }
            NZig = i;
            LZZ[i] = SM[i];
         }
      }
   }
   
   while ((i < LBZZ) || (NZZ < 5))
   {
      LZZ[i] = 0;
      RBar = i - MainRZZ;
      if (RBar < Pos) RBar = Pos;
      LBar = i + MainRZZ;
      if (i == ArrayMinimum(SM, RBar, LBar - RBar + 1))
      {
         if ((ZZ == -1) && (SM[i] < SM[NZig]))
         {
            if ((i >= Pos + MainRZZ) && (NZZ < 5)) LTF[NZZ] = i;
            LZZ[NZig] = 0;
            LZZ[i] = SM[i];
            NZig = i;
         }
         if (ZZ == 1)
         {
            if ((i >= Pos + MainRZZ) && (NZZ < 5))
            {
               NZZ++;
               LTF[NZZ] = i;
            }
            LZZ[i] = SM[i];
            ZZ = -1;
            NZig = i;
         }
      }
      if (i == ArrayMaximum(SM, RBar, LBar - RBar + 1))
      {
         if ((ZZ == 1) && (SM[i] > SM[NZag]))
         {
            if ((i >= Pos + MainRZZ) && (NZZ < 5)) LTF[NZZ] = i;
            LZZ[NZag] = 0;
            LZZ[i] = SM[i];
            NZag = i;
         }
         if (ZZ == -1)
         {
            if ((i >= Pos + MainRZZ) && (NZZ < 5))
            {
               NZZ++;
               LTF[NZZ] = i;
            }
            LZZ[i] = SM[i];
            ZZ = 1;
            NZag = i;
         }
      }
      i++;
      if (i > MaxBar) return;
   }
   nLBZZ = bars - LTF[5];
   LZZ[Pos] = SM[Pos];
}

void SZZCalc(const int Pos, const int bars, const double& Open[])
{
   int i, RBar, LBar, ZZ = 0, NZZ, NZig, NZag;
   i = Pos - 1;
   NZig = 0;
   NZag = 0;
   while ((i <= LBZZ) && (ZZ == 0))
   {
      i++;
      pDn[i] = 0;
      pUp[i] = 0;
      Dn[i] = 0;
      Up[i] = 0;
      Lmt[i] = 0;
      RBar = i - SRZZ;
      if (RBar < Pos) RBar = Pos;
      LBar = i + SRZZ;
      if (i == ArrayMinimum(SM, RBar, LBar - RBar + 1))
      {
         ZZ = -1;
         NZig = i;
      }
      if (i == ArrayMaximum(SM, RBar, LBar - RBar + 1))
      {
         ZZ = 1;
         NZag = i;
      }
   }
   if (ZZ == 0) return;
   
   NZZ = 0;
   if (i > Pos)
   {
      if (SM[i] > SM[Pos])
      {
         if (ZZ == 1)
         {
            if ((i >= Pos + SRZZ) && (NZZ < 4))
            {
               NZZ++;
               STF[NZZ] = i;
            }
            NZag = i;
            Dn[i - 1] = Open[i - 1];
         }
      }
      else
      {
         if (ZZ == -1)
         {
            if ((i >= Pos + SRZZ) && (NZZ < 4))
            {
               NZZ++;
               STF[NZZ] = i;
            }
            NZig = i;
            Up[i - 1] = Open[i - 1];
         }
      }
   }
   while ((i <= LBZZ) || (NZZ < 4))
   {
      pDn[i] = 0;
      pUp[i] = 0;
      Dn[i] = 0;
      Up[i] = 0;
      Lmt[i] = 0;
      RBar = i - SRZZ;
      if (RBar < Pos) RBar = Pos;
      LBar = i + SRZZ;
      if (i == ArrayMinimum(SM, RBar, LBar - RBar + 1))
      {
         if ((ZZ == -1) && (SM[i] < SM[NZig]))
         {
            if ((i >= Pos + SRZZ) && (NZZ < 4)) STF[NZZ] = i;
            Up[NZig - 1] = 0;
            Up[i - 1] = Open[i - 1];
            NZig = i;
         }
         if (ZZ == 1)
         {
            if ((i >= Pos + SRZZ) && (NZZ < 4))
            {
               NZZ++;
               STF[NZZ] = i;
            }
            Up[i - 1] = Open[i - 1];
            ZZ = -1;
            NZig = i;
         }
      }
      if (i == ArrayMaximum(SM, RBar, LBar - RBar + 1))
      {
         if ((ZZ == 1) && (SM[i] > SM[NZag]))
         {
            if ((i >= Pos + SRZZ) && (NZZ < 4)) STF[NZZ] = i;
            Dn[NZag - 1] = 0;
            Dn[i - 1] = Open[i - 1];
            NZag = i;
         }
         if (ZZ == -1)
         {
            if ((i >= Pos + SRZZ) && (NZZ < 4))
            {
               NZZ++;
               STF[NZZ] = i;
            }
            Dn[i - 1] = Open[i - 1];
            ZZ = 1;
            NZag = i;
         }
      }
      i++;
      if (i > LBZZ) return;
   }
   nSBZZ = bars - STF[4];
}

void ArrCalc(const double& Open[])
{
   int i, j, k, n, z = 0;
   double p;
   i = LBZZ;
   while (LZZ[i] == 0) 
      i--;
   j = i;
   p = LZZ[i];
   i--;
   while (LZZ[i] == 0) 
      i--;
   
   if (LZZ[i] > p) 
      z = 1;
   if ((LZZ[i] > 0) && (LZZ[i] < p)) z = -1;
   p = LZZ[j];
   i = j - 1;
   while (i > 0)
   {
      if (LZZ[i] > p)
      {
         z = -1;
         p = LZZ[i];
      }
      if ((LZZ[i] > 0) && (LZZ[i] < p))
      {
         z = 1;
         p = LZZ[i];
      }
      if ((z > 0) && (Dn[i] > 0))
      {
         Lmt[i] = Open[i];
         Dn[i] = 0;
      }
      if ((z < 0) && (Up[i] > 0))
      {
         Lmt[i] = Open[i];
         Up[i] = 0;
      }
      if ((z > 0) && (Up[i] > 0))
      {
         if (i > 1)
         {
            j = i - 1;
            k = j - SRZZ + 1;
            if (k < 0) k = 0;
            n = j;
            while ((n >= k) && (Dn[n] == 0))
            {
               pUp[n] = Up[i];
               pDn[n] = 0;
               n--;
            }
         }
         if (i == 1) pUp[0] = Up[i];
      }
      if ((z < 0) && (Dn[i] > 0))
      {
         if (i > 1)
         {
            j = i - 1;
            k = j - SRZZ + 1;
            if (k < 0) k = 0;
            n = j;
            while ((n >= k) && (Up[n] == 0))
            {
               pDn[n] = Dn[i];
               pUp[n] = 0;
               n--;
            }
         }
         if (i == 1) pDn[0] = Dn[i];
      }
      i--;
   }
}

Signaler* mainSignaler;

int OnInit()
{
   mainSignaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mainSignaler.SetPopupAlert(Popup_Alert);
   mainSignaler.SetEmailAlert(Email_Alert);
   mainSignaler.SetPlaySound(Play_Sound, Sound_File);
   mainSignaler.SetNotificationAlert(Notification_Alert);
   #ifdef ADVANCED_ALERTS
   mainSignaler.SetAdvancedAlert(Advanced_Alert, Advanced_Key);
   #endif
   mainSignaler.SetMessagePrefix(_Symbol + "/" + mainSignaler.GetTimeframeStr() + ": ");

   SetIndexBuffer(0, Lmt, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_ARROW, 167);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0);
   ArraySetAsSeries(Lmt, true);

   SetIndexBuffer(1, LZZ, INDICATOR_DATA);
   if (DrawZZ)
   {
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_SECTION);
      PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0);
   }
   else PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
   ArraySetAsSeries(LZZ, true);
   
   SetIndexBuffer(2, Up, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_ARROW, 233); // Green up arrow
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0);
   ArraySetAsSeries(Up, true);

   SetIndexBuffer(3, Dn, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_ARROW, 234); // Green up arrow
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0);
   ArraySetAsSeries(Dn, true);
   
   SetIndexBuffer(4, pUp, INDICATOR_DATA);
   PlotIndexSetInteger(4, PLOT_ARROW, 104); // Green up markers
   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, 0);
   ArraySetAsSeries(pUp, true);

   SetIndexBuffer(5, pDn, INDICATOR_DATA);
   PlotIndexSetInteger(5, PLOT_ARROW, 104); // Red down markers
   PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, 0);
   ArraySetAsSeries(pDn, true);

   SetIndexBuffer(6, SA, INDICATOR_CALCULATIONS);
   ArraySetAsSeries(SA, true);
   SetIndexBuffer(7, SM, INDICATOR_CALCULATIONS);
   ArraySetAsSeries(SM, true);
   
   if (SR < 2) SR = 2;
   if (SRZZ <= SR)
   {
      Alert("SRZZ should be greater than SR (", SR, ")");
      return(INIT_FAILED);
   }
   
   switch(PriceConst)
   {
   case PRICE_CLOSE:
      handle_ma = iMA(NULL, 0, SR + 1, 0, MODE_LWMA, PRICE_CLOSE);
      break;
   case PRICE_OPEN:
      handle_ma = iMA(NULL, 0, SR + 1, 0, MODE_LWMA, PRICE_OPEN);
      break;
   case PRICE_HIGH:
      handle_ma = iMA(NULL, 0, SR + 1, 0, MODE_LWMA, PRICE_HIGH);
      break;
   case PRICE_LOW:
      handle_ma = iMA(NULL, 0, SR + 1, 0, MODE_LWMA, PRICE_LOW);
      break;
   case PRICE_MEDIAN:
      handle_ma = iMA(NULL, 0, SR + 1, 0, MODE_LWMA, PRICE_MEDIAN);
      break;
   case PRICE_TYPICAL:
      handle_ma = iMA(NULL, 0, SR + 1, 0, MODE_LWMA, PRICE_TYPICAL);
      break;
   case PRICE_WEIGHTED:
      handle_ma = iMA(NULL, 0, SR + 1, 0, MODE_LWMA, PRICE_WEIGHTED);
      break;
   default:
      handle_ma = iMA(NULL, 0, SR + 1, 0, MODE_LWMA, PRICE_OPEN);
   }
   
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   delete mainSignaler;
   mainSignaler = NULL;
}

datetime last_signal;

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& Open[],
                const double& High[],
                const double& Low[],
                const double& Close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   ArraySetAsSeries(Open, true);
   ArraySetAsSeries(High, true);
   ArraySetAsSeries(Low, true);
   ArraySetAsSeries(Close, true);

   int counted_bars = prev_calculated > 0 ? prev_calculated - 1 : 0;
   int limit, i;
   if (counted_bars < 0) 
      return(-1);
   if (counted_bars > 0) 
      counted_bars--;
   if (First)
   {
      if (rates_total <= 2 * (MainRZZ + FP + SR + 2)) 
         return(-1);
      MaxBar = rates_total - (MainRZZ + FP + SR + 2);
      LBZZ = MaxBar;
      SBZZ = LBZZ;
      prevBars = rates_total;
      First = false;
   }
   limit = rates_total - counted_bars;
   if (limit >= rates_total - (2 * SR + 2)) 
      limit = rates_total - 1 - (2 * SR + 2);
   
   for (i = limit; i >= 0; i--)
   {
      MainCalculation(i, rates_total, Open, High, Low, Close);
   }
   if (prevBars != rates_total)
   {
      SBZZ = rates_total - nSBZZ;
      LBZZ = rates_total - nLBZZ;
      prevBars = rates_total;
   }
   SZZCalc(0, rates_total, Open);
   LZZCalc(0, rates_total);
   ArrCalc(Open);

   if (time[rates_total - 1] != last_signal)
   {
      if (Up[0] != 0)
      {
         mainSignaler.SendNotifications("Up");
         last_signal = time[rates_total - 1];
      }
      if (Dn[0] != 0)
      {
         mainSignaler.SendNotifications("Down");
         last_signal = time[rates_total - 1];
      }
   }

   return(rates_total);
}
//+------------------------------------------------------------------+