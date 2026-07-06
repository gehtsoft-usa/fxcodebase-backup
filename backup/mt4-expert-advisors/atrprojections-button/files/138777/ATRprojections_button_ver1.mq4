
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70458
//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window

input int ATRperiod = 7;
input double ATRupperLevel = 70.0;
input double ATRlowerLevel = 50.0;

input double ATRmultiplier1 = 1.5; //period multiplier to use
input double ATRmultiplier2 = 2.5; //period multiplier to use

input color Level1 = clrDarkGreen;
input color Level2 = clrDarkGray;
input int magicNumber = 13882323;
input int tempNumber01 = 0;
input int ATRwidth = 2;
input int BarsLength = 10;
//template code start1
input string button_note1 = "------------------------------";
input ENUM_BASE_CORNER btn_corner = CORNER_RIGHT_UPPER; // chart btn_corner for anchoring
input string btn_text = "ATR";
input string btn_Font = "Arial";
input int btn_FontSize = 10; //btn__font size
input color btn_text_ON_color = clrWhite;
input color btn_text_OFF_color = clrRed;
input color btn_background_color = clrDimGray;
input color btn_border_color = clrBlack;
input int button_x = 85;   //btn__x
input int button_y = 290;  //btn__y
input int btn_Width = 75;  //btn__width
input int btn_Height = 20; //btn__height
input string button_note2 = "------------------------------";

bool show_data = true;
string IndicatorName, IndicatorObjPrefix;
//template code end1

//+------------------------------------------------------------------------------------------------------------------+
string GenerateIndicatorName(const string target) //don't change anything here
{
   string name = target;
   int
   try
      = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try ++);
   }
   return name;
}
//+------------------------------------------------------------------------------------------------------------------+
string buttonId;

int OnInit()
{
   IndicatorName = GenerateIndicatorName(btn_text);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);

   double val;
   if (GlobalVariableGet(IndicatorName + "_visibility", val))
      show_data = val != 0;

   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix + "ATRprojections2020";
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_XDISTANCE, button_x);

   // put init() here

   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------------------------------------------------------+
//don't change anything here
void createButton(string buttonID, string buttonText, int width, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
{
   ObjectDelete(ChartID(), buttonID);
   ObjectCreate(ChartID(), buttonID, OBJ_BUTTON, 0, 0, 0);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_COLOR, txtColor);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_BGCOLOR, bgColor);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_BORDER_COLOR, borderColor);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_XSIZE, width);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_YSIZE, height);
   ObjectSetString(ChartID(), buttonID, OBJPROP_FONT, font);
   ObjectSetString(ChartID(), buttonID, OBJPROP_TEXT, buttonText);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_SELECTABLE, 0);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_CORNER, btn_corner);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_HIDDEN, 1);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_XDISTANCE, 9999);
   ObjectSetInteger(ChartID(), buttonID, OBJPROP_YDISTANCE, 9999);
}
//+------------------------------------------------------------------------------------------------------------------+
int deinit2()
{
   string lookFor, objectName;
   int i, lookForLength;
   lookFor = "high";
   lookForLength = StringLen(lookFor);
   for (i = ObjectsTotal() - 1; i >= 0; i--)
   {
      objectName = ObjectName(i);
      if (StringSubstr(objectName, 0, lookForLength) == lookFor)
         ObjectDelete(objectName);
   }
   lookFor = "low";
   lookForLength = StringLen(lookFor);
   for (i = ObjectsTotal() - 1; i >= 0; i--)
   {
      objectName = ObjectName(i);
      if (StringSubstr(objectName, 0, lookForLength) == lookFor)
         ObjectDelete(objectName);
   }
   Comment("");
   return (0);
}
//+------------------------------------------------------------------------------------------------------------------+
int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   deinit2();
   return (0);
}
//+------------------------------------------------------------------------------------------------------------------+
//don't change anything here
bool recalc = true;

