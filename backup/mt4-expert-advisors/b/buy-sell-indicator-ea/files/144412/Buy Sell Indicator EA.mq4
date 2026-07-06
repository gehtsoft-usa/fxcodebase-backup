//+------------------------------------------------------------------+
//|                                                Expert Advisor by |
//|                                                 Carlos Valloggia |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021. Carlos Valloggia"
#property link "https://www.mql5.com/en/users/cvalloggia"
#property version "1.00"
#property strict

// NOTE: Inputs
// ------------------------------------------------------------------
input string T0= "== Trades Setup ==";                       // Trades Setup
input double priceOffsetBuy  = 10;                           // Price Offset Buy:
input double priceOffsetSell = 10;                           // Price Offset Sell:
input double userLots        = 0.10;                         // Lots:
input double userSLPips      = 0;                            // SL pips:
input double userTPPips      = 0;                            // TP pips:
input   string                bb="== BB ==";                 // --- BB ---
input   int                   bb_period=20;                  // BB Period
input   int                   bb_bands_shift=0;              // BB shift
input   double                bb_deviation=2;                // BB desviation
input   ENUM_APPLIED_PRICE    bb_applied_price=PRICE_CLOSE;  // BB Applied price
input   string                ma1="== MA ==";                // --- MA ---
input   int                   ma_period2=50;                 // MA Period
input   int                   ma_shift2=0;                   // MA shift
input   ENUM_MA_METHOD        ma_method2=MODE_EMA;           // MA Method
input   ENUM_APPLIED_PRICE    applied_price2=PRICE_CLOSE;    // MA Applied price
input string                  T4                   = "== Notifications ==";// Notifications
input   bool                  notifications=true;            // Notifications
input   bool                  desktop_notifications=true;    // Desktop MT4 Notifications
input   bool                  email_notifications=true;      // Email Notifications
input   bool                  push_notifications=true;       // Push Mobile Notifications
// ------------------------------------------------------------------

// NOTE: Global Variables & objects:
double bb_high;
double bb_low;
double bb_high_prev;
double bb_low_prev;
double ma_5;
double ma_5_prev;

// NOTE: Conditions and Actions:
// ------------------------------------------------------------------
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
   int             _id;
   string          _symbol;
   double          _price;
   double          _sl;
   double          _tp;
   double          _lot;
   ENUM_ORDER_TYPE _type;
   int             _magic;
   string          _comment;
   string          _strategy;
   datetime        _expireTime;
   datetime        _signalTime;
   double          _profit;

  public:
   Order(
       int             id,
       string          symbol,
       double          price,
       double          sl,
       double          tp,
       double          lot,
       int             type,
       int             magic,
       string          comment,
       string          strategy,
       datetime        expireTime,
       datetime        signalTime,
       double          profit) : _id(id),
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
   SendNewOrder(string side, double lots, string symbol="", double price = 0, double sl = 0, double tp = 0, int magic = 0, string coment = "", datetime expire = 0)
   {
      if(symbol=="") { symbol = _Symbol; }

      newOrder
          .id(OrderTicket())
          .symbol(symbol)
          .type(SetType(side, price, symbol))
          .price(price)
          .sl(sl)
          .tp(tp)
          .lot(lots)
          .magic(magic)
          .comment(coment)
          .expireTime(expire)
          .profit(0);
   }

   ~SendNewOrder() {}

   // ------------------------------------------------------------------
   ENUM_ORDER_TYPE SetType(string side, double &price, string symbol)
   {
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);

      if (price == 0)
      {
         if (side == "buy")
         {
            price = ask;
            return OP_BUY;
         }
         if (side == "sell")
         {
            price = bid;
            return OP_SELL;
         }
      } else {
         if (side == "buy")
         {
            if (price > ask) { return OP_BUYSTOP; }
            if (price < ask) { return OP_BUYLIMIT; }
         }
         if (side == "sell")
         {
            if (price > bid) { return OP_SELLLIMIT; }
            if (price < bid) { return OP_SELLSTOP; }
         }
      }
      
      return 0;
   }

   // ------------------------------------------------------------------
   bool doAction()
   {
      int tk = OrderSend(newOrder.symbol(), newOrder.type(), newOrder.lot(), newOrder.price(), 100, newOrder.sl(), newOrder.tp(), newOrder.comment(), newOrder.magic(), newOrder.expireTime(), clrNONE);
      
		if(tk < 0 )
		{ 
			Print(__FUNCTION__," ","Connot Send Order, error: ",GetLastError());
			return false;
		}
		
		return true;		
   }
};

