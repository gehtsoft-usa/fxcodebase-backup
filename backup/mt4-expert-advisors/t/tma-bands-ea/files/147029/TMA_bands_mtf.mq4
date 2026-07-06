// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72607

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
// ------------------------------------------------------------------
#property strict
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots 7
//--- plot TMA
#property indicator_label1 "TMA"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrDarkGray
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
//--- plot TMA up
#property indicator_label2 "TMA_Up"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrLimeGreen
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2
//--- plot TMA dn
#property indicator_label3 "TMA_Dn"
#property indicator_type3  DRAW_LINE
#property indicator_color3 clrRed
#property indicator_style3 STYLE_SOLID
#property indicator_width3 2
//--- plot Top
#property indicator_label4 "Top"
#property indicator_type4  DRAW_LINE
#property indicator_color4 clrDarkGray
#property indicator_style4 STYLE_DOT
#property indicator_width4 1
//--- plot Bottom
#property indicator_label5 "Bottom"
#property indicator_type5  DRAW_LINE
#property indicator_color5 clrDarkGray
#property indicator_style5 STYLE_DOT
#property indicator_width5 1
//--- ARROWS
#property indicator_label6 "Arrow Up"
#property indicator_type6  DRAW_ARROW
#property indicator_color6 clrBlue
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "Arrow Down"
#property indicator_type7  DRAW_ARROW
#property indicator_color7 clrRed
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1

//--- enums
enum ENUM_INPUT_YES_NO {
  INPUT_YES = 1,  // Yes
  INPUT_NO  = 0   // No
};

enum BANDS_MODE {
  ATR_MODE,  // By ATR
  PIPS_MODE  // By PIPS
};

input ENUM_TIMEFRAMES inpTFsup = PERIOD_H4; // Time Frame:
ENUM_TIMEFRAMES       TFsup;
//--- input parameters
input uint              InpPeriodTMA          = 56;                     // TMA period
input BANDS_MODE        bands_mode            = PIPS_MODE;              // Bands Mode:
input uint              InpPeriodATR          = 100;                    // ATR period
input double            InpMultiplierATR      = 2.0;                    // ATR multiplier
input int               InpPipsDistance       = 12;                     // PIPS Distance
input double            InpThreshold          = 0.5;                    // Trend threshold
input ENUM_INPUT_YES_NO InpRedraw             = INPUT_NO;              // Redraw
input string            T2                    = "== Set Arrows ==";     // Set Arrows
input bool              ArrowsOn              = true;                   // Arrows On?
input color             ArrowUpClr            = clrBlue;                // Arrow Up Color:
input color             ArrowDnClr            = clrRed;                 // Arrow Down Color:
input string            T1                    = "== Notifications ==";  // Notifications
input bool              notifications         = false;                  // Notifications On?
input bool              desktop_notifications = false;                  // Desktop MT4 Notifications
input bool              email_notifications   = false;                  // Email Notifications
input bool              push_notifications    = false;                  // Push Mobile Notifications
//--- indicator buffers
double BufferTMA[];
double BufferTMAup[];
double BufferTMAdn[];
double BufferTop[];
double BufferBottom[];
double BufferATR[];
double ArrowUp[];
double ArrowDn[];

