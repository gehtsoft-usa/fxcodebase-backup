// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74459

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
#property strict



struct ChartData
{
    long id;
    string symbol;
    int tf;
};
ChartData data [];

string ms = "Important Information: To remove all the experts advisors the Script will Close and Re-Open all the charts with the default template. If you have thecnical analisis or other objects in the charts you will loss it. Are you sure to continue ? ";


void OnStart()
{

    if(MessageBox(ms, "WARNING!", MB_OKCANCEL + MB_ICONWARNING) == IDCANCEL)
    {
        return;
    }


    // recorrer los charts
    long first = ChartFirst();
    long prevChart = first;
    long currChart = first;
    int i = 0;

    // save charts:
    while(i < 100)  {
        int t = ArraySize(data);
        if(ArrayResize(data, t + 1))
        {

            data[t].id = currChart;
            data[t].symbol = ChartSymbol(currChart);
            data[t].tf = ChartPeriod(currChart);
        }

        currChart = ChartNext(prevChart);
        if(currChart < 0) break;
        prevChart = currChart;
        i++;

    }

    // close charts
    for(int i = 0; i < ArraySize(data); i++) {
        ChartClose(data[i].id);
    }

    // open same charts
    for(int i = 0; i < ArraySize(data); i++) {
        ChartOpen(data[i].symbol, data[i].tf);
    }

}



//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+