// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69872

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
#property link "http://fxcodebase.com"
#property version "1.2"
#property strict
#property indicator_separate_window
#property indicator_buffers 9

#property indicator_plots 9

#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Orange
#property indicator_color4 Purple
#property indicator_color5 Brown
#property indicator_color6 White
#property indicator_color7 Yellow
#property indicator_color8 Green
#property indicator_color9 Gold

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2
#property indicator_width6 2
#property indicator_width7 2
#property indicator_width8 3
#property indicator_width9 3

#property indicator_level1 - 50
#property indicator_level2 - 26
#property indicator_level3 - 12
#property indicator_level4 0
#property indicator_level5 12
#property indicator_level6 26
#property indicator_level7 50
#property indicator_levelcolor clrLightSlateGray
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_RANGEMODE
{
   HIGH_LOW,
   CLOSE_CLOSE,
   HIGH_LOW_CLOSE,
};
// Indicator parameters

input bool PopUP = false;
input bool Mail = false;
input bool Push = false;

input int iPRIPeriod = 14;
input int iVisibleBars = 0;

input ENUM_APPLIED_PRICE iPrice = PRICE_CLOSE;
input ENUM_RANGEMODE RangeMode = HIGH_LOW;
input ENUM_TIMEFRAMES TimeFrame = 0;
// Show currencies on chart
input bool ShowAuto = true;
// Show all currencies
input bool ShowAll = false;
input bool ShowEUR_ = false;
input bool ShowGBP_ = false;
input bool ShowAUD_ = false;
input bool ShowNZD_ = false;
input bool ShowCHF_ = false;
input bool ShowCAD_ = false;
input bool ShowJPY_ = false;
input bool ShowUSD_ = false;
input bool ShowXAU_ = false;
bool ShowEUR = false;
bool ShowGBP = false;
bool ShowAUD = false;
bool ShowNZD = false;
bool ShowCHF = false;
bool ShowCAD = false;
bool ShowJPY = false;
bool ShowUSD = false;
bool ShowXAU = false;

input color Color_EUR = Blue;
input color Color_GBP = Red;
input color Color_AUD = Orange;
input color Color_NZD = Purple;
input color Color_CHF = Brown;
input color Color_CAD = White;
input color Color_JPY = Yellow;
input color Color_USD = Green;
input color Color_XAU = Gold;

//---index buffers for drawing
double Idx1[], Idx2[], Idx3[], Idx4[], Idx5[], Idx6[], Idx7[], Idx8[], Idx9[];
string Currencies[indicator_buffers] =
    {
        "EUR", "GBP", "AUD", "NZD",
        "CHF", "CAD", "JPY", "USD", "XAU"};
string ShortName;
long BarsWindow;

string sTimeFrame;
string MESSAGE, tChartPeriod;
int window;
int mxStart = 40; //label coordinates
int myIncrement = 16;
int myStart = 32;