void handleButtonClicks()
{
   if (ObjectGetInteger(ChartID(), buttonId, OBJPROP_STATE))
   {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_STATE, false);
      show_data = !show_data;
      GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
      recalc = true;
      start();
   }
}
//+------------------------------------------------------------------------------------------------------------------+
void OnChartEvent(const int id, //don't change anything here
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   handleButtonClicks();
}
//+------------------------------------------------------------------------------------------------------------------+
int start()
{
   handleButtonClicks();
   recalc = false;
   //put start () here
   double tempArray01[2][6];
   double ATRnumber1 = iATR(NULL, NULL, ATRperiod, 0) * ATRmultiplier1;
   double ATRnumber2 = iATR(NULL, NULL, ATRperiod, 0) * ATRmultiplier2;

   double AskBid01 = Ask - Bid;
   double tempNumber011 = 0;
   double tempNumber02 = 0;
   double CloseOfPrice = Close[0];

   double tempNumber03 = 0;
   double tempNumber04 = 0;
   double tempNumber05 = 0;
   double tempNumber06 = 0;

   double MarketInfo01 = MarketInfo(Symbol(), MODE_TICKVALUE);
   double LowOfPrice = iLow(NULL, NULL, 0) + ATRnumber2;
   double HighOfPrice = iHigh(NULL, NULL, 0) - ATRnumber2;

   if (ATRnumber2 < 0.1)
      tempNumber011 = 10000.0 * ATRnumber2;
   else
      tempNumber011 = 100.0 * ATRnumber2;

   if (AskBid01 < 0.1)
      tempNumber02 = 10000.0 * AskBid01;
   else
      tempNumber02 = 100.0 * AskBid01;

   if (tempNumber02 > 99.0)
      tempNumber02 /= 100.0;
   else
      tempNumber02 = tempNumber02;

   ArrayCopyRates(tempArray01, Symbol(), NULL);
   tempNumber05 = tempArray01[0][3];
   tempNumber06 = tempArray01[0][2];
   tempNumber04 = tempNumber05 - tempNumber06;

   if (tempNumber04 < 0.1)
      tempNumber03 = 10000.0 * tempNumber04;
   else
      tempNumber03 = 100.0 * tempNumber04;

   if (iLow(NULL, NULL, 0) < 10.0)
      Comment("Today = ", tempNumber03, "   |   ATR = ", NormalizeDouble(tempNumber011, 0), "   |   ATR Projection Up = ", NormalizeDouble(LowOfPrice, 4), "   |   ATR Projection Down = ", NormalizeDouble(HighOfPrice, 4));
   else
      Comment("Today = ", tempNumber03, "   |   ATR = ", NormalizeDouble(tempNumber011, 0), "   |   ATR Projection Up = ", NormalizeDouble(LowOfPrice, 2), "   |   ATR Projection Down = ", NormalizeDouble(HighOfPrice, 2));

   double ATRnumber05 = ATRnumber1 / 2.0;
   double tempPriceLow = LowOfPrice;

   tempPriceLow = NormalizeDouble(tempPriceLow, Digits);
   double ATRcalculated01 = 0.8 * (LowOfPrice - iLow(NULL, NULL, 0)) + iLow(NULL, NULL, 0);

   ATRcalculated01 = NormalizeDouble(ATRcalculated01, Digits);
   double tempPriceHigh01 = HighOfPrice;

   tempPriceHigh01 = NormalizeDouble(tempPriceHigh01, Digits);
   double HighOfPrice10 = iHigh(NULL, NULL, 0) - 0.8 * (LowOfPrice - iLow(NULL, NULL, 0));
   HighOfPrice10 = NormalizeDouble(HighOfPrice10, Digits);

   DrawLevel("high1", tempPriceLow, tempNumber01, Level1);
   DrawLevel("high2", ATRcalculated01, tempNumber01, Level2);
   DrawLevel("low1", tempPriceHigh01, tempNumber01, Level1);
   DrawLevel("low2", HighOfPrice10, tempNumber01, Level2);
   if (show_data)
   {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_COLOR, btn_text_ON_color);
      DrawLevel("high1", tempPriceLow, tempNumber01, Level1);
      DrawLevel("high2", ATRcalculated01, tempNumber01, Level2);
      DrawLevel("low1", tempPriceHigh01, tempNumber01, Level1);
      DrawLevel("low2", HighOfPrice10, tempNumber01, Level2);
      DrawLabel("high1lbl", "(" + IntegerToString(ATRperiod) + "p, " + DoubleToString(ATRmultiplier2, 1) + "x)", tempPriceLow, Level1);
      DrawLabel("high2lbl", "(" + IntegerToString(ATRperiod) + "p, " + DoubleToString(ATRmultiplier1, 1) + "x)", ATRcalculated01, Level2);
      DrawLabel("low1lbl", "(" + IntegerToString(ATRperiod) + "p, " + DoubleToString(ATRmultiplier2, 1) + "x)", tempPriceHigh01, Level1);
      DrawLabel("low2lbl", "(" + IntegerToString(ATRperiod) + "p, " + DoubleToString(ATRmultiplier1, 1) + "x)", HighOfPrice10, Level2);
   }
   else
   {
      ObjectSetInteger(ChartID(), buttonId, OBJPROP_COLOR, btn_text_OFF_color);
      deinit2();
      ObjectDelete(IndicatorObjPrefix + "high1lbl");
      ObjectDelete(IndicatorObjPrefix + "high2lbl");
      ObjectDelete(IndicatorObjPrefix + "low1lbl");
      ObjectDelete(IndicatorObjPrefix + "low2lbl");
   }
   return (0);
}

