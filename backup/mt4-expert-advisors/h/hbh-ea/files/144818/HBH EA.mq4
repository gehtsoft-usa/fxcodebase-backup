// More information about this indicator can be found at:
// http://fxcodebase.com/ 

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




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
// Includes
enum ModeCalcLots { Money,
                    AccountPercent,
                    UserLots };
input string       IHBH                  = "== HBH Setup ==";      // == HBH Setup ==
input int          MaMethod              = 1;                      //  Ma Method:
input int          MaPeriod              = 15;                     //  Ma Period:
input string       T0                    = "== Trade Setup ==";    // == Trade Setup ==
input ModeCalcLots modeCalcLots          = UserLots;               // Mode to Calc Lots:
input double       userMoney             = 10;                     // Setup Lots by "Money":
input double       userBalancePer        = 0.1;                    // Setup Lots by "Account Percent":
input double       userLots              = 0.01;                   // Setup Lots by "User Lots":
input int          userTPpips            = 20;                     // Pips TP
input int          userSLpips            = 20;                     // Pips SL
input bool         closeOposite          = true;                   // Close in Oposite Signal:
input string       T1                    = "== Timer ==";          // Timer
input string       timeStart             = "00:00:00";             // Time Start GMT
input string       timeEnd               = "23:59:59";             // Time End GMT
input string       TZ                    = "== Notifications ==";  // Notifications
input bool         notifications         = false;                  // Notifications
input bool         desktop_notifications = false;                  // Desktop MT4 Notifications
input bool         email_notifications   = false;                  // Email Notifications
input bool         push_notifications    = false;                  // Push Mobile Notifications
input int          magico                = 1;                      // Magic Number:

interface iIndicators
{
   double calculate(int bufferNumber, int shift);
};
class HBH : public iIndicators
{
   string _symbol;
   int    _tf;
   string _file;
   struct HBHsetup
   {
      int setup0;  //  Ma Method
      int setup1;  //  Ma Period
   };
   HBHsetup _setup;

  public:
   HBH(string Symbol, int TimeFrame)
   {
      _symbol = Symbol;
      _tf     = TimeFrame;
      _file   = "HBH.ex4";
      setSetup(MaMethod, MaPeriod);
      printSetup();
   }
   ~HBH() { ; }

   HBH* file(string setfile)
   {
      _file = setfile;
      return &this;
   }

   void setSetup(int set0, int set1)
   {
      _setup.setup0 = set0;
      _setup.setup1 = set1;
   }

   double calculate(int buffer, int shift)
   {
      return iCustom(_symbol, _tf, _file, _setup.setup0, _setup.setup1, buffer, shift);
   }

   double lastValue(int buffer, bool candle = false)
   {
      double value = 0;
      int    i     = 0;
      while (value == 0 || i == 2000)
      {
         value = calculate(buffer, i);
         i++;
      }

      if (candle)
      {
         return i;
      }
      return value;
   }

   void printSetup()
   {
      Print("setup0 : ", _setup.setup0);
      Print("setup1 : ", _setup.setup1);
      // Print("setup2 : ", _setup.setup2);
      // Print("setup3 : ", _setup.setup3);
      // Print("setup4 : ", _setup.setup4);
      // Print("setup5 : ", _setup.setup5);
      // Print("setup6 : ", _setup.setup6);
      // Print("setup7 : ", _setup.setup7);
      // Print("setup8 : ", _setup.setup8);
      // Print("setup9 : ", _setup.setup9);
      // Print("setup10: ", _setup.setup10);
   }
};
HBH hbh(_Symbol, _Period);

// Gobal Variables
//////////////////////////////////////////////////////////////////////
bool CloseCandleMode = true;
class LotCalculator
{
   double _tickValue;
   double _modeCalc;
   double _contractSize;
   double _step;
   string _symbol;
   double _points;
   double _digits;

  public:
   LotCalculator(string inpSymbol = "") { setSymbol(inpSymbol); };
   ~LotCalculator() { ; }

