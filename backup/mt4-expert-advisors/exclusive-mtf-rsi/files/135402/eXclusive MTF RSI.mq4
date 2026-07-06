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

#property indicator_color1 Red
#property indicator_color2 Lime
#property indicator_color3 Orange
#property indicator_color4 Blue
#property indicator_color5 White
#property indicator_color6 Green
#property indicator_color7 Yellow
#property indicator_color8 Moccasin

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 8
#property indicator_level1 70
#property indicator_level2 30
#property indicator_level3 50

input int RSIperiod = 14;
input ENUM_APPLIED_PRICE RSIprice = PRICE_CLOSE; // Price type
input ENUM_MA_METHOD ma_type = MODE_SMA; // Smoothing method

input bool ShowRSI_M1 = true;
input bool ShowRSI_M5 = true;
input bool ShowRSI_M15 = true;
input bool ShowRSI_M30 = true;
input bool ShowRSI_M60 = true;
input bool ShowRSI_M240 = true;
input bool ShowRSI_M1440 = true;
input bool ShowRSI_M10080 = true;

input color M1_color = Red;
input color M5_color = Lime;
input color M15_color = Orange;
input color M30_color = Blue;
input color M60_color = White;
input color M240_color = Green;
input color M1440_color = Yellow;
input color M10080_color = Moccasin;

double M1Buffer[];
double M5Buffer[];
double M15Buffer[];
double M30Buffer[];
double M60Buffer[];
double M240Buffer[];
double M1440Buffer[];
double M10080Buffer[];

int TF1 = 1;
int TF5 = 5;
int TF15 = 15;
int TF30 = 30;
int TF60 = 60;
int TF240 = 240;
int TF1440 = 1440;
int TF10080 = 10080;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   double temp = iCustom(NULL, 0, "1-RSI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the '1-RSI' indicator");
      return INIT_FAILED;
   }
   //---- indicators
   //============================================================================================

   SetIndexBuffer(0, M1Buffer);
   SetIndexLabel(0, "M1 RSI");
   SetIndexStyle(0, DRAW_LINE, 0, 1, M1_color);
   //============================================================================================
   SetIndexBuffer(1, M5Buffer);
   SetIndexLabel(1, "M5 RSI");
   SetIndexStyle(1, DRAW_LINE, 0, 1, M5_color);
   //============================================================================================
   SetIndexBuffer(2, M15Buffer);
   SetIndexLabel(2, "M15 RSI");
   SetIndexStyle(2, DRAW_LINE, 0, 1, M15_color);
   //============================================================================================
   SetIndexBuffer(3, M30Buffer);
   SetIndexLabel(3, "M30 RSI");
   SetIndexStyle(3, DRAW_LINE, 0, 1, M30_color);
   //============================================================================================
   SetIndexBuffer(4, M60Buffer);
   SetIndexLabel(4, "H1 RSI");
   SetIndexStyle(4, DRAW_LINE, 0, 1, M60_color);
   //============================================================================================
   SetIndexBuffer(5, M240Buffer);
   SetIndexLabel(5, "H4 RSI");
   SetIndexStyle(5, DRAW_LINE, 0, 1, M240_color);
   //============================================================================================
   SetIndexBuffer(6, M1440Buffer);
   SetIndexLabel(6, "D1 RSI");
   SetIndexStyle(6, DRAW_LINE, 0, 1, M1440_color);
   //============================================================================================
   SetIndexBuffer(7, M10080Buffer);
   SetIndexLabel(7, "W1 RSI");
   SetIndexStyle(7, DRAW_LINE, 0, 1, M10080_color);
   //============================================================================================

   IndicatorShortName("eXclusive MTF_RSI(" + RSIperiod + ")");
   return 0;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   //----
   ObjectDelete("M1RSI");
   ObjectDelete("M5RSI");
   ObjectDelete("M15RSI");
   ObjectDelete("M30RSI");
   ObjectDelete("H1RSI");
   ObjectDelete("H4RSI");
   ObjectDelete("D1RSI");
   ObjectDelete("W1RSI");
   ObjectDelete("M1ValueRSI");
   ObjectDelete("M5ValueRSI");
   ObjectDelete("M15ValueRSI");
   ObjectDelete("M30ValueRSI");
   ObjectDelete("H1ValueRSI");
   ObjectDelete("H4ValueRSI");
   ObjectDelete("D1ValueRSI");
   ObjectDelete("W1ValueRSI");

   //----
   return (0);
}