ConcurrentConditions conditionsToBuy;
ConcurrentConditions conditionsToSell;
SendNewOrder*        actionSendOrder;

class CrossUp : public iConditions
{
  public:
   bool evaluate() 
	{
		if((ma_5_prev > bb_low_prev) && (ma_5<bb_low))
		{
	      return true;
		}
   return false;
	}
};
CrossUp* up;

class CrossDown : public iConditions
{
  public:
   bool evaluate() 
	{
		if((ma_5_prev < bb_high_prev) && (ma_5>bb_high))
		{
	      return true;
		}
   return false;
	}
};
CrossDown* down;

// NOTE: Init
int OnInit()
{
   newCandle = new CNewCandle();
   conditionsToBuy.AddCondition(up = new CrossUp());
   conditionsToSell.AddCondition(down = new CrossDown());
   return (INIT_SUCCEEDED);
}


void OnDeinit(const int reason) { }


void OnTick() 
{
   if(newCandle.IsNewCandle())
   {
      CalculateIndicators();

      if (conditionsToBuy.EvaluateConditions())
      {
         double price    = Price("buy");
         actionSendOrder = new SendNewOrder("buy", userLots, "", price,SL("buy",price),TP("buy",price));
         if(actionSendOrder.doAction())
         {
            Notifications(0);
         }
         delete actionSendOrder;
      }
      if (conditionsToSell.EvaluateConditions())
      {
         double price    = Price("sell");
         actionSendOrder = new SendNewOrder("sell", userLots, "", price,SL("sell",price),TP("sell",price));
         if(actionSendOrder.doAction())
         {   
            Notifications(1); 
         }
         delete actionSendOrder;
      }
   }
}

void CalculateIndicators()
{
 	bb_high      = iBands(_Symbol, _Period, bb_period, bb_deviation, bb_bands_shift, bb_applied_price, MODE_UPPER, 1);
   bb_low       = iBands(_Symbol, _Period, bb_period, bb_deviation, bb_bands_shift, bb_applied_price, MODE_LOWER, 1);
   bb_high_prev = iBands(_Symbol,_Period,bb_period,bb_deviation,bb_bands_shift,bb_applied_price,MODE_UPPER,2);
   bb_low_prev  = iBands(_Symbol,_Period,bb_period,bb_deviation,bb_bands_shift,bb_applied_price,MODE_LOWER,2);
	ma_5         = iMA(_Symbol,_Period,ma_period2,ma_shift2,ma_method2,applied_price2, 1);
   ma_5_prev    = iMA(_Symbol,_Period,ma_period2,ma_shift2,ma_method2,applied_price2, 2);
}

double Price(string direction)
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  if (direction == "buy")
  {
     double OffsetBuy  = priceOffsetBuy * _Point * 10;
     return ask + OffsetBuy;
  }
  if (direction == "sell")
  {
     double OffsetSell = priceOffsetSell * _Point *10;
     return bid + OffsetSell;
  }

  return 0;
}

double SL(string direction, double entryPrice)
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

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

double TP(string direction, double entryPrice)
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

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

void Notifications(int type)
  {

   string text="";
   if(type == 0)
      text += _Symbol+" "+GetTimeFrame(_Period)+" BUY ";
   else
      text += _Symbol+" "+GetTimeFrame(_Period)+" SELL ";
      
   text += " ";

   if(!notifications)
      return;
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification",text);
  }

string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return("M1");
      case PERIOD_M5:
         return("M5");
      case PERIOD_M15:
         return("M15");
      case PERIOD_M30:
         return("M30");
      case PERIOD_H1:
         return("H1");
      case PERIOD_H4:
         return("H4");
      case PERIOD_D1:
         return("D1");
      case PERIOD_W1:
         return("W1");
      case PERIOD_MN1:
         return("MN1");
     }
   return IntegerToString(lPeriod);
  }
