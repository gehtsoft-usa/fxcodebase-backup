// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73218

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  |
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

 

#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 0
#property indicator_label1 "Line Up"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrBlue
#property indicator_label2 "Line Down"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

//--- indicator buffers
double LineUp[];
double LineDn[];

// NOTE: ini
// ------------------------------------------------------------------
enum LabelType {
  points,
  money
};

input bool      includePendings = true;               // Include Pending Orders:
input int       magico          = 0;                  // Magic Number:
input LabelType showtype        = money;              // Profit Calculation mode:
input string    T2              = "== Set Lines ==";  // ————————————
input color     defaultclr      = clrGray;            // Default color:
input color     winclr          = clrLimeGreen;       // Line Win Color:
input color     lossclr         = clrOrange;          // Line Loss Color:
input int       width           = 2;                  // Width:
input string    buyname         = "Buy";              // Buy Line Name:
input string    sellname        = "Sell";             // Sell Line Name:

bool   LinesOn               = true;                   // Line On?
string T1                    = "== Notifications ==";  // ————————————
bool   notifications         = false;                  // Notifications On?
bool   desktop_notifications = false;                  // Desktop MT4 Notifications
bool   email_notifications   = false;                  // Email Notifications
bool   push_notifications    = false;                  // Push Mobile Notifications
// ------------------------------------------------------------------

class CNewCandle
{
 private:
  int    _initialCandles;
  string _symbol;
  int    _tf;

 public:
  CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
  CNewCandle()
  {
    // toma los valores del chart actual
    _initialCandles = iBars(Symbol(), Period());
    _symbol         = Symbol();
    _tf             = Period();
  }
  ~CNewCandle() { ; }

  bool IsNewCandle()
  {
    int _currentCandles = iBars(_symbol, _tf);
    if (_currentCandles > _initialCandles)
    {
      _initialCandles = _currentCandles;
      return true;
    }

    return false;
  }
};
CNewCandle newCandle();

// clang-format off
class Line
{
  string          _name;
  datetime        _iniTm;
  datetime        _endTm;
  double          _price;
  color           _clr;
  string          _txt;
  bool            _ray;
  int             _width;
  ENUM_LINE_STYLE _style;

 public:
  Line(string Name, datetime IniTm=0, datetime EndTm=0, double Price=0, color Clr=Black, string Txt = "")
  {
    _name  = Name;
    _iniTm = IniTm;
    _endTm = EndTm;
    _price = Price;
    _clr   = Clr;
    _txt   = Txt;
    _width = 1;
		_style = STYLE_SOLID;
  }
  ~Line() { erase(); }

  Line* name(string Name)            { _name  = Name;     return &this; }
  Line* price(double Price)          { _price = Price;    return &this; }
  Line* iniTime(int iniTm)           { _iniTm = iniTm;    return &this; }
  Line* width(int Width)             { _width = Width;    return &this; }
  Line* txt(string Txt)              { _txt   = Txt;      return &this; }
  Line* Ray(bool ray)                { _ray   = ray;      return &this; }
  Line* clr(color clr)               { _clr   = clr;      return &this; }
  Line* style(ENUM_LINE_STYLE Style) { _style = Style;    return &this; }
  Line* fromCandle(int candle)       { _iniTm = iTime(Symbol(), Period(), candle); return &this; }

  double price() { return _price; }
  string name()  { return _name; }

// NOTE: Line class

