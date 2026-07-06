//Available @ http://fxcodebase.com

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_separate_window

#property indicator_buffers 1
#property indicator_plots 1
#property indicator_type1  DRAW_LINE
#property indicator_color1 Green
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label1 "CEV"

#define MODE_ASCEND 0
#define MODE_DESCEND 1

//--- indicator buffers
double Plot [];


//--- indicator input
input double PI = 0; // PI
int Period = 14;  // Periods
input int bars = 100; // Bars:

// ------------------------------------------------------------------
void OnInit()
{
    //--- indicator short name
    string short_name = "Cumulative Effective Volume";
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    PlotIndexSetString(0, PLOT_LABEL, short_name);
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

    //--- Buffers 
    SetIndexBuffer(0, Plot);
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

    int start;
    if(prev_calculated > 1) start = prev_calculated - 1; else { start = rates_total - 1; }

    for(int i = start; i < rates_total && !IsStopped(); i++)
    {
        double val = Plot[i - 1] == EMPTY_VALUE ? 0 : Plot[i - 1];

        double highPrice = MathMax(high[i], close[i - 1]);
        double lowPrice = MathMin(low[i], close[i - 1]);

        val += highPrice - lowPrice + PI != 0 ?
            ((close[i] - close[i - 1] + PI) / (highPrice - lowPrice + PI)) * tick_volume[i]
            : 0;
        
        Plot[i] = val;
    }

    return (rates_total);
}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |   
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                                                    15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |  
//|Ethereum                                           0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D   |  
//|USDT addres  ERC-20 (Ethereum) address)            0x258C74Caac21c9535A0969F169FE0271d3cE56A0   | 
//+------------------------------------------------------------------------------------------------+