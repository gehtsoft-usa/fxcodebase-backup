/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        Stoch_RSI
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74307&start=10
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

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 7
#property indicator_plots   3
#property indicator_level1     20.0
#property indicator_level2     80.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
#property indicator_label1  "K"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_label2  "D"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
#property indicator_label3  "Signal"
#property indicator_type3   DRAW_NONE
input int                     InpStockKPeriod               = 3;                                   // K
input int                     InpStockDPeriod               = 3;                                   // D
input int                     InpRSIPeriod                  = 14;                                  // RSI Period
input int                     InpStochastikPeriod           = 14;                                  // Stochastic Period
input ENUM_APPLIED_PRICE      InpRSIAppliedPrice            = PRICE_CLOSE;                         // RSI Applied Price
input string T2                    = "== Set Arrows ==";     // ————————————
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color:
class Arrow
  {
   string            _name;
   datetime          _iniTm;
   double            _price;
   color             _clr;
   string            _txt;
   string            _type;
   int               _count;
   int               _arrowCode;
public:

                     Arrow() { ; }

                     Arrow(string inpName, datetime inpIniTm, double inpPrice, color inpClr, string inpLabelTxt = "", string inpType = "up")
     {
      _name  = inpName;
      _iniTm = inpIniTm;
      _price = inpPrice;
      _clr   = inpClr;
      _txt   = inpLabelTxt;
      _type  = inpType;
     }

                    ~Arrow()
     {
      ObjectsDeleteAll(0, "Arrow");
     }

   Arrow*            price(double inpPrice)
     {
      _price = inpPrice;
      return GetPointer(this);
     }

   Arrow*            txt(string inpTxt)
     {
      _txt = inpTxt;
      return GetPointer(this);
     }

   Arrow*            Color(color clr)
     {
      _clr = clr;
      return GetPointer(this);
     }

   Arrow*            Type(string direction)
     {
      _type = direction;
      return GetPointer(this);
     }

   Arrow*            candle(int shift, const datetime &time[])
     {
      _iniTm = TimeByCandles(shift, time);
      return GetPointer(this);
     }

   Arrow*            ArrowCode(int code)
     {
      _arrowCode = code;
      return GetPointer(this);
     }

   datetime          TimeByCandles(int candlesBack, const datetime &time[])
     {
      _iniTm = time[candlesBack];
      return _iniTm;
     }

   void              draw()
     {
      if(_type == "up")
        {
         _name = AutoName();
         ObjectCreate(0, _name, OBJ_ARROW, 0, _iniTm, 0, 0, 0);
         int arrowCode = _arrowCode == 0 ? 233 : _arrowCode;
         ObjectSetInteger(0, _name, OBJPROP_ARROWCODE, arrowCode);
         ObjectSetInteger(0, _name, OBJPROP_ANCHOR, ANCHOR_TOP);
         ObjectSetDouble(0, _name, OBJPROP_PRICE, _price);
        }
      if(_type == "down")
        {
         _name = AutoName();
         ObjectCreate(0, _name, OBJ_ARROW, 0, _iniTm, _price, TimeCurrent(), _price);
         int arrowCode = _arrowCode == 0 ? 234 : _arrowCode;
         ObjectSetInteger(0, _name, OBJPROP_ARROWCODE, arrowCode);
         ObjectSetInteger(0, _name, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
         ObjectSetDouble(0, _name, OBJPROP_PRICE, _price);
        }
      ObjectSetInteger(0, _name, OBJPROP_COLOR, _clr);
      if(_txt != NULL)
        {
         ObjectCreate(0, _name + "Label", OBJ_TEXT, 0, TimeCurrent(), _price);
         ObjectSetInteger(0, _name + "Label", OBJPROP_ANCHOR, ANCHOR_RIGHT);
         ObjectSetString(0, _name + "Label", OBJPROP_FONT, "Calibri Light");
         ObjectSetInteger(0, _name + "Label", OBJPROP_FONTSIZE, 8);
         ObjectSetInteger(0, _name + "Label", OBJPROP_COLOR, _clr);
         ObjectSetString(0, _name + "Label", OBJPROP_TEXT, _txt);
        }
     }

   void              erase()
     {
      ObjectDelete(0, _name);
      ObjectDelete(0, _name + "Label");
     }

   Arrow*            redraw()
     {
      erase();
      draw();
      return GetPointer(this);
     }

   string            AutoName()
     {
      _count++;
      _name = "arrow ";
      return _name + (string)_count;
     }

   void              EraseAll()
     {
      ObjectsDeleteAll(0, 0, OBJ_ARROW);
     }
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Arrow arrows();
double         KBuffer[];
double         DBuffer[];
double         SignalBuffer[];
double         RSIBuffer[];
double         StochBuffer[];
double         ArrowDn[];
double         ArrowUp[];
int            rsi_handle;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   arrows.EraseAll();
   if(rsi_handle != INVALID_HANDLE)
      IndicatorRelease(rsi_handle);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   rsi_handle = iRSI(_Symbol, _Period, InpRSIPeriod, InpRSIAppliedPrice);
   if(rsi_handle == INVALID_HANDLE)
     {
      Print("RSI handle creation failed!");
      return(INIT_FAILED);
     }
   SetIndexBuffer(0, KBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, DBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, SignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, RSIBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, StochBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, ArrowUp, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, ArrowDn, INDICATOR_CALCULATIONS);
   ArraySetAsSeries(KBuffer, true);
   ArraySetAsSeries(DBuffer, true);
   ArraySetAsSeries(SignalBuffer, true);
   ArraySetAsSeries(RSIBuffer, true);
   ArraySetAsSeries(StochBuffer, true);
   ArraySetAsSeries(ArrowUp, true);
   ArraySetAsSeries(ArrowDn, true);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrDodgerBlue);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 1);
   PlotIndexSetString(0, PLOT_LABEL, "K");
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrOrangeRed);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 1);
   PlotIndexSetString(1, PLOT_LABEL, "D");
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetString(2, PLOT_LABEL, "Signal");
   return(INIT_SUCCEEDED);
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
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   int limit = prev_calculated == 0 ? rates_total - (InpRSIPeriod + 1) : rates_total - prev_calculated;
   if(CopyBuffer(rsi_handle, 0, 0, rates_total, RSIBuffer) <= 0)
     {
      Print("RSI copy failed!");
      return(0);
     }
   ArraySetAsSeries(RSIBuffer, true);
   for(int i = limit; i >= 0; i--)
     {
      SignalBuffer[i] = 0;
      ArrowUp[i] = EMPTY_VALUE;
      ArrowDn[i] = EMPTY_VALUE;
      if(i < rates_total - (InpRSIPeriod + 2))
         StochBuffer[i] = Stoch(RSIBuffer, RSIBuffer, RSIBuffer, InpStochastikPeriod, i, rates_total);
      if(StochBuffer[i + InpStockKPeriod - 1] != EMPTY_VALUE)
         KBuffer[i] = SimpleMA(i, InpStockKPeriod, StochBuffer, rates_total);
      if(KBuffer[i + InpStockDPeriod - 1] != EMPTY_VALUE)
         DBuffer[i] = SimpleMA(i, InpStockDPeriod, KBuffer, rates_total);
      if(KBuffer[i] > DBuffer[i] && KBuffer[i + 1] <= DBuffer[i + 1] && KBuffer[i + 1] < 20.0)
        {
         ArrowUp[i] = low[i];
         SignalBuffer[i] = 1;
        }
      if(KBuffer[i] < DBuffer[i] && KBuffer[i + 1] >= DBuffer[i + 1] && KBuffer[i + 1] > 80.0)
        {
         ArrowDn[i] = high[i];
         SignalBuffer[i] = -1;
        }
      if(ArrowsOn)
        {
         if(ArrowUp[i] != EMPTY_VALUE)
            arrows.price(low[i]).Color(ArrowUpClr).Type("up").candle(i, time).draw();
         if(ArrowDn[i] != EMPTY_VALUE)
            arrows.price(high[i]).Color(ArrowDnClr).Type("down").candle(i, time).draw();
        }
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Stoch(const double &source[], double &high[], double &low[], int length, int shift, const int &rates_total)
  {
   if(shift + length >= rates_total)
      return EMPTY_VALUE;
   double Highest = Highest(high, length, shift);
   double Lowest = Lowest(low, length, shift);
   if(Highest - Lowest == 0)
      return EMPTY_VALUE;
   return 100 * (source[shift] - Lowest) / (Highest - Lowest);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Lowest(double &low[], int length, int shift)
  {
   double Result = 0;
   for(int i = shift; i <= shift + length; i++)
     {
      if(Result == 0 || (low[i] < Result && low[i] != EMPTY_VALUE))
        {
         Result = low[i];
        }
     }
   return Result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Highest(double &high[], int length, int shift)
  {
   double Result = 0;
   for(int i = shift; i <= shift + length; i++)
     {
      if(Result == 0 || (high[i] > Result && high[i] != EMPTY_VALUE))
        {
         Result = high[i];
        }
     }
   return Result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SimpleMA(const int position, const int period, const double &price[], const int &rates_total)
  {
   double result = 0.0;
   if(position <= rates_total - period && period > 0)
     {
      for(int i = 0; i < period; i++)
        {
         if(price[position + i] != EMPTY_VALUE)
           {
            result += price[position + i];
           }
        }
      result /= period;
     }
   return(result);
  }

/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        Stoch_RSI
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74307&start=10
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
