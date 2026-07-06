// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73262

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
#property indicator_buffers 3
#property indicator_plots 4
#property indicator_label1 "Line Up"
#property indicator_type1  DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_label2 "Line Down"
#property indicator_type2  DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_label3 "Line Center"
#property indicator_type3  DRAW_LINE
#property indicator_style3 STYLE_SOLID

//--- indicator buffers
double LineUp[];
double LineDn[];
double LineCenter[];

enum enMaTypes {
  ma_sma,    // Simple moving average
  ma_ema,    // Exponential moving average
  ma_smma,   // Smoothed MA
  ma_lwma,   // Linear weighted MA
  ma_slwma,  // Smoothed LWMA
  ma_dsema,  // Double Smoothed Exponential average
  ma_tema,   // Triple exponential moving average - TEMA
  ma_lsma,   // Linear regression value (lsma)
  ma_dema    // Double exponential moving average - DEMA
};

// ------------------------------------------------------------------
input string             T0                    = "== Setup ==";                 // ————————————
input ENUM_TIMEFRAMES    TFSup                 = PERIOD_CURRENT;                // Superior Time Frame:
input int                ATR_Period            = 18;                            // Atr Periods
input enMaTypes          AtrMaType             = ma_sma;                        // Atr averaging type
input double             m                     = 1.6;                           // Atr Multiplier:
input string             Iema                  = "== Moving Average Setup ==";  // == Moving Average Setup ==
input int                maPeriod              = 49;                            // Period
int                      maShift               = 0;                             // Ma Shift
input ENUM_MA_METHOD     maMethod              = MODE_EMA;                      // Method
input ENUM_APPLIED_PRICE maAppliedPrice        = PRICE_CLOSE;                   // Applied Price
input string             T1                    = "== Notifications ==";         // ————————————
input bool               notifications         = false;                         // Notifications On?
input bool               desktop_notifications = false;                         // Desktop MT4 Notifications
input bool               email_notifications   = false;                         // Email Notifications
input bool               push_notifications    = false;                         // Push Mobile Notifications
input string             T2                    = "== Set Lines ==";             // ————————————
input color              LineUpClr             = clrBlue;                       // Line Up Color:
input color              LineDnClr             = clrRed;                        // Line Down Color:
input color              LineCenterClr         = clrDimGray;                    // Line Center Color:
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

// ------------------------------------------------------------------
int OnInit()
{
  tf = TFSup <= Period() ? Period() : TFSup;

  //--- indicator buffers mapping
  SetIndexBuffer(0, LineUp, INDICATOR_DATA);
  SetIndexStyle(0, DRAW_LINE, EMPTY, 1, LineUpClr);
  SetIndexBuffer(1, LineDn, INDICATOR_DATA);
  SetIndexStyle(1, DRAW_LINE, EMPTY, 1, LineDnClr);
  SetIndexBuffer(2, LineCenter, INDICATOR_DATA);
  SetIndexStyle(2, DRAW_LINE, EMPTY, 2, LineCenterClr);

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
  int start, i, isup;
  if (prev_calculated == 0)
  {
    start = rates_total - ATR_Period;
  } else
  {
    start = rates_total - (prev_calculated - 1);
  }

  for (i = start; i >= 0; i--)
  {
    isup = iBarShift(NULL, tf, time[i], false);

    double tr     = (i < rates_total - 1) ? fmax(high[i], close[i + 1]) - fmin(low[i], close[i + 1]) : high[i] - low[i];
    double atr    = iCustomMa(AtrMaType, tr, ATR_Period, i, rates_total, 0) * m;
    double center = iMA(NULL, tf, maPeriod, 0, maMethod, maAppliedPrice, isup);

    LineCenter[i] = center;
    LineUp[i]     = center - atr;
    LineDn[i]     = center + atr;
  }
  return (rates_total);
}

// ------------------------------------------------------------------

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

// ------------------------------------------------------------------

// ------------------------------------------------------------------

#define _maInstances 2
#define _maWorkBufferx1 1 * _maInstances
#define _maWorkBufferx2 2 * _maInstances
#define _maWorkBufferx3 3 * _maInstances

