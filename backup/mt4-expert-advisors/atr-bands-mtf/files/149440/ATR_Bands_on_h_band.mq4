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
// #property indicator_chart_window
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots 3
#property indicator_label1 "Line Center"
 #property indicator_type1  DRAW_LINE
#property indicator_color1 clrBlack
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label2 "Line Up"
 #property indicator_type2  DRAW_LINE
#property indicator_color2 clrBlue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Line Down"
 #property indicator_type3  DRAW_LINE
#property indicator_color3 clrRed
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

string file_custom_indicator = "h_band.ex4";
#define CONTROL_CUSTOM_INDICATOR_FILE

//--- indicator buffers
double LineUp[];
double LineDn[];
double LineCenter[];

// ------------------------------------------------------------------
input string          T0                    = "== Setup ==";          // ————————————
input ENUM_TIMEFRAMES TFSup                 = PERIOD_H4;              // Superior Time Frame:
input int             ATR_Period            = 10;                     // Atr Periods
input double          m                     = 5;                      // Atr Multiplier:
// ------------------------------------------------------------------
input string         Thband            = "== h_band setup ==";          // ————————————
input int            TimeFrame         =       0;    //TimeFrame in min
input int            Length            =       1;    //Period of evaluation
input int            Signal            =       0;    //Period of Signal Line
input int            Pole              =       1;    //1-EMA(1 pole),2-DEMA(2 poles),3-TEMA(3 poles),4-QEMA(4 poles)...
input int            Order             =       1;    //Smoothing Order(min. 1)
input double         WeightFactor      =       2;    //Weight Factor (ex.Wilder=1,EMA=2)   
input double         DampingFactor     =     0.5;    //Damping Factor
input int            CumulativeMode    =       2;    //Cumulative Mode:0-Volume Delta,1-Cumulative Volume Delta,2-Cumulative Volume Delta Bars 
input int            CountBars         =     200;
input color          colorBarDn        =  clrNONE;  
input color          colorBarUp        = clrNONE;
input color          colorBarNeutral   = clrNONE;
input int            widthWick         =       1;
input int            widthBody         =       5;   
input string         UniqueName        = "VolumeDelta"; 
input int            SignalPeriod    = 1;
input ENUM_MA_METHOD SignalMaMode    = MODE_EMA;

// ------------------------------------------------------------------
input string          T1                    = "== Notifications ==";  // ————————————
input bool            notifications         = false;                  // Notifications On?
input bool            desktop_notifications = false;                  // Desktop MT4 Notifications
input bool            email_notifications   = false;                  // Email Notifications
input bool            push_notifications    = false;                  // Push Mobile Notifications
input string          T2                    = "== Set Lines ==";      // ————————————
input bool            LinesOn               = true;                   // Line On?
input color           LineUpClr             = clrBlue;                // Line Up Color:
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
CNewCandle      newCandle();
ENUM_TIMEFRAMES tf;

// ------------------------------------------------------------------
int OnInit()
{
	#ifdef CONTROL_CUSTOM_INDICATOR_FILE
  double temp = iCustom(NULL, 0, file_custom_indicator, 0, 0);
  if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
  {
    Alert("Please, install the: " + file_custom_indicator + " indicator, in folder MQL4/Indicators");
    return INIT_FAILED;
  }
#endif


  tf = TFSup <= Period() ? Period() : TFSup;

  //--- indicator buffers mapping
  SetIndexBuffer(0, LineCenter, INDICATOR_DATA);
  SetIndexArrow(0, 233);
  SetIndexBuffer(1, LineUp, INDICATOR_DATA);
  SetIndexArrow(1, 233);
  SetIndexStyle(1, DRAW_LINE, EMPTY, 1, LineUpClr);
  SetIndexBuffer(2, LineDn, INDICATOR_DATA);
  SetIndexStyle(2, DRAW_LINE, EMPTY, 1, LineDnClr);
  SetIndexArrow(2, 234);
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

	  double atr = iATR(NULL, tf, ATR_Period, isup) * m * tick_volume[1] *100;
    
    double center = iCustom(NULL,0, file_custom_indicator, TimeFrame, Length, Signal, Pole, Order, WeightFactor, DampingFactor, CumulativeMode, CountBars, colorBarDn, colorBarUp, colorBarNeutral, widthWick, widthBody, UniqueName, SignalPeriod, SignalMaMode, 0, i);

    LineCenter[i] = center;

    LineUp[i] = center - atr;
    LineDn[i] = center + atr;    

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