  void draw()
  {
    // draw line
    // ObjectCreate(0, _name, OBJ_TREND, 0, _iniTm, _price, TimeCurrent(), _price);
    ObjectCreate(0, _name, OBJ_HLINE, 0, _iniTm, _price);
    ObjectSetInteger(0, _name, OBJPROP_WIDTH, _width);
    ObjectSetInteger(0, _name, OBJPROP_COLOR, _clr);
    ObjectSetInteger(0, _name, OBJPROP_RAY_RIGHT, _ray);
    ObjectSetInteger(0, _name, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, _name, OBJPROP_STYLE, _style);

    // draw label
    if (_txt != "")
    {
      //  Period() * 2 * 60
      ObjectCreate(0, _name + "Label", OBJ_TEXT, 0, iTime(NULL, 0, 0), _price + 10*_Point);
      ObjectSetInteger(0, _name + "Label", OBJPROP_ANCHOR, ANCHOR_LOWER);
      ObjectSetString(0, _name + "Label", OBJPROP_FONT, "Calibri Light");
      ObjectSetInteger(0, _name + "Label", OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, _name + "Label", OBJPROP_COLOR, _clr);
      ObjectSetString(0, _name + "Label", OBJPROP_TEXT, _txt);
      // ObjectSetInteger(0, _name + "Label", OBJPROP_STYLE, STYLE_DOT);
    }
  }

  void erase()
  {
    ObjectDelete(0, _name);
    ObjectDelete(0, _name + "Label");
  }


  Line* redraw()
  {
    erase();
    draw();
    return &this;
  }


};
Line* upline;
Line* dnline;
// clang-format on
// ------------------------------------------------------------------
int OnInit()
{
  //--- indicator buffers mapping
  SetIndexBuffer(0, LineUp, INDICATOR_DATA);

  //---

  upline = new Line(buyname);
  dnline = new Line(sellname);
  upline.clr(defaultclr).width(width);
  dnline.clr(defaultclr).width(width);

  //---
  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
  delete upline;
  delete dnline;
}

// ------------------------------------------------------------------

int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
  // Print("BUY av: ", BuyAveragePrice());
  // Print("SEL av: ", SellAveragePrice());

  // upline.price(BuyAveragePrice()).clr(Blue).redraw();
  // dnline.price(SellAveragePrice()).clr(Orange).redraw();
  RefreshLines();

  // Print("buy count: ", BuyCount());
  // Print("sell count: ", SellCount());

  Print("buyProfit: ", buyProfit());

  return (rates_total);
}

// ------------------------------------------------------------------

bool haveSignalUp(int i)
{
  // TODO: signal up

  return true;
}

