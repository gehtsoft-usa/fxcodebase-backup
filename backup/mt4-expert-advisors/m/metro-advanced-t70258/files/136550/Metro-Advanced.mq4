// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70258
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
#property version "1.1"

#property indicator_separate_window
#property indicator_buffers 11
#property indicator_color1 Orange
#property indicator_color2 SkyBlue
#property indicator_color4 DarkGreen
#property indicator_color5 Crimson
#property indicator_color6 EMPTY //LimeGreen
#property indicator_color7 EMPTY //DimGray
#property indicator_color8 EMPTY //PaleVioletRed
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_style6 STYLE_DOT
#property indicator_style7 STYLE_DOT
#property indicator_style8 STYLE_DOT
#property indicator_level1 5
#property indicator_level2 10
#property indicator_level3 15
#property indicator_level4 20
#property indicator_level5 25
#property indicator_level6 30
#property indicator_level7 35
#property indicator_level8 40
#property indicator_level9 45
#property indicator_level10 50
#property indicator_level11 55
#property indicator_level12 60
#property indicator_level13 65
#property indicator_level14 70
#property indicator_level15 75
#property indicator_level16 80
#property indicator_level17 85
#property indicator_level18 90
#property indicator_level19 95
#property strict

enum enRsiTypes
{
   rsi_rsi, // Regular RSI
   rsi_wil, // Wilders RSI
   rsi_rsx, // RSX     Diffult
   rsi_cut  // Cuttlers RSI
};

input string TimeFrame = "Current time frame";
input enRsiTypes RsiType = rsi_rsi;
input int PeriodRSI = 14;
input ENUM_APPLIED_PRICE Price = PRICE_CLOSE;
input int StepSizeFast = 5;
input int StepSizeSlow = 15;
input double OverSold = 10;
input double OverBought = 90;
input int MinMaxPeriod = 49;                     //Green Bands
input bool alertsOn = false;                     // Turn alerts on?
input bool alertsOnCurrent = true;               // Alerts on current (still opened) bar?
input bool alertsMessage = true;                 // Alerts should show pop-up message?
input bool alertsPushNotif = false;              // Alerts should send push notification?
input bool alertsSound = false;                  // Alerts should play a sound?
input bool alertsEmail = false;                  // Alerts should send email?
input bool arrowsVisible = false;                // Arrows visible?
input bool arrowsOnNewest = false;               // Arrows drawn on newst bar of higher time frame bar?
input string arrowsIdentifier = "asesi Arrows1"; // Unique ID for arrows
input double arrowsUpperGap = 1.0;               // Upper arrow gap
input double arrowsLowerGap = 1.0;               // Lower arrow gap
input color arrowsUpColor = LimeGreen;           // Up arrow color
input color arrowsDnColor = Orange;              // Down arrow color
input int arrowsUpCode = 241;                    // Up arrow code
input int arrowsDnCode = 242;                    // Down arrow code
input bool Interpolate = true;
input int DivergearrowSize = 0;
input bool ShowClassicalDivergence = true;
input bool ShowHiddenDivergence = true;
input bool drawPriceTrendLines = true;
input bool drawIndicatorTrendLines = true;
input color divergenceBullishColor = Lime;
input color divergenceBearishColor = Magenta;

double Line2Buffer[];
double Line3Buffer[];
double trendf[];
double trends[];
double arrup[];
double arrdn[];
double trend[];
double maxf[];
double minf[];
double maxs[];
double mins[];
double levelUp[];
double levelMi[];
double levelDn[];
double bullishDivergence[];
double bearishDivergence[];

string indicatorFileName;
bool returnBars;
int timeFrame;

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

class ColoredStreamData
{
public:
   double Stream[];
};

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual int Size() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

class InstrumentInfo
{
   string _symbol;
   double _mult;
   double _point;
   double _pipSize;
   int _digits;
   double _tickSize;
public:
   InstrumentInfo(const string symbol)
   {
      _symbol = symbol;
      _point = MarketInfo(symbol, MODE_POINT);
      _digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      _mult = _digits == 3 || _digits == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
   }

   // Return < 0 when lot1 < lot2, > 0 when lot1 > lot2 and 0 owtherwise
   int CompareLots(double lot1, double lot2)
   {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
      {
         return lot1 < lot2 ? -1 : (lot1 > lot2 ? 1 : 0);
      }
      int lotSteps1 = (int)floor(lot1 / lotStep + 0.5);
      int lotSteps2 = (int)floor(lot2 / lotStep + 0.5);
      int res = lotSteps1 - lotSteps2;
      return res;
   }
   