   void setSymbol(string sym)
   {
      if (sym == "")
      {
         _symbol = Symbol();
      } else
      {
         _symbol = sym;
      }
      _tickValue    = MarketInfo(_symbol, MODE_TICKVALUE);
      _modeCalc     = MarketInfo(_symbol, MODE_PROFITCALCMODE);
      _contractSize = SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
      _step         = MarketInfo(_symbol, MODE_LOTSTEP);
      _points       = MarketInfo(_symbol, MODE_POINT);
      _digits       = MarketInfo(_symbol, MODE_DIGITS);
   }

   double LotsByBalancePercent(double BalancePercent, double Distance)
   {
      double risk = AccountBalance() * BalancePercent / 100;
      return CalculateLots(risk, Distance);
   }

   double LotsByMoney(double Money, double Distance)
   {
      double risk = fabs(Money);
      return CalculateLots(risk, Distance);
   }

   double CalculateLots(double risk, double distance)
   {
      distance *= 10;
      if (distance == 0)
      {
         return 0;
      }

      //FOREX
      if (_modeCalc == 0)
      {
         return NormalizeDouble(risk / distance / _tickValue, 2);
      }

      //FUTUROS
      if (_modeCalc == 1 && _step != 1.0)
      {
         double c = _contractSize * _step;
         return NormalizeDouble(risk / (distance * c), 2);
      }

      //FUTUROS SIN DECIMALES
      if (_modeCalc == 1 && _step == 1.0)
      {
         double c = _contractSize * _step;
         return MathFloor(risk / (distance * c) * 100);
      }

      return 0;
   }
};
LotCalculator* lotProvider;

enum enumDays { sunday,
                monday,
                tuesday,
                wednesday,
                thursday,
                friday,
                saturday,
                EA_OFF };
class Session
{
   int _iniTime;  // second from 00:00 hr of the day
   int _endTime;
   int _dayNumber;

  public:
   // receive time in format 00:00
   Session(string iniTime, string endTime, int dayNumber = 0)
   {
      _iniTime   = secondsFromZeroHour(iniTime);
      _endTime   = secondsFromZeroHour(endTime);
      _dayNumber = dayNumber;
   };

   ~Session() {}

   int iniTime() { return _iniTime; }
   int endTime() { return _endTime; }
   int dayNumber() { return _dayNumber; }

   int secondsFromZeroHour(string time)
   {
      int hh = (int)StringSubstr(time, 0, 2);
      int mm = (int)StringSubstr(time, 3, 2);

      return (hh * 3600) + (mm * 60);
   }
};
class ScheduleController
{
   Session* schedules[];
   int      _actualIndex;
   Session* _actualSession;
   int      _currentDay;

  public:
   ScheduleController()
   {
      setCurrentDay();
   };
   ~ScheduleController()
   {
      ClearShchedules();
   }

   Session* at() { return _actualSession; }

   void setCurrentDay()
   {
      _currentDay = TimeDay(TimeGMT());  // return the day of the month 1-31
   }

   bool isNewDay()
   {
      if (TimeDay(TimeGMT()) != _currentDay)
      {
         setCurrentDay();
         return true;
      }

      return false;
   }

   void setActualSession(int index)
   {
      _actualIndex = index;

      if (index > -1)
      {
         _actualSession = schedules[index];
      }
   }

   int qnt()
   {
      return ArraySize(schedules);
   }

   bool AddSession(string ini, string end, int day = 0)
   {
      Session* sc = new Session(ini, end, day);
      int      t  = qnt();
      if (ArrayResize(schedules, t + 1))
      {
         schedules[t] = sc;
         return true;
      }

      return false;
   }

   bool ClearShchedules()
   {
      for (int i = 0; i < qnt(); i++)
      {
         delete schedules[i];
      }
      ArrayFree(schedules);

      return true;
   }