bool haveSignalDown(int i)
{
  // TODO: signal down

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

double BuyAveragePrice()
{
  double PipAdjust = 0;

  if (_Digits == 5 || _Digits == 3)
    PipAdjust = 10;
  else if (_Digits == 4 || _Digits == 2)
    PipAdjust = 1;

  double point = Point * PipAdjust;

  double Pip_Value = MarketInfo(Symbol(), MODE_TICKVALUE) * PipAdjust;
  double Pip_Size  = MarketInfo(Symbol(), MODE_TICKSIZE) * PipAdjust;

  //---

  int    Total_Buy_Trades = 0;
  double Total_Buy_Size   = 0;
  double Total_Buy_Price  = 0;
  double Buy_Profit       = 0;
  double Average_Price    = 0;

  // NOTE: buy average

  for (int i = 0; i < OrdersTotal(); i++)
  {
    if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
    {
      if (includePendings)
        if (OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP)
        {
          Total_Buy_Trades++;
          Total_Buy_Price += OrderOpenPrice() * OrderLots();
          Total_Buy_Size += OrderLots();
          // Buy_Profit += OrderProfit() + OrderSwap() + OrderCommission();
        }

      if (!includePendings)
        if (OrderType() == OP_BUY)
        {
          Total_Buy_Trades++;
          Total_Buy_Price += OrderOpenPrice() * OrderLots();
          Total_Buy_Size += OrderLots();
          // Buy_Profit += OrderProfit() + OrderSwap() + OrderCommission();
        }
    }
  }

  if (Total_Buy_Trades == 0) return 0;

  if (Total_Buy_Price > 0)
  {
    // Total_Buy_Price /= Total_Buy_Size;
    Average_Price = Total_Buy_Price / Total_Buy_Size;
  }

  // double distance = (Buy_Profit / (MathAbs(Total_Buy_Size * MarketInfo(Symbol(), MODE_TICKVALUE))) * MarketInfo(Symbol(), MODE_TICKSIZE));

  // double Average_Price = Bid - distance;

  // string _name = "Average_Price_Line_Buy_" + Symbol();
  // ObjectDelete(_name);
  // ObjectCreate(_name, OBJ_HLINE, 0, 0, Average_Price);
  // ObjectSet(_name, OBJPROP_WIDTH, 2);
  // //---
  // color cl = Green;
  // if (Buy_Profit < 0) cl = Red;
  // if (Buy_Profit == 0) cl = White;
  // //---
  // ObjectSet(_name, OBJPROP_COLOR, cl);

  return NormalizeDouble(Average_Price, _Digits);
}

double SellAveragePrice()
{
  double PipAdjust = 0;
  if (_Digits == 5 || _Digits == 3)
    PipAdjust = 10;
  else if (_Digits == 4 || _Digits == 2)
    PipAdjust = 1;
  double point = Point * PipAdjust;

  double Pip_Value = MarketInfo(Symbol(), MODE_TICKVALUE) * PipAdjust;
  double Pip_Size  = MarketInfo(Symbol(), MODE_TICKSIZE) * PipAdjust;

  //---

  int    Total_Trades  = 0;
  double Total_Size    = 0;
  double Total_Price   = 0;
  double Profit        = 0;
  double Average_Price = 0;

  for (int i = 0; i < OrdersTotal(); i++)
  {
    if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
    {
      if (includePendings)
        if (OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP)
        {
          Total_Trades++;
          Total_Price += OrderOpenPrice() * OrderLots();
          Total_Size += OrderLots();
          // Profit += OrderProfit() + OrderSwap() + OrderCommission();
        }

      if (!includePendings)
        if (OrderType() == OP_SELL)
        {
          Total_Trades++;
          Total_Price += OrderOpenPrice() * OrderLots();
          Total_Size += OrderLots();
          // Profit += OrderProfit() + OrderSwap() + OrderCommission();
        }
    }
  }

  if (Total_Trades == 0) return 0;

  if (Total_Price > 0)
  {
    // Total_Price /= Total_Size;
    Average_Price = Total_Price / Total_Size;
  }

  // double distance = (Profit / (MathAbs(Total_Size * MarketInfo(Symbol(), MODE_TICKVALUE))) * MarketInfo(Symbol(), MODE_TICKSIZE));

  // double Average_Price = Ask + distance;

  // string _name = "Average_Price_Line_Sell_" + Symbol();
  // ObjectDelete(_name);
  // ObjectCreate(_name, OBJ_HLINE, 0, 0, Average_Price);
  // ObjectSet(_name, OBJPROP_WIDTH, 2);
  // //---
  // color cl = Green;
  // if (Profit < 0) cl = Red;
  // if (Profit == 0) cl = White;
  // //---
  // ObjectSet(_name, OBJPROP_COLOR, cl);

  return NormalizeDouble(Average_Price, _Digits);
}

int BuyCount()
{
  int count = 0;
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
    {
      if (includePendings)
        if (OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP)
        {
          count += 1;
        }

      if (!includePendings)
        if (OrderType() == OP_BUY)
        {
          count += 1;
        }
    }
  }
  return count;
}
int SellCount()
{
  int count = 0;
  for (int i = OrdersTotal() - 1; i >= 0; i--)
  {
    if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
    {
      if (includePendings)
        if (OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP)
        {
          count += 1;
        }

      if (!includePendings)
        if (OrderType() == OP_SELL)
        {
          count += 1;
        }
    }
  }
  return count;
}

