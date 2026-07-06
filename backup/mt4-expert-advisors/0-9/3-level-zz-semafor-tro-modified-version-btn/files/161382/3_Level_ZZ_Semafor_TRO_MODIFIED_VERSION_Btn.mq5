/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        3_Level_ZZ_Semafor_TRO_MODIFIED_VERSION_Btn
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=156155#p156155
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

#property strict
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   6
#property indicator_color1 Chocolate
#property indicator_color2 Chocolate
#property indicator_color3 MediumVioletRed
#property indicator_color4 MediumVioletRed
#property indicator_color5 Yellow
#property indicator_color6 Yellow
bool hide = false;
bool runtimeTurnOff = false;
#include <Controls/Button.mqh>
int deinitReason;
CButton bt1;
#define BUTTON1_NAME "On/Off"
int filehandle;
string filename = "setState.csv";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SaveState()
  {
   int handle = FileOpen(filename, FILE_READ | FILE_WRITE | FILE_CSV);
   if(handle == INVALID_HANDLE)
      return;
   FileSeek(handle, 0, SEEK_SET);
   FileWrite(handle, hide);
   FileClose(handle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetState()
  {
   int handle = FileOpen(filename, FILE_READ | FILE_WRITE | FILE_CSV);
   if(handle == INVALID_HANDLE)
     {
      hide = false;
      return;
     }
   hide = FileReadBool(handle);
   FileClose(handle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteState()
  {
   if(FileIsExist(filename))
     {
      FileDelete(filename);
     }
  }
input bool   TURN_OFF = false;
input bool   TrainingWheels     = true ;
input bool   Show_TRO_Mods      = false ;
input bool   Show_Tradelines    = true;
input bool   Show_Diff          = true ;
input bool   Show_Floaters      = false ;
input bool   Show_Legend        = true ;
input bool   Show_Trendlines    = true;
input bool   Show_Retracelines  = true;
input bool   Show_Targetlines   = true;
input bool   Show_Medianline    = true;
input bool   Show_TrendLines3   = true;
input bool   Show_Fiblines      = true;
input bool   Show_Fiblines3     = true;
input bool   Show_Bars          = true ;
input bool   Show_Boxes         = true ;
input bool   Show_Label         = true ;
input int    ShiftLabel         =  10 ;
input bool   Show_SupResLines3  = true;
input int    myTradeLinelevel   = 0 ;
input int    NumTradeLineLines  = 5 ;
input int    mySRlevel          = 1;
input int    NumSRLines         = 5 ;
input bool   DebugLog          = false;
input bool   Sound_Alert    = false ;
input bool   Show_Comment   = false ;
input int win = 0;
input int price_x_offset = 140 ;
input int price_y_offset = 20 ;
input string myFont          = "Impact";
input int   myFontSize       = 20;
input int    myBars         = 100 ;
input int    myThreshold    = 1;
input int    myRetracePips  = 20;
input int    myTargetPips   = 20;
input int    NumComments    = 5 ;
input int    yIncLegend     = 50 ;
input color Buy_color = Lime;
input color Wait_color = Yellow;
input color Sell_color = Red;
input color  myUpperTradeLineColor = Red;
input int    myUpperTradeLineStyle = STYLE_DOT;
input int    myUpperTradeLineWidth = 1;
input color  myLowerTradeLineColor = Blue;
input int    myLowerTradeLineStyle = STYLE_DOT;
input int    myLowerTradeLineWidth = 1;
input color  myUpperTrendLineColor = Red;
input int    myUpperTrendLineStyle = STYLE_SOLID;
input int    myUpperTrendLineWidth = 2;
input string myUpperSoundFile      = "ahooga.wav";
input color  myLowerTrendLineColor = Blue;
input int    myLowerTrendLineStyle = STYLE_SOLID;
input int    myLowerTrendLineWidth = 2;
input string myLowerSoundFile      = "siren.wav";
input color  myRetraceLineColor = Orange;
input int    myRetraceLineStyle = STYLE_DOT;
input int    myRetraceLineWidth = 1;
input color  myTargetLineColor = Magenta;
input int    myTargetLineStyle = STYLE_DOT;
input int    myTargetLineWidth = 1;
input color  myMedianLineColor = Violet;
input int    myMedianLineStyle = STYLE_DOT;
input int    myMedianLineWidth = 1;
input color  myUpperTrendLine3Color = Red;
input int    myUpperTrendLine3Style = STYLE_SOLID;
input int    myUpperTrendLine3Width = 3;
input color  myLowerTrendLine3Color = Blue;
input int    myLowerTrendLine3Style = STYLE_SOLID;
input int    myLowerTrendLine3Width = 3;
input color  myUpperSRColor = Red;
input int    myUpperSRStyle = STYLE_DASH;
input int    myUpperSRWidth = 1;
input color  myLowerSRColor = Blue;
input int    myLowerSRStyle = STYLE_DASH;
input int    myLowerSRWidth = 1;
input double    iLevel1 = 0.24;
input double    iLevel2 = 0.382;
input double    iLevel3 = 0.5;
input double    iLevel4 = 0.618;
input double    iLevel5 = 0.76;
input color Fibcolor1 = DarkSeaGreen ;
input color Fibcolor2 = Khaki ;
input color Fibcolor3 = Gray ;
input color Fibcolor4 = Khaki ;
input color Fibcolor5 = DarkSeaGreen ;
input int    myFibLineStyle = STYLE_DASHDOTDOT;
input int    myFibLineWidth = 1;
input int    myFibLine3Style = STYLE_DASHDOT;
input int    myFibLine3Width = 1;
input double Period1 = 5;
input double Period2 = 13;
input double Period3 = 34;
input string   Dev_Step_1 = "1,3";
input string   Dev_Step_2 = "8,5";
input string   Dev_Step_3 = "13,8";
input int Symbol_1_Kod = 140;
input int Symbol_2_Kod = 141;
input int Symbol_3_Kod = 142;
input int Symbol_1_Size = 1 ;
input int Symbol_2_Size = 2;
input int Symbol_3_Size = 4;
input color Color_1 = clrBrown;
input color Color_2 = clrMediumVioletRed;
input color Color_3 = clrYellow;
input string Tbtn = "== Button  ==";  // ������������
input color on_color = SpringGreen; // ON Color:
input color off_color = Gray; // OFF Color:
double FP_BuferUp[];
double FP_BuferDn[];
double NP_BuferUp[];
double NP_BuferDn[];
double HP_BuferUp[];
double HP_BuferDn[];
double gOpen[], gHigh[], gLow[], gClose[];
datetime gTime[];
int gBars = 0;
double bidPrice = 0.0, askPrice = 0.0;
#define Open gOpen
#define High gHigh
#define Low  gLow
#define Close gClose
#define Time gTime
#define Bars gBars

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DebugPrint(const string msg)
  {
   return;
  }
int F_Period;
int N_Period;
int H_Period;
int Dev1;
int Stp1;
int Dev2;
int Stp2;
int Dev3;
int Stp3;
string symbol, tChartPeriod,  tShortName ;
int    digits, period  ;
bool Trigger1,  Trigger2,  Trigger3 ;
int OldBars = -1 ;
color tColor = Yellow ;
int tltop, tlbot;
string Messages[26], theMessage, space ;
bool roll ;
double pointValue ;
double upperTL1[2], lowerTL1[2], upperTL2[2], lowerTL2[2], upperTL3[2], lowerTL3[2], upperTL[2], lowerTL[2];
double UpperTrendLinePrice, LowerTrendLinePrice, UpperLimit, LowerLimit, xThreshold;
double upperTradeLine, lowerTradeLine ;
double UpperRetracePrice, LowerRetracePrice, xRetracePips ;
double pUpperTargetPrice, pLowerTargetPrice, UpperTargetPrice, LowerTargetPrice, xTargetPips ;
datetime upperTLtime1[2], lowerTLtime1[2], upperTLtime2[2], lowerTLtime2[2], upperTLtime3[2], lowerTLtime3[2], upperTLtime[2], lowerTLtime[2];
datetime upperStime, upperEtime, lowerStime, lowerEtime;
string TAG = "3lzz", OBJ001, OBJ002, OBJ003, OBJ004, OBJ005, OBJ006 ;
string OBJ007, OBJ008 ;
double midpoint, midstart ;
datetime midstarttime ;
datetime upperTL3time[2], lowerTL3time[2]  ;
double upperTL3Max, lowerTL3Min,  UpperTrendLine3Price, LowerTrendLine3Price ;
int    tl1top, tl1bot, tl2top, tl2bot, tl3top, tl3bot;
double upperSR, lowerSR ;
double fibrange, fibvalue[5], fibvalue3[5], FIBLEVEL[5];
color FIBCOLOR[5];
datetime fibstarttime ;
int yIncL ;
string sFib;
int upperTLBars1[2], lowerTLBars1[2], upperTLBars2[2], lowerTLBars2[2], upperTLBars3[2], lowerTLBars3[2], upperTLBars[2], lowerTLBars[2];
double Sema3Diff, Close3Diff;
double  W1_VALUE, D1_VALUE, W1_OPEN, D1_OPEN, lastClose ;
bool    W1_UP, D1_UP, W1_DOWN, D1_DOWN  ;
string TW_MESSAGE;
color  TW_COLOR ;
datetime   TW_TRIGGER ;
int SRlevel, TradeLinelevel ;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
  {
   OnChartEventButtons(id, lparam, dparam, sparam);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInitButtons()
  {
   if(deinitReason != REASON_CHARTCHANGE && deinitReason != REASON_PARAMETERS)
     {
      Create_button(BUTTON1_NAME, 10, 100, 17, 100, bt1);
     }
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Create_button(string name, const int x1, const int y1, const int high, const int width, CButton& bt)
  {
   int x2 = x1 + width;
   int y2 = y1 + high;
   bt.Create(0, name, 0, x1, y1, x2, y2);
   bt.Text("ON");
   bt.Font("Calibri");
   bt.FontSize(8);
   bt.ColorBackground(on_color);
   return true;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEventButtons(const int id, const long& lparam, const double& dparam, const string& sparam)
  {
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == BUTTON1_NAME)
     {
      ActionBt1();
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void BindIndicatorBuffers()
  {
   ArraySetAsSeries(FP_BuferUp, true);
   ArraySetAsSeries(FP_BuferDn, true);
   ArraySetAsSeries(NP_BuferUp, true);
   ArraySetAsSeries(NP_BuferDn, true);
   ArraySetAsSeries(HP_BuferUp, true);
   ArraySetAsSeries(HP_BuferDn, true);
   SetIndexBuffer(0, FP_BuferUp, INDICATOR_DATA);
   SetIndexBuffer(1, FP_BuferDn, INDICATOR_DATA);
   SetIndexBuffer(2, NP_BuferUp, INDICATOR_DATA);
   SetIndexBuffer(3, NP_BuferDn, INDICATOR_DATA);
   SetIndexBuffer(4, HP_BuferUp, INDICATOR_DATA);
   SetIndexBuffer(5, HP_BuferDn, INDICATOR_DATA);
   for(int idx = 0; idx < 6; idx++)
      PlotIndexSetDouble(idx, PLOT_EMPTY_VALUE, 0.0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyArrowStyle(const int idx, const int arrowCode, const int size, const color clr)
  {
   PlotIndexSetInteger(idx, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(idx, PLOT_ARROW, arrowCode);
   PlotIndexSetInteger(idx, PLOT_LINE_WIDTH, size);
   PlotIndexSetInteger(idx, PLOT_LINE_COLOR, clr);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HidePlots()
  {
   for(int iPlot = 0; iPlot < 6; iPlot++)
      PlotIndexSetInteger(iPlot, PLOT_DRAW_TYPE, DRAW_NONE);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ApplyBufferStyles()
  {
   if(Period1 > 0)
     {
      ApplyArrowStyle(0, Symbol_1_Kod, Symbol_1_Size, Color_1);
      ApplyArrowStyle(1, Symbol_1_Kod, Symbol_1_Size, Color_1);
     }
   else
     {
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
     }
   if(Period2 > 0)
     {
      ApplyArrowStyle(2, Symbol_2_Kod, Symbol_2_Size, Color_2);
      ApplyArrowStyle(3, Symbol_2_Kod, Symbol_2_Size, Color_2);
     }
   else
     {
      PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
     }
   if(Period3 > 0)
     {
      ApplyArrowStyle(4, Symbol_3_Kod, Symbol_3_Size, Color_3);
      ApplyArrowStyle(5, Symbol_3_Kod, Symbol_3_Size, Color_3);
     }
   else
     {
      PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_NONE);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setButtonState(bool _hide)
  {
   if(_hide)
     {
      runtimeTurnOff = true;
      HidePlots();
      ObDeleteObjectsByPrefix(TAG);
      bt1.ColorBackground(off_color);
      bt1.Text("OFF");
     }
   else
     {
      runtimeTurnOff = false;
      ApplyBufferStyles();
      bt1.ColorBackground(on_color);
      bt1.Text("ON");
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ActionBt1()
  {
   hide = !hide;
   setButtonState(hide);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(deinitReason != REASON_CHARTCHANGE)
     {
      GetState();
      OnInitButtons();
     }
   runtimeTurnOff = TURN_OFF;
   BindIndicatorBuffers();
   setButtonState(hide);
   period       = Period() ;
   tChartPeriod =  TimeFrameToString(period) ;
   symbol       =  _Symbol ;
   digits       = (int)_Digits ;
   pointValue        =  _Point ;
   if(digits == 5 || digits == 3)
     {
      digits = digits - 1 ;
      pointValue = pointValue * 10 ;
     }
   IndicatorSetInteger(INDICATOR_DIGITS, digits);
   tShortName = "tbb" + symbol + tChartPeriod  ;
   IndicatorSetString(INDICATOR_SHORTNAME, tShortName);
   xThreshold   = myThreshold * pointValue ;
   xRetracePips = myRetracePips * pointValue ;
   xTargetPips = myTargetPips * pointValue ;
   OBJ001       = TAG + "001";
   OBJ002       = TAG + "002";
   OBJ003       = TAG + "003";
   OBJ004       = TAG + "004";
   OBJ005       = TAG + "005";
   OBJ006       = TAG + "006";
   OBJ007       = TAG + "007";
   OBJ008       = TAG + "008";
   FIBLEVEL[0] =     iLevel1 ;
   FIBLEVEL[1] =     iLevel2 ;
   FIBLEVEL[2] =     iLevel3 ;
   FIBLEVEL[3] =     iLevel4 ;
   FIBLEVEL[4] =     iLevel5 ;
   FIBCOLOR[0] =  Fibcolor1  ;
   FIBCOLOR[1] =  Fibcolor2  ;
   FIBCOLOR[2] =  Fibcolor3  ;
   FIBCOLOR[3] =  Fibcolor4  ;
   FIBCOLOR[4] =  Fibcolor5  ;
   if(Period1 > 0)
      F_Period = (int)MathCeil(Period1 * Period());
   else
      F_Period = 0;
   if(Period2 > 0)
      N_Period = (int)MathCeil(Period2 * Period());
   else
      N_Period = 0;
   if(Period3 > 0)
      H_Period = (int)MathCeil(Period3 * Period());
   else
      H_Period = 0;
   ApplyBufferStyles();
   int CDev = 0;
   int CSt = 0;
   int Mass[];
   int C = 0;
   if(IntFromStr(Dev_Step_1, C, Mass) == 1)
     {
      Stp1 = Mass[1];
      Dev1 = Mass[0];
     }
   if(IntFromStr(Dev_Step_2, C, Mass) == 1)
     {
      Stp2 = Mass[1];
      Dev2 = Mass[0];
     }
   if(IntFromStr(Dev_Step_3, C, Mass) == 1)
     {
      Stp3 = Mass[1];
      Dev3 = Mass[0];
     }
   if(myTradeLinelevel != 0)
     {
      TradeLinelevel = myTradeLinelevel ;
     }
   else
      if(period > PERIOD_H1)
        {
         TradeLinelevel = 1 ;
        }
      else
        {
         TradeLinelevel = 2 ;
        }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObDeleteObjectsByPrefix(string Prefix)
  {
   int LL = StringLen(Prefix);
   for(int ii = ObjectsTotal(0) - 1; ii >= 0; ii--)
     {
      string ObjName = ObjectName(0, ii);
      if(StringSubstr(ObjName, 0, LL) != Prefix)
        {
         continue;
        }
      ObjectDelete(0, ObjName);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   deinitReason = reason;
   SaveState();
   if(deinitReason != REASON_CHARTCHANGE && deinitReason != REASON_PARAMETERS)
     {
      bt1.Destroy();
      DeleteState();
     }
   _deinit();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int _deinit()
  {
   ObDeleteObjectsByPrefix(TAG);
   TRO();
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateSeries(const datetime &time[],
                  const double &open[],
                  const double &high[],
                  const double &low[],
                  const double &close[],
                  const int rates_total)
  {
   gBars = rates_total;
   ArrayResize(gTime, rates_total);
   ArrayResize(gOpen, rates_total);
   ArrayResize(gHigh, rates_total);
   ArrayResize(gLow, rates_total);
   ArrayResize(gClose, rates_total);
   ArraySetAsSeries(gTime, true);
   ArraySetAsSeries(gOpen, true);
   ArraySetAsSeries(gHigh, true);
   ArraySetAsSeries(gLow, true);
   ArraySetAsSeries(gClose, true);
   ArrayCopy(gTime, time, 0, 0, rates_total);
   ArrayCopy(gOpen, open, 0, 0, rates_total);
   ArrayCopy(gHigh, high, 0, 0, rates_total);
   ArrayCopy(gLow, low, 0, 0, rates_total);
   ArrayCopy(gClose, close, 0, 0, rates_total);
   if(symbol == "")
      symbol = _Symbol;
   MqlTick tick;
   if(SymbolInfoTick(symbol, tick))
     {
      bidPrice = tick.bid;
      askPrice = tick.ask;
     }
   else
     {
      bidPrice = SymbolInfoDouble(symbol, SYMBOL_BID);
      askPrice = SymbolInfoDouble(symbol, SYMBOL_ASK);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetPriceAtTime(const string name, const datetime when)
  {
   return ObjectGetValueByTime(0, name, when);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   int i, j, k;
   if(rates_total <= 0)
      return(0);
   UpdateSeries(time, open, high, low, close, rates_total);
   _deinit();
   if(runtimeTurnOff)
     {
      OldBars = Bars;
      return(rates_total) ;
     }
   if(DebugLog && Bars != OldBars)
     {
     }
   if(Bars != OldBars)
     {
      Trigger1 = true ;
      Trigger2 = true ;
      Trigger3 = true ;
     }
   if(Period1 > 0)
      CountZZ(FP_BuferUp, FP_BuferDn, (int)Period1, Dev1, Stp1);
   if(Period2 > 0)
      CountZZ(NP_BuferUp, NP_BuferDn, (int)Period2, Dev2, Stp2);
   if(Period3 > 0)
      CountZZ(HP_BuferUp, HP_BuferDn, (int)Period3, Dev3, Stp3);
   if(TrainingWheels)
     {
      lastClose    = iClose(symbol, PERIOD_D1, 0) ;
      D1_OPEN  = iOpen(symbol, PERIOD_D1, 0) ;
      W1_OPEN  = iOpen(symbol, PERIOD_W1, 0) ;
      if(lastClose < D1_OPEN)
        {
         D1_DOWN = true ;
         D1_UP = false ;
        }
      else
        {
         D1_DOWN = false ;
         D1_UP = true ;
        }
      if(lastClose < W1_OPEN)
        {
         W1_DOWN = true ;
         W1_UP = false ;
        }
      else
        {
         W1_DOWN = false ;
         W1_UP = true ;
        }
      while(true)
        {
         if(HP_BuferUp[0] != 0)
           {
            TW_MESSAGE = "3-LONG NEXT BAR";
            TW_COLOR = Buy_color ;
            break;
           }
         if(NP_BuferUp[0] != 0 && W1_UP)
           {
            TW_MESSAGE = "2-LONG NEXT BAR";
            TW_COLOR = Buy_color ;
            break;
           }
         if(FP_BuferUp[0] != 0 && W1_UP && D1_UP)
           {
            TW_MESSAGE = "1-LONG NEXT BAR";
            TW_COLOR = Buy_color ;
            break;
           }
         if(HP_BuferDn[0] != 0)
           {
            TW_MESSAGE = "3-SHORT NEXT BAR";
            TW_COLOR = Sell_color ;
            break;
           }
         if(NP_BuferDn[0] != 0 && W1_DOWN)
           {
            TW_MESSAGE = "2-SHORT NEXT BAR";
            TW_COLOR = Sell_color ;
            break;
           }
         if(FP_BuferDn[0] != 0 && W1_DOWN && D1_DOWN)
           {
            TW_MESSAGE = "1-SHORT NEXT BAR";
            TW_COLOR = Sell_color ;
            break;
           }
         TW_MESSAGE = "WAIT";
         TW_COLOR   = Wait_color ;
         break;
        }
      if(ObjectFind(0, TAG + "tw") < 0)
         ObjectCreate(0, TAG + "tw", OBJ_LABEL, win, 0, 0);
      ObjectSetString(0, TAG + "tw", OBJPROP_TEXT, TW_MESSAGE);
      ObjectSetInteger(0, TAG + "tw", OBJPROP_FONTSIZE, myFontSize);
      ObjectSetString(0, TAG + "tw", OBJPROP_FONT, myFont);
      ObjectSetInteger(0, TAG + "tw", OBJPROP_COLOR, TW_COLOR);
      ObjectSetInteger(0, TAG + "tw", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, TAG + "tw", OBJPROP_XDISTANCE, price_x_offset);
      ObjectSetInteger(0, TAG + "tw", OBJPROP_YDISTANCE, price_y_offset);
      if(Sound_Alert && TW_TRIGGER != Time[0] && TW_MESSAGE != "WAIT")
        {
         TW_TRIGGER = Time[0] ;
         Alert(symbol, " " + TW_MESSAGE) ;
        }
     }
   if(!Show_TRO_Mods)
     {
      OldBars = Bars;
      return(rates_total) ;
     }
   if(DebugLog && Bars != OldBars)
     {
     }
   if(Trigger1)
     {
      if(FP_BuferUp[0] != 0)
        {
         Trigger1 = false ;
         if(Sound_Alert)
           {
            Alert(StringFormat("%s %s Level 1 Lower %s", symbol, tChartPeriod, DoubleToString(Close[0], digits)));
           }
        }
      if(FP_BuferDn[0] != 0)
        {
         Trigger1 = false ;
         if(Sound_Alert)
           {
            Alert(StringFormat("%s %s Level 1 Upper %s", symbol, tChartPeriod, DoubleToString(Close[0], digits)));
           }
        }
     }
   if(Trigger2)
     {
      if(NP_BuferUp[0] != 0)
        {
         Trigger2 = false ;
         if(Sound_Alert)
           {
            Alert(StringFormat("%s %s Level 2 Lower %s", symbol, tChartPeriod, DoubleToString(Close[0], digits)));
           }
        }
      if(NP_BuferDn[0] != 0)
        {
         Trigger2 = false ;
         if(Sound_Alert)
           {
            Alert(StringFormat("%s %s Level 2 Upper %s", symbol, tChartPeriod, DoubleToString(Close[0], digits)));
           }
        }
     }
   if(Trigger3)
     {
      if(HP_BuferUp[0] != 0)
        {
         Trigger3 = false ;
         if(Sound_Alert)
           {
            Alert(StringFormat("%s %s Level 3 Lower %s", symbol, tChartPeriod, DoubleToString(Close[0], digits)));
           }
        }
      if(HP_BuferDn[0] != 0)
        {
         Trigger3 = false ;
         if(Sound_Alert)
           {
            Alert(StringFormat("%s %s Level 3 Upper %s", symbol, tChartPeriod, DoubleToString(Close[0], digits)));
           }
        }
     }
   tl3top = 0 ;
   tl3bot = 0 ;
   tl2top = 0 ;
   tl2bot = 0 ;
   tl1top = 0 ;
   tl1bot = 0 ;
   for(j = 0; j < 1000; j++)
     {
      while(true)
        {
         if(HP_BuferUp[j] != 0 && tl3bot < 2)
           {
            lowerTLBars3[tl3bot] = j ;
            lowerTL3[tl3bot] = HP_BuferUp[j] ;
            tl3bot = tl3bot + 1 ;
            break ;
           }
         if(HP_BuferDn[j] != 0 && tl3top < 2)
           {
            upperTLBars3[tl3top] = j ;
            upperTL3[tl3top] = HP_BuferDn[j] ;
            tl3top = tl3top + 1 ;
            break ;
           }
         if(NP_BuferUp[j] != 0 && tl2bot < 2)
           {
            lowerTLBars2[tl2bot] = j ;
            lowerTL2[tl2bot] = NP_BuferUp[j] ;
            tl2bot = tl2bot + 1 ;
            break ;
           }
         if(NP_BuferDn[j] != 0 && tl2top < 2)
           {
            upperTLBars2[tl2top] = j ;
            upperTL2[tl2top] = NP_BuferDn[j] ;
            tl2top = tl2top + 1 ;
            break ;
           }
         if(FP_BuferUp[j] != 0 && tl1bot < 2)
           {
            lowerTLBars1[tl1bot] = j ;
            lowerTL1[tl1bot] = FP_BuferUp[j] ;
            tl1bot = tl1bot + 1 ;
            break ;
           }
         if(FP_BuferDn[j] != 0 && tl1top < 2)
           {
            upperTLBars1[tl1top] = j ;
            upperTL1[tl1top] = FP_BuferDn[j] ;
            tl1top = tl1top + 1 ;
            break ;
           }
         break ;
        }
      if(tl3bot >= 2 && tl3top >= 2 && tl2bot >= 2 && tl2top >= 2  && tl1bot >= 2 && tl1top >= 2)
        {
         break ;
        }
     }
   if(Show_Comment)
     {
      k = 0 ;
      theMessage = "";
      for(i = 0; i < 26; i++)
        {
         Messages[i] = "" ;
        }
      for(j = myBars; j >= 0; j--)
        {
         while(true)
           {
            if(HP_BuferUp[j] != 0)
              {
               DoRollMsg(TimeToString(Time[j]) + " bot 3 ") ;
               break ;
              }
            if(HP_BuferDn[j] != 0)
              {
               DoRollMsg(TimeToString(Time[j]) + " top 3 ") ;
               break ;
              }
            if(NP_BuferUp[j] != 0)
              {
               DoRollMsg(TimeToString(Time[j]) + " bot 2 ") ;
               break ;
              }
            if(NP_BuferDn[j] != 0)
              {
               DoRollMsg(TimeToString(Time[j]) + " top 2 ") ;
               break ;
              }
            if(FP_BuferUp[j] != 0)
              {
               DoRollMsg(TimeToString(Time[j]) + " bot 1 ") ;
               break ;
              }
            if(FP_BuferDn[j] != 0)
              {
               DoRollMsg(TimeToString(Time[j]) + " top 1 ") ;
               break ;
              }
            break ;
           }
        }
      for(i = 0; i < NumComments; i++)
        {
         if(Messages[i] != "")
           {
            theMessage = theMessage + "\n" + Messages[i] ;
           }
         else
           {
            break ;
           }
        }
      Comment(theMessage) ;
     }
   if(Show_TrendLines3)
     {
      tl3top = 0 ;
      tl3bot = 0 ;
      for(j = 0; j < 1000; j++)
        {
         while(true)
           {
            if(HP_BuferUp[j] != 0 && tl3bot < 2)
              {
               lowerTL3time[tl3bot] = Time[j] ;
               lowerTL3[tl3bot] = HP_BuferUp[j] ;
               tl3bot = tl3bot + 1 ;
               break ;
              }
            if(HP_BuferDn[j] != 0 && tl3top < 2)
              {
               upperTL3time[tl3top] = Time[j] ;
               upperTL3[tl3top] = HP_BuferDn[j] ;
               tl3top = tl3top + 1 ;
               break ;
              }
            break ;
           }
         if(tl3bot >= 2 && tl3top >= 2)
           {
            break ;
           }
        }
      DrawPriceTrendLines(OBJ001 + "3", upperTL3time[1], upperTL3time[0], upperTL3[1],
                          upperTL3[0], myUpperTrendLine3Color, myUpperTrendLine3Style, myUpperTrendLine3Width) ;
      DrawPriceTrendLines(OBJ002 + "3", lowerTL3time[1], lowerTL3time[0], lowerTL3[1],
                          lowerTL3[0], myLowerTrendLine3Color, myLowerTrendLine3Style, myLowerTrendLine3Width) ;
      DrawPriceTrendLines(OBJ003 + "3", upperTL3time[0], Time[0], upperTL3[0],
                          upperTL3[0], myUpperTrendLine3Color, myUpperTrendLine3Style, myUpperTrendLine3Width) ;
      DrawPriceTrendLines(OBJ004 + "3", lowerTL3time[0], Time[0], lowerTL3[0],
                          lowerTL3[0], myLowerTrendLine3Color, myLowerTrendLine3Style, myLowerTrendLine3Width) ;
      if(lowerTL3time[0] < upperTL3time[0])
        {
         Close3Diff = upperTL3[0] - Close[0] ;
        }
      else
        {
         Close3Diff = Close[0] - lowerTL3[0] ;
        }
      Sema3Diff = upperTL3[0] - lowerTL3[0] ;
     }
   if(Show_Tradelines)
     {
      tl3top = 0 ;
      tl3bot = 0 ;
      for(j = 0; j < 1000; j++)
        {
         if(myTradeLinelevel == 3)
           {
            upperTradeLine = HP_BuferUp[j] ;
            lowerTradeLine = HP_BuferDn[j] ;
           }
         else
            if(myTradeLinelevel == 2)
              {
               upperTradeLine = NP_BuferUp[j] ;
               lowerTradeLine = NP_BuferDn[j] ;
              }
            else
              { upperTradeLine = FP_BuferUp[j] ; lowerTradeLine = FP_BuferDn[j] ; }
         if(upperTradeLine != 0 && tl3bot < NumTradeLineLines)
           {
            tl3bot = tl3bot + 1 ;
            if(Close[j] >= Open[j])
              {
               upperTradeLine = Open[j] ;
              }
            else
              {
               upperTradeLine = Close[j] ;
              }
            DrawPriceTradeLines(StringFormat("%sTRL%d", OBJ003, j), Time[j], Time[0], upperTradeLine,
                                upperTradeLine, myLowerTradeLineColor, myLowerTradeLineStyle, myLowerTradeLineWidth) ;
           }
         if(lowerTradeLine != 0 && tl3top < NumTradeLineLines)
           {
            tl3top = tl3top + 1 ;
            if(Close[j] <= Open[j])
              {
               lowerTradeLine = Open[j] ;
              }
            else
              {
               lowerTradeLine = Close[j] ;
              }
            DrawPriceTradeLines(StringFormat("%sTRL%d", OBJ004, j), Time[j], Time[0], lowerTradeLine,
                                lowerTradeLine, myUpperTradeLineColor, myUpperTradeLineStyle, myUpperTradeLineWidth) ;
           }
         if(tl3bot >= NumTradeLineLines && tl3top >= NumTradeLineLines)
           {
            break ;
           }
        }
     }
   if(Show_Trendlines)
     {
      tltop = 0 ;
      tlbot = 0 ;
      for(j = 0; j < 1000; j++)
        {
         while(true)
           {
            if(HP_BuferUp[j] != 0 && tlbot < 2)
              {
               lowerTLtime[tlbot] = Time[j] ;
               lowerTL[tlbot] = HP_BuferUp[j] ;
               tlbot = tlbot + 1 ;
               break ;
              }
            if(HP_BuferDn[j] != 0 && tltop < 2)
              {
               upperTLtime[tltop] = Time[j] ;
               upperTL[tltop] = HP_BuferDn[j] ;
               tltop = tltop + 1 ;
               break ;
              }
            if(NP_BuferUp[j] != 0 && tlbot < 2)
              {
               lowerTLtime[tlbot] = Time[j] ;
               lowerTL[tlbot] = NP_BuferUp[j] ;
               tlbot = tlbot + 1 ;
               break ;
              }
            if(NP_BuferDn[j] != 0 && tltop < 2)
              {
               upperTLtime[tltop] = Time[j] ;
               upperTL[tltop] = NP_BuferDn[j] ;
               tltop = tltop + 1 ;
               break ;
              }
            if(FP_BuferUp[j] != 0 && tlbot < 2)
              {
               lowerTLtime[tlbot] = Time[j] ;
               lowerTL[tlbot] = FP_BuferUp[j] ;
               tlbot = tlbot + 1 ;
               break ;
              }
            if(FP_BuferDn[j] != 0 && tltop < 2)
              {
               upperTLtime[tltop] = Time[j] ;
               upperTL[tltop] = FP_BuferDn[j] ;
               tltop = tltop + 1 ;
               break ;
              }
            break ;
           }
         if(tlbot >= 2 && tltop >= 2)
           {
            break ;
           }
        }
      DrawPriceTrendLines(OBJ001, upperTLtime[1], upperTLtime[0], upperTL[1],
                          upperTL[0], myUpperTrendLineColor, myUpperTrendLineStyle, myUpperTrendLineWidth) ;
      DrawPriceTrendLines(OBJ002, lowerTLtime[1], lowerTLtime[0], lowerTL[1],
                          lowerTL[0], myLowerTrendLineColor, myLowerTrendLineStyle, myLowerTrendLineWidth) ;
      DrawPriceTrendLines(OBJ003, upperTLtime[0], Time[0], upperTL[0],
                          upperTL[0], myUpperTrendLineColor, myUpperTrendLineStyle, myUpperTrendLineWidth) ;
      DrawPriceTrendLines(OBJ004, lowerTLtime[0], Time[0], lowerTL[0],
                          lowerTL[0], myLowerTrendLineColor, myLowerTrendLineStyle, myLowerTrendLineWidth) ;
      if(Show_Medianline)
        {
         midpoint = MathAbs(upperTL[0] + lowerTL[0]) * 0.50 ;
         for(j = 0; j < 1000; j++)
           {
            if(Time[j] > upperTLtime[0] && Time[j] > lowerTLtime[0])
              {
               continue ;
              }
            if(midpoint < High[j] && midpoint > Low[j])
              {
               break ;
              }
           }
         if(lowerTLtime[1] > upperTLtime[1])
           {
            midstarttime = lowerTLtime[1] ;
            midstart = lowerTL[1] ;
           }
         else
           {
            midstarttime = upperTLtime[1] ;
            midstart = upperTL[1] ;
           }
         DrawPriceTrendLines(OBJ004 + "pf", midstarttime, Time[j], midstart,
                             midpoint,  myMedianLineColor, myMedianLineStyle, myMedianLineWidth) ;
        }
      if(Show_Retracelines)
        {
         UpperRetracePrice = upperTL[0] - xRetracePips ;
         LowerRetracePrice = lowerTL[0] + xRetracePips ;
         DrawPriceTrendLines(OBJ005, upperTLtime[0], Time[0], UpperRetracePrice,
                             UpperRetracePrice, myRetraceLineColor, myRetraceLineStyle, myRetraceLineWidth) ;
         DrawPriceTrendLines(OBJ006, lowerTLtime[0], Time[0], LowerRetracePrice,
                             LowerRetracePrice, myRetraceLineColor, myRetraceLineStyle, myRetraceLineWidth) ;
        }
      if(Show_Targetlines)
        {
         pUpperTargetPrice = UpperTargetPrice ;
         pLowerTargetPrice = LowerTargetPrice ;
         UpperTargetPrice = upperTL[0] + xTargetPips ;
         LowerTargetPrice = lowerTL[0] - xTargetPips ;
         DrawPriceTrendLines(OBJ007, upperTLtime[0], Time[0], pUpperTargetPrice,
                             pUpperTargetPrice, myTargetLineColor, myTargetLineStyle, myTargetLineWidth) ;
         DrawPriceTrendLines(OBJ008, lowerTLtime[0], Time[0], pLowerTargetPrice,
                             pLowerTargetPrice, myTargetLineColor, myTargetLineStyle, myTargetLineWidth) ;
        }
      UpperTrendLinePrice = GetPriceAtTime(OBJ001, Time[0]);
      LowerTrendLinePrice = GetPriceAtTime(OBJ002, Time[0]);
      UpperLimit = askPrice + xThreshold ;
      LowerLimit = bidPrice - xThreshold ;
      if(Sound_Alert)
        {
         if(UpperTrendLinePrice >= LowerLimit && UpperTrendLinePrice <= UpperLimit)
           {
            PlaySound(myUpperSoundFile);
           }
         if(LowerTrendLinePrice >= LowerLimit && LowerTrendLinePrice <= UpperLimit)
           {
            PlaySound(myLowerSoundFile);
           }
         if(upperTL[0] >= LowerLimit && upperTL[0] <= UpperLimit)
           {
            PlaySound(myUpperSoundFile);
           }
         if(lowerTL[0] >= LowerLimit && lowerTL[0] <= UpperLimit)
           {
            PlaySound(myLowerSoundFile);
           }
        }
     }
   if(Show_SupResLines3)
     {
      tl3top = 0 ;
      tl3bot = 0 ;
      for(j = 0; j < 1000; j++)
        {
         if(mySRlevel == 3)
           {
            upperSR = HP_BuferUp[j] ;
            lowerSR = HP_BuferDn[j] ;
           }
         else
            if(mySRlevel == 2)
              {
               upperSR = NP_BuferUp[j] ;
               lowerSR = NP_BuferDn[j] ;
              }
            else
              { upperSR = FP_BuferUp[j] ; lowerSR = FP_BuferDn[j] ; }
         if(upperSR != 0 && tl3bot < NumSRLines)
           {
            tl3bot = tl3bot + 1 ;
            DrawPriceTrendLines(StringFormat("%sSR%d", OBJ003, j), Time[j], Time[0], upperSR,
                                upperSR, myLowerSRColor, myLowerSRStyle, myLowerSRWidth) ;
           }
         if(lowerSR != 0 && tl3top < NumSRLines)
           {
            tl3top = tl3top + 1 ;
            DrawPriceTrendLines(StringFormat("%sSR%d", OBJ004, j), Time[j], Time[0], lowerSR,
                                lowerSR, myUpperSRColor, myUpperSRStyle, myUpperSRWidth) ;
           }
         if(tl3bot >= NumSRLines && tl3top >= NumSRLines)
           {
            break ;
           }
        }
     }
   if(Show_Fiblines)
     {
      tltop = 0 ;
      tlbot = 0 ;
      for(j = 0; j < 1000; j++)
        {
         while(true)
           {
            if(HP_BuferUp[j] != 0 && tlbot < 1)
              {
               lowerTLtime[tlbot] = Time[j] ;
               lowerTL[tlbot] = HP_BuferUp[j] ;
               tlbot = tlbot + 1 ;
               break ;
              }
            if(HP_BuferDn[j] != 0 && tltop < 1)
              {
               upperTLtime[tltop] = Time[j] ;
               upperTL[tltop] = HP_BuferDn[j] ;
               tltop = tltop + 1 ;
               break ;
              }
            if(NP_BuferUp[j] != 0 && tlbot < 1)
              {
               lowerTLtime[tlbot] = Time[j] ;
               lowerTL[tlbot] = NP_BuferUp[j] ;
               tlbot = tlbot + 1 ;
               break ;
              }
            if(NP_BuferDn[j] != 0 && tltop < 1)
              {
               upperTLtime[tltop] = Time[j] ;
               upperTL[tltop] = NP_BuferDn[j] ;
               tltop = tltop + 1 ;
               break ;
              }
            if(FP_BuferUp[j] != 0 && tlbot < 1)
              {
               lowerTLtime[tlbot] = Time[j] ;
               lowerTL[tlbot] = FP_BuferUp[j] ;
               tlbot = tlbot + 1 ;
               break ;
              }
            if(FP_BuferDn[j] != 0 && tltop < 1)
              {
               upperTLtime[tltop] = Time[j] ;
               upperTL[tltop] = FP_BuferDn[j] ;
               tltop = tltop + 1 ;
               break ;
              }
            break ;
           }
         if(tlbot >= 1 && tltop >= 1)
           {
            break ;
           }
        }
      fibstarttime = MathMin(upperTLtime[0], lowerTLtime[0]) ;
      fibrange     = upperTL[0] - lowerTL[0] ;
      for(j = 0; j < 5; j++)
        {
         fibvalue[j] = lowerTL[0] + (fibrange * FIBLEVEL[j]);
         fibvalue[j] = NormalizeDouble(fibvalue[j], digits);
         DrawPriceTrendLines(StringFormat("%sFIB%d", OBJ003, j), fibstarttime, Time[0], fibvalue[j],
                             fibvalue[j], FIBCOLOR[j], myFibLineStyle, myFibLineWidth) ;
        }
     }
   if(Show_Fiblines3)
     {
      tltop = 0 ;
      tlbot = 0 ;
      for(j = 0; j < 1000; j++)
        {
         while(true)
           {
            if(HP_BuferUp[j] != 0 && tlbot < 1)
              {
               lowerTLtime[tlbot] = Time[j] ;
               lowerTL[tlbot] = HP_BuferUp[j] ;
               tlbot = tlbot + 1 ;
               break ;
              }
            if(HP_BuferDn[j] != 0 && tltop < 1)
              {
               upperTLtime[tltop] = Time[j] ;
               upperTL[tltop] = HP_BuferDn[j] ;
               tltop = tltop + 1 ;
               break ;
              }
            break ;
           }
         if(tlbot >= 1 && tltop >= 1)
           {
            break ;
           }
        }
      fibstarttime = MathMin(upperTLtime[0], lowerTLtime[0]) ;
      fibrange     = upperTL[0] - lowerTL[0] ;
      for(j = 0; j < 5; j++)
        {
         fibvalue3[j] = lowerTL[0] + (fibrange * FIBLEVEL[j]);
         fibvalue3[j] = NormalizeDouble(fibvalue3[j], digits);
         DrawPriceTrendLines(StringFormat("%sFIB3%d", OBJ003, j), fibstarttime, Time[0], fibvalue3[j],
                             fibvalue3[j], FIBCOLOR[j], myFibLine3Style, myFibLine3Width) ;
        }
     }
   if(Show_Legend)
     {
      DoShowLegend() ;
     }
   OldBars = Bars ;
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TimeFrameToString(int tf)
  {
   string tfs;
   switch(tf)
     {
      case PERIOD_M1:
         tfs = "M1"  ;
         break;
      case PERIOD_M5:
         tfs = "M5"  ;
         break;
      case PERIOD_M15:
         tfs = "M15" ;
         break;
      case PERIOD_M30:
         tfs = "M30" ;
         break;
      case PERIOD_H1:
         tfs = "H1"  ;
         break;
      case PERIOD_H4:
         tfs = "H4"  ;
         break;
      case PERIOD_D1:
         tfs = "D1"  ;
         break;
      case PERIOD_W1:
         tfs = "W1"  ;
         break;
      case PERIOD_MN1:
         tfs = "MN";
     }
   return(tfs);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountZZ(double& ExtMapBuffer[], double& ExtMapBuffer2[], int ExtDepth, int ExtDeviation, int ExtBackstep)
  {
   int    shift, back, lasthighpos, lastlowpos;
   double val, res;
   double curlow, curhigh, lasthigh = 0.0, lastlow = 0.0;
   for(shift = Bars - ExtDepth; shift >= 0; shift--)
     {
      int lowIndex = iLowest(symbol, (ENUM_TIMEFRAMES)period, MODE_LOW, ExtDepth, shift);
      val = Low[lowIndex];
      if(val == lastlow)
         val = 0.0;
      else
        {
         lastlow = val;
         if((Low[shift] - val) > (ExtDeviation * pointValue))
            val = 0.0;
         else
           {
            for(back = 1; back <= ExtBackstep; back++)
              {
               res = ExtMapBuffer[shift + back];
               if((res != 0) && (res > val))
                  ExtMapBuffer[shift + back] = 0.0;
              }
           }
        }
      ExtMapBuffer[shift] = val;
      int highIndex = iHighest(symbol, (ENUM_TIMEFRAMES)period, MODE_HIGH, ExtDepth, shift);
      val = High[highIndex];
      if(val == lasthigh)
         val = 0.0;
      else
        {
         lasthigh = val;
         if((val - High[shift]) > (ExtDeviation * pointValue))
            val = 0.0;
         else
           {
            for(back = 1; back <= ExtBackstep; back++)
              {
               res = ExtMapBuffer2[shift + back];
               if((res != 0) && (res < val))
                  ExtMapBuffer2[shift + back] = 0.0;
              }
           }
        }
      ExtMapBuffer2[shift] = val;
     }
   lasthigh = -1;
   lasthighpos = -1;
   lastlow = -1;
   lastlowpos = -1;
   for(shift = Bars - ExtDepth; shift >= 0; shift--)
     {
      curlow = ExtMapBuffer[shift];
      curhigh = ExtMapBuffer2[shift];
      if((curlow == 0) && (curhigh == 0))
         continue;
      if(curhigh != 0)
        {
         if(lasthigh > 0)
           {
            if(lasthigh < curhigh)
               ExtMapBuffer2[lasthighpos] = 0;
            else
               ExtMapBuffer2[shift] = 0;
           }
         if(lasthigh < curhigh || lasthigh < 0)
           {
            lasthigh = curhigh;
            lasthighpos = shift;
           }
         lastlow = -1;
        }
      if(curlow != 0)
        {
         if(lastlow > 0)
           {
            if(lastlow > curlow)
               ExtMapBuffer[lastlowpos] = 0;
            else
               ExtMapBuffer[shift] = 0;
           }
         if((curlow < lastlow) || (lastlow < 0))
           {
            lastlow = curlow;
            lastlowpos = shift;
           }
         lasthigh = -1;
        }
     }
   for(shift = Bars - 1; shift >= 0; shift--)
     {
      if(shift >= Bars - ExtDepth)
         ExtMapBuffer[shift] = 0.0;
      else
        {
         res = ExtMapBuffer2[shift];
         if(res != 0.0)
            ExtMapBuffer2[shift] = res;
        }
     }
   if(!Show_Floaters)
     {
      for(shift = Bars - 1; shift >= 0; shift--)
        {
         if(ExtMapBuffer2[shift] > High[shift])
           {
            ExtMapBuffer2[shift] = 0.0;
           }
         if(ExtMapBuffer[shift]  < Low[shift])
           {
            ExtMapBuffer[shift]  = 0.0;
           }
        }
     }
   return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Str2Massive(string VStr, int& M_Count, int& VMass[])
  {
   long val = StringToInteger(VStr);
   if(val > 0)
     {
      M_Count++;
      int mc = ArrayResize(VMass, M_Count);
      if(mc == 0)
         return(-1);
      VMass[M_Count - 1] = (int)val;
      return(1);
     }
   else
      return(0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int IntFromStr(string ValStr, int& M_Count, int& VMass[])
  {
   if(StringLen(ValStr) == 0)
      return(-1);
   string SS = ValStr;
   int NP = 0;
   string CS;
   M_Count = 0;
   ArrayResize(VMass, M_Count);
   while(StringLen(SS) > 0)
     {
      NP = StringFind(SS, ",");
      if(NP > 0)
        {
         CS = StringSubstr(SS, 0, NP);
         SS = StringSubstr(SS, NP + 1, StringLen(SS));
        }
      else
        {
         if(StringLen(SS) > 0)
           {
            CS = SS;
            SS = "";
           }
        }
      if(Str2Massive(CS, M_Count, VMass) == 0)
        {
         return(-2);
        }
     }
   return(1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string fFill(string filled, int f)
  {
   string FILLED ;
   FILLED = StringSubstr(filled + "                                         ", 0, f) ;
   return(FILLED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DoRollMsg(string msg)
  {
   if(msg != "")
     {
      roll = true ;
      for(int m = 23; m >= 0 ; m--)
        {
         Messages[m + 1] = Messages[m];
        }
      Messages[0] = fFill(msg, 30) ;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceTrendLines(string objname, datetime x1, datetime x2, double y1,
                         double y2, color lineColor, int style, int width)
  {
   ObjectDelete(0, objname);
   ObjectCreate(0, objname, OBJ_TREND, 0, x1, y1, x2, y2);
   ObjectSetInteger(0, objname, OBJPROP_RAY, false);
   ObjectSetInteger(0, objname, OBJPROP_COLOR, lineColor);
   ObjectSetInteger(0, objname, OBJPROP_STYLE, style);
   ObjectSetInteger(0, objname, OBJPROP_WIDTH, width);
   if(Show_Boxes)
     {
      string dName = objname + "boxes" ;
      if(ObjectFind(0, dName) < 0)
        {
         ObjectCreate(0, dName, OBJ_ARROW, 0, Time[0], y1);
        }
      ObjectSetInteger(0, dName, OBJPROP_ARROWCODE, 221);
      ObjectSetInteger(0, dName, OBJPROP_COLOR, lineColor);
      ObjectMove(0, dName, 0, Time[0], y1);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceTradeLines(string objname, datetime x1, datetime x2, double y1,
                         double y2, color lineColor, int style, int width)
  {
   ObjectDelete(0, objname);
   ObjectCreate(0, objname, OBJ_TREND, 0, x1, y1, x2, y2);
   ObjectSetInteger(0, objname, OBJPROP_RAY, false);
   ObjectSetInteger(0, objname, OBJPROP_COLOR, lineColor);
   ObjectSetInteger(0, objname, OBJPROP_STYLE, style);
   ObjectSetInteger(0, objname, OBJPROP_WIDTH, width);
   if(Show_Boxes)
     {
      string dName = objname + "boxes" ;
      if(ObjectFind(0, dName) < 0)
        {
         ObjectCreate(0, dName, OBJ_ARROW, 0, Time[0], y1);
        }
      ObjectSetInteger(0, dName, OBJPROP_ARROWCODE, 221);
      ObjectSetInteger(0, dName, OBJPROP_COLOR, lineColor);
      ObjectMove(0, dName, 0, Time[0], y1);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DoShowLegend()
  {
   yIncL = 0;
   if(Show_Trendlines)
     {
      setObject(TAG + "ut", StringFormat("Upper Target  %s", DoubleToString(pUpperTargetPrice, digits)), 30, yIncLegend, myTargetLineColor);
      setObject(TAG + "ut1", "l", 10, yIncLegend, myTargetLineColor, "Wingdings");
      yIncL += 20;
      setObject(TAG + "us", StringFormat("Upper Semafor %s", DoubleToString(upperTL[0], digits)), 30, yIncLegend + yIncL, myUpperTrendLineColor);
      setObject(TAG + "us1", "l", 10, yIncLegend + yIncL, myUpperTrendLineColor, "Wingdings");
      yIncL += 20;
      setObject(TAG + "ur", StringFormat("Upper Retrace %s", DoubleToString(UpperRetracePrice, digits)), 30, yIncLegend + yIncL, myRetraceLineColor);
      setObject(TAG + "ur1", "l", 10, yIncLegend + yIncL, myRetraceLineColor, "Wingdings");
      yIncL += 20;
      setObject(TAG + "lr", StringFormat("Lower Retrace %s", DoubleToString(LowerRetracePrice, digits)), 30, yIncLegend + yIncL, myRetraceLineColor);
      setObject(TAG + "lr1", "l", 10, yIncLegend + yIncL, myRetraceLineColor, "Wingdings");
      yIncL += 20;
      setObject(TAG + "ls", StringFormat("Lower Semafor %s", DoubleToString(lowerTL[0], digits)), 30, yIncLegend + yIncL, myLowerTrendLineColor);
      setObject(TAG + "ls1", "l", 10, yIncLegend + yIncL, myLowerTrendLineColor, "Wingdings");
      yIncL += 20;
      setObject(TAG + "lt", StringFormat("Lower Target  %s", DoubleToString(pLowerTargetPrice, digits)), 30, yIncLegend + yIncL, myTargetLineColor);
      setObject(TAG + "lt1", "l", 10, yIncLegend + yIncL, myTargetLineColor, "Wingdings");
      yIncL += 20;
      setObject(TAG + "ml", StringFormat("Median Line   %s", DoubleToString(midpoint, digits)), 30, yIncLegend + yIncL, myMedianLineColor);
      setObject(TAG + "ml1", "l", 10, yIncLegend + yIncL, myMedianLineColor, "Wingdings");
     }
   if(Show_Fiblines3)
     {
      int j;
      yIncL += 20;
      for(j = 4; j >= 0; j--)
        {
         yIncL += 20;
         sFib  = DoubleToString(FIBLEVEL[j] * 100, 1) + "%    " ;
         setObject(StringFormat("%sFib3.%d", TAG, j), StringFormat("Fib3 %s%s", sFib, DoubleToString(fibvalue3[j], digits)), 30, yIncLegend + yIncL, FIBCOLOR[j]);
         setObject(StringFormat("%sfib31.%d", TAG, j), "l", 10, yIncLegend + yIncL, FIBCOLOR[j], "Wingdings");
        }
     }
   if(Show_Fiblines)
     {
      int j;
      yIncL += 20;
      for(j = 4; j >= 0; j--)
        {
         yIncL += 20;
         sFib  = DoubleToString(FIBLEVEL[j] * 100, 1) + "%     " ;
         setObject(StringFormat("%sFib%d", TAG, j), StringFormat("Fib %s%s", sFib, DoubleToString(fibvalue[j], digits)), 30, yIncLegend + yIncL, FIBCOLOR[j]);
         setObject(StringFormat("%sfib1%d", TAG, j), "l", 10, yIncLegend + yIncL, FIBCOLOR[j], "Wingdings");
        }
     }
   if(Show_Bars)
     {
      yIncL += 40;
      setObject(TAG + "sem3u", StringFormat("Upper Semafor %s[%d]", DoubleToString(upperTL3[0], digits), upperTLBars3[0]), 30, yIncLegend + yIncL, Color_3);
      setObject(TAG + "sem3u1", CharToString((uchar)Symbol_3_Kod), 10, yIncLegend + yIncL, Color_3, "Wingdings");
      yIncL += 20;
      setObject(TAG + "sem3l", StringFormat("Lower Semafor %s[%d]", DoubleToString(lowerTL3[0], digits), lowerTLBars3[0]), 30, yIncLegend + yIncL, Color_3);
      setObject(TAG + "sem3l1", CharToString((uchar)Symbol_3_Kod), 10, yIncLegend + yIncL, Color_3, "Wingdings");
      yIncL += 20;
      setObject(TAG + "sem2u", StringFormat("Upper Semafor %s[%d]", DoubleToString(upperTL2[0], digits), upperTLBars2[0]), 30, yIncLegend + yIncL, Color_2);
      setObject(TAG + "sem2u1", CharToString((uchar)Symbol_2_Kod), 10, yIncLegend + yIncL, Color_2, "Wingdings");
      yIncL += 20;
      setObject(TAG + "sem2l", StringFormat("Lower Semafor %s[%d]", DoubleToString(lowerTL2[0], digits), lowerTLBars2[0]), 30, yIncLegend + yIncL, Color_2);
      setObject(TAG + "sem2l1", CharToString((uchar)Symbol_2_Kod), 10, yIncLegend + yIncL, Color_2, "Wingdings");
      yIncL += 20;
      setObject(TAG + "sem1u", StringFormat("Upper Semafor %s[%d]", DoubleToString(upperTL1[0], digits), upperTLBars1[0]), 30, yIncLegend + yIncL, Color_1);
      setObject(TAG + "sem1u1", CharToString((uchar)Symbol_1_Kod), 10, yIncLegend + yIncL, Color_1, "Wingdings");
      yIncL += 20;
      setObject(TAG + "sem1l", StringFormat("Lower Semafor %s[%d]", DoubleToString(lowerTL1[0], digits), lowerTLBars1[0]), 30, yIncLegend + yIncL, Color_1);
      setObject(TAG + "sem1l1", CharToString((uchar)Symbol_1_Kod), 10, yIncLegend + yIncL, Color_1, "Wingdings");
     }
   if(Show_Diff)
     {
      yIncL += 20;
      setObject(TAG + "s3ra", StringFormat("Sem3 Range    %s", DoubleToString(Sema3Diff / pointValue, 0)), 30, yIncLegend + yIncL, Color_3);
      yIncL += 20;
      setObject(TAG + "S3Rb", StringFormat("Sem3 Retrace  %s", DoubleToString(Close3Diff / pointValue, 0)), 30, yIncLegend + yIncL, Color_3);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setObject(string labelName, string text, int x, int y, color theColor, string font = "Courier New", int size = 10, int angle = 0)
  {
   if(ObjectFind(0, labelName) == -1)
     {
      ObjectCreate(0, labelName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, labelName, OBJPROP_CORNER, 0);
      if(angle != 0)
         ObjectSetDouble(0, labelName, OBJPROP_ANGLE, (double)angle);
     }
   ObjectSetInteger(0, labelName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, labelName, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, labelName, OBJPROP_TEXT, text);
   ObjectSetInteger(0, labelName, OBJPROP_FONTSIZE, size);
   ObjectSetString(0, labelName, OBJPROP_FONT, font);
   ObjectSetInteger(0, labelName, OBJPROP_COLOR, theColor);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TRO()
  {
   string tObjName03    = "TROTAG"  ;
   if(ObjectFind(0, tObjName03) < 0)
      ObjectCreate(0, tObjName03, OBJ_LABEL, 0, 0, 0);
   ObjectSetString(0, tObjName03, OBJPROP_TEXT, CharToString((ushort)78));
   ObjectSetInteger(0, tObjName03, OBJPROP_FONTSIZE, 12);
   ObjectSetString(0, tObjName03, OBJPROP_FONT,  "Wingdings");
   ObjectSetInteger(0, tObjName03, OBJPROP_COLOR,  DimGray);
   ObjectSetInteger(0, tObjName03, OBJPROP_CORNER, 3);
   ObjectSetInteger(0, tObjName03, OBJPROP_XDISTANCE, 5);
   ObjectSetInteger(0, tObjName03, OBJPROP_YDISTANCE, 5);
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        3_Level_ZZ_Semafor_TRO_MODIFIED_VERSION_Btn
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=156155#p156155
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
