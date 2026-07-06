// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72635

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
//|                                                                       https://mario-jemic.com/ |
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

#property description "Intructions:"
#property description "1. Download the file like .csv with the trades that you want to send. The data would be separate by comma (,)", "\n",
#property description "2. Put the file into the folder MQL4/Files"
#property description "3. Press Button -Load Data- (the button turn green when have some data to send)"
#property description "4. Press Button -Send Orders- to send the pending orders to the market"
#property description " "
#property description "Note: some times the orders are too many, so the broker not allow to send more ( error 148 )"
#property strict

#define CSV
#ifdef CSV

// #include "Read_csv.mqh"
class ReadCSV
{
  string _FileName;
  int    _Columns, _Rows;
  string _Data[];

 public:
  ReadCSV(string fileName) : _FileName(fileName) { ; }
  ~ReadCSV() { ;}

int Rows() { return _Rows; }
int Columns() { return _Columns; }
void CleanData()
{
  ArrayFree(_Data);
}
int QntData()
{
  return ArraySize(_Data);
}

void AutoSetColumnsAndRows()
  {
    short del  = ',';
    int file = FileOpen(_FileName, FILE_WRITE | FILE_READ | FILE_CSV, del);

    // Set Columns:
    int c = 0;
    while (!FileIsLineEnding(file))
    {
      FileReadString(file);
      c++;
    }
    _Columns = c;
    Print("Columns: ", c);

    // Set Rows:
    FileSeek(file, 0, SEEK_SET);
    int r = 0, t = 0;
    while (!FileIsEnding(file))
    {
      FileReadString(file);
      t++;
    }

    if (c != 0) r = t / c;
    _Rows = r;
    Print("Rows: ", _Rows);

    ArrayResize(_Data, t);

    FileClose(file);
  }

void SetDimensions(int rows, int columns)
{
  _Rows = rows;
  _Columns = columns;
  int size = rows * columns;
  ArrayResize(_Data, size);
}

  void Load()
  {
		short del  = ',';
    int file = FileOpen(_FileName, FILE_WRITE | FILE_READ | FILE_CSV, del);

    if (file != INVALID_HANDLE)
    {
      int pos = 0;
      for (int r = 0; r < _Rows; r++)
      {
        for (int c = 0; c < _Columns; c++)
        {
          string info = FileReadString(file);
          if (info == "") info = " ";
          _Data[pos] = info;
          pos++;
        }
      }
    } else
      PrintFormat("Error, code = %d", GetLastError());

    FileClose(file);
  }

  void PrintArray()
  {
    for (int i = 0; i < ArraySize(_Data); i++)
    {
      Print("Info en DATA, pos:", i, " ", _Data[i]);
    }
  }

  // filas y columnas inician en cero
	string RowHeader(int row)
  {
    if (_Columns == 0 || _Rows == 0) { AutoSetColumnsAndRows(); }
      
		int i = _Columns * row;
    return _Data[i];
  }
  
	// filas y columnas inician en cero
	string Value(int row, int column)
  {
    if (_Columns == 0 || _Rows == 0) { AutoSetColumnsAndRows(); }
      
		int pos = _Columns * row; // estás en el inicio de ese renglón
    pos += column;

    return _Data[pos];
  }
};
ReadCSV* csv;

#endif CSV

#define SEND_NEW_ORDER
#ifdef SEND_NEW_ORDER

interface iActions
{
  bool doAction();
};
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
      double   countPartials) : _id(id),
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
   double         tslNext()          { return _tslNext; }
   double         breakevenWasDoIt() { return _bkvWasDoIt; }
   int            countPartials()    { return _countPartials; }
   
   double         profit()
   { 
      if (OrderSelect(_id, SELECT_BY_TICKET)) 
      {
         double result = OrderProfit()+OrderCommission()+OrderSwap(); 
         return result;
      }
      return -1; 
   }
};

class SendNewOrder : public iActions
{
  private:
   Order* newOrder;
   bool _hideTp;
   bool _hideSl;

