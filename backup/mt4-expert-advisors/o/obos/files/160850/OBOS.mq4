//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76367
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
 

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_separate_window
#property indicator_buffers 15
#property indicator_color1 Green
#property indicator_color2 Yellow
#property indicator_color3 Green
#property indicator_color4 Yellow

extern int Length=9;
extern int MaxBars=100;
extern color UP_Color=Green;
extern color DN_Color=Red;
extern color OB_Color=Blue;

double Buff5[], Buff6[], Up[], Dn[];
double UpH[], UpL[], UpN[], DnH[], DnL[], DnN[], ZH[], ZL[], ZN[];

double ArrowUp[];
double ArrowDn[];

int init()
  {
   IndicatorShortName("Overbought/Oversold Indicator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Up);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Dn);
   SetIndexStyle(2,DRAW_NONE, EMPTY, EMPTY, UP_Color);
   SetIndexBuffer(2,UpH);
   SetIndexStyle(3,DRAW_NONE, EMPTY, EMPTY, UP_Color);
   SetIndexBuffer(3,DnH);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,ZH);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,Buff5);
   SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(6,Buff6);
   SetIndexStyle(7,DRAW_NONE, EMPTY, EMPTY, DN_Color);
   SetIndexBuffer(7,UpL);
   SetIndexStyle(8,DRAW_NONE, EMPTY, EMPTY, DN_Color);
   SetIndexBuffer(8,DnL);
   SetIndexStyle(9,DRAW_NONE);
   SetIndexBuffer(9,ZL);
   SetIndexStyle(10,DRAW_NONE, EMPTY, EMPTY, OB_Color);
   SetIndexBuffer(10,UpN);
   SetIndexStyle(11,DRAW_NONE, EMPTY, EMPTY, OB_Color);
   SetIndexBuffer(11,DnN);
   SetIndexStyle(12,DRAW_NONE);
   SetIndexBuffer(12,ZN);

   SetIndexBuffer(13, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(13, 233);
    SetIndexStyle(13, DRAW_ARROW, EMPTY, 1, Blue);
    SetIndexLabel(13, "Arrow Up");

   SetIndexBuffer(14, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(14, DRAW_ARROW, EMPTY, 1, Crimson);
    SetIndexArrow(14, 234);
    SetIndexLabel(14, "Arrow Dn");



   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 limit=MathMax(limit, MaxBars);
 pos=limit;
 double Buff1, Buff3, Buff4;
 while(pos>=0)
 {
  Buff1=(High[pos]+Low[pos]+Close[pos]+Close[pos])/4;
  Buff3=iMA(NULL, 0, Length, 0, MODE_EMA, PRICE_WEIGHTED, pos);
  Buff4=iStdDev(NULL, 0, Length, 0, MODE_EMA, PRICE_WEIGHTED, pos);
  if (Buff4!=0) 
  {
   Buff5[pos]=(Buff1-Buff3)*100/Buff4; 
  } 
  pos--;
 } 
 pos=limit;
 while(pos>=0)
 {
  Buff6[pos]=iMAOnArray(Buff5, 0, Length, 0, MODE_EMA, pos);
  pos--;
 }
 pos=limit;
 while(pos>=0)
 {
  Up[pos]=iMAOnArray(Buff6, 0, Length, 0, MODE_EMA, pos);
  pos--;
 }
 pos=limit - 1;
 
    while(pos>=0)
    {
        Dn[pos]=iMAOnArray(Up, 0, Length, 0, MODE_EMA, pos);
        if (Up[pos + 1] < Up[pos] && Dn[pos + 1] < Dn[pos])
        {
            if (Up[pos] > 0 && Dn[pos] > 0)
            {
                UpH[pos] = MathMax(Dn[pos], Up[pos]);
                ZH[pos] = MathMin(Dn[pos], Up[pos]);
            }
            else if (Up[pos] < 0 && Dn[pos] < 0)
            {
                DnH[pos] = MathMin(Dn[pos], Up[pos]);
                ZH[pos] = MathMax(Dn[pos], Up[pos]);
            }
            else
            {
                UpH[pos] = MathMax(Dn[pos], Up[pos]);
                DnH[pos] = MathMin(Dn[pos], Up[pos]);
            }
        }
        else if (Up[pos + 1] > Up[pos] && Dn[pos + 1] > Dn[pos])
        {
            if (Up[pos] > 0 && Dn[pos] > 0)
            {
                UpL[pos] = MathMax(Dn[pos], Up[pos]);
                ZL[pos] = MathMin(Dn[pos], Up[pos]);
            }
            else if (Up[pos] < 0 && Dn[pos] < 0)
            {
                DnL[pos] = MathMin(Dn[pos], Up[pos]);
                ZL[pos] = MathMax(Dn[pos], Up[pos]);
            }
            else
            {
                UpL[pos] = MathMax(Dn[pos], Up[pos]);
                DnL[pos] = MathMin(Dn[pos], Up[pos]);
            }
        }
        else
        {
            if (Up[pos] > 0 && Dn[pos] > 0)
            {
                UpN[pos] = MathMax(Dn[pos], Up[pos]);
                ZN[pos] = MathMin(Dn[pos], Up[pos]);
            }
            else if (Up[pos] < 0 && Dn[pos] < 0)
            {
                DnN[pos] = MathMin(Dn[pos], Up[pos]);
                ZN[pos] = MathMax(Dn[pos], Up[pos]);
            }
            else
            {
                UpN[pos] = MathMax(Dn[pos], Up[pos]);
                DnN[pos] = MathMin(Dn[pos], Up[pos]);
            }
        }
        

        int i = pos;
        if (Up[i] > Dn[i] && Up[i + 1] < Dn[i + 1]) {
            ArrowUp[i] =  Dn[i];
        }

        if (Up[i] < Dn[i] && Up[i + 1] > Dn[i + 1]) {
            ArrowDn[i] =  Up[i];
        }

        pos--;
    }

    return(0);
}


//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76367
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