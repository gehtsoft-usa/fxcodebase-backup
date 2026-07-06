//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73953

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
#property link      "http://fxcodebase.com"
#property version "1.0"

#include <Math/Stat/Math.mqh>

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 2
#property indicator_type1  DRAW_LINE
#property indicator_color1 Blue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label1 "Top"
#property indicator_type2  DRAW_LINE
#property indicator_color2 Tomato
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label2 "Bottom"

//--- indicator buffers
double TopLine [];
double BotLine [];
double Std [];
double VolDer [];
double BOTy [];
double TOPy [];

//--- indicator input
input int Period = 10;  // Indicator Periods

//--- indicator input
input int    Periods = 18;   // Periods
input int    Smooth = 2;    // Smoothness
input int    cp = 10;   // Fractals periods
input double change = 0.1;  // Percent change to modify the upper/lower channel

// ------------------------------------------------------------------
void OnInit()
{
    SetIndexBuffer(0, TopLine);
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    SetIndexBuffer(1, BotLine);
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

    SetIndexBuffer(2, Std, INDICATOR_CALCULATIONS);
    SetIndexBuffer(3, VolDer, INDICATOR_CALCULATIONS);
    SetIndexBuffer(4, BOTy, INDICATOR_CALCULATIONS);
    SetIndexBuffer(5, TOPy, INDICATOR_CALCULATIONS);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time [],
                const double& open [],
                const double& high [],
                const double& low [],
                const double& close [],
                const long& tick_volume [],
                const long& volume [],
                const int& spread [])
{
    if(rates_total < Period) return (0);

    int start = 100;
    if(prev_calculated > 1)
        start = prev_calculated - 1;
    //   else { start = Periods + 1; }

    for(int i = start; i < rates_total && !IsStopped(); i++)
    {

    BOTy[i]    = 0;
    TOPy[i]    = 0;
    TopLine[i] = 0;
    BotLine[i] = 0;
    
    // array de cierres para calcular el devío st
        // ------------------------------------------------------------------
        double closes [];
        ArrayResize(closes, Periods);

        for(int p = 0; p < Periods; p++)
        {
            closes[p] = close[i - p];
        }
        Std[i] = MathStandardDeviation(closes);

        // calculo VolDer:
        // ------------------------------------------------------------------
        // tomar los valors max y min del rango de desvíos st
        int minpos = ArrayMinimum(Std, i - 1 - Periods, i - 1);
        int maxpos = ArrayMaximum(Std, i - 1 - Periods, i - 1);

        double Actual_Menos_Maximo = Std[i] - Std[maxpos];
        double Maximo_Menos_Minimo = Std[maxpos] - Std[minpos];

        VolDer[i] = Actual_Menos_Maximo / Maximo_Menos_Minimo;

        // calculo VolSmooth:
        // ------------------------------------------------------------------
        double VolSmooth = avg(VolDer, i - Smooth, i);

        // Print(__FUNCTION__, " VolSmooth: ", VolSmooth);

        if(VolSmooth > 0) VolSmooth = 0;
        if(VolSmooth < -0.1) VolSmooth = -1;

        // ------------------------------------------------------------------

        // NOTE: busco LH LL
        // ------------------------------------------------------------------
        int count = (2 * cp) + 1;
        int hiBar = i - iHighest(NULL, 0, MODE_HIGH, count);
        int loBar = i - iLowest(NULL, 0, MODE_LOW, count);

        double highest = high[hiBar];
        double lowest = low[loBar];

        int LH = high[i - cp] >= highest ?  1 : 0;
        int LL = low[i - cp]  <= lowest  ? -1 : 0;
        // ------------------------------------------------------------------

        
        // copio los valores anteriores de cada buffer
        // ------------------------------------------------------------------
        BOTy[i] = BOTy[i - 1];
        TOPy[i] = TOPy[i - 1];
        TopLine[i] = TopLine[i - 1];
        BotLine[i] = BotLine[i - 1];

        if(LH == 1)  TOPy[i] = high[i - cp];
        if(LL == -1) BOTy[i] = low[i - cp];
        // ------------------------------------------------------------------


        // 
        // ------------------------------------------------------------------
        double ch = change / 100;
        if(VolSmooth == -1)
        {
            if( fabs(TOPy[i] - TopLine[i]) / close[i] > ch)
            {
                TopLine[i] = TOPy[i];
            }

            if( fabs(BOTy[i] - BotLine[i]) / close[i] > ch)
            {
                BotLine[i] = BOTy[i];
            }
        }
        // ------------------------------------------------------------------


    }

    return (rates_total);
}

//+------------------------------------------------------------------+
double avg(double& array [], int from, int to)
{
    int    n = 0;
    double sum = 0;
    for(int i = from; i < to; i++)
    {
        sum += array[i];
        n++;
    }
    return sum / n;
}

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