string TimeframeToString(ENUM_TIMEFRAMES tf)
{
   switch (tf)
   {
      case PERIOD_M1: return "M1";
      case PERIOD_M5: return "M5";
      case PERIOD_D1: return "D1";
      case PERIOD_H1: return "H1";
      case PERIOD_H4: return "H4";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_MN1: return "MN1";
      case PERIOD_W1: return "W1";
      case PERIOD_CURRENT: return TimeframeToString((ENUM_TIMEFRAMES)(_Period));
   }
   return "M1";
}

double rsi(int tf, int pos)
{
   return iCustom(_Symbol, tf, "1-RSI", TimeframeToString((ENUM_TIMEFRAMES)tf), RSIperiod, ma_type, RSIperiod, true, false, "", "", 0, 0, "", false, false, "", false, "", "", "", false, "", "", "", false, 0, pos);
}

double rsi(int tf, ENUM_APPLIED_PRICE price, int pos)
{
   return iCustom(_Symbol, tf, "1-RSI", TimeframeToString((ENUM_TIMEFRAMES)tf), RSIperiod, ma_type, RSIperiod, true, false, "", "", 0, 0, "", false, false, "", false, "", "", "", false, "", "", "", false, price, pos);
}

//============================================================================================
int start()
{
   if (ShowRSI_M1 && Period() <= 1)
   {
      start1();
      CreateLabel("M1_RSI", 10, 30, 2, M1_color, "M1", 10);
      CreateLabel("M1Value_RSI", 10, 10, 2, M1_color, DoubleToStr(NormalizeDouble(rsi(TF1, 0), 1), 1), 10);
   }
   if (ShowRSI_M5 && Period() <= 5)
   {
      start2();
      CreateLabel("M5_RSI", 50, 30, 2, M5_color, "M5", 10);
      CreateLabel("M5Value_RSI", 50, 10, 2, M5_color, DoubleToStr(NormalizeDouble(rsi(TF5, 0), 1), 1), 10);
   }
   if (ShowRSI_M15 && Period() <= 15)
   {
      start3();
      CreateLabel("M15_RSI", 90, 30, 2, M15_color, "M15", 10);
      CreateLabel("M15Value_RSI", 90, 10, 2, M15_color, DoubleToStr(NormalizeDouble(rsi(TF15, 0), 1), 1), 10);
   }
   if (ShowRSI_M30 && Period() <= 30)
   {
      start4();
      CreateLabel("M30_RSI", 130, 30, 2, M30_color, "M30", 10);
      CreateLabel("M30Value_RSI", 130, 10, 2, M30_color, DoubleToStr(NormalizeDouble(rsi(TF30, 0), 1), 1), 10);
   }
   if (ShowRSI_M60 && Period() <= 60)
   {
      start5();
      CreateLabel("H1_RSI", 170, 30, 2, M60_color, "H1", 10);
      CreateLabel("H1Value_RSI", 170, 10, 2, M60_color, DoubleToStr(NormalizeDouble(rsi(TF60, 0), 1), 1), 10);
   }
   if (ShowRSI_M240 && Period() <= 240)
   {
      start6();
      CreateLabel("H4_RSI", 210, 30, 2, M240_color, "H4", 10);
      CreateLabel("H4Value_RSI", 210, 10, 2, M240_color, DoubleToStr(NormalizeDouble(rsi(TF240, 0), 1), 1), 10);
   }
   if (ShowRSI_M1440 && Period() <= 1440)
   {
      start7();
      CreateLabel("D1_RSI", 250, 30, 2, M1440_color, "D1", 10);
      CreateLabel("D1Value_RSI", 250, 10, 2, M1440_color, DoubleToStr(NormalizeDouble(rsi(TF1440, 0), 1), 1), 10);
   }
   if (ShowRSI_M10080 && Period() <= 10080)
   {
      start8();
      CreateLabel("W1_RSI", 290, 30, 2, M10080_color, "W1", 10);
      CreateLabel("W1Value_RSI", 290, 10, 2, M10080_color, DoubleToStr(NormalizeDouble(rsi(TF10080, 0), 1), 1), 10);
   }

   return (0);
}
//============================================================================================
//============================================================================================
int start1()
{
   datetime TimeArray1[];
   int i, limit, y = 0, counted_bars = IndicatorCounted();
   ArrayCopySeries(TimeArray1, MODE_TIME, Symbol(), 1);
   limit = Bars - counted_bars;
   for (i = 0, y = 0; i < limit; i++)
   {
      if (Time[i] < TimeArray1[y])
         y++;
      M1Buffer[i] = rsi(1, RSIprice, y);
   }
   return (0);
}
//============================================================================================
int start2()
{
   datetime TimeArray2[];
   int i, limit, y = 0, counted_bars = IndicatorCounted();
   ArrayCopySeries(TimeArray2, MODE_TIME, Symbol(), TF5);
   limit = Bars - counted_bars;
   for (i = 0, y = 0; i < limit; i++)
   {
      if (Time[i] < TimeArray2[y])
         y++;
      M5Buffer[i] = rsi(TF5, RSIprice, y);
   }
   return (0);
}
//============================================================================================
int start3()
{
   datetime TimeArray3[];
   int i, limit, y = 0, counted_bars = IndicatorCounted();
   ArrayCopySeries(TimeArray3, MODE_TIME, Symbol(), TF15);
   limit = Bars - counted_bars;
   for (i = 0, y = 0; i < limit; i++)
   {
      if (Time[i] < TimeArray3[y])
         y++;
      M15Buffer[i] = rsi(TF15, RSIprice, y);
   }
   return (0);
}
//============================================================================================
int start4()
{
   datetime TimeArray4[];
   int i, limit, y = 0, counted_bars = IndicatorCounted();
   ArrayCopySeries(TimeArray4, MODE_TIME, Symbol(), TF30);
   limit = Bars - counted_bars;
   for (i = 0, y = 0; i < limit; i++)
   {
      if (Time[i] < TimeArray4[y])
         y++;
      M30Buffer[i] = rsi(TF30, RSIprice, y);
   }
   return (0);
}
//============================================================================================
int start5()
{
   datetime TimeArray5[];
   int i, limit, y = 0, counted_bars = IndicatorCounted();
   ArrayCopySeries(TimeArray5, MODE_TIME, Symbol(), TF60);
   limit = Bars - counted_bars;
   for (i = 0, y = 0; i < limit; i++)
   {
      if (Time[i] < TimeArray5[y])
         y++;
      M60Buffer[i] = rsi(TF60, RSIprice, y);
   }
   return (0);
}
//============================================================================================
int start6()
{
   datetime TimeArray6[];
   int i, limit, y = 0, counted_bars = IndicatorCounted();
   ArrayCopySeries(TimeArray6, MODE_TIME, Symbol(), TF240);
   limit = Bars - counted_bars;
   for (i = 0, y = 0; i < limit; i++)
   {
      if (Time[i] < TimeArray6[y])
         y++;
      M240Buffer[i] = rsi(TF240, RSIprice, y);
   }
   return (0);
}
//============================================================================================
int start7()
{
   datetime TimeArray7[];
   int i, limit, y = 0, counted_bars = IndicatorCounted();
   ArrayCopySeries(TimeArray7, MODE_TIME, Symbol(), TF1440);
   limit = Bars - counted_bars;
   for (i = 0, y = 0; i < limit; i++)
   {
      if (Time[i] < TimeArray7[y])
         y++;
      M1440Buffer[i] = rsi(TF1440, RSIprice, y);
   }
   return (0);
}
//============================================================================================
int start8()
{
   datetime TimeArray8[];
   int i, limit, y = 0, counted_bars = IndicatorCounted();
   ArrayCopySeries(TimeArray8, MODE_TIME, Symbol(), TF10080);
   limit = Bars - counted_bars;
   for (i = 0, y = 0; i < limit; i++)
   {
      if (Time[i] < TimeArray8[y])
         y++;
      M10080Buffer[i] = rsi(TF10080, RSIprice, y);
   }
   return (0);
}
//============================================================================================
//============================================================================================
void CreateLabel(string name, int x, int y, int corner, int z, string text, int size,
                 string font = "Arial")
{
   ObjectCreate(name, OBJ_LABEL, WindowFind("eXclusive MTF_RSI(" + RSIperiod + ")"), 0, 0);
   ObjectSet(name, OBJPROP_CORNER, corner);
   ObjectSet(name, OBJPROP_COLOR, z);
   ObjectSet(name, OBJPROP_XDISTANCE, x);
   ObjectSet(name, OBJPROP_YDISTANCE, y);
   ObjectSetText(name, text, size, font, z);
}
//============================================================================================
