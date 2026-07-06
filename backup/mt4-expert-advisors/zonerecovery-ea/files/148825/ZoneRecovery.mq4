// More information about this indicator can be found at:
// http://fxcodebase.com/ 

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
#property indicator_buffers 6
#property indicator_plots 6
#property indicator_label1 "Buy Entry"
#property indicator_type1  DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Sell Entry"
#property indicator_type2  DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Buy TP"
#property indicator_type3  DRAW_LINE
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Buy SL"
#property indicator_type4  DRAW_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Sell TP"
#property indicator_type5  DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "Sell SL"
#property indicator_type6  DRAW_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1

//--- indicator buffers
double EntryBuy[];
double TPBuy[];
double SLBuy[];
double EntrySell[];
double TPSell[];
double SLSell[];

double entryPrice;
enum CicleType
{
	Buy,
	Sell,
	NotCicle
};
CicleType cicle;
// ------------------------------------------------------------------
input int    periods               = 10;                     // Periods lines:
input string T1                    = "== Notifications ==";  // ————————————
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Distances ==";  // ————————————
input int    gap                   = 20;                     // Pips Between Orders:
input int    TPpips                = 20;                     // TP:
input int    SLpips                = 20;                     // SL:
input string T3                    = "== Set Lines ==";      // ————————————
input bool   BuyOn                 = true;                   // Buy On?
input color  EntryBuyClr           = clrBlue;                // Entry Buy Color:
input color  TPBuyClr              = clrLime;                // TP Buy Color:
input color  SLBuyClr              = clrCrimson;             // SL Buy Color:
input bool   SellOn                = true;                   // Sell On?
input color  EntrySellClr          = clrRed;                 // Entry Sell Color:
input color  TPSellClr             = clrLime;                // TP Sell Color:
input color  SLSellClr             = clrCrimson;             // SL Sell Color:
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

// ------------------------------------------------------------------
int OnInit()
{
  //--- indicator buffers mapping
  SetIndexBuffer(0, EntryBuy, INDICATOR_DATA);
  SetIndexStyle(0, DRAW_LINE, EMPTY, 1, EntryBuyClr);
  SetIndexBuffer(1, EntrySell, INDICATOR_DATA);
  SetIndexStyle(1, DRAW_LINE, EMPTY, 1, EntrySellClr);
  SetIndexBuffer(2, TPBuy, INDICATOR_DATA);
  SetIndexStyle(2, DRAW_LINE, EMPTY, 1, TPBuyClr);
  SetIndexBuffer(3, SLBuy, INDICATOR_DATA);
  SetIndexStyle(3, DRAW_LINE, EMPTY, 1, SLBuyClr);
  SetIndexBuffer(4, SLSell, INDICATOR_DATA);
  SetIndexStyle(4, DRAW_LINE, EMPTY, 1, SLSellClr);
  SetIndexBuffer(5, TPSell, INDICATOR_DATA);
  SetIndexStyle(5, DRAW_LINE, EMPTY, 1, TPSellClr);

  if (!BuyOn)
  {
    SetIndexStyle(0, DRAW_NONE);
    SetIndexStyle(2, DRAW_NONE);
    SetIndexStyle(3, DRAW_NONE);
  }
  if (!SellOn)
  {
    SetIndexStyle(1, DRAW_NONE);
    SetIndexStyle(4, DRAW_NONE);
    SetIndexStyle(5, DRAW_NONE);
  }

  //---
  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}
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
  // clang-format off
  int start, i;
  // if (prev_calculated == 0) { start = rates_total - periods; } else { start = rates_total - (prev_calculated - 1); }
  // clang-format on
  haveBuy();
  haveSell();
  haveNotOrders();
	
  for (i = periods + 1; i >= 0; i--)
  {
    if (i == periods + 1)
    {
      EntryBuy[i]  = EMPTY_VALUE;
      TPBuy[i]     = EMPTY_VALUE;
      SLBuy[i]     = EMPTY_VALUE;
      EntrySell[i] = EMPTY_VALUE;
      TPSell[i]    = EMPTY_VALUE;
      SLSell[i]    = EMPTY_VALUE;
      continue;
    }
    
		if (cicle == Buy)
    {
      if (OrderSelect(0, SELECT_BY_POS) && OrderSymbol() == _Symbol)
        entryPrice = OrderOpenPrice();

      EntryBuy[i] = entryPrice;
      TPBuy[i]    = entryPrice + TPpips * 10 * _Point;
      SLBuy[i]    = entryPrice - SLpips * 10 * _Point;

      EntrySell[i] = entryPrice - gap * 10 * _Point;
      TPSell[i]    = EntrySell[i] - TPpips * 10 * _Point;
      SLSell[i]    = EntrySell[i] + SLpips * 10 * _Point;

      if (newCandle.IsNewCandle())
      {
        Notifications(0);
      }
    }

    if (cicle == Sell)
    {
      if (OrderSelect(0, SELECT_BY_POS) && OrderSymbol() == _Symbol)
        entryPrice = OrderOpenPrice();

      EntrySell[i] = entryPrice;
      TPSell[i]    = entryPrice - TPpips * 10 * _Point;
      SLSell[i]    = entryPrice + SLpips * 10 * _Point;
      
			EntryBuy[i] = entryPrice + gap * 10 * _Point;
      TPBuy[i]    = EntryBuy[i] + TPpips * 10 * _Point;
      SLBuy[i]    = EntryBuy[i] - SLpips * 10 * _Point;


      if (newCandle.IsNewCandle())
      {
        Notifications(1);
      }
    }

    if (cicle == NotCicle)
    {
      double price  = Ask + (gap / 2) * 10 * _Point;
      EntryBuy[i] = price + gap * 10 * _Point;
      TPBuy[i]    = price + TPpips * 10 * _Point;
      SLBuy[i]    = price - SLpips * 10 * _Point;

      price   = Bid - (gap / 2) * 10 * _Point;
      EntrySell[i] = price - gap * 10 * _Point;
      TPSell[i]    = price - TPpips * 10 * _Point;
      SLSell[i]    = price + SLpips * 10 * _Point;
    }
  }
  return (rates_total);
}

// ------------------------------------------------------------------

bool haveBuy()
{
  // TODO: signal up
	if(cicle == Sell)return false;
  if(cicle == Buy)return true;

  for (int i = 0; i < OrdersTotal(); i++)
  {
    if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol)
    {
      if (OrderType() == OP_BUY)
      {
        cicle = Buy;
        return true;
      }
    }
  }
  return false;
}

bool haveSell()
{
  // TODO: signal down
  if(cicle == Buy)return false;
  if(cicle == Sell)return true;

	for (int i = 0; i < OrdersTotal(); i++)
  {
    if (OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == _Symbol)
    {
      if (OrderType() == OP_SELL)
      {
				cicle = Sell;
        return true;
      }
    }
  }
  return false;
}

bool haveNotOrders()
{
  if (OrdersTotal() == 0)
	{
    cicle = NotCicle;
    return true;
	}

  return false;
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
