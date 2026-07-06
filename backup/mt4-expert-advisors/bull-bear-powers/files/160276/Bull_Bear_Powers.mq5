//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76247

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
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGreen
#property indicator_style1  0
#property indicator_width1  2
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  0
#property indicator_width2  2
#property indicator_type3   DRAW_COLOR_ARROW
#property indicator_color3  clrRed, clrGreen, clrOrange
#property indicator_style3  0
#property indicator_width3  2


enum sLevel
  {
   s0, // No smoothing
   s1, // Smoothing level 1
   s2  // Smoothing level 2
  };
input ENUM_TIMEFRAMES TF = PERIOD_CURRENT;
input int Momentum_period = 14; // Momentum Period
input sLevel smoothingLevel = s0; // Smoothing
input int arrow_code = 84; // Arrow code
input int max_bars = 1000; // Maximum number of bars to calculate
enum alert
  {
   Off = 0, // Off
   Current = 1, // At current bar
   Previous = 2 // At previous closed bar
  };
input alert  notificationsOn       = Current;                // Notifications
input bool   desktop_notifications = true;                   // Desktop MT4 notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push mobile notifications
input bool   sound_notifications   = false;                  // Sound notifications
input string sound_file = "Tick.wav";                        // Choose a sound file for notifications

double bull[], bear[], arrow[], col[], bullMA[], bearMA[];
double bullSmoothed[], bearSmoothed[];
double bull_min, bear_min;
string short_name;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, bull, INDICATOR_DATA);
   SetIndexBuffer(1, bear, INDICATOR_DATA);
   SetIndexBuffer(2, arrow, INDICATOR_DATA);
   SetIndexBuffer(3, col, INDICATOR_DATA);
   SetIndexBuffer(4, bullMA, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, bearMA, INDICATOR_CALCULATIONS);
   ArrayResize(bullSmoothed, max_bars + 100);
   ArrayResize(bearSmoothed, max_bars + 100);
   ArraySetAsSeries(bullSmoothed, true);
   ArraySetAsSeries(bearSmoothed, true);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_COLOR_ARROW);
   PlotIndexSetInteger(2, PLOT_ARROW, arrow_code);
   PlotIndexSetInteger(3, PLOT_COLOR_INDEXES, 3);
   short_name = "Bull Bear Power (" + GetTimeFrame((int)TF) + ")";
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   ArraySetAsSeries(bull, true);
   ArraySetAsSeries(bear, true);
   ArraySetAsSeries(arrow, true);
   ArraySetAsSeries(col, true);
   ArraySetAsSeries(bullMA, true);
   ArraySetAsSeries(bearMA, true);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int barShift(int b)
  {
   if(TF <= PERIOD_CURRENT || TF == _Period)
      return b;
   datetime barTime = iTime(_Symbol, _Period, b);
   if(barTime == 0)
      return -1;
   int shift = iBarShift(_Symbol, TF, barTime, false);
   return shift;
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
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);
   ArraySetAsSeries(volume, true);
   ArraySetAsSeries(spread, true);
   int limit = MathMin(rates_total, max_bars);
   int p = 0;
   if(smoothingLevel == s1)
      p = 2;
   else
      if(smoothingLevel == s2)
         p = 3;
   for(int i = limit; i >= 0; i--)
     {
      int mtfShift = barShift(i);
      if(mtfShift >= 0)
        {
         bullMA[i] = iBullsPowerMQL4(_Symbol, TF, Momentum_period, PRICE_CLOSE, mtfShift);
         bearMA[i] = iBearsPowerMQL4(_Symbol, TF, Momentum_period, PRICE_CLOSE, mtfShift) * (-1);
        }
      else
        {
         if(i < limit)
           {
            bullMA[i] = bullMA[i + 1];
            bearMA[i] = bearMA[i + 1];
           }
         else
           {
            bullMA[i] = 0;
            bearMA[i] = 0;
           }
        }
     }
   if(p > 0)
     {
      for(int i = limit; i >= 0; i--)
        {
         bullSmoothed[i] = iMAOnArrayMQL4(bullMA, 0, p, 0, MODE_SMA, i);
         bearSmoothed[i] = iMAOnArrayMQL4(bearMA, 0, p, 0, MODE_SMA, i);
        }
      for(int i = limit; i >= 0; i--)
        {
         bull[i] = bullSmoothed[i] / Point();
         bear[i] = bearSmoothed[i] / Point();
        }
     }
   else
     {
      for(int i = limit; i >= 0; i--)
        {
         bull[i] = bullMA[i] / Point();
         bear[i] = bearMA[i] / Point();
        }
     }
   if(limit > 0)
     {
      bull_min = bull[0];
      bear_min = bear[0];
      for(int i = limit; i >= 0; i--)
        {
         if(bull[i] < bull_min)
            bull_min = bull[i];
         if(bear[i] < bear_min)
            bear_min = bear[i];
        }
      for(int i = limit; i >= 0; i--)
        {
         if(bull_min < 0)
            bull[i] = bull[i] - bull_min;
         if(bear_min < 0)
            bear[i] = bear[i] - bear_min;
        }
     }
   for(int i = limit; i >= 0; i--)
     {
      arrow[i] = 0;
     }
   for(int i = limit; i >= 0; i--)
     {
      col[i] = 2;
      int mtfShift = barShift(i);
      int prevMtfShift = barShift(i + 1);
      if(mtfShift >= 0 && prevMtfShift >= 0)
        {
         if(mtfShift == prevMtfShift && i < limit)
           {
            col[i] = col[i + 1];
           }
         else
           {
            if(bear[i] > bear[i + 1] && bear[i] > bull[i])
              {
               col[i] = 0;
              }
            else
               if(bull[i] > bull[i + 1] && bull[i] > bear[i])
                 {
                  col[i] = 1;
                 }
           }
        }
     }
   if(notificationsOn > 0)
     {
      checkAlert();
     }
   return(rates_total);
  }

