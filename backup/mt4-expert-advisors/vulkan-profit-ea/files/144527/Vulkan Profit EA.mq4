// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71730

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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




#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
// Includes

input string             T0                    = "== Trade Setup ==";      // Trade Setup
input double             userLots              = 0.01;                     // Lots:
input int                userTPPips            = 15;                       // TP pips:
input int                userSLPips            = 10;                       // SL pips:
input int                candlesBack           = 10; // Maximum bars back to valid signal:
input string             T2                    = "== Vulcan Profits Setup ==";  // Vulcan Profits Setup
input int                inpVPbars             = 1000;                       // VP Bars:
input int                inpVPversion          = 1;                        // VP version
bool                     inpVPAlerts           = false; // VP Alerts
bool                     inpVPChanelAlerts     = false; // VP Channel Alerts
bool                     inpVPmail             = false; // VP Mail Alerts
input int                inpVPWMA              = 3; // VP WMA:
input int                inpVPWMAslow          = 8; // VP slower LWMA:
input int                inpVPFasterSidusEMA   = 18; // VP FasterSidusEMA:
input int                inpVPSlowerSidusEMA   = 28; // VP SlowerSidusEMA:

input string             T1                    = "== Timer ==";            // Timer
input string             timeStart             = "00:00:00";               // Time Start GMT
input string             timeEnd               = "23:59:59";               // Time End GMT
input string             TZ                    = "== Notifications ==";    // Notifications
input bool               notifications         = false;                     // Notifications
input bool               desktop_notifications = false;                     // Desktop MT4 Notifications
input bool               email_notifications   = false;                     // Email Notifications
input bool               push_notifications    = false;                     // Push Mobile Notifications
input int                magico                = 1007;                     // Magic Number:

// Gobal Variables
//////////////////////////////////////////////////////////////////////
bool CloseCandleMode = true;  // meter en la clase CloseCandle
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

ConcurrentConditions conditionsToBuy;
ConcurrentConditions conditionsToSell;
SendNewOrder*        actionSendOrder;

// NOTE: buy sell conditions
class CustomConditionBUY : public iConditions
{
  public:
   bool evaluate()
   {
      double buf=0;
      double values[];
      for(int i=0;i < candlesBack;i++)
		{
         buf = iCustom(Symbol(), Period(), "Vulkan Profit.ex4",inpVPbars,inpVPversion,inpVPAlerts,inpVPChanelAlerts,inpVPmail,inpVPWMA,inpVPWMAslow,inpVPFasterSidusEMA,inpVPSlowerSidusEMA, 0, i) == EMPTY_VALUE ? 0:iCustom(Symbol(), Period(), "Vulkan Profit.ex4",inpVPbars,inpVPversion,inpVPAlerts,inpVPChanelAlerts,inpVPmail,inpVPWMA,inpVPWMAslow,inpVPFasterSidusEMA,inpVPSlowerSidusEMA, 0, i);

         int t = ArraySize(values);
         if (ArrayResize(values, t + 1))
         {
             values[t] = buf;
			}
		}
      
		for (int i = 0; i < ArraySize(values); i++) 
		{
         if(values[i] > 0)
         {
            datetime signalTm = iTime(_Symbol, _Period, i);
            Print(__FUNCTION__," ","signalTm"," ",signalTm);
            checkLastBuy.signalTime(signalTm);
				Print(__FUNCTION__," ","values[i]"," ",values[i]);
            return true;
         }          
      }

      //--- 
      return false;
   }
};
CustomConditionBUY* entryBuy;
class CustomConditionBUY2 : public iConditions
{
  datetime _signalTime;

