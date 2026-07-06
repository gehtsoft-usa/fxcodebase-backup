// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73392

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
#property indicator_buffers 12
#property indicator_plots 12
#property indicator_label1 "Line ema1"
#property indicator_label2 "Line ema2"
#property indicator_label3 "Line ema3"
#property indicator_label4 "Line ema4"
#property indicator_label5 "Line ema5"
#property indicator_label6 "Line ema6"
#property indicator_label7 "Line ema7"
#property indicator_label8 "Line ema8"
#property indicator_label9 "Line ema9"
#property indicator_label10 "Line ema10"
#property indicator_label11 "fill1"
#property indicator_label12 "fill2"

//--- indicator buffers
double LineEma1[];
double LineEma2[];
double LineEma3[];
double LineEma4[];
double LineEma5[];
double LineEma6[];
double LineEma7[];
double LineEma8[];
double LineEma9[];
double LineEma10[];

double fill1[];
double fill2[];

// ------------------------------------------------------------------
int                periods               = 200;                               // Periods:
ENUM_TIMEFRAMES          TFSup                 = PERIOD_H4;                        // Superior Time Frame:

input string             tma1                  = "== Moving Average 1 Setup ==";   // ————————————
input int                ma1Period             = 10;                               // Period
input ENUM_TIMEFRAMES    ma1tf                 = PERIOD_H4;                        // Time Frame:
int                      ma1Shift              = 0;                                // Ma Shift
input ENUM_MA_METHOD     ma1Method             = MODE_EMA;                         // Method
input ENUM_APPLIED_PRICE ma1AppliedPrice       = PRICE_CLOSE;                      // Applied Price
input string             tma2                  = "== Moving Average 2 Setup ==";   // ————————————
input int                ma2Period             = 20;                               // Period
input ENUM_TIMEFRAMES    ma2tf                 = PERIOD_H4;                        // Time Frame:
int                      ma2Shift              = 0;                                // Ma Shift
input ENUM_MA_METHOD     ma2Method             = MODE_EMA;                         // Method
input ENUM_APPLIED_PRICE ma2AppliedPrice       = PRICE_CLOSE;                      // Applied Price
input string             tma3                  = "== Moving Average 3 Setup ==";   // ————————————
input int                ma3Period             = 30;                               // Period
input ENUM_TIMEFRAMES    ma3tf                 = PERIOD_H4;                        // Time Frame:
int                      ma3Shift              = 0;                                // Ma Shift
input ENUM_MA_METHOD     ma3Method             = MODE_EMA;                         // Method
input ENUM_APPLIED_PRICE ma3AppliedPrice       = PRICE_CLOSE;                      // Applied Price
input string             tma4                  = "== Moving Average 4 Setup ==";   // ————————————
input int                ma4Period             = 40;                               // Period
input ENUM_TIMEFRAMES    ma4tf                 = PERIOD_H4;                        // Time Frame:
int                      ma4Shift              = 0;                                // Ma Shift
input ENUM_MA_METHOD     ma4Method             = MODE_EMA;                         // Method
input ENUM_APPLIED_PRICE ma4AppliedPrice       = PRICE_CLOSE;                      // Applied Price
input string             tma5                  = "== Moving Average 5 Setup ==";   // ————————————
input int                ma5Period             = 50;                               // Period
input ENUM_TIMEFRAMES    ma5tf                 = PERIOD_H4;                        // Time Frame:
int                      ma5Shift              = 0;                                // Ma Shift
input ENUM_MA_METHOD     ma5Method             = MODE_EMA;                         // Method
input ENUM_APPLIED_PRICE ma5AppliedPrice       = PRICE_CLOSE;                      // Applied Price
input string             tma6                  = "== Moving Average 6 Setup ==";   // ————————————
input int                ma6Period             = 60;                               // Period
input ENUM_TIMEFRAMES    ma6tf                 = PERIOD_H4;                        // Time Frame:
int                      ma6Shift              = 0;                                // Ma Shift
input ENUM_MA_METHOD     ma6Method             = MODE_EMA;                         // Method
input ENUM_APPLIED_PRICE ma6AppliedPrice       = PRICE_CLOSE;                      // Applied Price
input string             tma7                  = "== Moving Average 7 Setup ==";   // ————————————
input int                ma7Period             = 70;                               // Period
input ENUM_TIMEFRAMES    ma7tf                 = PERIOD_H4;                        // Time Frame:
int                      ma7Shift              = 0;                                // Ma Shift
input ENUM_MA_METHOD     ma7Method             = MODE_EMA;                         // Method
input ENUM_APPLIED_PRICE ma7AppliedPrice       = PRICE_CLOSE;                      // Applied Price
input string             tma8                  = "== Moving Average 8 Setup ==";   // ————————————
input int                ma8Period             = 80;                               // Period
input ENUM_TIMEFRAMES    ma8tf                 = PERIOD_H4;                        // Time Frame:
int                      ma8Shift              = 0;                                // Ma Shift
input ENUM_MA_METHOD     ma8Method             = MODE_EMA;                         // Method
input ENUM_APPLIED_PRICE ma8AppliedPrice       = PRICE_CLOSE;                      // Applied Price
input string             tma9                  = "== Moving Average 9 Setup ==";   // ————————————
input int                ma9Period             = 90;                               // Period
input ENUM_TIMEFRAMES    ma9tf                 = PERIOD_H4;                        // Time Frame:
int                      ma9Shift              = 0;                                // Ma Shift
input ENUM_MA_METHOD     ma9Method             = MODE_EMA;                         // Method
input ENUM_APPLIED_PRICE ma9AppliedPrice       = PRICE_CLOSE;                      // Applied Price
input string             tma10                 = "== Moving Average 10 Setup ==";  // ————————————
input int                ma10Period            = 100;                              // Period
input ENUM_TIMEFRAMES    ma10tf                = PERIOD_H4;                        // Time Frame:
int                      ma10Shift             = 0;                                // Ma Shift
input ENUM_MA_METHOD     ma10Method            = MODE_EMA;                         // Method
input ENUM_APPLIED_PRICE ma10AppliedPrice      = PRICE_CLOSE;                      // Applied Price
input string             T1                    = "== Notifications ==";            // ————————————
input bool               notifications         = false;                            // Notifications On?
input bool               desktop_notifications = false;                            // Desktop MT4 Notifications
input bool               email_notifications   = false;                            // Email Notifications
input bool               push_notifications    = false;                            // Push Mobile Notifications
input string             T2                    = "== Set Lines ==";                // ————————————
input color              ema1Clr               = DeepPink;                         // Color:
input color              ema2Clr               = Cyan;                             // Color:
input color              ema3Clr               = Orange;                           // Color:
input color              ema4Clr               = Violet;                           // Color:
input color              ema5Clr               = Green;                            // Color:
input color              ema6Clr               = Yellow;                           // Color:
input color              ema7Clr               = Red;                              // Color:
input color              ema8Clr               = DodgerBlue;                       // Color:
input color              ema9Clr               = Lime;                             // Color:
input color              ema10Clr              = Silver;                           // Color:
input string             T3                    = "== Set Fill ==";                 // ————————————
input bool               fill_on               = true;                             // Fill On
input int                fill_ema1             = 1;                                // Fill Ema1:
input int                fill_ema2             = 4;                                // Fill Ema2:
input ENUM_LINE_STYLE    fill_style            = STYLE_DOT;                        // Line Style:
input int                fill_width            = 1;                                // Width:
input color              fill_clr              = Blue;                             // Fill Color:

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
CNewCandle      newCandle();
ENUM_TIMEFRAMES tf;