  public:
   SendNewOrder(string side, double lots, string symbol = "", double price = 0, double sl = 0, double tp = 0, int magic = 0, string coment = "", datetime expire = 0, bool hideTp=false, bool hideSl=false)
   {
     _hideSl        = hideSl;
     _hideTp        = hideTp;
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
      // delete newOrder;
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
		if(CheckPointer(newOrder)==POINTER_INVALID) return false;
      
			// tp and sl value are still save into the order, but we not send to the broker;
      double tp = _hideTp == true ? 0 : newOrder.tp();
      double sl = _hideSl == true ? 0 : newOrder.sl();

      int tk = OrderSend(newOrder.symbol(), newOrder.type(), newOrder.lot(), newOrder.price(), 1000, sl, tp, newOrder.comment(), newOrder.magic(), newOrder.expireTime(), clrNONE);

      if (tk < 0)
      {
         Print(__FUNCTION__, " ", "Cannot Send Order, error: ", GetLastError());
         return false;
      } else 
			{
				for(int i=OrdersTotal()-1;i>=0;i--)
				{
					 if(OrderSelect(i,SELECT_BY_POS) && OrderSymbol() == newOrder.symbol() && OrderMagicNumber() == newOrder.magic())
					 {
	        		newOrder.id(OrderTicket());
							return true;							
					 }
				}
      }
      return true;
   }

   Order* lastOrder()
   {
      return GetPointer(newOrder);
   }
};

SendNewOrder* actionSendOrder;

#endif SEND_NEW_ORDER


#define GUI_
#ifdef GUI_

// #include "Gui.mqh"
#include <Canvas\Canvas.mqh>

#define SLIDER_MOVE 1
#define FOCUS_ON 2
#define MOVEALL_ON 3
#define PRIORITY_CONTROL 4

enum PriceAnchor {
  Top,
  Bottom,
  Center
};

class CObjectBase
{
 protected:
  CCanvas     canvas;
  int         _id;
  string      _name;
  int         _x;
  int         _x2;
  int         _y;
  int         _y2;
  int         _high;
  int         _width;
  bool        _focus;
  bool        _hide;
  bool        _show;
  uint        _colorBack;
  uint        _colorHover;
  string      _text;
  string      _font;
  uint        _textColor;
  bool        _wasPressed;
  bool        _movable;
  uint        _currentColor;
  double      _price;
  double      _priceY2;
  PriceAnchor _priceAnchor;
  int         _distanceToMouse;

 public:
  CObjectBase() { ; }
  ~CObjectBase()
  {
    canvas.Destroy();
  }

  // clang-format off
  virtual void OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam) { ; }
	virtual void OnTickEvent();
	void OnDeinitEvent(){ canvas.Destroy();}

  void   id(int inpid)               { _id = inpid; }
  int    id(void)                    { return _id; }
  void   Name(string name)           { _name = name; }
  string Name(void)                  { return _name; }
  
	void   X(int inpx)                 { _x = inpx; }
  int    X(void)                     { return _x; }
  void   Y(int inpy)                 { _y = inpy; }
  int    Y(void)                     { return _y; }
  int    X2(void)                    { return _x + _width; }
  int    Y2(void)                    { return _y + _high; }
  void   Y2(int inpy2)               { _y2 = inpy2; High(_y -_y2);}

void DistanceToMouse(int inpdistanceToMouse) { _distanceToMouse = inpdistanceToMouse; }
void setDistanceToMouse(int mousePos) {if(_distanceToMouse==0) _distanceToMouse = mousePos - Y();}
int  DistanceToMouse(void) { return _distanceToMouse; }

