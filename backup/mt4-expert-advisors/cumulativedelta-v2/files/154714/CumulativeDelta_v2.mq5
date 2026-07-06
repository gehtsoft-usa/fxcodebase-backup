// ── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        Cummulative Delta v2
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=155553#p155553
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
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
#property indicator_buffers 17
#property indicator_plots 13

input bool    showCumulative = true;
input bool    recordTicks = true;
input bool    printHistory = true;
input color   dnColor = clrCrimson;
input color   upColor = clrGreen;
input bool    showCorr = false;
input int     corrPeriod = 20;

double closed[], opened[], highed[], lowed[];
double Up_Body_Green[];
double Dn_Body_Red[];
double EqBodyBuffer[];
double Bg_Body_Black[];
double Up_Wick_Green[];
double Dn_Wick_Red[];
double EqShadowBuffer[];
double Bg_Wick_Black[];
double Dn_Body_Green[];
double Up_Body_Red[];
double Dn_Wick_Green[];
double Up_Wick_Red[];
double correlation[];

double Curr_Bid;
double Prev_Bid;
double Curr_Ask;
double Prev_Ask;
double Curr_Vol;
double Prev_Vol;
datetime timestamp;
color bkg_color;
int handle = INVALID_HANDLE;
bool firstTick = true;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetInteger(INDICATOR_DIGITS, 0);
   SetIndexBuffer(0, Up_Body_Green, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, upColor);
   SetIndexBuffer(1, Dn_Body_Red, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, dnColor);
   SetIndexBuffer(2, EqBodyBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(2, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, clrWhite);
   SetIndexBuffer(3, Bg_Body_Black, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(3, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, clrBlack);
   SetIndexBuffer(4, Up_Wick_Green, INDICATOR_DATA);
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(4, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(4, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, upColor);
   SetIndexBuffer(5, Dn_Wick_Red, INDICATOR_DATA);
   PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(5, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(5, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, dnColor);
   SetIndexBuffer(6, EqShadowBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(6, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(6, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(6, PLOT_LINE_COLOR, clrWhite);
   SetIndexBuffer(7, Bg_Wick_Black, INDICATOR_DATA);
   PlotIndexSetInteger(7, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(7, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(7, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(7, PLOT_LINE_COLOR, clrBlack);
   SetIndexBuffer(8, Dn_Body_Green, INDICATOR_DATA);
   PlotIndexSetInteger(8, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(8, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(8, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(8, PLOT_LINE_COLOR, upColor);
   SetIndexBuffer(9, Up_Body_Red, INDICATOR_DATA);
   PlotIndexSetInteger(9, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(9, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(9, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(9, PLOT_LINE_COLOR, dnColor);
   SetIndexBuffer(10, Dn_Wick_Green, INDICATOR_DATA);
   PlotIndexSetInteger(10, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(10, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(10, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(10, PLOT_LINE_COLOR, upColor);
   SetIndexBuffer(11, Up_Wick_Red, INDICATOR_DATA);
   PlotIndexSetInteger(11, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(11, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(11, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(11, PLOT_LINE_COLOR, dnColor);
   SetIndexBuffer(12, correlation, INDICATOR_DATA);
   PlotIndexSetInteger(12, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(12, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(12, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(12, PLOT_LINE_COLOR, clrYellow);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(6, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(7, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(8, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(9, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(10, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(11, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(12, PLOT_EMPTY_VALUE, 0.0);
   SetIndexBuffer(13, closed, INDICATOR_CALCULATIONS);
   SetIndexBuffer(14, opened, INDICATOR_CALCULATIONS);
   SetIndexBuffer(15, highed, INDICATOR_CALCULATIONS);
   SetIndexBuffer(16, lowed, INDICATOR_CALCULATIONS);
   ArraySetAsSeries(closed, true);
   ArraySetAsSeries(opened, true);
   ArraySetAsSeries(highed, true);
   ArraySetAsSeries(lowed, true);
   ArraySetAsSeries(Up_Body_Green, true);
   ArraySetAsSeries(Dn_Body_Red, true);
   ArraySetAsSeries(EqBodyBuffer, true);
   ArraySetAsSeries(Bg_Body_Black, true);
   ArraySetAsSeries(Up_Wick_Green, true);
   ArraySetAsSeries(Dn_Wick_Red, true);
   ArraySetAsSeries(EqShadowBuffer, true);
   ArraySetAsSeries(Bg_Wick_Black, true);
   ArraySetAsSeries(Dn_Body_Green, true);
   ArraySetAsSeries(Up_Body_Red, true);
   ArraySetAsSeries(Dn_Wick_Green, true);
   ArraySetAsSeries(Up_Wick_Red, true);
   ArraySetAsSeries(correlation, true);
   int buf_size = ArraySize(closed);
   if(buf_size > 1)
     {
      closed[1] = 0.0;
      opened[1] = 0.0;
      highed[1] = 0.0;
      lowed[1] = 0.0;
     }
   if(buf_size > 0)
     {
      closed[0] = 0.0;
      opened[0] = 0.0;
      highed[0] = 0.0;
      lowed[0] = 0.0;
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(handle != INVALID_HANDLE)
     {
      FileClose(handle);
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
   if(rates_total < 2)
      return(rates_total);
   const int latest = rates_total - 1;
   const datetime current_time = time[latest];
   bkg_color = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, bkg_color);
   PlotIndexSetInteger(7, PLOT_LINE_COLOR, bkg_color);
   Prev_Bid = Curr_Bid;
   Curr_Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   Prev_Ask = Curr_Ask;
   Curr_Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   Prev_Vol = Curr_Vol;
   Curr_Vol = (double)tick_volume[latest];
   if(current_time != timestamp && firstTick == false && showCumulative == true)
     {
      closed[0] = closed[1];
      opened[0] = closed[1];
      highed[0] = closed[1];
      lowed[0] = closed[1];
      Prev_Vol = Curr_Vol;
      timestamp = current_time;
     }
   if(current_time != timestamp && firstTick == false && showCumulative == false)
     {
      closed[0] = 0;
      opened[0] = 0;
      highed[0] = 0;
      lowed[0] = 0;
      Prev_Vol = Curr_Vol;
      timestamp = current_time;
     }
   if(firstTick == true)
      initialize();
   if(recordTicks == true && (Curr_Vol - Prev_Vol > 0 && (Prev_Ask != Curr_Ask || Prev_Bid != Curr_Bid)))
     {
      if(handle != INVALID_HANDLE)
        {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), Curr_Bid, Curr_Ask, Curr_Vol - Prev_Vol);
        }
     }
   updateTickValues();
   printBar(0);
   PlotIndexSetInteger(12, PLOT_DRAW_TYPE, showCorr ? DRAW_LINE : DRAW_NONE);
   if(showCorr)
     {
      double openSeries[];
      double closeSeries[];
      if(ArrayResize(openSeries, rates_total) != rates_total)
         return(rates_total);
      if(ArrayResize(closeSeries, rates_total) != rates_total)
         return(rates_total);
      if(ArrayCopy(openSeries, open, 0, 0, rates_total) != rates_total)
         return(rates_total);
      if(ArrayCopy(closeSeries, close, 0, 0, rates_total) != rates_total)
         return(rates_total);
      ArraySetAsSeries(openSeries, true);
      ArraySetAsSeries(closeSeries, true);
      calcCorr(rates_total, openSeries, closeSeries);
     }
   else
     {
      ArrayInitialize(correlation, 0.0);
     }
   return(rates_total);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initialize()
  {
   string nm = "Ticks_" + _Symbol + ".csv";
   Print(nm);
   if(printHistory == true)
     {
      handle = FileOpen(nm, FILE_CSV | FILE_READ | FILE_WRITE, ',');
      if(handle == INVALID_HANDLE)
        {
         Print("Could Not Create/Open File ", GetLastError());
        }
      else
        {
         Print("File Opened Successfully");
         FileSeek(handle, 0, SEEK_SET);
         if(!FileIsEnding(handle))
            readData();
        }
     }
   if(recordTicks == true && handle == INVALID_HANDLE)
     {
      handle = FileOpen(nm, FILE_CSV | FILE_READ | FILE_WRITE, ',');
      if(handle == INVALID_HANDLE)
        {
         Print("Could Not Create/Open File ", GetLastError());
        }
      else
        {
         Print("File Opened Successfully");
         FileSeek(handle, 0, SEEK_END);
        }
     }
   if(recordTicks == true && handle != INVALID_HANDLE)
     {
      FileSeek(handle, 0, SEEK_END);
     }
   datetime timeArray[];
   CopyTime(_Symbol, PERIOD_CURRENT, 0, 1, timeArray);
   Prev_Vol = (double)iVolumeC(_Symbol, PERIOD_CURRENT, 0);
   Curr_Vol = Prev_Vol;
   firstTick = false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void readData()
  {
   datetime time1 = StringToTime(FileReadString(handle));
   double bid1 = StringToDouble(FileReadString(handle));
   double ask1 = StringToDouble(FileReadString(handle));
   double volume1 = StringToDouble(FileReadString(handle));
   datetime timeArray[];
   int copied = CopyTime(_Symbol, PERIOD_CURRENT, 0, Bars(_Symbol, PERIOD_CURRENT), timeArray);
   ArraySetAsSeries(timeArray, true);
   int i = 0;
   while(i < copied && time1 <= timeArray[i])
     {
      i++;
     }
   if(i < ArraySize(opened))
     {
      opened[i] = 0;
      closed[i] = 0;
      highed[i] = 0;
      lowed[i] = 0;
     }
   datetime time2 = time1;
   for(int j = i; j > -1; j--)
     {
      if(j > 0)
        {
         while((time2 < timeArray[j - 1]) && !FileIsEnding(handle))
           {
            time2 = StringToTime(FileReadString(handle));
            double bid2 = StringToDouble(FileReadString(handle));
            double ask2 = StringToDouble(FileReadString(handle));
            double volume2 = StringToDouble(FileReadString(handle));
            if(ask2 > ask1)
              {
               closed[j] = closed[j] + volume2;
              }
            if(bid2 < bid1)
              {
               closed[j] = closed[j] - volume2;
              }
            if(closed[j] > highed[j])
              {
               highed[j] = closed[j];
              }
            if(closed[j] < lowed[j])
              {
               lowed[j] = closed[j];
              }
            if(showCumulative == false)
              {
               closed[j] = closed[j] - opened[j];
               highed[j] = highed[j] - opened[j];
               lowed[j] = lowed[j] - opened[j];
               opened[j] = 0;
              }
            printBar(j);
            time1 = time2;
            bid1 = bid2;
            ask1 = ask2;
            volume1 = volume2;
           }
        }
      if(j == 0)
        {
         while(!FileIsEnding(handle))
           {
            time2 = StringToTime(FileReadString(handle));
            double bid2 = StringToDouble(FileReadString(handle));
            double ask2 = StringToDouble(FileReadString(handle));
            double volume2 = StringToDouble(FileReadString(handle));
            if(ask2 > ask1)
              {
               closed[j] = closed[j] + volume2;
              }
            if(bid2 < bid1)
              {
               closed[j] = closed[j] - volume2;
              }
            if(closed[j] > highed[j])
              {
               highed[j] = closed[j];
              }
            if(closed[j] < lowed[j])
              {
               lowed[j] = closed[j];
              }
            printBar(j);
            time1 = time2;
            bid1 = bid2;
            ask1 = ask2;
            volume1 = volume2;
           }
        }
      if(j > 0 && j - 1 >= 0 && j < ArraySize(opened) && j - 1 < ArraySize(opened))
        {
         opened[j - 1] = closed[j];
         highed[j - 1] = closed[j];
         lowed[j - 1] = closed[j];
         closed[j - 1] = closed[j];
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void printBar(int pos)
  {
   Up_Body_Green[pos] = 0.0;
   Dn_Body_Red[pos] = 0.0;
   EqBodyBuffer[pos] = 0.0;
   Bg_Body_Black[pos] = 0.0;
   Up_Wick_Green[pos] = 0.0;
   Dn_Wick_Red[pos] = 0.0;
   EqShadowBuffer[pos] = 0.0;
   Bg_Wick_Black[pos] = 0.0;
   Dn_Body_Green[pos] = 0.0;
   Up_Body_Red[pos] = 0.0;
   Dn_Wick_Green[pos] = 0.0;
   Up_Wick_Red[pos] = 0.0;
   if(closed[pos] > 0 && opened[pos] >= 0 && lowed[pos] >= 0 && highed[pos] > 0)
     {
      if(closed[pos] > opened[pos])
        {
         Up_Body_Green[pos] = closed[pos];
         Bg_Body_Black[pos] = opened[pos];
         Up_Wick_Green[pos] = highed[pos];
         Bg_Wick_Black[pos] = lowed[pos];
        }
      if(closed[pos] < opened[pos])
        {
         Dn_Body_Red[pos] = opened[pos];
         Bg_Body_Black[pos] = closed[pos];
         Dn_Wick_Red[pos] = highed[pos];
         Bg_Wick_Black[pos] = lowed[pos];
        }
     }
   else
      if(closed[pos] >= 0 && opened[pos] >= 0 && lowed[pos] < 0 && highed[pos] > 0)
        {
         if(closed[pos] > opened[pos])
           {
            Up_Body_Green[pos] = closed[pos];
            Bg_Body_Black[pos] = opened[pos];
            Up_Wick_Green[pos] = highed[pos];
            Dn_Wick_Green[pos] = lowed[pos];
           }
         if(closed[pos] < opened[pos])
           {
            Up_Body_Red[pos] = opened[pos];
            Bg_Body_Black[pos] = closed[pos];
            Up_Wick_Red[pos] = highed[pos];
            Dn_Wick_Red[pos] = lowed[pos];
           }
        }
      else
         if(closed[pos] > 0 && opened[pos] < 0)
           {
            Up_Body_Green[pos] = closed[pos];
            Up_Wick_Green[pos] = highed[pos];
            Dn_Body_Green[pos] = opened[pos];
            Dn_Wick_Green[pos] = lowed[pos];
           }
         else
            if(closed[pos] < 0 && opened[pos] <= 0 && lowed[pos] < 0 && highed[pos] <= 0)
              {
               if(closed[pos] > opened[pos])
                 {
                  Up_Body_Green[pos] = opened[pos];
                  Bg_Body_Black[pos] = closed[pos];
                  Up_Wick_Green[pos] = lowed[pos];
                  Bg_Wick_Black[pos] = highed[pos];
                 }
               if(closed[pos] < opened[pos])
                 {
                  Dn_Body_Red[pos] = closed[pos];
                  Bg_Body_Black[pos] = opened[pos];
                  Dn_Wick_Red[pos] = lowed[pos];
                  Bg_Wick_Black[pos] = highed[pos];
                 }
              }
            else
               if(closed[pos] <= 0 && opened[pos] <= 0 && lowed[pos] < 0 && highed[pos] > 0)
                 {
                  if(closed[pos] > opened[pos])
                    {
                     Up_Body_Green[pos] = opened[pos];
                     Bg_Body_Black[pos] = closed[pos];
                     Up_Wick_Green[pos] = highed[pos];
                     Dn_Wick_Green[pos] = lowed[pos];
                    }
                  if(closed[pos] < opened[pos])
                    {
                     Dn_Body_Red[pos] = closed[pos];
                     Bg_Body_Black[pos] = opened[pos];
                     Up_Wick_Red[pos] = highed[pos];
                     Dn_Wick_Red[pos] = lowed[pos];
                    }
                 }
               else
                  if(closed[pos] < 0 && opened[pos] > 0)
                    {
                     Dn_Body_Red[pos] = closed[pos];
                     Up_Wick_Red[pos] = highed[pos];
                     Up_Body_Red[pos] = opened[pos];
                     Dn_Wick_Red[pos] = lowed[pos];
                    }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void updateTickValues()
  {
   if(Curr_Ask > Prev_Ask)
     {
      closed[0] = closed[0] + (Curr_Vol - Prev_Vol);
      if(closed[0] > highed[0])
        {
         highed[0] = closed[0];
        }
      if(closed[0] < lowed[0])
        {
         lowed[0] = closed[0];
        }
     }
   if(Curr_Bid < Prev_Bid)
     {
      closed[0] = closed[0] - (Curr_Vol - Prev_Vol);
      if(closed[0] > highed[0])
        {
         highed[0] = closed[0];
        }
      if(closed[0] < lowed[0])
        {
         lowed[0] = closed[0];
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calcCorr(const int rates_total, const double &openSeries[], const double &closeSeries[])
  {
   ArrayInitialize(correlation, 0.0);
   if(corrPeriod <= 0)
      return;
   int bars_for_calc = rates_total;
   const int open_series_size = ArraySize(openSeries);
   if(open_series_size > 0 && bars_for_calc > open_series_size)
      bars_for_calc = open_series_size;
   int buffer_bars = bars_for_calc;
   const int closed_size = ArraySize(closed);
   if(closed_size > 0 && buffer_bars > closed_size)
      buffer_bars = closed_size;
   if(buffer_bars <= corrPeriod)
      return;
   for(int i = buffer_bars - 1 - corrPeriod; i >= 0; i--)
     {
      double A = 0.0;
      double B = 0.0;
      double C = 0.0;
      double sumY = 0.0;
      double sumX = 0.0;
      for(int p = i + corrPeriod; p >= i; p--)
        {
         sumY += (closeSeries[p] - openSeries[p]);
         sumX += (closed[p] - opened[p]);
        }
      const double meanY = sumY / corrPeriod;
      const double meanX = sumX / corrPeriod;
      for(int q = i + corrPeriod; q >= i; q--)
        {
         const double x = closed[q] - opened[q] - meanX;
         const double y = closeSeries[q] - openSeries[q] - meanY;
         A += x * y;
         B += x * x;
         C += y * y;
        }
      if(A != 0.0 && B != 0.0 && C != 0.0)
         correlation[i] = 100.0 * A / (MathSqrt(B) * MathSqrt(C));
      else
         correlation[i] = 0.0;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long iVolumeC(string symbol, ENUM_TIMEFRAMES timeframe, int shift)
  {
   long vol[];
   if(CopyTickVolume(symbol, timeframe, shift, 1, vol) > 0)
      return vol[0];
   return 0;
  }
//+------------------------------------------------------------------+
// ── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        Cummulative Delta v2
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=155553#p155553
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
