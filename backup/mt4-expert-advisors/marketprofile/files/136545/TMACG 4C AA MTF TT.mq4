// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70257

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
#property version "1.1"
//---
#property indicator_chart_window
#property indicator_buffers 7
//---
#property indicator_color1 clrSilver     //Gray
#property indicator_color2 clrDarkOrange //Red  //Maroon
#property indicator_color3 clrLime       //DarkBlue
#property indicator_color4 clrGold       //Red
#property indicator_color5 clrAqua       //Blue
#property indicator_color6 clrRed        //DarkOrange
#property indicator_color7 clrDeepSkyBlue
//---
#property indicator_width1 0
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 0
#property indicator_width5 0
#property indicator_width6 2
#property indicator_width7 2
//---
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT
#property indicator_style6 STYLE_DOT
#property indicator_style7 STYLE_DOT
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   ChangeCOLOR
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

input ENUM_TIMEFRAMES TimeFrame_ = PERIOD_CURRENT; // Time frame to use
input int HalfLength_ = 24;                        //56;
input ENUM_APPLIED_PRICE Price = PRICE_WEIGHTED;
input double Deviations = 1.618;
input bool Interpolate = false;
input showCHL ShowTMA = onlyBANDS;
input calcARR CalcArrows = ChangeCOLOR;
input bool AlertsOnHiLo = false;
input int SIGNALBAR = 1;         //На каком баре сигналить....
input bool AlertsMessage = true, //false,
    AlertsSound = true,          //false,
    AlertsEmail = false,
           AlertsMobile = false;