  public:
   bool evaluate()
   {

      if (OrderSelect(OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == magico && OrderType() == OP_BUY)
      {
         if (OrderOpenTime() >= _signalTime)
         {
            return false;
         }
      }

      // Seleccionar la última del historial para este EA
      for(int i=OrdersHistoryTotal()-1;i>=0;i--)
      {
         if(OrderSelect(i,SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico && OrderType() == OP_BUY)
         {
            if (OrderOpenTime() >= _signalTime)
            {
               return false;
            }
            break;
         }
      }


      return true;
   }

   void signalTime(datetime inpsignalTime) { _signalTime = inpsignalTime; }
   datetime  signalTime(void) { return _signalTime; }
};
CustomConditionBUY2* checkLastBuy;

class CustomConditionSELL : public iConditions
{
  public:
   bool evaluate()
   {
      double buf=0;
      double values[];
      for(int i=0;i < candlesBack;i++)
		{
         buf = iCustom(Symbol(), Period(), "Vulkan Profit.ex4",inpVPbars,inpVPversion,inpVPAlerts,inpVPChanelAlerts,inpVPmail,inpVPWMA,inpVPWMAslow,inpVPFasterSidusEMA,inpVPSlowerSidusEMA, 1, i) == EMPTY_VALUE ? 0:iCustom(Symbol(), Period(), "Vulkan Profit.ex4",inpVPbars,inpVPversion,inpVPAlerts,inpVPChanelAlerts,inpVPmail,inpVPWMA,inpVPWMAslow,inpVPFasterSidusEMA,inpVPSlowerSidusEMA, 1, i);

         int t = ArraySize(values);
         if (ArrayResize(values, t + 1))
         {
             values[t] = buf;
			}
		}
      
		for (int i = 0; i < ArraySize(values); i++) 
		{
         if(values[i] > 0)
         {
            datetime signalTm = iTime(_Symbol, _Period, i);
            Print(__FUNCTION__," ","signalTm"," ",signalTm);
            checkLastSell.signalTime(signalTm);

            Print(__FUNCTION__," ","values[i]"," ",values[i]);

         return true;
         }
      }

      //--- 
      return false;
   }
};
CustomConditionSELL* entrySell;
class CustomConditionSELL2 : public iConditions
{
   datetime _signalTime;

  public:
   bool evaluate()
   {
      if (OrderSelect(OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES) && OrderMagicNumber() == magico && OrderType() == OP_SELL)
      {
         if (OrderOpenTime() >= _signalTime)
         {
            return false;
         }
      }

      // Seleccionar la última del historial para este EA
      for(int i=OrdersHistoryTotal()-1;i>=0;i--)
      {
         if(OrderSelect(i,SELECT_BY_POS, MODE_HISTORY) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico && OrderType() == OP_SELL)
         {
            if (OrderOpenTime() >= _signalTime)
            {
               return false;
            }
            break;
         }
      }


      return true;
   }

   void signalTime(datetime inpsignalTime) { _signalTime = inpsignalTime; }
   datetime  signalTime(void) { return _signalTime; }
};
CustomConditionSELL2* checkLastSell;

int OnInit()
{
   newCandle = new CNewCandle();
   conditionsToBuy.AddCondition(entryBuy = new CustomConditionBUY());
   conditionsToBuy.AddCondition(checkLastBuy = new CustomConditionBUY2());
   conditionsToSell.AddCondition(entrySell = new CustomConditionSELL());
   conditionsToSell.AddCondition(checkLastSell= new CustomConditionSELL2());
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

   //    if (!CalculateIndicators())
   //    {
   //       return;
   //    }

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
      return result;
   }

   if (direction == "sell")
   {
      return result;
   }

   return -1;
}

double SL(string direction, double entryPrice=0)
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if (userSLPips == 0) return 0;
   double SLPips = userSLPips *_Point * 10;
   
   if (direction == "buy")
   {
      if (entryPrice == 0) entryPrice = bid;
      return entryPrice - SLPips;
   }
   if (direction == "sell")
   {
      if (entryPrice == 0) entryPrice = ask;
      return entryPrice + SLPips;
   }

   return 0;
}

double TP(string direction, double entryPrice=0)
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if (userTPPips == 0) return 0;
   double TPPips = userTPPips * _Point * 10;
   
   if (direction == "buy")
   {
      if (entryPrice == 0) entryPrice = ask;
      return entryPrice + TPPips;
   }
   if (direction == "sell")
   {
      if (entryPrice == 0) entryPrice = bid;
      return entryPrice - TPPips;
   }

   return 0;
}

double Lots()
{
   return userLots;
   return 0;
}

bool CalculateIndicators()
{
   // TODO: tomar valores del In1007
   double buySignal = iCustom(_Symbol, _Period, "In1007.ex4", 20, 2.0, 2, 21, 1, 0);
   if (buySignal != 0)
   {
      Print(__FUNCTION__, " ", "buySignal", " ", buySignal);
   }

   double sellSignal = iCustom(_Symbol, _Period, "In1007.ex4", 20, 2.0, 2, 21, 2, 0);
   if (sellSignal != 0)
   {
      Print(__FUNCTION__, " ", "sellSignal", " ", sellSignal);
   }

   return true;
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