class MovingAverage
{
  string _symbol;
  int    _tf;

  struct MovingAverageParameters
  {
    int setup0;  //  Period
    int setup1;  //  Ma Shift
    int setup2;  //  Method
    int setup3;  //  Applied Price
  };
  MovingAverageParameters _setup;

 public:
  MovingAverage()
  {
    _symbol = _Symbol;
    _tf     = Period();
  }
  MovingAverage(string Symbol, int TimeFrame)
  {
    _symbol = Symbol;
    _tf     = TimeFrame;
  }
  MovingAverage(string Symbol, int TimeFrame, int period, int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE appliedPrice)
  {
    _symbol = Symbol;
    _tf     = TimeFrame;
    setSetup(period, shift, method, appliedPrice);
  }
  ~MovingAverage() { ; }

  void Set_Symbol_TF(string Symbol, int TimeFrame = 0)
  {
    _symbol = Symbol;
    _tf     = TimeFrame;
  }

	ENUM_TIMEFRAMES tf() { return _tf; }

  void setSetup(
      int set0,
      int set1,
      int set2,
      int set3)
  {
    _setup.setup0 = set0;
    _setup.setup1 = set1;
    _setup.setup2 = set2;
    _setup.setup3 = set3;
  }

  double calculate(int buffer, int shift)
  {
    return iMA(_symbol, _tf,
               _setup.setup0,
               _setup.setup1,
               _setup.setup2,
               _setup.setup3,
               shift);
  }

