// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68816

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Green

#property indicator_color3 Yellow
#property indicator_color4 Yellow
#property indicator_color5 Yellow

extern int Length = 30; // Length

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

double utl[], dtl[], ZZW[], SLR[], PVW[];

int init()
{
   IndicatorName = GenerateIndicatorName("AutomaticTrendLine");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(5);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, utl);
   SetIndexLabel(0, "UTL");
   
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, dtl);
   SetIndexLabel(1, "DTL");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, ZZW);

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, SLR);

   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(4, PVW);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

void DoWork(int updn)
{
   int pfr, pto;
   if (!GetLastWave(updn, pfr, pto))
      return;
   if (pfr - pto > 5 && pto >= 0 && pfr >= 0)
   {
      double value1, value2;
      GetRegressionPoint(updn < 0, pfr, pto, value1, value2);
      double step = (value2 - value1) / (pfr - pto);
      for (int i = pfr; i >= pto; --i)
      {
         SLR[i] = value1 + step * (pfr - i);
      }

      int position1, position2;
      Find2Peak(updn < 0, pfr, pto, updn, position1, position2);
      if (updn < 0)
      {
         step = (High[position1] - High[position2]) / (position1 - position2);
         for (int i = position1; i >= 0; --i)
         {
            dtl[i] = High[position1] + step * (position1 - i);
         }
      }
      else
      {
         step = (Low[position1] - Low[position2]) / (position1 - position2);
         for (int i = position1; i >= 0; --i)
         {
            utl[i] = Low[position1] - step * (position1 - i);
         }
      }
   }
}

void SetZZW(int lengthp)
{
   int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, Bars - 1, 0);
   double sMax = iHigh(_Symbol, _Period, highestIndex);
   int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, Bars - 1, 0);
   double sMin = iLow(_Symbol, _Period, lowestIndex);
   double sback = (sMax - sMin) / 100 * MathSqrt(lengthp) * 2;

   int searchhl = 1;
   bool srcfor = true;
   bool srcback = false;
   double preVal = Close[Bars - 1];
   int prePeak = Bars - 1;
   double newVal = Close[Bars - 1];
   int newPeak = Bars - 1;
   for (int iperiod = Bars - 1; iperiod >= 0; --iperiod)
   {
      if (((srcfor ? High[iperiod] : Low[iperiod]) - newVal) * searchhl > 0)
      {
         newVal = (srcfor ? High[iperiod] : Low[iperiod]);
         newPeak = iperiod;
      }
      if ((newPeak - iperiod >= lengthp) && ((newVal-(srcback ? High[iperiod] : Low[iperiod])) * searchhl > sback) )
      {
         ZZW[newPeak] = newVal;
         preVal = newVal;
         prePeak = newPeak;
         searchhl = searchhl * -1;
         
         if (searchhl > 0)
         {
            newPeak = iHighest(_Symbol, _Period, MODE_HIGH, newPeak - iperiod, iperiod);
            newVal = iHigh(_Symbol, _Period, newPeak);
            srcfor = true;
            srcback = false;
         }
         else if (searchhl < 0)
         {
            newPeak = iLowest(_Symbol, _Period, MODE_LOW, newPeak - iperiod, iperiod);
            newVal = iLow(_Symbol, _Period, newPeak);
            srcfor = false;
            srcback = true;
         }
      }
   }

   ZZW[newPeak] = newVal;
   preVal = newVal;
   prePeak = newPeak;
   
   double lastback;
   if (lengthp > 3 && lengthp <= 20)
      lastback = (sMax - sMin) / 100 * 1;
   else if (lengthp > 20 && lengthp <= 40)
      lastback = (sMax - sMin) / 100 * MathSqrt(lengthp*10);
   else if (lengthp > 40 && lengthp <= 100)
      lastback = (sMax - sMin) / 100 * (lengthp*0.75-10);
   else
      lastback = sback;
   
   if (searchhl * -1 > 0 && prePeak > 3)
   {
      newPeak = iHighest(_Symbol, _Period, MODE_HIGH, newPeak, 0);
      newVal = iHigh(_Symbol, _Period, newPeak);
   }
   else if (searchhl * -1 < 0 && prePeak > 3)
   {
      newPeak = iLowest(_Symbol, _Period, MODE_LOW, newPeak, 0);
      newVal = iLow(_Symbol, _Period, newPeak);
   }
   if ((newVal-preVal) * searchhl * -1  > lastback)
      ZZW[newPeak] = newVal;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   
   SetZZW(Length);
   DoWork(-1);
   DoWork(1);
   
   return 0;
}

