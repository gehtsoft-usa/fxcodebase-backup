// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=153922#p153922

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window

#property indicator_buffers 7
#property indicator_plots 7
#property indicator_label1 "Ma Fast"
#property indicator_type1  DRAW_LINE
#property indicator_color1 Crimson
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Ma Medium"
#property indicator_type2  DRAW_LINE
#property indicator_color2 Blue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Ma Slow"
#property indicator_type3  DRAW_LINE
#property indicator_color3 Green
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

#property indicator_label4 "Signal Up"
#property indicator_type4  DRAW_ARROW
#property indicator_color4 clrBlue
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label5 "Signal Down"
#property indicator_type5  DRAW_ARROW
#property indicator_color5 clrRed
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1

#property indicator_label6 "Pinbar Up"
#property indicator_type6  DRAW_ARROW
#property indicator_color6 clrBlue
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Pinbar Down"
#property indicator_type7  DRAW_ARROW
#property indicator_color7 clrRed
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1

// NOTE: Inputs
// ------------------------------------------------------------------
#define MOVING_AVERAGE_ON
#ifdef MOVING_AVERAGE_ON
input string             Iema1                 = "== Moving Average Fast Setup ==";    // == Moving Average Setup ==
input int                maFast_Period         = 10;                                   // Period
input ENUM_MA_METHOD     maFast_Method         = MODE_EMA;                             // Method
input ENUM_APPLIED_PRICE maFast_AppliedPrice   = PRICE_CLOSE;                          // Applied Price
input string             Iema2                 = "== Moving Average Medium Setup ==";  // == Moving Average Setup ==
input int                maMedium_Period       = 20;                                   // Period
input ENUM_MA_METHOD     maMedium_Method       = MODE_EMA;                             // Method
input ENUM_APPLIED_PRICE maMedium_AppliedPrice = PRICE_CLOSE;                          // Applied Price
input string             Iema3                 = "== Moving Average Slow Setup ==";    // == Moving Average Setup ==
input int                maSlow_Period         = 50;                                   // Period
input ENUM_MA_METHOD     maSlow_Method         = MODE_EMA;                             // Method
input ENUM_APPLIED_PRICE maSlow_AppliedPrice   = PRICE_CLOSE;                          // Applied Price
int                      maFast_Shift          = 0;                                    // Ma Shift
int                      maMedium_Shift        = 0;                                    // Ma Shift
int                      maSlow_Shift          = 0;                                    // Ma Shift

class MovingAverage
{
  string          _symbol;
  ENUM_TIMEFRAMES _tf;
  int             _handle;

  struct MovingAverageParameters {
    int                setup0;  //  Period
    int                setup1;  //  Ma Shift
    ENUM_MA_METHOD     setup2;  //  Method
    ENUM_APPLIED_PRICE setup3;  //  Applied Price
  };
  MovingAverageParameters _setup;

 public:
  MovingAverage()
  {
    _symbol = _Symbol;
    _tf     = Period();
  }
  MovingAverage(string Symbol, ENUM_TIMEFRAMES TimeFrame)
  {
    _symbol = Symbol;
    _tf     = TimeFrame;
  }
  ~MovingAverage() { ; }

  void setHandle()
  {
    _handle = iMA(_symbol, _tf,
                  _setup.setup0,
                  _setup.setup1,
                  _setup.setup2,
                  _setup.setup3);
  }

  void setSetup(int set0, int set1, ENUM_MA_METHOD set2, ENUM_APPLIED_PRICE set3)
  {
    _setup.setup0 = set0;
    _setup.setup1 = set1;
    _setup.setup2 = set2;
    _setup.setup3 = set3;
    setHandle();
  }

  double calculate(int buffer, int shift)
  {
    int    sh = Bars(Symbol(), Period()) - shift;
    double value[1];
    int    copy = CopyBuffer(_handle, buffer, sh, 1, value);
    if (copy > 0) {
      return value[0];
    }
    return -1;
  }

  double index(int shift)
  {
    return calculate(0, shift);
  }
};
MovingAverage* emaFast;
MovingAverage* emaMedium;
MovingAverage* emaSlow;
#endif

input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications

// NOTE: Buffers
//--- indicator buffers

double lineFast[];
double lineMed[];
double lineSlow[];

double SignalUp[];
double SignalDn[];
double PinbarUp[];
double PinbarDn[];

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

class Pinbar
{
  string          _symbol;  // symbol
  ENUM_TIMEFRAMES _tf;      // timeframe

 public:
  Pinbar(string Symbol, ENUM_TIMEFRAMES TF)
  {
    _symbol = Symbol;
    _tf     = TF;
  }
  ~Pinbar() { ; }

  double AverageSizeCandles(int pos)
  {
    double SumSize = 0;
    int    length  = 100;
    for (int i = pos; i >= pos - length; i--) {
      double hi, lo, cl, op;
      hi = iHigh(_symbol, _tf, i);
      lo = iLow(_symbol, _tf, i);

      SumSize += fabs(hi - lo);
    }
    return SumSize / length;
  }

