//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75836

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
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
#property indicator_color1 Blue
#property indicator_color2 Red

double UpArrowBuffer[];
double DownArrowBuffer[];

input int FastEMA = 12;
input int SlowEMA = 26;
input int SignalSMA = 9;

int OnInit()
{
    SetIndexBuffer(0, UpArrowBuffer);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 2);
    SetIndexArrow(0, 233); // Código ASCII para flecha hacia arriba

    SetIndexBuffer(1, DownArrowBuffer);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 2);
    SetIndexArrow(1, 234); // Código ASCII para flecha hacia abajo

    return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    if (rates_total < SlowEMA + SignalSMA) return 0;

    for (int i = rates_total - 1; i >= prev_calculated; i--)
    {
        double macdCurrent = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, i);
        double signalCurrent = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, i);
        double macdPrevious = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, i + 1);
        double signalPrevious = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, i + 1);

        // Detectar cruce dorado (Golden Cross)
        if (macdCurrent > signalCurrent && macdPrevious <= signalPrevious)
        {
            // buscar el cruce dorado anterior
            for (int j = i + 1; j < rates_total; j++)
            {
                double macd1 = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, j);
                double signal1 = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, j);
                double macd2 = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, j+1);
                double signal2 = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, j+1);
                
                if (macd1 > signal1 && macd2 <= signal2)
                {
                    if (macd1 <0 && macdCurrent<0)
                    {
                        double low1 = low[i + 1]; // Low de la vela anterior
                        UpArrowBuffer[i] = low1; 
                        break;
                    }                    
                }
            }
        }


        // ----------

        // Detectar cruce de la muerte (Death Cross)
        if (macdCurrent < signalCurrent && macdPrevious >= signalPrevious)
        {
            // buscar el cruce anterior
            for (int j = i + 1; j < rates_total; j++)
            {
                double macd1 = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, j);
                double signal1 = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, j);
                double macd2 = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, j+1);
                double signal2 = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, j+1);
                
                if (macd1 < signal1 && macd2 >= signal2)
                {
                    if (macd1 >0 && macdCurrent>0)
                    {
                        double lastHigh = high[i + 1]; // High de la vela anterior
                        DownArrowBuffer[i] = lastHigh; // Colocar flecha hacia abajo
                        break;
                    }                    
                }
            }
        }
    }
            

    return(rates_total);
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75836

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
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