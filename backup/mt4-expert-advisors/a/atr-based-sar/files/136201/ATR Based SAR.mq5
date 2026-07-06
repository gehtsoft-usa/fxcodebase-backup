// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70210

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

#property strict
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 1
#property indicator_color1 Red,Green

input int Period = 14; // Period
input double Multiplier = 20; // Step Multiplier
input double Max = 40; // Max Multiplier

double SAR[], sarColor[];
double tradeHigh[], tradeLow[], position[], parOp[], af[];
      
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

int atr;
void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("atrbsar");
   IndicatorSetString(INDICATOR_SHORTNAME, "ATR Based SAR");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, SAR, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_COLOR_LINE);
   PlotIndexSetString(id, PLOT_LABEL, "SAR");
   ++id;
   SetIndexBuffer(id, sarColor, INDICATOR_COLOR_INDEX);
   ++id;
   SetIndexBuffer(id, tradeHigh, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, tradeLow, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, position, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, parOp, INDICATOR_CALCULATIONS);
   ++id;
   SetIndexBuffer(id, af, INDICATOR_CALCULATIONS);
   ++id;
   atr = iATR(_Symbol, _Period, Period);
}

void OnDeinit(const int reason)
{
   IndicatorRelease(atr);
   ObjectsDeleteAll(0, IndicatorObjPrefix);
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
      ArrayInitialize(SAR, EMPTY_VALUE);
      ArrayInitialize(tradeHigh, EMPTY_VALUE);
      ArrayInitialize(tradeLow, EMPTY_VALUE);
      ArrayInitialize(position, EMPTY_VALUE);
      ArrayInitialize(parOp, EMPTY_VALUE);
      ArrayInitialize(af, EMPTY_VALUE);
   }
   int first = 1;
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double atrValue[1];
      if (CopyBuffer(atr, 0, oldPos, 1, atrValue) != 1)
      {
         continue;
      }
      double init = atrValue[0] * Multiplier;
      double quant = atrValue[0] * Multiplier;
      double maxVal = atrValue[0] * Max;
      double prevHigh = high[pos - 1];
      double prevLow = low[pos - 1];
      if (parOp[pos - 1] == EMPTY_VALUE)
      {
         tradeHigh[pos] = prevHigh;
         tradeLow[pos] = prevLow;
         position[pos] = -1;
         parOp[pos] = prevHigh;
         af[pos] = 0;
      }
      else
      {
         parOp[pos] = parOp[pos - 1];
         position[pos] = position[pos - 1];
         tradeHigh[pos] = tradeHigh[pos - 1];
         tradeLow[pos] = tradeLow[pos - 1];
         af[pos] = af[pos - 1];
      }
      double lastHighest = tradeHigh[pos];
      double lastLowest = tradeLow[pos];
      if (high[pos] > lastHighest)
      {
         tradeHigh[pos] = high[pos];
      }
      if (low[pos] < lastLowest)
      {
         tradeLow[pos] = low[pos];
      }
      double sarValue = EMPTY_VALUE;
      if (position[pos] == 1)
      {
         if (low[pos] < parOp[pos])
         {
            position[pos] = -1;
            sarValue = lastHighest;
            tradeHigh[pos] = high[pos];
            tradeLow[pos] = low[pos];
            af[pos] = init;
            parOp[pos] = sarValue + af[pos] * (tradeLow[pos] - sarValue);
            if (parOp[pos] < high[pos])
            {
               parOp[pos] = high[pos];
            }
            if (parOp[pos] < prevHigh)
            {
               parOp[pos] = prevHigh;
            }
         }
         else
         {
            sarValue = parOp[pos];
            if (tradeHigh[pos] > tradeHigh[pos - 1] && af[pos] < maxVal)
            {
               af[pos] = af[pos] + quant;
               if (af[pos] > maxVal)
               {
                  af[pos] = maxVal;
               }
            }
            parOp[pos] = sarValue + af[pos] * (tradeHigh[pos] - sarValue);
            if (parOp[pos] > low[pos])
            {
               parOp[pos] = low[pos];
            }
            if (parOp[pos] > prevLow)
            {
               parOp[pos] = prevLow;
            }
         }
      }
      else
      {
         if (high[pos] > parOp[pos])
         {
            position[pos] = 1;
            sarValue = lastLowest;
            tradeHigh[pos] = high[pos];
            tradeLow[pos] = low[pos];
            af[pos] = init;
            parOp[pos] = sarValue + af[pos] * (tradeHigh[pos] - sarValue);
            if (parOp[pos] > low[pos])
            {
               parOp[pos] = low[pos];
            }
            if (parOp[pos] > prevLow)
            {
               parOp[pos] = prevLow;
            }
         }
         else
         {
            sarValue = parOp[pos];
            if (tradeLow[pos] < tradeLow[pos - 1] && af[pos] < maxVal)
            {
               af[pos] = af[pos] + quant;
               if (af[pos] > maxVal)
               {
                  af[pos] = maxVal;
               }
            }

            parOp[pos] = sarValue + af[pos] * (tradeLow[pos] - sarValue);
            if (parOp[pos] < high[pos])
            {
               parOp[pos] = high[pos];
            }
            if (parOp[pos] < prevHigh)
            {
               parOp[pos] = prevHigh;
            }
         }
      }
      SAR[pos] = sarValue;
      sarColor[pos] = position[pos] == 1 ? 0 : 1;
   }
   return rates_total;
}