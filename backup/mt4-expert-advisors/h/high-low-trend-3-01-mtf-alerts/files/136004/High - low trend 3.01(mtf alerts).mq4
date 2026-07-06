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
#property indicator_buffers 9
#property indicator_color1 clrDimGray
#property indicator_color2 clrDimGray
#property indicator_color3 clrDimGray
#property indicator_color4 clrDeepSkyBlue
#property indicator_color5 clrDeepSkyBlue
#property indicator_color6 clrPaleVioletRed
#property indicator_color7 clrPaleVioletRed
#property indicator_color8 clrDeepSkyBlue
#property indicator_color9 clrPaleVioletRed
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT
#property indicator_width8 2
#property indicator_width9 2
#property strict

input ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT; // Time frame
input int HighLowPeriod = 10;                     // High low period
input int ZigZagLineWidth = 0;                    // Lines width
input bool alertsOn = false;                      // Turn alerts on?
input bool alertsOnCurrent = false;               // Alerts on still opened bar?
input bool alertsMessage = true;                  // Alerts should display message?
input bool alertsSound = false;                   // Alerts should play a sound?
input bool alertsNotify = false;                  // Alerts should send a notification?
input bool alertsEmail = false;                   // Alerts should send an email?
input string soundFile = "alert2.wav";            // Sound file
input bool Interpolate = true;                    // Interpolate in multi time frame mode?


class VisibilityCotroller
{
   string buttonId;
   string visibilityId;
   bool show_data;
   bool recalc;

public:
   void Init(string id, string indicatorName, string caption, int x, int y)
   {
      recalc = false;
      visibilityId = indicatorName + "_visibility";
      double val;
      if (GlobalVariableGet(visibilityId, val))
         show_data = val != 0;

      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, caption, 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, x);
   }

   void DeInit()
   {
      ObjectDelete(ChartID(), buttonId);
   }

   bool HandleButtonClicks()
   {
      if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
      {
         ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
         show_data = !show_data;
         GlobalVariableSet(visibilityId, show_data ? 1.0 : 0.0);
         recalc = true;
         return true;
      }
      return false;
   }

   bool IsRecalcNeeded()
   {
      return recalc;
   }

   void ResetRecalc()
   {
      recalc = false;
   }

   bool IsVisible()
   {
      return show_data;
   }

private:
   void createButton(string buttonID, string buttonText, int width, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
   {
      ObjectDelete(0, buttonID);
      ObjectCreate(0, buttonID, OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0, buttonID, OBJPROP_COLOR, txtColor);
      ObjectSetInteger(0, buttonID, OBJPROP_BGCOLOR, bgColor);
      ObjectSetInteger(0, buttonID, OBJPROP_BORDER_COLOR, borderColor);
      ObjectSetInteger(0, buttonID, OBJPROP_BORDER_TYPE, BORDER_RAISED);
      ObjectSetInteger(0, buttonID, OBJPROP_XDISTANCE, 9999);
      ObjectSetInteger(0, buttonID, OBJPROP_YDISTANCE, 9999);
      ObjectSetInteger(0, buttonID, OBJPROP_XSIZE, width);
      ObjectSetInteger(0, buttonID, OBJPROP_YSIZE, height);
      ObjectSetString(0, buttonID, OBJPROP_FONT, font);
      ObjectSetString(0, buttonID, OBJPROP_TEXT, buttonText);
      ObjectSetInteger(0, buttonID, OBJPROP_FONTSIZE, fontSize);
      ObjectSetInteger(0, buttonID, OBJPROP_SELECTABLE, 0);
      ObjectSetInteger(0, buttonID, OBJPROP_CORNER, 2);
      ObjectSetInteger(0, buttonID, OBJPROP_HIDDEN, 1);
   }
};

input int button_x = 20;
input int button_y = 30;

VisibilityCotroller visibility;
ENUM_TIMEFRAMES tf;

