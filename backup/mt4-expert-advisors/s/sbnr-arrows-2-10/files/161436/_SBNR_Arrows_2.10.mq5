/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        ! SBNR Arrows 2.10
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=27&p=161380#p161380
License:     GNU

── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com

── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7

── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
enum enTimeFrames
  {
   tf_cu  = 0,        // Current time frame
   tf_m1  = 1,        // 1 minute
   tf_m2  = 2,        // 2 minutes
   tf_m3  = 3,        // 3 minutes
   tf_m4  = 4,        // 4 minutes
   tf_m5  = 5,        // 5 minutes
   tf_m6  = 6,        // 6 minutes
   tf_m10 = 10,       // 10 minutes
   tf_m12 = 12,       // 12 minutes
   tf_m15 = 15,       // 15 minutes
   tf_m20 = 20,       // 20 minutes
   tf_m30 = 30,       // 30 minutes
   tf_h1  = 60,       // 1 hour
   tf_h2  = 120,      // 2 hours
   tf_h3  = 180,      // 3 hours
   tf_h4  = 240,      // 4 hours
   tf_h6  = 360,      // 6 hours
   tf_h8  = 480,      // 8 hours
   tf_h12 = 720,      // 12 hours
   tf_d1  = 1440,     // Daily
   tf_w1  = 10080,    // Weekly
   tf_mn1 = 43200,    // Monthly
   tf_n1  = -1,       // First higher time frame
   tf_n2  = -2,       // Second higher time frame
   tf_n3  = -3        // Third higher time frame
  };
input enTimeFrames        inpTimeFrame           = tf_cu;           // Time frame to use
input int                 RsiPeriod              = 4;               // RSI períod
input ENUM_MA_METHOD      MaType                 = MODE_EMA;        // MA Type
input int                 MaPeriod               = 200;             // MA Period
input bool                alertsOn               = false;           // Turn alerts on?
input bool                alertsOnCurrent        = false;           // Alerts on still opened bar?
input bool                alertsMessage          = true;            // Alerts should display message?
input bool                alertsSound            = false;           // Alerts should play a sound?
input bool                alertsNotify           = false;           // Alerts should send a notification?
input bool                alertsEmail            = false;           // Alerts should send an email?
input string              soundFile              = "alert2.wav";    // Sound file
input bool                arrowsVisible          = false;           // Arrows visible?
input bool                arrowsOnNewest         = false;           // Arrows drawn on newest bar of higher time frame bar?
input string              arrowsId               = "rsi a1";        // Unique ID for arrows
input double              arrowsUpperGap         = 1.0;             // Upper arrow gap
input double              arrowsLowerGap         = 1.0;             // Lower arrow gap
input color               arrowsUpColor          = clrLimeGreen;    // Up arrow color
input color               arrowsDnColor          = clrOrange;       // Down arrow color
input int                 arrowsUpCode           = 241;             // Up arrow code
input int                 arrowsDnCode           = 242;             // Down arrow code
input int                 arrowsSize             = 2;               // Arrows size
input bool                Interpolate            = false;           // Interpolate
double rsi[];
double ma[];
double trend[];
double count[];
int rsiHandle;
int maHandle;
int atrHandle;
struct sGlobalStruct
  {
   ENUM_TIMEFRAMES   indiTF;
  };