   static double GetBid(const string symbol) { return MarketInfo(symbol, MODE_BID); }
   double GetBid() { return GetBid(_symbol); }
   static double GetAsk(const string symbol) { return MarketInfo(symbol, MODE_ASK); }
   double GetAsk() { return GetAsk(_symbol); }
   static double GetPipSize(const string symbol)
   { 
      double point = MarketInfo(symbol, MODE_POINT);
      double digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      double mult = digits == 3 || digits == 5 ? 10 : 1;
      return point * mult;
   }
   double GetPipSize() { return _pipSize; }
   double GetPointSize() { return _point; }
   string GetSymbol() { return _symbol; }
   double GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }
   int GetDigits() { return _digits; }
   double GetTickSize() { return _tickSize; }
   double GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

   double AddPips(const double rate, const double pips)
   {
      return RoundRate(rate + pips * _pipSize);
   }

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathFloor(rate / _tickSize + 0.5) * _tickSize, _digits);
   }

   double RoundLots(const double lots)
   {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
      {
         return 0.0;
      }
      return floor(lots / lotStep) * lotStep;
   }

   double LimitLots(const double lots)
   {
      double minVolume = GetMinLots();
      if (minVolume > lots)
      {
         return 0.0;
      }
      double maxVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
      {
         return maxVolume;
      }
      return lots;
   }

   double NormalizeLots(const double lots)
   {
      return LimitLots(RoundLots(lots));
   }
};

class AStream : public IStream
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
   InstrumentInfo *_instrument;
   int _references;

   AStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _references = 1;
      _shift = 0.0;
      _symbol = symbol;
      _timeframe = timeframe;
      _instrument = new InstrumentInfo(_symbol);
   }

   ~AStream()
   {
      delete _instrument;
   }
public:
   void SetShift(const double shift)
   {
      _shift = shift;
   }

   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   int Size()
   {
      return iBars(_symbol, _timeframe);
   }
};

class ColoredStream : public AStream
{
public:
   ColoredStreamData _streams[];
   double _data[];

   ColoredStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   void Init(double defaultValue)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         ArrayInitialize(_streams[i].Stream, defaultValue);
      }
      ArrayInitialize(_data, defaultValue);
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id + 0, _data);
      SetIndexStyle(id + 0, DRAW_NONE);
      return id + 1;
   }

   int RegisterStream(int id, color clr, string label = "", int lineType = DRAW_LINE, ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      SetIndexStyle(id, lineType, lineStyle, width, clr);
      SetIndexBuffer(id, _streams[size].Stream);
      SetIndexEmptyValue(id, EMPTY_VALUE);
      if (label != "")
         SetIndexLabel(id, label);
      return id + 1;
   }

   int GetColorIndex(int period)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].Stream[period] != EMPTY_VALUE)
            return i;
      }
      return -1;
   }

   void Set(double value, int period, int colorIndex)
   {
      _data[period] = value;
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (colorIndex == i)
         {
            _streams[i].Stream[period] = value;
            if (period + 1 < iBars(_symbol, _timeframe) && _streams[i].Stream[period + 1] == EMPTY_VALUE)
               _streams[i].Stream[period + 1] = _data[period + 1];   
         }
         else
            _streams[i].Stream[period] = EMPTY_VALUE;
      }
   }

   bool GetValue(const int period, double &val)
   {
      if (period >= iBars(_symbol, _timeframe))
      {
         return false;
      }
      val = _data[period];
      return _data[period] != EMPTY_VALUE;
   }
};