void SetPosByPrice(double price) 
{ 
		int coorY = Coordinate(price);
    if(Anchor() == Top)    Y(coorY);
    if(Anchor() == Bottom) Y(coorY-High());
    if(Anchor() == Center) Y(coorY-High()/2);

		ObjectSetInteger(0, _name, OBJPROP_YDISTANCE, Y());
		
		Refresh();
}
// le pasas un precio te retorna la coordernada y
int Coordinate(double price) 
{ 
		Price(price); 
	  datetime tm = TimeCurrent();
		int coorY, coorX;
	  ChartTimePriceToXY(0, 0, tm, _price, coorX, coorY);  		
		return coorY;
}
  
	void   High(int high)              { _high = high; }
  int    High(void)                  { return _high; }
  void   Width(int width)            { _width = width; }
  int    Width(void)                 { return _width; }
  
	void   Focus(bool focus)           { _focus = focus; }
  bool   Focus(int x, int y)                 
	{ 
		_focus = false;
		if (x > X() && x < X2() && y > Y() && y < Y2())
    {
      _focus = true;			
			EventChartCustom(0,FOCUS_ON,0, y, _name);
    } 

		return _focus; 
	}

  void   Hide(bool hide)             { _hide = hide; }
  bool   Hide(void)                  { return _hide; }
  void   Show(bool show)             { _show = show; }
  bool   Show(void)                  { return _show; }
  
	void   ColorBack(color colorBack, int alpha)   { _colorBack = ColorToARGB(colorBack, alpha); }
	color  ColorBack()   { return _colorBack; }
  void   ColorHover(color colorHover, int alpha) { _colorHover = ColorToARGB(colorHover, alpha); }	
  void   ChangeColor(void)
	{
			_currentColor = _focus == true ? _colorHover : _colorBack;
			Refresh();
	}
	
	void Refresh()
	{
		canvas.Erase(_currentColor);		
    canvas.TextOut(Width()/2, 0, _text, _textColor, 1);
    canvas.Update(true);
	}

	void   Text(string text)                     { _text = text; }
  string Text(void)                            { return _text; }
  void   Font(string font, int size=9)           { _font = font; canvas.FontSet(_font, size*-10); }
  string Font(void)                            { return _font; }
  void   TextColor(color textColor, int alpha) { _textColor = ColorToARGB(textColor, alpha); }   
  uint   TextColor(void)                       { return _textColor; }

	void  Movable(bool movable)                  { _movable = movable; }
	bool  Movable(void)                          { return _movable; }
	void   WasPressed(bool  wasPressed)          { _wasPressed = wasPressed; }
	bool   WasPressed(void)                      { return _wasPressed; }
	void   Move(int y, double limitPrice=0)
	{
		if(!Movable()) return;
		
		if(WasPressed())
		{
	  	// limitar el movimiento
			if(limitPrice==0)
			{
				limitPrice = Bid;
			}
			// int coorAsk= Coordinate(limitPrice);  
			// int coorBid= Coordinate(Bid);  
			
			// int coorAsk= Coordinate(Ask);  
			// int coorBid= Coordinate(Bid);  

			// if(Anchor() == Top) 
			// {
			// 	if(y <= coorAsk)
			// 	{ 
			// 		y=coorAsk; 
			// 	}
			// } else 
			// {
			// 	 if(y >= coorBid) 
			// 	 {
			// 		 y=coorBid; 
			// 	 }
			// }
			
			//--- 
			
			int coorLimit= Coordinate(limitPrice);  
			
			if(Anchor() == Top) 
			{
				if(y <= coorLimit-5) { y=coorLimit-5; } 
			} else 
			{
				 if(y >= coorLimit-15) { y=coorLimit-15; }
			}
		
			Y(y);		 
		 ObjectSetInteger(0, _name, OBJPROP_YDISTANCE, Y());		
		 EventChartCustom(0,SLIDER_MOVE,0, y,_name);
		}
		Refresh();
	}
	void   MoveSlave(int mousePos)
	{
  		setDistanceToMouse(mousePos);
			Print(_name, "/ _distanceToMouse: ", _distanceToMouse);

			Y(mousePos - _distanceToMouse);	
			ObjectSetInteger(0, _name, OBJPROP_YDISTANCE, Y());		
			Refresh();
	}
	void   MoveSpecial(int mousePos, int sparam)
	{
		// ej: el obj esta en 180 , el mouse en 100, dif=-80. 
		// Esta distancia la tiene que mantener, 
		// significa que la nueva posición vá a ser, mouseY+distToMove
		
		// int distToMove = Y() - mouseY; 
		// Print("_y = ",_y); 
		// Print("distToMove: ", distToMove);
			setDistanceToMouse(mousePos);

			Print("_distanceToMouse: ", _distanceToMouse);

			// Y(mousePos - _distanceToMouse);	
			// ObjectSetInteger(0, _name, OBJPROP_YDISTANCE, Y());		
			EventChartCustom(0, MOVEALL_ON,0, mousePos, _name);

			// EventChartCustom(0,SLIDER_MOVE,0, y,_name);
		Refresh();
	}
  
	double PriceTop()
  {
    datetime tm;
    double   pr;
    int      sub;
    if (!ChartXYToTimePrice(0, X(), Y(), sub, tm, pr)) { return -1; }
    return NormalizeDouble(pr, _Digits);
  }
	double PriceBottom()
  {
    datetime tm;
    double   pr;
    int      sub;
    if (!ChartXYToTimePrice(0, X(), Y2(), sub, tm, pr)) { return -1; }
    return NormalizeDouble(pr, _Digits);
  }
	double PriceCenter()
  {
    datetime tm;
    double   pr;
    int      sub;
		int yCenter = (Y()+Y2())/2;
    if (!ChartXYToTimePrice(0, X(), yCenter, sub, tm, pr)) { return -1; }
    return NormalizeDouble(pr, _Digits);
  }
	void setPrice()
	{
		if(Anchor() == Top)    _price = PriceTop();
		if(Anchor() == Bottom) _price = PriceBottom();
		if(Anchor() == Center) _price = PriceCenter();
	}
	double Price(void) { setPrice(); return _price; }
	void Price(double price) { _price = price; }

	void   Anchor(PriceAnchor priceAnchor) 
	{ 
		_priceAnchor = priceAnchor; 	
		// Print("_priceAnchor",_priceAnchor);
		if(_priceAnchor == Top) { ObjectSetInteger(0,_name,OBJPROP_ANCHOR,ANCHOR_UPPER); }
		if(_priceAnchor == Center) { ObjectSetInteger(0,_name,OBJPROP_ANCHOR,ANCHOR_CENTER); }
		if(_priceAnchor == Bottom) { ObjectSetInteger(0,_name,OBJPROP_ANCHOR,ANCHOR_LOWER); }
	
	}
	PriceAnchor Anchor()
	{
		return _priceAnchor;
	}

  // clang-format on
};

