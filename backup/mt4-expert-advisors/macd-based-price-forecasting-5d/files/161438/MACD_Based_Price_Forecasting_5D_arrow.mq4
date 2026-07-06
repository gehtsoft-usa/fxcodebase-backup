/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        MACD_Based_Price_Forecasting_5D_arrow
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160949#p160949
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


#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrGray
#property indicator_color2 clrNONE
#property indicator_width1 1
input int    FastLength = 12;          // Fast Length
input int    SlowLength = 26;          // Slow Length
input int    SignalLength = 9;         // Signal Length
input string TrendDetermination = "MACD - Signal"; // Trend Determination (MACD, MACD - Signal)
input int    MaximumMemory = 50;       // Maximum Memory
input int    ForecastingLength = 50;   // Forecasting Length (reduced from 100)
input double TopPercentile = 80.0;     // Top Percentile
input double AveragePercentage = 50.0; // Average Percentage
input double BottomPercentile = 20.0;  // Bottom Percentile
input bool   EnablePerformanceMode = true; // Enable Performance Mode (reduces calculations)
input color  UpLineColor = clrDodgerBlue;     // Uptrend Line Color
input color  DnLineColor = clrOrangeRed;      // Downtrend Line Color
input color  UpAreaColor = C'245,121,49';     // Uptrend Area Color
input color  DnAreaColor = C'0,93,255';       // Downtrend Area Color
input bool   ShowSignalArea = true;           // Show Signal Area
input color  SignalBullColor = C'129,153,8';  // Bullish Signal Color
input color  SignalBearColor = C'69,54,242';  // Bearish Signal Color
input bool   ShowBreakArrows = true;          // Show Break Arrows
input int    ArrowSize = 2;                   // Arrow Size
input int    ArrowOffset = 20;                // Arrow Offset (Points)
input color  UpArrowColor = clrLime;          // Up Arrow Color
input color  DnArrowColor = clrRed;           // Down Arrow Color
double ReferenceBuffer[];
double PriceBuffer[];
struct PriceVector
  {
   double            prices[];
   int               size;
  };
struct MemoryHolder
  {
   PriceVector       vectors[];
   int               count;
  };