ColoredStream* Line1Buffer;
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("mabv");
   IndicatorShortName("Metro-Advanced");

   IndicatorBuffers(19);
   int id = 0;
   SetIndexBuffer(id, Line2Buffer);
   SetIndexLabel(id, "StepRSI fast");
   ++id;
   SetIndexBuffer(id, Line3Buffer);
   SetIndexLabel(id, "StepRSI slow");
   ++id;

   Line1Buffer = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = Line1Buffer.RegisterStream(id, divergenceBullishColor, "RSI");
   id = Line1Buffer.RegisterStream(id, divergenceBearishColor, "RSI");

   SetIndexBuffer(id, arrup);
   SetIndexStyle(id, DRAW_ARROW);
   SetIndexArrow(id, 159);
   ++id;
   SetIndexBuffer(id, arrdn);
   SetIndexStyle(id, DRAW_ARROW);
   SetIndexArrow(id, 159);
   ++id;

   SetIndexBuffer(id, bullishDivergence);
   SetIndexStyle(id, DRAW_ARROW, 0, DivergearrowSize);
   SetIndexArrow(id, 233);
   ++id;

   SetIndexBuffer(id, bearishDivergence);
   SetIndexStyle(id, DRAW_ARROW, 0, DivergearrowSize);
   SetIndexArrow(id, 234);
   ++id;

   id = Line1Buffer.RegisterInternalStream(id);
   
   SetIndexBuffer(id++, levelDn);
   SetIndexBuffer(id++, trendf);
   SetIndexBuffer(id++, trends);
   SetIndexBuffer(id++, minf);
   SetIndexBuffer(id++, mins);
   SetIndexBuffer(id++, maxf);
   SetIndexBuffer(id++, maxs);
   SetIndexBuffer(id++, trend);
   SetIndexBuffer(id++, levelUp);
   SetIndexBuffer(id++, levelMi);

   timeFrame = stringToTimeFrame(TimeFrame);
   indicatorFileName = WindowExpertName();
   returnBars = (TimeFrame == "returnBars");
   indicatorName = timeFrameToString(timeFrame) + " advanced step " + getRsiName((int)RsiType) + " (" + PeriodRSI + "," + StepSizeFast + "," + StepSizeSlow + ")";
   IndicatorShortName(indicatorName);
   return (0);
}
string indicatorName;
int deinit()
{
   delete Line1Buffer;
   Line1Buffer = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   string lookFor = arrowsIdentifier + ":";
   int lookForLength = StringLen(lookFor);
   for (int i = ObjectsTotal() - 1; i >= 0; i--)
   {
      string objectName = ObjectName(i);
      if (StringSubstr(objectName, 0, lookForLength) == lookFor)
         ObjectDelete(objectName);
   }
   return (0);
}