   bool doSessionControl()  // control day and hours for every session
   {
      Comment("Daily Control - EA OFF");

      int actual = (TimeHour(TimeGMT()) * 3600) + (TimeMinute(TimeGMT()) * 60);

      for (int i = 0; i < qnt(); i++)
      {
         if (schedules[i].dayNumber() == EA_OFF)
         {
            continue;
         }

         if (schedules[i].dayNumber() != 0)
         {
            if (schedules[i].dayNumber() == TimeDayOfWeek(TimeGMT()))
            {
               if ((actual >= schedules[i].iniTime()) && actual <= schedules[i].endTime())
               {
                  setActualSession(i);
                  Comment("Daily Control - EA ON");
                  return true;
               }
            }
         }

         if (schedules[i].dayNumber() == 0)
         {
            if ((actual >= schedules[i].iniTime()) && actual <= schedules[i].endTime())
            {
               setActualSession(i);
               Comment("Daily Control - EA ON");
               return true;
            }
         }
      }

      //---
      setActualSession(-1);
      return false;
   }

   void PrintDays()
   {
      for (int i = 0; i < qnt(); i++)
      {
         PrintDay(i);
      }
   }

   void PrintDay(int i)
   {
      Print("Day Nr: ", schedules[i].dayNumber());
      Print("Day Ini Time: ", schedules[i].iniTime());
      Print("Day End Time: ", schedules[i].endTime());
   }
};
ScheduleController sesionControl;

class CNewCandle
{
  private:
   int    velasInicio;
   string m_symbol;
   int    m_tf;

  public:
   CNewCandle();
   CNewCandle(string symbol, int tf) : m_symbol(symbol), m_tf(tf), velasInicio(iBars(symbol, tf)) {}
   ~CNewCandle();

   bool IsNewCandle();
};
CNewCandle::CNewCandle()
{
   // toma los valores del chart actual
   velasInicio = iBars(Symbol(), Period());
   m_symbol    = Symbol();
   m_tf        = Period();
}
CNewCandle::~CNewCandle() {}
bool CNewCandle::IsNewCandle()
{
   int velasActuales = iBars(m_symbol, m_tf);
   if (velasActuales > velasInicio)
   {
      velasInicio = velasActuales;
      return true;
   }

   //---
   return false;
}
CNewCandle* newCandle;

class Order
{
   int      _id;
   string   _symbol;
   double   _price;
   double   _sl;
   double   _tp;
   double   _lot;
   int      _type;
   int      _magic;
   string   _comment;
   string   _strategy;
   datetime _expireTime;
   datetime _signalTime;
   double   _profit;

  public:
   Order(
       int      id,
       string   symbol,
       double   price,
       double   sl,
       double   tp,
       double   lot,
       int      type,
       int      magic,
       string   comment,
       string   strategy,
       datetime expireTime,
       datetime signalTime,
       double   profit) : _id(id),
                        _symbol(symbol),
                        _price(price),
                        _sl(sl),
                        _tp(tp),
                        _lot(lot),
                        _type(type),
                        _magic(magic),
                        _comment(comment),
                        _strategy(strategy),
                        _expireTime(expireTime),
                        _signalTime(signalTime),
                        _profit(profit) {}

   Order() {}
   ~Order() {}
   // clang-format off
	Order* id(int id){_id=id; return &this;}
	Order* symbol(string symbol){_symbol=symbol; return &this;}
	Order* price(double price){_price=price; return &this;}
	Order* sl(double sl){_sl=sl; return &this;}
	Order* tp(double tp){_tp=tp; return &this;}
	Order* lot(double lot){_lot=lot; return &this;}
	Order* type(int type){_type=type; return &this;}
	Order* magic(int magic){_magic=magic; return &this;}
	Order* comment(string comment){_comment=comment; return &this;}
	Order* strategy(string strategy){_strategy=strategy; return &this;}
	Order* expireTime(datetime expireTm){_expireTime=expireTm; return &this;}
	Order* signalTime(datetime signalTm){_signalTime=signalTm; return &this;}
	Order* profit(double profit){_profit=profit; return &this;}

