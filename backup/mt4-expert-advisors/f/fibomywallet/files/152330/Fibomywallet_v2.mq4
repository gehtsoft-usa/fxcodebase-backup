//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74107

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
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
#property strict
datetime dateEnd=D'2039.6.30 00:00';
int account_number=519516;
// int account_number = 888173789;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
extern string   ColorNote="--- Fibonacci colors ---";
extern color   UpperFiboColor=clrWhite;
extern color   MainFiboColor=clrYellow;
extern color   LowerFiboColor=clrRed;
extern string   TimeFrameNote   = "--- Timeframe for the high and low ---";
extern string   TimeFrameNot2   = "{1=M1, 5=M5, 15=M15, ..., 1440=D1, 10080=W1, 43200=MN1}";
extern int      TimeFrame=PERIOD_D1;
extern string   OpenTimeNote2="--- Open hour for daily timeframe ---";
extern int      OpenTime=0;
extern string   TimeZoneNote="{0=ServerTime, 1=GMT, 2=LocalTime}";
extern int      TimeZone=0;

input double slPoints = 300; // Sl points
input double tpPoints = 700; // Tp Points

//+------------------------------------------------------------------+
//| state variables that are used for drawing the fibs.					|
//+------------------------------------------------------------------+
double HiPrice,LoPrice,Range;
datetime StartTime,EndTime;

//+------------------------------------------------------------------+
//| global constants; get initialized in the init function				|
//+------------------------------------------------------------------+
string   TimeFrameStr;                  // Used to label High and Low
int      FirstHour,                     // First hour that is used for the range calculation in server time
LastHour;                     // Last hour that is included in the range calculation in server time
//+------------------------------------------------------------------+
#import "kernel32.dll"
int      GetTimeZoneInformation(int &TZInfoArray[]);
#import
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


string sym;
double point;
int digit;



// NOTE: Clases
interface iConditions
{
   bool evaluate();
};
class ConditionMatchPrice : public iConditions
{
   string _symbol;
   string _side;
   double _price;
   int    _mode;  // 0: Ask>=Price & Bid <=Price , 1: Ask <= Price && Bid >= Price

  public:
   ConditionMatchPrice(string Symbol, string Side, double price, int Mode)
   {
      _symbol = Symbol;
      _side   = Side;
      _price  = price;
      _mode   = Mode;
   }
   ~ConditionMatchPrice() { ; }

   void   side(string inpside) { _side = inpside; }
   string side(void) { return _side; }
   void   symbol(string inpsymbol) { _symbol = inpsymbol; }
   string symbol(void) { return _symbol; }
   void   price(double inpprice) { _price = inpprice; }
   double price(void) { return _price; }
   void   mode(int inpmode) { _mode = inpmode; }
   int    mode(void) { return _mode; }

   bool evaluate()
   {
      double ask = SymbolInfoDouble(_symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(_symbol, SYMBOL_BID);

      if (_mode == 0)
      {
         if (_side == "buy")
         {
            if (ask >= _price && bid < _price)
            {
               return true;
            }
            return false;
         }
         if (_side == "sell")
         {
            if (bid <= _price && ask > _price)
            {
               return true;
            }
            return false;
         }
      }

      if (_mode == 1)
      {
         if (_side == "buy")
         {
            if (ask <= _price)
            {
               return true;
            }
            return false;
         }
         if (_side == "sell")
         {
            if (bid >= _price)
            {
               return true;
            }
            return false;
         }
      }
      return false;
   }
};

ConditionMatchPrice* FiboPrices [10];
int FiboStates[10];


interface IOrders
{
 public:
  virtual void Add()     = 0;
  virtual void Release() = 0;

  virtual bool AddOrder()    = 0;
  virtual bool DeleteOrder() = 0;
  virtual bool Select()      = 0;
};
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
  double   _tslNext;
  bool     _bkvWasDoIt;
  int      _countPartials;

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
      double   profit,
      double   bkvWasDoIt,
      int      countPartials) : _id(id),
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
                           _profit(profit),
                           _bkvWasDoIt(bkvWasDoIt),
                           _countPartials(countPartials) {}

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
	Order* expireTime(datetime expireTm){_expireTime=expireTm; return &this;}
	Order* signalTime(datetime signalTm){_signalTime=signalTm; return &this;}
	Order* profit(double profit){_profit=profit; return &this;}
	Order* strategy(string strategy){_strategy=strategy; return &this;}
	Order* tslNext(double tslNext){_tslNext=tslNext; return &this;}
	Order* breakevenWasDoIt(bool bkvWasDoIt){_bkvWasDoIt=bkvWasDoIt; return &this;}
	Order* countPartials(int count){_countPartials=_countPartials + count; return &this;}

   int            id()               { return _id; }
   string         symbol()           { return _symbol; }
   double         price()            { return _price; }
   double         sl()               { return _sl; }
   double         tp()               { return _tp; }
   double         lot()              { return _lot; }
   int            type()             { return _type; }
   int            magic()            { return _magic; }
   string         comment()          { return _comment; }
   string         strategy()         { return _strategy; }
   datetime       expireTime()       { return _expireTime; }
   datetime       signalTime()       { return _signalTime; }
   double         profit()           { if (OrderSelect(_id, SELECT_BY_TICKET)) return OrderProfit()+OrderCommission()+OrderSwap(); return -1; }
   double         tslNext()          { return _tslNext; }
   double         breakevenWasDoIt() { return _bkvWasDoIt; }
   int            countPartials()    { return _countPartials; }
};

interface iActions
{
  bool doAction();
};
class SendNewOrder : public iActions
{
 private:
  Order* newOrder;

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

    newOrder = new Order();

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

  ~SendNewOrder()
  {
    delete newOrder;
  }

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