int start()
{
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0)
      return (-1);
   if (counted_bars > 0)
      counted_bars--;
   int limit = MathMin(Bars - counted_bars, Bars - 1);
   if (returnBars)
   {
      Line2Buffer[0] = limit + 1;
      return (0);
   }
   if (timeFrame != Period())
   {
      limit = MathMax(limit, MathMin(Bars, iCustom(NULL, timeFrame, indicatorFileName, "returnBars", 0, 0) * timeFrame / Period()));
      for (int i = limit; i >= 0; i--)
      {
         int n, l, x, y = iBarShift(NULL, timeFrame, Time[i]);
         Line2Buffer[i] = iCustom(NULL, timeFrame, indicatorFileName, "", RsiType, PeriodRSI, Price, StepSizeFast, StepSizeSlow, OverSold, OverBought, MinMaxPeriod, alertsOn, alertsOnCurrent, alertsMessage, alertsPushNotif, alertsSound, alertsEmail, arrowsVisible, arrowsOnNewest, arrowsIdentifier, arrowsUpperGap, arrowsLowerGap, arrowsUpColor, arrowsDnColor, arrowsUpCode, arrowsDnCode, 0, y);
         Line3Buffer[i] = iCustom(NULL, timeFrame, indicatorFileName, "", RsiType, PeriodRSI, Price, StepSizeFast, StepSizeSlow, OverSold, OverBought, MinMaxPeriod, alertsOn, alertsOnCurrent, alertsMessage, alertsPushNotif, alertsSound, alertsEmail, arrowsVisible, arrowsOnNewest, arrowsIdentifier, arrowsUpperGap, arrowsLowerGap, arrowsUpColor, arrowsDnColor, arrowsUpCode, arrowsDnCode, 1, y);
         double Line1Buffer_val = iCustom(NULL, timeFrame, indicatorFileName, "", RsiType, PeriodRSI, Price, StepSizeFast, StepSizeSlow, OverSold, OverBought, MinMaxPeriod, alertsOn, alertsOnCurrent, alertsMessage, alertsPushNotif, alertsSound, alertsEmail, arrowsVisible, arrowsOnNewest, arrowsIdentifier, arrowsUpperGap, arrowsLowerGap, arrowsUpColor, arrowsDnColor, arrowsUpCode, arrowsDnCode, 2, y);
         double colorIndex = 0;
         if (Line1Buffer._data[i + 1] > Line1Buffer_val)
         {
            colorIndex = 1;
         }
         Line1Buffer.Set(Line1Buffer_val, i, colorIndex);
         levelUp[i] = iCustom(NULL, timeFrame, indicatorFileName, "", RsiType, PeriodRSI, Price, StepSizeFast, StepSizeSlow, OverSold, OverBought, MinMaxPeriod, alertsOn, alertsOnCurrent, alertsMessage, alertsPushNotif, alertsSound, alertsEmail, arrowsVisible, arrowsOnNewest, arrowsIdentifier, arrowsUpperGap, arrowsLowerGap, arrowsUpColor, arrowsDnColor, arrowsUpCode, arrowsDnCode, 5, y);
         levelMi[i] = iCustom(NULL, timeFrame, indicatorFileName, "", RsiType, PeriodRSI, Price, StepSizeFast, StepSizeSlow, OverSold, OverBought, MinMaxPeriod, alertsOn, alertsOnCurrent, alertsMessage, alertsPushNotif, alertsSound, alertsEmail, arrowsVisible, arrowsOnNewest, arrowsIdentifier, arrowsUpperGap, arrowsLowerGap, arrowsUpColor, arrowsDnColor, arrowsUpCode, arrowsDnCode, 6, y);
         levelDn[i] = iCustom(NULL, timeFrame, indicatorFileName, "", RsiType, PeriodRSI, Price, StepSizeFast, StepSizeSlow, OverSold, OverBought, MinMaxPeriod, alertsOn, alertsOnCurrent, alertsMessage, alertsPushNotif, alertsSound, alertsEmail, arrowsVisible, arrowsOnNewest, arrowsIdentifier, arrowsUpperGap, arrowsLowerGap, arrowsUpColor, arrowsDnColor, arrowsUpCode, arrowsDnCode, 7, y);
         trend[i] = iCustom(NULL, timeFrame, indicatorFileName, "", RsiType, PeriodRSI, Price, StepSizeFast, StepSizeSlow, OverSold, OverBought, MinMaxPeriod, alertsOn, alertsOnCurrent, alertsMessage, alertsPushNotif, alertsSound, alertsEmail, arrowsVisible, arrowsOnNewest, arrowsIdentifier, arrowsUpperGap, arrowsLowerGap, arrowsUpColor, arrowsDnColor, arrowsUpCode, arrowsDnCode, 14, y);
         arrup[i] = EMPTY_VALUE;
         arrdn[i] = EMPTY_VALUE;
         if (!Interpolate || (i > 0 && y == iBarShift(NULL, timeFrame, Time[i - 1])))
            continue;
         datetime time = iTime(NULL, timeFrame, y);
         for (n = 1; i + n < Bars && Time[i + n] >= time; n++)
            continue;
         for (l = 1; l < n && (i + l < Bars) && (i + n) < Bars; l++)
         {
            Line2Buffer[i + l] = Line2Buffer[i] + (Line2Buffer[i + n] - Line2Buffer[i]) * l / n;
            Line3Buffer[i + l] = Line3Buffer[i] + (Line3Buffer[i + n] - Line3Buffer[i]) * l / n;
            levelUp[i + l] = levelUp[i] + (levelUp[i + n] - levelUp[i]) * l / n;
            levelMi[i + l] = levelMi[i] + (levelMi[i + n] - levelMi[i]) * l / n;
            levelDn[i + l] = levelDn[i] + (levelDn[i + n] - levelDn[i]) * l / n;
         }
      }
      for (int i = limit; i >= 0; i--)
      {
         int y = iBarShift(NULL, timeFrame, Time[i]);
         int x = iBarShift(NULL, timeFrame, Time[i + 1]);
         if (arrowsOnNewest)
            x = iBarShift(NULL, timeFrame, Time[i - 1]);
         if (x != y)
         {
            arrup[i] = iCustom(NULL, timeFrame, indicatorFileName, "", RsiType, PeriodRSI, Price, StepSizeFast, StepSizeSlow, OverSold, OverBought, MinMaxPeriod, alertsOn, alertsOnCurrent, alertsMessage, alertsPushNotif, alertsSound, alertsEmail, arrowsVisible, arrowsOnNewest, arrowsIdentifier, arrowsUpperGap, arrowsLowerGap, arrowsUpColor, arrowsDnColor, arrowsUpCode, arrowsDnCode, 3, y);
            arrdn[i] = iCustom(NULL, timeFrame, indicatorFileName, "", RsiType, PeriodRSI, Price, StepSizeFast, StepSizeSlow, OverSold, OverBought, MinMaxPeriod, alertsOn, alertsOnCurrent, alertsMessage, alertsPushNotif, alertsSound, alertsEmail, arrowsVisible, arrowsOnNewest, arrowsIdentifier, arrowsUpperGap, arrowsLowerGap, arrowsUpColor, arrowsDnColor, arrowsUpCode, arrowsDnCode, 4, y);
         }
      }
      return (0);
   }


   for (int i = limit; i >= 0; i--)
   {
      double rsi = iRsi(iMA(NULL, 0, 1, 0, MODE_SMA, Price, i), PeriodRSI, RsiType, i);
      maxf[i] = rsi + 2 * StepSizeFast;
      minf[i] = rsi - 2 * StepSizeFast;
      maxs[i] = rsi + 2 * StepSizeSlow;
      mins[i] = rsi - 2 * StepSizeSlow;
      if (i > (Bars - 2))
         continue;

      trendf[i] = trendf[i + 1];
      if (rsi > maxf[i + 1])
         trendf[i] = 1;
      if (rsi < minf[i + 1])
         trendf[i] = -1;
      if (trendf[i] > 0 && minf[i] < minf[i + 1])
         minf[i] = minf[i + 1];
      if (trendf[i] < 0 && maxf[i] > maxf[i + 1])
         maxf[i] = maxf[i + 1];

      trends[i] = trends[i + 1];
      if (rsi > maxs[i + 1])
         trends[i] = 1;
      if (rsi < mins[i + 1])
         trends[i] = -1;
      if (trends[i] > 0 && mins[i] < mins[i + 1])
         mins[i] = mins[i + 1];
      if (trends[i] < 0 && maxs[i] > maxs[i + 1])
         maxs[i] = maxs[i + 1];

      double colorIndex = 0;
      double prev;
      if (Line1Buffer._data[i + 1] > rsi)
      {
         colorIndex = 1;
      }
      Line1Buffer.Set(rsi, i, colorIndex);
      double hi = Line1Buffer._data[ArrayMaximum(Line1Buffer._data, MinMaxPeriod, i)];
      double lo = Line1Buffer._data[ArrayMinimum(Line1Buffer._data, MinMaxPeriod, i)];
      double rn = hi - lo;
      levelUp[i] = lo + rn * OverBought / 100.0;
      levelDn[i] = lo + rn * OverSold / 100.0;
      levelMi[i] = (levelUp[i] + levelDn[i]) / 2.0;

      if (trendf[i] > 0)
         Line2Buffer[i] = minf[i] + StepSizeFast;
      if (trendf[i] < 0)
         Line2Buffer[i] = maxf[i] - StepSizeFast;
      if (trends[i] > 0)
         Line3Buffer[i] = mins[i] + StepSizeSlow;
      if (trends[i] < 0)
         Line3Buffer[i] = maxs[i] - StepSizeSlow;

      trend[i] = trend[i + 1];
      arrup[i] = EMPTY_VALUE;
      arrdn[i] = EMPTY_VALUE;
      if (Line2Buffer[i] > Line3Buffer[i])
         trend[i] = 1;
      if (Line2Buffer[i] < Line3Buffer[i])
         trend[i] = -1;
      if (trend[i] != trend[i + 1])
      {
         if (trend[i] == 1)
            arrup[i] = MathMin(MathMin(Line1Buffer._data[i], Line2Buffer[i]), Line3Buffer[i]);
         if (trend[i] == -1)
            arrdn[i] = MathMax(MathMax(Line1Buffer._data[i], Line2Buffer[i]), Line3Buffer[i]);
      }
      if (arrowsVisible)
      {
         string lookFor = arrowsIdentifier + ":" + (string)Time[i];
         ObjectDelete(lookFor);
         if (trend[i] != trend[i + 1])
         {
            if (trend[i] == 1)
               drawArrow(i, arrowsUpColor, arrowsUpCode, false);
            if (trend[i] == -1)
               drawArrow(i, arrowsDnColor, arrowsDnCode, true);
         }
      }
      if (i < Bars - 5)
      {
         CatchBullishDivergence(i + 2);
         CatchBearishDivergence(i + 2);
      }
   }
   manageAlerts();
   return (0);
}

