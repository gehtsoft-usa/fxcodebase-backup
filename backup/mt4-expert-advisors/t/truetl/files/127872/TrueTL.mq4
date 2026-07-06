// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68781

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

#include <WinUser32.mqh>
#import "user32.dll"
   int RegisterWindowMessageA(string a0);
#import

extern bool Auto_Refresh = TRUE;
extern int Normal_TL_Period = 500;
extern bool Three_Touch = TRUE;
extern bool M1_Fast_Analysis = TRUE;
extern bool M5_Fast_Analysis = TRUE;
extern bool Mark_Highest_and_Lowest_TL = TRUE;
extern int Expiration_Day_Alert = 5;
extern color Normal_TL_Color = Gainsboro;
extern color Long_TL_Color = Goldenrod;
extern int Three_Touch_TL_Widht = 2;
extern color Three_Touch_TL_Color = White;
extern int button_x = 20;
extern int button_y = 30;
int gi_120;
int gi_124;

//Visibility controller v1.0
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
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, x);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, y);
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

VisibilityCotroller _visibility;

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

int init() {
   IndicatorName = GenerateIndicatorName("TrueTL");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   _visibility.Init("_" + IndicatorObjPrefix + "CloseButton", "My indicator", "Show/Hide", button_x, button_y);

   ObjectCreate(IndicatorObjPrefix + "calctl", OBJ_HLINE, 0, 0, 0);
   ObjectCreate(IndicatorObjPrefix + "visibletl", OBJ_HLINE, 0, 0, 0);
   ObjectCreate(IndicatorObjPrefix + "downmax", OBJ_TREND, 0, 0, 0, 0, 0);
   ObjectCreate(IndicatorObjPrefix + "upmax", OBJ_TREND, 0, 0, 0, 0, 0);
   return (0);
}

void Clean()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}

int deinit() {
   ObjectsDeleteAll(ChartID(), "_" + IndicatorObjPrefix);
   Clean();
   return (0);
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (_visibility.HandleButtonClicks())
      start();
}

