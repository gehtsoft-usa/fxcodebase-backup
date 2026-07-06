// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69787


//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                                Patreon :  https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+


#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property version   "2.00"
#property strict

// Unique ID
#define ID "Panel:fxcodebase"

//+------------------------------------------------------------------+
//| Modification: Ability to place the panel on each corner of the   |
//| chart                                                            |
//|                                                                  |
//| Date: 05/05/2020                                                 |
//+------------------------------------------------------------------+
#define X_OFFSET_RIGHT 60

input int magic = 123456;
input int slippage = 300;
input ENUM_BASE_CORNER InpCorner = 0;        // Corner
input int InpXOffSet = 0;                   // X Off Set
input int InpYOffSet = 40;                  // Y Off Set

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
   CreatePanel();
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//--- remove panel
   RemovePanel();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
//---

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long& lparam,
                  const double& dparam,
                  const string& sparam )
{
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(ObjectGetInteger(ChartID(), "EA BUY SIMPLE", OBJPROP_STATE))
      {
         openSimple(0, 1);
         ObjectSetInteger(ChartID(), "EA BUY SIMPLE", OBJPROP_STATE, false);
      }
      else if(ObjectGetInteger(ChartID(), "EA SELL SIMPLE", OBJPROP_STATE))
      {
         openSimple(1, 1);
         ObjectSetInteger(ChartID(), "EA SELL SIMPLE", OBJPROP_STATE, false);
      }
      else if(ObjectGetInteger(ChartID(), "EA SELL 0", OBJPROP_STATE))
      {
         openSimple(1, 0);
         ObjectSetInteger(ChartID(), "EA SELL 0", OBJPROP_STATE, false);
      }
      else if(ObjectGetInteger(ChartID(), "EA BUY 0", OBJPROP_STATE))
      {
         openSimple(0, 0);
         ObjectSetInteger(ChartID(), "EA BUY 0", OBJPROP_STATE, false);
      }
   }
}
//+------------------------------------------------------------------+
//| Create the panel                                                 |
//+------------------------------------------------------------------+
void CreatePanel()
{
   int rightOffset = InpXOffSet;
   if(InpCorner == CORNER_RIGHT_LOWER || InpCorner == CORNER_RIGHT_UPPER) rightOffset = X_OFFSET_RIGHT + InpXOffSet;

   object("EA RISK EDIT", OBJ_EDIT, 55 + rightOffset, 80 + InpYOffSet, 30, 60, " 1.0");
   object("EA BUY SIMPLE", OBJ_BUTTON, 20 + rightOffset, 120 + InpYOffSet, 30, 60, "BUY", clrWhite, clrGreen);
   object("EA SELL SIMPLE", OBJ_BUTTON, 90 + rightOffset, 120 + InpYOffSet, 30, 60, "SELL", clrWhite, clrRed);
   object("EA BUY 0", OBJ_BUTTON, 20 + rightOffset, 160 + InpYOffSet, 30, 60, "BUY 0", clrWhite, clrGreen);
   object("EA SELL 0", OBJ_BUTTON, 90 + rightOffset, 160 + InpYOffSet, 30, 60, "SELL 0", clrWhite, clrRed);

   // move the chart to back
   ChartSetInteger(0, CHART_FOREGROUND, false);
}
//+------------------------------------------------------------------+
//| Remove the panel                                                 |
//+------------------------------------------------------------------+
void RemovePanel()
{
   ObjectDelete(ChartID(), "EA RISK EDIT");
   ObjectDelete(ChartID(), "EA BUY SIMPLE");
   ObjectDelete(ChartID(), "EA SELL SIMPLE");
   ObjectDelete(ChartID(), "EA BUY 0");
   ObjectDelete(ChartID(), "EA SELL 0");
}
//+------------------------------------------------------------------+
//| Create the object                                                |
//+------------------------------------------------------------------+
void object(string name, ENUM_OBJECT obj, int x, int y, int width, int lengh, string text, color colorText = clrBlack, color back = clrWhite)
{
   // to prevent repeated execution of the code
   long chartId = ChartID();

   ObjectCreate(chartId, name, obj, 0, 0, 0);
   ObjectSetText(name, text, 12, "Arial", colorText);
   ObjectSetInteger(chartId, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chartId, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(chartId, name, OBJPROP_YSIZE, width);
   ObjectSetInteger(chartId, name, OBJPROP_XSIZE, lengh);
   ObjectSetInteger(chartId, name, OBJPROP_BGCOLOR, back);
   ObjectSetInteger(chartId, name, OBJPROP_COLOR, colorText);
   ObjectSetInteger(chartId, name, OBJPROP_CORNER, InpCorner);
   ObjectSetInteger(chartId, name, OBJPROP_BORDER_TYPE, BORDER_SUNKEN);
}
//+------------------------------------------------------------------+
//| Open the Order                                                   |
//+------------------------------------------------------------------+
void openSimple(int type, int mode)
{
   // check if the indicator is attached to the chart
   if(ObjectFind("textSellSL") < 0)
   {
      Alert("Indicator is not properly attached to the chart...");
      return;
   }

   double sl = type ? StringToDouble(StringSubstr(ObjectGetString(ChartID(), "textSellSL", OBJPROP_TEXT), 8)) : StringToDouble(StringSubstr(ObjectGetString(ChartID(), "textBuySL", OBJPROP_TEXT), 7));
   double tp = mode ? (type ? StringToDouble(StringSubstr(ObjectGetString(ChartID(), "textSellTP", OBJPROP_TEXT), 8)) : StringToDouble(StringSubstr(ObjectGetString(ChartID(), "textBuyTP", OBJPROP_TEXT), 7))) : 0;
   double risk = StringToDouble(ObjectGetString(ChartID(), "EA RISK EDIT", OBJPROP_TEXT));
   if(risk > 100 || risk <= 0)
   {
      Alert("check Risk Value!!!");
      return;
   }
   double lot = NormalizeDouble((AccountBalance() * risk / 100) / ((type ? (sl - Bid) : (Ask - sl)) / Point()), 2);
   Print(lot);
   int k = OrderSend(Symbol(), type, lot, type ? Bid : Ask, slippage, sl, tp, "ATR BUY/SELL EA", magic);
}
//+------------------------------------------------------------------+