void drawArrow(int i, color theColor, int theCode, bool up)
{
   string name = arrowsIdentifier + ":" + (string)Time[i];
   double gap = iATR(NULL, 0, 20, i);

   datetime time = Time[i];
   if (arrowsOnNewest)
      time += _Period * 60 - 1;
   ObjectCreate(name, OBJ_ARROW, 0, time, 0);
   ObjectSet(name, OBJPROP_ARROWCODE, theCode);
   ObjectSet(name, OBJPROP_COLOR, theColor);
   if (up)
      ObjectSet(name, OBJPROP_PRICE1, High[i] + arrowsUpperGap * gap);
   else
      ObjectSet(name, OBJPROP_PRICE1, Low[i] - arrowsLowerGap * gap);
}

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
void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = 1;
      if (alertsOnCurrent)
         whichBar = 0;
      if (trend[whichBar] != trend[whichBar + 1])
      {
         if (trend[whichBar] == 1)
            doAlert(whichBar, "trend changed to up");
         if (trend[whichBar] == -1)
            doAlert(whichBar, "trend changed to down");
      }
   }
}

void doAlert(int forBar, string doWhat)
{
   static string previousAlert = "nothing";
   static datetime previousTime;
   string message;

   if (previousAlert != doWhat || previousTime != Time[forBar])
   {
      previousAlert = doWhat;
      previousTime = Time[forBar];

      message = Symbol() + " at " + TimeToStr(TimeLocal(), TIME_SECONDS) + "advanced step " + getRsiName((int)RsiType) + " " + doWhat;
      if (alertsMessage)
         Alert(message);
      if (alertsEmail)
         SendMail(StringConcatenate(Symbol(), "advanced step " + getRsiName((int)RsiType) + " "), message);
      if (alertsPushNotif)
         SendNotification(StringConcatenate(Symbol(), "advanced step " + getRsiName((int)RsiType) + " " + message));
      if (alertsSound)
         PlaySound("alert2.wav");
   }
}

