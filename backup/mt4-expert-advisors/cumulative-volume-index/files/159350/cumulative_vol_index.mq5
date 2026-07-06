//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=157298#p157298

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_type1  DRAW_COLOR_LINE
// #property indicator_color1 clrGreen
// #property indicator_color2 clrRed
#property indicator_color1 Green, Crimson
#property indicator_width1 1
// #property indicator_width2 1

input int Length = 60;
input bool Combined = true;
input bool Relative = false;

double Positive[], Negative[], Cumulative[];
double APos[], ANeg[];
double lineColor[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    IndicatorSetString(INDICATOR_SHORTNAME, "Cumulative Volume");
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

    if (Combined)
    {
        SetIndexBuffer(0, Cumulative, INDICATOR_DATA);
        PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_COLOR_LINE);
        SetIndexBuffer(1, lineColor, INDICATOR_COLOR_INDEX);
        
        SetIndexBuffer(2, Positive, INDICATOR_DATA);
        PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
        SetIndexBuffer(3, Negative, INDICATOR_DATA);
        PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
        SetIndexBuffer(4, APos, INDICATOR_DATA);
        PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_NONE);
        SetIndexBuffer(5, ANeg, INDICATOR_DATA);
        PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_NONE);
    }
    else
    {
        SetIndexBuffer(0, Positive, INDICATOR_DATA);
        PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
        SetIndexBuffer(1, lineColor, INDICATOR_COLOR_INDEX);
        SetIndexBuffer(2, Negative, INDICATOR_DATA);
        PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);        
        SetIndexBuffer(3, APos, INDICATOR_DATA);
        PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
        SetIndexBuffer(4, ANeg, INDICATOR_DATA);
        PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_NONE);
    }



    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    // No specific deinitialization required
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
    // if (rates_total <= Length)
        // return(0);

    // int limit = rates_total - prev_calculated;
    // if (prev_calculated > 0)
    //     limit++;

    // for (int pos = limit - 1; pos >= 0; --pos)

  int start = Length + 1; int pos = 0;
  if (prev_calculated > 1) start = prev_calculated - 1;

  for (pos = start; pos < rates_total; pos++)
    {
        if (close[pos] > close[pos - 1])
        {
            APos[pos] = tick_volume[pos] / 100.0;
            ANeg[pos] = 0;
        }
        else
        {
            APos[pos] = 0;
            ANeg[pos] = tick_volume[pos] / 100.0;
        }

        // double p = iMAOnArray(APos, 0, Length, 0, MODE_SMA, pos) * Length;
        // double n = iMAOnArray(ANeg, 0, Length, 0, MODE_SMA, pos) * Length;
        double p = CustomSMA(APos, Length, pos) * Length;
        double n = CustomSMA(ANeg, Length, pos) * Length;

        // if (pos > rates_total - 1 - Length)
        // continue;

        double SVolume = 0.0;
        for (int i = 0; i < Length; i++)
        {
            SVolume += tick_volume[pos - i];
        }
        SVolume /= 100.0;

        if (Combined)
        {
            if (Relative)
                Cumulative[pos] = (p - n) * 1000.0 / SVolume;
            else
                Cumulative[pos] = p - n;
        }
        else
        {
            if (Relative)
            {
                Positive[pos] = p * 1000.0 / SVolume;
                Negative[pos] = -n * 1000.0 / SVolume;
            }
            else
            {
                Positive[pos] = p;
                Negative[pos] = -n;
            }
        }

        if (Cumulative[pos] > 0) {
            lineColor[pos]=0;
        } else {
            lineColor[pos]=1;
        }
    }

    return(rates_total);
}

//+------------------------------------------------------------------+
//| Custom SMA function                                              |
//+------------------------------------------------------------------+
double CustomSMA(const double &array[], int length, int pos)
{
    double sum = 0.0;
    for (int i = 0; i < length; i++)
    {
        sum += array[pos - i];
    }
    return sum / length;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=157298#p157298

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 