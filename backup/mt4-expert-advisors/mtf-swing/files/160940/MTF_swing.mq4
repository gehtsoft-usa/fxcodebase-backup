// -- Project -------------------------------------------------------------------------------
/*
Name:        MTF_swing
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76383
License:     GNU
*/

// -- Author --------------------------------------------------------------------------------
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// -- Support & Donations -------------------------------------------------------------------
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// -- Copyright -----------------------------------------------------------------------------
/*
(c) 2025 Gehtsoft USA LLC - https://fxcodebase.com
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

#property copyright "Copyright (c) 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
input int    BarsBack = 5;                              // Bars back to check for a swing
input bool   ShowSig = true;                            // Show Chart Timeframe Swing Highs and Lows
input bool   ShowBtf = true;                            // Show Higher Timeframe Swing Highs and Lows
input bool   ShowHtf = true;                            // Show Highest Timeframe Swing Highs and Lows
enum TextSizeEnum
  {
   Tiny = 6,
   Small = 8,
   Normal = 10,
   Large = 12,
   Huge = 14
  };
input TextSizeEnum SigSize = Tiny;                      // Low Timeframe Swing Text Size
input TextSizeEnum BtfSize = Normal;                    // Mid Timeframe Swing Text Size
input TextSizeEnum HtfSize = Huge;                      // High Timeframe Swing Text Size
input bool   ShowESD1 = true;                           // Show Chart TF S/D Zone 1
input bool   ShowESD2 = false;                          // Show Chart TF S/D Zone 2
input bool   ShowESD3 = false;                          // Show Chart TF S/D Zone 3
input bool   ShowBSD1 = true;                           // Show Higher TF S/D Zone 1
input bool   ShowBSD2 = true;                           // Show Higher TF S/D Zone 2
input bool   ShowBSD3 = false;                          // Show Higher TF S/D Zone 3
input bool   ShowHSD1 = true;                           // Show Highest TF S/D Zone 1
input bool   ShowHSD2 = true;                           // Show Highest TF S/D Zone 2
input bool   ShowHSD3 = true;                           // Show Highest TF S/D Zone 3
input bool   ExtendLeft = false;                        // Extend Left
struct SwingData
  {
   datetime          time;
   double            price;
   double            close;
   double            open;
   double            low;
   bool              detected;
  };

SwingData etfSwingHighs[5];
SwingData etfSwingLows[5];
SwingData btfSwingHighs[5];
SwingData btfSwingLows[5];
SwingData htfSwingHighs[5];
SwingData htfSwingLows[5];
int etfSHCount = 0;
int etfSLCount = 0;
int btfSHCount = 0;
int btfSLCount = 0;
int htfSHCount = 0;
int htfSLCount = 0;
int etf, btf, htf;
int btf_bb, htf_bb;
string prefix = "MTF_Swing_";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   etf = Period();
   switch(etf)
     {
      case PERIOD_M1:
         btf = PERIOD_M5;
         htf = PERIOD_M15;
         break;
      case PERIOD_M5:
         btf = PERIOD_M15;
         htf = PERIOD_H1;
         break;
      case PERIOD_M15:
         btf = PERIOD_H1;
         htf = PERIOD_H4;
         break;
      case PERIOD_H1:
         btf = PERIOD_H4;
         htf = PERIOD_D1;
         break;
      case PERIOD_H4:
         btf = PERIOD_D1;
         htf = PERIOD_W1;
         break;
      case PERIOD_D1:
         btf = PERIOD_W1;
         htf = PERIOD_MN1;
         break;
      case PERIOD_W1:
         btf = PERIOD_MN1;
         htf = PERIOD_MN1;
         break;
      default:
         btf = etf * 5;
         htf = etf * 15;
         break;
     }
   int btf_bb_mult, htf_bb_mult;
   switch(etf)
     {
      case PERIOD_M1:
         btf_bb_mult = 5;
         htf_bb_mult = 15;
         break;
      case PERIOD_M5:
         btf_bb_mult = 3;
         htf_bb_mult = 12;
         break;
      case PERIOD_M15:
         btf_bb_mult = 4;
         htf_bb_mult = 16;
         break;
      case PERIOD_H1:
         btf_bb_mult = 4;
         htf_bb_mult = 24;
         break;
      case PERIOD_H4:
         btf_bb_mult = 6;
         htf_bb_mult = 30;
         break;
      case PERIOD_D1:
         btf_bb_mult = 5;
         htf_bb_mult = 20;
         break;
      case PERIOD_W1:
         btf_bb_mult = 4;
         htf_bb_mult = 16;
         break;
      default:
         btf_bb_mult = 5;
         htf_bb_mult = 15;
         break;
     }
   btf_bb = BarsBack * btf_bb_mult;
   htf_bb = BarsBack * htf_bb_mult;
   InitSwingArrays();
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteAllObjects();
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
   if(rates_total < BarsBack * 2 + 1)
      return(0);
   DeleteAllObjects();
   InitSwingArrays();
   if(ShowSig)
     {
      CheckSwingAtIndex(BarsBack, etfSwingHighs, etfSwingLows, etfSHCount, etfSLCount);
     }
   if(ShowBtf)
     {
      CheckSwingAtIndex(btf_bb, btfSwingHighs, btfSwingLows, btfSHCount, btfSLCount);
     }
   if(ShowHtf)
     {
      CheckSwingAtIndex(htf_bb, htfSwingHighs, htfSwingLows, htfSHCount, htfSLCount);
     }
   if(ShowSig && etfSHCount > 0)
     {
      DrawSwingLabels("ETF", etfSwingHighs, etfSwingLows, etfSHCount, etfSLCount, SigSize);
      DrawSupplyDemandZones("ETF", etfSwingHighs, etfSwingLows, etfSHCount, etfSLCount,
                            ShowESD1, ShowESD2, ShowESD3, clrOrange);
     }
   if(ShowBtf && btfSHCount > 0)
     {
      DrawSwingLabels("BTF", btfSwingHighs, btfSwingLows, btfSHCount, btfSLCount, BtfSize);
      DrawSupplyDemandZones("BTF", btfSwingHighs, btfSwingLows, btfSHCount, btfSLCount,
                            ShowBSD1, ShowBSD2, ShowBSD3, clrBlue);
     }
   if(ShowHtf && htfSHCount > 0)
     {
      DrawSwingLabels("HTF", htfSwingHighs, htfSwingLows, htfSHCount, htfSLCount, HtfSize);
      DrawSupplyDemandZones("HTF", htfSwingHighs, htfSwingLows, htfSHCount, htfSLCount,
                            ShowHSD1, ShowHSD2, ShowHSD3, clrBlack);
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitSwingArrays()
  {
   for(int i = 0; i < 5; i++)
     {
      etfSwingHighs[i].detected = false;
      etfSwingLows[i].detected = false;
      btfSwingHighs[i].detected = false;
      btfSwingLows[i].detected = false;
      htfSwingHighs[i].detected = false;
      htfSwingLows[i].detected = false;
     }
   etfSHCount = 0;
   etfSLCount = 0;
   btfSHCount = 0;
   btfSLCount = 0;
   htfSHCount = 0;
   htfSLCount = 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckSwingAtIndex(int index, SwingData &swingHighs[], SwingData &swingLows[],
                       int &shCount, int &slCount)
  {
   if(Bars < index + index * 2)
      return;
   CollectHistoricalSwings(index, true, swingHighs, shCount);
   CollectHistoricalSwings(index, false, swingLows, slCount);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CollectHistoricalSwings(int lookback, bool isHigh, SwingData &swings[], int &count)
  {
   count = 0;
   int swingsFound = 0;
   for(int bar = lookback; bar < MathMin(Bars - lookback * 2, 500) && swingsFound < 5; bar++)
     {
      int start = (lookback * 2) - 1;
      double swing_point = isHigh ? High[bar] : Low[bar];
      bool isSwing = true;
      for(int i = 0; i <= start && isSwing; i++)
        {
         int checkBar = bar + i - lookback;
         if(checkBar < 0 || checkBar >= Bars)
           {
            isSwing = false;
            break;
           }
         double checkValue = isHigh ? High[checkBar] : Low[checkBar];
         if(i < lookback)
           {
            if(isHigh)
              {
               if(checkValue > swing_point)
                  isSwing = false;
              }
            else
              {
               if(checkValue < swing_point)
                  isSwing = false;
              }
           }
         else
            if(i > lookback)
              {
               if(isHigh)
                 {
                  if(checkValue >= swing_point)
                     isSwing = false;
                 }
               else
                 {
                  if(checkValue <= swing_point)
                     isSwing = false;
                 }
              }
        }
      if(isSwing)
        {
         swings[swingsFound].time = Time[bar];
         swings[swingsFound].price = isHigh ? High[bar] : Low[bar];
         swings[swingsFound].close = Close[bar];
         swings[swingsFound].open = Open[bar];
         swings[swingsFound].low = Low[bar];
         swings[swingsFound].detected = true;
         swingsFound++;
        }
     }
   count = swingsFound;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSwingLabels(string tfName, SwingData &swingHighs[], SwingData &swingLows[],
                     int shCount, int slCount, int textSize)
  {
   if(shCount > 0 && swingHighs[0].detected)
     {
      string labelName = prefix + tfName + "_SH_Label";
      if(ObjectFind(ChartID(), labelName) >= 0)
         ObjectDelete(ChartID(), labelName);
      string labelText = "SH\n" + DoubleToString(swingHighs[0].price, _Digits);
      ObjectCreate(ChartID(), labelName, OBJ_TEXT, 0, swingHighs[0].time, swingHighs[0].price);
      ObjectSetInteger(ChartID(), labelName, OBJPROP_COLOR, clrLime);
      ObjectSetInteger(ChartID(), labelName, OBJPROP_FONTSIZE, textSize);
      ObjectSetInteger(ChartID(), labelName, OBJPROP_ANCHOR, ANCHOR_LOWER);
      ObjectSetString(ChartID(), labelName, OBJPROP_TEXT, labelText);
      ObjectSetString(ChartID(), labelName, OBJPROP_FONT, "Arial Bold");
     }
   if(slCount > 0 && swingLows[0].detected)
     {
      string labelName = prefix + tfName + "_SL_Label";
      if(ObjectFind(ChartID(), labelName) >= 0)
         ObjectDelete(ChartID(), labelName);
      string labelText = "SL\n" + DoubleToString(swingLows[0].price, _Digits);
      ObjectCreate(ChartID(), labelName, OBJ_TEXT, 0, swingLows[0].time, swingLows[0].price);
      ObjectSetInteger(ChartID(), labelName, OBJPROP_COLOR, clrRed);
      ObjectSetInteger(ChartID(), labelName, OBJPROP_FONTSIZE, textSize);
      ObjectSetInteger(ChartID(), labelName, OBJPROP_ANCHOR, ANCHOR_UPPER);
      ObjectSetString(ChartID(), labelName, OBJPROP_TEXT, labelText);
      ObjectSetString(ChartID(), labelName, OBJPROP_FONT, "Arial Bold");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSupplyDemandZones(string tfName, SwingData &swingHighs[], SwingData &swingLows[],
                           int shCount, int slCount, bool show1, bool show2, bool show3,
                           color borderColor)
  {
   if(show1 && shCount > 0)
      DrawSupplyZone(tfName, swingHighs[0], 1, borderColor);
   if(show2 && shCount > 1)
      DrawSupplyZone(tfName, swingHighs[1], 2, borderColor);
   if(show3 && shCount > 2)
      DrawSupplyZone(tfName, swingHighs[2], 3, borderColor);
   if(show1 && slCount > 0)
      DrawDemandZone(tfName, swingLows[0], 1, borderColor);
   if(show2 && slCount > 1)
      DrawDemandZone(tfName, swingLows[1], 2, borderColor);
   if(show3 && slCount > 2)
      DrawDemandZone(tfName, swingLows[2], 3, borderColor);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSupplyZone(string tfName, SwingData &swing, int index, color borderColor)
  {
   if(!swing.detected)
      return;
   string boxName = prefix + tfName + "_SupBox" + IntegerToString(index);
   if(ObjectFind(ChartID(), boxName) >= 0)
      ObjectDelete(ChartID(), boxName);
   double zoneHigh = swing.price;
   double zoneTop = swing.close > swing.open ? swing.close : swing.open;
   datetime startTime = swing.time;
   datetime endTime = Time[0];
   ObjectCreate(ChartID(), boxName, OBJ_RECTANGLE, 0, startTime, zoneHigh, endTime, zoneTop);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_COLOR, borderColor);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_BACK, true);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_FILL, true);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_BGCOLOR, clrMistyRose);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_RAY_LEFT, false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawDemandZone(string tfName, SwingData &swing, int index, color borderColor)
  {
   if(!swing.detected)
      return;
   string boxName = prefix + tfName + "_DemBox" + IntegerToString(index);
   if(ObjectFind(ChartID(), boxName) >= 0)
      ObjectDelete(ChartID(), boxName);
   double zoneLow = swing.price;
   double zoneBottom = swing.close < swing.open ? swing.close : swing.open;
   datetime startTime = swing.time;
   datetime endTime = Time[0];
   ObjectCreate(ChartID(), boxName, OBJ_RECTANGLE, 0, startTime, zoneLow, endTime, zoneBottom);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_COLOR, borderColor);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_WIDTH, 2);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_BACK, true);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_FILL, true);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_BGCOLOR, clrHoneydew);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_RAY_RIGHT, false);
   ObjectSetInteger(ChartID(), boxName, OBJPROP_RAY_LEFT, false);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   int total = ObjectsTotal(ChartID(), -1, -1);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(ChartID(), i, -1, -1);
      if(StringFind(name, prefix) == 0)
        {
         ObjectDelete(ChartID(), name);
        }
     }
  }
//+------------------------------------------------------------------+
// -- Project -------------------------------------------------------------------------------
/*
Name:        MTF_swing
Version:     1.00
Date:        2025
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76383
License:     GNU
*/

// -- Author --------------------------------------------------------------------------------
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// -- Support & Donations -------------------------------------------------------------------
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vzj

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// -- Copyright -----------------------------------------------------------------------------
/*
(c) 2025 Gehtsoft USA LLC - https://fxcodebase.com
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
