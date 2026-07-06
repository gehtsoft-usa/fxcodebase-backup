// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71878

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  |
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

// Your donations will allow the service to continue onward.
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

#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict

#define DAILY_LIMITS


// ------------------------------------------------------------------
datetime NewCandleTimeCurrent;

enum Profit_Level {
  Safe_Take_Profit_Level       = 0,  //  Safe  Take Profit Level
  Medium_Take_Profit_Level     = 1,  // Medium Take Profit Level
  Aggressive_Take_Profit_Level = 2   // Aggressive Take Profit Level
};
enum EnableDisable {
  Enable  = 0,
  Disable = 1
};

input bool           uMaxTradesOn             = false;    // Control Number of trades at same time:
input int            uMaxTrades               = 1;        // Max Trades At Same Time:
extern string        START_TIME               = "02:00";  // Start Time
extern string        STOP_TIME                = "20:00";  // End Time
extern double        STOP_LOSS_BUFFER         = 10;       //  Extra Stop Loss Pips
extern Profit_Level  TakeProfit               = Safe_Take_Profit_Level;
extern int           MAGIC_NUMBER             = 123456789;  // Magic  Number
extern EnableDisable rentry_trade             = Enable;     //  Rentry  Trade
extern EnableDisable trailling_stop_loss      = Disable;    // Trail Stop Loss
extern double        when_to_trail_l4         = 20;         //  When to trail
extern double        where_to_trail_l4        = 10;         //  Where to trail
extern double        Lot                      = 0.01;
extern EnableDisable useBreakEven             = Disable;  // Breakeven
extern double        when_to_trail_l1         = 7;        //  When To Breakeven
extern double        where_to_trail_l1        = 1;        //  Where to  Breakeven
extern string        INDICATOR_NAME           = "FiboMachinePro";
double               order_open_price_mapping = 0;
string               upcommingSignal          = "WAITING";

#ifdef DAILY_LIMITS
enum DayLimitsMode {
  LimitsByAmount,         // by Amount
  LimitsByAccountPercent  // by Account %
};
input string        Tlimits            = "== Daily Limits Setup ==";  // == Daily Limits Setup ==
input bool          uDailyProfitOn     = false;                       // Control Daily Profit On:
input DayLimitsMode limitProfitMode    = LimitsByAmount;              // Mode to control daily profit:
input double        uDayLimitProfit    = 2000;                        // Max Daily Profit ($ or %):
input bool          uDailyLossOn       = false;                       // Control Daily Loss On:
input DayLimitsMode limitLossMode      = LimitsByAmount;              // Mode to control daily loss:
input double        uDayLimitLoss      = -1000;                       // Max Daily Loss ($ or %):
input bool          uConsiderFloatting = false;                       // Consider Floating:
#endif

input string             Iema           = "== Moving Average Setup ==";  // == Moving Average Setup ==
input bool               uEmaFilterOn   = true;                          // M.A Filter On:
input int                maPeriod       = 50;                            // Period
int                      maShift        = 0;                             // Ma Shift
input ENUM_MA_METHOD     maMethod       = MODE_EMA;                      // Method
input ENUM_APPLIED_PRICE maAppliedPrice = PRICE_CLOSE;                   // Applied Price

// ------------------------------------------------------------------
class MovingAverage
{
   string _symbol;
   int    _tf;
   
   struct MovingAverageParameters
   {
      int setup0;  //  Period
      int setup1;  //  Ma Shift
      int setup2;  //  Method
      int setup3;  //  Applied Price
   };
   MovingAverageParameters _setup;

  public:
   MovingAverage()
   {
      _symbol = _Symbol;
      _tf     = Period();
   }
   MovingAverage(string Symbol, int TimeFrame)
   {
      _symbol = Symbol;
      _tf     = TimeFrame;
   }
   MovingAverage(string Symbol, int TimeFrame,int period, int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE appliedPrice)
   {
      _symbol = Symbol;
      _tf     = TimeFrame;
      setSetup(period, shift, method, appliedPrice);
   }
   ~MovingAverage() { ; }

   void setSetup(
       int set0,
       int set1,
       int set2,
       int set3)
   {
      _setup.setup0 = set0;
      _setup.setup1 = set1;
      _setup.setup2 = set2;
      _setup.setup3 = set3;
   }

   double calculate(int buffer, int shift)
   {
      return iMA(_symbol, _tf,
                 _setup.setup0,
                 _setup.setup1,
                 _setup.setup2,
                 _setup.setup3,
                 shift);
   }

