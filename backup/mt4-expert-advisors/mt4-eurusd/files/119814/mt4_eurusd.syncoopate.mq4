// Id: 21644
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66233

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"
#property strict

enum IncreaseType
{
    IncreasePercent, // %
    IncreasePips // Pips
};

enum StopLimitType
{
    StopLimitPercent, // %
    StopLimitPips, // Pips
    StopLimitDollar // $
};

enum ExitType
{
    ExitSLTP, // Exit only by Stop loss or Take profit triggers, no reversals
    ExitReversal // Reverse order if conditions for reverse order met
};

enum PositionSizeType
{
    PositionSizeAmount, // $
    PositionSizeContract, // In contracts
    PositionSizeEquity // % of equity
};

enum PositionDirection
{
    DirectLogic, // Direct
    ReversalLogic // Reversal
};

extern ENUM_TIMEFRAMES TF = PERIOD_CURRENT;
extern double Increase = 1;
extern IncreaseType Increase_Type = IncreasePips; // Increase parameter type
extern double OrderLevel = -1; // Level of the order to create on increase hit, %
extern double Lots            = 0.1; // Position size
extern PositionSizeType LotsType = PositionSizeContract; // Position size type
extern int Slippage           = 3;
extern bool SetStop           = true; // Set stop loss?
extern double Stop            = 10; // Stop loss value
extern StopLimitType StopType = StopLimitPips; // Stop loss type
extern bool SetLimit          = true; // Set take profit?
extern double Limit           = 10; // Take profit value
extern StopLimitType LimitType = StopLimitPips; // Take profit type
extern int MaxOrders = 1; // Max number of orders
extern string StartTime = "000000"; // Start time in hhmmss format
extern string EndTime = "235959"; // End time in hhmmss format
extern double MaxSpred = 12; // Max spread
extern PositionDirection LogicType = DirectLogic; // Logic type
extern int MagicNumber        = 42; // Magic number

int ParseTime(const string time)
{
    int time_parsed = StrToInteger(time);
    int seconds = time_parsed % 100;
    if (seconds > 59)
    {
        Print("Incorrect number of seconds in " + time);
        return -1;
    }
    time_parsed /= 100;
    int minutes = time_parsed % 100;
    if (minutes > 59)
    {
        Print("Incorrect number of minutes in " + time);
        return -1;
    }
    time_parsed /= 100;
    int hours = time_parsed % 100;
    if (hours > 23)
    {
        Print("Incorrect number of hours in " + time);
        return -1;
    }
    return (hours * 60 + minutes) * 60 + seconds;
}

// Order builder
// v.1.0.0

enum OrderSide
{
    BuySide,
    SellSide
};

class OrderBuilder
{
    OrderSide _orderSide;
    string _instrument;
    double _amount;
    double _rate;
    int _slippage;
    double _stop;
    double _limit;
    int _magicNumber;
public:
    OrderBuilder *SetSide(const OrderSide orderSide)
    {
        _orderSide = orderSide;
        return &this;
    }
    
    OrderBuilder *SetInstrument(const string instrument)
    {
        _instrument = instrument;
        return &this;
    }
    
    OrderBuilder *SetAmount(const double amount)
    {
        _amount = amount;
        return &this;
    }
    
    OrderBuilder *SetRate(const double rate)
    {
        _rate = NormalizeDouble(rate, Digits);
        return &this;
    }
    
    OrderBuilder *SetSlippage(const int slippage)
    {
        _slippage = slippage;
        return &this;
    }
    
    OrderBuilder *SetStop(const double stop)
    {
        _stop = NormalizeDouble(stop, Digits);
        return &this;
    }
    
    OrderBuilder *SetLimit(const double limit)
    {
        _limit = NormalizeDouble(limit, Digits);
        return &this;
    }
    
    OrderBuilder *SetMagicNumber(const int magicNumber)
    {
        _magicNumber = magicNumber;
        return &this;
    }
    
    int Execute()
    {
        int orderType;
        if (_orderSide == BuySide)
        {
            orderType = _rate > Ask ? OP_BUYSTOP : OP_BUYLIMIT;
        }
        else
        {
            orderType = _rate < Bid ? OP_SELLSTOP : OP_SELLLIMIT;
        }
        double minstoplevel=MarketInfo(_instrument,MODE_STOPLEVEL); 
        
        Print("Creating " + (_orderSide == BuySide ? "buy" : "sell")
            + " order at " + DoubleToStr(_rate, Digits) 
            + ". Amount: " + DoubleToStr(_amount, 2)
            + ". Stop: " + DoubleToStr(_stop, Digits)
            + ". Limit: " + DoubleToStr(_limit, Digits));
        int order = OrderSend(_instrument, orderType, _amount, _rate, _slippage, _stop, _limit, NULL, _magicNumber);
        if (order == -1)
        {
            int error = GetLastError();
            switch (error)
            {
                case 4109:
                    Print("Trading is not allowed");
                    break;
                case 130:
                    Print("Failed to create order: stoploss/takeprofit is too close");
                    break;
                default:
                    Print("Failed to create order: " + IntegerToString(error));
                    break;
            }
        }
        return order;
    }
};

