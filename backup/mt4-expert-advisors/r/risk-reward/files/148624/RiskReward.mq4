// More information about this indicator can be found at:
https://fxcodebase.com/code/viewtopic.php?f=38&t=73029

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


#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1

// NOTE: Enums
// ------------------------------------------------------------------
enum ModeTP {
  tp_modePips,   // Pips
  tp_modeATR,    // ATR
  tp_modeRatio,  // Ratio RR
};
enum ModeSL {
  sl_modePips,  // Pips
  sl_modeATR,   // ATR
};
enum ModeCalcLots {
  FixLots,         // Fix Lots
  Money,           // by Money
  AccountPercent,  // by Account Percent
};
enum Sides {
  Buy,
  Sell
};

// ------------------------------------------------------------------
input Sides           uSide             = Buy;                  // Side:
input string          Tvolumen          = "= Volumen =";        // ————————————
input ModeCalcLots    modeCalcLots      = FixLots;              // Mode to Calc Lots:
input double          userLots          = 0.01;                 // Setup Lots by "Fix Lots":
input double          userMoney         = 10;                   // Setup Lots by "Money":
input double          userBalancePer    = 0.1;                  // Setup Lots by "Account Percent":
input string          TATR              = "== ATR setup ==";    // ————————————
input ENUM_TIMEFRAMES uATRTf            = PERIOD_D1;            // ATR Time Frame:
input int             uATRPeriod        = 14;                   // ATR Periods:
input string          TSL               = "== Stop Loss ==";    // ————————————
input bool            stopLossOn        = true;                 // SL on:
input ModeSL          modeSL            = sl_modePips;          // Mode Stop Loss:
input int             userSLpips        = 20;                   // Pips SL
input double          uATRmultiplier_sl = 2;                    // ATR multiplier sl:
input string          TTP               = "== Take Profit ==";  // ————————————
input bool            takeProfitOn      = true;                 // TP on:
input ModeTP          modeTP            = tp_modePips;          // Mode Take Profit:
input int             userTPpips        = 20;                   // Pips TP
input double          uATRmultiplier_tp = 2;                    // ATR multiplier tp:
input double          uRatioTP          = 4;                    // Ratio RR:
input string          Tlines            = "== Lines ==";        // ————————————
input color           clrEntry          = Blue;                 // Entry Color:
input color           clrSL             = Red;                  // SL Color:
input color           clrTP             = LimeGreen;            // TP Color:

// ------------------------------------------------------------------
class HLine
{
  string          _name;
  datetime        _iniTm;
  double          _price;
  color           _clr;
  string          _txt;
  ENUM_LINE_STYLE _style;
  bool            _selectable;

 public:
  HLine(string inpName, datetime inpIniTm = 0, double inpPrice = 0, color inpClr = clrBlack, string inpLabelTxt = "", ENUM_LINE_STYLE inpStyle = 0, bool selectable = false)
  {
    _name       = inpName;
    _iniTm      = inpIniTm;
    _price      = inpPrice;
    _clr        = inpClr;
    _txt        = inpLabelTxt;
    _style      = inpStyle;
    _selectable = selectable;
  }
  ~HLine() { ; }

  // clang-format off

	string name()                          { return _name; }
  double price()                         { return _price; } 
  HLine* price(double inpPrice)          { _price = inpPrice; return &this; }
	HLine* txt(string inpTxt)              { _txt = inpTxt; return &this; }
  HLine* fromCandle(int candle)          { _iniTm = iTime(Symbol(), Period(), candle); return &this; }
  HLine* style(ENUM_LINE_STYLE inpStyle) { _style = inpStyle; return &this; }
	HLine* clr(color clr)                  { _clr = clr; return &this; }
  HLine* redraw()                        { erase(); draw(); return &this; }
	double linePrice()                     { return ObjectGetDouble(0, _name, OBJPROP_PRICE); }
  bool isSelected()                      { return ObjectGetInteger(0, _name, OBJPROP_SELECTED); }
  
	void move()                            { ObjectMove(0, _name,0, 0,_price); }
  void erase()                           { ObjectDelete(0, _name); ObjectDelete(0, _name + "Label"); }
	void changeColor(color clr)            { erase(); _clr = clr; draw(); }

