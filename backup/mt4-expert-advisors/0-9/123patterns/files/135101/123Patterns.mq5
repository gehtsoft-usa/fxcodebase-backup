// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70042

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

#property indicator_chart_window
#property indicator_plots 8
#property indicator_buffers 8
#property indicator_color1 DodgerBlue // UpperLine
#property indicator_color2 OrangeRed  // LowerLine
#property indicator_color3 LimeGreen  // Target1
#property indicator_color4 LimeGreen  // Target2
#property indicator_color5 DodgerBlue // BuyArrow
#property indicator_color6 OrangeRed  // SellArrow
#property indicator_color7 DodgerBlue // BullDot
#property indicator_color8 OrangeRed  // BearDot
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 3 // BuyArrow
#property indicator_width6 3 // SellArrow
#property indicator_width7 3 // BullDot
#property indicator_width8 3 // BearDot

input string Notes = "15pip RangeBars Basic Setup";
input int ZigZagDepth = 4;
input double RetraceDepthMin = 0.4;
input double RetraceDepthMax = 1.0;
input bool ShowAllLines = true;
input bool ShowAllBreaks = true;
input bool ShowTargets = false;
input double Target1Multiply = 1.5;
input double Target2Multiply = 3.0;
input bool HideTransitions = true;
input bool alertsOn = true;
input bool alertsOnCurrent = false;
input bool alertsMessage = true;
input bool alertsSound = false;
input bool alertsNotify = true;
input bool alertsEmail = true;
input string UniqueID = "GlobalVariable1";

// indicator buffers
double UpperLine[];
double LowerLine[];
double Target1[];
double Target2[];
double BuyArrow[];
double SellArrow[];
double BullDot[];
double BearDot[];

double signalprice, brokenline;
datetime signaltime;
datetime redrawtime; // remember when the indicator was redrawn

int signal;
#define NOSIG 0
#define BUYSIG 1
#define SELLSIG 2

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