   double index(int shift)
   {
      return calculate(0, shift);
   }

};
MovingAverage ma();

interface iConditions
{
  bool evaluate();
};
class ConcurrentConditions
{
 protected:
  iConditions* _conditions[];

 public:
  ConcurrentConditions(void) {}
  ~ConcurrentConditions(void) { releaseConditions(); }

  //+------------------------------------------------------------------+
  void releaseConditions()
  {
    for (int i = 0; i < ArraySize(_conditions); i++)
    {
      delete _conditions[i];
    }
    ArrayFree(_conditions);
  }
  //+------------------------------------------------------------------+
  void AddCondition(iConditions* condition)
  {
    int t = ArraySize(_conditions);
    ArrayResize(_conditions, t + 1);
    _conditions[t] = condition;
  }

  //+------------------------------------------------------------------+
  bool EvaluateConditions(void)
  {
    for (int i = 0; i < ArraySize(_conditions); i++)
    {
      if (!_conditions[i].evaluate())
      {
        return false;
      }
    }
    return true;
  }
};
ConcurrentConditions conditionsToBuy;
ConcurrentConditions conditionsToSell;

class ConditionCountTrades : public iConditions
{
  int _max;

 public:
  ConditionCountTrades(int maxTrades)
  {
    _max = maxTrades;
  }
  ~ConditionCountTrades() { ; }

  bool evaluate()
  {
    int count = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--)
    {
      if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == MAGIC_NUMBER)
      {
        count += 1;

        if (count == _max)
        {
          return false;
        }
      }
    }
    return true;
  }
};
ConditionCountTrades* countTrades;

class BUYcondition1 : public iConditions
{
 public:
  bool evaluate()
  {
    // TODO: condition Buy 1
    double ma1 = ma.index(1);
    double ma2 = ma.index(2);
    double ma3 = ma.index(3);

		double close1 = iClose(NULL,0,1);
		double close2 = iClose(NULL,0,2);
		double close3 = iClose(NULL,0,3);
    
		return close1 > ma1 && close2 > ma2 && close3 > ma3;
    // return false;
  }
};
BUYcondition1* buyCondition_EMA;

class SELLcondition1 : public iConditions
{
 public:
  bool evaluate()
  {
    // TODO: condition SELL 1
		double ma1 = ma.index(1);
    double ma2 = ma.index(2);
    double ma3 = ma.index(3);

		double close1 = iClose(NULL,0,1);
		double close2 = iClose(NULL,0,2);
		double close3 = iClose(NULL,0,3);
    
		return close1 < ma1 && close2 < ma2 && close3 < ma3;
    
		// return false;
  }
};
SELLcondition1* sellCondition_EMA;

class DailyProfitCondition : public iConditions
{
  int           _magic;
  double        _limit;
  bool          _considerOpen;  // Considera el flotante profit flotante
  string        _mode;          // loss or profit
  DayLimitsMode _limitMode;     // Amount or AccountPer
 public:
  DailyProfitCondition(double limit, int mag, bool considerOpen, string mode, DayLimitsMode limitMode) : _limit(limit), _magic(mag), _considerOpen(considerOpen), _mode(mode), _limitMode(limitMode) { ; }
  ~DailyProfitCondition() { ; }

  bool evaluate()
  {
    if (_mode == "profit")
    {
      if (TodayProfit() >= Limit())
      {
        Print("DAILY PROFIT REACHED: ", TodayProfit());
        return true;
      }
    }
    if (_mode == "loss")
    {
      if (TodayProfit() <= Limit())
      {
        Print("DAILY LOSS REACHED: ", TodayProfit());
        return true;
      }
    }
    return false;
  }

  double Limit()
  {
    if (_limitMode == LimitsByAmount)
    {
      return _limit;
    }
    if (_limitMode == LimitsByAccountPercent)
    {
      return _limit / 100 * AccountInfoDouble(ACCOUNT_BALANCE);
    }
    return 0;
  }