	void draw()
  {
    // draw line
    ObjectCreate(0, _name, OBJ_HLINE, 0, _iniTm, _price, TimeCurrent(), _price);
    ObjectSetInteger(0, _name, OBJPROP_COLOR, _clr);
    ObjectSetInteger(0, _name, OBJPROP_SELECTABLE, true);
    ObjectSetInteger(0, _name, OBJPROP_STYLE, _style);

    // draw label
    if (_txt != "")
    {
      //  Period() * 2 * 60
      ObjectCreate(0, _name + "Label", OBJ_TEXT, 0, TimeCurrent()+60*_Period, _price);
      ObjectSetInteger(0, _name + "Label", OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
      ObjectSetString(0, _name + "Label", OBJPROP_FONT, "Calibri Light");
      ObjectSetInteger(0, _name + "Label", OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, _name + "Label", OBJPROP_COLOR, _clr);
      ObjectSetInteger(0, _name + "Label", OBJPROP_BGCOLOR, clrBlack);
      ObjectSetString(0, _name + "Label", OBJPROP_TEXT, _txt);
    }
  }
};
HLine slLine("slLine");
HLine entryLine("entryLine");
HLine tpLine("tpLine");

interface iLevels
{
  double calculateLevel(string side, double price);
  double pips();
  void   setSide(string);
};
class ByFixPips : public iLevels
{
  string _symbol;
  string _side;
  int    _pips;
  string _mode;  // TP SL
  double _price;

 public:
  ByFixPips(string inpSymbol, string inpSide, int inpPips, string inpMode, double Price = 0)
  {
    _pips   = inpPips;
    _symbol = inpSymbol;
    _side   = inpSide;
    _mode   = inpMode;
    _price  = Price;
  }
  ~ByFixPips() { ; }

  double pips() { return _pips; }

  double calculateLevel(string side, double price)
  {
    _side           = side;
    _price          = price;
    double mPoint   = MarketInfo(_symbol, MODE_POINT);
    double distance = _pips * 10 * mPoint;

    if (_pips == 0)
    {
      return 0;
    }

    if (_mode == "SL")
    {
      distance *= -1;
    }

    if (_side == "buy")
    {
      double ask        = SymbolInfoDouble(_symbol, SYMBOL_ASK);
      double entryPrice = _price == 0 ? ask : _price;
      return entryPrice + distance;
    }

    if (_side == "sell")
    {
      double bid        = SymbolInfoDouble(_symbol, SYMBOL_BID);
      double entryPrice = _price == 0 ? bid : _price;
      return entryPrice - distance;
    }

    return -1;
  }

  void setSide(string inpSide)
  {
    _side = inpSide;
  }
};
class ByATR : public iLevels
{
  string          _symbol;
  string          _side;
  double          _pips;
  string          _mode;  // TP SL
  ENUM_TIMEFRAMES _tf;
  int             _period;
  int             _shift;
  double          _m;
  double          _price;

 public:
  ByATR(string inpSymbol, string inpSide, string inpMode, ENUM_TIMEFRAMES inpATRTf, int inpATRPeriod, int inpATRShift, double inpATRmultiplier)
  {
    _symbol = inpSymbol;
    _side   = inpSide;
    _mode   = inpMode;
    _tf     = inpATRTf;
    _period = inpATRPeriod;
    _shift  = inpATRShift;
    _m      = inpATRmultiplier;
  }
  ~ByATR() { ; }

  double atr()
  {
    double digits = SymbolInfoInteger(_symbol, SYMBOL_DIGITS);
    double atr    = NormalizeDouble(iATR(_symbol, _tf, _period, _shift), digits);
    return atr;
  }

  double calculateLevel(string side, double price)
  {
    _side           = side;
    _price          = price;
    double mPoint   = MarketInfo(_symbol, MODE_POINT);
    double ask      = SymbolInfoDouble(_symbol, SYMBOL_ASK);
    double bid      = SymbolInfoDouble(_symbol, SYMBOL_BID);
    double spread   = ask - bid;
    double distance = (atr() * _m) + spread;
    _pips         = distance / mPoint / 10;
    double result = 0;

    if (_pips == 0)
    {
      return 0;
    }

    if (_mode == "SL")
    {
      distance *= -1;
    }

    if (_side == "buy")
    {
      return ask + distance;
    }
    if (_side == "sell")
    {
      return bid - distance;
    }
    return -1;
  }

  double pips()
  {
    calculateLevel(_side, _price);
    return _pips;
  }

