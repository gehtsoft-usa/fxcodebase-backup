//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76312
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
//HEADER:END

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots 8
#property indicator_color1  White
#property indicator_width1 4
#property indicator_color2  Lime
#property indicator_width2 2
#property indicator_color3  Blue
#property indicator_width3 7
#property indicator_color4  Red
#property indicator_width4 7
#property indicator_color5  Blue//C'0,128,255'
#property indicator_width5 7
#property indicator_color6  Red//C'192,0,192'
#property indicator_width6 7
#property indicator_color7  DodgerBlue//C'0,128,255'
#property indicator_width7 3
#property indicator_color8  MediumVioletRed//C'192,0,192'
#property indicator_width8 3
//--------------------------------------------------------------------
int    SR     = 3; // =3..4   Xard settings (3,21,20,21,3,false,0)
input int    inpSRZZ   = 60; //60;//36;//24;//13; // =4..12..20..12
int   SRZZ = inpSRZZ;
int    MainRZZ = 20; //20; // =12..20..54..20
int    FP     = 21;
int    SMF    = 3; // =1..5
bool   DrawZZ = false;
int    PriceConst = 0; // 0 - Close
// 1 - Open
// 2 - High
// 3 - Low
// 4 - (H+L)/2
// 5 - (H+L+C)/3
// 6 - (H+L+2*C)/4
//--------------------------------------------------------------------
double        Lmt[];
double        LZZ[];
double        SA[];
double        SM[];
double        Up[];
double        Dn[];
double        pUp[];
double        pDn[];