// Trade controller v.1.0.0
class TradeController
{
    string _symbol;
    double _point;
    datetime _lastbartime;
    int _digit;
    double _mult;
    datetime _lastCloseTime;
public:
    TradeController(const string symbol)
    {
        _symbol = symbol;
        _point = MarketInfo(_symbol, MODE_POINT);
        _digit = (int)MarketInfo(_symbol, MODE_DIGITS); 
        _mult = _digit == 3 || _digit == 5 ? 10 : 1;
        _lastCloseTime = iTime(_symbol, TF, 0);
    }

    ~TradeController()
    {
    }

    void DoTrading()
    {
        datetime current_time = iTime(_symbol, TF, 0);
        if (_lastCloseTime != current_time)
        {
            DeleteOrders();
            CloseTrades(OP_SELL);
            CloseTrades(OP_BUY);
            _lastCloseTime = current_time;
        }
        if (current_time == _lastbartime)
        {
            return;
        }

        if (IsBuyCondition())
        {
            switch (LogicType)
            {
                case DirectLogic:
                    DoBuy(iOpen(_symbol, TF, 0) + iOpen(_symbol, TF, 0) * OrderLevel / 100.0);
                    break;
                case ReversalLogic:
                    DoSell(iOpen(_symbol, TF, 0) + iOpen(_symbol, TF, 0) * OrderLevel / 100.0);
                    break;
            }
        }
        if (IsSellCondition())
        {
            switch (LogicType)
            {
                case DirectLogic:
                    DoSell(iOpen(_symbol, TF, 0) - iOpen(_symbol, TF, 0) * OrderLevel / 100.0);
                    break;
                case ReversalLogic:
                    DoBuy(iOpen(_symbol, TF, 0) - iOpen(_symbol, TF, 0) * OrderLevel / 100.0);
                    break;
            }
        }
    }
private:
    double CalculateSLShift(const double amount, const double money)
    {
        double unitCost = MarketInfo(_symbol, MODE_TICKVALUE);
        double tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
        return (money / (unitCost / tickSize)) / amount;
    }

    double CalculateStop(const bool isBuy, const double amount, const double basePrice)
    {
        if (!SetStop)
            return 0;

        int direction = isBuy ? 1 : -1;
        switch (StopType)
        {
            case StopLimitPercent:
                return basePrice - basePrice * Stop / 100.0 * direction;
            case StopLimitPips:
                return basePrice - Stop * _mult * _point * direction;
            case StopLimitDollar:
                return basePrice - CalculateSLShift(amount, Stop) * direction;
        }
        return 0.0;
    }

    double CalculateLimit(const bool isBuy, const double limit, const StopLimitType limitType, const double amount, const double basePrice)
    {
        int direction = isBuy ? 1 : -1;
        switch (limitType)
        {
            case StopLimitPercent:
                return basePrice + basePrice * limit / 100.0 * direction;
            case StopLimitPips:
                return basePrice + limit * _mult * _point * direction;
            case StopLimitDollar:
                return basePrice + CalculateSLShift(amount, limit) * direction;
        }
        return 0.0;
    }
    
    double CalculateLimit(const bool isBuy, const double amount, const double basePrice)
    {
        if (!SetLimit)
            return 0;

        return CalculateLimit(isBuy, Limit, LimitType, amount, basePrice);
    }

    void DoBuy(const double rate)
    {
        double amount = GetLots();
        
        OrderBuilder *orderBuilder = new OrderBuilder();
        int order = orderBuilder
            .SetSide(BuySide)
            .SetInstrument(_symbol)
            .SetAmount(amount)
            .SetRate(rate)
            .SetSlippage(Slippage)
            .SetMagicNumber(MagicNumber)
            .SetStop(CalculateStop(true, amount, rate))
            .SetLimit(CalculateLimit(true, amount, rate))
            .Execute();
        delete orderBuilder;
        if (order != -1)
        {
            _lastbartime = iTime(_symbol, TF, 0);
        }
    }

