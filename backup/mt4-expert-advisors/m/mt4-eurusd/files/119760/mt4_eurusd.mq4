// Id: 21620
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66233
// Id: 

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

extern double Increase = 1;
extern IncreaseType Increase_Type = IncreasePips; // Increase parameter type
extern double Lots            = 0.1; // Position size
extern PositionSizeType LotsType = PositionSizeContract; // Position size type
extern int Slippage           = 3;
extern bool SetStop           = true; // Set stop loss?
extern double Stop            = 10; // Stop loss value
extern StopLimitType StopType = StopLimitPips; // Stop loss type
extern bool SetLimit          = true; // Set take profit?
extern double Limit           = 10; // Take profit value
extern StopLimitType LimitType = StopLimitPips; // Take profit type
extern bool ExitSLOnly = false; // Exit using SL/TP only?
extern int MaxOrders = 1; // Max number of orders
extern string StartTime = "000000"; // Start time in hhmmss format
extern string EndTime = "235959"; // End time in hhmmss format
extern bool MoveToBreakeven = false; // Move to breakeven
extern double BreakevenTrigger = 10; // Trigger for the breakeven
extern StopLimitType BreakevenTriggerType = StopLimitPips; // Trigger type for the breakeven
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

// Breakeven controller v. 1.0.0
class BreakevenController
{
    int _order;
    bool _finished;
    double _trigger;
    double _target;
public:
    BreakevenController()
    {
        _finished = false;
    }
    
    bool SetOrder(const int order, const double trigger, const double target)
    {
        if (!_finished)
        {
            return false;
        }
        _finished = false;
        _trigger = trigger;
        _target = target;
        _order = order;
        return true;
    }

    void DoLogic()
    {
        if (_finished || !OrderSelect(_order, SELECT_BY_TICKET, MODE_TRADES))
        {
            _finished = true;
            return;
        }

        int type = OrderType();
        if (type == OP_BUY)
        {
            if (Ask >= _trigger)
            {
                int res = OrderModify(OrderTicket(), OrderOpenPrice(), _target, OrderTakeProfit(), 0, CLR_NONE);
                _finished = true;
            }
        } 
        else if (type == OP_SELL) 
        {
            if (Bid < _trigger) 
            {
                int res = OrderModify(OrderTicket(), OrderOpenPrice(), _target, OrderTakeProfit(), 0, CLR_NONE);
                _finished = true;
            }
        } 
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
    BreakevenController *_breakeven[];
public:
    TradeController(const string symbol)
    {
        _symbol = symbol;
        _point = MarketInfo(_symbol, MODE_POINT);
        _digit = (int)MarketInfo(_symbol, MODE_DIGITS); 
        _mult = _digit == 3 || _digit == 5 ? 10 : 1;
    }

    ~TradeController()
    {
        int i_count = ArraySize(_breakeven);
        for (int i = 0; i < i_count; ++i)
        {
            delete _breakeven[i];
        }
    }

    void DoTrading()
    {
        int i_count = ArraySize(_breakeven);
        for (int i = 0; i < i_count; ++i)
        {
            _breakeven[i].DoLogic();
        }
        datetime current_time = iTime(NULL, _Period, 0);
        if (current_time == _lastbartime)
        {
            return;
        }

        if (IsBuyCondition())
        {
            switch (LogicType)
            {
                case DirectLogic:
                    DoBuy();
                    break;
                case ReversalLogic:
                    DoSell();
                    break;
            }
        }
        if (IsSellCondition())
        {
            switch (LogicType)
            {
                case DirectLogic:
                    DoSell();
                    break;
                case ReversalLogic:
                    DoBuy();
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

    double CalculateStop(const bool isBuy, const double amount)
    {
        if (!SetStop)
            return 0;

        double basePrice = isBuy ? Ask : Bid;
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

    double CalculateLimit(const bool isBuy, const double limit, const StopLimitType limitType, const double amount)
    {
        double basePrice = isBuy ? Ask : Bid;
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
    
    double CalculateLimit(const bool isBuy, const double amount)
    {
        if (!SetLimit)
            return 0;

        return CalculateLimit(isBuy, Limit, LimitType, amount);
    }

    void DoBuy()
    {
        if (!ExitSLOnly)
        {
            CloseTrades(OP_SELL);
        }

        double amount = GetLots();
        int order = OrderSend(_symbol, OP_BUY, amount, Ask, Slippage, CalculateStop(true, amount), CalculateLimit(true, amount), NULL, MagicNumber);
        if (order != -1)
        {
            _lastbartime = iTime(NULL, _Period, 0);
            if (MoveToBreakeven)
                CreateBreakeven(order);
        }
        else
        {
            Print("Failed to open long position: " + IntegerToString(GetLastError()));
        }
    }

    void DoSell()
    {
        if (!ExitSLOnly)
        {
            CloseTrades(OP_BUY);
        }

        double amount = GetLots();
        int order = OrderSend(_symbol, OP_SELL, amount, Bid, Slippage, CalculateStop(false, amount), CalculateLimit(false, amount), NULL, MagicNumber);
        if (order != -1)
        {
            _lastbartime = iTime(NULL, _Period, 0);
            if (MoveToBreakeven)
                CreateBreakeven(order);
        }
        else
        {
            Print("Failed to open short position: " + IntegerToString(GetLastError()));
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
        double open = iOpen(_symbol, _Period, 0);
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
        double close = iClose(_symbol, _Period, 0);
        return close >= GetTargetPrice(1) 
            && SpreadValid() 
            && OrdersCount() < MaxOrders
            && (!IsPositionExist(OP_SELL) || !ExitSLOnly);
    }

    bool IsSellCondition()
    {
        double close = iClose(_symbol, _Period, 0);
        return close <= GetTargetPrice(-1) 
            && SpreadValid() 
            && OrdersCount() < MaxOrders
            && (!IsPositionExist(OP_BUY) || !ExitSLOnly);
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

    bool IsPositionExist(const int side)
    {
        for (int i = OrdersTotal() - 1; i >= 0; i--)
        {
            if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            {
                if (OrderMagicNumber() == MagicNumber 
                    && OrderSymbol() == _symbol 
                    && OrderType() == side)
                {
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

    void CreateBreakeven(const int order)
    {
        if (!OrderSelect(order, SELECT_BY_TICKET, MODE_TRADES))
            return;

        double trigger = CalculateLimit(OrderType() == OP_BUY, BreakevenTrigger, BreakevenTriggerType, OrderLots());
        double target = OrderType() == OP_BUY ? Ask : Bid;
        int i_count = ArraySize(_breakeven);
        for (int i = 0; i < i_count; ++i)
        {
            if (_breakeven[i].SetOrder(order, trigger, target))
            {
                return;
            }
        }

        ArrayResize(_breakeven, i_count + 1);
        _breakeven[i_count] = new BreakevenController();
        _breakeven[i_count].SetOrder(order, trigger, target);
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
