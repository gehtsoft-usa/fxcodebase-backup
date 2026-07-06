// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70257

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
#property strict

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red
//---- indicator parameters
input int InpDepth = 12;    // Depth
input int InpDeviation = 5; // Deviation
input int InpBackstep = 3;  // Backstep

input color ExtLTColor = clrRed;
input ENUM_LINE_STYLE ExtLTChannelsStyle = 0;
input int ExtLTChannelsWidth = 2;
input color ExtLCColor = clrSlateGray;
input ENUM_LINE_STYLE ExtLCChannelsStyle = 0;
input int ExtLCChannelsWidth = 2;

input int ExtSet = 0;

input int button_x = 20;
input int button_y = 30;

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

VisibilityCotroller visibility;

//---- indicator buffers
double ExtZigzagBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];

double lBar, hBar;
datetime tiZZ;
//--- globals
int ExtLevel = 3; // recounting's depth of extremums
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   visibility.Init("show_hide_zzwc", "zzwc", "Show/Hide", button_x, button_y);
   if (InpBackstep >= InpDepth)
   {
      Print("Backstep cannot be greater or equal to Depth");
      return (INIT_FAILED);
   }
   //--- 2 additional buffers
   IndicatorBuffers(3);
   //---- drawing settings
   SetIndexStyle(0, DRAW_SECTION);
   //---- indicator buffers
   SetIndexBuffer(0, ExtZigzagBuffer);
   SetIndexBuffer(1, ExtHighBuffer);
   SetIndexBuffer(2, ExtLowBuffer);
   SetIndexEmptyValue(0, 0.0);
   //---- indicator short name
   IndicatorShortName("ZigZag(" + string(InpDepth) + "," + string(InpDeviation) + "," + string(InpBackstep) + ")");
   //---- initialization done

   lBar = -1;
   hBar = -1;
   tiZZ = -1;
   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{
   visibility.DeInit();
   delete_objects_channels();
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
   visibility.HandleButtonClicks();
   bool recalc = false;
   if (visibility.IsRecalcNeeded())
   {
      if (visibility.IsVisible())
      {
         recalc = true;
      }
      else
      {
         ArrayInitialize(ExtZigzagBuffer, EMPTY_VALUE);
         ArrayInitialize(ExtLowBuffer, EMPTY_VALUE);
         ArrayInitialize(ExtHighBuffer, EMPTY_VALUE);
         lBar = 0;
         hBar = 0;
         tiZZ = 0;
         delete_objects_channels();
         visibility.ResetRecalc();
         return 0;
      }
      visibility.ResetRecalc();
   }
   else if (!visibility.IsVisible())
   {
      return 0;
   }

   int i, limit, counterZ, whatlookfor = 0;
   int back, pos, lasthighpos = 0, lastlowpos = 0;
   double extremum;
   double curlow = 0.0, curhigh = 0.0, lasthigh = 0.0, lastlow = 0.0;
   //--- check for history and inputs
   if (rates_total < InpDepth || InpBackstep >= InpDepth)
      return (0);
   //--- first calculations
   if (prev_calculated == 0 || recalc)
      limit = InitializeAll();
   else
   {
      //--- find first extremum in the depth ExtLevel or 100 last bars
      i = counterZ = 0;
      while (counterZ < ExtLevel && i < 100)
      {
         if (ExtZigzagBuffer[i] != 0.0)
            counterZ++;
         i++;
      }
      //--- no extremum found - recounting all from begin
      if (counterZ == 0)
         limit = InitializeAll();
      else
      {
         //--- set start position to found extremum position
         limit = i - 1;
         //--- what kind of extremum?
         if (ExtLowBuffer[i] != 0.0)
         {
            //--- low extremum
            curlow = ExtLowBuffer[i];
            //--- will look for the next high extremum
            whatlookfor = 1;
         }
         else
         {
            //--- high extremum
            curhigh = ExtHighBuffer[i];
            //--- will look for the next low extremum
            whatlookfor = -1;
         }
         //--- clear the rest data
         for (i = limit - 1; i >= 0; i--)
         {
            ExtZigzagBuffer[i] = 0.0;
            ExtLowBuffer[i] = 0.0;
            ExtHighBuffer[i] = 0.0;
         }
      }
   }
   //--- main loop
   for (i = limit; i >= 0; i--)
   {
      //--- find lowest low in depth of bars
      extremum = low[iLowest(NULL, 0, MODE_LOW, InpDepth, i)];
      //--- this lowest has been found previously
      if (extremum == lastlow)
         extremum = 0.0;
      else
      {
         //--- new last low
         lastlow = extremum;
         //--- discard extremum if current low is too high
         if (low[i] - extremum > InpDeviation * Point)
            extremum = 0.0;
         else
         {
            //--- clear previous extremums in backstep bars
            for (back = 1; back <= InpBackstep; back++)
            {
               pos = i + back;
               if (ExtLowBuffer[pos] != 0 && ExtLowBuffer[pos] > extremum)
                  ExtLowBuffer[pos] = 0.0;
            }
         }
      }
      //--- found extremum is current low
      if (low[i] == extremum)
         ExtLowBuffer[i] = extremum;
      else
         ExtLowBuffer[i] = 0.0;
      //--- find highest high in depth of bars
      extremum = high[iHighest(NULL, 0, MODE_HIGH, InpDepth, i)];
      //--- this highest has been found previously
      if (extremum == lasthigh)
         extremum = 0.0;
      else
      {
         //--- new last high
         lasthigh = extremum;
         //--- discard extremum if current high is too low
         if (extremum - high[i] > InpDeviation * Point)
            extremum = 0.0;
         else
         {
            //--- clear previous extremums in backstep bars
            for (back = 1; back <= InpBackstep; back++)
            {
               pos = i + back;
               if (ExtHighBuffer[pos] != 0 && ExtHighBuffer[pos] < extremum)
                  ExtHighBuffer[pos] = 0.0;
            }
         }
      }
      //--- found extremum is current high
      if (high[i] == extremum)
         ExtHighBuffer[i] = extremum;
      else
         ExtHighBuffer[i] = 0.0;
   }
   //--- final cutting
   if (whatlookfor == 0)
   {
      lastlow = 0.0;
      lasthigh = 0.0;
   }
   else
   {
      lastlow = curlow;
      lasthigh = curhigh;
   }
   for (i = limit; i >= 0; i--)
   {
      switch (whatlookfor)
      {
      case 0: // look for peak or lawn
         if (lastlow == 0.0 && lasthigh == 0.0)
         {
            if (ExtHighBuffer[i] != 0.0)
            {
               lasthigh = High[i];
               lasthighpos = i;
               whatlookfor = -1;
               ExtZigzagBuffer[i] = lasthigh;
            }
            if (ExtLowBuffer[i] != 0.0)
            {
               lastlow = Low[i];
               lastlowpos = i;
               whatlookfor = 1;
               ExtZigzagBuffer[i] = lastlow;
            }
         }
         break;
      case 1: // look for peak
         if (ExtLowBuffer[i] != 0.0 && ExtLowBuffer[i] < lastlow && ExtHighBuffer[i] == 0.0)
         {
            ExtZigzagBuffer[lastlowpos] = 0.0;
            lastlowpos = i;
            lastlow = ExtLowBuffer[i];
            ExtZigzagBuffer[i] = lastlow;
         }
         if (ExtHighBuffer[i] != 0.0 && ExtLowBuffer[i] == 0.0)
         {
            lasthigh = ExtHighBuffer[i];
            lasthighpos = i;
            ExtZigzagBuffer[i] = lasthigh;
            whatlookfor = -1;
         }
         break;
      case -1: // look for lawn
         if (ExtHighBuffer[i] != 0.0 && ExtHighBuffer[i] > lasthigh && ExtLowBuffer[i] == 0.0)
         {
            ExtZigzagBuffer[lasthighpos] = 0.0;
            lasthighpos = i;
            lasthigh = ExtHighBuffer[i];
            ExtZigzagBuffer[i] = lasthigh;
         }
         if (ExtLowBuffer[i] != 0.0 && ExtHighBuffer[i] == 0.0)
         {
            lastlow = ExtLowBuffer[i];
            lastlowpos = i;
            ExtZigzagBuffer[i] = lastlow;
            whatlookfor = 1;
         }
         break;
      }
   }

   if (lBar > iLow(NULL, Period(), 0) || hBar < iHigh(NULL, Period(), 0) || tiZZ != iTime(NULL, Period(), 0))
   {
      visible_channels();
   }
   //--- done
   return (rates_total);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int InitializeAll()
{
   ArrayInitialize(ExtZigzagBuffer, 0.0);
   ArrayInitialize(ExtHighBuffer, 0.0);
   ArrayInitialize(ExtLowBuffer, 0.0);
   //--- first counting position
   return (Bars - InpDepth);
}
//+------------------------------------------------------------------+

void visible_channels()
{
   int n = 0, i = 0, j = 0;
   int peakLeft[3] = {0, 0, 0}, peakRight[3] = {0, 0, 0};
   double sdvigH_tmp = 0, sdvigL_tmp = 0, cenaLTLeft[3] = {0.0, 0.0, 0.0}, cenaLTRight[3] = {0.0, 0.0, 0.0}, cenaLCLeft[3] = {0.0, 0.0, 0.0}, cenaLCRight[3] = {0.0, 0.0, 0.0}, wrcenaL = 0, wrcenaR = 0;
   double cenaGray1 = 0.0, cenaGray2 = 0.0;
   double sdvigH[3] = {0.0, 0.0, 0.0}, sdvigL[3] = {0.0, 0.0, 0.0};
   double _tangens[3] = {0.0, 0.0, 0.0};
   datetime timeLTLeft[3] = {0, 0, 0}, timeLTRight[3] = {0, 0, 0}, timeLCLeft[3] = {0, 0, 0}, timeLCRight[3] = {0, 0, 0}, timeGray1[2] = {0, 0}, timeGray2[2] = {0, 0};
   bool fTrend[3] = {false, false, false}; // =true - Bull проводим трендовую по минимумам, =false - Bear проводим трендовую по максимумам
   string nameObj = "";

   delete_objects_channels();

   datetime t[4] = {0, 0, 0, 0};
   double c[4] = {0.0, 0.0, 0.0, 0.0};
   int point_touch[6] = {0, 0, 0, 0, 0, 0};

   n = 3;
   for (i = 0; i < Bars; i++)
   {
      if (ExtZigzagBuffer[i] != 0.0)
      {
         t[n] = iTime(_Symbol, _Period, i);
         c[n] = ExtZigzagBuffer[i];
         n--;
         if (n < 0)
            break;
      }
   }

   for (i = 0; i < 3; i++)
   {
      peakLeft[i] = iBarShift(_Symbol, _Period, t[i], true);
      peakRight[i] = iBarShift(_Symbol, _Period, t[i + 1], true);
      if (peakLeft[i] < 0)
         return;
      if (peakRight[i] < 0)
         return;
      if (peakLeft[i] - peakRight[i] == 0)
         return;

      _tangens[i] = (c[i + 1] - c[i]) / (peakLeft[i] - peakRight[i]);
      if (c[i] < c[i + 1])
         fTrend[i] = true;
      else
         fTrend[i] = false;

      for (j = peakLeft[i] - 1; j >= peakRight[i]; j--) // вычисляем сдвиги
      {
         sdvigH_tmp = iHigh(_Symbol, _Period, j) - (c[i] + _tangens[i] * (peakLeft[i] - j));
         sdvigL_tmp = c[i] + _tangens[i] * (peakLeft[i] - j) - iLow(_Symbol, _Period, j);
         if (i == 0)
         {
            if (sdvigH_tmp > sdvigH[i])
            {
               point_touch[0] = j;
               sdvigH[i] = sdvigH_tmp;
            }
            if (sdvigL_tmp > sdvigL[i])
            {
               point_touch[1] = j;
               sdvigL[i] = sdvigL_tmp;
            }
         }
         else if (i == 1)
         {
            if (sdvigH_tmp > sdvigH[i])
            {
               point_touch[2] = j;
               sdvigH[i] = sdvigH_tmp;
            }
            if (sdvigL_tmp > sdvigL[i])
            {
               point_touch[3] = j;
               sdvigL[i] = sdvigL_tmp;
            }
         }
         else
         {
            if (sdvigH_tmp > sdvigH[i])
            {
               point_touch[4] = j;
               sdvigH[i] = sdvigH_tmp;
            }
            if (sdvigL_tmp > sdvigL[i])
            {
               point_touch[5] = j;
               sdvigL[i] = sdvigL_tmp;
            }
         }
      }
   }

   // Вычисляем координаты точек привязки линий. Поряток вычислений слева направо.
   // Левая точка привязки первых двух линий. Начало.
   timeLCLeft[0] = t[0];
   timeLTLeft[0] = t[0];
   if (fTrend[0])
   {
      cenaLCLeft[0] = c[0] + sdvigH[0];
      cenaLTLeft[0] = c[0] - sdvigL[0];
   }
   else
   {
      cenaLCLeft[0] = c[0] - sdvigL[0];
      cenaLTLeft[0] = c[0] + sdvigH[0];
   }
   // Левая точка привязки первых двух линий. Конец.
   // Правая точка третьей линии тренда. Начало.
   if (fTrend[2])
   {
      wrcenaR = c[2] - sdvigL[2];
      cenaLTRight[2] = wrcenaR;
      n = peakLeft[2] - peakRight[2];
      while (cenaLTRight[2] < c[3])
      {
         n++; /*if (peakLeft[2]-n<0) break; else*/
         cenaLTRight[2] = wrcenaR + n * _tangens[2];
      }
      timeLCRight[2] = iTime(_Symbol, _Period, peakRight[2] + n);
   }
   else
   {
      wrcenaR = c[2] + sdvigH[2];
      cenaLTRight[2] = wrcenaR;
      n = peakLeft[2] - peakRight[2];
      while (cenaLTRight[2] > c[3])
      {
         n++;
         cenaLTRight[2] = wrcenaR + n * _tangens[2];
      }
   }

   if (peakLeft[2] - n >= 0)
      timeLTRight[2] = iTime(_Symbol, _Period, peakLeft[2] - n);
   else
      timeLTRight[2] = iTime(_Symbol, _Period, 0) + _Period * 60 * (n - peakLeft[2]);
   // Правая точка третьей линии тренда. Конец.
   // Правая точка третьей линии целей. Начало.
   if (fTrend[2])
   {
      wrcenaR = c[2] + sdvigH[2];
      n = peakLeft[2] - point_touch[4];
      cenaLCRight[2] = wrcenaR;
      while (cenaLCRight[2] <= c[3])
      {
         n++;
         cenaLCRight[2] = wrcenaR + n * _tangens[2];
      }
   }
   else
   {
      wrcenaR = c[2] - sdvigL[2];
      n = peakLeft[2] - point_touch[5];
      cenaLCRight[2] = wrcenaR;
      if (wrcenaR + n * _tangens[2] <= c[3])
         cenaLCRight[2] = wrcenaR + n * _tangens[2];
      else
         while (cenaLCRight[2] >= c[3])
         {
            n++;
            cenaLCRight[2] = wrcenaR + n * _tangens[2];
         }
   }

   timeLCRight[2] = iTime(_Symbol, _Period, peakLeft[2] - n);
   if (peakLeft[2] - n >= 0)
      timeLCRight[2] = iTime(_Symbol, _Period, peakLeft[2] - n);
   else
      timeLCRight[2] = iTime(_Symbol, _Period, 0) + _Period * 60 * (n - peakLeft[2]);

   // Правая точка третьей линии целей. Конец.
   // Правая точка первой линии целей и левая точка второй линии тренда. Начало.
   if (fTrend[0]) // Первая линия - тренд вверх
   {
      wrcenaR = c[1] + sdvigH[0];
      wrcenaL = c[1] + sdvigH[1];
      timeLCRight[0] = t[1];
      cenaLCRight[0] = wrcenaR;
      timeLTLeft[1] = t[1];
      cenaLTLeft[1] = wrcenaL;

      if (wrcenaR == wrcenaL)
      {
      }
      else if (wrcenaR > wrcenaL)
      {
         for (i = peakLeft[1] + 1; i < Bars; i++)
         {
            wrcenaR = wrcenaR - _tangens[0];
            wrcenaL = wrcenaL - _tangens[1];
            if (wrcenaR <= wrcenaL)
            {
               timeLTLeft[1] = iTime(_Symbol, _Period, i);
               cenaLTLeft[1] = wrcenaL;
               if (wrcenaR == wrcenaL)
               {
                  timeLCRight[0] = iTime(_Symbol, _Period, i);
                  cenaLCRight[0] = wrcenaR;
               }
               break;
            }
            timeLCRight[0] = iTime(_Symbol, _Period, i);
            cenaLCRight[0] = wrcenaR;
         }
      }
      else //if (wrcenaR<wrcenaL)
      {
         for (i = peakLeft[1] - 1; i > 0; i--)
         {
            wrcenaR = wrcenaR + _tangens[0];
            wrcenaL = wrcenaL + _tangens[1];
            if (wrcenaR >= wrcenaL)
            {
               timeLCRight[0] = iTime(_Symbol, _Period, i);
               cenaLCRight[0] = wrcenaR;
               if (wrcenaR == wrcenaL)
               {
                  timeLTLeft[1] = iTime(_Symbol, _Period, i);
                  cenaLTLeft[1] = wrcenaL;
               }
               break;
            }
            timeLTLeft[1] = iTime(_Symbol, _Period, i);
            cenaLTLeft[1] = wrcenaL;
         }
      }
   }
   else // Первая линия - тренд вниз
   {
      wrcenaR = c[1] - sdvigL[0];
      wrcenaL = c[1] - sdvigL[1];
      timeLCRight[0] = t[1];
      cenaLCRight[0] = wrcenaR;
      timeLTLeft[1] = t[1];
      cenaLTLeft[1] = wrcenaL;

      if (wrcenaR == wrcenaL)
      {
      }
      else if (wrcenaR > wrcenaL)
      {
         for (i = peakLeft[1] - 1; i >= 0; i--)
         {
            wrcenaR = wrcenaR + _tangens[0];
            wrcenaL = wrcenaL + _tangens[1];
            if (wrcenaR <= wrcenaL)
            {
               timeLCRight[0] = iTime(_Symbol, _Period, i);
               cenaLCRight[0] = wrcenaR;
               if (wrcenaR == wrcenaL)
               {
                  timeLTLeft[1] = iTime(_Symbol, _Period, i);
                  cenaLTLeft[1] = wrcenaL;
               }
               break;
            }
            timeLTLeft[1] = iTime(_Symbol, _Period, i);
            cenaLTLeft[1] = wrcenaL;
         }
      }
      else //if (wrcenaR<wrcenaL)
      {
         for (i = peakLeft[1] + 1; i < Bars; i++)
         {
            wrcenaR = wrcenaR - _tangens[0];
            wrcenaL = wrcenaL - _tangens[1];
            if (wrcenaR >= wrcenaL)
            {
               timeLTLeft[1] = iTime(_Symbol, _Period, i);
               cenaLTLeft[1] = wrcenaL;
               if (wrcenaR == wrcenaL)
               {
                  timeLCRight[0] = iTime(_Symbol, _Period, i);
                  cenaLCRight[0] = wrcenaR;
               }
               break;
            }
            timeLCRight[0] = iTime(_Symbol, _Period, i);
            cenaLCRight[0] = wrcenaR;
         }
      }
   }
   // Правая точка первой линии целей и левая точка второй линии тренда. Конец.
   // Цена первой серой линии
   if (fTrend[0])
   {
      if (cenaLTLeft[1] < cenaLCRight[0])
         cenaGray1 = cenaLTLeft[1];
      else
         cenaGray1 = cenaLCRight[0];
   }
   else
   {
      if (cenaLTLeft[1] > cenaLCRight[0])
         cenaGray1 = cenaLTLeft[1];
      else
         cenaGray1 = cenaLCRight[0];
   }
   // Время левой точки первой серой линии
   timeGray1[0] = (timeLTLeft[1] + timeLCRight[0]) / 2;
   // Веремя второй точки первой серой линии. Начало.
   timeGray1[1] = iTime(_Symbol, _Period, 0);
   for (i = peakLeft[1] - 1; i >= 0; i--)
   {
      if (cenaGray1 <= iHigh(_Symbol, _Period, i) && cenaGray1 >= iLow(_Symbol, _Period, i))
      {
         timeGray1[1] = iTime(_Symbol, _Period, i);
         break;
      }
   }
   // Веремя второй точки первой серой линии. Конец.
   // Правая точка второй линии целей и левая точка третьей линии тренда. Начало.
   if (fTrend[1])
   {
      wrcenaR = c[2] + sdvigH[1];
      wrcenaL = c[2] + sdvigH[2];
      timeLCRight[1] = t[2];
      cenaLCRight[1] = wrcenaR;
      timeLTLeft[2] = t[2];
      cenaLTLeft[2] = wrcenaL;

      if (wrcenaR == wrcenaL)
      {
      }
      else if (wrcenaR > wrcenaL)
      {
         for (i = peakLeft[2] + 1; i < Bars; i++)
         {
            wrcenaR = wrcenaR - _tangens[1];
            wrcenaL = wrcenaL - _tangens[2];
            if (wrcenaR <= wrcenaL)
            {
               timeLTLeft[2] = iTime(_Symbol, _Period, i);
               cenaLTLeft[2] = wrcenaL;
               if (wrcenaR == wrcenaL)
               {
                  timeLCRight[1] = iTime(_Symbol, _Period, i);
                  cenaLCRight[1] = wrcenaR;
               }
               break;
            }
            timeLCRight[1] = iTime(_Symbol, _Period, i);
            cenaLCRight[1] = wrcenaR;
         }
      }
      else //if (wrcenaR<wrcenaL)
      {
         for (i = peakLeft[2] - 1; i > 0; i--)
         {
            wrcenaR = wrcenaR + _tangens[1];
            wrcenaL = wrcenaL + _tangens[2];
            if (wrcenaR >= wrcenaL)
            {
               timeLCRight[1] = iTime(_Symbol, _Period, i);
               cenaLCRight[1] = wrcenaR;
               if (wrcenaR == wrcenaL)
               {
                  timeLTLeft[2] = iTime(_Symbol, _Period, i);
                  cenaLTLeft[2] = wrcenaL;
               }
               break;
            }
            timeLTLeft[2] = iTime(_Symbol, _Period, i);
            cenaLTLeft[2] = wrcenaL;
         }
      }
   }
   else
   {
      wrcenaR = c[2] - sdvigL[1];
      wrcenaL = c[2] - sdvigL[2];
      timeLCRight[1] = t[2];
      cenaLCRight[1] = wrcenaR;
      timeLTLeft[2] = t[2];
      cenaLTLeft[2] = wrcenaL;

      if (wrcenaR == wrcenaL)
      {
      }
      else if (wrcenaR > wrcenaL)
      {
         for (i = peakLeft[2] - 1; i > 0; i--)
         {
            wrcenaR = wrcenaR + _tangens[1];
            wrcenaL = wrcenaL + _tangens[2];
            if (wrcenaR <= wrcenaL)
            {
               timeLCRight[1] = iTime(_Symbol, _Period, i);
               cenaLCRight[1] = wrcenaR;
               if (wrcenaR == wrcenaL)
               {
                  timeLTLeft[2] = iTime(_Symbol, _Period, i);
                  cenaLTLeft[2] = wrcenaL;
               }
               break;
            }
            timeLTLeft[2] = iTime(_Symbol, _Period, i);
            cenaLTLeft[2] = wrcenaL;
         }
      }
      else //if (wrcenaR<wrcenaL)
      {
         for (i = peakLeft[2] + 1; i < Bars; i++)
         {
            wrcenaR = wrcenaR - _tangens[1];
            wrcenaL = wrcenaL - _tangens[2];
            if (wrcenaR >= wrcenaL)
            {
               timeLTLeft[2] = iTime(_Symbol, _Period, i);
               cenaLTLeft[2] = wrcenaL;
               if (wrcenaR == wrcenaL)
               {
                  timeLCRight[1] = iTime(_Symbol, _Period, i);
                  cenaLCRight[1] = wrcenaR;
               }
               break;
            }
            timeLCRight[1] = iTime(_Symbol, _Period, i);
            cenaLCRight[1] = wrcenaR;
         }
      }
   }
   // Правая точка второй линии целей и левая точка третьей линии тренда. Конец.
   // Цена второй серой линии
   if (fTrend[1])
   {
      if (cenaLTLeft[2] < cenaLCRight[1])
         cenaGray2 = cenaLTLeft[2];
      else
         cenaGray2 = cenaLCRight[1];
   }
   else
   {
      if (cenaLTLeft[2] > cenaLCRight[1])
         cenaGray2 = cenaLTLeft[2];
      else
         cenaGray2 = cenaLCRight[1];
   }
   // Время левой точки второй серой линии
   timeGray2[0] = (timeLTLeft[2] + timeLCRight[1]) / 2;
   // Веремя второй точки второй серой линии. Начало.
   timeGray2[1] = iTime(_Symbol, _Period, 0);
   for (i = peakLeft[2] - 1; i >= 0; i--)
   {
      if (cenaGray2 <= iHigh(_Symbol, _Period, i) && cenaGray2 >= iLow(_Symbol, _Period, i))
      {
         timeGray2[1] = iTime(_Symbol, _Period, i);
         break;
      }
   }
   // Веремя второй точки второй серой линии. Конец.
   // Пересечение первой и второй линий тренда. Начало.
   if (fTrend[0])
   {
      wrcenaR = c[1] - sdvigL[0];
      wrcenaL = c[1] + sdvigH[1];
      timeLTRight[0] = t[1];
      cenaLTRight[0] = wrcenaR;

      for (i = peakLeft[1] - 1; i >= 0; i--)
      {
         wrcenaR = wrcenaR + _tangens[0];
         wrcenaL = wrcenaL + _tangens[1];
         if (wrcenaR >= wrcenaL)
         {
            timeLTRight[0] = iTime(_Symbol, _Period, i);
            cenaLTRight[0] = wrcenaR;
            break;
         }
      }
   }
   else
   {
      wrcenaR = c[1] + sdvigH[0];
      wrcenaL = c[1] - sdvigL[1];
      timeLTRight[0] = t[1];
      cenaLTRight[0] = wrcenaR;

      for (i = peakLeft[1] - 1; i >= 0; i--)
      {
         wrcenaR = wrcenaR + _tangens[0];
         wrcenaL = wrcenaL + _tangens[1];
         if (wrcenaR <= wrcenaL)
         {
            timeLTRight[0] = iTime(_Symbol, _Period, i);
            cenaLTRight[0] = wrcenaR;
            break;
         }
      }
   }
   // Пересечение первой и второй линий тренда. Конец.
   // Пересечение второй и третьей линий тренда. Начало.
   if (fTrend[1])
   {
      wrcenaR = c[2] - sdvigL[1];
      wrcenaL = c[2] + sdvigH[2];
      timeLTRight[1] = t[2];
      cenaLTRight[1] = wrcenaR;

      for (i = peakLeft[2] - 1; i >= 0; i--)
      {
         wrcenaR = wrcenaR + _tangens[1];
         wrcenaL = wrcenaL + _tangens[2];
         if (wrcenaR >= wrcenaL)
         {
            timeLTRight[1] = iTime(_Symbol, _Period, i);
            cenaLTRight[1] = wrcenaR;
            break;
         }
      }
   }
   else
   {
      wrcenaR = c[2] + sdvigH[1];
      wrcenaL = c[2] - sdvigL[2];
      timeLTRight[1] = t[2];
      cenaLTRight[1] = wrcenaR;

      for (i = peakLeft[2] - 1; i >= 0; i--)
      {
         wrcenaR = wrcenaR + _tangens[1];
         wrcenaL = wrcenaL + _tangens[2];
         if (wrcenaR <= wrcenaL)
         {
            timeLTRight[1] = iTime(_Symbol, _Period, i);
            cenaLTRight[1] = wrcenaR;
            break;
         }
      }
   }
   // Пересечение второй и третьей линий тренда. Конец.
   // Пересечение первой и второй линий целей. Начало.
   if (fTrend[0])
   {
      wrcenaR = c[1] + sdvigH[0];
      wrcenaL = c[1] - sdvigL[1];
      timeLCLeft[1] = t[1];
      cenaLCLeft[1] = wrcenaL;

      for (i = peakLeft[1] + 1; i < Bars; i++)
      {
         wrcenaR = wrcenaR - _tangens[0];
         wrcenaL = wrcenaL - _tangens[1];
         if (wrcenaR <= wrcenaL)
         {
            timeLCLeft[1] = iTime(_Symbol, _Period, i);
            cenaLCLeft[1] = wrcenaL;
            break;
         }
      }
   }
   else
   {
      wrcenaR = c[1] - sdvigL[0];
      wrcenaL = c[1] + sdvigH[1];
      timeLCLeft[1] = t[1];
      cenaLCLeft[1] = wrcenaL;

      for (i = peakLeft[1] + 1; i < Bars; i++)
      {
         wrcenaR = wrcenaR - _tangens[0];
         wrcenaL = wrcenaL - _tangens[1];
         if (wrcenaR >= wrcenaL)
         {
            timeLCLeft[1] = iTime(_Symbol, _Period, i);
            cenaLCLeft[1] = wrcenaL;
            break;
         }
      }
   }
   // Пересечение первой и второй линий целей. Конец.
   // Пересечение второй и третьей линий целей. Начало.
   if (fTrend[1])
   {
      wrcenaR = c[2] + sdvigH[1];
      wrcenaL = c[2] - sdvigL[2];
      timeLCLeft[2] = t[2];
      cenaLCLeft[2] = wrcenaL;

      for (i = peakLeft[2] + 1; i < Bars; i++)
      {
         wrcenaR = wrcenaR - _tangens[1];
         wrcenaL = wrcenaL - _tangens[2];
         if (wrcenaR <= wrcenaL)
         {
            timeLCLeft[2] = iTime(_Symbol, _Period, i);
            cenaLCLeft[2] = wrcenaL;
            break;
         }
      }
   }
   else
   {
      wrcenaR = c[2] - sdvigL[1];
      wrcenaL = c[2] + sdvigH[2];
      timeLCLeft[2] = t[2];
      cenaLCLeft[2] = wrcenaL;
      for (i = peakLeft[2] + 1; i < Bars; i++)
      {
         wrcenaR = wrcenaR - _tangens[1];
         wrcenaL = wrcenaL - _tangens[2];
         if (wrcenaR >= wrcenaL)
         {
            timeLCLeft[2] = iTime(_Symbol, _Period, i);
            cenaLCLeft[2] = wrcenaL;
            break;
         }
      }
   }
   // Пересечение второй и третьей линий целей. Конец.

   nameObj = "LTChannel_0_" + (string)ExtSet + "_";
   ObjectCreate(nameObj, OBJ_TREND, 0, timeLTLeft[0], cenaLTLeft[0], timeLTRight[0], cenaLTRight[0]);
   ObjectSet(nameObj, OBJPROP_RAY, false);
   ObjectSet(nameObj, OBJPROP_COLOR, ExtLTColor);
   ObjectSet(nameObj, OBJPROP_STYLE, ExtLTChannelsStyle);
   ObjectSet(nameObj, OBJPROP_WIDTH, ExtLTChannelsWidth);
   ObjectSetInteger(0, nameObj, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nameObj, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, nameObj, OBJPROP_HIDDEN, true);
   ObjectSetString(0, nameObj, OBJPROP_TOOLTIP, "\n");

   nameObj = "LCChannel_0_" + (string)ExtSet + "_";
   ObjectCreate(nameObj, OBJ_TREND, 0, timeLCLeft[0], cenaLCLeft[0], timeLCRight[0], cenaLCRight[0]);
   ObjectSet(nameObj, OBJPROP_RAY, false);
   ObjectSet(nameObj, OBJPROP_COLOR, ExtLCColor);
   ObjectSet(nameObj, OBJPROP_STYLE, ExtLCChannelsStyle);
   ObjectSet(nameObj, OBJPROP_WIDTH, ExtLCChannelsWidth);
   ObjectSetInteger(0, nameObj, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nameObj, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, nameObj, OBJPROP_HIDDEN, true);
   ObjectSetString(0, nameObj, OBJPROP_TOOLTIP, "\n");

   nameObj = "LTChannel_1_" + (string)ExtSet + "_";
   ObjectCreate(nameObj, OBJ_TREND, 0, timeLTLeft[1], cenaLTLeft[1], timeLTRight[1], cenaLTRight[1]);
   ObjectSet(nameObj, OBJPROP_RAY, false);
   ObjectSet(nameObj, OBJPROP_COLOR, ExtLTColor);
   ObjectSet(nameObj, OBJPROP_STYLE, ExtLTChannelsStyle);
   ObjectSet(nameObj, OBJPROP_WIDTH, ExtLTChannelsWidth);
   ObjectSetInteger(0, nameObj, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nameObj, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, nameObj, OBJPROP_HIDDEN, true);
   ObjectSetString(0, nameObj, OBJPROP_TOOLTIP, "\n");

   nameObj = "LCChannel_1_" + (string)ExtSet + "_";
   ObjectCreate(nameObj, OBJ_TREND, 0, timeLCLeft[1], cenaLCLeft[1], timeLCRight[1], cenaLCRight[1]);
   ObjectSet(nameObj, OBJPROP_RAY, false);
   ObjectSet(nameObj, OBJPROP_COLOR, ExtLCColor);
   ObjectSet(nameObj, OBJPROP_STYLE, ExtLCChannelsStyle);
   ObjectSet(nameObj, OBJPROP_WIDTH, ExtLCChannelsWidth);
   ObjectSetInteger(0, nameObj, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nameObj, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, nameObj, OBJPROP_HIDDEN, true);
   ObjectSetString(0, nameObj, OBJPROP_TOOLTIP, "\n");

   nameObj = "LTChannel_2_" + (string)ExtSet + "_";
   ObjectCreate(nameObj, OBJ_TREND, 0, timeLTLeft[2], cenaLTLeft[2], timeLTRight[2], cenaLTRight[2]);
   ObjectSet(nameObj, OBJPROP_RAY, false);
   ObjectSet(nameObj, OBJPROP_COLOR, ExtLTColor);
   ObjectSet(nameObj, OBJPROP_STYLE, ExtLTChannelsStyle);
   ObjectSet(nameObj, OBJPROP_WIDTH, ExtLTChannelsWidth);
   ObjectSetInteger(0, nameObj, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nameObj, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, nameObj, OBJPROP_HIDDEN, true);
   ObjectSetString(0, nameObj, OBJPROP_TOOLTIP, "\n");

   nameObj = "LCChannel_2_" + (string)ExtSet + "_";
   ObjectCreate(nameObj, OBJ_TREND, 0, timeLCLeft[2], cenaLCLeft[2], timeLCRight[2], cenaLCRight[2]);
   ObjectSet(nameObj, OBJPROP_RAY, false);
   ObjectSet(nameObj, OBJPROP_COLOR, ExtLCColor);
   ObjectSet(nameObj, OBJPROP_STYLE, ExtLCChannelsStyle);
   ObjectSet(nameObj, OBJPROP_WIDTH, ExtLCChannelsWidth);
   ObjectSetInteger(0, nameObj, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, nameObj, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, nameObj, OBJPROP_HIDDEN, true);
   ObjectSetString(0, nameObj, OBJPROP_TOOLTIP, "\n");

   nameObj = "Gray_1_" + (string)ExtSet + "_";
   ObjectCreate(nameObj, OBJ_TREND, 0, timeGray1[0], cenaGray1, timeGray1[1], cenaGray1);
   ObjectSet(nameObj, OBJPROP_RAY, false);
   ObjectSet(nameObj, OBJPROP_COLOR, clrGray);
   ObjectSet(nameObj, OBJPROP_STYLE, 2);
   ObjectSet(nameObj, OBJPROP_WIDTH, 0);
   //   ObjectSetInteger(0,nameObj,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, nameObj, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, nameObj, OBJPROP_HIDDEN, true);
   ObjectSetString(0, nameObj, OBJPROP_TOOLTIP, "\n");

   nameObj = "Gray_2_" + (string)ExtSet + "_";
   ObjectCreate(nameObj, OBJ_TREND, 0, timeGray2[0], cenaGray2, timeGray2[1], cenaGray2);
   ObjectSet(nameObj, OBJPROP_RAY, false);
   ObjectSet(nameObj, OBJPROP_COLOR, clrGray);
   ObjectSet(nameObj, OBJPROP_STYLE, 2);
   ObjectSet(nameObj, OBJPROP_WIDTH, 0);
   //   ObjectSetInteger(0,nameObj,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0, nameObj, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, nameObj, OBJPROP_HIDDEN, true);
   ObjectSetString(0, nameObj, OBJPROP_TOOLTIP, "\n");

   //---
   lBar = iLow(NULL, Period(), 0);
   hBar = iHigh(NULL, Period(), 0);
   tiZZ = iTime(NULL, Period(), 0);
}

//--------------------------------------------------------
// Удаление каналов. Начало.
//--------------------------------------------------------
void delete_objects_channels()
{
   string nameObj = "";

   nameObj = StringConcatenate("LCChannel_0_", ExtSet, "_");
   if (ObjectFind(0, nameObj) == 0)
      ObjectDelete(nameObj);
   nameObj = StringConcatenate("LTChannel_0_", ExtSet, "_");
   if (ObjectFind(0, nameObj) == 0)
      ObjectDelete(nameObj);
   nameObj = StringConcatenate("LCChannel_1_", ExtSet, "_");
   if (ObjectFind(0, nameObj) == 0)
      ObjectDelete(nameObj);
   nameObj = StringConcatenate("LTChannel_1_", ExtSet, "_");
   if (ObjectFind(0, nameObj) == 0)
      ObjectDelete(nameObj);
   nameObj = StringConcatenate("LCChannel_2_", ExtSet, "_");
   if (ObjectFind(0, nameObj) == 0)
      ObjectDelete(nameObj);
   nameObj = StringConcatenate("LTChannel_2_", ExtSet, "_");
   if (ObjectFind(0, nameObj) == 0)
      ObjectDelete(nameObj);

   nameObj = StringConcatenate("Gray_1_", ExtSet, "_");
   if (ObjectFind(0, nameObj) == 0)
      ObjectDelete(nameObj);
   nameObj = StringConcatenate("Gray_2_", ExtSet, "_");
   if (ObjectFind(0, nameObj) == 0)
      ObjectDelete(nameObj);
}
//--------------------------------------------------------
// Удаление каналов. Конец.
//--------------------------------------------------------