  Order* lastOrder()
  {
    return GetPointer(newOrder);
  }
};
SendNewOrder* actionSendOrder;




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   sym=Symbol();
   point = Point;
   digit = MarketInfo(sym, MODE_DIGITS);
   fIsOnInit();
   switch(TimeFrame)
     {
      case 1:      TimeFrameStr="Minute";      break;
      case 5:      TimeFrameStr="5 Minute";   break;
      case 15:      TimeFrameStr="15 Minute";   break;
      case 30:      TimeFrameStr="30 Minute";   break;
      case 60:      TimeFrameStr="Hourly";      break;
      case 240:   TimeFrameStr="4 Hourly";   break;
      case 1440:   TimeFrameStr="Daily";      break;
      case 10080:   TimeFrameStr="Weekly";      break;
      case 43200:   TimeFrameStr="Monthly";      break;
      default:      TimeFrameStr="Unknown Timeframe";
     }
   int timeShift=0;
   int ServerLocalOffset=RoundClosest(TimeCurrent()-TimeLocal(),3600)/60;

   if(TimeZone==2)
      timeShift=ServerLocalOffset/60;                  // local time -> server time

   if(TimeZone==1)
     {
      if(IsDllsAllowed())
        {
         int GmtLocalOffset,
         ServerGmtOffset,
         TZInfoArray[43],
         result=GetTimeZoneInformation(TZInfoArray);
         if(result!=0) GmtLocalOffset=TZInfoArray[0];      //	Difference between your local time and GMT in minutes (winter time)
         if(result==2) GmtLocalOffset+=TZInfoArray[42];   //	Current difference between your local time and GMT in minutes
         ServerGmtOffset=ServerLocalOffset-GmtLocalOffset;
         timeShift=ServerGmtOffset/60;                  // GMT -> server time
        }
      else Alert("For GMT to work, DLLs must be enabled.");
     }

//----
   FirstHour=OpenTime%24;
   if(FirstHour>0) LastHour=FirstHour-1;
   else               LastHour=23;
   LastHour += 24+timeShift;   LastHour %=24;
   FirstHour+= 24+timeShift;   FirstHour%=24;
   Print("FirstHour (server time) = "+FirstHour);
   Print("LastHour (server time) = "+LastHour);



   //--- 
   // NOTE: Set Array Fibos ini
   for(int i=0;i < 5;i++)
   {
       FiboPrices[i] = new ConditionMatchPrice(_Symbol, "buy", 0, 0);
   }
   for(int i=5;i < 10;i++)
   {
       FiboPrices[i] = new ConditionMatchPrice(_Symbol, "sell", 0, 0);       
   }
   ResetFiboStates();



   //---

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("^_^");
   if(ObjectFind("BG")>=0) ObjectDelete("BG");
   if(ObjectFind("BG1") >= 0) ObjectDelete("BG1");
   if(ObjectFind("BG2") >= 0) ObjectDelete("BG2");
   if(ObjectFind("BG3") >= 0) ObjectDelete("BG3");
   if(ObjectFind("BG4") >= 0) ObjectDelete("BG4");
   if(ObjectFind("BG5") >= 0) ObjectDelete("BG5");
   if(ObjectFind("NAME")>= 0) ObjectDelete("NAME");
   ObjectDelete("FiboUp");
   ObjectDelete("FiboDn");
   ObjectDelete("FiboIn");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   if(TimeFrame!=PERIOD_D1 || (OpenTime==0 && TimeZone==0))
      //	Use daily, weekly, whatever candles
     {
      int shift=iBarShift(NULL,TimeFrame,Time[0])+1;   // yesterday
      HiPrice      = iHigh(NULL,TimeFrame,shift);
      LoPrice      = iLow (NULL,TimeFrame,shift);
      StartTime=iTime(NULL,TimeFrame,shift);
      EndTime=StartTime+TimeFrame*60;

      if(TimeFrame==PERIOD_D1 && TimeDayOfWeek(StartTime)==0/*Sunday*/)
        {//Add fridays high and low
         HiPrice = MathMax(HiPrice,iHigh(NULL,PERIOD_D1,shift+1));
         LoPrice = MathMin(LoPrice,iLow(NULL,PERIOD_D1,shift+1));
         StartTime=iTime(NULL,PERIOD_D1,shift+1);
        }
     }
   else
