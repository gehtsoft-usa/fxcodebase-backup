//HEADER:BEGIN
//-- Project ---------------------------------------------------------------------
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76314&p=160601#p160601
License:     GNU
*/

// -- Author ----------------------------------------------------------------------
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// -- Support & Donations ---------------------------------------------------------
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// -- Copyright -------------------------------------------------------------------
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
// #property strict

#property indicator_separate_window
#property  indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

extern int FastEMA     = 12;
extern int SlowEMA     = 26;
extern int SignalEMA   = 9;
extern int AlertCandle = 1;

double MACDBuffer[];
double SignalBuffer[];
double FastEMABuffer[];
double SlowEMABuffer[];
double SignalEMABuffer[];

datetime prev_time = -99999;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(5);
   SetIndexBuffer(0, MACDBuffer);
   SetIndexBuffer(1, SignalBuffer);
   SetIndexBuffer(2, FastEMABuffer);
   SetIndexBuffer(3, SlowEMABuffer);
   SetIndexBuffer(4, SignalEMABuffer);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE,EMPTY);
   SetIndexDrawBegin(0, SlowEMA);
   SetIndexDrawBegin(1, SlowEMA);
   IndicatorShortName("ZeroLag MACD(" + FastEMA + "," + SlowEMA + "," + SignalEMA + ")");
   SetIndexLabel(0, "MACD");
   SetIndexLabel(1, "Signal");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) 
       return(-1);
   if(counted_bars > 0) 
       counted_bars--;
   limit = Bars - counted_bars;
   double EMA, ZeroLagEMAp, ZeroLagEMAq;
   for(int i = 0; i < limit; i++)
     {
       FastEMABuffer[i] = iMA(NULL, 0, FastEMA, 0, MODE_EMA, PRICE_CLOSE, i);
       SlowEMABuffer[i] = iMA(NULL, 0, SlowEMA, 0, MODE_EMA, PRICE_CLOSE, i);
     }
   for(i = 0; i < limit; i++)
     {
        EMA = iMAOnArray(FastEMABuffer, Bars, FastEMA, 0, MODE_EMA, i);
        ZeroLagEMAp = FastEMABuffer[i] + FastEMABuffer[i] - EMA;
        EMA = iMAOnArray(SlowEMABuffer, Bars, SlowEMA, 0, MODE_EMA, i);
        ZeroLagEMAq = SlowEMABuffer[i] + SlowEMABuffer[i] - EMA;
        MACDBuffer[i] = ZeroLagEMAp - ZeroLagEMAq;
     }
   for(i = 0; i < limit; i++)
       SignalEMABuffer[i] = iMAOnArray(MACDBuffer, Bars, SignalEMA, 0, MODE_EMA, i);
   for(i = 0; i < limit; i++)
     {
       EMA = iMAOnArray(SignalEMABuffer, Bars, SignalEMA, 0, MODE_EMA, i);
       SignalBuffer[i] = SignalEMABuffer[i] + SignalEMABuffer[i] - EMA;
           
     }
     
   if (AlertCandle >= 0 && Time[0] > prev_time)   {
     if (MACDBuffer[AlertCandle] > SignalBuffer[AlertCandle] && MACDBuffer[AlertCandle+1] <= SignalBuffer[AlertCandle+1])
       Alert(Symbol() + "," + ": ZeroLag MACD cross UP");
     if (MACDBuffer[AlertCandle] < SignalBuffer[AlertCandle] && MACDBuffer[AlertCandle+1] >= SignalBuffer[AlertCandle+1])
       Alert(Symbol() + "," + ": ZeroLag MACD cross DOWN");
     prev_time = Time[0];
   }     
   return(0);
  }


