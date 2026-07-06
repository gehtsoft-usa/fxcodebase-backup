//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=156943#p156943

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
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 2
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

// NOTE: Inputs
// ------------------------------------------------------------------
input    int         inp_zone_period            =  10;      // zone period
input    int         inp_amplitude_period       =  25;      // zone amplitude
input    double      inp_amplitude_coefficient  =  3;       // zone coefficient

//---- indicator buffers
double ArrowUp[];
double ArrowDn[];
double ZoneUp[];
double ZoneDn[];
double CurrMin[];
double CurrMax[];
double trend[];

// ------------------------------------------------------------------
input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications

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


#define Section_ATR
#ifdef Section_ATR

int  handle_atr = 0;
void setHandleATR() { handle_atr = iATR(NULL, 0, inp_amplitude_period); }

double ATR(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle;
    // int shift = candle;
    int copy  = CopyBuffer(handle_atr, 0, shift, 1, value);

    if (copy > 0) { return value[0]; }
    
    return -1;
}

#endif


// NOTE: OnInit
// ------------------------------------------------------------------
int OnInit()
{    
//   IndicatorBuffers(7);
  SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
  PlotIndexSetInteger(0, PLOT_ARROW, 233);
  PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 10);
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrBlue);

  SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
  PlotIndexSetInteger(1, PLOT_ARROW, 234);
  PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
  PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrRed);

  SetIndexBuffer(2,ZoneUp);
  SetIndexBuffer(3,ZoneDn);
  SetIndexBuffer(4,CurrMin);
  SetIndexBuffer(5,CurrMax);
  SetIndexBuffer(6,trend);

  setHandleATR();

  return (INIT_SUCCEEDED);
}


// NOTE: OnCalculate
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

  start = inp_zone_period*2;
  if (prev_calculated > 1) start = prev_calculated - 1;

  for (i = start; i < rates_total && !IsStopped(); i++) 
	{

        double  atr = ATR(i-1);

        double max=0;
        for (int j = 1; j < inp_zone_period; j++)
        {
            if(high[i-j] > max) max = high[i-j];
        }
    
        double min=0;
        for (int j = 1; j < inp_zone_period; j++)
        {
            if(min == 0 || low[i-j] < min) min = low[i-j];
        }


        CurrMin[i] = max - inp_amplitude_coefficient * atr;
        CurrMax[i] = min + inp_amplitude_coefficient * atr;
        trend[i] = trend[i-1];

      if(close[i] > CurrMax[i-1])trend[i]= 1;
      if(close[i] < CurrMin[i-1])trend[i]=-1;

      if(trend[i] >0) {
         if(CurrMin[i]<CurrMin[i-1])CurrMin[i]=CurrMin[i-1];
         ZoneUp[i]=CurrMin[i];
         ZoneDn[i]=EMPTY_VALUE;
      }

      if(trend[i] <0) {
         if(CurrMax[i]>CurrMax[i-1])CurrMax[i]=CurrMax[i-1];
         ZoneUp[i]=EMPTY_VALUE;
         ZoneDn[i]=CurrMax[i];
      }
    
        
        if(trend[i] != trend[i-1]) {
            if(trend[i] == 1) 
            {
               ArrowUp[i] = low[i] - atr;
               if (newCandle.IsNewCandle()) { Notifications(0); }
            }
            else
            {
               ArrowDn[i] = high[i] + atr;
               if (newCandle.IsNewCandle()) { Notifications(1); }
            }
         }
  }

  return (rates_total);
}
//+------------------------------------------------------------------+


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
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
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