// NOTE: Refresh
void RefreshLines()
{
  string sym = showtype == money ? " $ " : " points: ";

  // Buy Line:
  // si hay buys mostrar buy line
  if (BuyCount() == 0)
    upline.erase();

  if (BuyCount() > 0 && ObjectFind(0, buyname) != 0)
    upline.price(BuyAveragePrice()).redraw();

  // actualizar el precio de la linea si el usuario la cambia
  double prb = ObjectGetDouble(0, buyname, OBJPROP_PRICE);
  upline.price(prb).txt(upline.name() + sym + (string)buyProfit()).redraw();

  // Sell Line:
  // si hay sells mostrar sell line
  if (SellCount() == 0)
    dnline.erase();

  if (SellCount() > 0 && ObjectFind(0, sellname) != 0)
    dnline.price(SellAveragePrice()).redraw();

  // actualizar el precio de la linea si el usuario la cambia
  double prs = ObjectGetDouble(0, sellname, OBJPROP_PRICE);
  dnline.price(prs).txt(dnline.name() + sym + (string)sellProfit()).redraw();

	// cambiar los colores:
  if (buyProfit() > 0) 
		upline.clr(winclr);
  else
    upline.clr(lossclr);
  
	if (sellProfit() > 0)
    dnline.clr(winclr);
  else
    dnline.clr(lossclr);
}

double calcProfit(double iniPrice, double linePrice, double lot, string side)
{
  double _tickValue    = MarketInfo(_Symbol, MODE_TICKVALUE);
  double _modeCalc     = MarketInfo(_Symbol, MODE_PROFITCALCMODE);
  double _contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
  double _step         = MarketInfo(_Symbol, MODE_LOTSTEP);
  double _points       = MarketInfo(_Symbol, MODE_POINT);
  double _digits       = MarketInfo(_Symbol, MODE_DIGITS);
  double distance      = 0;
  double money_profit  = 0;

  if (side == "buy")
    distance = (linePrice - iniPrice) / _points;

  if (side == "sell")
    distance = (iniPrice - linePrice) / _points;

  // FOREX
  if (_modeCalc == 0)
    money_profit = NormalizeDouble((lot * _tickValue * distance), 2);

  // FUTUROS
  // if (_modeCalc == 1 && _step != 1.0)
  // {
  //   double c = _contractSize * _step;
  //   // return NormalizeDouble(_money / (distance * c), 2);
  //   // lot = _money / (distance * c)
  //   return NormalizeDouble((_money / c / _lot), 2);
  // }

  // // FUTUROS SIN DECIMALES
  // if (_modeCalc == 1 && _step == 1.0)
  // {
  //   double c = _contractSize * _step;
  //   // return MathFloor(_money / (distance * c) * 100);
  //   return MathFloor((_money / c / _lot) / 100);
  // }

  if (showtype == points)
    return distance;

  return money_profit;
}

double buyProfit()
{
  double profit = 0;

  for (int i = 0; i < OrdersTotal(); i++)
  {
    if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
    {
      if (includePendings)
        if (OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP)
        {
          profit += calcProfit(OrderOpenPrice(), upline.price(), OrderLots(), "buy");
        }

      if (!includePendings)
        if (OrderType() == OP_BUY)
        {
          profit += calcProfit(OrderOpenPrice(), upline.price(), OrderLots(), "buy");
        }
    }
  }
  return NormalizeDouble(profit, 2);
}

double sellProfit()
{
  double profit = 0;

  for (int i = 0; i < OrdersTotal(); i++)
  {
    if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol && OrderMagicNumber() == magico)
    {
      if (includePendings)
        if (OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP)
        {
          profit += calcProfit(OrderOpenPrice(), dnline.price(), OrderLots(), "sell");
        }

      if (!includePendings)
        if (OrderType() == OP_SELL)
        {
          profit += calcProfit(OrderOpenPrice(), dnline.price(), OrderLots(), "sell");
        }
    }
  }
  return NormalizeDouble(profit, 2);
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