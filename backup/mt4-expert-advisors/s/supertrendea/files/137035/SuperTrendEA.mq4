// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70327

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+
#property version   "1.00"
#property strict
//--- input parameters
input string   Title="Super Trend Parameters";
input int      Nbr_Periods = 10;
input double   Multiplier = 3.0;
input string   Separator="--------------------------";
input bool     AutoRisk=false;
input double   RiskPercent=1.0;
input double   ManualLots=0.01;
input int      MaximumSlipage=5;
input double   TakeProfitPips=5.0;
input double   StopLossPips=5.0;
input double   TrailingStopPips=5.0;
input double   TrailingStopTriggerPips=5.0;
input double   TrailingStepInPips=5.0;
input int      MaxOpenTrades=2;
input int      WaitMinutesUntilTrade=5;
input double   MaxPipsAwayFromSignal=10.0;

// Custom Variables
const int MAGIC = 1001;

datetime initialTime;
datetime lastActionTime;

double upTrend_0 = 0.0;
double upTrend_1 = 0.0;
double dwTrend_0 = 0.0;
double dwTrend_1 = 0.0;

double maxPipsAwayFromSignal_AbsValue = 0.0;
double longTrailStopTriggerPrice = 0.0;
double shortTrailStopTriggerPrice = 0.0;
bool trailStopActivaded = false;
double nextTrailStopPrice = 0.0;

