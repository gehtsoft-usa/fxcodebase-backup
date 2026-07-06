// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73524

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
#property indicator_buffers 5
#property indicator_plots 2
#property indicator_label1 "Fast Ma"
#property indicator_type1  DRAW_LINE
#property indicator_color1 LimeGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Converging Line"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

//--- indicator buffers
double fma[];
double ma[];
double alpha[];
double upper[];
double lower[];

// ------------------------------------------------------------------
input double  length       = 100;
input double  incr         = 10;
input double  fast         = 10;
bool continuation = false;

string T1                    = "== Notifications ==";  // ————————————
bool   notifications         = false;                  // Notifications On?
bool   desktop_notifications = false;                  // Desktop MT4 Notifications
bool   email_notifications   = false;                  // Email Notifications
bool   push_notifications    = false;                  // Push Mobile Notifications
string T2                    = "== Set Lines ==";      // ————————————
color  LineUpClr             = LimeGreen;              // Line Up Color:
color  LineDnClr             = clrRed;                 // Line Down Color:
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
    SetIndexBuffer(0, fma, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_LINE, EMPTY, 1, LineUpClr);

    SetIndexBuffer(1, ma, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, EMPTY, 1, LineDnClr);
    SetIndexArrow(1, 234);

    SetIndexBuffer(2, alpha);
    SetIndexBuffer(3, upper);
    SetIndexBuffer(4, lower);
    SetIndexStyle(2, DRAW_NONE);
    SetIndexStyle(3, DRAW_NONE);
    SetIndexStyle(4, DRAW_NONE);

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
  int start, period;
  if (prev_calculated == 0) { start = rates_total - length; } else { start = rates_total - (prev_calculated - 1); }
  // if (prev_calculated == 0) { start = 1000; } else { start = rates_total - (prev_calculated - 1); }

    // clang-format on
    double k = 1 / incr;

    for (period = start; period >= 0; period--)
    {
        ma[period] = avg(period, length);

        if (continuation) alpha[period] = alpha[period + 1];
        else alpha[period] = 0;

        double min = close[iLowest(NULL, 0, MODE_CLOSE, length, period)];
        double max = close[iHighest(NULL, 0, MODE_CLOSE, length, period)];

				if(ma[period + 1]!= EMPTY_VALUE)
        ma[period] = ma[period + 1] + (alpha[period + 1] * (close[period] - ma[period + 1]));

        upper[period] = max;
        lower[period] = min;

        // comprobar si el precio cruzó a ma en cualquier direccion
        double cross = false;
        if ((close[period] > ma[period] && close[period + 1] <= ma[period + 1]) || (close[period] < ma[period] && close[period + 1] >= ma[period + 1])) cross = true;

        if (cross) alpha[period] = 2 / (length + 1);        
				if (close[period] > ma[period] && upper[period] > upper[period + 1]) alpha[period] = alpha[period] + k;
				if (close[period] < ma[period] && lower[period] < lower[period + 1]) alpha[period] = alpha[period] + k;
        
				// else
            // alpha[period] = 0;

        if (cross)
            fma[period] = avg(period, fast);
        else if (close[period] > ma[period])
            fma[period] = fmax(close[period], fma[period + 1]) + (close[period] - fma[period + 1]) / fast;
        else
            fma[period] = fmin(close[period], fma[period + 1]) + (close[period] - fma[period + 1]) / fast;
    }
    return (rates_total);
}

// ------------------------------------------------------------------

double avg(int i, int len)
{
    double sum = 0;
    for (int j = 0; j < len; j++)
        sum += iClose(NULL, 0, i + j);

    return sum / len;
}

bool haveSignalUp(int period)
{
    // TODO: signal up

    return true;
}

bool haveSignalDown(int period)
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