void DrawLabel(string lid, string text, double level, color textColor)
{
   ResetLastError();
   string id = IndicatorObjPrefix + lid;
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TEXT, 0, Time[0], level))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetString(0, id, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, id, OBJPROP_COLOR, textColor);
      ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   }
   ObjectSetInteger(0, id, OBJPROP_TIME, Time[0]);
   ObjectSetDouble(0, id, OBJPROP_PRICE1, level);
   ObjectSetString(0, id, OBJPROP_TEXT, text);
}

//+------------------------------------------------------------------------------------------------------------------+
void DrawLevel(string tempstring, double tempdouble1, int tempStyle01, color tempColor)
{
   int tempTime01 = Time[0]+_Period * 60 * 10; 
   if(BarsLength == 0) tempTime01 = Time[iBarShift(NULL, 0, StrToTime(Year() + "." + Month() + "." + Day() + " " + 0 + ":" + 0))];
   int tempDatetime01 = Time[0];
   if (tempdouble1 > 0.0)
   {
      if (ObjectFind(tempstring) != 0)
      {
         ObjectCreate(tempstring, OBJ_TREND, 0, tempTime01, tempdouble1, tempDatetime01, tempdouble1);
         ObjectSet(tempstring, OBJPROP_RAY, FALSE);
         ObjectSet(tempstring, OBJPROP_COLOR, tempColor);
         ObjectSet(tempstring, OBJPROP_WIDTH, ATRwidth);
         ObjectSet(tempstring, OBJPROP_STYLE, tempStyle01);
         return;
      }
      ObjectSet(tempstring, OBJPROP_RAY, FALSE);
      ObjectMove(tempstring, 0, tempTime01, tempdouble1);
      ObjectMove(tempstring, 1, tempDatetime01, tempdouble1);
      ObjectSet(tempstring, OBJPROP_COLOR, tempColor);
      ObjectSet(tempstring, OBJPROP_WIDTH, ATRwidth);
      ObjectSet(tempstring, OBJPROP_STYLE, tempStyle01);
      return;
   }
   if (ObjectFind(tempstring) >= 0)
      ObjectDelete(tempstring);
}
//+------------------------------------------------------------------------------------------------------------------+
