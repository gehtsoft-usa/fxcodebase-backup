//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73339

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
#property indicator_buffers 6
#property indicator_plots 4

#property indicator_label1 "Line Up"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

#property indicator_label2 "Line Down"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

#property indicator_label3 "Arrow Up"
#property indicator_type3  DRAW_ARROW
#property indicator_color3 clrBlue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Arrow Down"
#property indicator_type4  DRAW_ARROW
#property indicator_color4 clrRed
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

#define gap 30

double ArrowUp[];
double ArrowDn[];

//--- indicator buffers
double LineUp[];
double LineDn[];
double up[];
double dn[];

// ------------------------------------------------------------------
input int    periods               = 10;
input double multiplier            = 3;                      // Multiplier:
input string T1                    = "== Notifications ==";  // ————————————
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Lines ==";      // ————————————
input bool   LinesOn               = true;                   // Lines top bottom On?
// input color  LineCenterClr         = clrBlack;               // Line Center Color:
input color  LineUpClr  = clrBlue;             // Line Up Color:
input color  LineDnClr  = clrRed;              // Line Down Color:
input string Tarrows    = "== Set Arrows ==";  // ————————————
input bool   ArrowsOn   = true;                // Arrows On?
input color  ArrowUpClr = clrOrange;           // Arrow Up Color:
input color  ArrowDnClr = clrOrange;          // Arrow Down Color:
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
  SetIndexBuffer(0, LineUp, INDICATOR_DATA);
  SetIndexStyle(0, DRAW_LINE, EMPTY, 2, LineUpClr);

  SetIndexBuffer(1, LineDn, INDICATOR_DATA);
  SetIndexStyle(1, DRAW_LINE, EMPTY, 2, LineDnClr);

  SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
  SetIndexArrow(2, 233);
  SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
  SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
  SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
  SetIndexArrow(3, 234);

  // Aux Buffers:
  SetIndexBuffer(4, up);
  SetIndexStyle(4, DRAW_NONE);
  SetIndexBuffer(5, dn);
  SetIndexStyle(5, DRAW_NONE);

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
  int trend;
  int start, i;
  if (prev_calculated == 0)
  {
    start = rates_total - (periods + 1);
  } else
  {
    start = rates_total - (prev_calculated - 1);
  }

  for (i = start; i >= 0; i--)
  {
    double smooth      = iATR(NULL, 0, periods, i) * multiplier;
    double medianPrice = (high[i] + low[i]) / 2;

    LineUp[i] = EMPTY_VALUE;
    LineDn[i] = EMPTY_VALUE;

    up[i] = medianPrice + smooth;
    dn[i] = medianPrice - smooth;

    if (close[i + 1] > up[i + 1]) trend = 1;
    if (close[i + 1] < dn[i + 1]) trend = -1;

    if (trend == 1)
    {
      if (dn[i] < dn[i + 1]) dn[i] = dn[i + 1];
      LineUp[i] = dn[i];
      
			if (haveSignalUp(i))
      {
        ArrowUp[i] = LineUp[i] - gap * _Point;
        if (newCandle.IsNewCandle()) { Notifications(1); }
      }
    }

    if (trend == -1)
    {
      if (up[i] > up[i + 1]) up[i] = up[i + 1];
      LineDn[i] = up[i];
      
			if (haveSignalDown(i))
      {
        ArrowDn[i] = LineDn[i] + gap * _Point;
        if (newCandle.IsNewCandle()) { Notifications(1); }
      }
    }
  }
  return (rates_total);
}

// ------------------------------------------------------------------

bool haveSignalUp(int i)
{

  // TODO: signal up
  if (ArrowUp[i + 1] != EMPTY_VALUE) return false;

  if (iLow(NULL, 0, i + 2) < LineUp[i + 2] && iClose(NULL, 0, i + 2) > LineUp[i + 2] && iClose(NULL, 0, i + 1) > LineUp[i + 1])
    return true;

  return false;
}

bool haveSignalDown(int i)
{
// TODO: signal down
  if (ArrowDn[i + 1] != EMPTY_VALUE) return false;

if(iHigh(NULL,0,i+2) >LineDn[i+2] 
&& iClose(NULL,0,i+2)< LineDn[i+2] 
&& iClose(NULL,0,i+1)< LineDn[i+1])
  return true;

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