//	Use hourly candles
     {
      //----
      //	find last candle of the period
      int shift=1;
      while(TimeHour(iTime(NULL,PERIOD_H4,shift))!=LastHour)
         shift++;
      //----
      //	find first candle of the period
      int startShift=shift;
      while(TimeHour(iTime(NULL,PERIOD_H4,startShift))!=FirstHour
            || TimeDayOfWeek(iTime(NULL,PERIOD_H4,startShift))==0/*Sunday*/)
         startShift++;
      while(TimeHour(iTime(NULL,PERIOD_H4,startShift))==FirstHour)
         startShift++;
      startShift--;

      //----
      //	get the highest high and lowest low of the period
      HiPrice      = iHigh(NULL,PERIOD_H4,iHighest(NULL,PERIOD_H4,MODE_HIGH,startShift-shift+1,shift));
      LoPrice      = iLow (NULL,PERIOD_H4,iLowest (NULL,PERIOD_H4,MODE_LOW, startShift-shift+1,shift));
      StartTime=iTime(NULL,PERIOD_H4,startShift);
      EndTime=iTime(NULL,PERIOD_H4,shift);
     }

   Range=HiPrice-LoPrice;
   DrawFibo();

   if(OrdersTotal() == 0) ResetFiboStates();

   if(AccountNumber() == account_number)
     {
      if(TimeCurrent()>dateEnd)
        {
         Alert("This is version demo. Plz contact skype : joel_alves");
        }
      else
        {
          //  fIsGetSTR_AlertSignal();

    // NOTE: Chequear los niveles de fibo y generar compra o venta
          if(CrossingBuyLevels())
          {
              string side = "buy";
              actionSendOrder = new SendNewOrder(side, Lots(), "", 0, SL(side), TP(side));
              actionSendOrder.doAction();
              delete actionSendOrder;
          }
          if(CrossingSellLevels())
          {
              string side = "sell";
              actionSendOrder = new SendNewOrder(side, Lots(), "", 0, SL(side), TP(side));
              actionSendOrder.doAction();
              delete actionSendOrder;
          }
          f0_13();
        }
     }
   else 
     {
      Alert("Account is invalid. Plz contact skype : joel_alves");
     }
}
// ------------------------------------------------------------------
// NOTE: CrossingFiboLevels
bool CrossingBuyLevels()
{

    FiboPrices[0].price(LoPrice); // Buy: Daily low
    FiboPrices[1].price(va236a);  // Buy: -23.6
    FiboPrices[2].price(va382a);  // Buy: -38.2
    FiboPrices[3].price(va618a);  // Buy: -61.8
    FiboPrices[4].price(va100a);  // Buy: -100


    for(int i=0;i < 5;i++)
    {
        if(FiboPrices[i].evaluate()==true && FiboStates[i]==0)
        {
            Print("Crossing Fibo: ", FiboPrices[i].price());
            FiboStates[i] = 1;
            return true;
        }
    }
    return false;
}
bool CrossingSellLevels()
{

    FiboPrices[5].price(HiPrice); // Sell: Daily High
    FiboPrices[6].price(va1236);  // Sell: 123.6
    FiboPrices[7].price(va1382);  // Sell: 138.2
    FiboPrices[8].price(va1618);  // Sell: 161.8
    FiboPrices[9].price(va200);   // Sell: 200


    for(int i=5;i < 10;i++)
    {
        if(FiboPrices[i].evaluate()==true && FiboStates[i]==0)
        {
            Print("Crossing Fibo: ", FiboPrices[i].price());
            FiboStates[i] = 1;
            return true;
        }
    }
    return false;
}

void ResetFiboStates()
{
    for(int i=0;i < 10;i++)
    FiboStates[i] = 0;
}



// NOTE: tp
double TP(string side)
{
    if(side == "buy")
    {
        return Ask + slPoints * _Point;

    }
    if(side == "sell")
    {
        return Bid - slPoints * _Point;

    }
    return 0;
}
double SL(string side)
{
    if(side == "buy")
    {
        return Ask - slPoints * _Point;

    }
    if(side == "sell")
    {
        return Bid + slPoints * _Point;

    }
    return 0;
}
double Lots()
{
    return NormalizeDouble(AccountBalance() / 25000, 2);
}

