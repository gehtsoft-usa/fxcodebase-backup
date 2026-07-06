// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=71034

//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC |
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

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 DodgerBlue
#property indicator_color2 OrangeRed
#property indicator_color3 Lime
#property indicator_color4 White

//---- indicator parameters
ENUM_TIMEFRAMES TimeFrame;
input ENUM_TIMEFRAMES _TimeFrame = PERIOD_CURRENT; // Time frame
input int MA_Period = 14;
input int MA_Shift = 0;
input ENUM_MA_METHOD MA_Method = MODE_LWMA;
input bool UseSignal = true;

input string note = "turn on Alert = true; turn off = false";
input bool alertsOn = true;
input bool alertsOnCurrent = true;
input bool alertsMessage = true;
input bool alertsSound = true;
input bool alertsEmail = false;
input bool alertsNotify = false;
input string soundFile = "alert2.wav";
input int UpArrowCode = 250;
input int DnArrowCode = 250;
input int arrow_distance = 2;  // Arrow distance, pips
input bool Interpolate = true; // Interpolate in multi time frame mode
//---- indicator buffers
double UpBuffer[];
double DnBuffer[];
double UpSignal[];
double DnSignal[];
double smax[];
double smin[];
double trend[], count[];
string indicatorFileName;
#define _mtfCall(_buff, _y) iCustom(NULL, TimeFrame, indicatorFileName, PERIOD_CURRENT, MA_Period, 0, MA_Method, UseSignal, "", alertsOn, alertsOnCurrent, alertsMessage, alertsSound, alertsEmail, alertsNotify, soundFile, _buff, _y)
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(8);
   SetIndexBuffer(0, UpBuffer);
   SetIndexLabel(0, "UpTrendEnv");
   SetIndexBuffer(1, DnBuffer);
   SetIndexLabel(1, "DnTrendEnv");
   SetIndexBuffer(2, UpSignal);
   SetIndexLabel(2, "UpSignal");
   SetIndexBuffer(3, DnSignal);
   SetIndexLabel(3, "DnSignal");
   SetIndexBuffer(4, smax);
   SetIndexBuffer(5, smin);
   SetIndexBuffer(6, trend);
   SetIndexShift(0, MA_Shift);
   SetIndexShift(2, MA_Shift);
   SetIndexShift(1, MA_Shift);
   SetIndexShift(3, MA_Shift);
   SetIndexBuffer(7, count);

   if (UseSignal)
   {
      SetIndexStyle(2, DRAW_ARROW);
      SetIndexArrow(2, UpArrowCode);
      SetIndexStyle(3, DRAW_ARROW);
      SetIndexArrow(3, DnArrowCode);
   }
   else
   {
      SetIndexStyle(2, DRAW_NONE);
      SetIndexStyle(3, DRAW_NONE);
   }
   IndicatorShortName("Env(" + MA_Period + ")");
   indicatorFileName = WindowExpertName();
   TimeFrame = MathMax(_TimeFrame, _Period);
   return (0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0)
      return (-1);
   if (counted_bars > 0)
      counted_bars--;
   double point = MarketInfo(_Symbol, MODE_POINT);
   int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   double pipSize = point * mult;
   int limit = MathMin(Bars - counted_bars, Bars - 1);
   count[0] = limit;
   if (TimeFrame != Period())
   {
      limit = (int)MathMax(limit, MathMin(Bars - 1, (_mtfCall(8, 0) + 1) * TimeFrame / _Period));
      for (int i = limit; i >= 0 && !_StopFlag; i--)
      {
         int y = iBarShift(NULL, TimeFrame, Time[i]);
         int x = iBarShift(NULL, TimeFrame, Time[i + 1]);
         UpBuffer[i] = _mtfCall(0, y);
         DnBuffer[i] = _mtfCall(1, y);
         if (x != y)
         {
            UpSignal[i] = _mtfCall(2, y) + arrow_distance * pipSize;
            DnSignal[i] = _mtfCall(3, y) - arrow_distance * pipSize;
         }
         else
         {
            UpSignal[i] = EMPTY_VALUE;
            DnSignal[i] = EMPTY_VALUE;
         }

#define _interpolate(buff) buff[i + k] = buff[i] + (buff[i + n] - buff[i]) * k / n
         if (!Interpolate || (i > 0 && y == iBarShift(NULL, TimeFrame, Time[i - 1])))
            continue;
         int n, k;
         datetime ctime = iTime(NULL, TimeFrame, y);
         for (n = 1; (i + n) < Bars && Time[i + n] >= ctime; n++)
            continue;
         for (k = 1; k < n && (i + n) < Bars && (i + k) < Bars; k++)
         {
            if (DnBuffer[i + n] != EMPTY_VALUE)
               _interpolate(DnBuffer);
            if (UpBuffer[i + n] != EMPTY_VALUE)
               _interpolate(UpBuffer);
         }
      }
      return (0);
   }
   //
   //
   //
   //
   //

   for (i = limit; i >= 0; i--)
   {
      smax[i] = iMA(NULL, 0, MA_Period, 0, MA_Method, PRICE_HIGH, i);
      smin[i] = iMA(NULL, 0, MA_Period, 0, MA_Method, PRICE_LOW, i);
      UpSignal[i] = EMPTY_VALUE;
      DnSignal[i] = EMPTY_VALUE;
      UpBuffer[i] = EMPTY_VALUE;
      DnBuffer[i] = EMPTY_VALUE;
      trend[i] = trend[i + 1];

      //
      //
      //
      //
      //

      if (Close[i] > smax[i + 1])
         trend[i] = 1;
      if (Close[i] < smin[i + 1])
         trend[i] = -1;
      if (trend[i] > 0 && smin[i] < smin[i + 1])
         smin[i] = smin[i + 1];
      if (trend[i] < 0 && smax[i] > smax[i + 1])
         smax[i] = smax[i + 1];
      if (trend[i] == 1)
      {
         UpBuffer[i] = smin[i];
         if (trend[i + 1] != 1)
            UpSignal[i] = UpBuffer[i] + arrow_distance * pipSize;
      }
      if (trend[i] == -1)
      {
         DnBuffer[i] = smax[i];
         if (trend[i + 1] != -1)
            DnSignal[i] = DnBuffer[i] - arrow_distance * pipSize;
      }
   }

   //
   //
   //
   //
   //

   if (alertsOn)
   {
      if (alertsOnCurrent)
         int whichBar = 0;
      else
         whichBar = 1;
      if (trend[whichBar] != trend[whichBar + 1])
         if (trend[whichBar] == 1)
            doAlert("Buy");
         else
            doAlert("Sell");
   }
   return (0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(string doWhat)
{
   static string previousAlert = "nothing";
   static datetime previousTime;
   string message;

   if (previousAlert != doWhat || previousTime != Time[0])
   {
      previousAlert = doWhat;
      previousTime = Time[0];

      //
      //
      //
      //
      //

      message = StringConcatenate(Symbol(), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " TrendEnvelopes ", doWhat);
      if (alertsMessage)
         Alert(message);
      if (alertsNotify)
         SendNotification(message);
      if (alertsEmail)
         SendMail(StringConcatenate(Symbol(), " TrendEnvelopes "), message);
      if (alertsSound)
         PlaySound(soundFile);
   }
}