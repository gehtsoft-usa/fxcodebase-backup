// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74674

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
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

#property indicator_buffers 6
#property indicator_plots 6
#property indicator_label1 "High Month"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label2 "Low Month"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrGreen
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2
#property indicator_label3 "High Week"
#property indicator_type3  DRAW_LINE
#property indicator_color3 clrRoyalBlue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 2
#property indicator_label4 "Low Week"
#property indicator_type4  DRAW_LINE
#property indicator_color4 clrRoyalBlue
#property indicator_style4 STYLE_SOLID
#property indicator_width4 2
#property indicator_label5 "Midle Month"
#property indicator_type5  DRAW_LINE
#property indicator_color5 clrGreen
#property indicator_style5 STYLE_DOT
#property indicator_width5 1
#property indicator_label6 "Midle Week"
#property indicator_type6  DRAW_LINE
#property indicator_color6 clrRoyalBlue
#property indicator_style6 STYLE_DOT
#property indicator_width6 1

// NOTE: Inputs
// ------------------------------------------------------------------

string T1                    = "== Notifications ==";  // Notifications
bool   notifications         = false;                  // Notifications On?
bool   desktop_notifications = false;                  // Desktop MT4 Notifications
bool   email_notifications   = false;                  // Email Notifications
bool   push_notifications    = false;                  // Push Mobile Notifications

// NOTE: Buffers
//--- indicator buffers
double lineUp_month[];
double lineDn_month[];
double lineUp_week[];
double lineDn_week[];
double lineMd_week[];
double lineMd_month[];

// NOTE: Objects
// ------------------------------------------------------------------
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
    _initialCandles = iBars(NULL, Period());
    _symbol         = NULL;
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

// ------------------------------------------------------------------
void OnInit()
{
  //--- indicator short name
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
  
  SetIndexBuffer(0, lineUp_month);
  SetIndexBuffer(1, lineDn_month);
  SetIndexBuffer(2, lineUp_week);
  SetIndexBuffer(3, lineDn_week);
  SetIndexBuffer(4, lineMd_month);
  SetIndexBuffer(5, lineMd_week);

}
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


    ArrayInitialize( lineUp_month, EMPTY_VALUE);
    ArrayInitialize( lineDn_month, EMPTY_VALUE);
    ArrayInitialize(lineUp_week, EMPTY_VALUE);
    ArrayInitialize(lineDn_week, EMPTY_VALUE);
    ArrayInitialize(lineMd_month, EMPTY_VALUE);
    ArrayInitialize(lineMd_week, EMPTY_VALUE);
    
    datetime tm_month =  iTime(NULL, PERIOD_MN1, 1);
    datetime tm_week =  iTime(NULL, PERIOD_W1, 1);
    
    int bar_month = iBarShift(NULL, PERIOD_MN1, tm_month, false);
    int bar_week = iBarShift(NULL, PERIOD_W1, tm_week, false);
    
    int ini_bar_month =iBars(NULL, 0) - iBarShift(NULL, 0, tm_month, false);
    int ini_bar_week =iBars(NULL, 0) - iBarShift(NULL, 0, tm_week, false);
    
    double hiMonth = iHigh(NULL, PERIOD_MN1, bar_month);
    double loMonth = iLow(NULL, PERIOD_MN1, bar_month); 
    
    double hiWeek = iHigh(NULL, PERIOD_W1, bar_week);
    double loWeek = iLow(NULL, PERIOD_W1, bar_week);

    for(int i = ini_bar_month; i < rates_total; i++)
    {
        lineUp_month[i]  = hiMonth;
        lineDn_month[i]  = loMonth;
        lineMd_month[i]  = (hiMonth+loMonth)/2;
    }
    for(int j = ini_bar_week; j < rates_total; j++)
    {   
        lineUp_week[j] = hiWeek;
        lineDn_week[j] = loWeek;
        lineMd_week[j] = (hiWeek+loWeek)/2;
    }

  return (rates_total);
}
// ------------------------------------------------------------------







void Notifications(int type)
{
  string text = "";
  if (type == 0)
    text += _Symbol + " " + GetTimeFrame(_Period) + " Signal UP ";
  else
    text += _Symbol + " " + GetTimeFrame(_Period) + " Signal DOWN ";

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