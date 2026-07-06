/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76301
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
// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"


#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Gold
#property indicator_color2 DodgerBlue
#property indicator_color3 Lime
#property indicator_color4 Red
//������� ���������
extern int bars_for_autoscale = 200;
extern bool inverse = false;
extern bool MA = true;
extern int MAPeriod =14;
extern int MAMethod = 0;
extern bool MAOnly = false;
extern bool MASlopeColor = true;

double simbolBuffer[];
double MABuffer[];
double MASlopeUpBuffer[];
double MASlopeDownBuffer[];

// �������������
int init()
  {
   SetIndexBuffer(0,simbolBuffer);       
   SetIndexStyle (0,DRAW_LINE);
   SetIndexBuffer(1,MABuffer);       
   SetIndexStyle (1,DRAW_LINE);
   SetIndexBuffer(2,MASlopeUpBuffer);       
   SetIndexStyle (2,DRAW_LINE);
   SetIndexBuffer(3,MASlopeDownBuffer);       
   SetIndexStyle (3,DRAW_LINE);
   SetIndexLabel(0, "Symbol Price");
   SetIndexLabel(1, "MA");
   SetIndexLabel(2, "MA Up");
   SetIndexLabel(3, "MA Down");
   return (0);
  }
     
//�������� ����                              

int start()
  {
double simbol_scale = 1;
double simbol_offset = 0;
 int i,k;
int cb=IndicatorCounted();
i = Bars-cb-1;
k = bars_for_autoscale;
if (bars_for_autoscale==0) k=Bars;
double max_scale=Close[1];
double min_scale=Close[1];
double max_scale2=Close[1];
double min_scale2=Close[1];
while(k>=0) 
      {
      
      if (max_scale<Close[k]) max_scale=Close[k];
      if (min_scale>Close[k]) min_scale=Close[k];
      if (max_scale2<Close[k])max_scale2=Close[k];
      if (min_scale2>Close[k])min_scale2=Close[k];
    
    
      k--;
      }

simbol_scale = (max_scale2 - min_scale2)/(max_scale-min_scale);
      if(!inverse) {
 simbol_offset = max_scale2 - simbol_scale*max_scale;
 }
 else
 {
 simbol_offset = max_scale2 + simbol_scale*min_scale;
 }

while(i>=0) 
      {
      
        if(!inverse) 
        {
         if (!MAOnly) simbolBuffer[i]=simbol_scale*Close[i]+simbol_offset;
         if (MA) {
            double ma_value = iMA(NULL,0,MAPeriod,0,MAMethod,PRICE_CLOSE,i)*simbol_scale+simbol_offset;
            MABuffer[i] = ma_value;
            
            if (MASlopeColor && i < Bars-1) {
               double ma_prev = iMA(NULL,0,MAPeriod,0,MAMethod,PRICE_CLOSE,i+1)*simbol_scale+simbol_offset;
               if (ma_value > ma_prev) {
                  MASlopeUpBuffer[i] = ma_value;
                  MASlopeDownBuffer[i] = EMPTY_VALUE;
               } else if (ma_value < ma_prev) {
                  MASlopeDownBuffer[i] = ma_value;
                  MASlopeUpBuffer[i] = EMPTY_VALUE;
               } else {
                  MASlopeUpBuffer[i] = EMPTY_VALUE;
                  MASlopeDownBuffer[i] = EMPTY_VALUE;
               }
            } else {
               MASlopeUpBuffer[i] = EMPTY_VALUE;
               MASlopeDownBuffer[i] = EMPTY_VALUE;
            }
         }
         }
        else 
        {
        if (!MAOnly) simbolBuffer[i]=simbol_offset - simbol_scale*Close[i];
        if (MA) {
           double ma_value_inv = simbol_offset - simbol_scale*(iMA(NULL,0,MAPeriod,0,MAMethod,PRICE_CLOSE,i));
           MABuffer[i] = ma_value_inv;
           
           if (MASlopeColor && i < Bars-1) {
              double ma_prev_inv = simbol_offset - simbol_scale*(iMA(NULL,0,MAPeriod,0,MAMethod,PRICE_CLOSE,i+1));
              if (ma_value_inv > ma_prev_inv) {
                 MASlopeUpBuffer[i] = ma_value_inv;
                 MASlopeDownBuffer[i] = EMPTY_VALUE;
              } else if (ma_value_inv < ma_prev_inv) {
                 MASlopeDownBuffer[i] = ma_value_inv;
                 MASlopeUpBuffer[i] = EMPTY_VALUE;
              } else {
                 MASlopeUpBuffer[i] = EMPTY_VALUE;
                 MASlopeDownBuffer[i] = EMPTY_VALUE;
              }
           } else {
              MASlopeUpBuffer[i] = EMPTY_VALUE;
              MASlopeDownBuffer[i] = EMPTY_VALUE;
           }
        }
        }
          i--;
      }

   
   return(0);
  }


/*
── Project ─────────────────────────────────────────────────────────────────────

Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76301
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