datetime Alert_EUR, Alert_GBP, Alert_AUD, Alert_NZD, Alert_CHF, Alert_CAD, Alert_JPY, Alert_USD, Alert_XAU;

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   if (!IndicatorSetInteger(INDICATOR_DIGITS, 0))
   {
      Alert("[Error] - [" + __FUNCTION__ + "]: Could not set indicator digits! Error: " + IntegerToString(GetLastError()) + "!");

      return INIT_FAILED;
   }
   
   IndicatorObjPrefix = GenerateIndicatorPrefix("crl8tromod");

   BarsWindow = ChartGetInteger(0, CHART_VISIBLE_BARS, 0) + iPRIPeriod;
   switch (TimeFrame)
   {
   case PERIOD_MN1:
      sTimeFrame = "MN1 ";
      break;
   case PERIOD_W1:
      sTimeFrame = "W1 ";
      break;
   case PERIOD_D1:
      sTimeFrame = "D1 ";
      break;
   case PERIOD_H12:
      sTimeFrame = "H12 ";
      break;
   case PERIOD_H8:
      sTimeFrame = "H8 ";
      break;
   case PERIOD_H6:
      sTimeFrame = "H6 ";
      break;
   case PERIOD_H4:
      sTimeFrame = "H4 ";
      break;
   case PERIOD_H3:
      sTimeFrame = "H3 ";
      break;
   case PERIOD_H2:
      sTimeFrame = "H2 ";
      break;
   case PERIOD_H1:
      sTimeFrame = "H1 ";
      break;
   case PERIOD_M30:
      sTimeFrame = "M30 ";
      break;
   case PERIOD_M20:
      sTimeFrame = "M20 ";
      break;
   case PERIOD_M15:
      sTimeFrame = "M15 ";
      break;
   case PERIOD_M12:
      sTimeFrame = "M12 ";
      break;
   case PERIOD_M10:
      sTimeFrame = "M10 ";
      break;
   case PERIOD_M6:
      sTimeFrame = "M6 ";
      break;
   case PERIOD_M5:
      sTimeFrame = "M5 ";
      break;
   case PERIOD_M4:
      sTimeFrame = "M4 ";
      break;
   case PERIOD_M3:
      sTimeFrame = "M3 ";
      break;
   case PERIOD_M2:
      sTimeFrame = "M2 ";
      break;
   case PERIOD_M1:
      sTimeFrame = "M1 ";
      break;
   default:
      sTimeFrame = "";
      break;
   }

   ShortName = "iCorrel8 " + sTimeFrame + "(" + IntegerToString(iPRIPeriod) + ") ";

   if (!IndicatorSetString(INDICATOR_SHORTNAME, ShortName))
   {
      Alert("[Error] - [" + __FUNCTION__ + "]: Could not set indicator name! Error: " + IntegerToString(GetLastError()) + "!");

      return INIT_FAILED;
   }
   ShowEUR = ShowEUR_;
   ShowGBP = ShowGBP_;
   ShowAUD = ShowAUD_;
   ShowNZD = ShowNZD_;
   ShowCHF = ShowCHF_;
   ShowCAD = ShowCAD_;
   ShowJPY = ShowJPY_;
   ShowUSD = ShowUSD_;
   ShowXAU = ShowXAU_;

   //---currencies to show
   if (ShowAuto)
   {
      string Quote = StringSubstr(Symbol(), 3, 3); //Quote currency name
      string Base = StringSubstr(Symbol(), 0, 3);  //Base currency name
      if (Quote == "EUR" || Base == "EUR")
         ShowEUR = true;
      if (Quote == "GBP" || Base == "GBP")
         ShowGBP = true;
      if (Quote == "AUD" || Base == "AUD")
         ShowAUD = true;
      if (Quote == "NZD" || Base == "NZD")
         ShowNZD = true;
      if (Quote == "CHF" || Base == "CHF")
         ShowCHF = true;
      if (Quote == "CAD" || Base == "CAD")
         ShowCAD = true;
      if (Quote == "JPY" || Base == "JPY")
         ShowJPY = true;
      if (Quote == "USD" || Base == "USD")
         ShowUSD = true;
      if (Quote == "XAU" || Base == "XAU")
         ShowXAU = true;
   }

   if (ShowAll)
   {
      ShowEUR = true;
      ShowGBP = true;
      ShowAUD = true;
      ShowNZD = true;
      ShowCHF = true;
      ShowCAD = true;
      ShowJPY = true;
      ShowUSD = true;
      ShowXAU = true;
   }

   window = ChartWindowFind();

   int xStart = 4; //label coordinates
   int xIncrement = 50;
   int yStart = 16;
   //---set buffer properties

   if (ShowEUR)
   {
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetString(0, PLOT_LABEL, Currencies[0]);
      PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, iPRIPeriod);
      PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);

      CreateLabel(Currencies[0], window, xStart, yStart, Color_EUR);
      xStart += xIncrement;
   }
   if (ShowGBP)
   {
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetString(1, PLOT_LABEL, Currencies[1]);
      PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, iPRIPeriod);
      PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

      CreateLabel(Currencies[1], window, xStart, yStart, Color_GBP);
      xStart += xIncrement;
   }
   if (ShowAUD)
   {
      PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(2, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetString(2, PLOT_LABEL, Currencies[2]);
      PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, iPRIPeriod);
      PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, EMPTY_VALUE);

      CreateLabel(Currencies[2], window, xStart, yStart, Color_AUD);
      xStart += xIncrement;
   }
   if (ShowNZD)
   {
      PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(3, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetString(3, PLOT_LABEL, Currencies[3]);
      PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, iPRIPeriod);
      PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);

      CreateLabel(Currencies[3], window, xStart, yStart, Color_NZD);
      xStart += xIncrement;
   }
   if (ShowCHF)
   {
      PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(4, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetString(4, PLOT_LABEL, Currencies[4]);
      PlotIndexSetInteger(4, PLOT_DRAW_BEGIN, iPRIPeriod);
      PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, EMPTY_VALUE);

      CreateLabel(Currencies[4], window, xStart, yStart, Color_CHF);
      xStart += xIncrement;
   }
   if (ShowCAD)
   {
      PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(5, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetString(5, PLOT_LABEL, Currencies[5]);
      PlotIndexSetInteger(5, PLOT_DRAW_BEGIN, iPRIPeriod);
      PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, EMPTY_VALUE);

      CreateLabel(Currencies[5], window, xStart, yStart, Color_CAD);
      xStart += xIncrement;
   }
   if (ShowJPY)
   {
      PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(6, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetString(6, PLOT_LABEL, Currencies[6]);
      PlotIndexSetInteger(6, PLOT_DRAW_BEGIN, iPRIPeriod);
      PlotIndexSetDouble(6, PLOT_EMPTY_VALUE, EMPTY_VALUE);

      CreateLabel(Currencies[6], window, xStart, yStart, Color_JPY);
      xStart += xIncrement;
   }
   if (ShowUSD)
   {
      PlotIndexSetInteger(7, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(7, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetString(7, PLOT_LABEL, Currencies[7]);
      PlotIndexSetInteger(7, PLOT_DRAW_BEGIN, iPRIPeriod);
      PlotIndexSetDouble(7, PLOT_EMPTY_VALUE, EMPTY_VALUE);

      CreateLabel(Currencies[7], window, xStart, yStart, Color_USD);
      xStart += xIncrement;
   }
   if (ShowXAU)
   {
      PlotIndexSetInteger(8, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(8, PLOT_LINE_STYLE, STYLE_SOLID);
      PlotIndexSetString(8, PLOT_LABEL, Currencies[8]);
      PlotIndexSetInteger(8, PLOT_DRAW_BEGIN, iPRIPeriod);
      PlotIndexSetDouble(8, PLOT_EMPTY_VALUE, EMPTY_VALUE);

      CreateLabel(Currencies[8], window, xStart, yStart, Color_XAU);
   }

   //---index buffers
   SetIndexBuffer(0, Idx1);
   SetIndexBuffer(1, Idx2);
   SetIndexBuffer(2, Idx3);
   SetIndexBuffer(3, Idx4);
   SetIndexBuffer(4, Idx5);
   SetIndexBuffer(5, Idx6);
   SetIndexBuffer(6, Idx7);
   SetIndexBuffer(7, Idx8);
   SetIndexBuffer(8, Idx9);

   //---
   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   return;
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
   BarsWindow = ChartGetInteger(0, CHART_VISIBLE_BARS, 0) + iPRIPeriod;

   int shift;
   int limit = rates_total - prev_calculated;

   if (rates_total < iPRIPeriod)
   {
      return 0;
   }

   if ((prev_calculated < iPRIPeriod) || (prev_calculated > rates_total))
   {
      ArrayInitialize(Idx1, EMPTY_VALUE);
      ArrayInitialize(Idx2, EMPTY_VALUE);
      ArrayInitialize(Idx3, EMPTY_VALUE);
      ArrayInitialize(Idx4, EMPTY_VALUE);
      ArrayInitialize(Idx5, EMPTY_VALUE);
      ArrayInitialize(Idx6, EMPTY_VALUE);
      ArrayInitialize(Idx7, EMPTY_VALUE);
      ArrayInitialize(Idx8, EMPTY_VALUE);
      ArrayInitialize(Idx9, EMPTY_VALUE);

      limit = rates_total - iPRIPeriod;
   }

   bool Idx1_series = ArrayGetAsSeries(Idx1);
   bool Idx2_series = ArrayGetAsSeries(Idx2);
   bool Idx3_series = ArrayGetAsSeries(Idx3);
   bool Idx4_series = ArrayGetAsSeries(Idx4);
   bool Idx5_series = ArrayGetAsSeries(Idx5);
   bool Idx6_series = ArrayGetAsSeries(Idx6);
   bool Idx7_series = ArrayGetAsSeries(Idx7);
   bool Idx8_series = ArrayGetAsSeries(Idx8);
   bool Idx9_series = ArrayGetAsSeries(Idx9);
   bool time_series = ArrayGetAsSeries(time);

   ArraySetAsSeries(Idx1, true);
   ArraySetAsSeries(Idx2, true);
   ArraySetAsSeries(Idx3, true);
   ArraySetAsSeries(Idx4, true);
   ArraySetAsSeries(Idx5, true);
   ArraySetAsSeries(Idx6, true);
   ArraySetAsSeries(Idx7, true);
   ArraySetAsSeries(Idx8, true);
   ArraySetAsSeries(Idx9, true);
   ArraySetAsSeries(time, true);

   for (int i = 0; i <= limit; i++)
   {
      shift = iBarShift(NULL, TimeFrame, time[i]);

      double EUR = 0;
      if (ShowEUR || ShowUSD)
      {
         if (!iPRI("EURUSD", TimeFrame, iPRIPeriod, iPrice, shift, EUR))
         {
            Print("Loading EURUSD...");
            return 0;
         }
         double EURUSD = iClose("EURUSD", TimeFrame, shift);
         if (EURUSD == 0)
         {
            Print("Loading EURUSD...");
            return 0;
         }
         EUR *= 1 / EURUSD;
      }
      double GBP = 0;
      if (ShowGBP || ShowUSD)
      {
         if (!iPRI("GBPUSD", TimeFrame, iPRIPeriod, iPrice, shift, GBP))
         {
            Print("Loading GBPUSD...");
            return 0;
         }
         double GBPUSD = iClose("GBPUSD", TimeFrame, shift);
         if (GBPUSD == 0)
         {
            Print("Loading GBPUSD...");
            return 0;
         }
         GBP *= 1 / GBPUSD;
      }
      double AUD = 0;
      if (ShowAUD || ShowUSD)
      {
         if (!iPRI("AUDUSD", TimeFrame, iPRIPeriod, iPrice, shift, AUD))
         {
            Print("Loading AUDUSD...");
            return 0;
         }
         double AUDUSD = iClose("AUDUSD", TimeFrame, shift);
         if (AUDUSD == 0)
         {
            Print("Loading AUDUSD...");
            return 0;
         }
         AUD *= 1 / AUDUSD;
      }
      double NZD = 0;
      if (ShowNZD || ShowUSD)
      {
         if (!iPRI("NZDUSD", TimeFrame, iPRIPeriod, iPrice, shift, NZD))
         {
            Print("Loading NZDUSD...");
            return 0;
         }
         double NZDUSD = iClose("NZDUSD", TimeFrame, shift);
         if (NZDUSD == 0)
         {
            Print("Loading NZDUSD...");
            return 0;
         }
         NZD *= 1 / NZDUSD;
      }
      double CHF = 0;
      if (ShowCHF || ShowUSD)
      {
         if (!iPRI("USDCHF", TimeFrame, iPRIPeriod, iPrice, shift, CHF))
         {
            Print("Loading USDCHF...");
            return 0;
         }
         CHF *= -1;
      }
      double CAD = 0;
      if (ShowCAD || ShowUSD)
      {
         if (!iPRI("USDCAD", TimeFrame, iPRIPeriod, iPrice, shift, CAD))
         {
            Print("Loading USDCAD...");
            return 0;
         }
         CAD *= -1;
      }
      double JPY = 0;
      if (ShowJPY || ShowUSD)
      {
         if (!iPRI("USDJPY", TimeFrame, iPRIPeriod, iPrice, shift, JPY))
         {
            Print("Loading USDJPY...");
            return 0;
         }
         JPY *= -1;
      }
      double XAU = 0;
      if (ShowXAU || ShowUSD)
      {
         if (!iPRI("XAUUSD", TimeFrame, iPRIPeriod, iPrice, shift, XAU))
         {
            Print("Loading XAUUSD...");
            return 0;
         }
         double XAUUSD = iClose("XAUUSD", TimeFrame, shift) / 1000;
         if (XAUUSD == 0)
         {
            Print("Loading XAUUSD...");
            return 0;
         }
         XAU *= 1 / XAUUSD;
      }
      mxStart = 200; //label coordinates
      myIncrement = 20;
      myStart = 10;

      if (ShowEUR)
      {
         Idx1[i] = EUR;
         crossed0(Idx1[0], Idx1[1], "EUR", Color_EUR, Alert_EUR, time[0]);
      }
      if (ShowGBP)
      {
         Idx2[i] = GBP;
         crossed0(Idx2[0], Idx2[1], "GBP", Color_GBP, Alert_GBP, time[0]);
      }
      if (ShowAUD)
      {
         Idx3[i] = AUD;
         crossed0(Idx3[0], Idx3[1], "AUD", Color_AUD, Alert_AUD, time[0]);
      }
      if (ShowNZD)
      {
         Idx4[i] = NZD;
         crossed0(Idx4[0], Idx4[1], "NZD", Color_NZD, Alert_NZD, time[0]);
      }
      if (ShowCHF)
      {
         Idx5[i] = CHF;
         crossed0(Idx5[0], Idx5[1], "CHF", Color_CHF, Alert_CHF, time[0]);
      }
      if (ShowCAD)
      {
         Idx6[i] = CAD;
         crossed0(Idx6[0], Idx6[1], "CAD", Color_CAD, Alert_CAD, time[0]);
      }
      if (ShowJPY)
      {
         Idx7[i] = JPY;
         crossed0(Idx7[0], Idx7[1], "JPY", Color_JPY, Alert_JPY, time[0]);
      }
      if (ShowUSD)
      {
         Idx8[i] = -(EUR + GBP + AUD + NZD + CHF + CAD + JPY + XAU) / (indicator_buffers - 1);;
         crossed0(Idx8[0], Idx8[1], "USD", Color_USD, Alert_USD, time[0]);
      }
      if (ShowXAU)
      {
         Idx9[i] = XAU;
         crossed0(Idx9[0], Idx9[1], "XAU", Color_XAU, Alert_XAU, time[0]);
      }
   }

   ArraySetAsSeries(Idx1, Idx1_series);
   ArraySetAsSeries(Idx2, Idx2_series);
   ArraySetAsSeries(Idx3, Idx3_series);
   ArraySetAsSeries(Idx4, Idx4_series);
   ArraySetAsSeries(Idx5, Idx5_series);
   ArraySetAsSeries(Idx6, Idx6_series);
   ArraySetAsSeries(Idx7, Idx7_series);
   ArraySetAsSeries(Idx8, Idx8_series);
   ArraySetAsSeries(Idx9, Idx9_series);
   ArraySetAsSeries(time, time_series);

   int visibleBars = (iVisibleBars <= 0) ? rates_total : iVisibleBars;

   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, rates_total - visibleBars);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, rates_total - visibleBars);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, rates_total - visibleBars);
   PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, rates_total - visibleBars);
   PlotIndexSetInteger(4, PLOT_DRAW_BEGIN, rates_total - visibleBars);
   PlotIndexSetInteger(5, PLOT_DRAW_BEGIN, rates_total - visibleBars);
   PlotIndexSetInteger(6, PLOT_DRAW_BEGIN, rates_total - visibleBars);
   PlotIndexSetInteger(7, PLOT_DRAW_BEGIN, rates_total - visibleBars);
   PlotIndexSetInteger(8, PLOT_DRAW_BEGIN, rates_total - visibleBars);

   //--- return value of prev_calculated for next call
   return (rates_total);
}
//+------------------------------------------------------------------+