  void setSide(string inpSide)
  {
    _side = inpSide;
  }
};
class ByRatio : public iLevels
{
  string   _symbol;
  string   _side;
  int      _pips;
  string   _mode;  // TP SL
  double   _ratio;
  double   _priceSL;
  double   _price;
  iLevels* _sl;

 public:
  ByRatio(string inpSymbol, string inpSide, double inpPriceSL, double inpRatio, string inpMode, iLevels* sl)
  {
    _symbol  = inpSymbol;
    _side    = inpSide;
    _mode    = inpMode;
    _ratio   = inpRatio;
    _priceSL = inpPriceSL;
    _sl      = sl;
  }
  ~ByRatio() { ; }

  void setSide(string inpSide)
  {
    _side = inpSide;
  }

  double calculateLevel(string side, double price)
  {
    _side  = side;
    _price = price;

    setPips();
    if (_pips == 0)
    {
      return 0;
    }

    double mPoint   = MarketInfo(_symbol, MODE_POINT);
    double distance = _pips * 10 * mPoint;
    double result   = 0;
    double ask      = SymbolInfoDouble(_symbol, SYMBOL_ASK);
    double bid      = SymbolInfoDouble(_symbol, SYMBOL_BID);

    if (_mode == "SL")
    {
      distance *= -1;
    }
    if (_side == "buy")
    {
      return ask + distance;
    }
    if (_side == "sell")
    {
      return bid - distance;
    }

    return -1;
  }

  void setPips()
  {
    _pips = _sl.pips() * _ratio;
  }

  double pips()
  {
    setPips();
    return _pips;
  }
};
class Levels : public iLevels
{
  iLevels* _level;

 public:
  Levels(iLevels* inpLevel)
  {
    _level = inpLevel;
  }
  ~Levels()
  {
    if (CheckPointer(_level) == 1)
      delete _level;
  }

  iLevels* level()
  {
    return _level;
  }
  double calculateLevel(string side, double price)
  {
    return _level.calculateLevel(side, price);
  }
  double pips()
  {
    return _level.pips();
  }

  void setSide(string inpSide)
  {
    _level.setSide(inpSide);
  }
};
Levels* levelTP;
Levels* levelSL;

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
      // Print(__FUNCTION__, " ", "Set Distance");
      return 0;
    }

    // FOREX
    if (_modeCalc == 0)
    {
      return NormalizeDouble(risk / distance / _tickValue, 2);
    }

    // FUTUROS
    if (_modeCalc == 1 && _step != 1.0)
    {
      double c = _contractSize * _step;
      return NormalizeDouble(risk / (distance * c), 2);
    }

    // FUTUROS SIN DECIMALES
    if (_modeCalc == 1 && _step == 1.0)
    {
      double c = _contractSize * _step;
      return MathFloor(risk / (distance * c) * 100);
    }

    return 0;
  }
};
LotCalculator* lotProvider;
// ------------------------------------------------------------------

// NOTE: OnInit
int OnInit()
{

  // NOTE: oninit Sl TP
  // clang-format off
	switch (modeSL)
  {
    case sl_modePips: levelSL = new Levels(new ByFixPips(_Symbol, "", userSLpips, "SL", 0)); break;
    case sl_modeATR: levelSL = new Levels(new ByATR(_Symbol, "", "SL", uATRTf, uATRPeriod,0, uATRmultiplier_sl)); break;
  }

  switch (modeTP)
  {
    case tp_modePips: levelTP = new Levels(new ByFixPips(_Symbol, "", userTPpips, "TP", 0)); break;
		case tp_modeATR: levelTP = new Levels(new ByATR(_Symbol, "", "TP", uATRTf, uATRPeriod,0, uATRmultiplier_tp)); break;
		case tp_modeRatio: levelTP = new Levels(new ByRatio(_Symbol, "",0, uRatioTP, "TP", levelSL)); break;
  }

  return (INIT_SUCCEEDED);
}
// ------------------------------------------------------------------
void OnDeinit(const int reason)
{
  entryLine.erase();
  slLine.erase();
  tpLine.erase();

  delete levelTP;
  delete levelSL;
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
	// int start, i;
  // if (prev_calculated == 0) { start = rates_total - 1;
  // } else { start = rates_total - (prev_calculated - 1); }

  // for (i = start; i >= 0; i--) {}

  drawTrade();
  return (rates_total);
}

// ------------------------------------------------------------------