int start() {
   double ld_20;
   double ld_28;
   double ld_36;
   double ld_44;
   double ld_52;
   double ld_60;
   double ld_68;
   double ld_76;
   double ld_84;
   double ld_100;
   double ld_108;
   double ld_116;
   double ld_124;
   double ld_132;
   double ld_140;
   double ld_148;
   double ld_156;
   double ld_164;
   double ld_172;
   double ld_180;
   double ld_188;
   double ld_232;
   double ld_240;
   int li_248;
   int li_252;
   if (Normal_TL_Period > 1000 || Normal_TL_Period < 100) 
      Normal_TL_Period = 500;
   string ls_0 = AccountNumber();
   gi_124++;
   string ls_8 = AccountNumber();
   int li_16 = 1;

   _visibility.HandleButtonClicks();
   if (!_visibility.IsVisible())
   {
      gi_120 = 0;
      Clean();
      ObjectCreate(IndicatorObjPrefix + "calctl", OBJ_HLINE, 0, 0, 0);
      ObjectCreate(IndicatorObjPrefix + "visibletl", OBJ_HLINE, 0, 0, 0);
      ObjectCreate(IndicatorObjPrefix + "downmax", OBJ_TREND, 0, 0, 0, 0, 0);
      ObjectCreate(IndicatorObjPrefix + "upmax", OBJ_TREND, 0, 0, 0, 0, 0);
      return 0;
   }
   bool refreshed = _visibility.IsRecalcNeeded();
   _visibility.ResetRecalc();

   int li_196 = MathMax(0, WindowFirstVisibleBar() - WindowBarsPerChart());
   double ld_224 = Bars;
   if (gi_120 == 0) 
      gi_120 = ld_224;
   if (ld_224 > gi_120) {
      gi_120 = ld_224;
      if (Auto_Refresh == TRUE && li_196 == 0) 
         ObjectSet(IndicatorObjPrefix + "calctl", OBJPROP_PRICE1, -1);
   }
   if (Auto_Refresh == TRUE && (IndicatorCounted() == 0 || refreshed)) 
      ObjectSet(IndicatorObjPrefix + "calctl", OBJPROP_PRICE1, -1);
   if (ObjectGet(IndicatorObjPrefix + "visibletl", OBJPROP_PRICE1) == -1.0) {
      for (int li_208 = 0; li_208 <= 100; li_208++) {
         ObjectDelete(IndicatorObjPrefix + "downtrendline" + li_208);
         ObjectDelete(IndicatorObjPrefix + "uptrendline" + li_208);
         ObjectDelete(IndicatorObjPrefix + "downtrendline" + li_208 + "tt");
         ObjectDelete(IndicatorObjPrefix + "uptrendline" + li_208 + "tt");
      }
   }
   if (ObjectGet(IndicatorObjPrefix + "calctl", OBJPROP_PRICE1) == -1.0 && ObjectGet("visibletl", OBJPROP_PRICE1) == 0.0 && StringFind(ls_8, ls_0, 0) >= 0 && li_16 > 0) {
      for (int li_208 = 0; li_208 <= 100; li_208++) {
         ObjectDelete(IndicatorObjPrefix + "downtrendline" + li_208);
         ObjectDelete(IndicatorObjPrefix + "uptrendline" + li_208);
         ObjectDelete(IndicatorObjPrefix + "downtrendline" + li_208 + "tt");
         ObjectDelete(IndicatorObjPrefix + "uptrendline" + li_208 + "tt");
      }
      ld_20 = 150000;
      if (Period() == PERIOD_M1 && M1_Fast_Analysis == TRUE) ld_20 = 8000;
      if (Period() == PERIOD_M5 && M5_Fast_Analysis == TRUE) ld_20 = 2400;
      if (Period() == PERIOD_MN1) {
         ld_20 = 150;
         Three_Touch = FALSE;
         Normal_TL_Period = 150;
      }
      ld_28 = li_196 + MathMin(Bars - li_196 - 10, ld_20);
      ld_36 = iHigh(NULL, 0, ld_28);
      ld_52 = li_196 + MathMin(Bars - li_196 - 10, ld_20);
      ld_60 = iHigh(NULL, 0, ld_52);
      for (int li_200 = 1; li_200 < 50; li_200++) {
         if ((iFractals(NULL, 0, MODE_UPPER, li_196 + li_200) > 0.0 && li_200 > 2) || (Close[li_196 + li_200 + 1] > Open[li_196 + li_200 + 1] && Close[li_196 + li_200 + 1] - (Low[li_196 +
            li_200 + 1]) < 0.6 * (High[li_196 + li_200 + 1] - (Low[li_196 + li_200 + 1])) && Close[li_196 + li_200] < Open[li_196 + li_200]) || (Close[li_196 + li_200 + 1] <= Open[li_196 +
            li_200 + 1] && Close[li_196 + li_200] < Open[li_196 + li_200]) || (Close[li_196 + li_200] < Open[li_196 + li_200] && Close[li_196 + li_200] < Low[li_196 + li_200 + 1])) {
            ld_44 = li_196 + li_200;
            break;
         }
      }
      for (int li_204 = 1; li_204 <= 30; li_204++) {
         if (ld_28 > ld_44 + 6.0) {
            ObjectCreate(IndicatorObjPrefix + "downtrendline" + li_204, OBJ_TREND, 0, iTime(NULL, 0, ld_28), ld_36, iTime(NULL, 0, ld_28), ld_36);
            for (int li_200 = ld_28; li_200 >= ld_44; li_200--) {
               if (ObjectGet(IndicatorObjPrefix + "downtrendline" + li_204, OBJPROP_PRICE1) == ObjectGet(IndicatorObjPrefix + "downtrendline" + li_204, OBJPROP_PRICE2)) {
                  ObjectMove(IndicatorObjPrefix + "downtrendline" + li_204, 1, iTime(NULL, 0, li_200 - 1), iHigh(NULL, 0, li_200 - 1));
                  ld_28 = li_200 - 1;
                  ld_36 = iHigh(NULL, 0, li_200 - 1);
               }
               ld_76 = ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + li_204, li_200);
               if (ld_76 < iHigh(NULL, 0, li_200)) {
                  ObjectMove(IndicatorObjPrefix + "downtrendline" + li_204, 1, iTime(NULL, 0, li_200), iHigh(NULL, 0, li_200));
                  ld_28 = li_200;
                  ld_36 = iHigh(NULL, 0, li_200);
               }
            }
         }
         if (ObjectGet(IndicatorObjPrefix + "downtrendline" + li_204, OBJPROP_PRICE1) < ObjectGet(IndicatorObjPrefix + "downtrendline" + li_204, OBJPROP_PRICE2)) ObjectDelete(IndicatorObjPrefix + "downtrendline" + li_204);
         if (iBarShift(NULL, 0, ObjectGet(IndicatorObjPrefix + "downtrendline" + li_204, OBJPROP_TIME1)) - li_196 >= Normal_TL_Period) {
            ObjectSet(IndicatorObjPrefix + "downtrendline" + li_204, OBJPROP_COLOR, Long_TL_Color);
            ObjectSetText(IndicatorObjPrefix + "downtrendline" + li_204, "Long");
         } else {
            ObjectSet(IndicatorObjPrefix + "downtrendline" + li_204, OBJPROP_COLOR, Normal_TL_Color);
            ObjectSetText(IndicatorObjPrefix + "downtrendline" + li_204, "Normal");
         }
      }
      for (int li_200 = 1; li_200 < 50; li_200++) {
         if ((iFractals(NULL, 0, MODE_LOWER, li_196 + li_200) > 0.0 && li_200 > 2) || (Close[li_196 + li_200 + 1] < Open[li_196 + li_200 + 1] && High[li_196 + li_200 + 1] - (Close[li_196 +
            li_200 + 1]) < 0.6 * (High[li_196 + li_200 + 1] - (Low[li_196 + li_200 + 1])) && Close[li_196 + li_200] > Open[li_196 + li_200]) || (Close[li_196 + li_200 + 1] >= Open[li_196 +
            li_200 + 1] && Close[li_196 + li_200] > Open[li_196 + li_200]) || (Close[li_196 + li_200] > Open[li_196 + li_200] && Close[li_196 + li_200] > High[li_196 + li_200 + 1])) {
            ld_68 = li_196 + li_200;
            break;
         }
      }
      for (int li_204 = 1; li_204 <= 30; li_204++) {
         if (ld_52 > ld_68 + 6.0) {
            ObjectCreate(IndicatorObjPrefix + "uptrendline" + li_204, OBJ_TREND, 0, iTime(NULL, 0, ld_52), ld_60, iTime(NULL, 0, ld_52), ld_60);
            for (int li_200 = ld_52; li_200 >= ld_68; li_200--) {
               if (ObjectGet(IndicatorObjPrefix + "uptrendline" + li_204, OBJPROP_TIME1) == ObjectGet(IndicatorObjPrefix + "uptrendline" + li_204, OBJPROP_TIME2)) {
                  ObjectMove(IndicatorObjPrefix + "uptrendline" + li_204, 1, iTime(NULL, 0, li_200 - 1), iLow(NULL, 0, li_200 - 1));
                  ld_52 = li_200 - 1;
                  ld_60 = iLow(NULL, 0, li_200 - 1);
               }
               ld_76 = ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + li_204, li_200);
               if (iLow(NULL, 0, li_200) < ld_76) {
                  ObjectMove(IndicatorObjPrefix + "uptrendline" + li_204, 1, iTime(NULL, 0, li_200), iLow(NULL, 0, li_200));
                  ld_52 = li_200;
                  ld_60 = iLow(NULL, 0, li_200);
               }
            }
         }
         if (ObjectGet(IndicatorObjPrefix + "uptrendline" + li_204, OBJPROP_PRICE1) > ObjectGet(IndicatorObjPrefix + "uptrendline" + li_204, OBJPROP_PRICE2)) ObjectDelete(IndicatorObjPrefix + "uptrendline" + li_204);
         if (iBarShift(NULL, 0, ObjectGet(IndicatorObjPrefix + "uptrendline" + li_204, OBJPROP_TIME1)) - li_196 >= Normal_TL_Period) {
            ObjectSet(IndicatorObjPrefix + "uptrendline" + li_204, OBJPROP_COLOR, Long_TL_Color);
            ObjectSetText(IndicatorObjPrefix + "uptrendline" + li_204, "Long");
         } else {
            ObjectSet(IndicatorObjPrefix + "uptrendline" + li_204, OBJPROP_COLOR, Normal_TL_Color);
            ObjectSetText(IndicatorObjPrefix + "uptrendline" + li_204, "Normal");
         }
      }
      if (Three_Touch == TRUE && Bars > 1000) {
         for (int li_204 = 1; li_204 <= 30; li_204++) {
            ld_100 = ObjectGet(IndicatorObjPrefix + "downtrendline" + li_204, OBJPROP_TIME1);
            ld_108 = iBarShift(NULL, 0, ld_100);
            ld_84 = ld_44;
            ld_116 = ld_108 - ld_84;
            if (ld_116 < MathMin(Normal_TL_Period, 1000) && ld_116 > 6.0) {
               ObjectCreate(IndicatorObjPrefix + "downtrendline" + li_204 + "tt", OBJ_TREND, 0, iTime(NULL, 0, ld_108), iHigh(NULL, 0, ld_108), iTime(NULL, 0, ld_84), iHigh(NULL, 0, ld_84));
               ObjectSet(IndicatorObjPrefix + "downtrendline" + li_204 + "tt", OBJPROP_WIDTH, 2);
               ld_180 = iATR(NULL, 0, ld_116, li_196) / Point / 10.0;
               ld_188 = 8.0 * ld_180;
               ld_124 = 0;
               ld_132 = 0;
               ld_140 = 0;
               for (int li_212 = ld_84; li_212 <= ld_108; li_212++) {
                  if (ld_132 == 0.0 && ld_140 >= 3.0 && li_212 > ld_84) {
                     ld_164 = 0;
                     ld_172 = ObjectGet(IndicatorObjPrefix + "downtrendline" + li_204 + "tt", OBJPROP_PRICE2);
                     for (int li_216 = 1; li_216 <= 5; li_216++) {
                        if (ld_164 >= 3.0) ld_124 = 1;
                        if (ld_124 == 0.0) {
                           ObjectSet(IndicatorObjPrefix + "downtrendline" + li_204 + "tt", OBJPROP_PRICE2, ld_172 + (li_216 - 3) * Point);
                           ld_164 = 0;
                           for (int li_220 = ld_84; li_220 <= ld_108; li_220++) {
                              ld_76 = ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + li_204 + "tt", li_220);
                              if (ld_76 + ld_180 * Point > iHigh(NULL, 0, li_220) && ld_76 - ld_180 * Point < iHigh(NULL, 0, li_220)) {
                                 ld_164++;
                                 li_220++;
                              }
                           }
                        }
                     }
                  }
                  if (ld_124 == 0.0 && li_212 == ld_108) ObjectDelete(IndicatorObjPrefix + "downtrendline" + li_204 + "tt");
                  if (ld_124 == 1.0 && li_212 == ld_108) {
                     ld_148 = ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + li_204, ld_84);
                     ld_156 = ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + li_204 + "tt", ld_84);
                     if (MathAbs(ld_148 - ld_156) > ld_188 * Point) ObjectDelete(IndicatorObjPrefix + "downtrendline" + li_204 + "tt");
                  }
                  if (ld_124 == 0.0 && li_212 <= ld_108) ObjectMove(IndicatorObjPrefix + "downtrendline" + li_204 + "tt", 1, iTime(NULL, 0, li_212), iHigh(NULL, 0, li_212));
                  if (ld_124 == 0.0) {
                     ld_132 = 0;
                     ld_140 = 0;
                     for (int li_200 = ld_84; li_200 <= ld_108; li_200++) {
                        ld_76 = ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + li_204 + "tt", li_200);
                        if (iClose(NULL, 0, li_200) > ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + li_204 + "tt", li_200)) ld_132++;
                        if (ld_76 + 2.0 * ld_180 * Point > iHigh(NULL, 0, li_200) && ld_76 - 2.0 * ld_180 * Point < iHigh(NULL, 0, li_200)) {
                           ld_140++;
                           li_200++;
                        }
                     }
                  }
               }
            }
         }
         for (int li_204 = 1; li_204 <= 30; li_204++) {
            ld_100 = ObjectGet(IndicatorObjPrefix + "uptrendline" + li_204, OBJPROP_TIME1);
            ld_108 = iBarShift(NULL, 0, ld_100);
            ld_84 = ld_68;
            ld_116 = ld_108 - ld_84;
            if (ld_116 < MathMin(Normal_TL_Period, 1000) && ld_116 > 6.0) {
               ObjectCreate(IndicatorObjPrefix + "uptrendline" + li_204 + "tt", OBJ_TREND, 0, iTime(NULL, 0, ld_108), iLow(NULL, 0, ld_108), iTime(NULL, 0, ld_108), iLow(NULL, 0, ld_108));
               ObjectSet(IndicatorObjPrefix + "uptrendline" + li_204 + "tt", OBJPROP_WIDTH, 2);
               ld_180 = iATR(NULL, 0, ld_116, li_196) / Point / 10.0;
               ld_188 = 8.0 * ld_180;
               ld_124 = 0;
               ld_140 = 0;
               for (int li_212 = ld_84; li_212 <= ld_108; li_212++) {
                  if (ld_132 == 0.0 && ld_140 >= 3.0 && li_212 > ld_84 && ld_124 == 0.0) {
                     ld_164 = 0;
                     ld_172 = ObjectGet(IndicatorObjPrefix + "uptrendline" + li_204 + "tt", OBJPROP_PRICE2);
                     for (int li_216 = 1; li_216 <= 5; li_216++) {
                        if (ld_164 >= 3.0) ld_124 = 1;
                        if (ld_124 == 0.0) {
                           ObjectSet(IndicatorObjPrefix + "uptrendline" + li_204 + "tt", OBJPROP_PRICE2, ld_172 + (li_216 - 3) * Point);
                           ld_164 = 0;
                           for (int li_220 = ld_84; li_220 <= ld_108; li_220++) {
                              ld_76 = ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + li_204 + "tt", li_220);
                              if (ld_76 + ld_180 * Point > iLow(NULL, 0, li_220) && ld_76 - ld_180 * Point < iLow(NULL, 0, li_220)) {
                                 ld_164++;
                                 li_220++;
                              }
                           }
                        }
                     }
                  }
                  if (ld_124 == 0.0 && li_212 == ld_108) ObjectDelete(IndicatorObjPrefix + "uptrendline" + li_204 + "tt");
                  if (ld_124 == 1.0 && li_212 == ld_108) {
                     ld_148 = ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + li_204, ld_84);
                     ld_156 = ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + li_204 + "tt", ld_84);
                     if (MathAbs(ld_148 - ld_156) > ld_188 * Point) ObjectDelete(IndicatorObjPrefix + "uptrendline" + li_204 + "tt");
                  }
                  if (ld_124 == 0.0 && li_212 < ld_108) ObjectMove(IndicatorObjPrefix + "uptrendline" + li_204 + "tt", 1, iTime(NULL, 0, li_212), iLow(NULL, 0, li_212));
                  if (ld_124 == 0.0) {
                     ld_132 = 0;
                     ld_140 = 0;
                     for (int li_200 = ld_84; li_200 <= ld_108; li_200++) {
                        ld_76 = ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + li_204 + "tt", li_200);
                        if (iClose(NULL, 0, li_200) < ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + li_204 + "tt", li_200)) ld_132++;
                        if (ld_76 + 2.0 * ld_180 * Point > iLow(NULL, 0, li_200) && ld_76 - 2.0 * ld_180 * Point < iLow(NULL, 0, li_200)) {
                           ld_140++;
                           li_200++;
                        }
                     }
                  }
               }
            }
         }
         for (int li_200 = 0; li_200 <= 30; li_200++) {
            if (ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + li_200 + "tt", li_196 + 1) > 0.0) {
               ObjectSet(IndicatorObjPrefix + "uptrendline" + li_200, OBJPROP_WIDTH, Three_Touch_TL_Widht);
               ObjectSet(IndicatorObjPrefix + "uptrendline" + li_200, OBJPROP_COLOR, Three_Touch_TL_Color);
               ObjectSetText(IndicatorObjPrefix + "uptrendline" + li_200, "3t");
               ObjectDelete(IndicatorObjPrefix + "uptrendline" + li_200 + "tt");
            }
         }
         for (int li_200 = 0; li_200 <= 30; li_200++) {
            if (ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + li_200 + "tt", li_196 + 1) > 0.0) {
               ObjectSet(IndicatorObjPrefix + "downtrendline" + li_200, OBJPROP_WIDTH, Three_Touch_TL_Widht);
               ObjectSet(IndicatorObjPrefix + "downtrendline" + li_200, OBJPROP_COLOR, Three_Touch_TL_Color);
               ObjectSetText(IndicatorObjPrefix + "downtrendline" + li_200, "3t");
               ObjectDelete(IndicatorObjPrefix + "downtrendline" + li_200 + "tt");
            }
         }
      }
      for (int li_204 = 0; li_204 <= 30; li_204++) {
         if (ObjectGet(IndicatorObjPrefix + "downtrendline" + ((li_204 - 1)), OBJPROP_PRICE1) == 0.0 && ObjectGet(IndicatorObjPrefix + "downtrendline" + li_204, OBJPROP_PRICE1) > 0.0 && Mark_Highest_and_Lowest_TL == TRUE) {
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_TIME1, iTime(NULL, 0, li_196 + 6));
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_PRICE1, ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + li_204, li_196 + 6));
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_TIME2, iTime(NULL, 0, li_196 + 3));
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_PRICE2, ObjectGetValueByShift(IndicatorObjPrefix + "downtrendline" + li_204, li_196 + 3));
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_COLOR, ObjectGet(IndicatorObjPrefix + "downtrendline" + li_204, OBJPROP_COLOR));
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_WIDTH, 5);
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_RAY, FALSE);
            ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_BACK, FALSE);
         }
         if (ObjectGet(IndicatorObjPrefix + "uptrendline" + ((li_204 - 1)), OBJPROP_PRICE1) == 0.0 && ObjectGet(IndicatorObjPrefix + "uptrendline" + li_204, OBJPROP_PRICE1) > 0.0 && Mark_Highest_and_Lowest_TL == TRUE) {
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_TIME1, iTime(NULL, 0, li_196 + 6));
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_PRICE1, ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + li_204, li_196 + 6));
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_TIME2, iTime(NULL, 0, li_196 + 3));
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_PRICE2, ObjectGetValueByShift(IndicatorObjPrefix + "uptrendline" + li_204, li_196 + 3));
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_COLOR, ObjectGet(IndicatorObjPrefix + "uptrendline" + li_204, OBJPROP_COLOR));
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_WIDTH, 5);
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_RAY, FALSE);
            ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_BACK, FALSE);
         }
      }
      ld_232 = 0;
      ld_240 = 0;
      for (int li_204 = 1; li_204 <= 30; li_204++) {
         ld_232 += ObjectGet(IndicatorObjPrefix + "downtrendline" + li_204, OBJPROP_PRICE1);
         ld_240 += ObjectGet(IndicatorObjPrefix + "uptrendline" + li_204, OBJPROP_PRICE1);
      }
      if (ld_232 == 0.0) {
         ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_TIME1, 0);
         ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_PRICE1, 0);
         ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_TIME2, 0);
         ObjectSet(IndicatorObjPrefix + "downmax", OBJPROP_PRICE2, 0);
      }
      if (ld_240 == 0.0) {
         ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_TIME1, 0);
         ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_PRICE1, 0);
         ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_TIME2, 0);
         ObjectSet(IndicatorObjPrefix + "upmax", OBJPROP_PRICE2, 0);
      }
      ObjectSet(IndicatorObjPrefix + "calctl", OBJPROP_PRICE1, 0);
   }
   if (Auto_Refresh == TRUE && (IndicatorCounted() == 0 || refreshed)) {
      ObjectSet(IndicatorObjPrefix + "calctl", OBJPROP_PRICE1, -1);
      li_248 = WindowHandle(Symbol(), Period());
      li_252 = RegisterWindowMessageA("MetaTrader4_Internal_Message");
      PostMessageA(li_248, li_252, 2, 1);
   }
   return (0);
}