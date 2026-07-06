// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74309

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
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
#property description "Expert Advisor"
#property strict
 
//////////////////////////////////////////////////////////////////////
input string T0       = "== Minutes to Close ==";  // ————————————
input int minutesToClose = 1; // Minutes to Close Trade:

class ActionCloseOrder
{
    ENUM_ORDER_TYPE _type;
    string          _symbol;
    int             _magic;
    int             _slippage;
    double          _price;

    public:
    ActionCloseOrder(int magic=0, string symbol = "", int slippage = 10000)
    {
        _magic = magic;
        if(symbol == "")      { _symbol = Symbol();   } else { _symbol = symbol; }
        if(slippage != 10000) { _slippage = slippage; }
    }
    ~ActionCloseOrder() {}

    void setPrice()
    {
        if(_type == OP_BUY) { _price = SymbolInfoDouble(_symbol, SYMBOL_BID); }
        if(_type == OP_SELL) { _price = SymbolInfoDouble(_symbol, SYMBOL_ASK); }
    }

    bool doAction(int pos)
    {
        // for(int i = OrdersTotal() - 1; i >= 0; i--)
        // {
            if(OrderSelect(pos, SELECT_BY_POS) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic)
            {
                _type = OrderType();
                setPrice();
                
                if(!OrderClose(OrderTicket(), OrderLots(), _price, _slippage, clrNONE))
                {
                    Print(__FUNCTION__, " ", "can't close Order: ", OrderTicket(), " error: ", GetLastError());
                }
            }
        // }
        return true;
    }
};
ActionCloseOrder actionCloseOrder();
//////////////////////////////////////////////////////////////////////

int OnInit()
{
    EventSetTimer(1);
    return(INIT_SUCCEEDED);
}
 
void OnDeinit(const int reason) { }
 
void OnTick(){ }

void OnTimer(void)
{
    for(int i=OrdersTotal()-1;i>=0;i--)
    {
       if(OrderSelect(i,SELECT_BY_POS) && OrderSymbol() == _Symbol)
       {
           if((TimeCurrent() - OrderOpenTime()) > (minutesToClose * 60))
           {
               actionCloseOrder.doAction(i);
           }
       }
    }
}
 
void OnTrade(void) {}
 
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam){}
 
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