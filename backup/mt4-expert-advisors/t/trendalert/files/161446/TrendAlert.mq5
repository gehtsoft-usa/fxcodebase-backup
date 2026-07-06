// More information about this indicator can be found at:
// http://fxcodebase.com/

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

#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict
// #property indicator_chart_window
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots 1
//--- plot Histogram 
#property indicator_label1  "Color_Histogram" 
#property indicator_type1   DRAW_COLOR_HISTOGRAM 
#property indicator_color1  clrRed,clrGreen
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  4 
//--- búfer de valores 
double         buValue[]; 
//--- búfer para los índices de colores 
double         buColor[]; 




string                T0                    = "== TimeFrames ==";     // ————————————
input ENUM_TIMEFRAMES HTF                   = PERIOD_D1;              // Higher Time Frame:
input ENUM_TIMEFRAMES MTF                   = PERIOD_H4;              // Midle Time Frame:
// ------------------------------------------------------------------
input string TZ                    = "== Notifications =="; // ————————————
input bool   notifications         = false;                 // Notifications On
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications

// ------------------------------------------------------------------

double Linea1Buffer[];
string indicator_file = "heiken_ashi.ex5";


int  handleHTF = 0;
int  handleMTF = 0;
void setHandleHTF() { handleHTF = iCustom(Symbol(), HTF, indicator_file); }
void setHandleMTF() { handleMTF = iCustom(Symbol(), MTF, indicator_file); }

double op_HTF(int candle = 1) {
    int b = iBars(NULL, HTF)-1;
    int sh = b - candle;
    double value[1];
    int    copy = CopyBuffer(handleHTF, 0, sh, 1, value);
    if (copy > 0) { return value[0]; }
    return -1;
}
double cl_HTF(int candle = 1) {
    int b = iBars(NULL, HTF)-1;
    int sh = b - candle;
    double value[1];
    int    copy = CopyBuffer(handleHTF, 3, sh, 1, value);
    if (copy > 0) { return value[0]; }
    return -1;
}

double op_MTF(int candle = 1) {
    int b = iBars(NULL, MTF)-1;
    int sh = b - candle;
    double value[1];
    int    copy = CopyBuffer(handleMTF, 0, sh, 1, value);
    if (copy > 0) { return value[0]; }
    return -1;
}
double cl_MTF(int candle = 1) {
    int b = iBars(NULL, MTF)-1;
    int sh = b - candle;
    double value[1];
    int    copy = CopyBuffer(handleMTF, 3, sh, 1, value);
    if (copy > 0) { return value[0]; }
    return -1;
}


int  handle_ma1 = 0;
void setHandle_ma1() { handle_ma1 = iMA(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE); }

double MA(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle;
    // int shift = candle;
    int copy  = CopyBuffer(handle_ma1, 0, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}

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

//+------------------------------------------------------------------+



int OnInit()
{
    SetIndexBuffer(0, buValue, INDICATOR_DATA);
    SetIndexBuffer(1, buColor, INDICATOR_COLOR_INDEX); 
    
    setHandleMTF();
    setHandleHTF();
    setHandle_ma1();

    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
{
    int i, start;

    start = 1;
    if (prev_calculated > 1) start = prev_calculated - 1;

    for (i = start; i < rates_total && !IsStopped(); i++) {
    
        buValue[i] = 0;

        if(haveSignalUp(i))
        {
            buValue[i] = 1;
            double ema = MA(i);
            double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
			if(Bid > ema) if (newCandle.IsNewCandle()) { Notifications(0); }
        }
        if(haveSignalDn(i))
        {
            buValue[i] = -1;
            double ema = MA(i);
            double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
			if(Bid <= ema) if (newCandle.IsNewCandle()) { Notifications(1); }
        }
        buColor[i] = buValue[i] < 0 ? 0 : 1;
    }
    return (rates_total);
}

bool haveSignalUp(int i)
{
 	datetime tm   = iTime(NULL, 0, i);
	int iHTF      = iBarShift(NULL, HTF, tm, false);
	int iMTF      = iBarShift(NULL, MTF, tm, false);
 
    double op_htf = op_HTF(iHTF);
    double cl_htf = cl_HTF(iHTF);
    double op_mtf = op_MTF(iMTF);
    double cl_mtf = cl_MTF(iMTF);

    return op_htf < cl_htf && op_mtf < cl_mtf;
    // return op_htf < cl_htf;
}
bool haveSignalDn(int i)
{
 	datetime tm   = iTime(NULL, 0, i);
	int iHTF      = iBarShift(NULL, HTF, tm, false);
	int iMTF      = iBarShift(NULL, MTF, tm, false);
 
    double op_htf = op_HTF(iHTF);
    double cl_htf = cl_HTF(iHTF);
    double op_mtf = op_MTF(iMTF);
    double cl_mtf = cl_MTF(iMTF);

    return op_htf > cl_htf && op_mtf > cl_mtf;
    // return op_htf > cl_htf;
}



void Notifications(int type)
{
    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal UP ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " Signal DOWN ";

    text += " ";

    if (!notifications) return;
    if (desktop_notifications) Alert(text);
    if (push_notifications) SendNotification(text);
    if (email_notifications) SendMail("MetaTrader Notification", text);
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