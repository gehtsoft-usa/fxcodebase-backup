// Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=149852

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

#property indicator_chart_window

#property indicator_buffers 10
#property indicator_plots 6

// NOTE: Inputs
// ------------------------------------------------------------------
//---- input parameters
input int    Length    = 8;     // Bollinger Bands Period
input int    Deviation = 1;     // Deviation was 2
input double MoneyRisk = 1.00;  // Offset Factor
input int    Signal    = 1;     // Display signals mode: 1-Signals & Stops; 0-only Stops; 2-only Signals;
input int    Line      = 1;     // Display line mode: 0-no,1-yes
input int    Nbars     = 1000;

input int    Period                = 10;                     // Indicator Periods
input string T0                    = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color:
input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications

// NOTE: Buffers
//--- indicator buffers
double smax[];
double smin[];
double bsmax[];
double bsmin[];

double UpTrendLine[];
double DownTrendLine[];

double UpTrendBuffer[];
double DownTrendBuffer[];
double UpTrendSignal[];
double DownTrendSignal[];

bool TurnedUp = false;
bool TurnedDown = false;

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

int bb;

// ------------------------------------------------------------------
void OnInit()
{
  //--- indicator short name
  string short_name = "Line Indicator";
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  IndicatorSetInteger(INDICATOR_DIGITS, 2);

  SetIndexBuffer(0, UpTrendBuffer);
  SetIndexBuffer(1, DownTrendBuffer);
  SetIndexBuffer(2, UpTrendSignal);
  SetIndexBuffer(3, DownTrendSignal);
  SetIndexBuffer(4, UpTrendLine);
  SetIndexBuffer(5, DownTrendLine);

  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Length);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, Length);

  PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
  PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
  PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_ARROW);
  PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_ARROW);
  PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_LINE);
  PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_LINE);

  PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 1);
  PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 1);
  PlotIndexSetInteger(4, PLOT_LINE_WIDTH, 1);
  PlotIndexSetInteger(5, PLOT_LINE_WIDTH, 1);

  PlotIndexSetInteger(0, PLOT_ARROW, 159);
  PlotIndexSetInteger(1, PLOT_ARROW, 159);

  PlotIndexSetInteger(0, PLOT_LINE_COLOR, ArrowUpClr);
  PlotIndexSetInteger(1, PLOT_LINE_COLOR, ArrowDnClr);
  PlotIndexSetInteger(2, PLOT_LINE_COLOR, ArrowUpClr);
  PlotIndexSetInteger(3, PLOT_LINE_COLOR, ArrowDnClr);

  PlotIndexSetInteger(4, PLOT_LINE_COLOR, ArrowUpClr);
  PlotIndexSetInteger(5, PLOT_LINE_COLOR, ArrowDnClr);

  SetIndexBuffer(6, smax, INDICATOR_CALCULATIONS);
  SetIndexBuffer(7, smin, INDICATOR_CALCULATIONS);
  SetIndexBuffer(8, bsmax, INDICATOR_CALCULATIONS);
  SetIndexBuffer(9, bsmin, INDICATOR_CALCULATIONS);

  if (!ArrowsOn) {
    PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
    PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
  }

  bb = iBands(NULL, 0, Length, 0, Deviation, PRICE_CLOSE);
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
  if (rates_total < Length) return (0);

  int start, trend;
  if (prev_calculated > 1) start = prev_calculated - 1; else { start = Length + 1; }


  for (int i = start; i < rates_total && !IsStopped(); i++) {
    UpTrendBuffer[i]   = 0;
    DownTrendBuffer[i] = 0;
    UpTrendSignal[i]   = 0;
    DownTrendSignal[i] = 0;
    UpTrendLine[i]     = EMPTY_VALUE;
    DownTrendLine[i]   = EMPTY_VALUE;

    smax[i] = index(bb, 1, i);
    smin[i] = index(bb, 2, i);

    if (close[i] > smax[i - 1]) trend = 1;
    if (close[i] < smin[i - 1]) trend = -1;

    if (trend > 0 && smin[i] < smin[i - 1]) smin[i] = smin[i - 1];
    if (trend < 0 && smax[i] > smax[i - 1]) smax[i] = smax[i - 1];

    bsmax[i] = smax[i] + 0.5 * (MoneyRisk - 1) * (smax[i] - smin[i]);
    bsmin[i] = smin[i] - 0.5 * (MoneyRisk - 1) * (smax[i] - smin[i]);

    if (trend > 0 && bsmin[i] < bsmin[i - 1]) bsmin[i] = bsmin[i - 1];
    if (trend < 0 && bsmax[i] > bsmax[i - 1]) bsmax[i] = bsmax[i - 1];

    if (trend > 0) {
      if (Signal > 0 && UpTrendBuffer[i - 1] == -1.0) {
        UpTrendSignal[i] = bsmin[i];
        UpTrendBuffer[i] = bsmin[i];
        if (Line > 0) UpTrendLine[i] = bsmin[i];

        if (newCandle.IsNewCandle() && !TurnedUp) {
          Notifications(0);
          TurnedUp   = true;
          TurnedDown = false;
        }

      } else {
        UpTrendBuffer[i] = bsmin[i];
        if (Line > 0) UpTrendLine[i] = bsmin[i];
        UpTrendSignal[i] = -1;
      }
      if (Signal == 2) UpTrendBuffer[i] = 0;
      
			DownTrendSignal[i] = -1;
      DownTrendBuffer[i] = -1.0;
      DownTrendLine[i]   = EMPTY_VALUE;
    }

    if (trend < 0) {
      if (Signal > 0 && DownTrendBuffer[i - 1] == -1.0) {
        DownTrendSignal[i] = bsmax[i];
        DownTrendBuffer[i] = bsmax[i];
        if (Line > 0) DownTrendLine[i] = bsmax[i];

        if (newCandle.IsNewCandle() && !TurnedDown) {
          Notifications(0);
          TurnedUp   = false;
          TurnedDown = true;
        }

      } else {
        DownTrendBuffer[i] = bsmax[i];
        if (Line > 0) DownTrendLine[i] = bsmax[i];
        	DownTrendSignal[i] = -1;
      }
      if (Signal == 2)
        DownTrendBuffer[i] = 0;

      UpTrendSignal[i] = -1;
      UpTrendBuffer[i] = -1.0;
      UpTrendLine[i]   = EMPTY_VALUE;
    }
  }

  return (rates_total);
}

// ------------------------------------------------------------------

double index(int handle, int buffer, int shift)
{
  int    bars   = iBars(NULL, 0);
  int    _shift = bars - shift -1;
  double value[1];
  int    qnt = CopyBuffer(handle, buffer, _shift, 1, value);

  if (qnt > 0) { return value[0]; }
  return -1;
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

//+------------------------------------------------------------------+
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