sGlobalStruct glo;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, rsi, INDICATOR_DATA);
   SetIndexBuffer(1, ma,  INDICATOR_DATA);
   SetIndexBuffer(2, trend, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, count, INDICATOR_CALCULATIONS);
   ArraySetAsSeries(rsi, true);
   ArraySetAsSeries(ma, true);
   ArraySetAsSeries(trend, true);
   ArraySetAsSeries(count, true);
   glo.indiTF = timeFrameValue(inpTimeFrame);
   rsiHandle = iRSI(_Symbol, glo.indiTF, RsiPeriod, PRICE_CLOSE);
   atrHandle = iATR(_Symbol, PERIOD_CURRENT, 20);
   if(rsiHandle == INVALID_HANDLE || atrHandle == INVALID_HANDLE)
     {
      Print("Error creating handles");
      return(INIT_FAILED);
     }
   IndicatorSetString(INDICATOR_SHORTNAME, timeFrameToString(glo.indiTF) + " rsi ma ");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, arrowsId + ":");
   if(rsiHandle != INVALID_HANDLE)
      IndicatorRelease(rsiHandle);
   if(atrHandle != INVALID_HANDLE)
      IndicatorRelease(atrHandle);
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
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   int limit = rates_total - prev_calculated;
   if(prev_calculated > 0)
      limit++;
   count[0] = limit;
   if(glo.indiTF != PERIOD_CURRENT)
     {
      return CalculateMTF(rates_total, prev_calculated, time, high, low, close, limit);
     }
   return CalculateCurrent(rates_total, prev_calculated, time, high, low, close, limit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalculateCurrent(const int rates_total, const int prev_calculated,
                     const datetime &time[], const double &high[],
                     const double &low[], const double &close[], int limit)
  {
   int copyCount = MathMin(rates_total, limit + MaPeriod + 10);
   double rsiArray[];
   ArraySetAsSeries(rsiArray, true);
   if(CopyBuffer(rsiHandle, 0, 0, copyCount, rsiArray) <= 0)
     {
      return(prev_calculated);
     }
   int copyLimit = MathMin(copyCount, ArraySize(rsi));
   for(int i = 0; i < copyLimit; i++)
     {
      rsi[i] = rsiArray[i];
     }
   for(int i = limit - 1; i >= 0; i--)
     {
      ma[i] = CalculateMA(i, MaPeriod, MaType);
      trend[i] = (rsi[i] > ma[i]) ? 1 : (rsi[i] < ma[i]) ? -1 : (i < rates_total - 1) ? trend[i + 1] : 0;
      if(arrowsVisible)
        {
         string lookFor = arrowsId + ":" + TimeToString(time[i]);
         ObjectDelete(0, lookFor);
         if(i < (rates_total - 1) && trend[i] != trend[i + 1])
           {
            if(trend[i] == 1)
               drawArrow(i, arrowsUpColor, arrowsUpCode, false, time, high, low);
            if(trend[i] == -1)
               drawArrow(i, arrowsDnColor, arrowsDnCode, true, time, high, low);
           }
        }
     }
   if(alertsOn)
     {
      int whichBar = alertsOnCurrent ? 0 : 1;
      if(whichBar < rates_total - 1 && trend[whichBar] != trend[whichBar + 1])
        {
         if(trend[whichBar] == 1)
            doAlert(" crossed signal up ", time);
         else
            doAlert(" crossed signal down ", time);
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalculateMTF(const int rates_total, const int prev_calculated,
                 const datetime &time[], const double &high[],
                 const double &low[], const double &close[], int limit)
  {
   int rsi_bars = BarsCalculated(rsiHandle);
   if(rsi_bars <= 0)
     {
      return(0);
     }
   int mtfBarsNeeded = (int)MathCeil((double)(limit + MaPeriod) * PeriodSeconds(PERIOD_CURRENT) / PeriodSeconds(glo.indiTF)) + 20;
   int mtfBars = MathMin(mtfBarsNeeded, rsi_bars);
   mtfBars = MathMin(mtfBars, Bars(_Symbol, glo.indiTF));
   if(mtfBars < 10)
     {
      return(prev_calculated);
     }
   double mtfRsi[];
   datetime mtfTime[];
   double mtfHigh[];
   double mtfLow[];
   ArraySetAsSeries(mtfRsi, true);
   ArraySetAsSeries(mtfTime, true);
   ArraySetAsSeries(mtfHigh, true);
   ArraySetAsSeries(mtfLow, true);
   if(CopyBuffer(rsiHandle, 0, 0, mtfBars, mtfRsi) <= 0)
     {
      return(prev_calculated);
     }
   if(CopyTime(_Symbol, glo.indiTF, 0, mtfBars, mtfTime) <= 0)
     {
      return(prev_calculated);
     }
   if(CopyHigh(_Symbol, glo.indiTF, 0, mtfBars, mtfHigh) <= 0)
     {
      return(prev_calculated);
     }
   if(CopyLow(_Symbol, glo.indiTF, 0, mtfBars, mtfLow) <= 0)
     {
      return(prev_calculated);
     }
   static double prevMtfMa[];
   static datetime prevMtfTime0 = 0;
   double mtfMa[];
   ArrayResize(mtfMa, mtfBars);
   ArraySetAsSeries(mtfMa, true);
   ArrayInitialize(mtfMa, 0);
   bool newMtfBar = (prevMtfTime0 != mtfTime[0]);
   if(ArraySize(prevMtfMa) > 0 && prev_calculated > 0 && !newMtfBar)
     {
      int copySize = MathMin(ArraySize(prevMtfMa), mtfBars);
      for(int i = 0; i < copySize; i++)
         mtfMa[i] = prevMtfMa[i];
     }
   else
     {
      int mtfMaLimit = MathMin(mtfBars, ArraySize(mtfRsi));
      for(int i = 0; i < mtfMaLimit; i++)
        {
         if(i + MaPeriod <= ArraySize(mtfRsi))
           {
            mtfMa[i] = CalculateMAOnArray(mtfRsi, MaPeriod, 0, MaType, i);
           }
         else
            if(ArraySize(mtfRsi) > 0 && i < ArraySize(mtfRsi))
              {
               int availablePeriod = MathMin(MaPeriod, ArraySize(mtfRsi) - i);
               if(availablePeriod > 10)
                  mtfMa[i] = CalculateMAOnArray(mtfRsi, availablePeriod, 0, MaType, i);
              }
        }
      ArrayResize(prevMtfMa, mtfBars);
      ArrayCopy(prevMtfMa, mtfMa);
      ArraySetAsSeries(prevMtfMa, true);
      prevMtfTime0 = mtfTime[0];
     }
   for(int i = limit - 1; i >= 0; i--)
     {
      int mtfBar = -1;
      for(int j = 0; j < mtfBars - 1; j++)
        {
         if(time[i] >= mtfTime[j])
           {
            mtfBar = j;
            break;
           }
        }
      if(mtfBar >= 0 && mtfBar < mtfBars && mtfBar < ArraySize(mtfMa))
        {
         rsi[i] = mtfRsi[mtfBar];
         ma[i] = mtfMa[mtfBar];
         if(Interpolate && i > 0)
           {
            int nextBar = -1;
            for(int j = mtfBar + 1; j < mtfBars; j++)
              {
               if(time[i - 1] >= mtfTime[j])
                 {
                  nextBar = j;
                  break;
                 }
              }
            if(nextBar >= 0 && nextBar != mtfBar)
              {
               datetime mtfBarTime = mtfTime[mtfBar];
               int n = 0;
               for(int k = i; k < rates_total && time[k] >= mtfBarTime; k++)
                  n++;
               if(n > 1)
                 {
                  for(int k = 1; k < n && (i + k) < rates_total; k++)
                    {
                     rsi[i + k] = rsi[i] + (rsi[i + n] - rsi[i]) * k / n;
                     ma[i + k] = ma[i] + (ma[i + n] - ma[i]) * k / n;
                    }
                 }
              }
           }
        }
     }
   for(int i = limit - 1; i >= 0; i--)
     {
      trend[i] = (rsi[i] > ma[i]) ? 1 : (rsi[i] < ma[i]) ? -1 : (i < rates_total - 1) ? trend[i + 1] : 0;
      if(arrowsVisible)
        {
         string lookFor = arrowsId + ":" + TimeToString(time[i]);
         ObjectDelete(0, lookFor);
         if(i < (rates_total - 1) && trend[i] != trend[i + 1])
           {
            if(trend[i] == 1)
               drawArrow(i, arrowsUpColor, arrowsUpCode, false, time, high, low);
            if(trend[i] == -1)
               drawArrow(i, arrowsDnColor, arrowsDnCode, true, time, high, low);
           }
        }
     }
   if(alertsOn)
     {
      int whichBar = alertsOnCurrent ? 0 : 1;
      if(whichBar < rates_total - 1 && trend[whichBar] != trend[whichBar + 1])
        {
         if(trend[whichBar] == 1)
            doAlert(" crossed signal up ", time);
         else
            doAlert(" crossed signal down ", time);
        }
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateMA(int shift, int period, ENUM_MA_METHOD maType)
  {
   if(shift + period > ArraySize(rsi))
      return 0;
   double sum = 0;
   double weights = 0;
   switch(maType)
     {
      case MODE_SMA:
        {
         for(int i = 0; i < period; i++)
            sum += rsi[shift + i];
         return sum / period;
        }
      case MODE_EMA:
        {
         double alpha = 2.0 / (period + 1.0);
         double sum = 0;
         for(int j = 0; j < period; j++)
            sum += rsi[shift + period - 1 - j];
         double ema = sum / period;
         for(int j = period - 2; j >= 0; j--)
            ema = alpha * rsi[shift + j] + (1.0 - alpha) * ema;
         return ema;
        }
      case MODE_SMMA:
        {
         sum = 0;
         for(int i = 0; i < period; i++)
            sum += rsi[shift + i];
         return sum / period;
        }
      case MODE_LWMA:
        {
         for(int i = 0; i < period; i++)
           {
            double weight = period - i;
            sum += rsi[shift + i] * weight;
            weights += weight;
           }
         return sum / weights;
        }
     }
   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateMAOnArray(const double &array[], int period, int ma_shift, ENUM_MA_METHOD ma_method, int shift)
  {
   if(shift + period > ArraySize(array))
      return 0;
   double sum = 0;
   double weights = 0;
   switch(ma_method)
     {
      case MODE_SMA:
        {
         for(int i = 0; i < period; i++)
            sum += array[shift + i];
         return sum / period;
        }
      case MODE_EMA:
        {
         double alpha = 2.0 / (period + 1.0);
         double sum = 0;
         for(int j = 0; j < period; j++)
            sum += array[shift + period - 1 - j];
         double ema = sum / period;
         for(int j = period - 2; j >= 0; j--)
            ema = alpha * array[shift + j] + (1.0 - alpha) * ema;
         return ema;
        }
      case MODE_SMMA:
        {
         sum = 0;
         for(int i = 0; i < period; i++)
            sum += array[shift + i];
         return sum / period;
        }
      case MODE_LWMA:
        {
         for(int i = 0; i < period; i++)
           {
            double weight = period - i;
            sum += array[shift + i] * weight;
            weights += weight;
           }
         return sum / weights;
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawArrow(int i, color theColor, int theCode, bool tup,
               const datetime &time[], const double &high[], const double &low[])
  {
   string name = arrowsId + ":" + TimeToString(time[i]);
   double atrArray[];
   ArraySetAsSeries(atrArray, true);
   CopyBuffer(atrHandle, 0, i, 1, atrArray);
   double gap = atrArray[0];
   datetime objTime = time[i];
   if(arrowsOnNewest)
      objTime += PeriodSeconds(PERIOD_CURRENT) - 1;
   double price;
   if(tup)
      price = high[i] + arrowsUpperGap * gap;
   else
      price = low[i] - arrowsLowerGap * gap;
   ObjectCreate(0, name, OBJ_ARROW, 0, objTime, price);
   ObjectSetInteger(0, name, OBJPROP_ARROWCODE, theCode);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, arrowsSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, theColor);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(string doWhat, const datetime &time[])
  {
   static string previousAlert = "nothing";
   static datetime previousTime;
   if(previousAlert != doWhat || previousTime != time[0])
     {
      previousAlert = doWhat;
      previousTime = time[0];
      string message = timeFrameToString(PERIOD_CURRENT) + " " +
                       _Symbol + " at " + TimeToString(TimeLocal(), TIME_SECONDS) +
                       " rsi ma " + doWhat;
      if(alertsMessage)
         Alert(message);
      if(alertsNotify)
         SendNotification(message);
      if(alertsEmail)
         SendMail(_Symbol + " rsi ma ", message);
      if(alertsSound)
         PlaySound(soundFile);
     }
  }
ENUM_TIMEFRAMES tfTable[] = {PERIOD_M1, PERIOD_M2, PERIOD_M3, PERIOD_M4, PERIOD_M5, PERIOD_M6,
                             PERIOD_M10, PERIOD_M12, PERIOD_M15, PERIOD_M20, PERIOD_M30,
                             PERIOD_H1, PERIOD_H2, PERIOD_H3, PERIOD_H4, PERIOD_H6, PERIOD_H8, PERIOD_H12,
                             PERIOD_D1, PERIOD_W1, PERIOD_MN1
                            };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(ENUM_TIMEFRAMES tf)
  {
   int seconds = PeriodSeconds(tf);
   int minutes = seconds / 60;
   int hours = minutes / 60;
   int days = hours / 24;
   if(seconds < 60)
      return "S" + IntegerToString(seconds);
   if(minutes < 60)
      return "M" + IntegerToString(minutes);
   if(hours < 24)
      return "H" + IntegerToString(hours);
   if(days < 7)
      return "D" + IntegerToString(days);
   if(days >= 7 && days < 30)
      return "W" + IntegerToString(days / 7);
   return "MN" + IntegerToString(days / 30);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES timeFrameValue(int _tf)
  {
   int add = (_tf >= 0) ? 0 : MathAbs(_tf);
   if(_tf == 0)
      return PERIOD_CURRENT;
   int size = ArraySize(tfTable);
   int currentMinutes = PeriodSeconds(PERIOD_CURRENT) / 60;
   if(add > 0)
     {
      for(int i = 0; i < size; i++)
        {
         if(PeriodSeconds(tfTable[i]) / 60 >= currentMinutes)
           {
            return tfTable[(int)MathMin(i + add, size - 1)];
           }
        }
      return PERIOD_CURRENT;
     }
   for(int i = 0; i < size; i++)
     {
      if((int)tfTable[i] == _tf || PeriodSeconds(tfTable[i]) / 60 == _tf)
        {
         return tfTable[i];
        }
     }
   return PERIOD_CURRENT;
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        ! SBNR Arrows 2.10
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=27&p=161380#p161380
License:     GNU

── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com

── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7

── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