int LTF[6] = {0, 0, 0, 0, 0, 0}, STF[5] = {0, 0, 0, 0, 0};
int MaxBar, nSBZZ, nLBZZ, SBZZ, LBZZ;
bool First = true;
int prevBars = 0;
void MainCalculation(int pos, int rates_total)
  {
   if((rates_total - pos) > (SR + 1))
      SACalc(pos, rates_total);
   else
      SA[pos] = 0.0;
   if((rates_total - pos) > (FP + SR + 2))
      SMCalc(pos, rates_total);
   else
      SM[pos] = 0.0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SACalc(int Pos, int rates_total)
  {
   int sw, i, w, ww, Shift;
   double sum;
   switch(PriceConst)
     {
      case  0:
         SA[Pos] = iMAMQL4(_Symbol, 0, SR + 1, 0, MODE_LWMA, PRICE_CLOSE, Pos);
         break;
      case  1:
         SA[Pos] = iMAMQL4(_Symbol, 0, SR + 1, 0, MODE_LWMA, PRICE_OPEN, Pos);
         break;
      case  4:
         SA[Pos] = iMAMQL4(_Symbol, 0, SR + 1, 0, MODE_LWMA, PRICE_MEDIAN, Pos);
         break;
      case  5:
         SA[Pos] = iMAMQL4(_Symbol, 0, SR + 1, 0, MODE_LWMA, PRICE_TYPICAL, Pos);
         break;
      case  6:
         SA[Pos] = iMAMQL4(_Symbol, 0, SR + 1, 0, MODE_LWMA, PRICE_WEIGHTED, Pos);
         break;
      default:
         SA[Pos] = iMAMQL4(_Symbol, 0, SR + 1, 0, MODE_LWMA, PRICE_OPEN, Pos);
         break;
     }
   for(Shift = Pos + SR + 2; Shift > Pos; Shift--)
     {
      if(Shift >= rates_total)
         continue;
      sum = 0.0;
      sw = 0;
      i = 0;
      w = Shift + SR;
      ww = Shift - SR;
      if(ww < Pos)
         ww = Pos;
      while(w >= Shift)
        {
         i++;
         sum = sum + i * SnakePrice(w);
         sw = sw + i;
         w--;
        }
      while(w >= ww)
        {
         i--;
         sum = sum + i * SnakePrice(w);
         sw = sw + i;
         w--;
        }
      SA[Shift] = sum / sw;
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SnakePrice(int Shift)
  {
   switch(PriceConst)
     {
      case  0:
         return(iClose(_Symbol, _Period, Shift));
      case  1:
         return(iOpen(_Symbol, _Period, Shift));
      case  4:
         return((iHigh(_Symbol, _Period, Shift) + iLow(_Symbol, _Period, Shift)) / 2);
      case  5:
         return((iClose(_Symbol, _Period, Shift) + iHigh(_Symbol, _Period, Shift) + iLow(_Symbol, _Period, Shift)) / 3);
      case  6:
         return((2 * iClose(_Symbol, _Period, Shift) + iHigh(_Symbol, _Period, Shift) + iLow(_Symbol, _Period, Shift)) / 4);
      default:
         return(iOpen(_Symbol, _Period, Shift));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SMCalc(int i, int rates_total)
  {
   double t, b;
   for(int Shift = i + SR + 2; Shift >= i; Shift--)
     {
      if(Shift >= rates_total)
         continue;
      int idxMax = ArrayMaximum(SA, Shift, FP);
      int idxMin = ArrayMinimum(SA, Shift, FP);
      t = SA[idxMax];
      b = SA[idxMin];
      SM[Shift] = (2.0 * (2 + SMF) * SA[Shift] - (t + b)) / 2.0 / (1 + SMF);
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LZZCalc(int Pos)
  {
   int i, RBar, LBar, ZZ = 0, NZZ, NZig = 0, NZag = 0;
   i = Pos - 1;
   while(i < MaxBar && ZZ == 0)
     {
      i++;
      LZZ[i] = 0;
      RBar = i - MainRZZ;
      if(RBar < Pos)
         RBar = Pos;
      LBar = i + MainRZZ;
      if(i == ArrayMinimum(SM, RBar, LBar - RBar + 1))
        {
         ZZ = -1;
         NZig = i;
        }
      if(i == ArrayMaximum(SM, RBar, LBar - RBar + 1))
        {
         ZZ = 1;
         NZag = i;
        }
     }
   if(ZZ == 0)
      return;
   NZZ = 0;
   if(i > Pos)
     {
      if(SM[i] > SM[Pos])
        {
         if(ZZ == 1)
           {
            if(i >= Pos + MainRZZ && NZZ < 5)
              {
               NZZ++;
               LTF[NZZ] = i;
              }
            NZag = i;
            LZZ[i] = SM[i];
           }
        }
      else
        {
         if(ZZ == -1)
           {
            if(i >= Pos + MainRZZ && NZZ < 5)
              {
               NZZ++;
               LTF[NZZ] = i;
              }
            NZig = i;
            LZZ[i] = SM[i];
           }
        }
     }
   while(i < LBZZ || NZZ < 5)
     {
      LZZ[i] = 0;
      RBar = i - MainRZZ;
      if(RBar < Pos)
         RBar = Pos;
      LBar = i + MainRZZ;
      if(i == ArrayMinimum(SM, RBar, LBar - RBar + 1))
        {
         if(ZZ == -1 && SM[i] < SM[NZig])
           {
            if(i >= Pos + MainRZZ && NZZ < 5)
               LTF[NZZ] = i;
            LZZ[NZig] = 0;
            LZZ[i] = SM[i];
            NZig = i;
           }
         if(ZZ == 1)
           {
            if(i >= Pos + MainRZZ && NZZ < 5)
              {
               NZZ++;
               LTF[NZZ] = i;
              }
            LZZ[i] = SM[i];
            ZZ = -1;
            NZig = i;
           }
        }
      if(i == ArrayMaximum(SM, RBar, LBar - RBar + 1))
        {
         if(ZZ == 1 && SM[i] > SM[NZag])
           {
            if(i >= Pos + MainRZZ && NZZ < 5)
               LTF[NZZ] = i;
            LZZ[NZag] = 0;
            LZZ[i] = SM[i];
            NZag = i;
           }
         if(ZZ == -1)
           {
            if(i >= Pos + MainRZZ && NZZ < 5)
              {
               NZZ++;
               LTF[NZZ] = i;
              }
            LZZ[i] = SM[i];
            ZZ = 1;
            NZag = i;
           }
        }
      i++;
      if(i > MaxBar)
         return;
     }
   int totalBars = Bars(_Symbol, _Period);
   nLBZZ = totalBars - LTF[5];
   LZZ[Pos] = SM[Pos];
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SZZCalc(int Pos)
  {
   int i, RBar, LBar, ZZ = 0, NZZ, NZig = 0, NZag = 0;
   i = Pos - 1;
   while(i <= LBZZ && ZZ == 0)
     {
      i++;
      pDn[i] = 0;
      pUp[i] = 0;
      Dn[i] = 0;
      Up[i] = 0;
      Lmt[i] = 0;
      RBar = i - SRZZ;
      if(RBar < Pos)
         RBar = Pos;
      LBar = i + SRZZ;
      if(i == ArrayMinimum(SM, RBar, LBar - RBar + 1))
        {
         ZZ = -1;
         NZig = i;
        }
      if(i == ArrayMaximum(SM, RBar, LBar - RBar + 1))
        {
         ZZ = 1;
         NZag = i;
        }
     }
   if(ZZ == 0)
      return;
   NZZ = 0;
   if(i > Pos)
     {
      if(SM[i] > SM[Pos])
        {
         if(ZZ == 1)
           {
            if(i >= Pos + SRZZ && NZZ < 4)
              {
               NZZ++;
               STF[NZZ] = i;
              }
            NZag = i;
            if(i - 1 >= 0)
               Dn[i - 1] = iOpen(_Symbol, _Period, i - 1);
           }
        }
      else
        {
         if(ZZ == -1)
           {
            if(i >= Pos + SRZZ && NZZ < 4)
              {
               NZZ++;
               STF[NZZ] = i;
              }
            NZig = i;
            if(i - 1 >= 0)
               Up[i - 1] = iOpen(_Symbol, _Period, i - 1);
           }
        }
     }
   while(i <= LBZZ || NZZ < 4)
     {
      pDn[i] = 0;
      pUp[i] = 0;
      Dn[i] = 0;
      Up[i] = 0;
      Lmt[i] = 0;
      RBar = i - SRZZ;
      if(RBar < Pos)
         RBar = Pos;
      LBar = i + SRZZ;
      if(i == ArrayMinimum(SM, RBar, LBar - RBar + 1))
        {
         if(ZZ == -1 && SM[i] < SM[NZig])
           {
            if(i >= Pos + SRZZ && NZZ < 4)
               STF[NZZ] = i;
            if(NZig - 1 >= 0)
               Up[NZig - 1] = 0;
            if(i - 1 >= 0)
               Up[i - 1] = iOpen(_Symbol, _Period, i - 1);
            NZig = i;
           }
         if(ZZ == 1)
           {
            if(i >= Pos + SRZZ && NZZ < 4)
              {
               NZZ++;
               STF[NZZ] = i;
              }
            if(i - 1 >= 0)
               Up[i - 1] = iOpen(_Symbol, _Period, i - 1);
            ZZ = -1;
            NZig = i;
           }
        }
      if(i == ArrayMaximum(SM, RBar, LBar - RBar + 1))
        {
         if(ZZ == 1 && SM[i] > SM[NZag])
           {
            if(i >= Pos + SRZZ && NZZ < 4)
               STF[NZZ] = i;
            if(NZag - 1 >= 0)
               Dn[NZag - 1] = 0;
            if(i - 1 >= 0)
               Dn[i - 1] = iOpen(_Symbol, _Period, i - 1);
            NZag = i;
           }
         if(ZZ == -1)
           {
            if(i >= Pos + SRZZ && NZZ < 4)
              {
               NZZ++;
               STF[NZZ] = i;
              }
            if(i - 1 >= 0)
               Dn[i - 1] = iOpen(_Symbol, _Period, i - 1);
            ZZ = 1;
            NZag = i;
           }
        }
      i++;
      if(i > LBZZ)
         break;
     }
   int totalBars = Bars(_Symbol, _Period);
   nSBZZ = totalBars - STF[4];
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrCalc()
  {
   int i, j, k, n, z = 0;
   double p;
   i = LBZZ;
   while(LZZ[i] == 0)
      i--;
   j = i;
   p = LZZ[i];
   i--;
   while(LZZ[i] == 0)
      i--;
   if(LZZ[i] > p)
      z = 1;
   if(LZZ[i] > 0 && LZZ[i] < p)
      z = -1;
   p = LZZ[j];
   i = j - 1;
   while(i > 0)
     {
      if(LZZ[i] > p)
        {
         z = -1;
         p = LZZ[i];
        }
      if(LZZ[i] > 0 && LZZ[i] < p)
        {
         z = 1;
         p = LZZ[i];
        }
      if(z > 0 && Dn[i] > 0)
        {
         Lmt[i] = iOpen(_Symbol, _Period, i);
         Dn[i] = 0;
        }
      if(z < 0 && Up[i] > 0)
        {
         Lmt[i] = iOpen(_Symbol, _Period, i);
         Up[i] = 0;
        }
      if(z > 0 && Up[i] > 0)
        {
         if(i > 1)
           {
            j = i - 1;
            k = j - SRZZ + 1;
            if(k < 0)
               k = 0;
            n = j;
            while(n >= k && Dn[n] == 0)
              {
               pUp[n] = Up[i];
               pDn[n] = 0;
               n--;
              }
           }
         if(i == 1)
            pUp[0] = Up[i];
        }
      if(z < 0 && Dn[i] > 0)
        {
         if(i > 1)
           {
            j = i - 1;
            k = j - SRZZ + 1;
            if(k < 0)
               k = 0;
            n = j;
            while(n >= k && Up[n] == 0)
              {
               pDn[n] = Dn[i];
               pUp[n] = 0;
               n--;
              }
           }
         if(i == 1)
            pDn[0] = Dn[i];
        }
      i--;
     }
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deinit()
  {
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   ArraySetAsSeries(Lmt, true);
   ArraySetAsSeries(LZZ, true);
   ArraySetAsSeries(SA, true);
   ArraySetAsSeries(SM, true);
   ArraySetAsSeries(Up, true);
   ArraySetAsSeries(Dn, true);
   ArraySetAsSeries(pUp, true);
   ArraySetAsSeries(pDn, true);
   SetIndexBuffer(0, Lmt, INDICATOR_DATA);
   SetIndexBuffer(1, LZZ, INDICATOR_DATA);
   SetIndexBuffer(2, Up, INDICATOR_DATA);
   SetIndexBuffer(3, Dn, INDICATOR_DATA);
   SetIndexBuffer(4, pUp, INDICATOR_DATA);
   SetIndexBuffer(5, pDn, INDICATOR_DATA);
   SetIndexBuffer(6, SA, INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, SM, INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 5);
   PlotIndexSetInteger(0, PLOT_ARROW, 167);
   if(DrawZZ)
     {
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_SECTION);
      PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
     }
   else
     {
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
     }
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 7);
   PlotIndexSetInteger(2, PLOT_ARROW, 233);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 7);
   PlotIndexSetInteger(3, PLOT_ARROW, 234);
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(4, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(4, PLOT_ARROW, 104);
   PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(5, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(5, PLOT_ARROW, 104);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
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
   int counted_bars = prev_calculated;
   if(counted_bars < 0)
      return(0);
   if(counted_bars > 0)
      counted_bars--;
   if(First)
     {
      if(SR < 2)
         SR = 2;
      if(rates_total <= 2 * (MainRZZ + FP + SR + 2))
         return(prev_calculated);
      if(SRZZ <= SR)
         SRZZ = SR + 1;
      MaxBar = rates_total - (MainRZZ + FP + SR + 2);
      LBZZ   = MaxBar;
      SBZZ   = LBZZ;
      prevBars = rates_total;
      First = false;
     }
   int limit = rates_total - prev_calculated;
   for(int i = prev_calculated; i < rates_total; i++)
     {
      int Pos = rates_total - 1 - i;
      MainCalculation(Pos, rates_total);
     }
   if(prevBars != rates_total)
     {
      SBZZ = rates_total - nSBZZ;
      LBZZ = rates_total - nLBZZ;
      prevBars = rates_total;
     }
   SZZCalc(0);
   LZZCalc(0);
   ArrCalc();
   return(rates_total);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0:
         return(PERIOD_CURRENT);
      case 1:
         return(PERIOD_M1);
      case 5:
         return(PERIOD_M5);
      case 15:
         return(PERIOD_M15);
      case 30:
         return(PERIOD_M30);
      case 60:
         return(PERIOD_H1);
      case 240:
         return(PERIOD_H4);
      case 1440:
         return(PERIOD_D1);
      case 10080:
         return(PERIOD_W1);
      case 43200:
         return(PERIOD_MN1);
      case 2:
         return(PERIOD_M2);
      case 3:
         return(PERIOD_M3);
      case 4:
         return(PERIOD_M4);
      case 6:
         return(PERIOD_M6);
      case 10:
         return(PERIOD_M10);
      case 12:
         return(PERIOD_M12);
      case 16385:
         return(PERIOD_H1);
      case 16386:
         return(PERIOD_H2);
      case 16387:
         return(PERIOD_H3);
      case 16388:
         return(PERIOD_H4);
      case 16390:
         return(PERIOD_H6);
      case 16392:
         return(PERIOD_H8);
      case 16396:
         return(PERIOD_H12);
      case 16408:
         return(PERIOD_D1);
      case 32769:
         return(PERIOD_W1);
      case 49153:
         return(PERIOD_MN1);
      default:
         return(PERIOD_CURRENT);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_MA_METHOD MethodMigrate(int method)
  {
   switch(method)
     {
      case 0:
         return(MODE_SMA);
      case 1:
         return(MODE_EMA);
      case 2:
         return(MODE_SMMA);
      case 3:
         return(MODE_LWMA);
      default:
         return(MODE_SMA);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_APPLIED_PRICE PriceMigrate(int price)
  {
   switch(price)
     {
      case 0:
         return(PRICE_CLOSE);
      case 1:
         return(PRICE_OPEN);
      case 2:
         return(PRICE_HIGH);
      case 3:
         return(PRICE_LOW);
      case 4:
         return(PRICE_MEDIAN);
      case 5:
         return(PRICE_TYPICAL);
      case 6:
         return(PRICE_WEIGHTED);
      default:
         return(PRICE_CLOSE);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CopyBufferMQL4(int handle, int index, int shift)
  {
   double buf[];
   switch(index)
     {
      case 0:
         if(CopyBuffer(handle, 0, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 1:
         if(CopyBuffer(handle, 1, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 2:
         if(CopyBuffer(handle, 2, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 3:
         if(CopyBuffer(handle, 3, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 4:
         if(CopyBuffer(handle, 4, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      default:
         break;
     }
   return(EMPTY_VALUE);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iMAMQL4(string symbol, int tf, int period, int ma_shift, int method, int price, int shift)
  {
   if(StringLen(symbol) == 0)
      symbol = _Symbol;
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   ENUM_MA_METHOD ma_method = MethodMigrate(method);
   ENUM_APPLIED_PRICE applied_price = PriceMigrate(price);
   int handle = iMA(symbol, timeframe, period, ma_shift,
                    ma_method, applied_price);
   if(handle < 0)
     {
      Print("The iMA object is not created: Error", GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle, 0, shift));
  }
//+------------------------------------------------------------------+
//FOOTER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76312
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
//FOOTER:END