string rsiMethodNames[] = {"rsi", "Wilders rsi", "rsx", "Cuttler RSI"};
string getRsiName(int method)
{
   int max = ArraySize(rsiMethodNames) - 1;
   method = MathMax(MathMin(method, max), 0);
   return (rsiMethodNames[method]);
}

double workRsi[][13];
#define _price 0
#define _change 1
#define _changa 2

double iRsi(double price, double period, int rsiMode, int i, int instanceNo = 0)
{
   if (ArrayRange(workRsi, 0) != Bars)
      ArrayResize(workRsi, Bars);
   int z = instanceNo * 13;
   int r = Bars - i - 1;

   workRsi[r][z + _price] = price;
   switch (rsiMode)
   {
   case 0:
      {
         double alpha = 1.0 / period;
         if (r < period)
         {
            int k;
            double sum = 0;
            for (k = 0; k < period && (r - k - 1) >= 0; k++)
               sum += MathAbs(workRsi[r - k][z + _price] - workRsi[r - k - 1][z + _price]);
            workRsi[r][z + _change] = (workRsi[r][z + _price] - workRsi[0][z + _price]) / MathMax(k, 1);
            workRsi[r][z + _changa] = sum / MathMax(k, 1);
         }
         else
         {
            double change = workRsi[r][z + _price] - workRsi[r - 1][z + _price];
            workRsi[r][z + _change] = workRsi[r - 1][z + _change] + alpha * (change - workRsi[r - 1][z + _change]);
            workRsi[r][z + _changa] = workRsi[r - 1][z + _changa] + alpha * (MathAbs(change) - workRsi[r - 1][z + _changa]);
         }
         if (workRsi[r][z + _changa] != 0)
            return (50.0 * (workRsi[r][z + _change] / workRsi[r][z + _changa] + 1));
         else
            return (50.0);
      }
   case 1:
      workRsi[r][z + 1] = iSmma(0.5 * (MathAbs(workRsi[r][z + _price] - workRsi[r - 1][z + _price]) + (workRsi[r][z + _price] - workRsi[r - 1][z + _price])), 0.5 * (period - 1), Bars - i - 1, instanceNo * 2 + 0);
      workRsi[r][z + 2] = iSmma(0.5 * (MathAbs(workRsi[r][z + _price] - workRsi[r - 1][z + _price]) - (workRsi[r][z + _price] - workRsi[r - 1][z + _price])), 0.5 * (period - 1), Bars - i - 1, instanceNo * 2 + 1);
      if ((workRsi[r][z + 1] + workRsi[r][z + 2]) != 0)
         return (100.0 * workRsi[r][z + 1] / (workRsi[r][z + 1] + workRsi[r][z + 2]));
      else
         return (50);

   case 2:
      {
         double Kg = (3.0) / (2.0 + period), Hg = 1.0 - Kg;
         if (r < period)
         {
            for (int k = 1; k < 13; k++)
               workRsi[r][k + z] = 0;
            return (50);
         }

         double mom = workRsi[r][_price + z] - workRsi[r - 1][_price + z];
         double moa = MathAbs(mom);
         for (int k = 0; k < 3; k++)
         {
            int kk = k * 2;
            workRsi[r][z + kk + 1] = Kg * mom + Hg * workRsi[r - 1][z + kk + 1];
            workRsi[r][z + kk + 2] = Kg * workRsi[r][z + kk + 1] + Hg * workRsi[r - 1][z + kk + 2];
            mom = 1.5 * workRsi[r][z + kk + 1] - 0.5 * workRsi[r][z + kk + 2];
            workRsi[r][z + kk + 7] = Kg * moa + Hg * workRsi[r - 1][z + kk + 7];
            workRsi[r][z + kk + 8] = Kg * workRsi[r][z + kk + 7] + Hg * workRsi[r - 1][z + kk + 8];
            moa = 1.5 * workRsi[r][z + kk + 7] - 0.5 * workRsi[r][z + kk + 8];
         }
         if (moa != 0)
            return (MathMax(MathMin((mom / moa + 1.0) * 50.0, 100.00), 0.00));
         else
            return (50);
      }
   case 3:
      {
         double sump = 0;
         double sumn = 0;
         for (int k = 0; k < period; k++)
         {
            double diff = workRsi[r - k][z + _price] - workRsi[r - k - 1][z + _price];
            if (diff > 0)
               sump += diff;
            if (diff < 0)
               sumn -= diff;
         }
         if (sumn > 0)
            return (100.0 - 100.0 / (1.0 + sump / sumn));
         else
            return (50);
      }
   }
   return (0);
}