int zz;
int OnInit(void)
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("123Patterns");
   IndicatorSetString(INDICATOR_SHORTNAME, "123Patterns");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   SetIndexBuffer(0, UpperLine, ShowAllLines ? INDICATOR_DATA : INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(0, PLOT_LABEL, "UpperLine");

   SetIndexBuffer(1, LowerLine, ShowAllLines ? INDICATOR_DATA : INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(1, PLOT_LABEL, "LowerLine");

   SetIndexBuffer(2, Target1, ShowAllLines ? INDICATOR_DATA : INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(2, PLOT_LABEL, "Target1");

   SetIndexBuffer(3, Target2, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(3, PLOT_LABEL, "Target2");

   SetIndexBuffer(4, BuyArrow, INDICATOR_DATA);
   PlotIndexSetInteger(4, PLOT_ARROW, 217);
   PlotIndexSetInteger(4, PLOT_ARROW_SHIFT, 5);

   SetIndexBuffer(5, SellArrow, INDICATOR_DATA);
   PlotIndexSetInteger(5, PLOT_ARROW, 218);
   PlotIndexSetInteger(5, PLOT_ARROW_SHIFT, 5);

   SetIndexBuffer(6, BullDot, INDICATOR_DATA);
   PlotIndexSetInteger(6, PLOT_ARROW, 159);
   PlotIndexSetInteger(6, PLOT_ARROW_SHIFT, 5);

   SetIndexBuffer(7, BearDot, INDICATOR_DATA);
   PlotIndexSetInteger(7, PLOT_ARROW, 159);
   PlotIndexSetInteger(7, PLOT_ARROW_SHIFT, 5);

   zz = iCustom(_Symbol, 0, "Examples/ZigZag", ZigZagDepth, 5, 3);

   return (0);
}

void OnDeinit(const int reason)
{
   IndicatorRelease(zz);
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}
//+------------------------------------------------------------------+
//| Status Message prints below OHLC upper left of chart window
//+------------------------------------------------------------------+
void StatusMessage()
{
   string symbol = Symbol();
   if (StringSubstr(symbol, 0, 2) == "_t")
      symbol = StringSubstr(symbol, 2);
   double multi = 1;
   int digits = Digits();
   if (digits == 3 || digits == 5)
      multi = 10.0;
   string msg = "123Patterns" + "  " + TimeToString(TimeCurrent(), TIME_MINUTES) + "  ";
   if (signal == NOSIG)
      msg = msg + "NOSIG  ";
   if (signal == BUYSIG)
      msg = msg + "BUYSIG  " + TimeToString(signaltime, TIME_MINUTES) + "  " + DoubleToString(signalprice, Digits()) + "  ";
   if (signal == SELLSIG)
      msg = msg + "SELLSIG  " + TimeToString(signaltime, TIME_MINUTES) + "  " + DoubleToString(signalprice, Digits()) + "  ";
   msg = msg + "ZigZagDepth=" + ZigZagDepth + "  ";
   msg = msg + "Spread=" + DoubleToString(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / multi, 2) + "  ";
   msg = msg + "Range=" + (iHigh(symbol, _Period, 0) - iLow(symbol, _Period, 0)) / (SymbolInfoDouble(symbol, SYMBOL_POINT) * multi) + "  ";
   Comment(msg);
   GlobalVariableSet(UniqueID + ":0", signal);
   GlobalVariableSet(UniqueID + ":1", signaltime);
   GlobalVariableSet(UniqueID + ":2", signalprice);
}

double one, prevhigh, lasthigh, prevlow, firstlow, lastlow, two, three, retracedepth, firsthigh, range;
int twotime, threetime, firsthightime;
int onetime, prevlowtime, lastlowtime, prevhightime, lasthightime, firstlowtime;

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
      ArrayInitialize(UpperLine, EMPTY_VALUE);
      ArrayInitialize(LowerLine, EMPTY_VALUE);
      ArrayInitialize(Target1, EMPTY_VALUE);
      ArrayInitialize(Target2, EMPTY_VALUE);
      ArrayInitialize(BuyArrow, EMPTY_VALUE);
      ArrayInitialize(SellArrow, EMPTY_VALUE);
      ArrayInitialize(BullDot, EMPTY_VALUE);
      ArrayInitialize(BearDot, EMPTY_VALUE);
      redrawtime = 0;
   }
   if (redrawtime == time[rates_total - 1])
   {
      StatusMessage();
      return rates_total;
   } // if already redrawn on this candle then do no more
   else
   {
      redrawtime = time[rates_total - 1]; // remember when the indicator was redrawn
   }
   int first = 1;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      UpperLine[pos] = UpperLine[pos - 1];
      LowerLine[pos] = LowerLine[pos - 1];
      Target1[pos] = Target1[pos - 1];
      Target2[pos] = Target2[pos - 1];
      BuyArrow[pos] = EMPTY_VALUE;
      SellArrow[pos] = EMPTY_VALUE;
      BullDot[pos] = EMPTY_VALUE;
      BearDot[pos] = EMPTY_VALUE;
      double zzVals[1];
      if (CopyBuffer(zz, 0, oldPos, 1, zzVals) != 1)
      {
         continue;
      }
      if (zzVals[0] == high[pos])
      {
         UpperLine[pos] = high[pos];
         firsthigh = prevhigh;
         firsthightime = prevhightime;
         prevhigh = lasthigh;
         prevhightime = lasthightime;
         lasthigh = zzVals[0];
         lasthightime = pos;
      }
      if (zzVals[0] == low[pos])
      {
         LowerLine[pos] = low[pos];
         firstlow = prevlow;
         firstlowtime = prevlowtime;
         prevlow = lastlow;
         prevlowtime = lastlowtime;
         lastlow = zzVals[0];
         lastlowtime = pos;
      }
      one = prevlow;
      onetime = prevlowtime;
      two = lasthigh;
      twotime = lasthightime;
      if (twotime == pos)
      {
         two = prevhigh;
         twotime = prevhightime;
      }
      three = lastlow;
      threetime = lastlowtime;
      if (one - two != 0)
      {
         retracedepth = (three - two) / (one - two); // retrace depth
      }
      if (pos < rates_total - 1 
         && retracedepth > RetraceDepthMin // minimum retrace depth for 123 pattern
         && retracedepth < RetraceDepthMax // maximum retrace depth for 123 pattern
         && brokenline != UpperLine[pos] // if this line has not already been broken
         && low[pos] < UpperLine[pos] // low of rangebar is below the line
         && close[pos] > UpperLine[pos]) // close of rangebar body is above the line (break)
      {
         range = MathAbs(two - three); // range is the distance between two and three
         Target1[pos] = two + (range * Target1Multiply);
         Target2[pos] = two + (range * Target2Multiply);
         BuyArrow[pos] = low[pos] - (high[pos] - low[pos]) / 3;
         BullDot[onetime] = one;     // ONE
         BullDot[twotime] = two;     // TWO
         BullDot[threetime] = three; // THREE
         signal = BUYSIG;
         signaltime = pos;
         signalprice = BuyArrow[pos];
         brokenline = UpperLine[pos];
      }
      if (pos > 0
         && ShowAllBreaks
         && brokenline != UpperLine[pos] // if this line has not already been broken
         && low[pos] < UpperLine[pos]    // low of rangebar is below the line
         && close[pos] > UpperLine[pos]) // close of rangebar body is above the line (break)
      {
         range = UpperLine[pos] - LowerLine[pos];
         Target1[pos] = UpperLine[pos] + (range * Target1Multiply);
         Target2[pos] = UpperLine[pos] + (range * Target2Multiply);
         BuyArrow[pos] = low[pos] - (high[pos] - low[pos]) / 3;
         signal = BUYSIG;
         signaltime = pos;
         signalprice = BuyArrow[pos];
         brokenline = UpperLine[pos];
      }
      one = prevhigh;
      onetime = prevhightime;
      two = lastlow;
      twotime = lastlowtime;
      if (twotime == pos)
      {
         two = prevlow;
         twotime = prevlowtime;
      }
      three = lasthigh;
      threetime = lasthightime;
      if (one - two != 0)
      {
         retracedepth = (three - two) / (one - two); // retrace depth
      }
      // signal rules
      if (pos > 0
         && retracedepth > RetraceDepthMin // minimum retrace depth for 123 pattern
         && retracedepth < RetraceDepthMax // maximum retrace depth for 123 pattern
         && brokenline != LowerLine[pos]   // if this line has not already been broken
         && high[pos] > LowerLine[pos]     // high of rangebar is above the line
         && close[pos] < LowerLine[pos])   // close of rangebar is below the line (break)
      {
         range = MathAbs(two - three); // range is the distance between two and three
         Target1[pos] = two - (range * Target1Multiply);
         Target2[pos] = two - (range * Target2Multiply);
         SellArrow[pos] = high[pos] + (high[pos] - low[pos]) / 3;
         BearDot[onetime] = one;     // ONE
         BearDot[twotime] = two;     // TWO
         BearDot[threetime] = three; // THREE
         signal = SELLSIG;
         signaltime = pos;
         signalprice = SellArrow[pos];
         brokenline = LowerLine[pos];
      }

      /////////////////////////////////////////////
      // BEARISH BREAK OF LOWERLINE (NOT 123 SETUP)
      // signal rules

      if (pos > 0
         && ShowAllBreaks
         && brokenline != LowerLine[pos]        // if this line has not already been broken
         && high[pos] > LowerLine[pos]     // high of rangebar is above the line
         && close[pos] < LowerLine[pos]) // close of rangebar is below the line (break)
      {
         range = UpperLine[pos] - LowerLine[pos];
         Target1[pos] = LowerLine[pos] - (range * Target1Multiply);
         Target2[pos] = LowerLine[pos] - (range * Target2Multiply);
         SellArrow[pos] = high[pos] + (high[pos] - low[pos]) / 3;
         signal = SELLSIG;
         signaltime = pos;
         signalprice = SellArrow[pos];
         brokenline = LowerLine[pos];
      }

      // TARGET LINE RULES
      if (signal == BUYSIG)
      {
         if (low[pos] > Target1[pos])
         {
            Target1[pos] = EMPTY_VALUE;
         }
         if (low[pos] > Target2[pos])
         {
            Target2[pos] = EMPTY_VALUE;
         }
      }
      if (signal == SELLSIG)
      {
         if (high[pos] < Target1[pos])
         {
            Target1[pos] = EMPTY_VALUE;
         }
         if (high[pos] < Target2[pos])
         {
            Target2[pos] = EMPTY_VALUE;
         }
      }

      // HIDE LINE TRANSITIONS
      if (HideTransitions)
      {
         if (UpperLine[pos] != UpperLine[pos - 1])
         {
            UpperLine[pos - 1] = EMPTY_VALUE;
         }
         if (LowerLine[pos] != LowerLine[pos - 1])
         {
            LowerLine[pos - 1] = EMPTY_VALUE;
         }
         if (Target1[pos] != Target1[pos - 1])
         {
            Target1[pos - 1] = EMPTY_VALUE;
         }
         if (Target2[pos] != Target2[pos - 1])
         {
            Target2[pos - 1] = EMPTY_VALUE;
         }
      }
   }
   return rates_total;
}


         