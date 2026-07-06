//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76363
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

#property indicator_separate_window

#property indicator_buffers 5 
#property indicator_plots   1 
#property indicator_label1  "ColorCandles" 
#property indicator_type1   DRAW_COLOR_CANDLES 
#property indicator_color1  Green, Crimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- indicator buffers
double line[];

//--- búfers indicadores 
double    buf_open[]; 
double    buf_high[]; 
double    buf_low[]; 
double    buf_close[]; 
double    buf_color[]; 

// Declarar el handle globalmente
int zigzag_handle = INVALID_HANDLE;



// ------------------------------------------------------------------
void OnInit()
{
  //--- indicator buffers mapping 
   SetIndexBuffer(0,buf_open,INDICATOR_DATA); 
   SetIndexBuffer(1,buf_high,INDICATOR_DATA); 
   SetIndexBuffer(2,buf_low,INDICATOR_DATA); 
   SetIndexBuffer(3,buf_close,INDICATOR_DATA); 
   SetIndexBuffer(4,buf_color,INDICATOR_COLOR_INDEX); 

     zigzag_handle = iCustom(_Symbol, _Period, "ZigZag");
    // Verifica si el handle es válido
    if(zigzag_handle == INVALID_HANDLE)
        Print("Error al cargar ZigZag externo");
    
   IndicatorSetInteger(INDICATOR_LEVELS,1); 
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0); 

//--- valor vacío 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0); 
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
  // clang-format off
	int start;
  if (prev_calculated > 1) start = prev_calculated - 1; else { start = 100 + 1; }
  // clang-format on

double zz_buffer[];

// Por ejemplo, para el primer buffer del ZigZag (extremos)
int copied = CopyBuffer(zigzag_handle, 0, 0, rates_total, zz_buffer);
if(copied != rates_total) Print("Error al copiar buffer ZigZag");


  for (int i = start; i < rates_total && !IsStopped(); i++) 
	{

    int last_zz = GetLastZigZagPoint(zz_buffer, i);
    double price_zz = zz_buffer[last_zz];
    
    buf_open[i]  = open[i]  - price_zz;
    buf_high[i]  = high[i]  - price_zz;
    buf_low[i]   = low[i]   - price_zz;
    buf_close[i] = close[i] - price_zz;
	
    // if(close[i] > price_zz) buf_color[i] = 0; else buf_color[i] = 1;

	// NOTE: set color
    if (open[i] < close[i]) {
      buf_color[i] = 0;
    } else {
      buf_color[i] = 1;
    }
  

}

  return (rates_total);
}
//+------------------------------------------------------------------+

int GetLastZigZagPoint(const double &ZigZagBuffer[], int current_bar)
{
    int count = 0;
    for(int i = current_bar; i >= 0; i--)
    {
        if(ZigZagBuffer[i] != 0.0 && ZigZagBuffer[i] != EMPTY_VALUE)
        {
            if(count == 0)
            {
                count ++;
                continue;
            }
            return i;
        }
    }
    return -1; // No se encontró extremo
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76363
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