class CButtonFlat : public CObjectBase
{
 public:
  CButtonFlat() { DefaultProperties(); }
  ~CButtonFlat() { ; }

  void OnTickEvent()
  {
    Text("Pr: " + (string)Bid);
    Refresh();
  }
  void OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
  {
    int mousex = lparam;
    int mousey = dparam;

    // NOTE: CHARTEVENT_MOUSE_MOVE
    if (id == CHARTEVENT_MOUSE_MOVE)
    {
      Focus(mousex, mousey);
      ChangeColor();
      // Print(sparam);
      // SetPosByPrice(Ask);

      if (sparam == 0)
      {
        WasPressed(false);
      }
      if (sparam == 1 && Focus(mousex, mousey))
      {
        // EventChartCustom(0,PRIORITY_CONTROL,0, mousey, _name);
      }
      // Move(mousey);

      return;
    }

    if (id == CHARTEVENT_OBJECT_CLICK)
    {
      // SetPosByPriceY(1.25240);
      Print(sparam);
      return;
    }
  }

  void DefaultProperties()
  {
    Name("BtFlat");
    X(0);
    Y(Coordinate(Bid));
    Anchor(Center);
    Width(150);
    High(16);
    ColorBack(C'20,20,20', 255);
    ColorHover(C'33,97,140', 255);
    canvas.FontSet("Calibri", -90);
    Text(_name);
    TextColor(clrWhite, 255);
    Movable(true);
  }

  bool Create()
  {
    _currentColor = _colorBack;

    if (!canvas.CreateBitmapLabel(0, 0, _name, _x, _y, _width, _high, COLOR_FORMAT_ARGB_NORMALIZE))
    {
      Print("CAN'T CREATE THE BUTTON, ERROR: ", GetLastError());
      return false;
    }
    Refresh();

    return true;
  }

  void RefreshText()
  {
    canvas.Erase(_currentColor);
    canvas.TextOut(Width() / 2, 0, _text, _textColor, 1);
    canvas.Update(true);
  }
};
CButtonFlat* btLoad;
CButtonFlat* btSend;
CButtonFlat* btDelete;

#endif GUI_

//////////////////////////////////////////////////////////////////////

input string uFile    = "Weekly Script Test - Sheet1.csv";  // .csv File Name:
input int    uRows    = 30;                                 // Rows in .csv file:
input int    uColumns = 11;                                 // Columns in .csv file:
input double uLots    = 0.1;                                // Lots:
input int    uMagic   = 202208;                             // Magic Number:
input color  uBackColor = DimGray;                          // Chart Back Color:
//////////////////////////////////////////////////////////////////////

int OnInit()
{
  ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1, true);
  
	ChartSetInteger(0, CHART_COLOR_BACKGROUND, uBackColor);
  ChartSetInteger(0, CHART_COLOR_FOREGROUND, uBackColor);
  ChartSetInteger(0, CHART_COLOR_GRID, uBackColor);
  ChartSetInteger(0, CHART_COLOR_VOLUME, uBackColor);
  ChartSetInteger(0, CHART_COLOR_CHART_UP, uBackColor);
  ChartSetInteger(0, CHART_COLOR_CHART_DOWN, uBackColor);
  ChartSetInteger(0, CHART_COLOR_CHART_LINE, uBackColor);
  ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, uBackColor);
  ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, uBackColor);
  ChartSetInteger(0, CHART_COLOR_BID, uBackColor);
  ChartSetInteger(0, CHART_COLOR_ASK, uBackColor);
	

  CreateGui();
  csv = new ReadCSV(uFile);

  return (INIT_SUCCEEDED);
}

