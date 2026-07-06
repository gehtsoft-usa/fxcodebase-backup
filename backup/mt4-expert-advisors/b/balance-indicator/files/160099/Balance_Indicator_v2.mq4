// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&p=148816#p148816
// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
// #property indicator_chart_window
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots 3
#property indicator_label1 "Line Balance"
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_color1 clrDimGray
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Line Buys"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrRoyalBlue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Line Sells"
#property indicator_type3  DRAW_LINE
#property indicator_color3 clrRed
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

//--- indicator buffers
double LineBalance[];
double LineBuys[];
double LineSells[];

// ------------------------------------------------------------------
input string T1                    = "== Notifications ==";  // ————————————
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Lines ==";      // ————————————
input bool   DrawBalance           = true;                   // Draw Balance variation?
input bool   DrawBuys              = true;                   // Draw Buys?
input bool   DrawSells             = true;                   // Draw Sells?
input color  LineBalance_crl       = clrDimGray;             // Line Up Color:
input color  LineBuys_clr          = clrRoyalBlue;           // Line Down Color:
input color  LineSells_clr         = clrRed;                 // Line Down Color:
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
  SetIndexBuffer(0, LineBalance, INDICATOR_DATA);
  SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 2, LineBalance_crl);
  SetIndexBuffer(1, LineBuys, INDICATOR_DATA);
  SetIndexStyle(1, DRAW_LINE, EMPTY, 1, LineBuys_clr);
  SetIndexBuffer(2, LineSells, INDICATOR_DATA);
  SetIndexStyle(2, DRAW_LINE, EMPTY, 1, LineSells_clr);

	//--- set levels    
   IndicatorSetInteger(INDICATOR_LEVELS,1); 
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0); 
	 SetLevelStyle(STYLE_SOLID,1,clrDimGray);

  if (!DrawBalance) SetIndexStyle(0, DRAW_NONE);
  if (!DrawBuys) SetIndexStyle(1, DRAW_NONE);
  if (!DrawSells) SetIndexStyle(2, DRAW_NONE);

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
  int start, i;
  if (prev_calculated == 0)
  {
    start = 1;
  } else
  {
    start = rates_total - (prev_calculated - 1);
  }

  for (i = start; i >= 0; i--)
  {
    LineBalance[i] = BuyAmount() + SellAmount();
    LineBuys[i]    = BuyAmount();
    LineSells[i]   = SellAmount();
  }

  return (rates_total);
}

// ------------------------------------------------------------------

double SellAmount()
{
  double amount = 0;
  int total = OrdersTotal();
  
  for (int i = 0; i < total; i++)
  {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
       bool symbolMatch = (IsTesting() || IsOptimization()) ? true : (OrderSymbol() == _Symbol);
      
      if (symbolMatch && OrderType() == OP_SELL)
      {
        amount += OrderProfit() + OrderCommission() + OrderSwap();
      }
    }
  }
  return amount;
}

double BuyAmount()
{
  double amount = 0;
  int total = OrdersTotal();
  
  for (int i = 0; i < total; i++)
  {
    if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
    {
       bool symbolMatch = (IsTesting() || IsOptimization()) ? true : (OrderSymbol() == _Symbol);
      
      if (symbolMatch && OrderType() == OP_BUY)
      {
        amount += OrderProfit() + OrderCommission() + OrderSwap();
      }
    }
  }
  return amount;
}

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

// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&p=148816#p148816
// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+