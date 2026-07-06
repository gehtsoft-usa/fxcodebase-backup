// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73773

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

// Gobal Variables
input double profitToClose = 10; // Profit to Close
input double lossToClose = 10; // Loss to Close

//////////////////////////////////////////////////////////////////////

int OnInit()
{

    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick()
{
    for(int i = OrdersTotal() - 1;i >= 0;i--)
    {
        if(OrderSelect(i, SELECT_BY_POS))
        {
            double currentProfit = OrderProfit() + OrderCommission() + OrderSwap();
            if(currentProfit >= profitToClose || currentProfit <= (0 - lossToClose))
            {
                double _price=0;
                if(OrderType() == OP_BUY) { _price = SymbolInfoDouble(OrderSymbol(), SYMBOL_BID); }
                if(OrderType() == OP_SELL){ _price = SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK); }

                if(!OrderClose(OrderTicket(), OrderLots(), _price, 100000, clrNONE))
                {
                    Print(__FUNCTION__, " ", "can't close Order: ", OrderTicket(), " error: ", GetLastError());
                }
            }
        }
    }
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