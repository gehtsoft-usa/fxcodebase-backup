//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76340
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
#property indicator_buffers 4
#property indicator_color1 clrRed
#property indicator_color2 clrBlue
#property indicator_color3 clrLime
#property indicator_color4 clrOrange
#property indicator_width1 0
#property indicator_width2 0
#property indicator_width3 2
#property indicator_width4 2
//--- input parameters
extern int       LookBackPeriod=13;
//--- buffers
double SupportBuffer[];
double ResistanceBuffer[];
double ArrowUpBuffer[];
double ArrowDnBuffer[];
//double CrossBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   //IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,162);
   SetIndexBuffer(0,SupportBuffer);
   SetIndexEmptyValue(0,0.0);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,162);
   SetIndexBuffer(1,ResistanceBuffer);
SetIndexEmptyValue(1,0.0);
SetIndexStyle(2,DRAW_ARROW);
SetIndexArrow(2,233);
SetIndexBuffer(2,ArrowUpBuffer);
SetIndexEmptyValue(2,EMPTY_VALUE);
SetIndexStyle(3,DRAW_ARROW);
SetIndexArrow(3,234);
SetIndexBuffer(3,ArrowDnBuffer);
SetIndexEmptyValue(3,EMPTY_VALUE);
   //SetIndexBuffer(2,CrossBuffer);
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//----
   int limit = Bars - IndicatorCounted() -1;
   int i;
   
   //////////////////////////////////////////////
   for(i=limit;i>=0;i--){
      SupportBuffer[i] = iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,LookBackPeriod,SearchDn(i)));
      
      ResistanceBuffer[i] = iLow(NULL,0,iLowest(NULL,0,MODE_LOW,LookBackPeriod,SearchUp(i)));
    
    
    if(SupportBuffer[i] > 0 && Close[i] > SupportBuffer[i] && (Close[i+1] <= SupportBuffer[i] || Open[i] < SupportBuffer[i]))
        ArrowUpBuffer[i] = Low[i] - (Point() * 20);
      else
      ArrowUpBuffer[i] = EMPTY_VALUE;
    if(ResistanceBuffer[i] > 0 && Close[i] < ResistanceBuffer[i] && (Close[i+1] >= ResistanceBuffer[i] || Open[i] > ResistanceBuffer[i]))
        ArrowDnBuffer[i] = High[i] + (Point() * 20);
      else
        ArrowDnBuffer[i] = EMPTY_VALUE;

   }
   
   
//----
   return(0);
  }
//+------------------------------------------------------------------+

int SearchUp(int start){
   for(int i=start;i<Bars-LookBackPeriod;i++){
      if(Close[i] >= iMA(NULL,0,LookBackPeriod,0,MODE_SMA,PRICE_CLOSE,i) && Close[i+1] < iMA(NULL,0,LookBackPeriod,0,MODE_SMA,PRICE_CLOSE,i+1) )break;
   }
   return(i);
}
int SearchDn(int start){
   for(int i=start;i<Bars-LookBackPeriod;i++){
      if(Close[i] <= iMA(NULL,0,LookBackPeriod,0,MODE_SMA,PRICE_CLOSE,i) && Close[i+1] > iMA(NULL,0,LookBackPeriod,0,MODE_SMA,PRICE_CLOSE,i+1) )break;
   }
   return(i);
}
//FOOTER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76340
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