  string FindPattern(int pos)
  {
    string direction;
    string candle;

    if (pos - 1 > 0)
      for (int i = pos - 1; i >= pos - 1; i--) {
        bool   havePinbar = false;
        double hi, lo, cl, op;

        int _i = Bars(Symbol(), Period()) - i;

        hi = iHigh(_symbol, _tf, _i);
        lo = iLow(_symbol, _tf, _i);
        op = iOpen(_symbol, _tf, _i);
        cl = iClose(_symbol, _tf, _i);

        // check patrón alcista:
        double body  = fabs(op - cl);
        double size  = fabs(hi - lo);
        double ratio = 0;

        if (size > 0) ratio = body / size;
        Print(__FUNCTION__, " ratio: ", ratio);

        // Tengo ratio
        if (ratio < 0.30) {
          double position = 0;  //(op - lo) / size;
          if (size > 0) {
            position = (op - lo) / size;
            Print(__FUNCTION__, " position: ", position);
          }

          if (size > AverageSizeCandles(pos)) {
            if (position < 0.30) {
              direction  = "q";
              havePinbar = true;
            }
            if (position > 0.60) {
              direction  = "p";
              havePinbar = true;
            }
          }
        }

        if (havePinbar) {
          candle = i < 10 ? "0" + (string)i : (string)i;
          return direction;
          // return candle + direction;
        }
      }

    return "000";
  }
};
Pinbar* pinbar;

// ------------------------------------------------------------------
// NOTE: oninit
void OnInit()
{
  //--- indicator short name
  SetIndexBuffer(0, lineFast);
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, maSlow_Period);
  SetIndexBuffer(1, lineMed);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, maSlow_Period);
  SetIndexBuffer(2, lineSlow);
  PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, maSlow_Period);

  SetIndexBuffer(3, SignalUp, INDICATOR_DATA);
  PlotIndexSetInteger(3, PLOT_ARROW, 233);
  PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, 10);
  PlotIndexSetInteger(3, PLOT_LINE_COLOR, Blue);

  SetIndexBuffer(4, SignalDn, INDICATOR_DATA);
  PlotIndexSetInteger(4, PLOT_ARROW, 234);
  PlotIndexSetInteger(4, PLOT_ARROW_SHIFT, -10);
  PlotIndexSetInteger(4, PLOT_LINE_COLOR, Red);

  SetIndexBuffer(5, PinbarUp, INDICATOR_DATA);
  PlotIndexSetInteger(5, PLOT_ARROW, 159);
  PlotIndexSetInteger(5, PLOT_ARROW_SHIFT, 10);
  PlotIndexSetInteger(5, PLOT_LINE_COLOR, Blue);

  SetIndexBuffer(6, PinbarDn, INDICATOR_DATA);
  PlotIndexSetInteger(6, PLOT_ARROW, 159);
  PlotIndexSetInteger(6, PLOT_ARROW_SHIFT, -10);
  PlotIndexSetInteger(6, PLOT_LINE_COLOR, Red);

#ifdef MOVING_AVERAGE_ON
  emaFast   = new MovingAverage(_Symbol, Period());
  emaMedium = new MovingAverage(_Symbol, Period());
  emaSlow   = new MovingAverage(_Symbol, Period());
  emaFast.setSetup(maFast_Period, maFast_Shift, maFast_Method, maFast_AppliedPrice);
  emaMedium.setSetup(maMedium_Period, maMedium_Shift, maMedium_Method, maMedium_AppliedPrice);
  emaSlow.setSetup(maSlow_Period, maSlow_Shift, maSlow_Method, maSlow_AppliedPrice);
#endif

  pinbar = new Pinbar(Symbol(), PERIOD_CURRENT);
}

void OnDeinit(const int reason)
{
#ifdef MOVING_AVERAGE_ON
  delete emaFast;
  delete emaMedium;
  delete emaSlow;
#endif
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

  int start;
  if (prev_calculated > 1)
    start = prev_calculated - 2;
  else {
    start = (int)Bars(Symbol(), Period()) / 2;
  }

  for (int i = start; i < rates_total && !IsStopped(); i++) {
    lineFast[i] = emaFast.index(i);
    lineMed[i]  = emaMedium.index(i);
    lineSlow[i] = emaSlow.index(i);

    SignalUp[i] = EMPTY_VALUE;
    SignalDn[i] = EMPTY_VALUE;

    if (havePinbarUp(i)) {
      if (lineFast[i - 1] > lineMed[i - 1] && lineMed[i - 1] > lineSlow[i - 1]) {
        SignalUp[i - 2] = low[i - 2];
        notify(0);
      }

      if (SignalUp[i - 2] == EMPTY_VALUE)
        PinbarUp[i - 2] = low[i - 2];
    }

    if (havePinbarDown(i)) {
      if (lineFast[i - 1] < lineMed[i - 1] && lineMed[i - 1] < lineSlow[i - 1]) {
        SignalDn[i - 2] = high[i - 2];
        notify(1);
      }
      if (SignalDn[i - 2] == EMPTY_VALUE)
        PinbarDn[i - 2] = high[i - 2];
    }
  }

  return (rates_total);
}
// ------------------------------------------------------------------

bool havePinbarUp(int i)
{
  return pinbar.FindPattern(i) == "p";
}
bool havePinbarDown(int i)
{
  return pinbar.FindPattern(i) == "q";
}

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

void notify(int type)
{
  if (newCandle.IsNewCandle()) {
    Notifications(type);
  }
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
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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