double workSmma[][2];
double iSmma(double price, double period, int r, int instanceNo = 0)
{
   if (ArrayRange(workSmma, 0) != Bars)
      ArrayResize(workSmma, Bars);

   if (r < period)
      workSmma[r][instanceNo] = price;
   else
      workSmma[r][instanceNo] = workSmma[r - 1][instanceNo] + (price - workSmma[r - 1][instanceNo]) / period;
   return (workSmma[r][instanceNo]);
}


void CatchBullishDivergence(int shift)
{
   shift++;
   bullishDivergence[shift] = EMPTY_VALUE;
   ObjectDelete(IndicatorObjPrefix + "l" + DoubleToStr(Time[shift], 0));
   ObjectDelete(IndicatorObjPrefix + "l" + "os" + DoubleToStr(Time[shift], 0));
   if (!IsIndicatorLow(shift))
      return;
   int currentLow = shift;
   int lastLow = GetIndicatorLastLow(shift + 1);
   if (lastLow < 0)
   {
      return;
   }
   if (Line2Buffer[currentLow] > Line2Buffer[lastLow] && Low[currentLow] < Low[lastLow])
   {
      if (ShowClassicalDivergence)
      {
         bullishDivergence[currentLow] = Line2Buffer[currentLow] - iStdDevOnArray(Line2Buffer, 0, 10, 0, MODE_SMA, currentLow);
         if (drawPriceTrendLines)
            DrawPriceTrendLine("l", Time[currentLow], Time[lastLow], Low[currentLow], Low[lastLow], divergenceBullishColor, STYLE_SOLID);
         if (drawIndicatorTrendLines)
            DrawIndicatorTrendLine("l", Time[currentLow], Time[lastLow], Line2Buffer[currentLow], Line2Buffer[lastLow], divergenceBullishColor, STYLE_SOLID);
      }
   }

   if (Line2Buffer[currentLow] < Line2Buffer[lastLow] && Low[currentLow] > Low[lastLow])
   {
      if (ShowHiddenDivergence)
      {
         bullishDivergence[currentLow] = Line2Buffer[currentLow] - iStdDevOnArray(Line2Buffer, 0, 10, 0, MODE_SMA, currentLow);
         if (drawPriceTrendLines)
            DrawPriceTrendLine("l", Time[currentLow], Time[lastLow], Low[currentLow], Low[lastLow], divergenceBullishColor, STYLE_DOT);
         if (drawIndicatorTrendLines)
            DrawIndicatorTrendLine("l", Time[currentLow], Time[lastLow], Line2Buffer[currentLow], Line2Buffer[lastLow], divergenceBullishColor, STYLE_DOT);
      }
   }
}