void drawTrade()
{
	string side = uSide == Buy ? "buy" : "sell";
  
	entryLine.price(Price(side)).style(0).clr(clrEntry).txt("Entry: " + (string)Price(side) + " | Lots: "+(string)Lots()).redraw();
  slLine.price(SL(side)).style(2).clr(clrSL).txt("SL: " + (string)SL(side) + " | $ "+ riskAmount("SL")).redraw();
  tpLine.price(TP(side)).style(2).clr(clrTP).txt("TP: " + (string)TP(side) + " | $ "+ riskAmount("TP")).redraw();
}

double Price(string direction, int pips = 0, string _symbol = "")
{
  string symbol   = _symbol == "" ? Symbol() : _symbol;
  double points   = MarketInfo(symbol, MODE_POINT);
  double distance = pips * 10 * points;
  int    digits   = MarketInfo(symbol, MODE_DIGITS);

  if (direction == "buy")
  {
    double ask   = SymbolInfoDouble(_symbol, SYMBOL_ASK);
    double price = distance == 0 ? ask : ask + distance;

    // if (modeEntry == PendingStop)
    // {
    //   double cl = iClose(symbol, 0, 1);
    //   double op = iOpen(symbol, 0, 1);
    //   if (cl > op)
    //   {
    //     price = cl + distance;
    //   } else
    //   {
    //     price = op + distance;
    //   }
    // }
    // if (modeEntry == PendingLimit)
    // {
    //   double cl = iClose(symbol, 0, 1);
    //   double op = iOpen(symbol, 0, 1);
    //   if (cl > op)
    //   {
    //     price = op - distance;
    //   } else
    //   {
    //     price = cl - distance;
    //   }
    // }

    return NormalizeDouble(price, digits);
  }

  if (direction == "sell")
  {
    double bid   = SymbolInfoDouble(_symbol, SYMBOL_BID);
    double price = distance == 0 ? bid : bid + distance;

    // if (modeEntry == PendingStop)
    // {
    //   double cl = iClose(symbol, 0, 1);
    //   double op = iOpen(symbol, 0, 1);
    //   if (cl > op)
    //   {
    //     price = op - distance;
    //   } else
    //   {
    //     price = cl - distance;
    //   }
    // }
    // if (modeEntry == PendingLimit)
    // {
    //   double cl = iClose(symbol, 0, 1);
    //   double op = iOpen(symbol, 0, 1);
    //   if (cl > op)
    //   {
    //     price = cl + distance;
    //   } else
    //   {
    //     price = op + distance;
    //   }
    // }

    return NormalizeDouble(price, digits);
  }

  return -1;
}

double SL(string side, double price = 0)
{
  double result = 0;
  if (stopLossOn)
    result = levelSL.calculateLevel(side, price);

  return result;
}

double TP(string side, double price = 0)
{
  double result = 0;

  if (takeProfitOn)
    result = levelTP.calculateLevel(side, price);

  return result;
}

double Lots()
{
  lotProvider = new LotCalculator();
  double lots = -1;
  switch (modeCalcLots)
  {
    case Money:
      lots = lotProvider.LotsByMoney(userMoney, levelSL.pips());
      break;

    case AccountPercent:
      lots = lotProvider.LotsByBalancePercent(userBalancePer, levelSL.pips());
      break;

    case FixLots:
      lots = userLots;
      break;
  }
  delete lotProvider;
  return lots;
}

double riskAmount(string mode)
{
	double money = 0;
	double lots = Lots();
	double distance=0;
	if(mode == "SL") distance = Distancia(Price("buy"), SL("buy"), _Symbol, "pips");
	if(mode == "TP") distance = Distancia(Price("buy"), TP("buy"), _Symbol, "pips");

	double _tickValue    = MarketInfo(_Symbol, MODE_TICKVALUE);
	double _modeCalc     = MarketInfo(_Symbol, MODE_PROFITCALCMODE);

	// if (_modeCalc == 0) { money = distance * _tickValue * lots; }
	money = distance * _tickValue * lots;
		
	return NormalizeDouble(money, 2);
}

int Distancia(double precioA, double precioB, string par, string mode)
{

	double mPoints = MarketInfo(par, MODE_POINT);
	double dist   = fabs(precioA - precioB);
	if(mode == "points") return (dist / mPoints);
	if(mode == "pips") return ((dist / mPoints)/10);
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