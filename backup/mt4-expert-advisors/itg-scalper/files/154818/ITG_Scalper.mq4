//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74730

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 8
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

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];
double LineUp[];
double LineDn[];

extern int       EMA_period=14;
input string             IMACD = "== MACD Setup ==";      // == MACD Setup ==
input int                fast_ema_period = 12;           // fast ema period:
input int                slow_ema_period = 26;           // slow ema period:
input int                signal_period   = 9;            // signal period:
input ENUM_APPLIED_PRICE applied_price   = PRICE_CLOSE;  // applied price:

//---- buffers
double TemaBuffer[];
double Ema[];
double EmaOfEma[];
double EmaOfEmaOfEma[];

int lookfor=0;

input string T1                    = "== Notifications ==";  // === Notifications ===
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Lines ==";      // === Set  Lines ===
input color  LineUpClr             = clrBlue;                // Line Up Color:
input color  LineDnClr             = clrRed;                 // Line Down Color:
input string T3                    = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color:



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
  //---- indicators

  //--- indicator buffers mapping
  SetIndexBuffer(0, LineUp, INDICATOR_DATA);
  SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, LineUpClr);
  SetIndexLabel(0, "Line Up");

  SetIndexBuffer(1, LineDn, INDICATOR_DATA);
  SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, LineDnClr);
  SetIndexLabel(1, "Line Dn");

 SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
  SetIndexArrow(2, 233);
  SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
  SetIndexLabel(2, "Arrow Up");

 SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
  SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
  SetIndexArrow(3, 234);
  SetIndexLabel(3, "Arrow Dn");

  if (!ArrowsOn)
  {
    SetIndexStyle(2, DRAW_NONE);
    SetIndexStyle(3, DRAW_NONE);
  }

   SetIndexBuffer(4,TemaBuffer);
   SetIndexBuffer(5,Ema);
   SetIndexBuffer(6,EmaOfEma);
   SetIndexBuffer(7,EmaOfEmaOfEma);
    
   SetIndexStyle(4, DRAW_NONE);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexStyle(6, DRAW_NONE);
   SetIndexStyle(7, DRAW_NONE);
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
  if (prev_calculated == 0) {
    start = rates_total - EMA_period-1;
  } else
  {
    start = rates_total - (prev_calculated - 1);
  }

  for (i = start; i >= 0; i--)
  {
   Ema[i]=iMA(NULL,0,EMA_period,0,MODE_EMA,PRICE_CLOSE,i);
   EmaOfEma[i]=iMAOnArray(Ema,0,EMA_period,0,MODE_EMA,i);
   EmaOfEmaOfEma[i]=iMAOnArray(EmaOfEma,0,EMA_period,0,MODE_EMA,i);
   TemaBuffer[i]=3*Ema[i]-3*EmaOfEma[i]+EmaOfEmaOfEma[i];


    if (ConditionsToLineUp(i))
    {
      LineUp[i] = TemaBuffer[i];
      LineDn[i] = EMPTY_VALUE;
    
      if(LineUp[i+1] == EMPTY_VALUE)
      {
        LineUp[i+1] = TemaBuffer[i+1];     
      }
    }

    // if (haveSignalUp(i))
        if(lookfor ==1 && MACD_Main(i)>=MACD_Signal(i)){
        lookfor = 0;
        ArrowUp[i] = Low[i];
        notify(0);
    }
    
    if (ConditionsToLineDn(i))
    {
      LineUp[i] = EMPTY_VALUE;
      LineDn[i] = TemaBuffer[i];

      if(LineDn[i+1] == EMPTY_VALUE)
      {
        LineDn[i+1] = TemaBuffer[i+1];       
      }
    }
    
    // if (haveSignalDown(i))
  
        if(lookfor ==0 && MACD_Main(i)<MACD_Signal(i)){
        ArrowDn[i] = High[i];
        lookfor=1;
        notify(1);
        }
  
  
  }
  return (rates_total);
}

// ------------------------------------------------------------------

bool ConditionsToLineUp(int i)
{
  return TemaBuffer[i]>=TemaBuffer[i+1];
}

bool ConditionsToLineDn(int i)
{
   return TemaBuffer[i]<TemaBuffer[i+1];
}

double MACD_Main(int i)
{
  return iMACD(NULL, 0, fast_ema_period, slow_ema_period, signal_period, applied_price, 0, i);
}
double MACD_Signal(int i)
{
  return iMACD(NULL, 0, fast_ema_period, slow_ema_period, signal_period, applied_price, 1, i);
}






bool haveSignalUp(int i)
{
  // TODO: signal up
  return (iClose(NULL, 0, i + 2) > iOpen(NULL, 0, i + 2) && iClose(NULL, 0, i + 1) > iOpen(NULL, 0, i + 1));
  // return true;
}

bool haveSignalDown(int i)
{
  // TODO: signal down
  return (iClose(NULL, 0, i + 2) < iOpen(NULL, 0, i + 2) && iClose(NULL, 0, i + 1) < iOpen(NULL, 0, i + 1));
  // return true;
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