bool alerted;
void checkAlert()
  {
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   if(notificationsOn == 1 && !alerted)
     {
      if(col[0] == 1 && (col[1] == 0 || col[1] == 2))
        {
         Notify(1);
         alerted = true;
        }
      if(col[0] == 0 && (col[1] == 1 || col[1] == 2))
        {
         Notify(2);
         alerted = true;
        }
     }
   if(notificationsOn == 2 && nb)
     {
      if(col[1] == 1 && (col[2] == 0 || col[2] == 2))
        {
         Notify(11);
        }
      if(col[1] == 0 && (col[2] == 1 || col[2] == 2))
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
   string text = "Bull Bear Powers (" + GetTimeFrame((int)TF) + "): ";
   switch(type)
     {
      case 1:
         text += " Turn UP before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += " Turn DOWN before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 11:
         text += " Turn UP after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 22:
         text += " Turn DOWN after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
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
//|                                                                  |
//+------------------------------------------------------------------+
double iBullsPowerMQL4(string symbol, int tf, int period, int price, int shift)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   int handle = iBullsPower(symbol, timeframe, period);
   if(handle < 0)
     {
      Print("The iBullsPower object is not created: Error", GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle, 0, shift));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iBearsPowerMQL4(string symbol, int tf, int period, int price, int shift)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   int handle = iBearsPower(symbol, timeframe, period);
   if(handle < 0)
     {
      Print("The iBearsPower object is not created: Error", GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle, 0, shift));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CopyBufferMQL4(int handle, int index, int shift)
  {
   double buf[];
   switch(index)
     {
      case 0:
         if(CopyBuffer(handle, 0, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 1:
         if(CopyBuffer(handle, 1, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 2:
         if(CopyBuffer(handle, 2, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 3:
         if(CopyBuffer(handle, 3, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 4:
         if(CopyBuffer(handle, 4, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      default:
         break;
     }
   return(EMPTY_VALUE);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0:
         return(PERIOD_CURRENT);
      case 1:
         return(PERIOD_M1);
      case 5:
         return(PERIOD_M5);
      case 15:
         return(PERIOD_M15);
      case 30:
         return(PERIOD_M30);
      case 60:
         return(PERIOD_H1);
      case 240:
         return(PERIOD_H4);
      case 1440:
         return(PERIOD_D1);
      case 10080:
         return(PERIOD_W1);
      case 43200:
         return(PERIOD_MN1);
      case 2:
         return(PERIOD_M2);
      case 3:
         return(PERIOD_M3);
      case 4:
         return(PERIOD_M4);
      case 6:
         return(PERIOD_M6);
      case 10:
         return(PERIOD_M10);
      case 12:
         return(PERIOD_M12);
      case 16385:
         return(PERIOD_H1);
      case 16386:
         return(PERIOD_H2);
      case 16387:
         return(PERIOD_H3);
      case 16388:
         return(PERIOD_H4);
      case 16390:
         return(PERIOD_H6);
      case 16392:
         return(PERIOD_H8);
      case 16396:
         return(PERIOD_H12);
      case 16408:
         return(PERIOD_D1);
      case 32769:
         return(PERIOD_W1);
      case 49153:
         return(PERIOD_MN1);
      default:
         return(PERIOD_CURRENT);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iMAOnArrayMQL4(double &array[], int total, int period, int ma_shift, int ma_method, int shift)
  {
   double buf[], arr[];
   if(total == 0)
      total = ArraySize(array);
   if(total > 0 && total <= period)
      return(0);
   if(shift > total - period - ma_shift)
      return(0);
   switch(ma_method)
     {
      case MODE_SMA :
        {
         total = ArrayCopy(arr, array, 0, shift + ma_shift, period);
         if(ArrayResize(buf, total) < 0)
            return(0);
         double sum = 0;
         int    i, pos = total - 1;
         for(i = 1; i < period; i++, pos--)
            sum += arr[pos];
         while(pos >= 0)
           {
            sum += arr[pos];
            buf[pos] = sum / period;
            sum -= arr[pos + period - 1];
            pos--;
           }
         return(buf[0]);
        }
      case MODE_EMA :
        {
         if(ArrayResize(buf, total) < 0)
            return(0);
         double pr = 2.0 / (period + 1);
         int    pos = total - 2;
         while(pos >= 0)
           {
            if(pos == total - 2)
               buf[pos + 1] = array[pos + 1];
            buf[pos] = array[pos] * pr + buf[pos + 1] * (1 - pr);
            pos--;
           }
         return(buf[shift + ma_shift]);
        }
      case MODE_SMMA :
        {
         if(ArrayResize(buf, total) < 0)
            return(0);
         double sum = 0;
         int    i, k, pos;
         pos = total - period;
         while(pos >= 0)
           {
            if(pos == total - period)
              {
               for(i = 0, k = pos; i < period; i++, k++)
                 {
                  sum += array[k];
                  buf[k] = 0;
                 }
              }
            else
               sum = buf[pos + 1] * (period - 1) + array[pos];
            buf[pos] = sum / period;
            pos--;
           }
         return(buf[shift + ma_shift]);
        }
      case MODE_LWMA :
        {
         if(ArrayResize(buf, total) < 0)
            return(0);
         double sum = 0.0, lsum = 0.0;
         double price;
         int    i, weight = 0, pos = total - 1;
         for(i = 1; i <= period; i++, pos--)
           {
            price = array[pos];
            sum += price * i;
            lsum += price;
            weight += i;
           }
         pos++;
         i = pos + period;
         while(pos >= 0)
           {
            buf[pos] = sum / weight;
            if(pos == 0)
               break;
            pos--;
            i--;
            price = array[pos];
            sum = sum - lsum + price * period;
            lsum -= array[i];
            lsum += price;
           }
         return(buf[shift + ma_shift]);
        }
      default:
         return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76247

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