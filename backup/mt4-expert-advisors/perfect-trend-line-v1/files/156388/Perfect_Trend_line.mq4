// Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=156259#p156259

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 7

// Mark: buffers
double LineUpSlow[];
double LineDnSlow[];
double LineUpFast[];
double LineDnFast[];
double ArrowUp[];
double ArrowDn[];
double Trend[];

// ------------------------------------------------------------------

input int inpFastLength = 3; // Fast length
input int inpSlowLength = 7; // Slow length

input string T1                    = "== Notifications =="; // === Notifications ===
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
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

// Mark: Oninit
int OnInit()
{
    SetIndexBuffer(0, LineUpSlow, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2, RoyalBlue);
    SetIndexLabel(0, "Line Up Slow");

    SetIndexBuffer(1, LineDnSlow, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2, Crimson);
    SetIndexLabel(1, "Line Dn Slow");

    SetIndexBuffer(2, LineUpFast, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_LINE, STYLE_DOT, 1, RoyalBlue);
    SetIndexLabel(2, "Line Up Fast");

    SetIndexBuffer(3, LineDnFast, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_LINE, STYLE_DOT, 1, Crimson);
    SetIndexLabel(3, "Line Dn Fast");

    SetIndexBuffer(4, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(4, 108);
    SetIndexStyle(4, DRAW_ARROW, EMPTY, 1, RoyalBlue);
    SetIndexLabel(4, "Arrow Up");

    SetIndexBuffer(5, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(5, DRAW_ARROW, EMPTY, 1, Crimson);
    SetIndexArrow(5, 108);
    SetIndexLabel(5, "Arrow Dn");

    SetIndexBuffer(6, Trend);
    SetIndexStyle(6, DRAW_NONE);

    return (INIT_SUCCEEDED);
}

// Mark: ontick
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start, i;
    if (prev_calculated == 0) {
        start = rates_total - inpSlowLength;        
    } else {
        start = rates_total - (prev_calculated - 1);
    }

    for (i = start; i >= 0; i--) {
        
        if (prev_calculated == 0) { Trend[i] = 1; } else { Trend[i] = Trend[i+1]; }

        double slowhi = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, inpSlowLength, i+1));
        double slowlo = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, inpSlowLength, i+1));
        double fasthi = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, inpFastLength, i+1));
        double fastlo = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, inpFastLength, i+1));

        LineDnSlow[i] = slowlo;
        LineDnFast[i] = fastlo;
        LineUpSlow[i] = slowhi;
        LineUpFast[i] = fasthi;


        if(close[i+1]>LineUpSlow[i+1]) 
        {
            Trend[i] = 1; // up
        } else if(close[i+1]<LineDnSlow[i+1]) 
        {
            Trend[i] = -1; // dn
        }

        if (Trend[i] == 1)
        {
            if (Trend[i+1] == -1)
            {
                LineDnSlow[i+1] = slowlo;
                LineDnFast[i+1] = fastlo;
                ArrowDn[i+1]    = slowlo;
                notify(0);

            }
            LineDnSlow[i] = MathMax(LineDnSlow[i],LineDnSlow[i+1]);
            LineDnFast[i] = MathMax(LineDnFast[i],LineDnFast[i+1]);
            LineUpSlow[i] = EMPTY_VALUE;
            LineUpFast[i] = EMPTY_VALUE;
        }

        if (Trend[i] == -1)
        {
            if (Trend[i+1] == 1)
            {
                LineUpSlow[i+1] = slowhi;
                LineUpFast[i+1] = fasthi;
                ArrowUp[i+1]    = slowhi;
                notify(1);
            }
            LineUpSlow[i] = MathMin(LineUpSlow[i],LineUpSlow[i+1]);
            LineUpFast[i] = MathMin(LineUpFast[i],LineUpFast[i+1]);
            LineDnSlow[i] = EMPTY_VALUE;
            LineDnFast[i] = EMPTY_VALUE;
        }
        


    }
    return (rates_total);
}

void notify(int type)
{
    if (newCandle.IsNewCandle()) {
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

    if (!notifications) return;
    if (desktop_notifications) Alert(text);
    if (push_notifications) SendNotification(text);
    if (email_notifications) SendMail("MetaTrader Notification", text);
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