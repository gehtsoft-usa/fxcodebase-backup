// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74828

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
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
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
//--- indicator buffers
double ArrowUp[];
double ArrowDn[];

// NOTE: Inputs
// ------------------------------------------------------------------
input string T0         = "== set Arrows ==";  // set Arrows
input bool   ArrowsOn   = true;                // Arrows On?
input color  ArrowUpClr = clrBlue;             // Arrow Up Color:
input color  ArrowDnClr = clrRed;              // Arrow Down Color:

string ICustom        = "== Ichimoku Setup ==";  // == Ichimoku Setup ==
int    uTenkan_sen    = 9;                       // period of Tenkan-sen line
int    uKijun_sen     = 26;                      // period of Kijun-sen line
int    uSenkou_span_b = 52;                      // period of Senkou Span B line

class Ichimoku
{
  string          _symbol;         // symbol
  ENUM_TIMEFRAMES _tf;             // timeframe
  int             _tenkan_sen;     // period of Tenkan-sen line
  int             _kijun_sen;      // period of Kijun-sen line
  int             _senkou_span_b;  // period of Senkou Span B line
  int             _handle;

 public:
  Ichimoku()
  {
    _symbol = _Symbol;
    _tf     = Period();
  }
  Ichimoku(string Symbol, ENUM_TIMEFRAMES TimeFrame)
  {
    _symbol = Symbol;
    _tf     = TimeFrame;
  }
  ~Ichimoku() { ; }

  void setHandle()
  {
    _handle = iIchimoku(_symbol, _tf, _tenkan_sen, _kijun_sen, _senkou_span_b);
  }
  void set(int inpTenkan_sen, int inpKijun_sen, int inpSenkou_span_b)
  {
    _tenkan_sen    = inpTenkan_sen;
    _kijun_sen     = inpKijun_sen;
    _senkou_span_b = inpSenkou_span_b;
    setHandle();
  }

  // clang-format off
  
  double calculate(int shift, int buffer = 0)
  {
	 double value[1];
        int copy = CopyBuffer(_handle,buffer,shift,1,value);
        if(copy>0) { return value[0]; } 
	 return -1;
  }
  double index(int i, int buffer = 0)
  {
   int    shift = iBars(_Symbol, Period()) - i;
	 double value[1];
        int copy = CopyBuffer(_handle,buffer,shift,1,value);
        if(copy>0) { return value[0]; } 
	 return -1;
  }
	
  double Tenkansen(int i)   { return index(i, 0); }
  double Kijunsen(int i)    { return index(i, 1); }
  double SenkouSpanA(int i) { return index(i, 2); }
  double SenkouSpanB(int i) { return index(i, 3); }
  double ChikouSpan(int i)  { return index(i, 4); }

  // clang-format on
};
Ichimoku ichimoku;

string             Iema               = "== Moving Average Setup ==";  // == Moving Average Setup ==
int                maFastPeriod       = 50;                            // Period
int                      maFastShift        = 0;                             // Ma Shift
ENUM_MA_METHOD     maFastMethod       = MODE_EMA;                      // Method
ENUM_APPLIED_PRICE maFastAppliedPrice = PRICE_CLOSE;                   // Applied Price
int                maSlowPeriod       = 100;                           // Period
int                      maSlowShift        = 0;                             // Ma Shift
ENUM_MA_METHOD     maSlowMethod       = MODE_EMA;                      // Method
ENUM_APPLIED_PRICE maSlowAppliedPrice = PRICE_CLOSE;                   // Applied Price

class MovingAverage
{
  int _handle;

 public:
  MovingAverage() { ; }
  ~MovingAverage() { ; }

  void set(string Symbol, ENUM_TIMEFRAMES TimeFrame, int Periods, int Shift, ENUM_MA_METHOD Method, ENUM_APPLIED_PRICE AppliedPrice)
  {
    _handle = iMA(Symbol, TimeFrame, Periods, Shift, Method, AppliedPrice);
  }

  double shift(int shift)
  {
    double value[1];
    int    copy = CopyBuffer(_handle, 0, shift, 1, value);
    if (copy > 0) {
      return value[0];
    }
    return -1;
  }
  double index(int i)
  {
    int    shift = iBars(_Symbol, Period()) - i;
    double value[1];
    int    copy = CopyBuffer(_handle, 0, shift, 1, value);
    if (copy > 0) {
      return value[0];
    }
    return -1;
  }
};
MovingAverage maFast;
MovingAverage maSlow;

string             tbb           = "== BBands Setup ==";  // == BBands Setup ==
int                bbPeriods     = 200;                    // Periods:
int                bbDesviation  = 2;                     // Desviation:
ENUM_APPLIED_PRICE bbApliedPrice = PRICE_CLOSE;           // Applied price:

class BBands
{
  int _handle;

 public:
  BBands() { ; }
  ~BBands() { ; }

  void set(string Symbol = NULL, ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT, int Periods = 20, int Desviation = 2, ENUM_APPLIED_PRICE Applied_price = PRICE_CLOSE)
  {
    _handle = iBands(Symbol, TimeFrame, Periods, 0, Desviation, Applied_price);
  }

  double calculate(int buffer, int shift)
  {
    double value[1];
    int    copy = CopyBuffer(_handle, buffer, shift, 1, value);
    if (copy > 0) { return value[0]; }
    //---
    return -1;
  }
  double index(int buffer, int i)
  {
    int    shift = iBars(_Symbol, Period()) - i;
    double value[1];
    int    copy = CopyBuffer(_handle, buffer, shift, 1, value);
    if (copy > 0) { return value[0]; }
    //---
    return -1;
  }

  double Upper(int i) { return index(1, i); }
  double Lower(int i) { return index(2, i); }
  double Midle(int i) { return index(0, i); }
};
BBands bands;

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

  ichimoku.set(uTenkan_sen, uKijun_sen, uSenkou_span_b);
  maFast.set(_Symbol, _Period, maFastPeriod, maFastShift, maFastMethod, maFastAppliedPrice);
  maSlow.set(_Symbol, _Period, maSlowPeriod, maSlowShift, maSlowMethod, maSlowAppliedPrice);
  bands.set(_Symbol, _Period, bbPeriods, bbDesviation, bbApliedPrice);

  return (INIT_SUCCEEDED);
}

string next = "buy";

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
    if (next == "buy")
      if (maFast.index(i) > maSlow.index(i) &&
          ichimoku.SenkouSpanA(i) > ichimoku.SenkouSpanB(i) &&
          close[i] > ichimoku.SenkouSpanA(i)) {
        if (close[i] >= bands.Midle(i)) {
          ArrowUp[i] = low[i];
          next       = "sell";
          if (newCandle.IsNewCandle()) Notifications(0);
        }
      }

    if (next == "sell")
      if (maFast.index(i) < maSlow.index(i) &&
          ichimoku.SenkouSpanA(i) < ichimoku.SenkouSpanB(i) &&
          close[i] < ichimoku.SenkouSpanA(i)) {
        if (close[i] <= bands.Midle(i)) {
          ArrowDn[i] = high[i];
          next       = "buy";
          if (newCandle.IsNewCandle()) Notifications(1);
        }
      }
  }

  return (rates_total);
}
//+------------------------------------------------------------------+

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