double peakUp[], peakDn[], legUpa[], legUpb[], legDna[], legDnb[], limHi[], limMi[], limLo[], leg[], zigzag[], trend[], value[], count[];
string indicatorFileName;
#define _mtfCall(_buf, _ind) iCustom(NULL, TimeFrame, indicatorFileName, 0, HighLowPeriod, ZigZagLineWidth, alertsOn, alertsOnCurrent, alertsMessage, alertsSound, alertsNotify, alertsEmail, soundFile, _buf, _ind)
//+------------------------------------------------------------------
int init()
{
   visibility.Init("hlt", "hlt", "Show/Hide", button_x, button_y);
   IndicatorBuffers(14);
   SetIndexBuffer(0, limHi);
   SetIndexBuffer(1, limMi);
   SetIndexBuffer(2, limLo);
   SetIndexBuffer(3, legUpa);
   SetIndexBuffer(4, legUpb);
   SetIndexBuffer(5, legDna);
   SetIndexBuffer(6, legDnb);
   SetIndexBuffer(7, peakUp);
   SetIndexArrow(7, 159);
   SetIndexBuffer(8, peakDn);
   SetIndexArrow(8, 159);
   SetIndexBuffer(9, leg);
   SetIndexBuffer(10, trend);
   SetIndexBuffer(11, value);
   SetIndexBuffer(12, zigzag);
   SetIndexBuffer(13, count);

   SetIndexStyle(3, EMPTY, EMPTY, ZigZagLineWidth);
   SetIndexStyle(4, EMPTY, EMPTY, ZigZagLineWidth);
   SetIndexStyle(5, EMPTY, EMPTY, ZigZagLineWidth);
   SetIndexStyle(6, EMPTY, EMPTY, ZigZagLineWidth);
   SetIndexStyle(7, DRAW_ARROW);
   SetIndexStyle(8, DRAW_ARROW);

   indicatorFileName = WindowExpertName();
   tf = TimeFrame;
   if (tf == PERIOD_CURRENT || tf == 0)
   {
      tf = (ENUM_TIMEFRAMES)_Period;
   }
   return (0);
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
      start();
}

