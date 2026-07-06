// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73806

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
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

#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 LimeGreen
#property indicator_color2 Red

//---- input parameters
extern int SVPeriod=100;
extern int SMAPeriod=14;
//---- buffers
double Buffer[];
double SMA[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
    string short_name;
    //---- 1 additional buffer used for counting.
    IndicatorBuffers(2);
    //IndicatorDigits(Digits);
    //---- indicator line
    SetIndexStyle(0,DRAW_HISTOGRAM);
    SetIndexBuffer(0,Buffer);
    SetIndexLabel(0,"Simple Volume");
    
    //---- SMA line
    SetIndexStyle(1,DRAW_LINE);
    SetIndexBuffer(1,SMA);
    SetIndexLabel(1,"SMA");
    SetIndexShift(1, 1); // Shift the SMA line to the right by 1 bar
    
    //---- name for DataWindow and indicator subwindow label
    short_name="Simple Volume with SMA";
    IndicatorShortName(short_name);
    
    //---- initialize SMA buffer to 0
    ArrayInitialize(SMA, 0);
    
    return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
    //---- 
    return(0);
}

//+------------------------------------------------------------------+
//| Simple Volume calculation                                        |
//+------------------------------------------------------------------+
int start()
{
    int i, counted_bars=IndicatorCounted();
    if(Bars<SVPeriod) return(0);
    
    i = Bars - SVPeriod - 1;
    if(counted_bars > SVPeriod) i = Bars - counted_bars - 1;
    
    while(i > 0)
    {
        Buffer[i] = Open[i] * Volume[i];
        i--;
    }
    
    //---- calculate SMA
    ArraySetAsSeries(Buffer, true); // set Buffer as series
    ArraySetAsSeries(SMA, true); // set SMA as series
    int limit = Bars - SMAPeriod;
    for(i = limit; i >= 0; i--)
    {
        double sum = 0;
        for(int j = 0; j < SMAPeriod; j++)
        {
            sum += Buffer[i+j];
        }
        SMA[i] = sum / SMAPeriod;
    }
    
    return(0);
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