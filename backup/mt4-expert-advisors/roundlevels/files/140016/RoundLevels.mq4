// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70774

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
#property version   "1.1"
 
#property strict
#property description "Generates round level zone background shading on chart."

#property indicator_chart_window 
#property indicator_plots 0

input int Levels = 5; // Levels - number of level zones in each direction.
input int Interval = 50; // Interval between zones in points.
input int ZoneWidth = 10; // Zone width in points.
input color ColorUp = clrFireBrick;
input color ColorDn = clrDarkGreen;
input bool InvertZones = false; // Invert zones to shade the areas between round numbers.
input bool DrawLines = false; // Draw lines on levels.
input color LineColor = clrDarkGray;
input int LineWidth = 1;
input ENUM_LINE_STYLE LineStyle = STYLE_DASHDOT;
input string ObjectPrefix = "RoundLevels";

input int button_x = 20;
input int button_y = 30;

//Visibility controller v1.3
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
VisibilityCotroller visibility;

enum direction
{
   Up,
   Down
};

int OnInit()
{
   visibility.Init("rl" + ObjectPrefix, "rl" + ObjectPrefix, "Show/Hide", button_x, button_y);
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   visibility.DeInit();
	ObjectsDeleteAll(0, ObjectPrefix);
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
   {
      DoLogic();
   }
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   DoLogic();

   return(0);
}

void DoLogic()
{
   double starting_price = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID), _Digits);
   
   visibility.HandleButtonClicks();

   if (visibility.IsRecalcNeeded())
   {
      if (visibility.IsVisible())
      {
      }
      else
      {
	      ObjectsDeleteAll(0, ObjectPrefix);
      }
      visibility.ResetRecalc();
   }
   if (!visibility.IsVisible())
   {
      return;
   }
   
   for (int i = 0; i < Levels; i++)
   {
      // Calculate price levels below and above the current price.
      double lvl_down = FindNextLevel(NormalizeDouble(starting_price - i * Interval * _Point, _Digits), Down);
      double lvl_up = FindNextLevel(NormalizeDouble(starting_price + i * Interval * _Point, _Digits), Up);
      // Calculate and draw rectangle below current price.
      string name = ObjectPrefix + "D" + IntegerToString(i);
      double price1, price2;
      if (InvertZones)
      {
         price1 = lvl_down - (ZoneWidth / 2 * _Point);
         price2 = lvl_down - ((Interval - ZoneWidth / 2) * _Point);
      }
      else
      {
         price1 = lvl_down + (ZoneWidth / 2 * _Point);
         price2 = lvl_down - (ZoneWidth / 2 * _Point);
      }
      DrawRectangle(name, price1, price2, ColorDn);
      name = ObjectPrefix + "LD" + IntegerToString(i);
      if (DrawLines) DrawLine(name, lvl_down);

      // Calculate and draw rectangle above current price.
      name = ObjectPrefix + "U" + IntegerToString(i);
      if (InvertZones)
      {
         price1 = lvl_up + ((Interval - ZoneWidth / 2) * _Point);
         price2 = lvl_up + (ZoneWidth / 2 * _Point);
      }
      else
      {
         price1 = lvl_up + (ZoneWidth / 2 * _Point);
         price2 = lvl_up - (ZoneWidth / 2 * _Point);
      }         
      DrawRectangle(name, price1, price2, ColorUp);
      name = ObjectPrefix + "LU" + IntegerToString(i);
      if (DrawLines) DrawLine(name, lvl_up);
   }
   
   // Center level required for inverted zones.
   if (InvertZones)
   {
      double lvl_down = FindNextLevel(NormalizeDouble(starting_price, _Digits), Down);
      double lvl_up = FindNextLevel(NormalizeDouble(starting_price, _Digits), Up);
      string name = ObjectPrefix + "C";
      double price1 = lvl_up - (ZoneWidth / 2 * _Point);
      double price2 = lvl_down + (ZoneWidth / 2 * _Point);
      DrawRectangle(name, price1, price2, (ColorDn + ColorUp) / 2);
   }
}

double FindNextLevel(const double sp, const direction dir)
{
   // Multiplier for getting number of points in the price.
   double multiplier = MathPow(10, _Digits);
   // Integer price (nubmer of points in the price).
   int integer_price = (int)MathRound(sp * MathPow(10, _Digits));
   // Distance from the next round number down.
   int distance = integer_price % Interval;
   if (dir == Down)
   {
      return(NormalizeDouble(MathRound(integer_price - distance) / multiplier, _Digits));
   }
   else if (dir == Up)
   {
      return(NormalizeDouble((integer_price + (Interval - distance)) / multiplier, _Digits));
   }
   return(EMPTY_VALUE);
}

void DrawRectangle(const string name, const double price1, const double price2, const color colour)
{
   if (ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_RECTANGLE, 0, 0, 0);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, price1);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 1, price2);
   ObjectSetInteger(0, name, OBJPROP_TIME, 0, D'1970.01.01');
   ObjectSetInteger(0, name, OBJPROP_TIME, 1, D'3000.12.31');
   ObjectSetInteger(0, name, OBJPROP_COLOR, colour);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
}

void DrawLine(const string name, const double price)
{
   if (ObjectFind(0, name) < 0) ObjectCreate(0, name, OBJ_HLINE, 0, 0, 0);
   ObjectSetDouble(0, name, OBJPROP_PRICE, 0, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, LineColor);
   ObjectSetInteger(0, name, OBJPROP_STYLE, LineStyle);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, LineWidth);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
}
//+------------------------------------------------------------------+