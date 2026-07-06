//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76184

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
#property indicator_buffers 4

enum meth
  {
   Atr,
   Stdev,
   Linreg
  };
// Input parameters
input int    length = 14;           // Swing Detection Lookback
input double mult = 1.0;            // Slope multiplier
input meth calcMethod = Atr;        // Slope Calculation Method: Atr, Stdev, Linreg
input bool   backpaint = true;      // Enable backpainting
input color  upCss = clrTeal;       // Up Trendline Color
input color  dnCss = clrRed;        // Down Trendline Color
input bool   showExt = false;       // Show Extended Lines
enum alert
  {
   Off = 0,         // Off
   Current = 1,     // At current bar
   Previous = 2     // At previous closed bar
  };
input alert  notificationsOn       = 1;                      // Notifications
input bool   desktop_notifications = true;                   // Desktop MT4 notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push mobile notifications
input bool   sound_notifications   = false;                  // Sound notifications
input string sound_file = "Tick.wav";                        // Choose a sound file for notifications

double UpperBuffer[];
double LowerBuffer[];
double UpperBreakBuffer[];
double LowerBreakBuffer[];

static double upper = 0.0;
static double lower = 0.0;
static double slope_ph = 0.0;
static double slope_pl = 0.0;
static int upos = 0;
static int dnos = 0;
static int prev_upos = 0;
static int prev_dnos = 0;
int offset = 0;
static string current_uptl = "";
static string current_dntl = "";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, UpperBuffer);
   SetIndexBuffer(1, LowerBuffer);
   SetIndexBuffer(2, UpperBreakBuffer);
   SetIndexBuffer(3, LowerBreakBuffer);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, upCss);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, dnCss);
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 2, upCss);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 2, dnCss);
   SetIndexArrow(2, 233);
   SetIndexArrow(3, 234);
   SetIndexLabel(0, "Upper Trendline");
   SetIndexLabel(1, "Lower Trendline");
   SetIndexLabel(2, "Upper Break");
   SetIndexLabel(3, "Lower Break");
   IndicatorShortName("Trendlines with Breaks");
   offset = backpaint ? length : 0;
   CleanupObjects();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   CleanupObjects();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanupObjects()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
      string objName = ObjectName(i);
      if(StringFind(objName, "UpTrendline_") >= 0 || StringFind(objName, "DnTrendline_") >= 0)
        {
         ObjectDelete(objName);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   if(rates_total < length * 2)
      return(0);
   if(prev_calculated == 0)
     {
      upper = 0.0;
      lower = 0.0;
      slope_ph = 0.0;
      slope_pl = 0.0;
      upos = 0;
      dnos = 0;
      ArrayInitialize(UpperBuffer, EMPTY_VALUE);
      ArrayInitialize(LowerBuffer, EMPTY_VALUE);
      ArrayInitialize(UpperBreakBuffer, EMPTY_VALUE);
      ArrayInitialize(LowerBreakBuffer, EMPTY_VALUE);
     }
   int limit = rates_total - prev_calculated;
   if(prev_calculated > 0)
      limit++;
   int start_bar = MathMin(rates_total - 1, MathMax(limit - 1, rates_total - 500));
   if(prev_calculated == 0)
      start_bar = rates_total - 1;
   for(int i = start_bar; i >= 0; i--)
     {
      UpperBuffer[i] = EMPTY_VALUE;
      LowerBuffer[i] = EMPTY_VALUE;
      UpperBreakBuffer[i] = EMPTY_VALUE;
      LowerBreakBuffer[i] = EMPTY_VALUE;
      int n = i;
      double ph = EMPTY_VALUE;
      double pl = EMPTY_VALUE;
      if(i >= length && i <= rates_total - length - 1 && i >= 3)
        {
         ph = GetPivotHigh(high, i, length);
         pl = GetPivotLow(low, i, length);
        }
      double slope = 0.0;
      if(ph != EMPTY_VALUE || pl != EMPTY_VALUE)
        {
         if(calcMethod == Atr)
           {
            slope = iATR(Symbol(), Period(), length, i) / length * mult;
           }
         else
            if(calcMethod == Stdev)
              {
               slope = GetStdev(close, i, length) / length * mult;
              }
            else
               if(calcMethod == Linreg)
                 {
                  slope = GetLinregSlope(close, i, length, n) * mult;
                 }
        }
      prev_upos = upos;
      prev_dnos = dnos;
      if(ph != EMPTY_VALUE)
         slope_ph = slope;
      if(pl != EMPTY_VALUE)
         slope_pl = slope;
      if(ph != EMPTY_VALUE)
         upper = ph;
      else
         if(slope_ph != 0.0 && i >= 3)
            upper = upper - slope_ph;
      if(pl != EMPTY_VALUE)
         lower = pl;
      else
         if(slope_pl != 0.0 && i >= 3)
            lower = lower + slope_pl;
      double current_upper = backpaint ? upper : (upper - slope_ph * length);
      double current_lower = backpaint ? lower : (lower + slope_pl * length);
      if(i <= 2)
        {
         if(slope_ph != 0.0)
           {
            double extension_steps = (2 - i) + 1;
            UpperBuffer[i] = current_upper - (slope_ph * extension_steps);
           }
         if(slope_pl != 0.0)
           {
            double extension_steps = (2 - i) + 1;
            LowerBuffer[i] = current_lower + (slope_pl * extension_steps);
           }
         continue;
        }
      if(ph != EMPTY_VALUE)
         upos = 0;
      else
         if(slope_ph != 0.0 && close[i] > current_upper)
            upos = 1;
      if(pl != EMPTY_VALUE)
         dnos = 0;
      else
         if(slope_pl != 0.0 && close[i] < current_lower)
            dnos = 1;
      if(ph == EMPTY_VALUE && slope_ph != 0.0)
         UpperBuffer[i] = current_upper;
      if(pl == EMPTY_VALUE && slope_pl != 0.0)
         LowerBuffer[i] = current_lower;
      if(showExt)
        {
         if(ph != EMPTY_VALUE)
           {
            ObjectDelete(current_uptl);
            current_uptl = "UpTrendline_" + IntegerToString(TimeLocal()) + "_" + IntegerToString(i);
            double y1 = backpaint ? ph : upper - slope_ph * length;
            double y2 = backpaint ? ph - slope : upper - slope_ph * (length + 1);
            int time_index1 = i + offset;
            int time_index2 = i + offset - 1;
            if(time_index1 < rates_total && time_index2 >= 0)
              {
               ObjectCreate(current_uptl, OBJ_TREND, 0,
                            time[time_index1], y1,
                            time[time_index2], y2);
               ObjectSet(current_uptl, OBJPROP_COLOR, upCss);
               ObjectSet(current_uptl, OBJPROP_STYLE, STYLE_DASH);
               ObjectSet(current_uptl, OBJPROP_RAY_RIGHT, true);
               ObjectSet(current_uptl, OBJPROP_WIDTH, 1);
              }
           }
         if(pl != EMPTY_VALUE)
           {
            ObjectDelete(current_dntl);
            current_dntl = "DnTrendline_" + IntegerToString(TimeLocal()) + "_" + IntegerToString(i);
            double y1 = backpaint ? pl : lower + slope_pl * length;
            double y2 = backpaint ? pl + slope : lower + slope_pl * (length + 1);
            int time_index1 = i + offset;
            int time_index2 = i + offset - 1;
            if(time_index1 < rates_total && time_index2 >= 0)
              {
               ObjectCreate(current_dntl, OBJ_TREND, 0,
                            time[time_index1], y1,
                            time[time_index2], y2);
               ObjectSet(current_dntl, OBJPROP_COLOR, dnCss);
               ObjectSet(current_dntl, OBJPROP_STYLE, STYLE_DASH);
               ObjectSet(current_dntl, OBJPROP_RAY_RIGHT, true);
               ObjectSet(current_dntl, OBJPROP_WIDTH, 1);
              }
           }
         if(upos > prev_upos && current_uptl != "")
           {
            ObjectSet(current_uptl, OBJPROP_RAY_RIGHT, false);
            ObjectSet(current_uptl, OBJPROP_TIME2, time[i]);
            ObjectSet(current_uptl, OBJPROP_PRICE2, UpperBuffer[i]);
           }
         if(dnos > prev_dnos && current_dntl != "")
           {
            ObjectSet(current_dntl, OBJPROP_RAY_RIGHT, false);
            ObjectSet(current_dntl, OBJPROP_TIME2, time[i]);
            ObjectSet(current_dntl, OBJPROP_PRICE2, LowerBuffer[i]);
           }
        }
      else
        {
         static bool cleanupDone = false;
         if(!cleanupDone)
           {
            CleanupObjects();
            cleanupDone = true;
           }
        }
     }
   for(int i = rates_total - 1; i >= 0; i--)
     {
      bool upper_break = false;
      bool lower_break = false;
      if(UpperBuffer[i] != EMPTY_VALUE && UpperBuffer[i + 1] != EMPTY_VALUE)
        {
         if(close[i] > UpperBuffer[i] && (open[i] < UpperBuffer[i] || (i < rates_total - 1 && close[i + 1] < UpperBuffer[i + 1])))
           {
            UpperBreakBuffer[i] = Low[i] - 10 * Point();
           }
        }
      if(LowerBuffer[i] != EMPTY_VALUE && LowerBuffer[i + 1] != EMPTY_VALUE)
        {
         if(close[i] < LowerBuffer[i] && (open[i] > LowerBuffer[i] || (i < rates_total - 1 && close[i + 1] > LowerBuffer[i + 1])))
           {
            LowerBreakBuffer[i] = High[i] + 10 * Point();
           }
        }
     }
   if(notificationsOn > 0)
     {
      checkAlert();
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPivotHigh(const double &high[], int index, int period)
  {
   if(index < period || index >= ArraySize(high) - period)
      return EMPTY_VALUE;
   double centerHigh = high[index];
   for(int i = 1; i <= period; i++)
     {
      if(high[index + i] >= centerHigh)
         return EMPTY_VALUE;
     }
   for(int i = 1; i <= period; i++)
     {
      if(high[index - i] >= centerHigh)
         return EMPTY_VALUE;
     }
   return centerHigh;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPivotLow(const double &low[], int index, int period)
  {
   if(index < period || index >= ArraySize(low) - period)
      return EMPTY_VALUE;
   double centerLow = low[index];
   for(int i = 1; i <= period; i++)
     {
      if(low[index + i] <= centerLow)
         return EMPTY_VALUE;
     }
   for(int i = 1; i <= period; i++)
     {
      if(low[index - i] <= centerLow)
         return EMPTY_VALUE;
     }
   return centerLow;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStdev(const double &price[], int index, int period)
  {
   if(index + period >= ArraySize(price))
      return 0.0;
   double sum = 0.0;
   for(int i = 0; i < period; i++)
     {
      sum += price[index + i];
     }
   double mean = sum / period;
   double variance = 0.0;
   for(int i = 0; i < period; i++)
     {
      variance += MathPow(price[index + i] - mean, 2);
     }
   return MathSqrt(variance / period);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetLinregSlope(const double &price[], int index, int period, int bar_index)
  {
   if(index + period >= ArraySize(price))
      return 0.0;
   double sumN = 0.0, sumPrice = 0.0, sumNPrice = 0.0, sumN2 = 0.0;
   for(int i = 0; i < period; i++)
     {
      double price_val = price[index + i];
      double n_val = bar_index + i;
      sumN += n_val;
      sumPrice += price_val;
      sumNPrice += n_val * price_val;
      sumN2 += n_val * n_val;
     }
   double sma_price_n = sumNPrice / period;
   double sma_price = sumPrice / period;
   double sma_n = sumN / period;
   double variance_n = 0.0;
   for(int i = 0; i < period; i++)
     {
      double n_val = bar_index + i;
      variance_n += MathPow(n_val - sma_n, 2);
     }
   variance_n = variance_n / period;
   if(variance_n == 0.0)
      return 0.0;
   double result = MathAbs(sma_price_n - sma_price * sma_n) / variance_n / 2.0;
   return result;
  }

bool alerted;
void checkAlert()
  {
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   if(notificationsOn == 1 && !alerted)
     {
      if(UpperBreakBuffer[0] > 0 &&  UpperBreakBuffer[0] != EMPTY_VALUE)
        {
         Notify(1);
         alerted = true;
        }
      if(LowerBreakBuffer[0] > 0 &&  LowerBreakBuffer[0] != EMPTY_VALUE)
        {
         Notify(2);
         alerted = true;
        }
     }
   if(notificationsOn == 2 && nb)
     {
      if(UpperBreakBuffer[1] > 0 &&  UpperBreakBuffer[1] != EMPTY_VALUE)
        {
         Notify(11);
        }
      if(LowerBreakBuffer[1] > 0 &&  LowerBreakBuffer[1] != EMPTY_VALUE)
        {
         Notify(22);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
     {
      lastbar = curbar;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notify(int type)
  {
   string text = "Trendline with break: ";
   switch(type)
     {
      case 1:
         text += " Break UP before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += " Break DOWN before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 11:
         text += " Broken UP after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 22:
         text += " Broken DOWN after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
     }
   text += " ";
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
   if(sound_notifications)
      PlaySound(sound_file);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
     }
   return IntegerToString(lPeriod);
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76184

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