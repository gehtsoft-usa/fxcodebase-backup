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
#property indicator_buffers 2
#property strict

input int Fractal_Timeframe = 0;
input int Maxbar = 2000;
input color Up_Fractal_Color = clrRed;
input int Up_Fractal_Symbol = 108;
input color Down_Fractal_Color = clrBlue;
input int Down_Fractal_Symbol = 108;
input bool Extend_Line = true;
input bool Extend_Line_to_Background = true;
input bool Show_Validation_Candle = true;
input color Up_Fractal_Extend_Line_Color = clrRed;
input int Up_Fractal_Extend_Width = 0;
input int Up_Fractal_Extend_Style = 2;
input color Down_Fractal_Extend_Line_Color = clrBlue;
input int Down_Fractal_Extend_Width = 0;
input int Down_Fractal_Extend_Style = 2;
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

double UpBuffer[], DoBuffer[], refchk, tempref, level;
int barc;

int init()
{
   visibility.Init("fractal_mtf", "fract", "Show/Hide", button_x, button_y);
   SetIndexBuffer(0, UpBuffer);
   SetIndexStyle(0, DRAW_ARROW, DRAW_ARROW, 0, Up_Fractal_Color);
   SetIndexArrow(0, Up_Fractal_Symbol);
   SetIndexBuffer(1, DoBuffer);
   SetIndexStyle(1, DRAW_ARROW, DRAW_ARROW, 0, Down_Fractal_Color);
   SetIndexArrow(1, Down_Fractal_Symbol);

   return (0);
}

int deinit()
{
   visibility.DeInit();
   for (int i = ObjectsTotal(); i >= 0; i--)
   {
      if (StringSubstr(ObjectName(i), 0, 12) == "MTF_Fractal_")
      {
         ObjectDelete(ObjectName(i));
      }
   }

   return (0);
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
   {
      start();
   }
}

int start()
{
   visibility.HandleButtonClicks();
   int i, c, dif;
   tempref = iHigh(Symbol(), Fractal_Timeframe, 1) +
             iHigh(Symbol(), Fractal_Timeframe, 51) +
             iHigh(Symbol(), Fractal_Timeframe, 101);
   
   if (visibility.IsRecalcNeeded())
   {
      if (visibility.IsVisible())
      {
         barc = 0;
         refchk = tempref;
      }
      else
      {
         ArrayInitialize(UpBuffer, EMPTY_VALUE);
         ArrayInitialize(DoBuffer, EMPTY_VALUE);
         for (int i = ObjectsTotal(); i >= 0; i--)
         {
            if (StringSubstr(ObjectName(i), 0, 12) == "MTF_Fractal_")
            {
               ObjectDelete(ObjectName(i));
            }
         }
         visibility.ResetRecalc();
         return 0;
      }
      visibility.ResetRecalc();
   }
   else if (!visibility.IsVisible())
   {
      return 0;
   }

   if (barc != Bars || IndicatorCounted() < 0 || tempref != refchk)
   {
      barc = Bars;
      refchk = tempref;
   }
   else
      return (0);

   dif = Fractal_Timeframe / Period();

   for (i = 0; i < MathMin(Bars - 10, Maxbar); i++)
   {
      if (iBarShift(NULL, Fractal_Timeframe, Time[i]) < 3)
      {
         UpBuffer[i] = 0;
         DoBuffer[i] = 0;
         continue;
      }
      UpBuffer[i] = iFractals(NULL, Fractal_Timeframe, 1, iBarShift(NULL, Fractal_Timeframe, Time[i]));
      DoBuffer[i] = iFractals(NULL, Fractal_Timeframe, 2, iBarShift(NULL, Fractal_Timeframe, Time[i]));
   }

   if (Extend_Line)
   {
      for (i = 0; i < MathMin(Bars - 10, Maxbar); i++)
      {
         if (UpBuffer[i] > 0)
         {
            level = UpBuffer[i];
            for (c = i; c > 0; c--)
            {
               if ((Open[c] < level && Close[c] > level) || (Open[c] > level && Close[c] < level))
                  break;
               if (Open[c] <= level && Close[c] <= level && Open[c - 1] >= level && Close[c - 1] >= level)
                  break;
               if (Open[c] >= level && Close[c] >= level && Open[c - 1] <= level && Close[c - 1] <= level)
                  break;
            }
            DrawLine("H", i, c, level, Extend_Line_to_Background, Up_Fractal_Extend_Line_Color, Up_Fractal_Extend_Width, Up_Fractal_Extend_Style);
            if (Show_Validation_Candle)
               UpBuffer[i - 2 * dif] = level;
            i += dif;
         }
      }

      for (i = 0; i < MathMin(Bars - 10, Maxbar); i++)
      {
         if (DoBuffer[i] > 0)
         {
            level = DoBuffer[i];
            for (c = i; c > 0; c--)
            {
               if ((Open[c] < level && Close[c] > level) || (Open[c] > level && Close[c] < level))
                  break;
               if (Open[c] <= level && Close[c] <= level && Open[c - 1] >= level && Close[c - 1] >= level)
                  break;
               if (Open[c] >= level && Close[c] >= level && Open[c - 1] <= level && Close[c - 1] <= level)
                  break;
            }
            DrawLine("L", i, c, level, Extend_Line_to_Background, Down_Fractal_Extend_Line_Color, Down_Fractal_Extend_Width, Down_Fractal_Extend_Style);
            if (Show_Validation_Candle)
               DoBuffer[i - 2 * dif] = level;
            i += dif;
         }
      }
   }

   return (0);
}

void DrawLine(string dir, int i, int c, double lev, bool back, color col, int width, int style)
{
   ObjectCreate("MTF_Fractal_" + dir + i, OBJ_TREND, 0, 0, 0, 0, 0);
   ObjectSet("MTF_Fractal_" + dir + i, OBJPROP_TIME1, iTime(Symbol(), Period(), i));
   ObjectSet("MTF_Fractal_" + dir + i, OBJPROP_PRICE1, lev);
   ObjectSet("MTF_Fractal_" + dir + i, OBJPROP_TIME2, iTime(Symbol(), Period(), c));
   ObjectSet("MTF_Fractal_" + dir + i, OBJPROP_PRICE2, lev);
   ObjectSet("MTF_Fractal_" + dir + i, OBJPROP_RAY, 0);
   ObjectSet("MTF_Fractal_" + dir + i, OBJPROP_BACK, back);
   ObjectSet("MTF_Fractal_" + dir + i, OBJPROP_COLOR, col);
   ObjectSet("MTF_Fractal_" + dir + i, OBJPROP_WIDTH, width);
   ObjectSet("MTF_Fractal_" + dir + i, OBJPROP_STYLE, style);
}