//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74702

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_separate_window

#property indicator_buffers 4
#property indicator_plots 3
#property indicator_label1 "Arrow Up"
#property indicator_type1 DRAW_ARROW
#property indicator_label2 "Arrow Down"
#property indicator_type2 DRAW_ARROW

#property indicator_type3  DRAW_COLOR_LINE
#property indicator_color3 Green, Crimson
#property indicator_style3 STYLE_SOLID
#property indicator_width3 2
#property indicator_label3 "LineColor"

// NOTE: Inputs
// ------------------------------------------------------------------
int          Period                = 10;                     // Indicator Periods
string       T0                    = "== Set Arrows ==";     // Set Arrows
bool         ArrowsOn              = true;                  // Arrows On?
color        ArrowUpClr            = C'60,120,60';                // Arrow Up Color:
color        ArrowDnClr            = C'120,60,60';                 // Arrow Down Color:
input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications

int param1 = 21;

// NOTE: Buffers
//--- indicator buffers
double ArrowUp[];
double ArrowDn[];
double line[];
double lineColor[];

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

// ------------------------------------------------------------------
void OnInit()
{
  //--- Buffers
  SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
  PlotIndexSetInteger(0, PLOT_ARROW, 233);
  PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 10);
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, ArrowUpClr);

  SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
  PlotIndexSetInteger(1, PLOT_ARROW, 234);
  PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
  PlotIndexSetInteger(1, PLOT_LINE_COLOR, ArrowDnClr);

  if (!ArrowsOn) {
    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
    PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
  }

  SetIndexBuffer(2, line, INDICATOR_DATA);
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, Period);
  SetIndexBuffer(3, lineColor, INDICATOR_COLOR_INDEX);

  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

  IndicatorSetInteger(INDICATOR_LEVELS, 1);
  IndicatorSetInteger(INDICATOR_LEVELSTYLE, STYLE_DOT);
  IndicatorSetInteger(INDICATOR_LEVELCOLOR, C'40,40,40');
  IndicatorSetDouble(INDICATOR_LEVELVALUE, 0.0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
  if (rates_total < param1) return (0);

  int    start;
  double mega  = 0;
  double Ld_60 = 0;
  double Ld_36 = 0;

  if (prev_calculated > 1)
    start = prev_calculated - 1;
  else {
    start = param1 + 1;
  }

  for (int i = start; i < rates_total && !IsStopped(); i++) {
    ArrowUp[i]=EMPTY_VALUE;
    ArrowDn[i]=EMPTY_VALUE;

    int    _i = iBars(NULL, 0) - i - 1;
    int    h  = iHighest(NULL, 0, MODE_HIGH, param1, _i);
    int    l  = iLowest(NULL, 0, MODE_LOW, param1, _i);
    double hi = iHigh(NULL, 0, h);
    double lo = iLow(NULL, 0, l);

    double barMiddle = (high[i] + low[i]) / 2.0;
    mega             = 0.66 * ((barMiddle - lo) / (hi - lo) - 0.5) + 0.67 * Ld_36;
    mega             = MathMin(MathMax(mega, -0.999), 0.999);
    line[i]          = MathLog((mega + 1.0) / (1 - mega)) / 2.0 + Ld_60 / 2.0;

    Ld_36 = mega;
    Ld_60 = line[i];

    lineColor[i] = line[i] >= 0 ? 0 : 1;

    if (line[i-1] > 0 && line[i - 2] <= 0) {
      ArrowUp[i-1] = line[i-1];
      if (newCandle.IsNewCandle()) { Notifications(0); }
    }

    if (line[i-1] < 0 && line[i - 2] >= 0) {
      ArrowDn[i - 1] = line[i - 1];      
      if (newCandle.IsNewCandle()) { Notifications(1); }
    }
  }

  return (rates_total);
}
// ------------------------------------------------------------------

bool haveSignalUp(int i)
{
  int shift = iBars(_Symbol, Period()) - i;
  if (iOpen(_Symbol, Period(), shift) < iClose(_Symbol, Period(), shift)) { return true; }

  return false;
}
bool haveSignalDown(int i)
{
  int shift = iBars(_Symbol, Period()) - i;
  if (iOpen(_Symbol, Period(), shift) > iClose(_Symbol, Period(), shift)) { return true; }

  return false;
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
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 