input string SoundFile = "alert2.wav"; //"news.wav";  //"expert.wav";  //   //"stops.wav"   //   //
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double tmBuffer[], upBuffer[], dnBuffer[];
double clrSEL[], clrBUY[];
double arrSEL[], arrBUY[];
double wuBuffer[], wdBuffer[], FLAG[];
//---
string IndikName;
bool calculateTma = false;
bool returnBars = false;
string messageUP, messageDN, sufix;
datetime TimeBar = 0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int HalfLength;
ENUM_TIMEFRAMES TimeFrame;
int init()
{
   visibility.Init("show_hide_tma", "tma", "Show/Hide", button_x, button_y);
   HalfLength = MathMax(HalfLength_, 1);
   IndikName = WindowExpertName();
   returnBars = TimeFrame_ == -99;
   calculateTma = TimeFrame_ == PERIOD_CURRENT;
   TimeFrame = MathMax(TimeFrame_, _Period);
   //---
   IndicatorBuffers(10);
   IndicatorDigits(Digits);
   //---  //enum showCHL { NoLINES, onlyTMA, onlyBANDS, allLINES };
   int TMT = (ShowTMA == 1 || ShowTMA == 3) ? DRAW_LINE : DRAW_NONE;
   SetIndexBuffer(0, tmBuffer);
   SetIndexStyle(0, TMT); //SetIndexDrawBegin(0,HalfLength);
   int BNT = (ShowTMA == 2 || ShowTMA == 3) ? DRAW_LINE : DRAW_NONE;
   SetIndexBuffer(1, upBuffer);
   SetIndexStyle(1, BNT); //SetIndexDrawBegin(1,HalfLength);
   SetIndexBuffer(2, dnBuffer);
   SetIndexStyle(2, BNT); //SetIndexDrawBegin(2,HalfLength);
   SetIndexBuffer(3, arrSEL);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexArrow(3, 234);
   SetIndexBuffer(4, arrBUY);
   SetIndexStyle(4, DRAW_ARROW);
   SetIndexArrow(4, 233);
   SetIndexBuffer(5, clrSEL);
   SetIndexStyle(5, BNT); //SetIndexDrawBegin(5,HalfLength);
   SetIndexBuffer(6, clrBUY);
   SetIndexStyle(6, BNT); //SetIndexDrawBegin(6,HalfLength);
   SetIndexBuffer(7, wuBuffer);
   SetIndexBuffer(8, wdBuffer);
   SetIndexBuffer(9, FLAG);
   //---
   for (int i = 0; i <= 10; i++)
   {
      //SetIndexStyle(i,DRAW_HISTOGRAM);   //--- настройка параметров отрисовки
      SetIndexEmptyValue(i, 0.0); //--- значение 0 отображаться не будет
      //SetIndexShift(11,SlowShift);       //--- установка сдвига линий при отрисовке
      SetIndexDrawBegin(i, HalfLength);
   } //--- пропуск отрисовки первых баров

   //--- отображение в DataWindow
   SetIndexLabel(0, stringMTF(TimeFrame) + ": TMA [" + (string)HalfLength + "]");
   SetIndexLabel(1, "Band UP  +" + DoubleToStr(Deviations, 2));
   SetIndexLabel(2, "Band LO  -" + DoubleToStr(Deviations, 2));
   SetIndexLabel(3, "Arrow SELL  [" + EnumToString(CalcArrows) + "]");
   SetIndexLabel(4, "Arrow BUY   [" + EnumToString(CalcArrows) + "]");
   SetIndexLabel(5, "Hard SELL");
   SetIndexLabel(6, "Weak BUY");

   //--- "короткое имя" для DataWindow и подокна индикатора + и/или "уникальное имя индикатора"
   IndicatorShortName(stringMTF(TimeFrame) + ": TMA+CG 4C [" + (string)HalfLength + "]");
   //---
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
   visibility.HandleButtonClicks();
   int CountedBars = IndicatorCounted();

   if (visibility.IsRecalcNeeded())
   {
      if (visibility.IsVisible())
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
   else if (!visibility.IsVisible())
   {
      return 0;
   }

   if (CountedBars < 0)
      return (-1);
   if (CountedBars > 0)
      CountedBars--;
   int i, y, x, limit = MathMin(Bars - 1, Bars - CountedBars + HalfLength);
   //---
   if (returnBars)
   {
      tmBuffer[0] = limit + 1;
      return (0);
   }
   if (calculateTma)
   {
      calculateTMA(limit);
      return (0);
   }
   if (TimeFrame > _Period)
      limit = MathMax(limit, MathMin(Bars - 1, iCustom(NULL, TimeFrame, IndikName, -99, 0, 0) * TimeFrame / _Period));
   //+------------------------------------------------------------------+
   //+------------------------------------------------------------------+

   for (i = limit; i >= 0; i--)
   {
      y = iBarShift(NULL, TimeFrame, Time[i]);
      x = y;
      if (i < Bars - 1)
         x = iBarShift(NULL, TimeFrame, Time[i + 1]);
      //---
      tmBuffer[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 0, y);
      upBuffer[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 1, y);
      dnBuffer[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 2, y);
      FLAG[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 9, y);
      //---
      if (!Interpolate)
      {
         if (x != y)
         {
            arrSEL[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 3, y);
            arrBUY[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 4, y);
         }
         //---
         clrSEL[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 5, y);
         clrBUY[i] = iCustom(NULL, TimeFrame, IndikName, PERIOD_CURRENT, HalfLength, Price, Deviations, 6, y);
      }
      //---
      //---
      if (TimeFrame != _Period)
      {
         if (CalcArrows == 1)
            setupARROWS(i);
         setupALERTS(FLAG);
      }
      //---
      //---
      if (TimeFrame <= _Period || y == iBarShift(NULL, TimeFrame, Time[i - 1]))
         continue;
      if (!Interpolate)
         continue;
      //---
      datetime time = iTime(NULL, TimeFrame, y);
      for (int n = 1; i + n < Bars && Time[i + n] >= time; n++)
         continue;
      double factor = 1.0 / n;
      for (int k = 1; k < n; k++)
      {
         tmBuffer[i + k] = k * factor * tmBuffer[i + n] + (1.0 - k * factor) * tmBuffer[i];
         upBuffer[i + k] = k * factor * upBuffer[i + n] + (1.0 - k * factor) * upBuffer[i];
         dnBuffer[i + k] = k * factor * dnBuffer[i + n] + (1.0 - k * factor) * dnBuffer[i];
      }
      //+------------------------------------------------------------------+
   } //*конец цикла*  for (i=limit; i>=0; i--)
     //+------------------------------------------------------------------+

   if (Interpolate)
   {
      for (i = limit; i >= 0; i--)
      {
         setupCOLOR(i);
         if (CalcArrows == 2)
            setupARROWS(i);
      }
   }
   //+------------------------------------------------------------------+
   //+------------------------------------------------------------------+
   //---
   return (0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateTMA(int limit)
{
   int i, j, k;
   double FullLength = 2.0 * HalfLength + 1.0;
   //+------------------------------------------------------------------+

   for (i = limit; i >= 0; i--)
   {
      double sum = (HalfLength + 1) * iMA(NULL, 0, 1, 0, MODE_SMA, Price, i);
      double sumw = (HalfLength + 1);
      //---
      for (j = 1, k = HalfLength; j <= HalfLength; j++, k--)
      {
         sum += k * iMA(NULL, 0, 1, 0, MODE_SMA, Price, i + j);
         sumw += k;
         //--
         if (j <= i)
         {
            sum += k * iMA(NULL, 0, 1, 0, MODE_SMA, Price, i - j);
            sumw += k;
         }
      }
      //---
      tmBuffer[i] = sum / sumw;
      //+------------------------------------------------------------------+

      double diff = iMA(NULL, 0, 1, 0, MODE_SMA, Price, i) - tmBuffer[i];
      if (i > (Bars - HalfLength - 1))
         continue;
      if (i == (Bars - HalfLength - 1))
      {
         upBuffer[i] = tmBuffer[i];
         dnBuffer[i] = tmBuffer[i];
         //---
         if (diff >= 0)
         {
            wuBuffer[i] = MathPow(diff, 2);
            wdBuffer[i] = 0;
         }
         //---
         if (diff < 0)
         {
            wdBuffer[i] = MathPow(diff, 2);
            wuBuffer[i] = 0;
         }
         continue;
      }
      //+------------------------------------------------------------------+

      if (diff >= 0)
      {
         wuBuffer[i] = (wuBuffer[i + 1] * (FullLength - 1) + MathPow(diff, 2)) / FullLength;
         wdBuffer[i] = wdBuffer[i + 1] * (FullLength - 1) / FullLength;
      }
      //---
      if (diff < 0)
      {
         wdBuffer[i] = (wdBuffer[i + 1] * (FullLength - 1) + MathPow(diff, 2)) / FullLength;
         wuBuffer[i] = wuBuffer[i + 1] * (FullLength - 1) / FullLength;
      }
      //+------------------------------------------------------------------+

      upBuffer[i] = tmBuffer[i] + Deviations * MathSqrt(wuBuffer[i]);
      dnBuffer[i] = tmBuffer[i] - Deviations * MathSqrt(wdBuffer[i]);
      //+------------------------------------------------------------------+

      FLAG[i] = 0;
      //---
      if (AlertsOnHiLo)
      {
         if (High[i] > upBuffer[i] && High[i + 1] < upBuffer[i + 1])
         {
            FLAG[i] = -444;
            sufix = "High";
         }
         if (Low[i] < dnBuffer[i] && Low[i + 1] > dnBuffer[i + 1])
         {
            FLAG[i] = 444;
            sufix = "Low";
         }
      }
      //---
      if (!AlertsOnHiLo)
      {
         if (Close[i] > upBuffer[i] && Close[i + 1] < upBuffer[i + 1])
         {
            FLAG[i] = -888;
            sufix = "Close";
         }
         if (Close[i] < dnBuffer[i] && Close[i + 1] > dnBuffer[i + 1])
         {
            FLAG[i] = 888;
            sufix = "Close";
         }
      }
      //+------------------------------------------------------------------+

      if (TimeFrame == _Period)
      {
         setupARROWS(i);
         setupALERTS(FLAG);
      }
      if (!Interpolate)
      {
         setupCOLOR(i);
      }
      //+------------------------------------------------------------------+
   } //*конец цикла*
   //+------------------------------------------------------------------+
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setupCOLOR(int i)
{
   clrSEL[i] = upBuffer[i];
   clrBUY[i] = dnBuffer[i];
   //---
   if (upBuffer[i] > upBuffer[i + 1] && upBuffer[i + 1] > upBuffer[i + 2])
      clrSEL[i + 1] = 0;
   if (dnBuffer[i] > dnBuffer[i + 1] && dnBuffer[i + 1] > dnBuffer[i + 2])
      clrBUY[i + 1] = 0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setupARROWS(int i) //enum calcARR { ArrowsOFF, TrendOCLH, ChangeCOLOR };
{
   arrSEL[i] = 0;
   arrBUY[i] = 0;
   //---
   if (CalcArrows == 1)
   {
      if (High[i + 1] > upBuffer[i + 1] && Close[i + 1] > Open[i + 1] && Close[i] < Open[i])
         arrSEL[i] = High[i] + iATR(NULL, 0, 48, i);
      if (Low[i + 1] < dnBuffer[i + 1] && Close[i + 1] < Open[i + 1] && Close[i] > Open[i])
         arrBUY[i] = Low[i] - iATR(NULL, 0, 48, i);
   }
   //---
   if (CalcArrows == 2)
   {
      if (upBuffer[i] < upBuffer[i + 1] && upBuffer[i + 1] > upBuffer[i + 2])
         arrSEL[i] = High[i] + iATR(NULL, 0, 48, i);
      if (dnBuffer[i] > dnBuffer[i + 1] && dnBuffer[i + 1] < dnBuffer[i + 2])
         arrBUY[i] = Low[i] - iATR(NULL, 0, 48, i);
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setupALERTS(double &flag[])
{
   if (AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound)
   {
      messageUP = WindowExpertName() + ":  " + _Symbol + ", " + stringMTF(_Period) + "  >>  " + sufix + " touched BandLO  >>  BUY";
      messageDN = WindowExpertName() + ":  " + _Symbol + ", " + stringMTF(_Period) + "  <<  " + sufix + " touched BandUP  <<  SELL";
      //------
      if (TimeBar != Time[0] && (flag[SIGNALBAR] == 444 || flag[SIGNALBAR] == 888))
      {
         if (AlertsMessage)
            Alert(messageUP);
         if (AlertsEmail)
            SendMail(_Symbol, messageUP);
         if (AlertsMobile)
            SendNotification(messageUP);
         if (AlertsSound)
            PlaySound(SoundFile); //"stops.wav"   //"news.wav"   //"alert2.wav"  //"expert.wav"
         TimeBar = Time[0];
      } //return(0);
        //------
      else if (TimeBar != Time[0] && (flag[SIGNALBAR] == -444 || flag[SIGNALBAR] == -888))
      {
         if (AlertsMessage)
            Alert(messageDN);
         if (AlertsEmail)
            SendMail(_Symbol, messageDN);
         if (AlertsMobile)
            SendNotification(messageDN);
         if (AlertsSound)
            PlaySound(SoundFile); //"stops.wav"   //"news.wav"   //"alert2.wav"  //"expert.wav"
         TimeBar = Time[0];
      } //return(0);
   }    //*конец* Алертов
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string stringMTF(int perMTF)
{
   if (perMTF == 0)
      perMTF = _Period;
   if (perMTF == 1)
      return ("M1");
   if (perMTF == 5)
      return ("M5");
   if (perMTF == 15)
      return ("M15");
   if (perMTF == 30)
      return ("M30");
   if (perMTF == 60)
      return ("H1");
   if (perMTF == 240)
      return ("H4");
   if (perMTF == 1440)
      return ("D1");
   if (perMTF == 10080)
      return ("W1");
   if (perMTF == 43200)
      return ("MN1");
   if (perMTF == 2 || 3 || 4 || 6 || 7 || 8 || 9 || /// нестандартные периоды для грфиков Renko
       10 || 11 || 12 || 13 || 14 || 16 || 17 || 18)
      return ("M" + (string)_Period);
   //------
   return ("Ошибка периода");
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+