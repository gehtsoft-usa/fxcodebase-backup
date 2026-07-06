
/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        PRICEBAND_MTF_BTN_-_Current_TF_arrow
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160956#p160956
License:     GNU

── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com

── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7

── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1  C'131,131,131'      //
#property indicator_color2  C'131,131,131'      //
#property indicator_color3  C'131,131,131'      //
#property indicator_color4  C'131,131,131'      //
#property indicator_color5  C'131,131,131'      //
#property indicator_color6  C'131,131,131'      //
#property indicator_color7  C'131,131,131'      //
#property indicator_width1 0
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 0
#property indicator_width5 0
#property indicator_width6 1
#property indicator_width7 1
#property indicator_style1 STYLE_DASHDOTDOT
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_style7 STYLE_DASHDOTDOT
enum showCHL
  {
   NoLINES,
   onlyTMA,
   onlyBANDS,
   allLINES
  };
enum calcARR
  {
   ArrowsOFF,
   TrendOCLH,
   ChangeCOLOR,
   BreakBand
  };
ENUM_TIMEFRAMES TimeFrame_;
enum ENUM_TIMEFRAMES_CUSTOM
  {
   TF_CURRENT = PERIOD_CURRENT,     // Current timeframe
   TF_NEXT = -1,                     // Next higher timeframe
   TF_M1 = PERIOD_M1,                // 1 Minute
   TF_M5 = PERIOD_M5,                // 5 Minutes
   TF_M15 = PERIOD_M15,              // 15 Minutes
   TF_M30 = PERIOD_M30,              // 30 Minutes
   TF_H1 = PERIOD_H1,                // 1 Hour
   TF_H4 = PERIOD_H4,                // 4 Hours
   TF_D1 = PERIOD_D1,                // Daily
   TF_W1 = PERIOD_W1,                // Weekly
   TF_MN1 = PERIOD_MN1               // Monthly
  };
input ENUM_TIMEFRAMES_CUSTOM inpTimeFrame_ = TF_CURRENT;
input int HalfLength_            = 55;  //56;
input ENUM_APPLIED_PRICE Price   = PRICE_CLOSE;
input double Deviations          = 2.0;
input bool Interpolate           = true;
input showCHL ShowTMA            = onlyBANDS;
input calcARR CalcArrows         = ArrowsOFF;
input bool AlertsOnHiLo          = false;
input int SIGNALBAR              = 1;
input bool AlertsMessage = false,    //false,
           AlertsSound = false,
           AlertsEmail = false,
           AlertsMobile = false;
input string SoundFile = "alert2.wav"; //"news.wav";
extern string             button_note1          = "------------------------------";
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_LOWER;    // btn_corner
extern string             btn_text              = "B1";
extern string             btn_Font              = "Impact";
extern int                btn_FontSize          = 8;                    //btn__font size
extern color              btn_text_ON_color     = clrWhite;
extern color              btn_text_OFF_color    = clrWhite;
extern color              btn_background_color  = C'41,50,56';
extern color              btn_border_color      = C'41,50,56';
extern int                button_x              = 104;                  //btn__x
extern int                button_y              = 20;                   //btn__y
extern int                btn_Width             = 18;                   //btn__width
extern int                btn_Height            = 20;                   //btn__height
extern string             UniquebuttonId        = "BAND_Current TF";
extern int                btn_Subwindow         = 0;
extern string             button_note2          = "------------------------------";
class VisibilityCotroller
  {
   string            buttonId;
   string            visibilityId;
   bool              show_data;
   bool              recalc;
public:

   void              Init(string id, string indicatorName, string caption, int x, int y)
     {
      recalc = true;
      visibilityId = id + "_visibility";
      double val;
      if(GlobalVariableGet(visibilityId, val))
         show_data = val != 0;
      else
         show_data = true;
      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, caption, btn_Width, btn_Height, "Impact", 8, btn_background_color, btn_border_color, clrWhite);
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, buttonId, OBJPROP_COLOR, btn_text_ON_color);
      ObjectSetInteger(0, buttonId, OBJPROP_BGCOLOR, btn_background_color);
      ObjectSetInteger(0, buttonId, OBJPROP_BORDER_COLOR, btn_border_color);
      ObjectSetInteger(0, buttonId, OBJPROP_XSIZE, btn_Width);
      ObjectSetInteger(0, buttonId, OBJPROP_YSIZE, btn_Height);
      ObjectSetString(0, buttonId, OBJPROP_FONT, btn_Font);
      ObjectSetString(0, buttonId, OBJPROP_TEXT, caption);
      ObjectSetInteger(0, buttonId, OBJPROP_FONTSIZE, btn_FontSize);
      ObjectSetInteger(0, buttonId, OBJPROP_CORNER, btn_corner);
     }

   void              DeInit()
     {
      ObjectDelete(ChartID(), buttonId);
     }

   bool              HandleButtonClicks()
     {
      if(ObjectGetInteger(0, buttonId, OBJPROP_STATE))
        {
         ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
         show_data = !show_data;
         GlobalVariableSet(visibilityId, show_data ? 1.0 : 0.0);
         recalc = true;
         return true;
        }
      return false;
     }

   bool              IsRecalcNeeded()
     {
      return recalc;
     }

   void              ResetRecalc()
     {
      recalc = false;
     }

   bool              IsVisible()
     {
      return show_data;
     }
