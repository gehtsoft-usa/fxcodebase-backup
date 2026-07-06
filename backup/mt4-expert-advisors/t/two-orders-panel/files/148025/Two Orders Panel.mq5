// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72870

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

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
#include <Trade/Trade.mqh>

#define GUI_ON
#ifdef GUI_ON

int i_reason;
// #include "Panel.mqh"
#include <Controls\Button.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Label.mqh>

interface iActions {
  bool doAction();
};


// clang-format off
class GUI : public CAppDialog
{

 int _magic;
 int _high, _width;
 int _PanelWidth, _PanelHigh;
 int _x, _y;
 int _gapV, _gapH;
 iActions* button1Action; 
 iActions* button2Action; 
 iActions* button3Action; 
 
 // CEdit   edit1;

 public: 
  GUI(int magic=0)
	{
		int columns = 4;
		int rows = 7;

    _high  = 16;
    _width = 65;
    _x     = 10;
    _y     = 10;
    _gapV  = 2;
    _gapH  = 5;
		_magic = magic;		
    // _high  = (_PanelHigh/rows)-_gapV;
    // _width = (_PanelWidth/columns)-_gapH;
		_PanelWidth = 2 * _x + _width * columns + columns * _gapH;
		_PanelHigh  = 2 * _y + _high * rows + rows * _gapV;
  }
  ~GUI() 
	{ 
		delete button1Action;
		delete button2Action;
		delete button3Action;
	}

	CLabel  lb1, lb2, lb3, lb4, lb5, lb6, lb7, lb8, lb9;
	CButton bt1,bt2, bt3;
	CEdit e1,e2, e3,e4;

	void setButton1Action(iActions *action) { button1Action = action; }
	void setButton2Action(iActions *action) { button2Action = action; }
	void setButton3Action(iActions *action) { button3Action = action; }
	
	// Create Pannel:
	// ------------------------------------------------------------------
	int Row(int r) { return _y + (r * _high)+ r * _gapV; }  
	int Col(int c) { return _x + (c * _width)+ c * _gapH; }

	bool Create(const string name, const long chart=0,  const int subwin=0)
  {
		int x1 = 10;
		int y1 = 10;
		int x2 = x1+_PanelWidth;
		int y2 = y1+_PanelHigh;

    if (!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2)) return false;

    if (!Create_label("BUY" ,         Col(0), Row(0), _high, _width, lb1)) return false;
    if (!Create_label("Buy_SL" ,      Col(0), Row(1), _high, _width, lb3, "Stop Loss")) return false;
    if (!Create_label("Buy_TP",       Col(0), Row(2), _high, _width, lb4, "Stop Win")) return false;
    
		if (!Create_label("SELL",         Col(2), Row(0), _high, _width, lb2)) return false;
    if (!Create_label("Sell_SL",      Col(2), Row(1), _high, _width, lb5, "Stop Loss")) return false;
    if (!Create_label("Sell_TP",      Col(2), Row(2), _high, _width, lb6, "Stop Win")) return false;

    if (!Create_button("Confirme",    Col(3), Row(4), _high, _width, bt1)) return false; 

		if (!Create_edit("eSell_SL",      Col(1), Row(1), _high, _width, e1)) return false;
		if (!Create_edit("eSell_TP",      Col(1), Row(2), _high, _width, e2)) return false;
		if (!Create_edit("eBuy_SL",       Col(3), Row(1), _high, _width, e3)) return false;
		if (!Create_edit("eBuy_TP",       Col(3), Row(2), _high, _width, e4)) return false;
		