//+------------------------------------------------------------------+
int RoundClosest(int n,int step)
  {
   if(n>0) n+=step/2;
   else         n-=step/2;
   return(n - n%step);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double va764=0;
double va618=0;
double va50=0;
double va382=0;
double va236=0;




double va1236 = 0;
double va1382 = 0;
double va150=0;
double va1618 = 0;
double va1764 = 0;
double va200=0;

double va100a=0;
double va764a=0;
double va618a=0;
double va50a=0;
double va382a=0;
double va236a=0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ab="";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
extern string hdSup= "------ Setting STR_AlertSignal ----- ";
extern int ExtDepth=31;
extern int ExtDeviation= 3;
extern int ExtBackstep = 31;
extern bool AlertOn=false;
extern bool Email_Alert=false;

string hd="------ Setting Order -----";
int stoploss=0;
int takeprofit=300;
double volume=0.2;
extern string hdvlS="------ Setting Volume -----";
extern double volume_0 = 0.04;//Lot size at -100
//extern double volume_1 = 0;//Lot size at -76.4
extern double volume_2 = 0.03;//Lot size at -61.8
//extern double volume_3 = 0;//Lot size at -50.0
extern double volume_4 = 0.02;//Lot size at -38.2
extern double volume_5 = 0.01;//Lot size at -23.6
//extern double volume_6 =  0;//Lot size at 0
//extern double volume_7 = 00;//Lot size at 23.6
//extern double volume_8 = 0;//Lot size at 38.2
//extern double volume_9 = 0;//Lot size at  50.
//extern double volume_10 = 0;//Lot size at 61.8
//extern double volume_11 = 0;//Lot size at 76.4
//extern double volume_12 = 0;//Lot size at 100
extern double volume_13 = 0.01;//Lot size at 123.6
extern double volume_14 = 0.02;//Lot size at 138.2
//extern double volume_15 = 0.0;//Lot size at 150.0
extern double volume_16 = 0.03;//Lot size at 161.8
//extern double volume_17 = 0;//Lot size at 176.7
extern double volume_18 = 0.04;//Lot size at 200
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DrawFibo()
  {
//----
   if(ObjectFind("FiboUp")==-1)
      ObjectCreate("FiboUp",OBJ_FIBO,0,StartTime,HiPrice+Range,StartTime,HiPrice);
   else
     {
      ObjectSet("FiboUp",OBJPROP_TIME2,StartTime);
      ObjectSet("FiboUp",OBJPROP_TIME1,StartTime);
      ObjectSet("FiboUp",OBJPROP_PRICE1,HiPrice+Range);
      ObjectSet("FiboUp",OBJPROP_PRICE2,HiPrice);
     }
   ObjectSet("FiboUp",OBJPROP_LEVELCOLOR,UpperFiboColor);
   ObjectSet("FiboUp",OBJPROP_FIBOLEVELS,7);
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+0,0.0);   ObjectSetFiboDescription("FiboUp",0,TimeFrameStr+" HIGH (100.0%) -  %$");
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+1,0.236);   ObjectSetFiboDescription("FiboUp",1,"(123.6%) -  %$");
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+2,0.382);   ObjectSetFiboDescription("FiboUp",2,"(138.2%) -  %$");
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+3,0.500);   ObjectSetFiboDescription("FiboUp",3,"(150.0%) -  %$");
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+4,0.618);   ObjectSetFiboDescription("FiboUp",4,"(161.8%) -  %$");
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+5,0.764);   ObjectSetFiboDescription("FiboUp",5,"(176.4%) -  %$");
   ObjectSet("FiboUp",OBJPROP_FIRSTLEVEL+6,1.000);   ObjectSetFiboDescription("FiboUp",6,"(200.0%) -  %$");
   ObjectSet("FiboUp",OBJPROP_RAY,true);
   ObjectSet("FiboUp",OBJPROP_BACK,true);

   string va1=ObjectGetFiboDescription("FiboUp",6);
   double price=ObjectGetValueByShift(va1,1);

   va764 = NormalizeDouble(((HiPrice - LoPrice) * 0.764 + LoPrice), digit);
   va618 = NormalizeDouble(((HiPrice - LoPrice) * 0.618 + LoPrice), digit);
   va50  =  NormalizeDouble(((HiPrice - LoPrice) * 0.5 + LoPrice), digit);
   va382 = NormalizeDouble(((HiPrice - LoPrice) * 0.382 + LoPrice), digit);
   va236 = NormalizeDouble(((HiPrice - LoPrice) * 0.236 + LoPrice), digit);

   va100a=NormalizeDouble((LoPrice -(HiPrice-LoPrice)*1.0),digit);;
   va764a = NormalizeDouble((LoPrice -(HiPrice - LoPrice) * 0.764 ), digit);
   va618a = NormalizeDouble((LoPrice -(HiPrice - LoPrice) * 0.618), digit);
   va50a  =  NormalizeDouble(LoPrice -((HiPrice - LoPrice) * 0.5 ), digit);
   va382a = NormalizeDouble((LoPrice -(HiPrice - LoPrice) * 0.382), digit);
   va236a = NormalizeDouble((LoPrice -(HiPrice - LoPrice) * 0.236), digit);


   va1236 = NormalizeDouble(((HiPrice - LoPrice) * 1.236 + LoPrice), digit);
   va1382 = NormalizeDouble(((HiPrice - LoPrice) * 1.382 + LoPrice), digit);
   va150=NormalizeDouble(((HiPrice-LoPrice)*1.5+LoPrice),digit);
   va1618 =  NormalizeDouble(((HiPrice - LoPrice) * 1.618 + LoPrice), digit);
   va1764 = NormalizeDouble(((HiPrice - LoPrice) * 1.764 + LoPrice), digit);
   va200=NormalizeDouble(((HiPrice-LoPrice)*2.00+LoPrice),digit);

   arrValue[0]=va100a;
   arrValue[1] =  va764a;
   arrValue[2] =  va618a;
   arrValue[3] = va50a;
   arrValue[4] = va382a;
   arrValue[5] = va236a;

   arrValue[6]=LoPrice; //0
   arrValue[7] = va236;
   arrValue[8] = va382;
   arrValue[9] = va50;
   arrValue[10]= va618;
   arrValue[11]= va764;

   arrValue[12]=HiPrice; // 100

   arrValue[13] = va1236;
   arrValue[14] = va1382;
   arrValue[15] = va150;
   arrValue[16] = va1618;
   arrValue[17] = va1764;

   arrValue[18]=va200;

   ab="";
   ab="FiboUp\n"+



      "\n--- Fibo High ---"+
      "\nLevel 200: "+va200+" ||  OpenS: "+arrStatus[18]+" || OpenB: "+arrStatusB[18]+
      "\nLevel 1764: "+va1764+" || OpenS: "+arrStatus[17]+" || OpenB: "+arrStatusB[17]+
      "\nLevel 1618: "+va1618+" || OpenS: "+arrStatus[16]+" || OpenB: "+arrStatusB[16]+
      "\nLevel 150: "+va150+" || OpenS: "+arrStatus[15]+" || OpenB: "+arrStatusB[15]+
      "\nLevel 1382: "+va1382+" || OpenS: "+arrStatus[14]+" || OpenB: "+arrStatusB[14]+
      "\nLevel 1236: "+va1236+" || OpenS: "+arrStatus[13]+" || OpenB: "+arrStatusB[13]+
      "\nLevel 100: "+arrValue[12]+" || OpenS: "+arrStatus[12]+" || OpenB: "+arrStatusB[12]+
      "\n----------"+
      "\nLevel 764: "+va764+" || OpenS: "+arrStatus[11]+" || OpenB: "+arrStatusB[11]+
      "\nLevel 618: "+va618+" || OpenS: "+arrStatus[10]+" || OpenB: "+arrStatusB[10]+
      "\nLevel 508: "+va50+" || OpenS: "+arrStatus[9]+" || OpenB: "+arrStatusB[9]+
      "\nLevel 382: "+va382+" || OpenS: "+arrStatus[8]+" || OpenB: "+arrStatusB[8]+
      "\nLevel 236: "+va236+" || OpenS: "+arrStatus[7]+" || OpenB: "+arrStatusB[7]+
      "\nLevel 0: "+arrValue[6]+" || OpenS: "+arrStatus[6]+" || OpenB: "+arrStatusB[6]+
      "\n---  Fibo Low ----"+

      "\nLevel -236: "+va236a+" || OpenS: "+arrStatus[5]+" || OpenB: "+arrStatusB[5]+
      "\nLevel -382: "+va382a+" || OpenS: "+arrStatus[4]+" || OpenB: "+arrStatusB[4]+
      "\nLevel -508: "+va50a+" || OpenS: "+arrStatus[3]+" || OpenB: "+arrStatusB[3]+
      "\nLevel -618: "+va618a+" || OpenS: "+arrStatus[2]+" || OpenB: "+arrStatusB[2]+
      "\nLevel -764: "+va764a+" || OpenS: "+arrStatus[1]+" || OpenB: "+arrStatusB[1]+
      "\nLevel -100: "+va100a+" || OpenS: "+arrStatus[0]+" || OpenB: "+arrStatusB[0]
      ;
