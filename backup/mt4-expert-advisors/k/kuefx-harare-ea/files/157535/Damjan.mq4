// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75412&p=157535#p157535

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                                       https://mario-jemic.com/ | 
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency |  Network             |  Address                                              |
//+------------------------------------------------+-----------------------------------------------+
//|  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
//|  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
//|  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
//|  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
//|  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
//|  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
//+------------------------------------------------+-----------------------------------------------+ 

#property copyright "Copyright ©Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "Line Up"
#property indicator_type1  DRAW_HISTOGRAM
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label2 "Line Down"
#property indicator_type2  DRAW_HISTOGRAM
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2

//--- indicator buffers
input int period = 10;

double LineUp[];
double LineDn[];

// ------------------------------------------------------------------
string       T1                    = "== Notifications ==";  // ————————————
bool         notifications         = false;                  // Notifications On?
bool         desktop_notifications = false;                  // Desktop MT4 Notifications
bool         email_notifications   = false;                  // Email Notifications
bool         push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Lines ==";      // ————————————
input bool   LinesOn               = true;                   // Line On?
input color  LineUpClr             = clrBlue;                // Line Up Color:
input color  LineDnClr             = clrRed;                 // Line Down Color:
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
  SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 2, LineUpClr);
  SetIndexBuffer(1, LineDn, INDICATOR_DATA);
  SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 2, LineDnClr);
  if (!LinesOn)
  {
    SetIndexStyle(0, DRAW_NONE);
    SetIndexStyle(1, DRAW_NONE);
  }
  //---
  return (INIT_SUCCEEDED);
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
  double prev, current;
  double Value1 = 0;
  double Fish1 = 0;
   
  if (prev_calculated == 0) { start = rates_total - 1; } else { start = rates_total - (prev_calculated - 1); }

  for (i = start; i >= 0; i--)
  {
      double MaxH  = high[ArrayMaximum(high, period, i)];
      double MinL  = low[ArrayMinimum(low, period, i)];
      double price = (high[i] + low[i]) / 2;
      double Value = 0.33 * 2 * ((price - MinL) / (MaxH - MinL) - 0.5) + 0.67 * Value1;     
      Value        = MathMin(MathMax(Value, -0.999), 0.999); 
    
    //   int index = rates_total - i - 1;
      double v = 0.5 * MathLog((1 + Value) / (1 - Value)) + 0.5 * Fish1;
      LineUp[i] = v > 0 ? v : EMPTY_VALUE;
      LineDn[i] = v < 0 ? v : EMPTY_VALUE;
      
      Value1 = Value;
      Fish1 = v;


    // if (haveSignalUp(i))
    // {
    //   LineUp[i] = Open[i];

    //   if (newCandle.IsNewCandle())
    //   {
    //     Notifications(0);
    //   }
    // }

    // if (haveSignalDown(i))
    // {
    //   LineDn[i] = Open[i];

    //   if (newCandle.IsNewCandle())
    //   {
    //     Notifications(1);
    //   }
    // }
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
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75412&p=157535#p157535

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                                       https://mario-jemic.com/ | 
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency |  Network             |  Address                                              |
//+------------------------------------------------+-----------------------------------------------+
//|  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
//|  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
//|  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
//|  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
//|  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
//|  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
//+------------------------------------------------+-----------------------------------------------+ 