private:

   void              createButton(string ButtonId, string buttonText, int width, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
     {
      ObjectDelete(0, ButtonId);
      ObjectCreate(0, ButtonId, OBJ_BUTTON, btn_Subwindow, 0, 0);
      ObjectSetInteger(0, ButtonId, OBJPROP_COLOR, txtColor);
      ObjectSetInteger(0, ButtonId, OBJPROP_BGCOLOR, bgColor);
      ObjectSetInteger(0, ButtonId, OBJPROP_BORDER_COLOR, borderColor);
      ObjectSetInteger(0, ButtonId, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, ButtonId, OBJPROP_XDISTANCE, 9999);
      ObjectSetInteger(0, ButtonId, OBJPROP_YDISTANCE, 9999);
      ObjectSetInteger(0, ButtonId, OBJPROP_XSIZE, width);
      ObjectSetInteger(0, ButtonId, OBJPROP_YSIZE, height);
      ObjectSetString(0, ButtonId, OBJPROP_FONT, font);
      ObjectSetString(0, ButtonId, OBJPROP_TEXT, buttonText);
      ObjectSetInteger(0, ButtonId, OBJPROP_FONTSIZE, fontSize);
      ObjectSetInteger(0, ButtonId, OBJPROP_SELECTABLE, 0);
      ObjectSetInteger(0, ButtonId, OBJPROP_CORNER, 2);
      ObjectSetInteger(0, ButtonId, OBJPROP_HIDDEN, 1);
     }
  };
VisibilityCotroller visibility;
double tmBuffer[], upBuffer[], dnBuffer[];
double clrSEL[], clrBUY[];
double arrSEL[], arrBUY[];
double wuBuffer[], wdBuffer[], FLAG[];
string IndikName;
bool calculateTma = false;
bool returnBars = false;
string messageUP, messageDN, sufix;
datetime TimeBar = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES GetNextTimeframe(ENUM_TIMEFRAMES current)
  {
   switch(current)
     {
      case PERIOD_M1:
         return PERIOD_M5;
      case PERIOD_M5:
         return PERIOD_M15;
      case PERIOD_M15:
         return PERIOD_M30;
      case PERIOD_M30:
         return PERIOD_H1;
      case PERIOD_H1:
         return PERIOD_H4;
      case PERIOD_H4:
         return PERIOD_D1;
      case PERIOD_D1:
         return PERIOD_W1;
      case PERIOD_W1:
         return PERIOD_MN1;
      case PERIOD_MN1:
         return PERIOD_MN1;
      default:
         return PERIOD_H1;
     }
  }