double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo = 0)
{
  r = bars - r - 1;
  switch (mode)
  {
    case ma_sma: return (iSma(price, (int)MathCeil(length), r, bars, instanceNo));
    case ma_ema: return (iEma(price, length, r, bars, instanceNo));
    case ma_smma: return (iSmma(price, length, r, bars, instanceNo));
    case ma_lwma: return (iLwma(price, (int)MathCeil(length), r, bars, instanceNo));
    case ma_slwma: return (iSlwma(price, (int)MathCeil(length), r, bars, instanceNo));
    case ma_dsema: return (iDsema(price, length, r, bars, instanceNo));
    case ma_tema: return (iTema(price, length, r, bars, instanceNo));
    case ma_lsma: return (iLinr(price, (int)MathCeil(length), r, bars, instanceNo));
    case ma_dema: return (iDema(price, length, r, bars, instanceNo));
    default: return (price);
  }
}

//
//
//
//
//

double workSma[][_maWorkBufferx1];
double iSma(double price, int period, int r, int _bars, int instanceNo = 0)
{
  if (ArrayRange(workSma, 0) != _bars) ArrayResize(workSma, _bars);

  workSma[r][instanceNo + 0] = price;
  double avg                 = price;
  int    k                   = 1;
  for (; k < period && (r - k) >= 0; k++) avg += workSma[r - k][instanceNo + 0];
  return (avg / (double)k);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo = 0)
{
  if (ArrayRange(workEma, 0) != _bars) ArrayResize(workEma, _bars);

  workEma[r][instanceNo] = price;
  if (r > 0 && period > 1)
    workEma[r][instanceNo] = workEma[r - 1][instanceNo] + (2.0 / (1.0 + period)) * (price - workEma[r - 1][instanceNo]);
  return (workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo = 0)
{
  if (ArrayRange(workSmma, 0) != _bars) ArrayResize(workSmma, _bars);

  workSmma[r][instanceNo] = price;
  if (r > 1 && period > 1)
    workSmma[r][instanceNo] = workSmma[r - 1][instanceNo] + (price - workSmma[r - 1][instanceNo]) / period;
  return (workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo = 0)
{
  if (ArrayRange(workLwma, 0) != _bars) ArrayResize(workLwma, _bars);

  workLwma[r][instanceNo] = price;
  if (period <= 1) return (price);
  double sumw = period;
  double sum  = period * price;

  for (int k = 1; k < period && (r - k) >= 0; k++)
  {
    double weight = period - k;
    sumw += weight;
    sum += weight * workLwma[r - k][instanceNo];
  }
  return (sum / sumw);
}

//
//
//
//
//

double workSlwma[][_maWorkBufferx2];
double iSlwma(double price, double period, int r, int _bars, int instanceNo = 0)
{
  if (ArrayRange(workSlwma, 0) != _bars) ArrayResize(workSlwma, _bars);

  //
  //
  //
  //
  //

  int SqrtPeriod = (int)MathFloor(MathSqrt(period));
  instanceNo *= 2;
  workSlwma[r][instanceNo] = price;

  //
  //
  //
  //
  //

  double sumw = period;
  double sum  = period * price;

  for (int k = 1; k < period && (r - k) >= 0; k++)
  {
    double weight = period - k;
    sumw += weight;
    sum += weight * workSlwma[r - k][instanceNo];
  }
  workSlwma[r][instanceNo + 1] = (sum / sumw);

  //
  //
  //
  //
  //

  sumw = SqrtPeriod;
  sum  = SqrtPeriod * workSlwma[r][instanceNo + 1];
  for (int k = 1; k < SqrtPeriod && (r - k) >= 0; k++)
  {
    double weight = SqrtPeriod - k;
    sumw += weight;
    sum += weight * workSlwma[r - k][instanceNo + 1];
  }
  return (sum / sumw);
}

//
//
//
//
//

double workDsema[][_maWorkBufferx2];
#define _ema1 0
#define _ema2 1

double iDsema(double price, double period, int r, int _bars, int instanceNo = 0)
{
  if (ArrayRange(workDsema, 0) != _bars) ArrayResize(workDsema, _bars);
  instanceNo *= 2;

  //
  //
  //
  //
  //

  workDsema[r][_ema1 + instanceNo] = price;
  workDsema[r][_ema2 + instanceNo] = price;
  if (r > 0 && period > 1)
  {
    double alpha                     = 2.0 / (1.0 + MathSqrt(period));
    workDsema[r][_ema1 + instanceNo] = workDsema[r - 1][_ema1 + instanceNo] + alpha * (price - workDsema[r - 1][_ema1 + instanceNo]);
    workDsema[r][_ema2 + instanceNo] = workDsema[r - 1][_ema2 + instanceNo] + alpha * (workDsema[r][_ema1 + instanceNo] - workDsema[r - 1][_ema2 + instanceNo]);
  }
  return (workDsema[r][_ema2 + instanceNo]);
}

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

double iTema(double price, double period, int r, int bars, int instanceNo = 0)
{
  if (ArrayRange(workTema, 0) != bars) ArrayResize(workTema, bars);
  instanceNo *= 3;

  workTema[r][_tema1 + instanceNo] = price;
  workTema[r][_tema2 + instanceNo] = price;
  workTema[r][_tema3 + instanceNo] = price;
  if (r > 0 && period > 1)
  {
    double alpha                     = 2.0 / (1.0 + period);
    workTema[r][_tema1 + instanceNo] = workTema[r - 1][_tema1 + instanceNo] + alpha * (price - workTema[r - 1][_tema1 + instanceNo]);
    workTema[r][_tema2 + instanceNo] = workTema[r - 1][_tema2 + instanceNo] + alpha * (workTema[r][_tema1 + instanceNo] - workTema[r - 1][_tema2 + instanceNo]);
    workTema[r][_tema3 + instanceNo] = workTema[r - 1][_tema3 + instanceNo] + alpha * (workTema[r][_tema2 + instanceNo] - workTema[r - 1][_tema3 + instanceNo]);
  }
  return (workTema[r][_tema3 + instanceNo] + 3.0 * (workTema[r][_tema1 + instanceNo] - workTema[r][_tema2 + instanceNo]));
}

double workLinr[][_maWorkBufferx1];
double iLinr(double price, int period, int r, int bars, int instanceNo = 0)
{
  if (ArrayRange(workLinr, 0) != bars) ArrayResize(workLinr, bars);

  period                  = MathMax(period, 1);
  workLinr[r][instanceNo] = price;
  if (r < period) return (price);
  double lwmw = period;
  double lwma = lwmw * price;
  double sma  = price;
  for (int k = 1; k < period && (r - k) >= 0; k++)
  {
    double weight = period - k;
    lwmw += weight;
    lwma += weight * workLinr[r - k][instanceNo];
    sma += workLinr[r - k][instanceNo];
  }

  return (3.0 * lwma / lwmw - 2.0 * sma / period);
}

double workDema[][_maWorkBufferx2];
#define _dema1 0
#define _dema2 1

double iDema(double price, double period, int r, int bars, int instanceNo = 0)
{
  if (period <= 1) return (price);
  if (ArrayRange(workDema, 0) != bars) ArrayResize(workDema, bars);
  instanceNo *= 2;

  workDema[r][_dema1 + instanceNo] = price;
  workDema[r][_dema2 + instanceNo] = price;
  double alpha                     = 2.0 / (1.0 + period);
  if (r > 0)
  {
    workDema[r][_dema1 + instanceNo] = workDema[r - 1][_dema1 + instanceNo] + alpha * (price - workDema[r - 1][_dema1 + instanceNo]);
    workDema[r][_dema2 + instanceNo] = workDema[r - 1][_dema2 + instanceNo] + alpha * (workDema[r][_dema1 + instanceNo] - workDema[r - 1][_dema2 + instanceNo]);
  }
  return (workDema[r][_dema1 + instanceNo] * 2.0 - workDema[r][_dema2 + instanceNo]);
}

//------------------------------------------------------------------

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