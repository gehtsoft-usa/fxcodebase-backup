// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73577

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
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "Line Up"
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_color1 clrGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label2 "Line Down"
#property indicator_type2  DRAW_HISTOGRAM
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2

//--- indicator buffers
double LineUp[];
double LineDn[];
string file_custom_indicator = "Heiken Ashi.ex4";

// ------------------------------------------------------------------

string                T0                    = "== TimeFrames ==";     // ————————————
input ENUM_TIMEFRAMES HTF                   = PERIOD_D1;              // Higher Time Frame:
input ENUM_TIMEFRAMES MTF                   = PERIOD_H4;              // Midle Time Frame:
input string                T1                    = "== Notifications ==";  // ————————————
input bool                  notifications         = false;                  // Notifications On?
input bool                  desktop_notifications = false;                  // Desktop MT4 Notifications
input bool                  email_notifications   = false;                  // Email Notifications
input bool                  push_notifications    = false;                  // Push Mobile Notifications
input string          T2                    = "== Set Lines ==";      // ————————————
input bool            LinesOn               = true;                  // Line On?
input color           LineUpClr             = clrGreen;                // Line Up Color:
input color           LineDnClr             = clrRed;                 // Line Down Color:
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
    double temp = iCustom(NULL, 0, file_custom_indicator, 0, 0);
    if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
    {
        Alert("Please, install the: " + file_custom_indicator + " indicator, in folder MQL4/Indicators");
        return INIT_FAILED;
    }

    //--- indicator buffers mapping
    SetIndexBuffer(0, LineUp, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 3, LineUpClr);
    SetIndexBuffer(1, LineDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 3, LineDnClr);
    if (!LinesOn)
    {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }
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
    int start, i;
    if (prev_calculated == 0)
    {
        // start = rates_total - 1;
        start = 1000;
    } else
    {
        start = rates_total - (prev_calculated - 1);
    }

    for (i = start; i >= 0; i--)
    {
				LineUp[i] = 0;
        LineDn[i] = 0;
  
	      if (haveSignalUp(i))
        {
            LineUp[i] = 1;
	
						double ema = iMA(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE, i);
						if(Bid >= ema) if (newCandle.IsNewCandle()) { Notifications(0); }
        }

        if (haveSignalDown(i))
        {
            // LineDn[i] = Open[i];
            LineDn[i] = 1;

            double ema = iMA(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE, i);
						if(Bid <= ema) if (newCandle.IsNewCandle()) { Notifications(1); }
        }
    }
    return (rates_total);
}

// ------------------------------------------------------------------

bool haveSignalUp(int i)
{
    // TODO: signal up
		datetime tm   = iTime(NULL, 0, i);
		int iHTF = iBarShift(NULL, HTF, tm, false);
		int iMTF = iBarShift(NULL, MTF, tm, false);

    double op_htf = iCustom(NULL, HTF, file_custom_indicator, 2, iHTF);
    double cl_htf = iCustom(NULL, HTF, file_custom_indicator, 3, iHTF);
    double op_mtf = iCustom(NULL, MTF, file_custom_indicator, 2, iMTF);
    double cl_mtf = iCustom(NULL, MTF, file_custom_indicator, 3, iMTF);

    return op_htf < cl_htf && op_mtf < cl_mtf;
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    datetime tm   = iTime(NULL, 0, i);
    int      iHTF = iBarShift(NULL, HTF, tm, false);
    int      iMTF = iBarShift(NULL, MTF, tm, false);

    double op_htf = iCustom(NULL, HTF, file_custom_indicator, 2, iHTF);
    double cl_htf = iCustom(NULL, HTF, file_custom_indicator, 3, iHTF);
    double op_mtf = iCustom(NULL, MTF, file_custom_indicator, 2, iMTF);
    double cl_mtf = iCustom(NULL, MTF, file_custom_indicator, 3, iMTF);

    return op_htf > cl_htf && op_mtf > cl_mtf;
}

void Notifications(int type)
{
    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " TREND UP ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " TREND DOWN ";

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