// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68850

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.2"
#property strict

#property indicator_separate_window
#property indicator_buffers 2
//--- indicator buffers
double bp[];
double sp[];
double tmp_bp[];
double tmp_sp[];
double nsp[];
double nbp[];
double diff[], nv[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
    SetIndexBuffer(0, bp);
    SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2, clrMediumSeaGreen);
    SetIndexBuffer(1, sp);
    SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2, clrCrimson);

    IndicatorBuffers(7);

    SetIndexBuffer(2, tmp_bp);
    SetIndexBuffer(3, nbp);
    SetIndexBuffer(4, tmp_sp);
    SetIndexBuffer(5, nsp);
    SetIndexBuffer(6, diff);

    return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
    if (Bars <= 1)
        return 0;
    int ExtCountedBars = IndicatorCounted();

    if (IndicatorCounted() <= 0)
    {
        for (int i = 0; i < rates_total; i++)
        {
            bp[i]     = EMPTY_VALUE;
            sp[i]     = EMPTY_VALUE;
            tmp_bp[i] = EMPTY_VALUE;
            tmp_sp[i] = EMPTY_VALUE;
            nsp[i]    = EMPTY_VALUE;
            nbp[i]    = EMPTY_VALUE;
            diff[i]   = EMPTY_VALUE;
        }
    }

    if (ExtCountedBars < 0)
        return -1;

    int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
    for (int i = limit; i >= 0; --i)
    {
        tmp_sp[i] = high[i] - close[i];
        tmp_bp[i] = close[i] - low[i];

        double tmp_sp_ma = iMAOnArray(tmp_sp, 0, 80, 0, MODE_EMA, i);
        nsp[i] = tmp_sp_ma == 0 ? 0 : (tmp_sp[i] / tmp_sp_ma);

        double tmp_bp_ma = iMAOnArray(tmp_bp, 0, 80, 0, MODE_EMA, i);
        nbp[i] = tmp_bp_ma == 0 ? 0 : tmp_bp[i] / tmp_bp_ma;

        diff[i] = iMAOnArray(nsp, 0, 20, 0, MODE_EMA, i) - iMAOnArray(nbp, 0, 20, 0, MODE_EMA, i);
        if (diff[i] > 0)
            bp[i] = diff[i];
        if (diff[i] < 0)
            sp[i] = diff[i];
    }
//--- return value of prev_calculated for next call
    return(rates_total);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
//---
}