bool GetLastWave(int updown, int& peakb, int& peake)
{
   double peaka[3];
   int preakIndex[3];
   int index = 0;
   for (int i = 1; i < Bars - 2; ++i)
   {
      double zigzag_curr = ZZW[i];
      if (zigzag_curr != EMPTY_VALUE)
      {
         peaka[index] = zigzag_curr;
         preakIndex[index++] = i;
      }
      if (index == 3)
      {
         if (peaka[0] - peaka[1] * updown > 0)
         {
            peakb = preakIndex[1];
            peake = preakIndex[0];
         }
         else
         {
            peakb = preakIndex[2];
            peake = preakIndex[1];
         }
         return true;
      }
   }
   
   return false;
}

void FindMax(int pos1, int pos2, double& value, int& pos)
{
   pos = -1;
   for (int i = MathMax(pos1, pos2); i >= MathMin(pos1, pos2); --i)
   {
      if (pos == -1 || value < PVW[i])
      {
         pos = i;
         value = PVW[i];
      }
   }
}

void FindMin(int pos1, int pos2, double& value, int& pos)
{
   pos = -1;
   for (int i = MathMax(pos1, pos2); i >= MathMin(pos1, pos2); --i)
   {
      if (pos == -1 || value > PVW[i])
      {
         pos = i;
         value = PVW[i];
      }
   }
}

void Find2Peak(bool isHigh, int pos1, int pos2, int updown, int& peak1, int& peak3)
{
   int peak2 = 0;
   int peak4 = 0;
   double pv1 = 0;
   double pv2 = 0;
   double pv3 = 0;
   double pv4 = 0;
   
   for (int i = pos1; i >= pos2; --i)
      PVW[i] = (isHigh ? High[i] : Low[i]) - SLR[i];
      
   int fromPos = MathMax(pos1, pos2);
   int toPos = MathMin(pos1, pos2);

   int span = (int)MathFloor((pos1 - pos2)/4);
   if (updown < 0)
      if (pos1 - pos2 > 8)
      {
         FindMax(fromPos, fromPos - span * 1, pv1, peak1);
         FindMax(fromPos - span * 1 - 1, fromPos - span * 2, pv2, peak2);
         FindMax(fromPos - span * 2 - 1, fromPos - span * 3, pv3, peak3);
         FindMax(fromPos - span * 3 - 1, toPos, pv4, peak4);
         if (pv1 - pv2 < 0)
         {
            double temp = peak1;
            peak1 = peak2;
            peak2 = temp;
         }
         if (pv3 - pv4 < 0)
         {
            double temp = peak3;
            peak3 = peak4;
            peak4 = temp;
         }
         if (peak1 - peak3 < span)
         {
            if (PVW[peak1] - PVW[peak3] < 0)
            {
               double temp = peak1;
               peak1 = peak3;
               peak3 = temp;
            }
            peak3 = peak4;
         }
      }
      else
      {
         FindMax(fromPos, fromPos - span * 2, pv1, peak1);
         FindMax(fromPos - span * 2 - 1, toPos, pv3, peak3);
      }
   else
      if (pos1 - pos2 > 8)
      {
         FindMin(fromPos, fromPos - span * 1, pv1, peak1);
         FindMin(fromPos - span * 1 - 1, fromPos - span * 2, pv2, peak2);
         FindMin(fromPos - span * 2 - 1, fromPos - span * 3, pv3, peak3);
         FindMin(fromPos - span * 3 - 1, toPos, pv4, peak4);
         if (pv1 - pv2 > 0)
         {
            double temp = peak1;
            peak1 = peak2;
            peak2 = temp;
         }
         if (pv3 - pv4 > 0)
         {
            double temp = peak3;
            peak3 = peak4;
            peak4 = temp;
         }
         if (peak1 - peak3 < span)
         {
            if (PVW[peak1] - PVW[peak3] > 0)
            {
               double temp = peak1;
               peak1 = peak3;
               peak3 = temp;
            }
            peak3 = peak4;
         }
      }
      else
      {
         FindMin(fromPos, fromPos - span * 2, pv1, peak1);
         FindMin(fromPos - span * 2 - 1, toPos, pv3, peak3);
      }
}

void GetRegressionPoint(bool useHigh, int pos1, int pos2, double& value1, double& value2)
{
   double dx_sum = 0;
   double dv_sum = 0;
   
   double x_avg = (pos1 + pos2) / 2;
   double y_avg = iMA(_Symbol, _Period, pos1 - pos2, 0, MODE_SMA, useHigh ? PRICE_HIGH : PRICE_LOW, pos2);
   for (int i = pos1; i >= pos2; --i)
   {
      dv_sum = dv_sum + (i - x_avg) * ((useHigh ? High[i] : Low[i]) - y_avg);
      dx_sum = dx_sum + MathPow(i - x_avg, 2);
   }
   double b1 = dx_sum == 0 ? 0 : dv_sum / dx_sum;
   double b0 = y_avg - b1 * x_avg;
   
   value1 = b1 * pos1 + b0;
   value2 = b1 * pos2 + b0;
}