//+------------------------------------------------------------------
int deinit()
{
   visibility.DeInit();
   return (0);
}
//+------------------------------------------------------------------
int start()
{
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0)
      return (-1);
   if (counted_bars > 0)
      counted_bars--;
   visibility.HandleButtonClicks();
   if (visibility.IsRecalcNeeded())
   {
      counted_bars = 0;
      ArrayInitialize(limHi, EMPTY_VALUE);
      ArrayInitialize(limMi, EMPTY_VALUE);
      ArrayInitialize(limLo, EMPTY_VALUE);
      ArrayInitialize(legUpa, EMPTY_VALUE);
      ArrayInitialize(legUpb, EMPTY_VALUE);
      ArrayInitialize(legDna, EMPTY_VALUE);
      ArrayInitialize(legDnb, EMPTY_VALUE);
      ArrayInitialize(peakUp, EMPTY_VALUE);
      ArrayInitialize(peakDn, EMPTY_VALUE);
      ArrayInitialize(leg, EMPTY_VALUE);
      ArrayInitialize(trend, EMPTY_VALUE);
      ArrayInitialize(value, EMPTY_VALUE);
      ArrayInitialize(zigzag, EMPTY_VALUE);
      ArrayInitialize(count, EMPTY_VALUE);
   }
   visibility.ResetRecalc();
   if (!visibility.IsVisible())
   {
      return 0;
   }
   Print(12);
   int limit = MathMin(Bars - counted_bars, Bars - 1);
   int countz = 0;
   int k = limit;
   for (; k < Bars && countz < 2; k++)
   {
      if (peakUp[k] != EMPTY_VALUE)
         countz++;
      if (peakDn[k] != EMPTY_VALUE)
         countz++;
   }
   count[0] = k;
   if (tf != _Period)
   {
      limit = (int)MathMax(limit, MathMin(Bars - 1, _mtfCall(13, 0) * tf / Period()));
      if (trend[limit] == 1)
         CleanPoint(limit, legUpa, legUpb);
      if (trend[limit] == -1)
         CleanPoint(limit, legDna, legDnb);
      for (int i = limit; i >= 0; i--)
      {
         int y = iBarShift(NULL, tf, Time[i]);
         int x = (i < Bars - 1) ? iBarShift(NULL, tf, Time[i + 1]) : y;
         if (Interpolate)
            x = (i > 0) ? iBarShift(NULL, tf, Time[i - 1]) : x;
         limHi[i] = _mtfCall(0, y);
         limMi[i] = _mtfCall(1, y);
         limLo[i] = _mtfCall(2, y);
         trend[i] = _mtfCall(10, y);
         zigzag[i] = _mtfCall(12, y);
         peakUp[i] = EMPTY_VALUE;
         peakDn[i] = EMPTY_VALUE;
         if (x != y)
         {
            peakUp[i] = _mtfCall(7, y);
            peakDn[i] = _mtfCall(8, y);
         }

         if (!Interpolate || (i > 0 && y == iBarShift(NULL, tf, Time[i - 1])))
            continue;
#define _interpolate(_buff) _buff[i + k] = _buff[i] + (_buff[i + n] - _buff[i]) * k / n
         int n;
         datetime time = iTime(NULL, tf, y);
         for (n = 1; (i + n) < Bars && Time[i + n] >= time; n++)
            continue;
         for (k = 1; (k < n) && (i + n) < Bars && (i + k) < Bars; k++)
         {
            _interpolate(limHi);
            _interpolate(limLo);
            _interpolate(limMi);
            if (zigzag[i] != EMPTY_VALUE)
               _interpolate(zigzag);
         }
      }
      for (int i = limit; i >= 0; i--)
      {
         legDna[i] = EMPTY_VALUE;
         legDnb[i] = EMPTY_VALUE;
         legUpa[i] = EMPTY_VALUE;
         legUpb[i] = EMPTY_VALUE;
         if (trend[i] == 1)
            PlotPoint(i, legUpa, legUpb, zigzag);
         if (trend[i] == -1)
            PlotPoint(i, legDna, legDnb, zigzag);
      }
      return (0);
   }

   if (trend[limit] == 1)
      CleanPoint(limit, legUpa, legUpb);
   if (trend[limit] == -1)
      CleanPoint(limit, legDna, legDnb);
   for (int i = limit, n = 0; i >= 0; i--)
   {
      peakUp[i] = EMPTY_VALUE;
      peakDn[i] = EMPTY_VALUE;
      zigzag[i] = EMPTY_VALUE;
      limHi[i] = High[ArrayMaximum(High, HighLowPeriod, i)];
      limLo[i] = Low[ArrayMinimum(Low, HighLowPeriod, i)];
      limMi[i] = (limHi[i] + limLo[i]) / 2.0;
      leg[i] = (i < Bars - 1) ? leg[i + 1] : 0;

      if ((i < Bars - 1) && limHi[i] > limHi[i + 1])
         leg[i] = MathMax(1, leg[i + 1] + 1);
      if ((i < Bars - 1) && limLo[i] < limLo[i + 1])
         leg[i] = MathMin(-1, leg[i + 1] - 1);
      if (leg[i] > 0 && leg[i] != leg[i + 1])
      {
         if (leg[i] > 1)
            cleanUppeak(i);
         peakUp[i] = High[i];
      }
      if (leg[i] < 0 && leg[i] != leg[i + 1])
      {
         if (leg[i] < 1)
            cleanDnpeak(i);
         peakDn[i] = Low[i];
      }
      value[i] = (i < Bars - 1) ? (Close[i] > limMi[i]) ? 1 : (Close[i] < limMi[i]) ? -1 : value[i + 1] : 0;

      trend[i] = (i < Bars - 1) ? trend[i + 1] : 0;
      if (peakUp[i] != EMPTY_VALUE || peakDn[i] != EMPTY_VALUE)
      {
         if (peakUp[i] != EMPTY_VALUE)
         {
            for (n = 1; i + n < Bars - 1 && peakUp[i + n] == EMPTY_VALUE; n++)
               continue;
            if (peakUp[i + n] < peakUp[i])
               trend[i] = 1;
            for (n = 1; i + n < Bars - 1 && peakDn[i + n] == EMPTY_VALUE; n++)
               continue;
         }
         if (peakDn[i] != EMPTY_VALUE)
         {
            for (n = 1; i + n < Bars - 1 && peakDn[i + n] == EMPTY_VALUE; n++)
               continue;
            if (peakDn[i + n] > peakDn[i])
               trend[i] = -1;
            for (n = 1; i + n < Bars - 1 && peakUp[i + n] == EMPTY_VALUE; n++)
               continue;
         }

         if (trend[i] == 1)
            if (peakUp[i] != EMPTY_VALUE)
            {
               zigzag[i] = peakUp[i];
               zigzag[i + n] = peakDn[i + n];
            }
            else
            {
               zigzag[i] = peakDn[i];
               zigzag[i + n] = peakUp[i + n];
            }
         else if (peakUp[i] != EMPTY_VALUE)
         {
            zigzag[i] = peakUp[i];
            zigzag[i + n] = peakDn[i + n];
         }
         else
         {
            zigzag[i] = peakDn[i];
            zigzag[i + n] = peakUp[i + n];
         }

         for (k = 1; k < n; k++)
         {
            zigzag[i + k] = zigzag[i] + (zigzag[i + n] - zigzag[i]) * k / n;
            trend[i + k] = trend[i];
         }
         for (k = n - 1; k >= 0; k--)
         {
            legDna[i + k] = EMPTY_VALUE;
            legDnb[i + k] = EMPTY_VALUE;
            legUpa[i + k] = EMPTY_VALUE;
            legUpb[i + k] = EMPTY_VALUE;
            if (trend[i] == 1)
               PlotPoint(i + k, legUpa, legUpb, zigzag);
            if (trend[i] == -1)
               PlotPoint(i + k, legDna, legDnb, zigzag);
         }
      }
   }
   if (alertsOn)
   {
      int whichBar = 1;
      if (alertsOnCurrent)
         whichBar = 0;
      if (leg[whichBar] != leg[whichBar + 1])
      {
         if (leg[whichBar] > 1)
            doAlert(" leg up ");
         if (leg[whichBar] < 1)
            doAlert(" leg down ");
      }
   }
   return (0);
}
//+------------------------------------------------------------------
void cleanUppeak(int i)
{
   for (int k = i + 1; k < Bars && peakDn[k] == EMPTY_VALUE; k++)
      if (peakUp[k] != EMPTY_VALUE)
      {
         peakUp[k] = EMPTY_VALUE;
         break;
      }
}
void cleanDnpeak(int i)
{
   for (int k = i + 1; k < Bars && peakUp[k] == EMPTY_VALUE; k++)
      if (peakDn[k] != EMPTY_VALUE)
      {
         peakDn[k] = EMPTY_VALUE;
         break;
      }
}
//+------------------------------------------------------------------
void CleanPoint(int i, double &first[], double &second[])
{
   if (i >= Bars - 3)
      return;
   if ((second[i] != EMPTY_VALUE) && (second[i + 1] != EMPTY_VALUE))
      second[i + 1] = EMPTY_VALUE;
   else if ((first[i] != EMPTY_VALUE) && (first[i + 1] != EMPTY_VALUE) && (first[i + 2] == EMPTY_VALUE))
      first[i + 1] = EMPTY_VALUE;
}
//+------------------------------------------------------------------
void PlotPoint(int i, double &first[], double &second[], double &from[])
{
   if (i >= Bars - 2)
      return;
   if (first[i + 1] == EMPTY_VALUE)
      if (first[i + 2] == EMPTY_VALUE)
      {
         first[i] = from[i];
         first[i + 1] = from[i + 1];
         second[i] = EMPTY_VALUE;
      }
      else
      {
         second[i] = from[i];
         second[i + 1] = from[i + 1];
         first[i] = EMPTY_VALUE;
      }
   else
   {
      first[i] = from[i];
      second[i] = EMPTY_VALUE;
   }
}
//+------------------------------------------------------------------
string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

string TimeframeToString(int tf)
{
   for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if (tf == iTfTable[i])
         return (sTfTable[i]);
   return ("");
}
//+------------------------------------------------------------------
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

      message = TimeframeToString(_Period) + " " + _Symbol + " at " + TimeToStr(TimeLocal(), TIME_SECONDS) + " High - low trend " + doWhat;
      if (alertsMessage)
         Alert(message);
      if (alertsNotify)
         SendNotification(message);
      if (alertsEmail)
         SendMail(_Symbol + " High - low trend ", message);
      if (alertsSound)
         PlaySound(soundFile);
   }
}
//+------------------------------------------------------------------
