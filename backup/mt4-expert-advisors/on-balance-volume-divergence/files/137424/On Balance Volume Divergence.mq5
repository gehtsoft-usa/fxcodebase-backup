// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70400

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

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_label1  "OBV"
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; // Volumes
input color bearish_color = Red; // Bearish color
input color bullish_color = Green; // Bullish color
double ExtOBVBuffer[];

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

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("OBVD");
   IndicatorSetString(INDICATOR_SHORTNAME, "OBV Divergence");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   SetIndexBuffer(0,ExtOBVBuffer);
   IndicatorSetInteger(INDICATOR_DIGITS,0);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

#define DIVERGENCE_PEAK 1
#define DIVERGENCE_TROUGH -1
#define DIVERGENCE_NO 0

bool GetBarType(const int period, int &type, double &val)
{
   double divVal0 = ExtOBVBuffer[period];
   double divVal1 = ExtOBVBuffer[period - 1];
   double divVal2 = ExtOBVBuffer[period - 2];
   double divVal3 = ExtOBVBuffer[period - 3];
   double divVal4 = ExtOBVBuffer[period - 4];
   if (divVal2 >= divVal3 && divVal2 > divVal4 && divVal2 >= divVal1 && divVal2 > divVal0)
   {
      type = DIVERGENCE_PEAK;
      val = divVal2;
      return true;
   }
   if (divVal2 <= divVal3 && divVal2 < divVal4 && divVal2 <= divVal1 && divVal2 < divVal0)
   {
      type = DIVERGENCE_TROUGH;
      val = divVal2;
      return true;
   }
   type = DIVERGENCE_NO;
   return true;
}

enum DivergenceType
{
   DivergenceRegularBearish,
   DivergenceHiddenBearish,
   DivergenceRegularBullish,
   DivergenceHiddenBulish
};