  double index(int shift)
  {
    return calculate(0, shift);
  }
};
MovingAverage* emas[10];

// ------------------------------------------------------------------
int OnInit()
{
  tf = validateTimeFrame(TFSup);

  for (int i = 0; i < ArraySize(emas); i++)
  {
    emas[i] = new MovingAverage();
  }

  emas[0].Set_Symbol_TF(NULL, validateTimeFrame(ma1tf));
  emas[1].Set_Symbol_TF(NULL, validateTimeFrame(ma2tf));
  emas[2].Set_Symbol_TF(NULL, validateTimeFrame(ma3tf));
  emas[3].Set_Symbol_TF(NULL, validateTimeFrame(ma4tf));
  emas[4].Set_Symbol_TF(NULL, validateTimeFrame(ma5tf));
  emas[5].Set_Symbol_TF(NULL, validateTimeFrame(ma6tf));
  emas[6].Set_Symbol_TF(NULL, validateTimeFrame(ma7tf));
  emas[7].Set_Symbol_TF(NULL, validateTimeFrame(ma8tf));
  emas[8].Set_Symbol_TF(NULL, validateTimeFrame(ma9tf));
  emas[9].Set_Symbol_TF(NULL, validateTimeFrame(ma10tf));

  emas[0].setSetup(ma1Period, ma1Shift, ma1Method, ma1AppliedPrice);
  emas[1].setSetup(ma2Period, ma2Shift, ma2Method, ma2AppliedPrice);
  emas[2].setSetup(ma3Period, ma3Shift, ma3Method, ma3AppliedPrice);
  emas[3].setSetup(ma4Period, ma4Shift, ma4Method, ma4AppliedPrice);
  emas[4].setSetup(ma5Period, ma5Shift, ma5Method, ma5AppliedPrice);
  emas[5].setSetup(ma6Period, ma6Shift, ma6Method, ma6AppliedPrice);
  emas[6].setSetup(ma7Period, ma7Shift, ma7Method, ma7AppliedPrice);
  emas[7].setSetup(ma8Period, ma8Shift, ma8Method, ma8AppliedPrice);
  emas[8].setSetup(ma9Period, ma9Shift, ma9Method, ma9AppliedPrice);
  emas[9].setSetup(ma10Period, ma10Shift, ma10Method, ma10AppliedPrice);

  //--- indicator buffers mapping
  SetIndexBuffer(0, LineEma1, INDICATOR_DATA);
  SetIndexBuffer(1, LineEma2, INDICATOR_DATA);
  SetIndexBuffer(2, LineEma3, INDICATOR_DATA);
  SetIndexBuffer(3, LineEma4, INDICATOR_DATA);
  SetIndexBuffer(4, LineEma5, INDICATOR_DATA);
  SetIndexBuffer(5, LineEma6, INDICATOR_DATA);
  SetIndexBuffer(6, LineEma7, INDICATOR_DATA);
  SetIndexBuffer(7, LineEma8, INDICATOR_DATA);
  SetIndexBuffer(8, LineEma9, INDICATOR_DATA);
  SetIndexBuffer(9, LineEma10, INDICATOR_DATA);
  SetIndexStyle(0, DRAW_LINE, EMPTY, 1, ema1Clr);
  SetIndexStyle(1, DRAW_LINE, EMPTY, 1, ema2Clr);
  SetIndexStyle(2, DRAW_LINE, EMPTY, 1, ema3Clr);
  SetIndexStyle(3, DRAW_LINE, EMPTY, 1, ema4Clr);
  SetIndexStyle(4, DRAW_LINE, EMPTY, 1, ema5Clr);
  SetIndexStyle(5, DRAW_LINE, EMPTY, 1, ema6Clr);
  SetIndexStyle(6, DRAW_LINE, EMPTY, 1, ema7Clr);
  SetIndexStyle(7, DRAW_LINE, EMPTY, 1, ema8Clr);
  SetIndexStyle(8, DRAW_LINE, EMPTY, 1, ema9Clr);
  SetIndexStyle(9, DRAW_LINE, EMPTY, 1, ema10Clr);

  SetIndexBuffer(10, fill1, INDICATOR_DATA);
  SetIndexBuffer(11, fill2, INDICATOR_DATA);
  SetIndexStyle(10, DRAW_HISTOGRAM, fill_style, fill_width, fill_clr);
  SetIndexStyle(11, DRAW_HISTOGRAM, fill_style, fill_width, fill_clr);

  //---
  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
  for (int i = 0; i < ArraySize(emas); i++)
  {
    delete emas[i];
  }
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
  int start, i, isup;
  if (prev_calculated == 0)
  {
    start = rates_total - periods;
  } else
  {
    start = rates_total - (prev_calculated - 1);
  }

  for (i = start; i >= 0; i--)
  {
    isup = iBarShift(NULL, TFSup, time[i], false);

    // NOTE: Draw emas:		
    LineEma1[i]  = emas[0].index(isup(i, ma1tf));
    LineEma2[i]  = emas[1].index(isup(i, ma2tf));
    LineEma3[i]  = emas[2].index(isup(i, ma3tf));
    LineEma4[i]  = emas[3].index(isup(i, ma4tf));
    LineEma5[i]  = emas[4].index(isup(i, ma5tf));
    LineEma6[i]  = emas[5].index(isup(i, ma6tf));
    LineEma7[i]  = emas[6].index(isup(i, ma7tf));
    LineEma8[i]  = emas[7].index(isup(i, ma8tf));
    LineEma9[i]  = emas[8].index(isup(i, ma9tf));
    LineEma10[i] = emas[9].index(isup(i, ma10tf));

	if(fill_on)
	{
    int pos1 = validateEmaNumber(fill_ema1) - 1;
    int pos2 = validateEmaNumber(fill_ema2) - 1;
    fill1[i] = emas[pos1].index(isup(i, emas[pos1].tf()));
    fill2[i] = emas[pos2].index(isup(i, emas[pos2].tf()));
	}

    if (haveSignalUp(isup))
    {
      // double sum;
      // for (int j = 0; j < periods; j++)
      // {
      //   sum += iLow(NULL, tf, isup);
      // }

      // LineUp[i] = sum / periods;

      if (newCandle.IsNewCandle())
      {
        Notifications(0);
      }
    }

    if (haveSignalDown(isup))
    {
      double sum;
      for (int j = 0; j < periods; j++)
      {
        sum += iHigh(NULL, tf, isup);
      }

      // LineDn[i] = sum / periods;

      if (newCandle.IsNewCandle())
      {
        Notifications(1);
      }
    }
  }
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

ENUM_TIMEFRAMES validateTimeFrame(ENUM_TIMEFRAMES suptf)
{
  ENUM_TIMEFRAMES _tf = suptf <= Period() ? Period() : suptf;
  return _tf;
}

int isup(int i, ENUM_TIMEFRAMES tfsup)
{
  return iBarShift(NULL, tfsup, iTime(NULL, 0, i), false);
}


int validateEmaNumber(int _n)
{
  int n = 1;
  if (_n >= 1) n = _n > 9 ? 9 : _n;

  return n;
}

// ------------------------------------------------------------------

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