int HalfLength;
ENUM_TIMEFRAMES TimeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   visibility.Init(UniquebuttonId, "tma", btn_text, button_x, button_y);
   HalfLength = MathMax(HalfLength_, 1);
   IndikName = WindowExpertName();
   inpTimeFrame_ == TF_NEXT ? TimeFrame_ = GetNextTimeframe((ENUM_TIMEFRAMES)Period()) : TimeFrame_ = (ENUM_TIMEFRAMES)inpTimeFrame_;
   returnBars = TimeFrame_ == -99;
   calculateTma = TimeFrame_ == PERIOD_CURRENT;
   TimeFrame = MathMax(TimeFrame_, _Period);
   IndicatorBuffers(10);
   IndicatorDigits(Digits);
   int TMT = (ShowTMA == 1 || ShowTMA == 3) ? DRAW_LINE : DRAW_NONE;
   SetIndexBuffer(0, tmBuffer);
   SetIndexStyle(0, TMT);
   int BNT = (ShowTMA == 2 || ShowTMA == 3) ? DRAW_LINE : DRAW_NONE;
   SetIndexBuffer(1, upBuffer);
   SetIndexStyle(1, BNT);
   SetIndexBuffer(2, dnBuffer);
   SetIndexStyle(2, BNT);
   SetIndexBuffer(3, arrSEL);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexArrow(3, 234);
   SetIndexBuffer(4, arrBUY);
   SetIndexStyle(4, DRAW_ARROW);
   SetIndexArrow(4, 233);
   SetIndexBuffer(5, clrSEL);
   SetIndexStyle(5, BNT);
   SetIndexBuffer(6, clrBUY);
   SetIndexStyle(6, BNT);
   SetIndexBuffer(7, wuBuffer);
   SetIndexBuffer(8, wdBuffer);
   SetIndexBuffer(9, FLAG);
   for(int i = 0; i <= 10; i++)
     {
      SetIndexEmptyValue(i, 0.0);
      SetIndexDrawBegin(i, HalfLength);
     }
   SetIndexLabel(0, stringMTF(TimeFrame) + ": TMA [" + (string)HalfLength + "]");
   SetIndexLabel(1, "Band UP  +" + DoubleToStr(Deviations, 2));
   SetIndexLabel(2, "Band LO  -" + DoubleToStr(Deviations, 2));
   SetIndexLabel(3, "Arrow SELL  [" + EnumToString(CalcArrows) + "]");
   SetIndexLabel(4, "Arrow BUY   [" + EnumToString(CalcArrows) + "]");
   SetIndexLabel(5, "Hard SELL");
   SetIndexLabel(6, "Weak BUY");
   IndicatorShortName(stringMTF(TimeFrame) + ": TMA+CG 4C [" + (string)HalfLength + "]");
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   visibility.DeInit();
   Comment("");
   return (0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(visibility.HandleButtonClicks())
     {
      start();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   visibility.HandleButtonClicks();
   int CountedBars = IndicatorCounted();
   if(visibility.IsRecalcNeeded())
     {
      if(visibility.IsVisible())
        {
         CountedBars = 0;
        }
      else
        {
         ArrayInitialize(tmBuffer, 0);
         ArrayInitialize(upBuffer, 0);
         ArrayInitialize(dnBuffer, 0);
         ArrayInitialize(arrSEL, 0);
         ArrayInitialize(arrBUY, 0);
         ArrayInitialize(clrSEL, 0);
         ArrayInitialize(clrBUY, 0);
         ArrayInitialize(FLAG, 0);
         ArrayInitialize(wuBuffer, 0);
         ArrayInitialize(wdBuffer, 0);
         visibility.ResetRecalc();
         return 0;
        }
      visibility.ResetRecalc();
     }
   else
      if(!visibility.IsVisible())
        {
         return 0;
        }
   if(CountedBars < 0)
      return (-1);
   if(CountedBars > 0)
      CountedBars--;
   int i, y, x, limit = MathMin(Bars - 1, Bars - CountedBars + HalfLength);
   if(returnBars)
     {
      tmBuffer[0] = limit + 1;
      return (0);
     }
   if(calculateTma)
     {
      calculateTMA(limit);
      return (0);
     }
   if(TimeFrame > _Period)
      limit = MathMax(limit, MathMin(Bars - 1, iCustom(NULL, TimeFrame, IndikName, -99, 0, 0) * TimeFrame / _Period));
   for(i = limit; i >= 0; i--)
     {
      y = iBarShift(NULL, TimeFrame, Time[i]);
      x = y;
      if(i < Bars - 1)
         x = iBarShift(NULL, TimeFrame, Time[i + 1]);
      tmBuffer[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 0, y);
      upBuffer[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 1, y);
      dnBuffer[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 2, y);
      FLAG[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 9, y);
      if(!Interpolate)
        {
         if(x != y)
           {
            arrSEL[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 3, y);
            arrBUY[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 4, y);
           }
         clrSEL[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 5, y);
         clrBUY[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 6, y);
        }
      if(TimeFrame != _Period)
        {
         if(CalcArrows == 1)
            setupARROWS(i);
         setupALERTS(FLAG);
        }
      if(TimeFrame <= _Period || y == iBarShift(NULL, TimeFrame, Time[i - 1]))
         continue;
      if(!Interpolate)
         continue;
      datetime time = iTime(NULL, TimeFrame, y);
      for(int n = 1; i + n < Bars && Time[i + n] >= time; n++)
         continue;
      double factor = 1.0 / n;
      for(int k = 1; k < n; k++)
        {
         tmBuffer[i + k] = k * factor * tmBuffer[i + n] + (1.0 - k * factor) * tmBuffer[i];
         upBuffer[i + k] = k * factor * upBuffer[i + n] + (1.0 - k * factor) * upBuffer[i];
         dnBuffer[i + k] = k * factor * dnBuffer[i + n] + (1.0 - k * factor) * dnBuffer[i];
        }
     }
   if(Interpolate)
     {
      for(i = limit; i >= 0; i--)
        {
         setupCOLOR(i);
         if(CalcArrows == 2)
            setupARROWS(i);
        }
     }
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateTMA(int limit)
  {
   int i, j, k;
   double FullLength = 2.0 * HalfLength + 1.0;
   for(i = limit; i >= 0; i--)
     {
      double sum = (HalfLength + 1) * iMA(NULL, 0, 1, 0, MODE_SMA, Price, i);
      double sumw = (HalfLength + 1);
      for(j = 1, k = HalfLength; j <= HalfLength; j++, k--)
        {
         sum += k * iMA(NULL, 0, 1, 0, MODE_SMA, Price, i + j);
         sumw += k;
         if(j <= i)
           {
            sum += k * iMA(NULL, 0, 1, 0, MODE_SMA, Price, i - j);
            sumw += k;
           }
        }
      tmBuffer[i] = sum / sumw;
      double diff = iMA(NULL, 0, 1, 0, MODE_SMA, Price, i) - tmBuffer[i];
      if(i > (Bars - HalfLength - 1))
         continue;
      if(i == (Bars - HalfLength - 1))
        {
         upBuffer[i] = tmBuffer[i];
         dnBuffer[i] = tmBuffer[i];
         if(diff >= 0)
           {
            wuBuffer[i] = MathPow(diff, 2);
            wdBuffer[i] = 0;
           }
         if(diff < 0)
           {
            wdBuffer[i] = MathPow(diff, 2);
            wuBuffer[i] = 0;
           }
         continue;
        }
      if(diff >= 0)
        {
         wuBuffer[i] = (wuBuffer[i + 1] * (FullLength - 1) + MathPow(diff, 2)) / FullLength;
         wdBuffer[i] = wdBuffer[i + 1] * (FullLength - 1) / FullLength;
        }
      if(diff < 0)
        {
         wdBuffer[i] = (wdBuffer[i + 1] * (FullLength - 1) + MathPow(diff, 2)) / FullLength;
         wuBuffer[i] = wuBuffer[i + 1] * (FullLength - 1) / FullLength;
        }
      upBuffer[i] = tmBuffer[i] + Deviations * MathSqrt(wuBuffer[i]);
      dnBuffer[i] = tmBuffer[i] - Deviations * MathSqrt(wdBuffer[i]);
      FLAG[i] = 0;
      if(AlertsOnHiLo)
        {
         if(High[i] > upBuffer[i] && High[i + 1] < upBuffer[i + 1])
           {
            FLAG[i] = -444;
            sufix = "High";
           }
         if(Low[i] < dnBuffer[i] && Low[i + 1] > dnBuffer[i + 1])
           {
            FLAG[i] = 444;
            sufix = "Low";
           }
        }
      if(!AlertsOnHiLo)
        {
         if(Close[i] > upBuffer[i] && Close[i + 1] < upBuffer[i + 1])
           {
            FLAG[i] = -888;
            sufix = "Close";
           }
         if(Close[i] < dnBuffer[i] && Close[i + 1] > dnBuffer[i + 1])
           {
            FLAG[i] = 888;
            sufix = "Close";
           }
        }
      if(TimeFrame == _Period)
        {
         setupARROWS(i);
         setupALERTS(FLAG);
        }
      if(!Interpolate)
        {
         setupCOLOR(i);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setupCOLOR(int i)
  {
   clrSEL[i] = upBuffer[i];
   clrBUY[i] = dnBuffer[i];
   if(upBuffer[i] > upBuffer[i + 1] && upBuffer[i + 1] > upBuffer[i + 2])
      clrSEL[i + 1] = 0;
   if(dnBuffer[i] > dnBuffer[i + 1] && dnBuffer[i + 1] > dnBuffer[i + 2])
      clrBUY[i + 1] = 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setupARROWS(int i)
  {
   arrSEL[i] = 0;
   arrBUY[i] = 0;
   if(CalcArrows == 1)
     {
      if(High[i + 1] > upBuffer[i + 1] && Close[i + 1] > Open[i + 1] && Close[i] < Open[i])
         arrSEL[i] = High[i] + iATR(NULL, 0, 48, i);
      if(Low[i + 1] < dnBuffer[i + 1] && Close[i + 1] < Open[i + 1] && Close[i] > Open[i])
         arrBUY[i] = Low[i] - iATR(NULL, 0, 48, i);
     }
   if(CalcArrows == 2)
     {
      if(upBuffer[i] < upBuffer[i + 1] && upBuffer[i + 1] > upBuffer[i + 2])
         arrSEL[i] = High[i] + iATR(NULL, 0, 48, i);
      if(dnBuffer[i] > dnBuffer[i + 1] && dnBuffer[i + 1] < dnBuffer[i + 2])
         arrBUY[i] = Low[i] - iATR(NULL, 0, 48, i);
     }
   if(CalcArrows == 3)
     {
      if(Close[i] > upBuffer[i] && Close[i] > Open[i] && (Open[i] < upBuffer[i] || Close[i + 1] < upBuffer[i + 1]))
         arrBUY[i] = Low[i] - iATR(NULL, 0, 48, i);
      if(Close[i] < dnBuffer[i] && Close[i] < Open[i] && (Open[i] > dnBuffer[i] || Close[i + 1] > dnBuffer[i + 1]))
         arrSEL[i] = High[i] + iATR(NULL, 0, 48, i);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setupALERTS(double &flag[])
  {
   if(AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound)
     {
      messageUP = WindowExpertName() + ":  " + _Symbol + ", " + stringMTF(_Period) + "  >>  " + sufix + " touched BandLO  >>  BUY";
      messageDN = WindowExpertName() + ":  " + _Symbol + ", " + stringMTF(_Period) + "  <<  " + sufix + " touched BandUP  <<  SELL";
      if(TimeBar != Time[0] && (flag[SIGNALBAR] == 444 || flag[SIGNALBAR] == 888))
        {
         if(AlertsMessage)
            Alert(messageUP);
         if(AlertsEmail)
            SendMail(_Symbol, messageUP);
         if(AlertsMobile)
            SendNotification(messageUP);
         if(AlertsSound)
            PlaySound(SoundFile);
         TimeBar = Time[0];
        }
      else
         if(TimeBar != Time[0] && (flag[SIGNALBAR] == -444 || flag[SIGNALBAR] == -888))
           {
            if(AlertsMessage)
               Alert(messageDN);
            if(AlertsEmail)
               SendMail(_Symbol, messageDN);
            if(AlertsMobile)
               SendNotification(messageDN);
            if(AlertsSound)
               PlaySound(SoundFile);
            TimeBar = Time[0];
           }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string stringMTF(int perMTF)
  {
   if(perMTF == 0)
      perMTF = _Period;
   if(perMTF == 1)
      return ("M1");
   if(perMTF == 5)
      return ("M5");
   if(perMTF == 15)
      return ("M15");
   if(perMTF == 30)
      return ("M30");
   if(perMTF == 60)
      return ("H1");
   if(perMTF == 240)
      return ("H4");
   if(perMTF == 1440)
      return ("D1");
   if(perMTF == 10080)
      return ("W1");
   if(perMTF == 43200)
      return ("MN1");
   if(perMTF == 2 || 3 || 4 || 6 || 7 || 8 || 9 ||
      10 || 11 || 12 || 13 || 14 || 16 || 17 || 18)
      return ("M" + (string)_Period);
   return ("Ошибка периода");
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        PRICEBAND_MTF_BTN_-_Current_TF_arrow
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160956#p160956
License:     GNU

── Author ──────────────────────────────────────────────────────────────────────

Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com

── Support & Donations ─────────────────────────────────────────────────────────

PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7

── Copyright ───────────────────────────────────────────────────────────────────

© 2025 Gehtsoft USA LLC — https://fxcodebase.com

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
