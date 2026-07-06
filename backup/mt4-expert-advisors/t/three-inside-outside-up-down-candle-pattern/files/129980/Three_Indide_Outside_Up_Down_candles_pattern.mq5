// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=147069

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
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4
#property indicator_label1 "Inside Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Inside Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Outside Up"
#property indicator_type3  DRAW_ARROW
#property indicator_color3 clrBlue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Outside Down"
#property indicator_type4  DRAW_ARROW
#property indicator_color4 clrRed
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
//--- indicator buffers
double InArrowUp[];
double InArrowDn[];
double OutArrowUp[];
double OutArrowDn[];

// NOTE: Inputs
// ------------------------------------------------------------------
input string T0                    = "== Set Arrows ==";     // Set Arrows
input bool   InArrowsOn            = true;                   // Inside Arrows On?
input color  InArrowUpClr          = clrBlue;                // Inside Up Color:
input color  InArrowDnClr          = clrRed;                 // Inside Down Color:
input bool   OutArrowsOn           = true;                   // Outside Arrows On?
input color  OutArrowUpClr         = clrRoyalBlue;           // Outside Up Color:
input color  OutArrowDnClr         = clrTomato;              // Outside Down Color:
input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications

// NOTE: Objects
// ------------------------------------------------------------------
class CNewCandle
{
 private:
  int             _initialCandles;
  string          _symbol;
  ENUM_TIMEFRAMES _tf;

 public:
  CNewCandle(string symbol, ENUM_TIMEFRAMES tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
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
    if (_currentCandles > _initialCandles) {
      _initialCandles = _currentCandles;
      return true;
    }

    return false;
  }
};
CNewCandle newCandle();

// NOTE: OnInit
// ------------------------------------------------------------------
int OnInit()
{
  SetIndexBuffer(0, InArrowUp, INDICATOR_DATA);
  PlotIndexSetInteger(0, PLOT_ARROW, 233);
  PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 10);
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, InArrowUpClr);

  SetIndexBuffer(1, InArrowDn, INDICATOR_DATA);
  PlotIndexSetInteger(1, PLOT_ARROW, 234);
  PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
  PlotIndexSetInteger(1, PLOT_LINE_COLOR, InArrowDnClr);

  if (!InArrowsOn) {
    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
    PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
  }

  SetIndexBuffer(2, OutArrowUp, INDICATOR_DATA);
  PlotIndexSetInteger(2, PLOT_ARROW, 233);
  PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 10);
  PlotIndexSetInteger(2, PLOT_LINE_COLOR, OutArrowUpClr);

  SetIndexBuffer(3, OutArrowDn, INDICATOR_DATA);
  PlotIndexSetInteger(3, PLOT_ARROW, 234);
  PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, -10);
  PlotIndexSetInteger(3, PLOT_LINE_COLOR, OutArrowDnClr);

  if (!OutArrowsOn) {
    PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
    PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
  }

  return (INIT_SUCCEEDED);
}

// NOTE: OnCalculate
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
  int i, start;

  start = 1;
  if (prev_calculated > 1) start = prev_calculated - 1;
  for (i = start; i < rates_total && !IsStopped(); i++) {
    InArrowUp[i]  = 0;
    InArrowDn[i]  = 0;
    OutArrowUp[i] = 0;
    OutArrowDn[i] = 0;

    if (haveInsideSignalUp(i)) {
      InArrowUp[i - 1] = low[i - 1];

      if (newCandle.IsNewCandle()) { Notifications(0); }
    }

    if (haveInsideSignalDown(i)) {
      InArrowDn[i - 1] = high[i - 1];

      if (newCandle.IsNewCandle()) { Notifications(1); }
    }

    if (OutsideSignalUp(i)) {
      OutArrowUp[i - 1] = low[i - 1];

      if (newCandle.IsNewCandle()) { Notifications(0); }
    }

    if (OutsideSignalDown(i)) {
      OutArrowDn[i - 1] = high[i - 1];

      if (newCandle.IsNewCandle()) { Notifications(1); }
    }
  }

  return (rates_total);
}
//+------------------------------------------------------------------+

bool haveInsideSignalUp(int i)
{
  int    shift  = iBars(_Symbol, Period()) - i;
  double close0 = iClose(_Symbol, Period(), shift);
  double close1 = iClose(_Symbol, Period(), shift - 1);
  double close2 = iClose(_Symbol, Period(), shift - 2);
  double open0  = iOpen(_Symbol, Period(), shift);
  double high0  = iHigh(_Symbol, Period(), shift);
  double high1  = iHigh(_Symbol, Period(), shift - 1);
  double low0   = iLow(_Symbol, Period(), shift);
  double low1   = iLow(_Symbol, Period(), shift - 1);
  return close0 < open0 && high1 <= high0 && low1 >= low0 && close2 > high1;
}

bool haveInsideSignalDown(int i)
{
  int    shift  = iBars(_Symbol, Period()) - i;
  double close0 = iClose(_Symbol, Period(), shift);
  double close1 = iClose(_Symbol, Period(), shift - 1);
  double close2 = iClose(_Symbol, Period(), shift - 2);
  double open0  = iOpen(_Symbol, Period(), shift);
  double high0  = iHigh(_Symbol, Period(), shift);
  double high1  = iHigh(_Symbol, Period(), shift - 1);
  double low0   = iLow(_Symbol, Period(), shift);
  double low1   = iLow(_Symbol, Period(), shift - 1);
  return close0 > open0 && high1 <= high0 && low1 >= low0 && close2 < low1;
}

bool OutsideSignalUp(int i)
{
  int    shift  = iBars(_Symbol, Period()) - i;
  double close0 = iClose(_Symbol, Period(), shift);
  double close1 = iClose(_Symbol, Period(), shift - 1);
  double close2 = iClose(_Symbol, Period(), shift - 2);
  double open0  = iOpen(_Symbol, Period(), shift);
  double high0  = iHigh(_Symbol, Period(), shift);
  double high1  = iHigh(_Symbol, Period(), shift - 1);
  double low0   = iLow(_Symbol, Period(), shift);
  double low1   = iLow(_Symbol, Period(), shift - 1);
  return close0 < open0 && high1 <= high0 && low1 >= low0 && close2 > high1;
}
bool OutsideSignalDown(int i)
{
  int    shift  = iBars(_Symbol, Period()) - i;
  double close0 = iClose(_Symbol, Period(), shift);
  double close1 = iClose(_Symbol, Period(), shift - 1);
  double close2 = iClose(_Symbol, Period(), shift - 2);
  double low0   = iLow(_Symbol, Period(), shift);
  double low1   = iLow(_Symbol, Period(), shift - 1);
  double open0  = iOpen(_Symbol, Period(), shift);
  return close0 > open0 && close1 < low0 && close2 < low1;
}

void Notifications(int type)
{
  string text = "";
  if (type == 0)
    text += _Symbol + " " + GetTimeFrame(_Period) + " Signal UP ";
  else
    text += _Symbol + " " + GetTimeFrame(_Period) + " Signal DOWN ";

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
  switch (lPeriod) {
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