   int            id()         { return _id; }
   string         symbol()     { return _symbol; }
   double         price()      { return _price; }
   double         sl()         { return _sl; }
   double         tp()         { return _tp; }
   double         lot()        { return _lot; }
   int            type()       { return _type; }
   int            magic()      { return _magic; }
   string         comment()    { return _comment; }
   string         strategy()   { return _strategy; }
   datetime       expireTime() { return _expireTime; }
   datetime       signalTime() { return _signalTime; }
   double         profit()     { return _profit; }
   // clang-format on
};

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
interface iActions
{
   bool doAction();
};
class SendNewOrder : public iActions
{
  private:
   Order newOrder;

  public:
   SendNewOrder(string side, double lots, string symbol = "", double price = 0, double sl = 0, double tp = 0, int magic = 0, string coment = "", datetime expire = 0)
   {
      string _symbol = setSymbol(symbol);
      double _price  = setPrice(side, price, _symbol);
      int    _type   = SetType(side, price, _symbol);
      if (_type == -1)
      {
         Print(__FUNCTION__, " ", "Imposible to set OrderType");
         return;
      }

      newOrder
          .id(OrderTicket())
          .symbol(_symbol)
          .type(_type)
          .price(_price)
          .sl(sl)
          .tp(tp)
          .lot(lots)
          .magic(magic)
          .comment(coment)
          .expireTime(expire)
          .profit(0);
   }

   ~SendNewOrder() {}

   string setSymbol(string sim)
   {
      if (sim == "")
      {
         return Symbol();
      }
      return sim;
   }

   double setPrice(string side, double pr, string sym)
   {
      if (pr == 0)
      {
         if (side == "buy")
         {
            return SymbolInfoDouble(sym, SYMBOL_ASK);
         }
         if (side == "sell")
         {
            return SymbolInfoDouble(sym, SYMBOL_BID);
         }
      }

      return pr;
   }

   int SetType(string side, double priceClient, string sym)
   {
      double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
      double bid = SymbolInfoDouble(sym, SYMBOL_BID);

      if (priceClient == 0)
      {
         if (side == "buy")
         {
            return (int)OP_BUY;
         }
         if (side == "sell")
         {
            return (int)OP_SELL;
         }
      } else
      {
         if (side == "buy")
         {
            if (priceClient > ask)
            {
               return (int)OP_BUYSTOP;
            }
            if (priceClient < ask)
            {
               return (int)OP_BUYLIMIT;
            }
         }
         if (side == "sell")
         {
            if (priceClient > bid)
            {
               return (int)OP_SELLLIMIT;
            }
            if (priceClient < bid)
            {
               return (int)OP_SELLSTOP;
            }
         }
      }

      return -1;
   }

   bool doAction()
   {
      int tk = OrderSend(newOrder.symbol(), newOrder.type(), newOrder.lot(), newOrder.price(), 1000, newOrder.sl(), newOrder.tp(), newOrder.comment(), newOrder.magic(), newOrder.expireTime(), clrNONE);

      if (tk < 0)
      {
         Print(__FUNCTION__, " ", "Connot Send Order, error: ", GetLastError());
         return false;
      }

      return true;
   }
};

class ActionCloseOrdersByType : public iActions
{
   ENUM_ORDER_TYPE _type;
   string          _symbol;
   int             _magic;
   int             _slippage;
   double          _price;

  public:
   ActionCloseOrdersByType(string side, int magic = 0, string symbol = "", int slippage = 10000)
   {
      if (side == "buy") _type = OP_BUY;
      if (side == "sell") _type = OP_SELL;
      if (symbol == "")
      {
         _symbol = Symbol();
      } else
      {
         _symbol = symbol;
      }
      if (magic != 0)
      {
         _magic = magic;
      }
      if (slippage != 10000)
      {
         _slippage = slippage;
      }
   }
   ~ActionCloseOrdersByType() {}