void CatchBearishDivergence(int shift)
{
   shift++;
   bearishDivergence[shift] = EMPTY_VALUE;
   ObjectDelete(IndicatorObjPrefix + "h" + DoubleToStr(Time[shift], 0));
   ObjectDelete(IndicatorObjPrefix + "h" + "os" + DoubleToStr(Time[shift], 0));
   if (IsIndicatorPeak(shift) == false)
      return;
   int currentPeak = shift;
   int lastPeak = GetIndicatorLastPeak(shift + 1);
   if (lastPeak < 0)
   {
      return;
   }

   if (Line2Buffer[currentPeak] < Line2Buffer[lastPeak] && High[currentPeak] > High[lastPeak])
   {
      if (ShowClassicalDivergence)
      {
         bearishDivergence[currentPeak] = Line2Buffer[currentPeak] + iStdDevOnArray(Line2Buffer, 0, 10, 0, MODE_SMA, currentPeak);
         if (drawPriceTrendLines)
            DrawPriceTrendLine("h", Time[currentPeak], Time[lastPeak], High[currentPeak], High[lastPeak], divergenceBearishColor, STYLE_SOLID);
         if (drawIndicatorTrendLines)
            DrawIndicatorTrendLine("h", Time[currentPeak], Time[lastPeak], Line2Buffer[currentPeak], Line2Buffer[lastPeak], divergenceBearishColor, STYLE_SOLID);
      }
   }

   if (Line2Buffer[currentPeak] > Line2Buffer[lastPeak] && High[currentPeak] < High[lastPeak])
   {
      if (ShowHiddenDivergence)
      {
         bearishDivergence[currentPeak] = Line2Buffer[currentPeak] + iStdDevOnArray(Line2Buffer, 0, 10, 0, MODE_SMA, currentPeak);
         if (drawPriceTrendLines)
            DrawPriceTrendLine("h", Time[currentPeak], Time[lastPeak], High[currentPeak], High[lastPeak], divergenceBearishColor, STYLE_DOT);
         if (drawIndicatorTrendLines)
            DrawIndicatorTrendLine("h", Time[currentPeak], Time[lastPeak], Line2Buffer[currentPeak], Line2Buffer[lastPeak], divergenceBearishColor, STYLE_DOT);
      }
   }
}

bool IsIndicatorPeak(int shift)
{
   if (Line2Buffer[shift] >= Line2Buffer[shift + 1] && Line2Buffer[shift] > Line2Buffer[shift + 2] && Line2Buffer[shift] > Line2Buffer[shift - 1])
      return (true);
   else
      return (false);
}

bool IsIndicatorLow(int shift)
{
   if (Line2Buffer[shift] <= Line2Buffer[shift + 1] && Line2Buffer[shift] < Line2Buffer[shift + 2] && Line2Buffer[shift] < Line2Buffer[shift - 1])
      return (true);
   else
      return (false);
}

int GetIndicatorLastPeak(int shift)
{
   for (int i = shift + 5; i < Bars - 5; i++)
   {
      if (Line2Buffer[i] >= Line2Buffer[i + 1] && Line2Buffer[i] > Line2Buffer[i + 2] && Line2Buffer[i] >= Line2Buffer[i - 1] && Line2Buffer[i] > Line2Buffer[i - 2])
         return (i);
   }
   return (-1);
}

int GetIndicatorLastLow(int shift)
{
   for (int i = shift + 5; i < Bars - 5; i++)
   {
      if (Line2Buffer[i] <= Line2Buffer[i + 1] && Line2Buffer[i] < Line2Buffer[i + 2] && Line2Buffer[i] <= Line2Buffer[i - 1] && Line2Buffer[i] < Line2Buffer[i - 2])
         return (i);
   }

   return (-1);
}


void DrawPriceTrendLine(string first, datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   string label = IndicatorObjPrefix + first + "os" + DoubleToStr(t1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, t1, p1, t2, p2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
}

void DrawIndicatorTrendLine(string first, datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   int indicatorWindow = WindowFind(indicatorName);
   if (indicatorWindow < 0)
      return;

   string label = IndicatorObjPrefix + first + DoubleToStr(t1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, indicatorWindow, t1, p1, t2, p2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
}