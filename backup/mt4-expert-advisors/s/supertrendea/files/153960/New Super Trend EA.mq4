//+------------------------------------------------------------------+
//|                                                     Supertrend EA|
//+------------------------------------------------------------------+
extern int      Nbr_Periods = 10;
extern double   Multiplier = 3.0;
extern double   SpreadLimit = 3; // Spread limit in points
extern double   RiskPercentage = 1; // Risk percentage of equity
extern double   TakeProfitPercentage = 150; // Take profit as a percentage of stop loss
extern double   BreakevenPercentage = 50; // Breakeven trigger as a percentage of profit

int changeOfTrend;
double stopDistance;
double lotSize;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
    // Check for spread limit
    if (Ask - Bid > SpreadLimit * Point)
        return;

    // Check for new buy signal
    if (iCustom(_Symbol, _Period, "Supertrend", 0, 0) == 1 && OrderSendAllowed())
    {
        stopDistance = CalculateStopDistance();
        lotSize = CalculateLotSize();

        // Print conditions for debugging
        Print("Buy Conditions Met");
        Print("Spread Limit: ", Ask - Bid);
        Print("Order Send Allowed: ", OrderSendAllowed());
        Print("OrderSend Result: ", OrderSend(_Symbol, OP_BUY, lotSize, Ask, 3, 0, 0, "Buy Order", 0, 0, Blue));

        // Open Buy Order
        if (OrderSend(_Symbol, OP_BUY, lotSize, Ask, 3, 0, 0, "Buy Order", 0, 0, Blue) > 0)
        {
            // Order executed successfully
            // Additional handling can be added here if needed
        }
        else
        {
            Print("Error opening Buy Order: ", GetLastError());
        }
    }

    // Check for new sell signal
    if (iCustom(_Symbol, _Period, "Supertrend", 1, 0) == 1 && OrderSendAllowed())
    {
        stopDistance = CalculateStopDistance();
        lotSize = CalculateLotSize();

        // Open Sell Order
        if (OrderSend(_Symbol, OP_SELL, lotSize, Bid, 3, 0, 0, "Sell Order", 0, 0, Red) > 0)
        {
            // Order executed successfully
            // Additional handling can be added here if needed
        }
        else
        {
            Print("Error opening Sell Order: ", GetLastError());
        }
    }
}


//+------------------------------------------------------------------+
//| Calculate stop loss distance                                     |
//+------------------------------------------------------------------+
double CalculateStopDistance()
{
    double atr = iATR(_Symbol, _Period, Nbr_Periods, 0);
    double medianPrice = (iHigh(_Symbol, _Period, 0) + iLow(_Symbol, _Period, 0)) / 2;

    return atr * Multiplier + Point; // Adding Point to account for spread
}

//+------------------------------------------------------------------+
//| Calculate lot size based on risk percentage                      |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
    double riskAmount = AccountEquity() * RiskPercentage / 100;
    return riskAmount / stopDistance;
}

//+------------------------------------------------------------------+
//| Check if order send is allowed                                   |
//+------------------------------------------------------------------+
bool OrderSendAllowed()
{
    int totalOrders = OrdersHistoryTotal();
    if (totalOrders > 0)
        return false;

    return true;
}