    return true;
  }

	virtual bool OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam);

	void HoverEvents(const int id, const long& lparam, const double& dparam, const string& sparam)
	{
		if(bt1.IsActive()) bt1.ColorBackground(RoyalBlue); else bt1.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
		if(bt2.IsActive()) bt2.ColorBackground(RoyalBlue); else bt2.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
		if(bt3.IsActive()) bt3.ColorBackground(RoyalBlue); else bt3.ColorBackground(CONTROLS_BUTTON_COLOR_BG);
	}
	
 protected:
  void OnEndEdit_edit1(){;}
  void OnClick_button1(){ button1Action.doAction();}
  // void OnClick_button2(){ button2Action.doAction();}
  // void OnClick_button3(){ button3Action.doAction();}

	bool Create_label(string name,int x1, int y1, int high, int width, CLabel &label, string txt="")
	{
   int x2 = x1+width;
   int y2 = y1+high;
   
	 label.Create(m_chart_id, name, 0, x1, y1, x2, y2);
	
	 string tx = txt ==""? name : txt;
   label.Text(tx);
   label.Font("Calibri");
   label.Color(C'121, 125, 127');
   label.FontSize(9);
   Add(label);
   return true;
	}

	bool Create_button(string name, const int x1, const int y1, const int high, const int width, CButton &bt)
	{
	 int x2 = x1+width;
   int y2 = y1+high;

	 bt.Create(m_chart_id, name, m_subwin, x1, y1, x2, y2);
   bt.Text(name);
   bt.Font("Calibri");
   bt.FontSize(9);

   Add(bt);
   return true;
	}

   bool Create_edit(string name, const int x1, const int y1, const int high, const int width, CEdit &ed)
	 {
	 	int x2 = x1+width;
   	int y2 = y1+high;

		ed.Create(m_chart_id, name, m_subwin, x1,y1,x2,y2);
		ed.Text("20");
   	ed.Font("Calibri");
   	ed.FontSize(9);

   	Add(ed);
   	return true;
	 }

};

//Mapa de eventos (MACRO substituciones)
EVENT_MAP_BEGIN(GUI)
// ON_EVENT(ON_END_EDIT, edit1, OnEndEdit_edit1)
ON_EVENT(ON_CLICK, bt1, OnClick_button1)
// ON_EVENT(ON_CLICK, bt2, OnClick_button2)
// ON_EVENT(ON_CLICK, bt3, OnClick_button3)
EVENT_MAP_END(CAppDialog)

GUI gui;

#endif

// clang-format on

// Gobal Variables
input double uLots = 0.01;                         // Lots
input int    magico = 2022663;                     // Magic Number:
bool         takeProfitOn            = true;       // Take Profit On:
bool         stopLossOn              = true;       // Stop Loss On:

//////////////////////////////////////////////////////////////////////

int OnInit()
{
	if (i_reason != REASON_CHARTCHANGE && i_reason != REASON_TEMPLATE && i_reason != REASON_PARAMETERS) 
	{
    gui.Create("Amazing Dashboard");
    gui.Run();
  }
  gui.setButton1Action(sendOrders = new SendOrders());
	

return(INIT_SUCCEEDED);
}
 
void OnDeinit(const int reason) 
{
	i_reason = reason;
  if (i_reason != REASON_CHARTCHANGE && i_reason != REASON_PARAMETERS) {
    gui.Destroy(reason);
  }
}
 
void OnTick() { }
 
void OnTimer(void) { }
 
void OnTrade(void) {}
 
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam){
  
	gui.ChartEvent(id, lparam, dparam, sparam);
  gui.HoverEvents(id, lparam, dparam, sparam);
}
 
//////////////////////////////////////////////////////////////////////

interface IOrders {
 public:
  virtual void Add()     = 0;
  virtual void Release() = 0;