void CreateGui()
{
  btLoad = new CButtonFlat();
  btLoad.Name("btLoad");
  btLoad.Text("Load from " + uFile);
  btLoad.Width(250);
  btLoad.X(10);
  btLoad.Y(50);
  btLoad.ColorHover(C'13,71,161', 255);  // Azul Marino
  btLoad.Create();

  btSend = new CButtonFlat();
  btSend.Name("btSend");
  btSend.Text("Send Orders");
  btSend.Width(250);
  btSend.X(10);
  btSend.Y(70);
  btSend.ColorHover(C'13,71,161', 255);  // Azul Marino
  btSend.Create();

  btDelete = new CButtonFlat();
  btDelete.Name("btDelete");
  btDelete.Text("Delete Pendings");
  btDelete.Width(250);
  btDelete.X(10);
  btDelete.Y(90);
  btDelete.ColorHover(C'13,71,161', 255);  // Azul Marino
  btDelete.Create();
}

void LoadData()
{
  csv.SetDimensions(uRows, uColumns);
  csv.Load();
  csv.PrintArray();
}

void RefreshButtons()
{
  if (CheckPointer(csv) != POINTER_INVALID)
    if (csv.QntData() > 0 && btLoad.ColorBack() != Green)
    {
      btLoad.ColorBack(Green, 255);
    } else
    {
      btLoad.ColorBack(Black, 255);
    }
}

void GenerateOrders()
{
  if (csv.QntData() == 0)
  {
    Alert("No Data to Send, First Load Data from file");
    return;
  }

  for (int r = 0; r < csv.Rows(); r++)
  {
    // SYMBOL - si la columna 0 ó 1 no tiene valor, saltear al siguiente simbolo
    if (csv.Value(r, 0) == " " || csv.Value(r, 0) == "")
    {
      continue;
    }
    string sym = csv.Value(r, 0);

    // SIDE: columna 1 (B ó S)
    if (csv.Value(r, 1) == " " || csv.Value(r, 1) == "")
    {
      continue;
    }
    string side = csv.Value(r, 1);
    string type;
    if (side == "B")
    {
      type = "buy";
    }
    if (side == "S")
    {
      type = "sell";
    }

    // SL: es el mismo para todas las ordenes de un simbolo y está en la columna 2
    double sl   = 0;
    double data = StringToDouble(csv.Value(r, 2));
    sl          = csv.Value(r, 2) == "" ? 0 : csv.Value(r, 2);

    // PRICES: columnas 3 a 7
    double prices[5];
    for (int p = 0; p < ArraySize(prices); p++)
    {
      prices[p] = csv.Value(r, 3 + p);
    }

    // TP: vá a ser la primer celda con valor de las columnas 8,9,10
    double tp = 0;
    if (tp == 0 && csv.Value(r, 8) != 0) tp = StringToDouble(csv.Value(r, 8));
    if (tp == 0 && csv.Value(r, 9) != 0) tp = StringToDouble(csv.Value(r, 9));
    if (tp == 0 && csv.Value(r, 10) != 0) tp = StringToDouble(csv.Value(r, 10));

    // Generar las ordenes para el symbolo y enviarlas
    for (int i = 0; i < ArraySize(prices); i++)
    {
      actionSendOrder = new SendNewOrder(type, uLots, sym, prices[i], sl, tp, uMagic);
      actionSendOrder.doAction();
    }
    delete actionSendOrder;
  }

  csv.CleanData();
}

void DeletePendings()
{
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (OrderSelect(i, SELECT_BY_POS) && OrderMagicNumber() == uMagic)
    {
      if (OrderType() != OP_BUY && OrderType() != OP_SELL)
      {
        OrderDelete(OrderTicket());
      }
    }
  }
}

// ------------------------------------------------------------------
void OnDeinit(const int reason)
{
  delete csv;
  delete btLoad;
  delete btSend;
  delete btDelete;
}

void OnTick()
{
  RefreshButtons();
}

void OnTimer(void) {}

void OnTrade(void) {}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
  btLoad.OnEvent(id, lparam, dparam, sparam);
  btSend.OnEvent(id, lparam, dparam, sparam);
  btDelete.OnEvent(id, lparam, dparam, sparam);

  if (id == CHARTEVENT_OBJECT_CLICK && sparam == "btLoad")
  {
    LoadData();
    return;
  }
  if (id == CHARTEVENT_OBJECT_CLICK && sparam == "btSend")
  {
    GenerateOrders();
    return;
  }
  if (id == CHARTEVENT_OBJECT_CLICK && sparam == "btDelete")
  {
    DeletePendings();
    return;
  }
}

//////////////////////////////////////////////////////////////////////
