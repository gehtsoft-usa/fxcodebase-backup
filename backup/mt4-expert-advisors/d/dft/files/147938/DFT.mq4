// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72848

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




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 11
#property indicator_color1 clrOrchid
#property indicator_color2 clrDarkOrange
#property indicator_color3 clrChartreuse
#property indicator_color4 clrGray
#property indicator_color5 clrChartreuse
#property indicator_color6 clrDarkOrange
#property indicator_color7 clrOrchid
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 1

// ------------------------------------------------------------------
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
//--- indicator buffers
double ArrowUp[];
double ArrowDn[];
// ------------------------------------------------------------------

input int   periods     = 55;
input color Val_1_Color = clrOrchid;
input color Val_2_Color = clrDarkOrange;
input color Val_3_Color = clrChartreuse;
input color Val_4_Color = clrSteelBlue;
input color Val_5_Color = clrChartreuse;
input color Val_6_Color = clrDarkOrange;
input color Val_7_Color = clrOrchid;

input color clrLower  = PaleGreen;  // Lower Zone Color:
input color clrMedium = Gray;       // Medium Zone Color:
input color clrHigher = Tomato;     // Higher Zone Color:

input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color:

//---- indicator buffers
double line0[];
double line1[];
double line2[];
// double line3[];
double line4[];
double line5[];
double line6[];
double ZoneLower[];
double ZoneCentral[];
double ZoneHigher[];

double dif;

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

int OnInit()
{
  //---- drawing settings
  IndicatorBuffers(9);
  //---- indicator buffers mapping
  SetIndexBuffer(0, ZoneLower);
  SetIndexBuffer(1, line0);
  SetIndexBuffer(2, line1);
  SetIndexBuffer(3, ZoneCentral);
  SetIndexBuffer(4, line2);
  // SetIndexBuffer(5, line3);
  SetIndexBuffer(5, line4);
  SetIndexBuffer(6, line5);
  SetIndexBuffer(7, line6);
  SetIndexBuffer(8, ZoneHigher);

  SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 6, clrLower);
  SetIndexStyle(1, DRAW_LINE, STYLE_SOLID);
  SetIndexStyle(2, DRAW_LINE, STYLE_SOLID);
  SetIndexStyle(3, DRAW_HISTOGRAM, EMPTY, 6, clrMedium);
  SetIndexStyle(4, DRAW_LINE, STYLE_SOLID);
  // SetIndexStyle(5, DRAW_LINE, STYLE_DOT);// FIBO 50%
  SetIndexStyle(5, DRAW_LINE, STYLE_SOLID);
  SetIndexStyle(6, DRAW_LINE, STYLE_SOLID);
  SetIndexStyle(7, DRAW_HISTOGRAM, EMPTY, 6, clrHigher);
  SetIndexStyle(8, DRAW_LINE, STYLE_SOLID);

  //--- indicator buffers mapping
  SetIndexBuffer(9, ArrowUp, INDICATOR_DATA);
  SetIndexArrow(9, 116);
  SetIndexStyle(9, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
  SetIndexBuffer(10, ArrowDn, INDICATOR_DATA);
  SetIndexStyle(10, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
  SetIndexArrow(10, 116);
  if (!ArrowsOn)
  {
    SetIndexStyle(9, DRAW_NONE);
    SetIndexStyle(10, DRAW_NONE);
  }

  //---- name for DataWindow and indicator subwindow label
  SetIndexLabel(0, "lower Zone");
  SetIndexLabel(1, "Fibo 0.00");
  SetIndexLabel(2, "Fibo 0.236");
  SetIndexLabel(3, "medium Zone");
  SetIndexLabel(4, "Fibo 0.382");
  SetIndexLabel(5, "Fibo 0.618");
  SetIndexLabel(6, "higher Zone");
  SetIndexLabel(7, "Fibo 0.764");
  SetIndexLabel(8, "Fibo 1.00");
  SetIndexLabel(9, "Arrow up");
  SetIndexLabel(10, "Arrow down");

  //---- initialization done
  return (0);
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
  int start, i;
  if (prev_calculated == 0)
  {
    start = rates_total - periods;
  } else
  {
    start = rates_total - (prev_calculated - 1);
  }

  for (i = start; i >= 0; i--)
  {
    line6[i] = iHigh(Symbol(), Period(), iHighest(Symbol(), Period(), MODE_HIGH, periods, i));
    line0[i] = iLow(Symbol(), Period(), iLowest(Symbol(), Period(), MODE_LOW, periods, i));

    dif      = line6[i] - line0[i];
    line1[i] = line0[i] + dif * 0.236;
    line2[i] = line0[i] + dif * 0.382;
    // line3[i] = line0[i] + dif * 0.5;
    line4[i] = line0[i] + dif * 0.618;
    line5[i] = line0[i] + dif * 0.764;

		// NOTE: Zones
    ZoneLower[i]   = line1[i];  // de 0 a 1
    ZoneCentral[i] = line5[i];  // de 2 a 4
    ZoneHigher[i]  = line6[i];  // de 5 a 6

		// NOTE: Arrows
    if (haveSignalUp(i))
    {
      ArrowUp[i+1] = Low[i+1];
      if (newCandle.IsNewCandle()) { Notifications(0); }
    }
    if (haveSignalDown(i))
    {
      ArrowDn[i+1] = High[i+1];
      if (newCandle.IsNewCandle()) { Notifications(1); }
    }
  }

  //---- done
  return (0);
}
//+------------------------------------------------------------------+

bool haveSignalUp(int i)
{
  // TODO: signal up
  double low = iLow(NULL, 0, i+1);
	if(low <= line0[i+1])
  {
    return true;
  }

  return false;
}

bool haveSignalDown(int i)
{
  // TODO: signal down
	double high = iHigh(NULL, 0, i+1);
	if(high >= line6[i+1])
  {
    return true;
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
