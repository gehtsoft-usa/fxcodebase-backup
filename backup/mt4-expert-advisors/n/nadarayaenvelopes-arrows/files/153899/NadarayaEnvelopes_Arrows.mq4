// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=74508

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
#property strict
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots 2
#property indicator_label1 "Line Up"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrLime
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label2 "Line Down"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2

#define NOTIFY

//--- indicator buffers
double LineUp[];
double LineDn[];
double ArrowUp[];
double ArrowDn[];
double sum_e[];

// ------------------------------------------------------------------
input string T0                    = "== Setups ==";         // == Setups ==
input int    length                = 50;                     // length:
input int    h                     = 8;                      // Bandwidth:
input int    mult                  = 3;                      // Multiplier:
input string T2                    = "== Set Lines ==";      // === Set  Lines ===
input bool   LinesOn               = true;                   // Line On?
input color  LineUpClr             = clrLimeGreen;           // Line Up Color:
input color  LineDnClr             = clrRed;                 // Line Down Color:


#ifdef NOTIFY

input string T1                    = "== Notifications ==";  // === Notifications ===
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications

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
#endif

// ------------------------------------------------------------------
int OnInit()
{
  //--- indicator buffers mapping
  SetIndexBuffer(0, LineUp, INDICATOR_DATA);
  SetIndexArrow(0, 233);
  SetIndexStyle(0, DRAW_LINE, EMPTY, 2, LineUpClr);
  SetIndexBuffer(1, LineDn, INDICATOR_DATA);
  SetIndexStyle(1, DRAW_LINE, EMPTY, 2, LineDnClr);
  SetIndexArrow(1, 234);

  if(!LinesOn)
  {
    SetIndexStyle(0, DRAW_NONE);
    SetIndexStyle(1, DRAW_NONE);
  }

  SetIndexBuffer(2, sum_e);

 SetIndexBuffer(3, ArrowUp, INDICATOR_DATA);
  SetIndexArrow(3, 233);
  SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, RoyalBlue);
  SetIndexLabel(3, "Arrow Up");

 SetIndexBuffer(4, ArrowDn, INDICATOR_DATA);
  SetIndexStyle(4, DRAW_ARROW, EMPTY, 1, Crimson);
  SetIndexArrow(4, 234);
  SetIndexLabel(4, "Arrow Dn");

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
  

  int i, start;
  if (prev_calculated == 0)
  {
    start = rates_total - length;
  } else
  {
    start = rates_total - (prev_calculated - 1);
  }

  for (i = start; i >= 0; i--)
  {
  
		double w, sum, sumw;
    for (int j = 0; j < length; j++)
    {
      w = MathExp(-(pow(j, 2) / (h * h * 2)));
      sum += Close[i + j] * w;
      sumw += w;
    }

    double y2 = sum / sumw;
    sum_e[i] = fabs(Close[i] - y2);

    // sumar los valores del buffer sum_e, para los periodos length desde el actual
    double sum_values;
    for (int j = 0; j < length; j++)
    {
      sum_values += sum_e[i + j];
    }

    double distance = sum_values / length * mult;
    LineUp[i] = y2 + distance;
    LineDn[i] = y2 - distance;

    if(close[i+1] > LineUp[i+1] && close[i] < LineUp[i])
    {
        ArrowDn[i] = High[i];
        if(newCandle.IsNewCandle()) Notifications(1);
    }
    if(close[i+1] < LineDn[i+1] && close[i] > LineDn[i])
    {
        ArrowUp[i] = Low[i];
        if(newCandle.IsNewCandle()) Notifications(0);
    }
  }


  
  return (rates_total);
}

// ------------------------------------------------------------------
#ifdef NOTIFY

bool haveSignalUp(int i)
{
  // TODO: signal up

  // "Strong Up Trend";
  // DMI+ / DMI Level CrossOver
  // ADX > ADX Level
  // ADM+ > DMI-
  // if (adx.bull(i) == true && adx.PlusDiCrossLevel(i) == true && adx.Main(i) > AdxLevelMain)
  // {
    
    return true;
  // }

  // return false;
}

bool haveSignalDown(int i)
{
  // TODO: signal down

  // "Strong Down Trend";
  // DMI- / DMI Level CrossOver
  // ADX > ADX Level
  // ADM+ < DMI-
  // if (adx.bear(i) == true && adx.MinusDiCrossLevel(i)== true && adx.Main(i) > AdxLevelMain)
  // {
  return true;
  // }

  // return false;
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
#endif

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+