    void DoSell(const double rate)
    {
        double amount = GetLots();
        
        OrderBuilder *orderBuilder = new OrderBuilder();
        int order = orderBuilder
            .SetSide(SellSide)
            .SetInstrument(_symbol)
            .SetAmount(amount)
            .SetRate(rate)
            .SetSlippage(Slippage)
            .SetMagicNumber(MagicNumber)
            .SetStop(CalculateStop(true, amount, rate))
            .SetLimit(CalculateLimit(true, amount, rate))
            .Execute();
        delete orderBuilder;
        if (order != -1)
        {
            _lastbartime = iTime(_symbol, TF, 0);
        }
    }

    double GetLotsForMoney(const double money)
    {
        double marginRequired = MarketInfo(_symbol, MODE_MARGINREQUIRED);
        double lotStep = MarketInfo(_symbol, MODE_LOTSTEP);
        return floor((money / marginRequired) / lotStep) * lotStep;
    }

    double GetLots()
    {
        switch (LotsType)
        {
            case PositionSizeAmount:
                return GetLotsForMoney(Lots);
            case PositionSizeContract:
                return Lots;
            case PositionSizeEquity:
                return GetLotsForMoney(AccountEquity() * Lots / 100.0);
        }
        return Lots;
    }

    double GetTargetPrice(const int direction)
    {
        double open = iOpen(_symbol, TF, 0);
        switch (Increase_Type)
        {
            case IncreasePercent:
                return open + open * Increase / 100.0 * direction;
            case IncreasePips:
                return open + _mult * _point * Increase * direction;
        }
        return 0.0;
    }

    bool SpreadValid()
    {
        double spread = SymbolInfoInteger(_symbol, SYMBOL_SPREAD) / _mult;
        return spread <= MaxSpred;
    }

    bool IsBuyCondition()
    {
        double close = iClose(_symbol, TF, 0);
        return close >= GetTargetPrice(1) 
            && SpreadValid() 
            && OrdersCount() < MaxOrders
            && (!IsPositionExist(OP_SELL));
    }

    bool IsSellCondition()
    {
        double close = iClose(_symbol, TF, 0);
        return close <= GetTargetPrice(-1) 
            && SpreadValid() 
            && OrdersCount() < MaxOrders
            && (!IsPositionExist(OP_BUY));
    }

    int OrdersCount()
    {
        int count = 0;
        for (int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) 
                && OrderSymbol() == _symbol 
                && OrderMagicNumber() == MagicNumber)
            {
                count += 1;
            }
        }
        return count;
    }

    void DeleteOrders()
    {
        for (int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == MagicNumber && OrderType() != OP_BUY && OrderType() != OP_SELL)
            {
                if (!OrderDelete(OrderTicket()))
                {
                    Print("Failed to delete the order " + IntegerToString(OrderTicket()));
                }
            }
        }
    }

    bool IsPositionExist(const int side)
    {
        for (int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            {
                if (OrderMagicNumber() == MagicNumber 
                    && OrderSymbol() == _symbol)
                {
                    if (OrderType() == side || (OrderType() != OP_BUY && OrderType() != OP_SELL))
                        return true;
                }
            }
        }
        return false;
    }

    void CloseTrades(const int side)
    {
        for (int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            {
                if (OrderMagicNumber() == MagicNumber
                    && OrderSymbol() == _symbol
                    && OrderType() == side)
                {
                    if (OrderType() == OP_BUY)
                    {
                        if (!OrderClose(OrderTicket(), OrderLots(), Bid, 5)) 
                        {
                            Print("LastError = ", GetLastError());
                        } 
                    }
                    if (OrderType() == OP_SELL)
                    {
                        if (!OrderClose(OrderTicket(), OrderLots(), Ask, 5)) 
                        {
                            Print("LastError = ", GetLastError());
                        }
                    }
                }
            }
        }
    }
};

int start_time;
int end_time;

bool IsTradingTime()
{
    MqlDateTime current_time;
    TimeLocal(current_time);
    int current_t = (current_time.hour * 60 + current_time.min) * 60 + current_time.sec;
    if (start_time == end_time)
        return true;
    if (start_time > end_time)
        return current_t >= start_time || current_t <= end_time;
    return current_t >= start_time && current_t <= end_time;
}

int OnInit()
{
    start_time = ParseTime(StartTime);
    end_time = ParseTime(EndTime);
    if (start_time == -1 || end_time == -1)
    {
        return 0;
    }
    tradingLogic = new TradeController(_Symbol);

    return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
    delete tradingLogic;
}

TradeController *tradingLogic;

void OnTick()
{
    if (!IsTradingTime())
    {
        return;
    }
    tradingLogic.DoTrading();
}