   void setPrice()
   {
      if (_type == OP_BUY)
      {
         _price = SymbolInfoDouble(_symbol, SYMBOL_BID);
      }
      if (_type == OP_SELL)
      {
         _price = SymbolInfoDouble(_symbol, SYMBOL_ASK);
      }
   }

   bool doAction()
   {
      setPrice();
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _symbol && OrderMagicNumber() == _magic)
         {
            if (OrderClose(OrderTicket(), OrderLots(), _price, _slippage, clrNONE))
            {
               return true;
            } else
            {
               Print(__FUNCTION__, " ", "can't close Order: ", OrderTicket(), " error: ", GetLastError());
               return false;
            }
         }
      }
      return true;
   }
};

ConcurrentConditions     conditionsToBuy;
ConcurrentConditions     conditionsToSell;
ConcurrentConditions     conditionsToCloseBuy;
ConcurrentConditions     conditionsToCloseSell;
SendNewOrder*            actionSendOrder;
ActionCloseOrdersByType* actionCloseSells;
ActionCloseOrdersByType* actionCloseBuys;

// NOTE: buy sell conditions
class CustomConditionBUY : public iConditions
{
  public:
   bool evaluate()
   {
      if ((hbh.calculate(4, 1) == 1) && (hbh.calculate(4, 2) == -1))
      {
         return true;
      }

      return false;
   }
};
CustomConditionBUY* entryBuy;
class CustomConditionBUY2 : public iConditions
{
  public:
   bool evaluate()
   {
      // TODO: dev condition

      return false;
   }
};
CustomConditionBUY2* customConditionBuy2;
class ConditionCountBuys : public iConditions
{
   int _maxBuys;

  public:
   ConditionCountBuys(int maxBuys)
   {
      _maxBuys = maxBuys;
   }
   ~ConditionCountBuys() { ; }

   bool evaluate()
   {
      int count = 0;
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
         {
            if (OrderType() == OP_BUY)
            {
               count += 1;
            }

            if (count == _maxBuys)
            {
               return false;
            }
         }
      }
      return true;
   }
};
ConditionCountBuys* countBuys;
class CustomConditionSELL : public iConditions
{
  public:
   bool evaluate()
   {
      if ((hbh.calculate(4, 1) == -1) && (hbh.calculate(4, 2) == 1))
      {
         return true;
      }
      return false;
   }
};
CustomConditionSELL* entrySell;
class CustomConditionSELL2 : public iConditions
{
  public:
   bool evaluate()
   {
      // TODO: dev condition
      return false;
   }
};
CustomConditionSELL2* customConditionSell2;
class ConditionCountSells : public iConditions
{
   int _maxSells;

  public:
   ConditionCountSells(int maxSells)
   {
      _maxSells = maxSells;
   }
   ~ConditionCountSells() { ; }

   bool evaluate()
   {
      int count = 0;
      for (int i = OrdersTotal() - 1; i >= 0; i--)
      {
         if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
         {
            if (OrderType() == OP_SELL)
            {
               count += 1;
            }

            if (count == _maxSells)
            {
               return false;
            }
         }
      }
      return true;
   }
};
ConditionCountSells* countSells;
class ConditionToCloseBuy : public iConditions
{
  public:
   bool evaluate()
   {
      if(conditionsToSell.EvaluateConditions())
      {
         return true;
      }
      return false;
   }
};
ConditionToCloseBuy* conditionCloseBuy;
class ConditionToCloseSell : public iConditions
{
  public:
   bool evaluate()
   {
      if(conditionsToBuy.EvaluateConditions())
      {
         return true;
      }
      return false;
   }
};
ConditionToCloseSell* conditionCloseSell;

//////////////////////////////////////////////////////////////////////