  double TodayProfit()
  {
    datetime iniDay = iTime(NULL, PERIOD_D1, 0);

    double profit = 0;
    for (int i = OrdersHistoryTotal() - 1; i >= 0; i--)
    {
      if (OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _Symbol && OrderMagicNumber() == _magic)
      {
        if (OrderCloseTime() >= iniDay)
        {
          profit += OrderProfit() + OrderSwap() + OrderCommission();
        }
      }
    }

    if (_considerOpen)
    {
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
        if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == _magic)
        {
          profit += OrderProfit() + OrderSwap() + OrderCommission();
        }
      }
    }

    return profit;
  }
};
DailyProfitCondition dailyProfitCondition(uDayLimitProfit, MAGIC_NUMBER, uConsiderFloatting, "profit", limitProfitMode);
DailyProfitCondition dailyLossCondition(uDayLimitLoss, MAGIC_NUMBER, uConsiderFloatting, "loss", limitLossMode);

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  //---
  // Calling Indicator  on Fibomachine
  double calling_indicator = iCustom(Symbol(), PERIOD_CURRENT, INDICATOR_NAME, 0, 1);  //  positive

  if (calling_indicator == 0.0)
  {
    Comment("====  Please Install Indicator /  Reload MT4");
  }
  //---

  ma.setSetup(maPeriod, maShift, maMethod, maAppliedPrice);
	if(uEmaFilterOn) conditionsToBuy.AddCondition(buyCondition_EMA = new BUYcondition1);
	if(uEmaFilterOn) conditionsToSell.AddCondition(sellCondition_EMA = new SELLcondition1);

  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  //---
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{

	// NOTE: Daily Limits:
	if (uDailyProfitOn) 
	{
    if (dailyProfitCondition.evaluate()) return;
  }
  if (uDailyLossOn)
  {
    if (dailyLossCondition.evaluate()) return;
  }

	if(uMaxTradesOn) if (!countTrades.evaluate()) return;

  // ------------------------------------------------------------------


  if ((StringCompare(TimeToString(TimeCurrent(), TIME_MINUTES), START_TIME) == 0 || StringCompare(TimeToString(TimeCurrent(), TIME_MINUTES), START_TIME) == 1) &&
      (StringCompare(TimeToString(TimeCurrent(), TIME_MINUTES), STOP_TIME) == -1 || StringCompare(TimeToString(TimeCurrent(), TIME_MINUTES), STOP_TIME) == 0)
  )
  {
    if (IsNewCandleCurrent())
    {
      // ChartIndicatorDelete(0,0,INDICATOR_NAME);
      double calling_indicator = iCustom(Symbol(), PERIOD_CURRENT, INDICATOR_NAME, 0, 1);  //  positive
    }
  }


  fx_handle_order_sl_tp_data();

  if (trailling_stop_loss == Enable)
  {
    fx_trail();
  }

  if (useBreakEven == Enable)
  {
    fx_trail_breakeven();
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_handle_order_sl_tp_data()
{
  int numberOfFibs = ObjectsTotal();
  // fs Line
  // fb Line
  // fe Line
  // tp1 Line
  // tp2 Line
  // tp3 Line

  string fb_line      = "";
  string fs_line      = "";
  string fe_line      = "";
  string tp1_line     = "";
  string tp2_line     = "";
  string tp3_line     = "";
  string fb_line_time = "";
  string fs_line_time = "";

  string name;
  string output[];
  int    i;
  for (i = 0; i < numberOfFibs; i++)
  {
    name  = ObjectName(i);
    int k = StringSplit(name, StringGetCharacter("FBP_", 3), output);
    if (ArraySize(output) > 1)
    {
      if (output[1] == "fb Line")
      {
        fb_line      = ObjectGetDouble(0, name, OBJPROP_PRICE, 0);
        fb_line_time = ObjectGetInteger(0, name, OBJPROP_TIME, 0);
      }

      if (output[1] == "fe Line")
      {
        fe_line = ObjectGetDouble(0, name, OBJPROP_PRICE, 0);
      }
      if (output[1] == "tp1 Line")
      {
        tp1_line = ObjectGetDouble(0, name, OBJPROP_PRICE, 0);
      }

      if (output[1] == "tp2 Line")
      {
        tp2_line = ObjectGetDouble(0, name, OBJPROP_PRICE, 0);
      }

      if (output[1] == "tp3 Line")
      {
        tp3_line = ObjectGetDouble(0, name, OBJPROP_PRICE, 0);
      }
      if (output[1] == "fs Line")
      {
        fs_line      = ObjectGetDouble(0, name, OBJPROP_PRICE, 0);
        fs_line_time = ObjectGetInteger(0, name, OBJPROP_TIME, 0);
      }
    }

    if (i == numberOfFibs - 1)
    {
      //  Comment     (   fb_line    , "Fb Line "   ,  fs_line  , "Fs Line ", tp1_line   , "tp1 line"   ,   tp2_line   , "tp2 line "  ,  tp3_line   , "tp3 line"    );
      if (fb_line != "")
      {
        Comment(fx_is_exist_trade(), "Data Goes");
        if (fb_line < Bid + 10 * Point && fb_line > Bid - 10 * Point)
        {
          if (fx_is_exist_trade() == true && fx_is_rentry_trade("BUY"))
          {
            //   Time Mapping  is Left

						// NOTE: BUY 
						if (conditionsToBuy.EvaluateConditions())
						{
							fx_take_trade_order(0, fe_line, tp1_line, tp2_line, tp3_line);
            	order_open_price_mapping = fb_line;
						}
          }
        }
      }
      if (fs_line != "")
      {
        //  Alert ( "Sell  Line  Goes  Here ") ;

        if (fs_line < Bid + 10 * Point && fs_line > Bid - 10 * Point)
        {
          if (fx_is_exist_trade() == true && fx_is_rentry_trade("SELL"))
          {

						// NOTE: SELL						
						if (conditionsToSell.EvaluateConditions())
						{
            	fx_take_trade_order(1, fe_line, tp1_line, tp2_line, tp3_line);
	            order_open_price_mapping = fs_line;
						}
          }
        }
      }
    }
  }

  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool fx_is_rentry_trade(string mapping_signal)
{
  if (rentry_trade == Disable)
  {
    if (upcommingSignal == "WAITING" || upcommingSignal != mapping_signal)
    {
      upcommingSignal = mapping_signal;
      return true;
    }
  }

  if (rentry_trade == Enable)
  {
    return true;
  }

  return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool fx_is_exist_trade()
{
  for (int fx = 0; fx < OrdersTotal(); fx++)
  {
    if (OrderSelect(fx, SELECT_BY_POS))
    {
      if (OrderComment() == "TRADE" && OrderSymbol() == Symbol())
      {
        return false;
      }
    }
  }
  return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_trail()
{
  for (int fx = 0; fx < OrdersTotal(); fx++)
  {
    if (OrderSelect(fx, SELECT_BY_POS))
    {
      if (OrderType() == 0 && OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC_NUMBER)
      {
        double bid_price = fx_bidder(OrderSymbol());
        if (bid_price - OrderOpenPrice() > when_to_trail_l4 * fx_pips_evaluation(OrderSymbol()) * MarketInfo(OrderSymbol(), MODE_POINT))
        {
          double local_strage = bid_price - where_to_trail_l4 * fx_pips_evaluation(OrderSymbol()) * MarketInfo(OrderSymbol(), MODE_POINT);
          if (OrderStopLoss() < local_strage || OrderStopLoss() == 0.0)
          {
            fx_order_modification(OrderTicket(), OrderOpenPrice(), local_strage, OrderTakeProfit(), 0, "NONE", OrderMagicNumber());
          }
        }
      }

      if (OrderType() == 1 && OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC_NUMBER)
      {
        double ask_price = fx_asker(OrderSymbol());

        if (OrderOpenPrice() - ask_price > when_to_trail_l4 * fx_pips_evaluation(OrderSymbol()) * MarketInfo(OrderSymbol(), MODE_POINT))
        {
          double local_strage = ask_price + where_to_trail_l4 * fx_pips_evaluation(OrderSymbol()) * MarketInfo(OrderSymbol(), MODE_POINT);
          if (OrderStopLoss() > local_strage || OrderStopLoss() == 0.0)
          {
            fx_order_modification(OrderTicket(), OrderOpenPrice(), local_strage, OrderTakeProfit(), 0, "NONE", OrderMagicNumber());
          }
        }
      }
    }
  }

  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_trail_breakeven()
{
  for (int b = OrdersTotal() - 1; b >= 0; b--)
  {
    if (OrderSelect(b, SELECT_BY_POS))
    {
      if (OrderType() == 0 && OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC_NUMBER)
      {
        double ask_price = fx_asker(OrderSymbol());
        double bid_price = fx_bidder(OrderSymbol());
        if (bid_price - OrderOpenPrice() > when_to_trail_l1 * fx_pips_evaluation(OrderSymbol()) * MarketInfo(OrderSymbol(), MODE_POINT))
        {
          double local_strage = OrderOpenPrice() + where_to_trail_l1 * fx_pips_evaluation(OrderSymbol()) * MarketInfo(OrderSymbol(), MODE_POINT);
          if (OrderStopLoss() < OrderOpenPrice() && ask_price > OrderOpenPrice())
          {
            fx_order_modification(OrderTicket(), OrderOpenPrice(), local_strage, OrderTakeProfit(), 0, "NONE", OrderMagicNumber());
          }
        }
      }

      if (OrderType() == 1 && OrderSymbol() == Symbol() && OrderMagicNumber() == MAGIC_NUMBER)
      {
        double ask_price = fx_asker(OrderSymbol());
        double bid_price = fx_bidder(OrderSymbol());
        if (OrderOpenPrice() - ask_price > when_to_trail_l1 * fx_pips_evaluation(OrderSymbol()) * MarketInfo(OrderSymbol(), MODE_POINT))
        {
          double local_strage = OrderOpenPrice() - where_to_trail_l1 * fx_pips_evaluation(OrderSymbol()) * MarketInfo(OrderSymbol(), MODE_POINT);
          if (OrderStopLoss() > OrderOpenPrice() && bid_price < OrderOpenPrice())
          {
            fx_order_modification(OrderTicket(), OrderOpenPrice(), local_strage, OrderTakeProfit(), 0, "NONE", OrderMagicNumber());
          }
        }
      }
    }
  }

  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_pips_evaluation(string symbol_mapping)
{
  // double point = MarketInfo(OrderSymbol(), MODE_POINT);
  int digits = (int)MarketInfo(symbol_mapping, MODE_DIGITS);
  if (digits == 2)
  {
    return 100;
    // Lot   =    0.01;ize =  0.01;
  } else if (digits == 4 || digits == 5)
  {
    return 10;
  } else
  {
    return 1;
  }

  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fx_asker(string symbol_mapping)
{
  return MarketInfo(symbol_mapping, MODE_ASK);

  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fx_bidder(string symbol_mapping)
{
  return MarketInfo(symbol_mapping, MODE_BID);

  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_order_modification(int ticket, double order_open_price, double local_storage_stop_loss, double order_take_profit, int expiration, string additional, int order_magic_number)
{
  // OrderTicket()  , OrderOpenPrice() ,local_strage ,OrderTakeProfit(), 0 , "NONE" ,  OrderMagicNumber()

  // OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice()-(StopLoss*pips),OrderOpenPrice()+(TakeProfit*pips), 0, CLR_NONE); // OP_BUY
  // Alert (   local_storage_stop_loss ,   "Local Storage Stop Loss" );
  bool res = OrderModify(ticket, order_open_price, local_storage_stop_loss, order_take_profit, expiration, CLR_NONE);
  if (!res)
  {
    Alert("Error in OrderModify. Error code=", GetLastError());
  }

  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_take_trade_order(int order_type, double stop_loss, double tp1_line, double tp2_line, double tp3_line)
{
  //  calculate  currrent  symbol  have  any trade  There

  double Spread         = MarketInfo(Symbol(), MODE_SPREAD);
  bool   response_order = OrderSend(Symbol(), order_type, Lot, order_type == 0 ? Ask : Bid, 10, NormalizeDouble(fx_stoploss_evaluation(stop_loss, order_type), Digits()), NormalizeDouble(fx_tp_evaluation(tp1_line, tp2_line, tp3_line), Digits()), "TRADE", MAGIC_NUMBER, 0, clrNONE);
  if (!response_order)
  {
    Print(GetLastError(), "GetLastError()========================");
  } else
  {
  }
  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fx_tp_evaluation(double tp1_line, double tp2_line, double tp3_line)
{
  if (TakeProfit == Safe_Take_Profit_Level)
  {
    return tp1_line;
  }
  if (TakeProfit == Safe_Take_Profit_Level)
  {
    return tp2_line;
  }
  if (TakeProfit == Aggressive_Take_Profit_Level)
  {
    return tp3_line;
  }

  return 0;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewCandleCurrent()
{
  if (NewCandleTimeCurrent == iTime(Symbol(), PERIOD_CURRENT, 0))
    return false;
  else
  {
    NewCandleTimeCurrent = iTime(Symbol(), PERIOD_CURRENT, 0);
    return true;
  }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double fx_stoploss_evaluation(double stop_loss_mapping, int order_type)
{
  if (order_type == 0)
  {
    return stop_loss_mapping - fx_pips_evaluation(Symbol()) * STOP_LOSS_BUFFER * Point;
  }
  if (order_type == 1)
  {
    return stop_loss_mapping + fx_pips_evaluation(Symbol()) * STOP_LOSS_BUFFER * Point;
  }

  return 0;
}

//+------------------------------------------------------------------+

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
