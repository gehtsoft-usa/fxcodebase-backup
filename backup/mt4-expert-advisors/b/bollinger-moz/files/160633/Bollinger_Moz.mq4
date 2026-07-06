//HEADER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76324
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
#property indicator_buffers 5
#property indicator_plots   2

#property indicator_label1  "UP"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLimeGreen
#property indicator_width1  1

#property indicator_label2  "DN"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrTomato
#property indicator_width2  1

input int    BandsPeriod        = 20;   // Bollinger period
input double BandsDeviation     = 2.0;  // Bollinger deviation
input int    BandsShift         = 0;    // Bollinger shift
input double ArrowOffsetPoints  = 20.0; // Arrow offset (points)

double UpArrowBuffer[];
double DownArrowBuffer[];
double MyBoll[]; 
double MyBoll2[];
double MyBoll3[];

int OnInit()
{
   IndicatorDigits(_Digits);

	SetIndexBuffer(0, UpArrowBuffer); 
	SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 1, clrLimeGreen);
	SetIndexArrow(0, 233);
	SetIndexLabel(0, "UP");
	SetIndexDrawBegin(0, BandsPeriod);

	SetIndexBuffer(1, DownArrowBuffer);
	SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 1, clrTomato);
	SetIndexArrow(1, 234);
	SetIndexLabel(1, "DN");
	SetIndexDrawBegin(1, BandsPeriod);

    SetIndexBuffer(2, MyBoll);
    SetIndexBuffer(3, MyBoll2);
    SetIndexBuffer(4, MyBoll3);

    SetIndexStyle(2, DRAW_NONE);
    SetIndexStyle(3, DRAW_NONE);    
    SetIndexStyle(4, DRAW_NONE);

	ArraySetAsSeries(UpArrowBuffer, true);
	ArraySetAsSeries(DownArrowBuffer, true);

    ArraySetAsSeries(MyBoll, true);
	ArraySetAsSeries(MyBoll2, true);
	ArraySetAsSeries(MyBoll3, true);

	IndicatorShortName("Bollinger MOZ");

	return(INIT_SUCCEEDED);
}

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
	if(rates_total <= BandsPeriod)
		return(0);

	int start = prev_calculated;
    int i;
	if(start == 0)
	{
		ArrayInitialize(UpArrowBuffer, EMPTY_VALUE);
		ArrayInitialize(DownArrowBuffer, EMPTY_VALUE);
		start = BandsPeriod;
	}
	else
	{
		start--;
		if(start < BandsPeriod)
			start = BandsPeriod;
	}

	const double offset = ArrowOffsetPoints * Point();

    static double upBollState[];
    static double downBollState[];
    static bool   stateInit = false;

    if(!stateInit)
    {
        ArraySetAsSeries(upBollState, true);
        ArraySetAsSeries(downBollState, true);
        stateInit = true;
    }

    if(ArraySize(upBollState) != rates_total)
    {
        ArrayResize(upBollState, rates_total);
        ArrayResize(downBollState, rates_total);
        if(prev_calculated == 0)
        {
            ArrayInitialize(upBollState, 0.0);
            ArrayInitialize(downBollState, 0.0);
        }
    }

    const int first = BandsPeriod;

    for(i = rates_total - 1; i >= 0; --i)
    {
        UpArrowBuffer[i]   = EMPTY_VALUE;
        DownArrowBuffer[i] = EMPTY_VALUE;

        if(i >= rates_total - first)
        {
            MyBoll[i] = MyBoll2[i] = MyBoll3[i] = 0.0;
            upBollState[i] = downBollState[i] = 0.0;
            continue;
        }

        double upper = iBands(NULL, 0, BandsPeriod, BandsDeviation, BandsShift, PRICE_CLOSE, MODE_UPPER, i);
        double lower = iBands(NULL, 0, BandsPeriod, BandsDeviation, BandsShift, PRICE_CLOSE, MODE_LOWER, i);
        double range = upper - lower;

        if(range == 0.0)
        {
            MyBoll[i] = MyBoll2[i] = MyBoll3[i] = 0.0;
            upBollState[i] = downBollState[i] = 0.0;
            continue;
        }

        MyBoll[i]  = (close[i] - lower) / range * 100.0;
        MyBoll2[i] = (high[i]  - lower) / range * 100.0;
        MyBoll3[i] = (low[i]   - lower) / range * 100.0;

        if(i + 2 >= rates_total)
        {
            upBollState[i] = downBollState[i] = 0.0;
            continue;
        }

        double x = (MyBoll2[i] + MyBoll2[i + 1] + MyBoll2[i + 2]) / 3.0;
        double y = (MyBoll3[i] + MyBoll3[i + 1] + MyBoll3[i + 2]) / 3.0;

        if(MyBoll[i] >= 50.0)
        {
            upBollState[i]   = (x > 100.0) ? 1.0 : 0.0;
            downBollState[i] = 0.0;
        }
        else
        {
            downBollState[i] = (y < 0.0) ? 1.0 : 0.0;
            upBollState[i]   = 0.0;
        }

        if(i + 1 < rates_total)
        {
            if(upBollState[i + 1] > 0.0 && upBollState[i] == 0.0)
            {
                double maxValue = MathMax(high[i], high[i + 1]);
                DownArrowBuffer[i] = maxValue + offset;
            }

            if(downBollState[i + 1] > 0.0 && downBollState[i] == 0.0)
            {
                double minValue = MathMin(low[i], low[i + 1]);
                UpArrowBuffer[i] = minValue - offset;
            }
        }
    }

	return(rates_total);
}
//FOOTER:BEGIN
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76324
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