int OnInit()
{
   newCandle = new CNewCandle();

   //--- CONDITIONS TO OPEN TRADES:
   conditionsToBuy.AddCondition(entryBuy = new CustomConditionBUY());
   // conditionsToBuy.AddCondition(customConditionBuy2 = new CustomConditionBUY2());
   conditionsToBuy.AddCondition(countBuys = new ConditionCountBuys(1));
   conditionsToSell.AddCondition(entrySell = new CustomConditionSELL());
   // conditionsToSell.AddCondition(customConditionSell2 = new CustomConditionSELL2());
   conditionsToSell.AddCondition(countSells = new ConditionCountSells(1));

   //--- CONDITIONS TO CLOSE TRADES:
   conditionsToCloseBuy.AddCondition(conditionCloseBuy = new ConditionToCloseBuy());
   conditionsToCloseSell.AddCondition(conditionCloseSell = new ConditionToCloseSell());

   //--- SESSIONS CONTROL:
   sesionControl.AddSession(timeStart, timeEnd);
   EventSetTimer(1);

   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
   delete newCandle;
}
void OnTick()
{
   if (CloseCandleMode)
      if (!newCandle.IsNewCandle())
      {
         return;
      }

   if (!sesionControl.doSessionControl())
   {
      return;
   }

   if(closeOposite)
   {
   if (conditionsToCloseBuy.EvaluateConditions())
   {
      actionCloseBuys = new ActionCloseOrdersByType("buy", magico);
      actionCloseBuys.doAction();
      delete actionCloseBuys;
   }
   if (conditionsToCloseSell.EvaluateConditions())
   {
      actionCloseSells = new ActionCloseOrdersByType("sell", magico);
      actionCloseSells.doAction();
      delete actionCloseSells;
   }
   }

   if (conditionsToBuy.EvaluateConditions())
   {
      actionSendOrder = new SendNewOrder("buy", Lots(), "", 0, SL("buy"), TP("buy"), magico);
      if (actionSendOrder.doAction())
      {
         Notifications(0);
      }
      delete actionSendOrder;
   }
   if (conditionsToSell.EvaluateConditions())
   {
      actionSendOrder = new SendNewOrder("sell", Lots(), "", 0, SL("sell"), TP("sell"), magico);
      if (actionSendOrder.doAction())
      {
         Notifications(1);
      }
      delete actionSendOrder;
   }
}
void OnTimer(void) {}

//////////////////////////////////////////////////////////////////////

double Price(string direction)
{
   double result = 0;
   if (direction == "buy")
   {
      result = Ask;
      return result;
   }

   if (direction == "sell")
   {
      result = Bid;
      return result;
   }

   return -1;
}
double SL(string direction)
{
   double result = 0;
   if (userSLpips == 0)
   {
      return 0;
   }
   if (direction == "buy")
   {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      result     = ask - userSLpips * 10 * _Point;
      return result;
   }

   if (direction == "sell")
   {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      result     = bid + userSLpips * 10 * _Point;
      return result;
   }

   return -1;
}
double TP(string direction)
{
   double result = 0;
   if (userTPpips == 0)
   {
      return 0;
   }
   if (direction == "buy")
   {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      result     = ask + userTPpips * 10 * _Point;
      return result;
   }

   if (direction == "sell")
   {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      result     = bid - userTPpips * 10 * _Point;
      return result;
   }

   return -1;
}
double Lots()
{
   lotProvider = new LotCalculator();
   double lots = -1;
   switch (modeCalcLots)
   {
      case Money:
         lots = lotProvider.LotsByMoney(userMoney, userTPpips);
         break;

      case AccountPercent:
         lots = lotProvider.LotsByBalancePercent(userBalancePer, userTPpips);
         break;

      case UserLots:
         lots = userLots;
         break;
   }
   delete lotProvider;
   return lots;
}
void Notifications(int type)
{
   string text = "";
   if (type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
   else
      text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

   text += " ";

   if (!notifications)
      return;
   if (desktop_notifications)
      Alert(text);
   if (push_notifications)
      SendNotification(text);
   if (email_notifications)
      SendMail("MetaTrader Notification", text);
}
string GetTimeFrame(int lPeriod)
{
   switch (lPeriod)
   {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
   }
   return IntegerToString(lPeriod);
}
