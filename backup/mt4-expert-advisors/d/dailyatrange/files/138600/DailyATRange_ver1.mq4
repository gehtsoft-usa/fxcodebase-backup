// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69204

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
#property indicator_buffers 0

input int days = 14; // Days
input double level1 = 100; // Level 1, %
input color lines_color_1 = Red; // Level 1 color
input double level2 = 50; // Level 2, %
input color lines_color_2 = Green; // Level 2 color
input double level3 = 150; // Level 3, %
input color lines_color_3 = Yellow; // Level 3 color
input int button_x = 20;
input int button_y = 30;

string IndicatorName;
string IndicatorObjPrefix;

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
   void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
   {
      ObjectDelete(0,buttonID);
      ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString(0,buttonID,OBJPROP_FONT,font);
      ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,2);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
   }
};

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

VisibilityCotroller visibility;

int init()
{
   visibility.Init("dailyatr", "dailyatr", "Show/Hide", button_x, button_y);

   IndicatorName = GenerateIndicatorName("DailyATRange");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(1);

   return 0;
}

int deinit()
{
   visibility.DeInit();
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
   {
      ChartRedraw();
   }
}

void DrawLines(datetime openTime, datetime closeTime, double atrValue, double open, int index, color clr)
{
   ResetLastError();
   string id = IndicatorObjPrefix + TimeToString(openTime) + "highValue" + IntegerToString(index);
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TREND, 0, openTime, open + atrValue, closeTime, open + atrValue))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE1, open + atrValue);
   ObjectSetDouble(0, id, OBJPROP_PRICE2, open + atrValue);

   ResetLastError();
   id = IndicatorObjPrefix + TimeToString(openTime) + "lowValue" + IntegerToString(index);
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TREND, 0, openTime, open - atrValue, closeTime, open - atrValue))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE1, open - atrValue);
   ObjectSetDouble(0, id, OBJPROP_PRICE2, open - atrValue);
}

int start()
{
   visibility.HandleButtonClicks();
   int counted_bars = IndicatorCounted();
   if (visibility.IsRecalcNeeded())
   {
      if (visibility.IsVisible())
      {
         counted_bars = 0;
      }
      else
      {
         ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
      }
      visibility.ResetRecalc();
   }
   if (!visibility.IsVisible())
   {
      return 0;
   }

   int limit = Bars - counted_bars - 1;
   for (int i = limit; i >= 0; i--)
   {
      int index = iBarShift(_Symbol, PERIOD_D1, Time[i]);
      if (index < 0)
      {
         continue;
      }
      double atrValue = iATR(_Symbol, PERIOD_D1, days, index);
      double open = iOpen(_Symbol, PERIOD_D1, index);
      datetime openTime = iTime(_Symbol, PERIOD_D1, index);
      datetime closeTime = openTime + 86400;
      DrawLines(openTime, closeTime, atrValue * level1 / 100, open, 1, lines_color_1);
      DrawLines(openTime, closeTime, atrValue * level2 / 100, open, 2, lines_color_2);
      DrawLines(openTime, closeTime, atrValue * level3 / 100, open, 3, lines_color_3);
   }
   return 0;
}