MemoryHolder uptrendMemory;
MemoryHolder downtrendMemory;
int upIndex = 0;
int dnIndex = 0;
double uptrendInitPrice = 0;
double downtrendInitPrice = 0;
bool prevUptrend = false;
bool prevTrigger = false;
int lastBarCalculated = 0;
string objPrefix = "MACD_Forecast_";
int objectCounter = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, ReferenceBuffer);
   SetIndexBuffer(1, PriceBuffer);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, clrGray);
   SetIndexStyle(1, DRAW_NONE);
   SetIndexLabel(0, "Reference Price");
   SetIndexLabel(1, "Price");
   ArraySetAsSeries(ReferenceBuffer, true);
   ArraySetAsSeries(PriceBuffer, true);
   ArrayResize(uptrendMemory.vectors, 0);
   ArrayResize(downtrendMemory.vectors, 0);
   uptrendMemory.count = 0;
   downtrendMemory.count = 0;
   IndicatorShortName("MACD Based Price Forecasting [LuxAlgo]");
   IndicatorDigits(Digits);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteAllObjects();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
      string name = ObjectName(i);
      if(StringFind(name, objPrefix) == 0)
        {
         ObjectDelete(name);
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
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(time, true);
   int limit = rates_total - prev_calculated;
   if(prev_calculated > 0)
      limit++;
   if(EnablePerformanceMode)
     {
      limit = MathMin(limit, 500);
     }
   else
     {
      limit = MathMin(limit, 1000);
     }
   for(int i = MathMin(limit, rates_total - 1); i >= 0; i--)
     {
      int pos = rates_total - 1 - i;
      double macdMain, macdSignal;
      CalculateMACD(pos, rates_total, close, macdMain, macdSignal);
      bool uptrend, downtrend, trigger;
      DetermineTrend(macdMain, macdSignal, i, uptrend, downtrend, trigger);
      if(uptrend && !prevUptrend)
        {
         uptrendInitPrice = close[i];
        }
      if(downtrend && prevUptrend)
        {
         downtrendInitPrice = close[i];
        }
      double initValue = uptrend ? uptrendInitPrice : downtrendInitPrice;
      ReferenceBuffer[i] = initValue;
      PriceBuffer[i] = close[i];
      if(uptrend)
        {
         PopulateMemory(uptrendMemory, upIndex, close[i], uptrendInitPrice);
        }
      if(downtrend)
        {
         PopulateMemory(downtrendMemory, dnIndex, close[i], downtrendInitPrice);
        }
      if(trigger && i == 0)
        {
         if(uptrend)
           {
            CreateForecast(uptrendMemory, upIndex, uptrendInitPrice, time[i], close[i], true);
           }
         else
           {
            CreateForecast(downtrendMemory, dnIndex, downtrendInitPrice, time[i], close[i], false);
           }
        }
      if(ShowSignalArea && i <= 50)
        {
         DrawSignalArea(i, close[i], initValue, uptrend);
        }
      if(ShowBreakArrows && i < rates_total - 1)
        {
         CheckAndDrawBreakArrow(i, close, ReferenceBuffer, time);
        }
      if(!uptrend)
         upIndex = 0;
      else
         upIndex++;
      if(!downtrend)
         dnIndex = 0;
      else
         dnIndex++;
      prevUptrend = uptrend;
      prevTrigger = trigger;
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateMACD(int pos, int total, const double &price[], double &macdMain, double &macdSignal)
  {
   if(EnablePerformanceMode)
     {
      macdMain = iMACD(NULL, 0, FastLength, SlowLength, SignalLength, PRICE_CLOSE, MODE_MAIN, total - 1 - pos);
      macdSignal = iMACD(NULL, 0, FastLength, SlowLength, SignalLength, PRICE_CLOSE, MODE_SIGNAL, total - 1 - pos);
      return;
     }
   double fastEMA = CalculateEMA(pos, total, FastLength, price);
   double slowEMA = CalculateEMA(pos, total, SlowLength, price);
   macdMain = fastEMA - slowEMA;
   macdSignal = CalculateMACD_Signal(pos, total, price);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateEMA(int pos, int total, int period, const double &price[])
  {
   if(pos >= total - period)
     {
      double sum = 0;
      int count = 0;
      for(int i = pos; i < total && count < period; i++)
        {
         sum += price[total - 1 - i];
         count++;
        }
      return count > 0 ? sum / count : price[total - 1 - pos];
     }
   double alpha = 2.0 / (period + 1.0);
   double ema = 0;
   double sum = 0;
   for(int i = 0; i < period; i++)
     {
      sum += price[total - 1 - (pos + period - 1 - i)];
     }
   ema = sum / period;
   for(int i = pos + period - 1; i > pos; i--)
     {
      ema = price[total - 1 - i] * alpha + ema * (1 - alpha);
     }
   return ema;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateMACD_Signal(int pos, int total, const double &price[])
  {
   if(EnablePerformanceMode)
     {
      double macdMain = iMACD(NULL, 0, FastLength, SlowLength, SignalLength, PRICE_CLOSE, MODE_MAIN, total - 1 - pos);
      return iMACD(NULL, 0, FastLength, SlowLength, SignalLength, PRICE_CLOSE, MODE_SIGNAL, total - 1 - pos);
     }
   double macd[];
   ArrayResize(macd, total);
   for(int i = 0; i < total; i++)
     {
      double fastEMA = CalculateEMA(i, total, FastLength, price);
      double slowEMA = CalculateEMA(i, total, SlowLength, price);
      macd[i] = fastEMA - slowEMA;
     }
   return CalculateEMA(pos, total, SignalLength, macd);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DetermineTrend(double macdMain, double macdSignal, int shift, bool &uptrend, bool &downtrend, bool &trigger)
  {
   double prevMacdMain = 0, prevMacdSignal = 0;
   if(shift < Bars - 1)
     {
      int prevPos = Bars - 1 - (shift + 1);
      CalculateMACD(prevPos, Bars, Close, prevMacdMain, prevMacdSignal);
     }
   if(TrendDetermination == "MACD")
     {
      uptrend = macdMain > 0;
      downtrend = macdMain < 0;
      trigger = (macdMain > 0 && prevMacdMain <= 0) || (macdMain < 0 && prevMacdMain >= 0);
     }
   else
     {
      uptrend = macdMain > macdSignal;
      downtrend = macdMain < macdSignal;
      trigger = (macdMain > macdSignal && prevMacdMain <= prevMacdSignal) ||
                (macdMain < macdSignal && prevMacdMain >= prevMacdSignal);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PopulateMemory(MemoryHolder &holder, int idx, double currentPrice, double initPrice)
  {
   if(idx > 500)
      return;
   while(holder.count <= idx)
     {
      int newIdx = ArrayResize(holder.vectors, holder.count + 1) - 1;
      ArrayResize(holder.vectors[newIdx].prices, 0);
      holder.vectors[newIdx].size = 0;
      holder.count++;
     }
   double priceDiff = currentPrice - initPrice;
   int currentSize = holder.vectors[idx].size;
   ArrayResize(holder.vectors[idx].prices, currentSize + 1);
   for(int i = currentSize; i > 0; i--)
     {
      holder.vectors[idx].prices[i] = holder.vectors[idx].prices[i - 1];
     }
   holder.vectors[idx].prices[0] = priceDiff;
   holder.vectors[idx].size++;
   if(holder.vectors[idx].size > MaximumMemory)
     {
      ArrayResize(holder.vectors[idx].prices, MaximumMemory);
      holder.vectors[idx].size = MaximumMemory;
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculatePercentile(double &arr[], int size, double percentile)
  {
   if(size == 0)
      return 0;
   if(size == 1)
      return arr[0];
   double sorted[];
   ArrayResize(sorted, size);
   ArrayCopy(sorted, arr, 0, 0, size);
   ArraySort(sorted);
   double rank = (percentile / 100.0) * (size - 1);
   int lower = (int)MathFloor(rank);
   int upper = (int)MathCeil(rank);
   if(lower == upper || upper >= size)
     {
      return sorted[lower];
     }
   double weight = rank - lower;
   return sorted[lower] * (1 - weight) + sorted[upper] * weight;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateForecast(MemoryHolder &holder, int idx, double initPrice, datetime startTime, double startPrice, bool isUptrend)
  {
   int maxHorizon = holder.count;
   if(maxHorizon == 0)
      return;
   int forecastBars = MathMin(ForecastingLength, 50);
   forecastBars = MathMin(forecastBars, maxHorizon - idx);
   if(forecastBars <= 0)
      return;
   double upperPrices[], midPrices[], lowerPrices[];
   datetime times[];
   ArrayResize(upperPrices, forecastBars);
   ArrayResize(midPrices, forecastBars);
   ArrayResize(lowerPrices, forecastBars);
   ArrayResize(times, forecastBars);
   for(int i = 0; i < forecastBars; i++)
     {
      int vectorIdx = idx + i;
      if(vectorIdx >= holder.count)
         break;
      PriceVector vec = holder.vectors[vectorIdx];
      upperPrices[i] = initPrice + CalculatePercentile(vec.prices, vec.size, TopPercentile);
      midPrices[i] = initPrice + CalculatePercentile(vec.prices, vec.size, AveragePercentage);
      lowerPrices[i] = initPrice + CalculatePercentile(vec.prices, vec.size, BottomPercentile);
      times[i] = startTime + i * PeriodSeconds();
     }
   DrawForecastLines(times, upperPrices, midPrices, lowerPrices, forecastBars, isUptrend);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawForecastLines(datetime &times[], double &upper[], double &mid[], double &lower[], int count, bool isUptrend)
  {
   if(count < 2)
      return;
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
      string name = ObjectName(i);
      if(StringFind(name, objPrefix + "Mid_") == 0 ||
         StringFind(name, objPrefix + "Upper_") == 0 ||
         StringFind(name, objPrefix + "Lower_") == 0 ||
         StringFind(name, objPrefix + "Area_") == 0)
        {
         ObjectDelete(name);
        }
     }
   color lineColor = isUptrend ? UpLineColor : DnLineColor;
   color areaColor = isUptrend ? UpAreaColor : DnAreaColor;
   string midName = objPrefix + "Mid_" + IntegerToString(objectCounter++);
   ObjectCreate(midName, OBJ_TREND, 0, times[0], mid[0], times[count - 1], mid[count - 1]);
   ObjectSet(midName, OBJPROP_COLOR, lineColor);
   ObjectSet(midName, OBJPROP_WIDTH, 2);
   ObjectSet(midName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(midName, OBJPROP_RAY, false);
   ObjectSet(midName, OBJPROP_BACK, false);
   string upperName = objPrefix + "Upper_" + IntegerToString(objectCounter++);
   ObjectCreate(upperName, OBJ_TREND, 0, times[0], upper[0], times[count - 1], upper[count - 1]);
   ObjectSet(upperName, OBJPROP_COLOR, areaColor);
   ObjectSet(upperName, OBJPROP_WIDTH, 1);
   ObjectSet(upperName, OBJPROP_STYLE, STYLE_DOT);
   ObjectSet(upperName, OBJPROP_RAY, false);
   ObjectSet(upperName, OBJPROP_BACK, true);
   string lowerName = objPrefix + "Lower_" + IntegerToString(objectCounter++);
   ObjectCreate(lowerName, OBJ_TREND, 0, times[0], lower[0], times[count - 1], lower[count - 1]);
   ObjectSet(lowerName, OBJPROP_COLOR, areaColor);
   ObjectSet(lowerName, OBJPROP_WIDTH, 1);
   ObjectSet(lowerName, OBJPROP_STYLE, STYLE_DOT);
   ObjectSet(lowerName, OBJPROP_RAY, false);
   ObjectSet(lowerName, OBJPROP_BACK, true);
   int stepSize = MathMax(1, count / 10);
   for(int i = 0; i < count - stepSize; i += stepSize)
     {
      string rectName = objPrefix + "Area_" + IntegerToString(objectCounter++);
      ObjectCreate(rectName, OBJ_RECTANGLE, 0, times[i], upper[i], times[MathMin(i + stepSize, count - 1)], lower[MathMin(i + stepSize, count - 1)]);
      ObjectSet(rectName, OBJPROP_COLOR, areaColor);
      ObjectSet(rectName, OBJPROP_BACK, true);
      ObjectSet(rectName, OBJPROP_FILL, true);
      ObjectSet(rectName, OBJPROP_STYLE, STYLE_SOLID);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckAndDrawBreakArrow(int shift, const double &close[], const double &reference[], const datetime &time[])
  {
   double currentClose = close[shift];
   double prevClose = close[shift + 1];
   double currentRef = reference[shift];
   double prevRef = reference[shift + 1];
   if(currentRef == 0 || prevRef == 0)
      return;
   bool upBreak = false;
   bool dnBreak = false;
   if(prevClose <= prevRef && currentClose > currentRef)
     {
      upBreak = true;
     }
   if(prevClose >= prevRef && currentClose < currentRef)
     {
      dnBreak = true;
     }
   if(upBreak || dnBreak)
     {
      string arrowName = objPrefix + "Arrow_" + IntegerToString(shift);
      if(ObjectFind(arrowName) >= 0)
         ObjectDelete(arrowName);
      int arrowCode = upBreak ? 233 : 234;
      color arrowColor = upBreak ? UpArrowColor : DnArrowColor;
      double arrowPrice;
      if(upBreak)
        {
         arrowPrice = Low[shift] - ArrowOffset * Point();
        }
      else
        {
         arrowPrice = High[shift] + ArrowOffset * Point();
        }
      ObjectCreate(arrowName, OBJ_ARROW, 0, time[shift], arrowPrice);
      ObjectSet(arrowName, OBJPROP_ARROWCODE, arrowCode);
      ObjectSet(arrowName, OBJPROP_COLOR, arrowColor);
      ObjectSet(arrowName, OBJPROP_WIDTH, ArrowSize);
      ObjectSet(arrowName, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
      ObjectSet(arrowName, OBJPROP_BACK, false);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSignalArea(int shift, double price, double reference, bool isUptrend)
  {
   if(!ShowSignalArea)
      return;
   if(shift >= Bars - 1)
      return;
   datetime time1 = Time[shift];
   datetime time2 = Time[shift + 1];
   double topValue = MathMax(price, reference);
   double bottomValue = MathMin(price, reference);
   color fillColor = clrNONE;
   if(isUptrend && price > reference)
     {
      fillColor = SignalBullColor;
     }
   else
      if(!isUptrend && price < reference)
        {
         fillColor = SignalBearColor;
        }
   if(fillColor != clrNONE)
     {
      string rectName = objPrefix + "Signal_" + IntegerToString(shift);
      if(ObjectFind(rectName) >= 0)
         ObjectDelete(rectName);
      ObjectCreate(rectName, OBJ_RECTANGLE, 0, time2, topValue, time1, bottomValue);
      ObjectSet(rectName, OBJPROP_COLOR, fillColor);
      ObjectSet(rectName, OBJPROP_BACK, true);
      ObjectSet(rectName, OBJPROP_FILL, true);
     }
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        MACD_Based_Price_Forecasting_5D_arrow
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160949#p160949
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
