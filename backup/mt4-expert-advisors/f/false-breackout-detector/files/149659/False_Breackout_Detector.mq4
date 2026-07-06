//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73389

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
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#property indicator_label3 "Buy";
#property indicator_label4 "Sell";

//--- indicator buffers
double Valley[];
double Peack[];
double Buy[];
double Sell[];

// ------------------------------------------------------------------

input string T1                    = "== Notifications ==";  // ————————————
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";     // ————————————
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrBlue;                // Valley Color:
input color  ArrowDnClr            = clrOrange;              // Peack Color:
input color  BuyClr                = Green;                  // Buy Signal Color:
input color  SellClr               = Crimson;                // Sell Signal Color:
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
  SetIndexBuffer(0, Buy, INDICATOR_DATA);
   SetIndexArrow(0, 233);
   SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, BuyClr);
  SetIndexBuffer(1, Sell, INDICATOR_DATA);
   SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, SellClr);
   SetIndexArrow(1, 234);

  SetIndexBuffer(2, Valley, INDICATOR_DATA);
   SetIndexArrow(2, 159);
   SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
  SetIndexBuffer(3, Peack, INDICATOR_DATA);
   SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
   SetIndexArrow(3, 159);


  if (!ArrowsOn)
  {
    SetIndexStyle(0, DRAW_NONE);
    SetIndexStyle(1, DRAW_NONE);
  }
  //---
  return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) 
{
  ObjectsDeleteAll(0, "line");
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
  int i = rates_total - (prev_calculated + 6);
  if (i >= rates_total) i = rates_total - 1;
  for (; i > 0; i--)
  {
    if (isValley(i))
    {
      Valley[i + 3] = Low[i + 3];
      if (newCandle.IsNewCandle())
      {
        Notifications(0);
      }
    }
    if (isPeack(i))
    {
      Peack[i + 3] = High[i + 3];
      if (newCandle.IsNewCandle())
      {
        Notifications(1);
      }
    }

    if ((close[i+1] > lastPeack(i+1) && close[i] < lastPeack(i+1) )||
		(high[i] > lastPeack(i+1) && close[i] < lastPeack(i+1) && close[i]<=open[i]))
    {
      Sell[i] = high[i];
      drawLine(lastPeack(i + 1), (int)lastPeack(i + 1, "pos"), i, ArrowDnClr);
    }
    if ((close[i+1] < lastValley(i+1) && close[i]>lastValley(i+1)) || 
		(low[i] < lastValley(i+1) && close[i] > lastValley(i+1)&& close[i]>=open[i]))
    {
      Buy[i] = low[i];
			drawLine(lastValley(i + 1), (int)lastValley(i + 1, "pos"), i, ArrowUpClr);			
    }
  }

  return (rates_total);
}

// ------------------------------------------------------------------

bool isValley(int i)
{
  // TODO: signal up
  double cl5 = iLow(NULL, 0, i + 5);
  double cl4 = iLow(NULL, 0, i + 4);
  double cl2 = iLow(NULL, 0, i + 2);
  double cl1 = iLow(NULL, 0, i + 1);
  double lo  = iLow(NULL, 0, i + 3);
  return lo < cl2 && cl2 < cl1 && lo < cl4 && cl4 < cl5;
}

bool isPeack(int i)
{
  // TODO: signal down
  double cl5 = iHigh(NULL, 0, i + 5);
  double cl4 = iHigh(NULL, 0, i + 4);
  double cl2 = iHigh(NULL, 0, i + 2);
  double cl1 = iHigh(NULL, 0, i + 1);
  double hi  = iHigh(NULL, 0, i + 3);
  return hi > cl2 && cl2 > cl1 && hi > cl4 && cl4 > cl5;
}

double lastValley(int i, string mode="")
{
  while (Valley[i] == EMPTY_VALUE && i<ArraySize(Valley)-1)
  {
    i++;
  }

	double value = mode == "pos" ? i : Valley[i];
  return value;
}
double lastPeack(int i, string mode="")
{
  while (Peack[i] == EMPTY_VALUE && i<ArraySize(Peack)-1)
  {
    i++;
  }

  double value = mode == "pos"? i : Peack[i];
  return value;
}

void drawLine(double price, int iniPos, int endPos, color clr)
{
  string name = "line" + (string)iniPos;
  ObjectCreate(0, name, OBJ_TREND, 0, iTime(NULL, 0, iniPos), price, iTime(NULL, 0, endPos), price);
  ObjectSet(name, OBJPROP_RAY, false);
  ObjectSet(name, OBJPROP_COLOR, clr);
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