enum MarketPosition
{
    MARKET_FLAT = 0,
    MARKET_LONG = 1,
    MARKET_SHORT = 2
};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Getting Initial Time
   initialTime = TimeCurrent();
   maxPipsAwayFromSignal_AbsValue = MaxPipsAwayFromSignal * 10 * MarketInfo(Symbol(), MODE_TICKSIZE);
   Print("MaxAbsAwayFromSignal: " + maxPipsAwayFromSignal_AbsValue);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Getting the waiting minutes since the EA started
    int WaitingMinutes =  TimeMinute(TimeCurrent() - initialTime);

    // Executing the analysis once per every bar
    if (lastActionTime != Time[0])
    {
        Print("===========================");

        //If WaitingMinutes is greater than the WaitMinutesUntilTrade parameters them we can start doing entries
        if (WaitingMinutes > WaitMinutesUntilTrade)
        {
            upTrend_1 = upTrend_0;
            upTrend_0 = iCustom(Symbol(), 0, "SUPERTREND", Nbr_Periods, Multiplier, 0, 0);

            dwTrend_1 = dwTrend_0;
            dwTrend_0 = iCustom(Symbol(), 0, "SUPERTREND", Nbr_Periods, Multiplier, 1, 0);

            Print("upTrend_0: " + upTrend_0);
            Print("upTrend_1: " + upTrend_1);
            Print("dwTrend_0: " + dwTrend_0);
            Print("dwTrend_1: " + dwTrend_1);

            if (upTrend_0 != EMPTY_VALUE && upTrend_1 == EMPTY_VALUE)
            {
                Print("Long Entry Activated");
                // Close any open orders
                CloseStrategyOpenOrders();

                // Verify if the signal if the signal is close enough
                if (Close[0] - upTrend_0 < maxPipsAwayFromSignal_AbsValue)
                {
                    // Total Open ordes should be less the MaxOpenOrders
                    if (OrdersTotal() < MaxOpenTrades)
                    {
                        // Setting Stop Loss Price
                        double stopLossPrice = Close[0] - StopLossPips * 10 * MarketInfo(Symbol(), MODE_TICKSIZE);
                        // Setting Take Profit Price
                        double takeProfitPrice = Close[0] + TakeProfitPips * 10 * MarketInfo(Symbol(), MODE_TICKSIZE);

                        double lotSize = 0.0;
                        // Setting lot size
                        if (AutoRisk)
                        {
                            lotSize = CalculateSizeByPercentRisk(AccountBalance(), RiskPercent, Ask, stopLossPrice);
                        }
                        else
                        {
                            lotSize = NormalizeDouble(ManualLots, 2);
                        }

                        // Executing Long Entries
                        int longOrderResult = OrderSend(Symbol(),
                                                        OP_BUY,
                                                        lotSize,
                                                        Ask,
                                                        MaximumSlipage,
                                                        stopLossPrice,
                                                        takeProfitPrice,
                                                        "Super Treand Long Entry",
                                                        MAGIC,
                                                        0,
                                                        CLR_NONE);

                        if (longOrderResult < 0)
                        {
                            Print("LongOrder failed with error: #" + GetLastError());
                        }
                        else
                        {
                            Print("LongOrder placed successfully");
                            if (OrderSelect(longOrderResult, SELECT_BY_TICKET, MODE_TRADES))
                            {
                                longTrailStopTriggerPrice = OrderOpenPrice() + TrailingStopTriggerPips * 10 * MarketInfo(Symbol(), MODE_TICKSIZE);
                                trailStopActivaded = false;
                            }
                        }
                    }
                }
            }
            else if (dwTrend_0 != EMPTY_VALUE && dwTrend_1 == EMPTY_VALUE)
            {
                Print("Short Entry Activated");
                // Close any open orders
                CloseStrategyOpenOrders();

                // Verify if the signal if the signal is close enough
                if (dwTrend_0 - Close[0] < maxPipsAwayFromSignal_AbsValue)
                {
                    // Total Open ordes should be less the MaxOpenOrders
                    if (OrdersTotal() < MaxOpenTrades)
                    {
                        // Setting Stop Loss Price
                        double stopLossPrice = Close[0] + StopLossPips * 10 * MarketInfo(Symbol(), MODE_TICKSIZE);
                        // Setting Take Profit Price
                        double takeProfitPrice = Close[0] - TakeProfitPips * 10 * MarketInfo(Symbol(), MODE_TICKSIZE);

                        double lotSize = 0.0;
                        // Setting lot size
                        if (AutoRisk)
                        {
                            lotSize = CalculateSizeByPercentRisk(AccountBalance(), RiskPercent, Bid, stopLossPrice);
                        }
                        else
                        {
                            lotSize = NormalizeDouble(ManualLots, 2);
                        }

                        // Executing Long Entries
                        int shortOrderResult = OrderSend(Symbol(),
                                                        OP_SELL,
                                                        lotSize,
                                                        Bid,
                                                        MaximumSlipage,
                                                        stopLossPrice,
                                                        takeProfitPrice,
                                                        "Super Treand Short Entry",
                                                        MAGIC,
                                                        0,
                                                        CLR_NONE);

                        if (shortOrderResult < 0)
                        {
                            Print("ShortOrder failed with error: #" + GetLastError());
                        }
                        else
                        {
                            Print("ShortOrder placed successfully");
                            if (OrderSelect(shortOrderResult, SELECT_BY_TICKET, MODE_TRADES))
                            {
                                shortTrailStopTriggerPrice = OrderOpenPrice() - TrailingStopTriggerPips * 10 * MarketInfo(Symbol(), MODE_TICKSIZE);
                                trailStopActivaded = false;
                            }
                        }
                    }
                }
            }
            else
            {
                MarketPosition mktPos = GetMarketPosition();

                Print("MarketPosition: " + (string)mktPos);

                if (mktPos == MARKET_LONG)
                {
                    if (trailStopActivaded)
                    {
                        if (Bid > nextTrailStopPrice)
                        {
                             for (int i = 0; i < OrdersTotal(); i ++)
                             {
                                 if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
                                 {
                                     if (OrderMagicNumber() == MAGIC
                                         && OrderType() == OP_BUY)
                                     {
                                        double newStopLoss = Bid - TrailingStopPips * 10 * MarketInfo(Symbol(), MODE_TICKSIZE);
                                        if (OrderModify(OrderTicket(),
                                                        OrderOpenPrice(),
                                                        newStopLoss,
                                                        OrderTakeProfit(),
                                                        OrderExpiration(),
                                                        CLR_NONE)
                                            )
                                        {
                                            Print("Long Trail Stop Step Activated");
                                            nextTrailStopPrice = nextTrailStopPrice + TrailingStepInPips * 10 * MarketInfo(Symbol(), MODE_TICKSIZE);
                                        }
                                     }
                                 }
                             }
                        }
                    }
                    else
                    {
                        if (Bid > longTrailStopTriggerPrice)
                        {
                            trailStopActivaded = true;
                            // Setting Break Even State for Long Positions
                            for (int i = 0; i < OrdersTotal(); i ++)
                            {
                                if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
                                {
                                    if (OrderMagicNumber() == MAGIC
                                        && OrderType() == OP_BUY)
                                    {
                                        double newStopLoss = Bid - TrailingStopPips * 10 * MarketInfo(Symbol(), MODE_TICKSIZE);
                                        if (OrderModify(OrderTicket(),
                                                        OrderOpenPrice(),
                                                        newStopLoss,
                                                        OrderTakeProfit(),
                                                        OrderExpiration(),
                                                        CLR_NONE)
                                            )
                                        {
                                            Print("Long Trail Stop Activated");
                                            nextTrailStopPrice = longTrailStopTriggerPrice + TrailingStepInPips * 10 * MarketInfo(Symbol(), MODE_TICKSIZE);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                else if (mktPos == MARKET_SHORT)
                {
                    if (trailStopActivaded)
                    {
                        if (Ask < nextTrailStopPrice)
                        {
                             for (int i = 0; i < OrdersTotal(); i ++)
                             {
                                 if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
                                 {
                                     if (OrderMagicNumber() == MAGIC
                                         && OrderType() == OP_SELL)
                                     {
                                        double newStopLoss = Ask + TrailingStopPips * 10 * MarketInfo(Symbol(), MODE_TICKSIZE);
                                        if (OrderModify(OrderTicket(),
                                                        OrderOpenPrice(),
                                                        newStopLoss,
                                                        OrderTakeProfit(),
                                                        OrderExpiration(),
                                                        CLR_NONE)
                                            )
                                        {
                                            Print("Long Trail Stop Step Activated");
                                            nextTrailStopPrice = nextTrailStopPrice - TrailingStepInPips * 10 * MarketInfo(Symbol(), MODE_TICKSIZE);
                                        }
                                     }
                                 }
                             }
                        }
                    }
                    else
                    {
                        if (Ask < shortTrailStopTriggerPrice)
                        {
                            trailStopActivaded = true;
                            // Setting Break Even State for Long Positions
                            for (int i = 0; i < OrdersTotal(); i ++)
                            {
                                if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
                                {
                                    if (OrderMagicNumber() == MAGIC
                                        && OrderType() == OP_SELL)
                                        {
                                            double newStopLoss = Ask + TrailingStopPips * 10 * MarketInfo(Symbol(), MODE_TICKSIZE);
                                            if (OrderModify(OrderTicket(),
                                                            OrderOpenPrice(),
                                                            newStopLoss,
                                                            OrderTakeProfit(),
                                                            OrderExpiration(),
                                                            CLR_NONE)
                                                )
                                            {
                                                Print("Short Trail Stop Activated");
                                                nextTrailStopPrice = longTrailStopTriggerPrice - TrailingStepInPips * 10 * MarketInfo(Symbol(), MODE_TICKSIZE);
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
        }
        else
        {
            Print("WaitingMinutes: " + WaitingMinutes);
        }

        lastActionTime = Time[0];
    }
}

void CloseStrategyOpenOrders()
{
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderMagicNumber() == MAGIC)
            {
                if (OrderType() == OP_BUY)
                {
                    bool result =OrderClose( OrderTicket(),
                                                OrderLots(),
                                                Bid,
                                                MaximumSlipage,
                                                CLR_NONE
                                                );

                    if (result)
                        Print("Long order sucesfully closed.");
                }
                else if (OrderType() == OP_SELL)
                {
                    bool result = OrderClose( OrderTicket(),
                                        OrderLots(),
                                        Bid,
                                        MaximumSlipage,
                                        CLR_NONE
                                        );

                    if (result)
                        Print("Short order sucesfully closed.");
                }

            }
        }
    }
}

double  DeltaValuePerLot(string pair=""){
     
    if (pair == "") pair = Symbol();
    return(  MarketInfo(pair, MODE_TICKVALUE)
           / MarketInfo(pair, MODE_TICKSIZE) ); // Not Point.
}

double CalculateSizeByPercentRisk(double balance, double percent, double openPrice, double stopLoss)
{
    double orderLots = 0.0;

    orderLots = (balance * percent / 100) / (MathAbs(openPrice - stopLoss)*DeltaValuePerLot());

    orderLots = NormalizeDouble(orderLots, 2);

    return orderLots;
}

MarketPosition GetMarketPosition()
{
    MarketPosition marketPosition = MARKET_FLAT;

    for (int i = 0; i < OrdersTotal(); i++)
    {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
            if (OrderMagicNumber() == MAGIC)
            {
                if (OrderType() == OP_BUY)
                {
                    marketPosition = MARKET_LONG;
                }
                else
                {
                    marketPosition = MARKET_SHORT;
                }
            }
            else
            {
                marketPosition = MARKET_FLAT;
            }
        }
        else
        {
            marketPosition = MARKET_FLAT;
        }
    }

    return marketPosition;
}


//+------------------------------------------------------------------+