  virtual bool AddOrder()    = 0;
  virtual bool DeleteOrder() = 0;
  virtual bool Select()      = 0;
};
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
  double          _tslNext;

 public:
  Order(
      int             id,
      string          symbol,
      double          price,
      double          sl,
      double          tp,
      double          lot,
      ENUM_ORDER_TYPE type,
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
	Order* type(ENUM_ORDER_TYPE type){_type=type; return &this;}
	Order* magic(int magic){_magic=magic; return &this;}
	Order* comment(string comment){_comment=comment; return &this;}
	Order* expireTime(datetime expireTm){_expireTime=expireTm; return &this;}
	Order* signalTime(datetime signalTm){_signalTime=signalTm; return &this;}
	Order* profit(double profit){_profit=profit; return &this;}
	Order* strategy(string strategy){_strategy=strategy; return &this;}
	Order* tslNext(double tslNext){_tslNext=tslNext; return &this;}

   int            id()         { return _id; }
   string         symbol()     { return _symbol; }
   double         price()      { return _price; }
   double         sl()         { return _sl; }
   double         tp()         { return _tp; }
   double         lot()        { return _lot; }
   ENUM_ORDER_TYPE type()      { return _type; }
   int            magic()      { return _magic; }
   string         comment()    { return _comment; }
   string         strategy()   { return _strategy; }
   datetime       expireTime() { return _expireTime; }
   datetime       signalTime() { return _signalTime; }
   // double         profit()     { if (OrderSelect(_id, SELECT_BY_TICKET)) return OrderProfit(); return -1; }
   double         profit()     { return _profit; }
   double         tslNext()    { return _tslNext; }
};
class SendNewOrder : public iActions
{
 private:
  Order* newOrder;
  CTrade trade;

 public:
  SendNewOrder(string side, double lots, string symbol = "", double price = 0, double sl = 0, double tp = 0, int magic = 0, string coment = "", datetime expire = 0)
  {
    string          _symbol = setSymbol(symbol);
    double          _price  = setPrice(side, price, _symbol);
    ENUM_ORDER_TYPE _type   = SetType(side, price, _symbol);
    trade.SetExpertMagicNumber(magic);

    if (_type == -1) {
      Print(__FUNCTION__, " ", "Imposible to set OrderType");
      return;
    }

    newOrder = new Order();

    newOrder
        .id(0)
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
    //  delete newOrder;
  }

  string setSymbol(string sim)
  {
    if (sim == "") {
      return Symbol();
    }
    return sim;
  }

  double setPrice(string side, double pr, string sym)
  {
    if (pr == 0) {
      if (side == "buy") {
        return SymbolInfoDouble(sym, SYMBOL_ASK);
      }
      if (side == "sell") {
        return SymbolInfoDouble(sym, SYMBOL_BID);
      }
    }

    return pr;
  }

  ENUM_ORDER_TYPE SetType(string side, double priceClient, string sym)
  {
    double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
    double bid = SymbolInfoDouble(sym, SYMBOL_BID);

    if (priceClient == 0) {
      if (side == "buy") {
        return ORDER_TYPE_BUY;
      }
      if (side == "sell") {
        return ORDER_TYPE_SELL;
      }
    } else {
      if (side == "buy") {
        if (priceClient > ask) {
          return ORDER_TYPE_BUY_STOP;
        }
        if (priceClient < ask) {
          return ORDER_TYPE_BUY_LIMIT;
        }
      }
      if (side == "sell") {
        if (priceClient > bid) {
          return ORDER_TYPE_SELL_LIMIT;
        }
        if (priceClient < bid) {
          return ORDER_TYPE_SELL_STOP;
        }
      }
    }

    return -1;
  }

  bool doAction()
  {
    if (!trade.PositionOpen(newOrder.symbol(), newOrder.type(), newOrder.lot(), newOrder.price(), newOrder.sl(), newOrder.tp(), newOrder.comment())) {
      Print(__FUNCTION__, " ", "Cannot Send Order, error: ", GetLastError());
      return false;
    }
    return true;
  }

  Order* lastOrder()
  {
    return GetPointer(newOrder);
  }
};
class SendOrders : public iActions
{
 SendNewOrder* actionBuy;
 SendNewOrder* actionSell;
	
	 public:
	 SendOrders(){;}
	 ~SendOrders(){;}

