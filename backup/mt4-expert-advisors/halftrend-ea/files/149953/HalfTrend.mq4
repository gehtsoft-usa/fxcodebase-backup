//Available @ http://fxcodebase.com

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
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 11
#property indicator_plots 6

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];
double htup[];
double htdn[];
double MaxLow[];
double MinHigh[];
double trend[];
double down[];
double up[];
double atrLow[];
double atrHigh[];

// int trend   = 0;
int nextTrend = 0;
// ------------------------------------------------------------------

input int    amplitud              = 2;
input int    channelDeviation      = 2;
input string T1                    = "== Notifications ==";  // === Notifications ===
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Lines ==";      // === Set  Lines ===
input bool   ChannelsOn            = true;                   // Channels On?
input color  LineUpClr             = RoyalBlue;              // Line Up Color
input color  LineDnClr             = Crimson;                // Line Down Color
input string T3                    = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrBlue;                // Arrow Up Color
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color

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
  // clang-format off
	IndicatorBuffers(11);
  //--- indicator buffers mapping
 SetIndexBuffer(0, htup, INDICATOR_DATA);
  SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2, LineUpClr);
  SetIndexLabel(0, "HT Up");
  
 SetIndexBuffer(1, htdn, INDICATOR_DATA);
  SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2, LineDnClr);
  SetIndexLabel(1, "HT Dn");

 SetIndexBuffer(2, atrHigh, INDICATOR_DATA);
  SetIndexStyle(2, DRAW_LINE, STYLE_DOT, 1, clrGray);
  SetIndexLabel(2, "Atr Up");

 SetIndexBuffer(3, atrLow, INDICATOR_DATA);
  SetIndexStyle(3, DRAW_LINE, STYLE_DOT, 1, clrGray);
  SetIndexLabel(3, "Atr Dn");

  if (!ChannelsOn) {
    SetIndexStyle(2, DRAW_NONE);
    SetIndexStyle(3, DRAW_NONE);
  }

 SetIndexBuffer(4, ArrowUp, INDICATOR_DATA);
  SetIndexArrow(4, 233);
  SetIndexStyle(4, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
  SetIndexLabel(4, "Arrow Up");

 SetIndexBuffer(5, ArrowDn, INDICATOR_DATA);
  SetIndexStyle(5, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
  SetIndexArrow(5, 234);
  SetIndexLabel(5, "Arrow Dn");

  if (!ArrowsOn)
  {
    SetIndexStyle(4, DRAW_NONE);
    SetIndexStyle(5, DRAW_NONE);
  }

 SetIndexBuffer(6, trend);
  SetIndexLabel(6, "trend");

  SetIndexBuffer(7, down);
  SetIndexBuffer(8, up);
 
 SetIndexBuffer(9, MaxLow);
  SetIndexLabel(9, "MaxLow");
 SetIndexBuffer(10, MinHigh);
  SetIndexLabel(10, "MinHigh");

  SetIndexStyle(6, DRAW_NONE);
  SetIndexStyle(7, DRAW_NONE);
  SetIndexStyle(8, DRAW_NONE);
  SetIndexStyle(9, DRAW_NONE);
  SetIndexStyle(10, DRAW_NONE);

 

  //---
  return (INIT_SUCCEEDED);
}

// ------------------------------------------------------------------
// NOTE: Oncalc
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
  if (prev_calculated == 0) { start = rates_total - amplitud*2; } else { start = rates_total - (prev_calculated - 1); }
  // clang-format on

  for (i = start; i >= 0; i--)
  {
		Print(__FUNCTION__," start: ",start);
    up[i]   = up[i + 1];
    down[i] = down[i + 1];
    ArrowUp[i] = EMPTY_VALUE;
    ArrowDn[i] = EMPTY_VALUE;

    double atr = iATR(NULL, 0, 100, i) / 2;
    double dev = channelDeviation * atr;

    double minHighPrice = high[i + amplitud];
    double maxLowPrice  = low[i + amplitud];

    double highPrice = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, amplitud, i));
    double lowPrice  = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, amplitud, i));
    double highma    = sma("high", amplitud, i);
    double lowma     = sma("low", amplitud, i);

    trend[i]   = trend[i + 1];
    MinHigh[i] = MinHigh[i + 1];
    MaxLow[i]  = MaxLow[i + 1];

    // ESCENARIO ALCISTA
    if (nextTrend == 1)
    {
      maxLowPrice = fmax(lowPrice, maxLowPrice);
      MaxLow[i]   = fmax(MaxLow[i + 1], maxLowPrice);

      if (highma < MaxLow[i] && close[i] <= low[i + 1])
      {
        trend[i]     = 1;  // BAJISTA
        nextTrend    = 0;
        minHighPrice = highPrice;
        MinHigh[i]   = highPrice;
      }
    }

    //  ESCENARIO BAJISTA
    else
    {
      minHighPrice = fmin(highPrice, minHighPrice);
      MinHigh[i]   = fmin(MinHigh[i + 1], minHighPrice);

      if (lowma > MinHigh[i] && close[i] >= high[i + 1])
      {
        trend[i]    = 0;  // ALCISTA
        nextTrend   = 1;
        maxLowPrice = lowPrice;
        MaxLow[i]   = lowPrice;
      }
    }

    if (trend[i] == 0)
    {
      if (trend[i + 1] != 0)
      {
        htup[i + 1] = down[i + 1];
        up[i]       = down[i + 1];
        
				ArrowUp[i]  = up[i] - atr;
        
				notify(0);
      } else
      {
        up[i] = fmax(maxLowPrice, up[i + 1]);
      }
      atrLow[i + 1]  = htup[i + 1] - dev;
      atrHigh[i + 1] = htup[i + 1] + dev;
    }

    if (trend[i] == 1)
    {
      if (trend[i + 1] != 1)  // change up - dn
      {
        htdn[i + 1] = up[i + 1];
        down[i]     = up[i + 1];
        
				ArrowDn[i]  = down[i] + atr;
        
				notify(1);
      } else
      {
        down[i] = fmin(minHighPrice, down[i + 1]);
      }
      atrLow[i + 1]  = htdn[i + 1] - dev;
      atrHigh[i + 1] = htdn[i + 1] + dev;
    }

    htup[i] = trend[i] == 0 ? up[i] : EMPTY_VALUE;
    htdn[i] = trend[i] == 1 ? down[i] : EMPTY_VALUE;
  }

  return (rates_total);
}

// ------------------------------------------------------------------

// aplica la media movil a ese array
double sma(string mode, int bars, int i)
{
  double sum = 0;
  for (int j = 0; j < bars; j++)
  {
    if (mode == "high") sum += iHigh(NULL, 0, i + j);
    if (mode == "low") sum += iLow(NULL, 0, i + j);
  }
  return NormalizeDouble(sum / bars, _Digits);
}

void notify(int type)
{
  if (newCandle.IsNewCandle())
  {
    Notifications(type);
  }
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