//Comment(ab);
//----
   if(ObjectFind("FiboDn")==-1)
      ObjectCreate("FiboDn",OBJ_FIBO,0,StartTime,LoPrice-Range,StartTime,LoPrice);
   else
     {
      ObjectSet("FiboDn",OBJPROP_TIME2,StartTime);
      ObjectSet("FiboDn",OBJPROP_TIME1,StartTime);
      ObjectSet("FiboDn",OBJPROP_PRICE1,LoPrice-Range);
      ObjectSet("FiboDn",OBJPROP_PRICE2,LoPrice);
     }
   ObjectSet("FiboDn",OBJPROP_LEVELCOLOR,LowerFiboColor);
   ObjectSet("FiboDn",OBJPROP_FIBOLEVELS,7);
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+0,0.0);   ObjectSetFiboDescription("FiboDn",0,TimeFrameStr+" LOW (0.0%) -  %$");
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+1,0.236);   ObjectSetFiboDescription("FiboDn",1,"(-23.6%) -  %$");
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+2,0.382);   ObjectSetFiboDescription("FiboDn",2,"(-38.2%) -  %$");
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+3,0.500);   ObjectSetFiboDescription("FiboDn",3,"(-50.0%) -  %$");
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+4,0.618);   ObjectSetFiboDescription("FiboDn",4,"(-61.8%) -  %$");
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+5,0.764);   ObjectSetFiboDescription("FiboDn",5,"(-76.4%) -  %$");
   ObjectSet("FiboDn",OBJPROP_FIRSTLEVEL+6,1.000);   ObjectSetFiboDescription("FiboDn",6,"(-100.0%) -  %$");
   ObjectSet("FiboDn",OBJPROP_RAY,true);
   ObjectSet("FiboDn",OBJPROP_BACK,true);

//----
   if(ObjectFind("FiboIn")==-1)
      ObjectCreate("FiboIn",OBJ_FIBO,0,StartTime,HiPrice,EndTime,LoPrice);
   else
     {
      ObjectSet("FiboIn",OBJPROP_TIME1,StartTime);
      ObjectSet("FiboIn",OBJPROP_TIME2,StartTime+TimeFrame*60);
      ObjectSet("FiboIn",OBJPROP_PRICE1,HiPrice);
      ObjectSet("FiboIn",OBJPROP_PRICE2,LoPrice);
     }
   ObjectSet("FiboIn",OBJPROP_LEVELCOLOR,MainFiboColor);
   ObjectSet("FiboIn",OBJPROP_FIBOLEVELS,5);
   ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+0,0.236);   ObjectSetFiboDescription("FiboIn",0,"(23.6"+"\x25"+") -  %$");
   ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+1,0.382);   ObjectSetFiboDescription("FiboIn",1,"(38.2) -  %$");
   ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+2,0.500);   ObjectSetFiboDescription("FiboIn",2,"(50.0) -  %$");
   ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+3,0.618);   ObjectSetFiboDescription("FiboIn",3,"(61.8) -  %$");
   ObjectSet("FiboIn",OBJPROP_FIRSTLEVEL+4,0.764);   ObjectSetFiboDescription("FiboIn",4,"(76.4) -  %$");
   ObjectSet("FiboIn",OBJPROP_RAY,true);
   ObjectSet("FiboIn",OBJPROP_BACK,true);
   return(0);
  }

//+------------------------------------------------------------------+
//| Indicator start function
//+------------------------------------------------------------------+