	 bool doAction()
	 {
			actionBuy = new SendNewOrder("buy", uLots, "", 0, SL("buy"), TP("buy"), magico);
			actionBuy.doAction();
			delete actionBuy;
			
			actionSell = new SendNewOrder("sell", uLots, "", 0, SL("sell"), TP("sell"), magico);
			actionSell.doAction();
			delete actionSell;
			
			return true;
	 }
};
SendOrders* sendOrders;

// ------------------------------------------------------------------
double Bid() { return SymbolInfoDouble(_Symbol, SYMBOL_BID); }
double Ask() { return SymbolInfoDouble(_Symbol, SYMBOL_ASK); }
enum ModeCalcLots { Money,
                    AccountPercent,
                    FixLots };
class LotCalculator
{
  double _tickValue;
  long   _modeCalc;
  double _contractSize;
  double _step;
  string _symbol;
  double _points;
  long   _digits;

 public:
  LotCalculator(string inpSymbol = "") { setSymbol(inpSymbol); };
  ~LotCalculator() { ; }

  void setSymbol(string sym)
  {
    if (sym == "") {
      _symbol = Symbol();
    } else {
      _symbol = sym;
    }
    _modeCalc     = SymbolInfoInteger(_symbol, SYMBOL_TRADE_CALC_MODE);
    _digits       = SymbolInfoInteger(_symbol, SYMBOL_DIGITS);
    _tickValue    = SymbolInfoDouble(_symbol, SYMBOL_TRADE_TICK_VALUE);
    _contractSize = SymbolInfoDouble(_symbol, SYMBOL_TRADE_CONTRACT_SIZE);
    _step         = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
    _points       = SymbolInfoDouble(_symbol, SYMBOL_POINT);
  }

  double LotsByBalancePercent(double BalancePercent, double Distance)
  {
    double risk = AccountInfoDouble(ACCOUNT_BALANCE) * BalancePercent / 100;
    return CalculateLots(risk, Distance);
  }

  double LotsByMoney(double Money, double Distance)
  {
    double risk = fabs(Money);
    return CalculateLots(risk, Distance);
  }

  double CalculateLots(double risk, double distance)  // distance in pips
  {
    distance *= 10;
    if (distance == 0) {
      Print(__FUNCTION__, " ", "Set Distance");
      return 0;
    }

    // FOREX
    if (_modeCalc == 0) {
      return NormalizeDouble(risk / distance / _tickValue, 2);
    }

    // FUTUROS
    if (_modeCalc == 1 && _step != 1.0) {
      double c = _contractSize * _step;
      return NormalizeDouble(risk / (distance * c), 2);
    }

    // FUTUROS SIN DECIMALES
    if (_modeCalc == 1 && _step == 1.0) {
      double c = _contractSize * _step;
      return MathFloor(risk / (distance * c) * 100);
    }

    return 0;
  }
};
LotCalculator* lotProvider;
double Price(string direction)
{
  double result = 0;
  if (direction == "buy") {
    result = Ask();
    return result;
  }

  if (direction == "sell") {
    result = Bid();
    return result;
  }

  return -1;
}
double SL(string direction)
{
  if (!stopLossOn) return 0;
  double result = 0;

  if (direction == "buy") {
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
		int Buy_SLpips = (int)gui.e1.Text();
    result     = ask - Buy_SLpips * 10 * _Point;
    return result;
  }

  if (direction == "sell") {
		int Sell_SLpips = (int)gui.e3.Text();
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    result     = bid + Sell_SLpips * 10 * _Point;
    return result;
  }

  return -1;
}
double TP(string direction)
{
  if (!takeProfitOn) return 0;
  double result = 0;
	
  if (direction == "buy") {
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  	int Buy_TPpips = (int)gui.e2.Text();
	  result     = ask + Buy_TPpips * 10 * _Point;
    return result;
  }

  if (direction == "sell") {
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
		int Sell_TPpips = (int)gui.e4.Text();
    result     = bid - Sell_TPpips * 10 * _Point;
    return result;
  }

  return -1;
}

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