bool IsPass(const int period, const double& high[], const double& low[], DivergenceType& divergence, int& prevPeriod)
{
   int type;
   double divergenceValue;
   if (!GetBarType(period, type, divergenceValue) || type == DIVERGENCE_NO)
   {
      return false;
   }

   prevPeriod = period - 1;
   int prevType;
   double prevDivergenceValue;
   while (prevPeriod > 4 && GetBarType(prevPeriod, prevType, prevDivergenceValue))
   {
      if (prevType != type)
      {
         prevPeriod--;
         continue;
      }
      if (type == DIVERGENCE_PEAK)
      {
         double peakHigh = high[period - 2];
         double prevPeakHigh = high[prevPeriod - 2];
         if (divergenceValue < prevDivergenceValue && peakHigh > prevPeakHigh)
         {
            divergence = DivergenceRegularBearish;
            return true;
         }
         if (divergenceValue > prevDivergenceValue && peakHigh < prevPeakHigh)
         {
            divergence = DivergenceHiddenBearish;
            return true;
         }
         return false;
      }
      double troughLow = low[period - 2];
      double prevTroughLow = low[prevPeriod - 2];
      if (divergenceValue > prevDivergenceValue && troughLow < prevTroughLow)
      {
         divergence = DivergenceRegularBullish;
         return true;
      }
      if (divergenceValue < prevDivergenceValue && troughLow > prevTroughLow)
      {
         divergence = DivergenceHiddenBulish;
         return true;
      }
      return false;
   }
   return false;
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
   int pos;
   if (rates_total < 6)
      return 0;
   pos = prev_calculated - 1;
   if (pos < 5)
   {
      pos = 5;
      for (int i = 0; i < pos; ++i)
      {
         if (InpVolumeType == VOLUME_TICK)
            ExtOBVBuffer[i] = (double)tick_volume[i];
         else 
            ExtOBVBuffer[i] = (double)volume[i];
      }
   }
   if (InpVolumeType == VOLUME_TICK)
      CalculateOBV(pos, rates_total, close, tick_volume);
   else
      CalculateOBV(pos, rates_total, close, volume);

   for (int i = pos; i < rates_total && !IsStopped(); i++)
   {
      DivergenceType divergence;
      int prevPeriod;
      if (IsPass(i, high, low, divergence, prevPeriod))
      {
         switch (divergence)
         {
            case DivergenceRegularBearish:
            case DivergenceHiddenBearish:
               {
                  string id = IndicatorObjPrefix + TimeToString(time[prevPeriod]);
                  if (ObjectFind(0, id) == -1)
                  {
                     if (ObjectCreate(0, id, OBJ_TREND, 0, time[i - 2], high[i - 2], time[prevPeriod], high[prevPeriod]))
                     {
                        ObjectSetInteger(0, id, OBJPROP_COLOR, bearish_color);
                        ObjectSetInteger(0, id, OBJPROP_RAY_LEFT, false);
                        ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
                     }
                  }
                  ObjectSetInteger(0, id, OBJPROP_TIME, 0, time[i - 2]);
                  ObjectSetDouble(0, id, OBJPROP_PRICE, 0, high[i - 2]);
                  ObjectSetInteger(0, id, OBJPROP_TIME, 1, time[prevPeriod]);
                  ObjectSetDouble(0, id, OBJPROP_PRICE, 1, high[prevPeriod]);
                  
                  id = IndicatorObjPrefix + TimeToString(time[prevPeriod]) + "_";
                  if (ObjectFind(0, id) == -1)
                  {
                     if (ObjectCreate(0, id, OBJ_TREND, ChartWindowFind(), time[i - 2], ExtOBVBuffer[i - 2], time[prevPeriod], ExtOBVBuffer[prevPeriod]))
                     {
                        ObjectSetInteger(0, id, OBJPROP_COLOR, bearish_color);
                        ObjectSetInteger(0, id, OBJPROP_RAY_LEFT, false);
                        ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
                     }
                  }
                  ObjectSetInteger(0, id, OBJPROP_TIME, 0, time[i - 2]);
                  ObjectSetDouble(0, id, OBJPROP_PRICE, 0, ExtOBVBuffer[i - 2]);
                  ObjectSetInteger(0, id, OBJPROP_TIME, 1, time[prevPeriod]);
                  ObjectSetDouble(0, id, OBJPROP_PRICE, 1, ExtOBVBuffer[prevPeriod]);
               }
               break;

            case DivergenceRegularBullish:
            case DivergenceHiddenBulish:
               {
                  string id = IndicatorObjPrefix + TimeToString(time[prevPeriod]);
                  if (ObjectFind(0, id) == -1)
                  {
                     if (ObjectCreate(0, id, OBJ_TREND, 0, time[i - 2], low[i - 2], time[prevPeriod], low[prevPeriod]))
                     {
                        ObjectSetInteger(0, id, OBJPROP_COLOR, bullish_color);
                        ObjectSetInteger(0, id, OBJPROP_RAY_LEFT, false);
                        ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
                     }
                  }
                  ObjectSetInteger(0, id, OBJPROP_TIME, 0, time[i - 2]);
                  ObjectSetDouble(0, id, OBJPROP_PRICE, 0, low[i - 2]);
                  ObjectSetInteger(0, id, OBJPROP_TIME, 1, time[prevPeriod]);
                  ObjectSetDouble(0, id, OBJPROP_PRICE, 1, low[prevPeriod]);

                  id = IndicatorObjPrefix + TimeToString(time[prevPeriod]) + "_";
                  if (ObjectFind(0, id) == -1)
                  {
                     if (ObjectCreate(0, id, OBJ_TREND, ChartWindowFind(), time[i - 2], ExtOBVBuffer[i - 2], time[prevPeriod], ExtOBVBuffer[prevPeriod]))
                     {
                        ObjectSetInteger(0, id, OBJPROP_COLOR, bullish_color);
                        ObjectSetInteger(0, id, OBJPROP_RAY_LEFT, false);
                        ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
                     }
                  }
                  ObjectSetInteger(0, id, OBJPROP_TIME, 0, time[i - 2]);
                  ObjectSetDouble(0, id, OBJPROP_PRICE, 0, ExtOBVBuffer[i - 2]);
                  ObjectSetInteger(0, id, OBJPROP_TIME, 1, time[prevPeriod]);
                  ObjectSetDouble(0, id, OBJPROP_PRICE, 1, ExtOBVBuffer[prevPeriod]);
               }
               break;
         }
      }
   }
   return rates_total;
}

void CalculateOBV(int StartPosition,
                  int RatesCount,
                  const double &ClBuffer[],
                  const long &VolBuffer[])
{
   for (int i = StartPosition; i < RatesCount && !IsStopped(); i++)
   {
      double Volume = (double)VolBuffer[i];
      double PrevClose = ClBuffer[i - 1];
      double CurrClose = ClBuffer[i];
      if (CurrClose < PrevClose)
         ExtOBVBuffer[i] = ExtOBVBuffer[i - 1] - Volume;
      else
      {
         if (CurrClose > PrevClose) 
            ExtOBVBuffer[i] = ExtOBVBuffer[i - 1] + Volume;
         else
            ExtOBVBuffer[i] = ExtOBVBuffer[i - 1];
      }
   }
}
//+------------------------------------------------------------------+
