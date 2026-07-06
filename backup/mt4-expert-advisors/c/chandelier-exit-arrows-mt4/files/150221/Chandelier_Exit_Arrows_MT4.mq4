// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73553

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 6
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrDodgerBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrMagenta
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
//--- indicator buffers
double BuySignal[];
double SellSignal[];

double atr[];
double longStop[];
double shortStop[];
double dir[];
//--- indicator variables
int    atr_period;
double atr_multiplier;

// ------------------------------------------------------------------
//--- input parameters
input int    inp_atr_period     = 22;    // ATR Period (min val: 1; step val: 1)
input double inp_atr_multiplier = 3.0;   // ATR Multiplier (min val: 0.1; step val: 0.1)
input bool   inp_use_close      = true;  // Use Close Price as Extremums?

// ------------------------------------------------------------------
input string T2                    = "== Set Arrows ==";     // ————————————
bool         ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrDodgerBlue;          // Arrow Up Color:
input color  ArrowDnClr            = clrMagenta;             // Arrow Down Color:
// ------------------------------------------------------------------


// ------------------------------------------------------------------
int OnInit()
{
    atr_period     = inp_atr_period < 1 ? 1 : inp_atr_period;
    atr_multiplier = inp_atr_multiplier < 0.1 ? 0.1 : NormalizeDouble(inp_atr_multiplier, 1);

    //--- indicator buffers mapping
    SetIndexBuffer(0, BuySignal, INDICATOR_DATA);
    SetIndexArrow(0, 225);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexBuffer(1, SellSignal, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(1, 226);

    SetIndexBuffer(2, atr, INDICATOR_CALCULATIONS);
    SetIndexBuffer(3, longStop, INDICATOR_CALCULATIONS);
    SetIndexBuffer(4, shortStop, INDICATOR_CALCULATIONS);
    SetIndexBuffer(5, dir, INDICATOR_CALCULATIONS);
    
		 SetIndexStyle(2,DRAW_NONE,EMPTY,2,clrBlue);
		 SetIndexStyle(3,DRAW_NONE,EMPTY,2,clrGreen);
		 SetIndexStyle(4,DRAW_NONE,EMPTY,2,clrRed);

		 SetIndexLabel(2,"atr");
		 SetIndexLabel(3,"LongStop");
		 SetIndexLabel(4,"ShortStop");

    //---
    return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}
// ------------------------------------------------------------------

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
    //--- populate ATR buffer
    // inAverageTrueRange(rates_total, prev_calculated, atr_period, high, low, close, atr);

    double alpha = 1.0 / double(atr_period);

    //---
    int i = rates_total - (atr_period + prev_calculated + 1);
    if (i >= rates_total) i = rates_total - 1;
    for (; i > 0; i--)
    {
        double true_range = i < 1 ? high[i] - low[i] : fmax(high[i] - low[i], fmax(fabs(high[i] - close[i + 1]), fabs(low[i] - close[i + 1])));
        if (i < 1)
            atr[i] = true_range;
        else
            atr[i] = true_range * alpha + atr[i + 1] * (1.0 - alpha);

        //---

        double hh=0;
        double ll=10000000;
        double atr_mult = atr_multiplier * atr[i];
				for (int k = 0; k < atr_period; k++)
        {
            hh = inp_use_close == true ? (close[i + k] > hh ? close[i + k] : hh) : (high[i + k] > hh ? high[i + k] : hh);
            ll = inp_use_close == true ? (close[i + k] < ll ? close[i + k] : ll) : (low[i + k] < ll ? low[i + k] : ll);
        }
	
	  				longStop[i]   = hh - atr_mult;
            longStop[i]   = close[i + 1] > longStop[i + 1] ? fmax(longStop[i], longStop[i + 1]) : longStop[i];
            shortStop[i]  = ll + atr_mult;
            shortStop[i]  = close[i + 1] < shortStop[i + 1] ? fmin(shortStop[i], shortStop[i + 1]) : shortStop[i];

            dir[i]        = close[i] > shortStop[i + 1] ? 1.0 : close[i] < longStop[i + 1] ? -1.0
                                                                                           : dir[i + 1];
            BuySignal[i]  = dir[i] == 1.0 && dir[i + 1] == -1.0 ? low[i] : EMPTY_VALUE;
            SellSignal[i] = dir[i] == -1.0 && dir[i + 1] == 1.0 ? high[i] : EMPTY_VALUE;
    }

    return (rates_total);
}

// ------------------------------------------------------------------


//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 |
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |
//+------------------------------------------------------------------------------------------------+