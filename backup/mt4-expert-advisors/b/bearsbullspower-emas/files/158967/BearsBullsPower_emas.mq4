//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75834

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
//--
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots 4
#property indicator_width1 2
#property indicator_width2 2
// #property indicator_width3 2
#property indicator_label1 "BullsPower"
#property indicator_label2 "BearsPower"
//--- input parameter
input int   InpPeriod  = 13;        // Power Period
input color BullsColor = clrAqua;   // Bulls Color
input color BearsColor = clrYellow; // Beasr Color
input bool draw_emas = true; // Draw EMAs
//--- buffers
double ExtBearsBuffer[];
double ExtBullsBuffer[];
double ExtBullBuffer1[];
double ExtTempBuffer1[];

double emaBears[];
double emaBulls[];

//--
string short_name;
//---------//

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- 1 additional buffer used for counting.
    IndicatorBuffers(6);
    IndicatorDigits(Digits);
    //--- indicator line
    SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, EMPTY, BullsColor);
    SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, EMPTY, BearsColor);
   //  SetIndexStyle(2, DRAW_HISTOGRAM, EMPTY, EMPTY, BullsColor);
    //--
    SetIndexBuffer(0, ExtBullsBuffer);
    SetIndexBuffer(1, ExtBearsBuffer);
    
   SetIndexBuffer(2, emaBears, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_LINE, STYLE_SOLID, 1, Orange);
    SetIndexLabel(2, "EMA BEARS");
    
   SetIndexBuffer(3, emaBulls, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_LINE, STYLE_SOLID, 1, Blue);
    SetIndexLabel(3, "EMA BULLS");
    
    
    SetIndexBuffer(4, ExtBullBuffer1);
    SetIndexStyle(4, DRAW_NONE);
    SetIndexBuffer(5, ExtTempBuffer1);
    SetIndexLabel(5, NULL);
    SetIndexStyle(5, DRAW_NONE);


    ArrayInitialize(emaBulls, 0);
    ArrayInitialize(emaBears, 0);

    //--- name for DataWindow and indicator subwindow label
    short_name = "BBPower(" + IntegerToString(InpPeriod) + ")";
    IndicatorShortName(short_name);
    //---
    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],const long &tick_volume[], const long &volume[], const int &spread[])
{
    //---
    int limit = rates_total - prev_calculated;
    //---
    if (rates_total <= InpPeriod) return (0);
    //---
    if (prev_calculated > 0) limit++;
    for (int i = 0; i < limit; i++) {
        ExtTempBuffer1[i] = iMA(NULL, 0, InpPeriod, 0, MODE_EMA, PRICE_CLOSE, i);
        ExtBullsBuffer[i] = high[i] - ExtTempBuffer1[i];
        ExtBearsBuffer[i] = low[i] - ExtTempBuffer1[i];
        if (ExtBullsBuffer[i] < 0.0) ExtBullBuffer1[i] = ExtBullsBuffer[i];
    
    
        //   EMAS
        if(draw_emas)
        {
           emaBears[i] = ExtBearsBuffer[i];
           emaBulls[i] = ExtBullsBuffer[i];
           
           if (i>0) {
              double multiplier = 2.0 / (InpPeriod + 1);
              emaBears[i] = (ExtBearsBuffer[i] - emaBears[i - 1]) * multiplier + emaBears[i - 1];
              emaBulls[i] = (ExtBullsBuffer[i] - emaBulls[i - 1]) * multiplier + emaBulls[i - 1];
            }
         }
    }

   //  CalculateEMABulls(rates_total, InpPeriod);
   //  CalculateEMABears(rates_total, InpPeriod);

    //--- return value of prev_calculated for next call
    return (rates_total);
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

// void CalculateEMABears(const int i)
// {

//     emaBears[i-1] = ExtBearsBuffer[i-1];

//     // Constante de suavizado para la EMA
//     double multiplier = 2.0 / (InpPeriod + 1);

//     // Calcular la EMA para cada índice
//     for (int i = 1; i < rates_total; i++) {
//         emaBears[i] = (ExtBearsBuffer[i] - emaBears[i - 1]) * multiplier + emaBears[i - 1];
//     }
// }

// void CalculateEMABulls(const int rates_total, const int period)
// {
//     // Verificar si hay suficientes datos para calcular la EMA
//     if (rates_total <= period) return;

//     // Inicializar el primer valor de la EMA con el primer valor del buffer
//     emaBulls[0] = ExtBullsBuffer[0];

//     // Constante de suavizado para la EMA
//     double multiplier = 2.0 / (period + 1);

//     // Calcular la EMA para cada índice
//     for (int i = 1; i < rates_total; i++) {
//         emaBulls[i] = (ExtBullsBuffer[i] - emaBulls[i - 1]) * multiplier + emaBulls[i - 1];
//     }
// }
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75834

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