void crossed0(double val0, double val1, string curr, color CLR, datetime &AlertTime, datetime time0)
{
   bool bAlert;

   bAlert = false;

   while (true)
   {
      if (val0 > 0.0 && val1 < 0.0)
      {
         MESSAGE = curr + " " + DoubleToString(val0, 1) + " XA 0";
         bAlert = true;
         break;
      }

      if (val0 < 0.0 && val1 > 0.0)
      {
         MESSAGE = curr + " " + DoubleToString(val0, 1) + " XB 0";
         bAlert = true;
         break;
      }

      if (val0 < val1)
      {
         MESSAGE = curr + " " + DoubleToString(val0, 1) + "<";
         break;
      }

      if (val0 > val1)
      {
         MESSAGE = curr + " " + DoubleToString(val0, 1) + ">";
         break;
      }

      MESSAGE = curr + " " + DoubleToString(val0, 1) + "=";
      break;
   } // while

   CreateMessage(curr + "m", MESSAGE, window, mxStart, myStart, CLR);
   myStart += myIncrement;

   if (bAlert)
   {
      if (PopUP == true && AlertTime != time0)
         Alert(MESSAGE + " " + sTimeFrame);
      if (Mail == true && AlertTime != time0)
         SendMail(MESSAGE + " " + sTimeFrame, MESSAGE);
      if (Push == true && AlertTime != time0)
         SendNotification(MESSAGE + " " + sTimeFrame);

      AlertTime = time0;
   }

   return;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateMessage(string label,
                   string currency,
                   int window,
                   int x,
                   int y,
                   int clr)
{
   currency = fFill(currency, 14);
   ObjectDelete(0, IndicatorObjPrefix + label);
   ObjectCreate(0, IndicatorObjPrefix + label, OBJ_LABEL, window, 0, 0);

   ObjectSetString(0, IndicatorObjPrefix + label, OBJPROP_TEXT, currency);
   ObjectSetInteger(0, IndicatorObjPrefix + label, OBJPROP_FONTSIZE, 16);
   ObjectSetString(0, IndicatorObjPrefix + label, OBJPROP_FONT, "Terminal");
   ObjectSetInteger(0, IndicatorObjPrefix + label, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, IndicatorObjPrefix + label, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, IndicatorObjPrefix + label, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, IndicatorObjPrefix + label, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string fFill(string filled, int f)
{
   string FILLED;

   FILLED = StringSubstr(filled + "                                         ", 0, f);

   return (FILLED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLabel(string currency,
                 int window,
                 int x,
                 int y,
                 int clr)
{

   return;

   int label = ObjectCreate(0, IndicatorObjPrefix + currency, OBJ_LABEL, window, 0, 0);

   ObjectSetString(0, IndicatorObjPrefix + currency, OBJPROP_TEXT, currency);
   ObjectSetInteger(0, IndicatorObjPrefix + currency, OBJPROP_FONTSIZE, 16);
   ObjectSetInteger(0, IndicatorObjPrefix + currency, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, IndicatorObjPrefix + currency, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, IndicatorObjPrefix + currency, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, IndicatorObjPrefix + currency, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar()
{
   static datetime time_prev;
   if (iTime("EURUSD", TimeFrame, 0) != time_prev &&
       iTime("GBPUSD", TimeFrame, 0) != time_prev &&
       iTime("AUDUSD", TimeFrame, 0) != time_prev &&
       iTime("NZDUSD", TimeFrame, 0) != time_prev &&
       iTime("USDCHF", TimeFrame, 0) != time_prev &&
       iTime("USDCAD", TimeFrame, 0) != time_prev &&
       iTime("USDJPY", TimeFrame, 0) != time_prev &&
       iTime("XAUUSD", TimeFrame, 0) != time_prev)
   {
      time_prev = iTime("EURUSD", TimeFrame, 0);
      time_prev = iTime("GBPUSD", TimeFrame, 0);
      time_prev = iTime("AUDUSD", TimeFrame, 0);
      time_prev = iTime("NZDUSD", TimeFrame, 0);
      time_prev = iTime("USDCHF", TimeFrame, 0);
      time_prev = iTime("USDCAD", TimeFrame, 0);
      time_prev = iTime("USDJPY", TimeFrame, 0);
      time_prev = iTime("XAUUSD", TimeFrame, 0);
      return (true);
   }
   return (false);
}
//+------------------------------------------------------------------+
//| Percent Range Index Function                                     |
//+------------------------------------------------------------------+
bool iPRI(const string symbol,
            const ENUM_TIMEFRAMES timeframe,
            const int period,
            const ENUM_APPLIED_PRICE price,
            const int idx,
            double& PRI)
{
   double Price;
   double MaxHigh = -999;
   double MinLow = 999;
   double HighHigh;
   double HighClose;
   double HighLow;
   double LowHigh;
   double LowClose;
   double LowLow;
   ResetLastError();
   double test = iClose(symbol, timeframe, idx);
   if (test == 0 && GetLastError() == ERR_HISTORY_NOT_FOUND)
   {
      return false;
   }
   switch (RangeMode)
   {
      case HIGH_LOW:
      {
         MaxHigh = iHigh(symbol, timeframe,
                        iHighest(symbol, timeframe, MODE_HIGH, period, idx));
         MinLow = iLow(symbol, timeframe,
                     iLowest(symbol, timeframe, MODE_LOW, period, idx));
         break;
      }
      case CLOSE_CLOSE:
      {
         MaxHigh = iClose(symbol, timeframe,
                        iHighest(symbol, timeframe, MODE_CLOSE, period, idx));
         MinLow = iClose(symbol, timeframe,
                        iLowest(symbol, timeframe, MODE_CLOSE, period, idx));
         break;
      }
      case HIGH_LOW_CLOSE:
      {
         HighHigh = iHigh(symbol, timeframe,
                        iHighest(symbol, timeframe, MODE_HIGH, period, idx));
         HighClose = iClose(symbol, timeframe,
                           iHighest(symbol, timeframe, MODE_CLOSE, period, idx));
         HighLow = iLow(symbol, timeframe,
                        iHighest(symbol, timeframe, MODE_LOW, period, idx));
         LowHigh = iHigh(symbol, timeframe,
                        iLowest(symbol, timeframe, MODE_HIGH, period, idx));
         LowClose = iClose(symbol, timeframe,
                           iLowest(symbol, timeframe, MODE_CLOSE, period, idx));
         LowLow = iLow(symbol, timeframe,
                     iLowest(symbol, timeframe, MODE_LOW, period, idx));
         MaxHigh = (HighHigh + HighClose + HighLow) / 3;
         MinLow = (LowHigh + LowClose + LowLow) / 3;
         break;
      }
   }

   switch (price)
   {
   case PRICE_CLOSE:
      Price = iClose(symbol, timeframe, idx);
      break;
   case PRICE_HIGH:
      Price = iHigh(symbol, timeframe, idx);
      break;
   case PRICE_LOW:
      Price = iLow(symbol, timeframe, idx);
      break;
   case PRICE_MEDIAN:
      Price = (iHigh(symbol, timeframe, idx) +
               iLow(symbol, timeframe, idx)) /
              2;
      break;
   case PRICE_TYPICAL:
      Price = (iHigh(symbol, timeframe, idx) +
               iLow(symbol, timeframe, idx) +
               iClose(symbol, timeframe, idx)) /
              3;
      break;
   case PRICE_WEIGHTED:
      Price = (iHigh(symbol, timeframe, idx) +
               iLow(symbol, timeframe, idx) +
               iClose(symbol, timeframe, idx) +
               iClose(symbol, timeframe, idx)) /
              4;
      break;
   default:
      Price = iClose(symbol, timeframe, idx);
   }

   double Range = MaxHigh - MinLow;

   if (Range != 0.0)
   {
      PRI = 100 * (Price - MinLow) / Range;
      PRI -= 50;
   }
   else
      PRI = 0;
   return true;
}
