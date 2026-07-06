//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75762

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2

#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrLime
#property indicator_width1 1
#property indicator_style1 STYLE_SOLID

#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_width2 1
#property indicator_style1 STYLE_SOLID

// ENUM_TIMEFRAMES TimeFrame = PERIOD_H4; // Time Frame

input int      RSI_Period     = 4;        // Periodo del RSI
input int      MA_Period      = 2;        // Periodo de la media móvil del RSI
ENUM_MA_METHOD MA_Method      = MODE_SMA; // Método de la media móvil
input double   Arrow_Distance = 3.0;      // Distancia de las flechas

double ArrowUp[];
double ArrowDn[];
int    rsi_handle;

// Función para obtener el valor del RSI
double RSI(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle;
    int    copy  = CopyBuffer(rsi_handle, 0, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    // Configurar los buffers
    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    PlotIndexSetInteger(0, PLOT_ARROW, 233);

    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    PlotIndexSetInteger(1, PLOT_ARROW, 234);

    IndicatorSetString(INDICATOR_SHORTNAME, "SNRB");
    IndicatorSetInteger(INDICATOR_DIGITS, 2);

    rsi_handle = iRSI(NULL, 0, RSI_Period, PRICE_CLOSE);

    return (INIT_SUCCEEDED);
}

int lastSignal = 0;

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
{

    int start = prev_calculated > 0 ? prev_calculated - 1 : 1;

    for (int i = start; i < rates_total; i++) {
        // Calcular el RSI actual y el anterior
        double rsi_current  = RSI(i);
        double rsi_previous = RSI(i + 1);

        // Calcular la media móvil del RSI actual y anterior
        double rsi_sum_current  = 0;
        double rsi_sum_previous = 0;

        for (int j = 0; j < MA_Period; j++) {
            rsi_sum_current += RSI(i + j);
            rsi_sum_previous += RSI(i + j + 1);
        }

        double ma_rsi_current  = rsi_sum_current / MA_Period;
        double ma_rsi_previous = rsi_sum_previous / MA_Period;

        // Generar señales de cruce
        ArrowUp[i] = EMPTY_VALUE;
        ArrowDn[i] = EMPTY_VALUE;

        if (rsi_previous < ma_rsi_previous && rsi_current > ma_rsi_current && lastSignal <= 0) {
            ArrowUp[i] = low[i] - Arrow_Distance * Point();
            lastSignal = 1;
        }

        if (rsi_previous > ma_rsi_previous && rsi_current < ma_rsi_current && lastSignal >= 0) {
            ArrowDn[i] = high[i] + Arrow_Distance * Point();
            lastSignal = -1;
        }
    }

    return (rates_total);
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75762

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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