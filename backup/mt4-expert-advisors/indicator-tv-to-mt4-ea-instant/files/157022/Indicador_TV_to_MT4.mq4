// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75288

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




#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 3
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
#property indicator_type2 DRAW_NONE
//--- indicator buffers
double ArrowUp[];
double ArrowDn[];
double xATRTrailingStop[];

//--- variables
double nLoss, xATR;

// ------------------------------------------------------------------
input double m                     = 2;                     // Key value:
input double atrPeriods            = 1;                    // ATR periods:
input bool   h                     = false;                 // Signals From Heinken Ashi Candles
input string T1                    = "== Notifications =="; // ————————————
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";    // ————————————
input bool   ArrowsOn              = true;                  // Arrows On?
input color  ArrowUpClr            = clrLime;               // Arrow Up Color:
input color  ArrowDnClr            = clrYellow;            // Arrow Down Color:

// ------------------------------------------------------------------

bool IsNewCandle()
{
    static datetime saved_candle_time;
    if (saved_candle_time == 0) {
        saved_candle_time = iTime(NULL, 0, 0);
        return false;
    }

    if (iTime(NULL, 0, 0) == saved_candle_time) {
        return false;
    } else {
        saved_candle_time = iTime(NULL, 0, 0);
        return true;
    }
    return false;
}

void notify(string side)
{
    if (!notifications) return;
    if (IsNewCandle()) { Notifications(side); }
}

void Notifications(string side)
{
    string text = "";
    if (side == "buy")
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    if (side == "sell")
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

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
    case PERIOD_M1: return ("M1");
    case PERIOD_M5: return ("M5");
    case PERIOD_M15: return ("M15");
    case PERIOD_M30: return ("M30");
    case PERIOD_H1: return ("H1");
    case PERIOD_H4: return ("H4");
    case PERIOD_D1: return ("D1");
    case PERIOD_W1: return ("W1");
    case PERIOD_MN1: return ("MN1");
    }
    return IntegerToString(lPeriod);
}

// ------------------------------------------------------------------
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexArrow(1, 234);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexBuffer(2, xATRTrailingStop);
    SetIndexStyle(2, DRAW_NONE);

    if (!ArrowsOn) {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }
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
    // int i = 1000;
    int start, i;
  if (prev_calculated == 0)
  {
    start = rates_total - 100;
  } else
  {
    start = rates_total - (prev_calculated - 1);
  }

  for (i = start; i > 0; i--){
        xATR  = iATR(NULL, 0, atrPeriods, i);
        nLoss = m * xATR;

        ArrowUp[i] = EMPTY_VALUE;
        ArrowDn[i] = EMPTY_VALUE;

        double cl  = close[i];
        double cl1 = close[i + 1];

        // clang-format off
        xATRTrailingStop[i] = cl > xATRTrailingStop[i + 1] && cl1 > xATRTrailingStop[i + 1] ? fmax(xATRTrailingStop[i + 1], cl - nLoss) :
            cl < xATRTrailingStop[i + 1] && cl1 < xATRTrailingStop[i + 1] ? fmin(xATRTrailingStop[i + 1], cl + nLoss) :
            cl > xATRTrailingStop[i + 1] ? cl - nLoss : cl + nLoss;

        bool crossUp = cl > xATRTrailingStop[i] && cl1 < xATRTrailingStop[i + 1];
        bool crossDn = cl < xATRTrailingStop[i] && cl1 > xATRTrailingStop[i + 1];

        if(cl > xATRTrailingStop[i] && crossUp == true)
        {
            ArrowUp[i] = low[i] - xATR / 2;
            if(ArrowUp[i]!=EMPTY_VALUE) { notify("buy"); }
        }

        if(cl < xATRTrailingStop[i] && crossDn == true)
        {
            ArrowDn[i] = high[i] + xATR / 2;
            if(ArrowDn[i]!=EMPTY_VALUE) { notify("sell");}
        }

    }

    return (rates_total);
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