int shift=0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int bar=0;
int bar1=0;
int bar2=0;
int bar3=0;
int barDaily=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int count_1 = 0;
int count_2 = 0;
int count_3 = 0;
int count_4 = 0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double arrValue[19];
bool arrStatus[19];
bool arrStatusB[19];
double arrVolume[19];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fIsOnInit()
  {
   int arrSize=ArraySize(arrStatus);
   for(int i=0;i<arrSize;i++)
     {
      arrStatus[i]=0;
      arrStatusB[i]=0;
     }
   arrVolume[0] = volume_0;
//   arrVolume[1] = volume_1;
   arrVolume[2] = volume_2;
//   arrVolume[3] = volume_3;
   arrVolume[4] = volume_4;
   arrVolume[5] = volume_5;
//   arrVolume[6] = volume_6;
//   arrVolume[7] = volume_7;
//   arrVolume[8] = volume_8;
//   arrVolume[9] = volume_9;
//   arrVolume[10] = volume_10;
//   arrVolume[11] = volume_11;
//   arrVolume[12] = volume_12;
   arrVolume[13] = volume_13;
   arrVolume[14] = volume_14;
//   arrVolume[15] = volume_15;
   arrVolume[16] = volume_16;
//   arrVolume[17] = volume_17;
   arrVolume[18] = volume_18;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void fIsGetSTR_AlertSignal()
  {
   string name="STR_AlertSignal(On-Off)";

   double diCusDn_0 = iCustom(sym, 0,name, ExtDepth, ExtDeviation, ExtBackstep, AlertOn, Email_Alert, 0 , shift);//Up
   double diCusDn_1 = iCustom(sym, 0,name, ExtDepth, ExtDeviation, ExtBackstep, AlertOn, Email_Alert, 1 , shift);//Dn

   double diCusDn_0_1 = iCustom(sym, 0,name, ExtDepth, ExtDeviation, ExtBackstep, AlertOn, Email_Alert, 0 , 1);//Up
   double diCusDn_1_1 = iCustom(sym, 0,name, ExtDepth, ExtDeviation, ExtBackstep, AlertOn, Email_Alert, 1 , 1);//Dn

/*double va764=0;
double va618=0;
double va1236 = 0;
double va1382 = 0;*/

   double ask=MarketInfo(sym,MODE_ASK);
   double bid=MarketInfo(sym,MODE_BID);
   double diClose=iClose(sym,0,2);

   string a="\n0: "+diCusDn_0+
            "\n1: "+diCusDn_1+
            "\nAsk: "+ask+
            "\nBid: "+bid+
            "\nClose: "+diClose;
// Comment(a);
   fIsCheck();

   int arrSize=ArraySize(arrValue);

   for(int i=0;i<arrSize;i++)
     {
      double bid = MarketInfo(sym, MODE_BID);
      double ask = MarketInfo(sym, MODE_ASK);
      double diClose2 = iClose(sym, 0 , 1);
      if(arrStatusB[i]==false && arrValue[i]!=0)
        {
         //Print("BUY 1: "+arrValue[i]+" ==> "+i+" ==> "+diCusDn_0);
         if(i>0)
           {
            if((diCusDn_0<=arrValue[i] && diCusDn_0>=arrValue[i-1] && diCusDn_0!=0 && diCusDn_0!=EMPTY_VALUE)
               || (diCusDn_0_1<=arrValue[i] && diCusDn_0_1>=arrValue[i-1] && diCusDn_0_1!=0 && diCusDn_0_1!=EMPTY_VALUE))
              {
               double ask=MarketInfo(sym,MODE_ASK);
               double sl = ask - stoploss * point;
               double tp = ask + takeprofit * point;
               if(stoploss==0){ sl=0;}
               if(takeprofit==0){ tp=0;}
               OrderSend(sym,0,arrVolume[i],ask,30,sl,tp,NULL,magic,0,clrBlue);

               flagClSell=true;
               arrStatusB[i]=true;
              }
           }
         else
           {
            if((diCusDn_0<=arrValue[i] && diCusDn_0!=0 && diCusDn_0!=EMPTY_VALUE)
               || (diCusDn_0_1<=arrValue[i] && diCusDn_0_1!=0 && diCusDn_0_1!=EMPTY_VALUE))
              {
               Print("Vao lenh o day nao : "+i+" => "+arrValue[i]);
               double ask=MarketInfo(sym,MODE_ASK);
               double sl = ask - stoploss * point;
               double tp = ask + takeprofit * point;
               if(stoploss==0){ sl=0;}
               if(takeprofit==0){ tp=0;}
               OrderSend(sym,0,arrVolume[i],ask,30,sl,tp,NULL,magic,0,clrBlue);

               flagClSell=true;
               arrStatusB[i]=true;
              }
           }
        }
     }

   for(int i=arrSize-1;i>=0;i--)
     {
      double bid = MarketInfo(sym, MODE_BID);
      double ask = MarketInfo(sym, MODE_ASK);
      double diClose2 = iClose(sym, 0 , 1);
      if(arrStatus[i] == false)
        {
         //Print("1");
         if(i==(arrSize-1))
           {
            if((diCusDn_1>=arrValue[i] && diCusDn_1!=0 && diCusDn_1!=EMPTY_VALUE)
               || (diCusDn_1_1>=arrValue[i] && diCusDn_1_1!=0 && diCusDn_1_1!=EMPTY_VALUE))
              {
               Print("Vao lenh o day nao : "+i+" => "+arrValue[i]);
               double bid=MarketInfo(sym,MODE_BID);
               double sl = bid + stoploss * point;
               double tp = bid - takeprofit * point;
               if(stoploss==0){ sl=0;}
               if(takeprofit==0){ tp=0;}
               OrderSend(sym,1,arrVolume[i],bid,30,sl,tp,NULL,magic,0,clrRed);

               arrStatus[i]=true;
               flagClBuy=true;
              }
           }
         else
           {
            if((diCusDn_1>=arrValue[i] && diCusDn_1<=arrValue[i+1] && diCusDn_1!=0 && diCusDn_1!=EMPTY_VALUE)
               || (diCusDn_1_1>=arrValue[i] && diCusDn_1_1<=arrValue[i+1] && diCusDn_1_1!=0 && diCusDn_1_1!=EMPTY_VALUE))
              {
               double bid=MarketInfo(sym,MODE_BID);
               double sl = bid + stoploss * point;
               double tp = bid - takeprofit * point;
               if(stoploss==0){ sl=0;}
               if(takeprofit==0){ tp=0;}
               OrderSend(sym,1,arrVolume[i],bid,30,sl,tp,NULL,magic,0,clrRed);

               arrStatus[i]=true;
               flagClBuy=true;
              }
           }
        }
     }

   if(flagCloseOpposite)
     {
      fIsCloseOpposite();
     }

//Comment(ab+a+"\nflagS: "+flagClSell+"\nflagB: "+flagClBuy);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fIsCloseOpposite()
  {
   fIsCheck();
   if(b_count>0)
     {
      if(flagClBuy)
        {
         fIsCloseBuy();
         fIsCheck();
         if(b_count==0)
           {
            flagClBuy=false;

            int arrSize=ArraySize(arrStatusB);
            for(int i=0;i<arrSize;i++)
              {
               Print("Reset status BUY");
               arrStatusB[i]=0;
              }
           }
        }
     }
   else
     {
      flagClBuy=false;
     }

   if(s_count>0)
     {
      if(flagClSell)
        {
         fIsCloseSell();
         fIsCheck();
         if(s_count==0)
           {
            flagClSell=false;
            int arrSize=ArraySize(arrStatus);
            for(int i=0;i<arrSize;i++)
              {
               Print("Reset status SELL");
               arrStatus[i]=0;
              }
           }
        }
     }
   else
     {
      flagClSell=false;
     }

  }
//+------------------------------------------------------------------+
void fIsBuy(double volume_use_)
  {
   double ask=MarketInfo(sym,MODE_ASK);
   double sl = ask - stoploss * point;
   double tp = ask + takeprofit * point;
   if(stoploss==0){ sl=0;}
   if(takeprofit==0){ tp=0;}
   OrderSend(sym,0,volume_use_,ask,30,sl,tp,NULL,magic,0,clrBlue);
// bar=Bars;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fIsSell(double volume_use_)
  {
   double bid=MarketInfo(sym,MODE_BID);
   double sl = bid + stoploss * point;
   double tp = bid - takeprofit * point;
   if(stoploss==0){ sl=0;}
   if(takeprofit==0){ tp=0;}
   OrderSend(sym,1,volume_use_,bid,30,sl,tp,NULL,magic,0,clrRed);
//bar=Bars;

  }
//+------------------------------------------------------------------+

extern string hdCO="------ Use close opposite -----";
extern string hdCO1="------ Open Sell/Close Buy. Reverse -----";
extern bool flagCloseOpposite=true;//Use close opposite
//+------------------------------------------------------------------+
int b_count = 0;
int s_count = 0;
int pending_count=0;
int total_order=0;
double profit_now=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool flagClBuy=false;
bool flagClSell=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fIsCheck()
  {
   b_count=0;
   s_count=0;
   pending_count=0;
   total_order=0;
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         if(OrderSymbol()==sym && OrderMagicNumber()==magic)
           {
            if(OrderType()==0)
              {
               b_count++;
              }
            else if(OrderType()==1)
              {
               s_count++;
              }
            else if(OrderType()>1)
              {
               pending_count++;
              }
           }
        }
     }
   total_order=b_count+s_count+pending_count;
  }
//+------------------------------------------------------------------+

void fIsCloseSell()
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         double ask=MarketInfo(sym,MODE_ASK);
         if(OrderSymbol()==sym && OrderMagicNumber()==magic && OrderType()==1)
           {
            OrderClose(OrderTicket(),OrderLots(),ask,30,clrWhite);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void fIsCloseBuy()
  {
   for(int i=0; i<OrdersTotal(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS))
        {
         double bid=MarketInfo(sym,MODE_BID);
         if(OrderSymbol()==sym && OrderMagicNumber()==magic && OrderType()==0)
           {
            OrderClose(OrderTicket(),OrderLots(),bid,30,clrWhite);
           }
        }
     }
  }
//+------------------------------------------------------------------+
extern string ______________ = "---- Display EA ----";
extern bool ShowTradeComment = TRUE;
extern int magic=2024536;//Magic Number
int MaxOpenOrders=15;
extern double SafeEquityRisk=0.5;
extern bool FreezeAfterTP=FALSE;
string _______________="---- Setting Time ----";
int StartHour=0;
int StartMinute=0;
int StopHour=0;
int StopMinute=0;
int StartingTradeDay=0;
int EndingTradeDay=7;

string modver="M6 (TLP public)";
double PipToTP,MaxDD=0;
int gStartMinutes,gStopMinutes;
string gs_live_380= "REAL";
string gs_off_372 = "OFF";
double gd_304;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double balanceDeviation() 
  {
   double bd;
   bd=(AccountEquity()/AccountBalance()-1.0)/(-0.01);
   if(bd <= 0.0) return (0);
   return (bd);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradeTime() 
  {
   if(FreezeAfterTP) return(false);
   bool AllowTrade=true;
   gStartMinutes= 60 * StartHour+StartMinute;
   gStopMinutes = 60 * StopHour+StopMinute;
   int day=DayOfWeek();
   if(day<StartingTradeDay || day>EndingTradeDay) AllowTrade=false;
   int minuntes=60*TimeHour(TimeCurrent())+TimeMinute(TimeCurrent());
   if(day <= StartingTradeDay && gStartMinutes >= minuntes) AllowTrade = false;
   if(day >= EndingTradeDay && gStopMinutes < minuntes) AllowTrade = false;
   return(AllowTrade);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f0_3() 
  {
   string ls_1 = "", ls_2 = "", ls_3 = "";
   string ls_0 = DoubleToStr(balanceDeviation(), 2);
   if(balanceDeviation()>MaxDD) MaxDD=balanceDeviation();
   ls_3="Margin Usage:                            "+DoubleToStr(100 -(AccountFreeMargin()/AccountBalance()*100),2)+"%\n";
   if(!IsTradeTime()) ls_1= "New Trades disallowed by scheduler";
   if(FreezeAfterTP) ls_1 = "Freeze AfterTP Enabled";
   Comment(""
           +"\n"
           +"\n"
           +"\n"
           +"EXPERT VERSION: 1.0 "+modver
           +"\n"
           +"======================================="
           //+ "\n" 
           //+ "-----------------------------------------------------------------------------------" 
           //+ "\n" 
           //+ "AUTHENTICATION STATUS" 
           //+ "\n" 
           //+ "-----------------------------------------------------------------------------------" 
           //+ "\n" 
           //+ "STATUS MESSAGE:   " + gs_396 
           //+ "\n" 
           //+ "-----------------------------------------------------------------------------------" 
           +"\n"
           +"INFORMACAO CONTA"
           +"\n"
           +"-----------------------------------------------------------------------------------"
           +"\n"
           //+ "Account Name:                " + AccountName() 
           //+ "\n" 
           +"Account Number:             "+AccountNumber()+" ("+gs_live_380+")"
           +"\n"
           //+ "Account Type:                 " + gs_live_380 
           //+ "\n" 
           +"Account Leverage:           1:"+DoubleToStr(AccountLeverage(),0)
           +"\n"
           +"Account Balance:             "+DoubleToStr(AccountBalance(),2)
           +"\n"
           +"Account Equity:               "+DoubleToStr(AccountEquity(),2)
           +"\n"
           +"Server Time:                   "+TimeToStr(TimeCurrent(),TIME_SECONDS)
           +"\n"
           +"-----------------------------------------------------------------------------------"
           +"\n"
           +"TRADE INFORMATIONS "
           +"\n"
           +"------------------------------------------------------------------------------------"
           +"\n"
           +"SAFE EQUITY STOP OUT :        "+gs_off_372+"  @ "+DoubleToStr(SafeEquityRisk*100,2)+"%"
           +"\n"
           //+ "SAFE EQUITY RISK % :             " + DoubleToStr(SafeEquityRisk, 2) 
           //+ "\n" 
           +ls_2
           +"NEXT LOT(S) :                            "+DoubleToStr(gd_304,2)
           +"\n"
           +"OPEN TRADES :                         "+DoubleToStr(f0_8(),0)+" / "+MaxOpenOrders
           +"\n"
           +"FLOATING P/L :                          "+DoubleToStr(AccountProfit(),2)
           +"\n"
           //      + "CURRENT PROFIT:                     " + DoubleToStr(CurProfit, 2) 
           //      + "\n" 
           //      + "POTENTIAL PROFIT:                  " + DoubleToStr(PotProfit, 2) 
           //      + "\n"
           +"Pips To TP:                                  "+DoubleToStr(PipToTP,1)
           +"\n"
           +"=======================================\n"
           +"Drawdown :                               "+ls_0+"%"
           +"\n"
           +"Drawdown (Max) :                      "+DoubleToStr(MaxDD,2)+"%"
           +"\n"
           +ls_3
           +"Total Profit/Loss :                        "+DoubleToStr(calculatePLBalance(),2)+"\n"
           +ls_1
           );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int f0_8() 
  {
   int li_0 = OrdersTotal();
   int li_8 = 0;
   for(int li_4=0; li_4<li_0; li_4++) 
     {
      OrderSelect(li_4,SELECT_BY_POS,MODE_TRADES);
      if(OrderType()==OP_SELL || OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==magic) li_8++;
     }
   return (li_8);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculatePLBalance() 
  {
   double gd_TotalPL=0;
   int li_0=OrdersHistoryTotal();
   for(int li_4=0; li_4<li_0; li_4++) 
     {
      OrderSelect(li_4,SELECT_BY_POS,MODE_HISTORY);
      if(OrderMagicNumber()==magic) gd_TotalPL+=OrderProfit()+OrderSwap()+OrderCommission();
     }
   return(gd_TotalPL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void f0_13() 
  {
   if(ShowTradeComment) 
     {
      if(IsTesting() && !IsVisualMode()) return;
      if(ObjectFind("BG")<0) 
        {
         ObjectCreate("BG",OBJ_LABEL,0,0,0);
         ObjectSetText("BG","g",210,"Webdings",Orange);
         ObjectSet("BG",OBJPROP_CORNER,0);
         ObjectSet("BG",OBJPROP_BACK,TRUE);
         ObjectSet("BG",OBJPROP_XDISTANCE,0);
         ObjectSet("BG",OBJPROP_YDISTANCE,15);
        }
      if(ObjectFind("BG1")<0) 
        {
         ObjectCreate("BG1",OBJ_LABEL,0,0,0);
         ObjectSetText("BG1","g",210,"Webdings",DimGray);
         ObjectSet("BG1",OBJPROP_BACK,FALSE);
         ObjectSet("BG1",OBJPROP_XDISTANCE,0);
         ObjectSet("BG1",OBJPROP_YDISTANCE,42);
        }
      if(ObjectFind("BG2")<0) 
        {
         ObjectCreate("BG2",OBJ_LABEL,0,0,0);
         ObjectSetText("BG2","g",210,"Webdings",DimGray);
         ObjectSet("BG2",OBJPROP_CORNER,0);
         ObjectSet("BG2",OBJPROP_BACK,TRUE);
         ObjectSet("BG2",OBJPROP_XDISTANCE,0);
         ObjectSet("BG2",OBJPROP_YDISTANCE,42);
        }
      if(ObjectFind("NAME")<0) 
        {
         ObjectCreate("NAME",OBJ_LABEL,0,0,0);
         ObjectSetText("NAME","JOEL ALVES TRADER EA - "+Symbol(),9,"Arial Bold",White);
         ObjectSet("NAME",OBJPROP_CORNER,0);
         ObjectSet("NAME",OBJPROP_BACK,FALSE);
         ObjectSet("NAME",OBJPROP_XDISTANCE,5);
         ObjectSet("NAME",OBJPROP_YDISTANCE,23);
        }
      if(ObjectFind("BG3")<0) 
        {
         ObjectCreate("BG3",OBJ_LABEL,0,0,0);
         ObjectSetText("BG3","g",110,"Webdings",DimGray);
         ObjectSet("BG3",OBJPROP_CORNER,0);
         ObjectSet("BG3",OBJPROP_BACK,TRUE);
         ObjectSet("BG3",OBJPROP_XDISTANCE,0);
         ObjectSet("BG3",OBJPROP_YDISTANCE,73);
        }
      if(ObjectFind("BG5")<0) 
        {
         ObjectCreate("BG5",OBJ_LABEL,0,0,0);
         ObjectSetText("BG5","g",210,"Webdings",DimGray);
         ObjectSet("BG5",OBJPROP_CORNER,0);
         ObjectSet("BG5",OBJPROP_BACK,FALSE);
         ObjectSet("BG5",OBJPROP_XDISTANCE,0);
         ObjectSet("BG5",OBJPROP_YDISTANCE,73);
        }
      f0_3();
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |   
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                                                    15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |  
//|Ethereum                                           0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D   |  
//|USDT addres  ERC-20 (Ethereum) address)            0x258C74Caac21c9535A0969F169FE0271d3cE56A0   | 
//+------------------------------------------------------------------------------------------------+