//--- global variables
double multiplier;
double threshold;
int    period_tma;
int    period_atr;
int    period_max;
int    handle_atr;
int    lastSignal;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  //--- set global variables
  period_tma = int(InpPeriodTMA < 1 ? 1 : InpPeriodTMA);
  period_atr = int(InpPeriodATR < 1 ? 1 : InpPeriodATR);
  period_max = fmax(period_atr, period_tma);
  multiplier = InpMultiplierATR;
  threshold  = InpThreshold;
  //--- indicator buffers mapping
  SetIndexBuffer(0, BufferTMA, INDICATOR_DATA);
  SetIndexBuffer(1, BufferTMAup, INDICATOR_DATA);
  SetIndexBuffer(2, BufferTMAdn, INDICATOR_DATA);
  SetIndexBuffer(3, BufferTop, INDICATOR_DATA);
  SetIndexBuffer(4, BufferBottom, INDICATOR_DATA);
  SetIndexBuffer(5, BufferATR, INDICATOR_CALCULATIONS);
  IndicatorSetInteger(INDICATOR_DIGITS, Digits());
  //--- ARROWS
  SetIndexBuffer(6, ArrowUp, INDICATOR_DATA);
  SetIndexArrow(6, 233);
  SetIndexStyle(6, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
  SetIndexBuffer(7, ArrowDn, INDICATOR_DATA);
  SetIndexStyle(7, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
  SetIndexArrow(7, 234);
  if (!ArrowsOn)
  {
    SetIndexStyle(0, DRAW_NONE);
    SetIndexStyle(1, DRAW_NONE);
  }

  //--- setting buffer arrays as timeseries
  ArraySetAsSeries(BufferTMA, true);
  ArraySetAsSeries(BufferTMAup, true);
  ArraySetAsSeries(BufferTMAdn, true);
  ArraySetAsSeries(BufferTop, true);
  ArraySetAsSeries(BufferBottom, true);
  ArraySetAsSeries(BufferATR, true);
  ArraySetAsSeries(ArrowUp, true);
  ArraySetAsSeries(ArrowDn, true);
  ResetLastError();

//--- TF
  if (inpTFsup < _Period) TFsup = _Period; else TFsup = inpTFsup;

  return (INIT_SUCCEEDED);
}

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
  ArraySetAsSeries(close, true);

  if (rates_total < fmax(period_max, 4)) return 0;
  int limit = rates_total - prev_calculated;
  if (limit > 1)
  {
    limit = rates_total - period_max - 2;
    ArrayInitialize(BufferTMA, EMPTY_VALUE);
    ArrayInitialize(BufferTMAup, EMPTY_VALUE);
    ArrayInitialize(BufferTMAdn, EMPTY_VALUE);
    ArrayInitialize(BufferTop, EMPTY_VALUE);
    ArrayInitialize(BufferBottom, EMPTY_VALUE);
    ArrayInitialize(BufferATR, 0);
    ArrayInitialize(ArrowUp, EMPTY_VALUE);
    ArrayInitialize(ArrowDn, EMPTY_VALUE);
  }

  for (int i = limit; i >= 0 && !IsStopped(); i--)
  {
		
		int i_TFsup = iBarShift(NULL, TFsup, time[i],false);
    
		int  tcount      = period_tma;
    bool period_last = (i == 0 ? true : false);

    while (tcount > 0)
    {
      tcount      = (!period_last ? 0 : tcount - 1);
      double sum  = 0;
      double sumw = (period_tma + 2) * (period_tma + 1) / 2;
      
			for (int j = 0; j <= period_tma; j++)
      {
        // sum += (period_tma - j + 1) * close[i + j]; // close tiene que ser del tfsup
        sum += (period_tma - j + 1) * iClose(NULL, TFsup, i_TFsup + j);

        if (InpRedraw)
        {
          // if (i - j > 0)
          if (i_TFsup - j > 0)
          {
            // sum += (period_tma - j + 1) * close[i - j]; // close del tfsup
            sum += (period_tma - j + 1) * iClose(NULL, TFsup, i_TFsup - j);
            sumw += (period_tma - j + 1);
          }
        }
      }
      if (sumw != 0)
      {
        BufferTMA[i] = sum / sumw;
      }
    }

    //--- define colors
		
    // BufferATR[i] = iATR(NULL, PERIOD_CURRENT, period_atr, i); // ATR del tfsup
    BufferATR[i] = iATR(NULL, TFsup, period_atr, i_TFsup);
    
		// double slope = (BufferTMA[i] - BufferTMA[i + 1]) / (0.1 * BufferATR[i]); // i + 1 -> en realidad se mantiene igual en mtf, tengo que buscar el punto anterior en el buffer cuando el valor sea distinto al actual

    double BufferTMA_anterior = 0;
    int    n                  = i;
    while (BufferTMA[i] == BufferTMA[n+1]) { n++; }
    BufferTMA_anterior        = BufferTMA[n + 1];

    double slope              = (BufferTMA[i] - BufferTMA_anterior) / (0.1 * BufferATR[i]);

    // calculate bands separation:
    double range;
    if (bands_mode == PIPS_MODE)
    {
      range = InpPipsDistance * 10 * _Point;
    } else
    {
      range = BufferATR[i] * multiplier;
    }

    BufferTop[i]    = BufferTMA[i] + range;
    BufferBottom[i] = BufferTMA[i] - range;

    if (slope > threshold)
      BufferTMAup[i] = BufferTMA[i];
    else if (slope < -threshold)
      BufferTMAdn[i] = BufferTMA[i];

    if (haveSignalUp(i))
    {
      ArrowUp[i] = Low[i]-100*_Point;
      if (newCandle.IsNewCandle())
      {
        Notifications(0);
      }
    }
    if (haveSignalDown(i))
    {
      ArrowDn[i] = High[i]+100*_Point;
      if (newCandle.IsNewCandle())
      {
        Notifications(1);
      }
    }
  }

  //--- return value of prev_calculated for next call
  return (rates_total);
}
//+------------------------------------------------------------------+

bool haveSignalUp(int i)
{
  // TODO: signal up

  if (iClose(NULL, 0, i + 1) < BufferBottom[i + 1])
  {
    if (lastSignal != 1)
    {
      lastSignal = 1;
      return true;
    }
  }
  return false;
}

bool haveSignalDown(int i)
{
	// datetime time    = iTime(NULL, 0, i);
	if (iClose(NULL, 0, i + 1) > BufferTop[i + 1])
  {
    if (lastSignal != -1)
    {
      lastSignal = -1;
      return true;
    }
  }
  return false;
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