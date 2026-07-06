//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74507

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
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  PaleVioletRed
#property indicator_color2  DimGray
#property indicator_width1  2
#property indicator_style2  STYLE_DASHDOTDOT
#property indicator_levelcolor DimGray
#property strict

enum enPrices
{
    pr_close,      // Close
    pr_open,       // Open
    pr_high,       // High
    pr_low,        // Low
    pr_median,     // Median
    pr_typical,    // Typical
    pr_weighted,   // Weighted
    pr_average,    // Average (high+low+open+close)/4
    pr_medianb,    // Average median body (open+close)/2
    pr_tbiased,    // Trend biased price
    pr_haclose,    // Heiken ashi close
    pr_haopen,    // Heiken ashi open
    pr_hahigh,     // Heiken ashi high
    pr_halow,      // Heiken ashi low
    pr_hamedian,   // Heiken ashi median
    pr_hatypical,  // Heiken ashi typical
    pr_haweighted, // Heiken ashi weighted
    pr_haaverage,  // Heiken ashi average
    pr_hamedianb,  // Heiken ashi median body
    pr_hatbiased   // Heiken ashi trend biased price
};

extern string   UniqueID = "Laguerre rsi & filter 1"; // Indicator unique ID
extern double   RsiGamma = 0.80;           // Laguerre RSI gamma
extern enPrices RsiPrice = 0;              // Price
extern double   RsiSmoothGamma = 0.001;          // Laguerre RSI smooth gamma
extern int      RsiSmoothSpeed = 2;              // Laguerre RSI smooth speed (min 0, max 6)
extern double   FilterGamma = 0.60;           // Laguerre filter gamma
extern int      FilterSpeed = 2;              // Laguerre filter speed (min 0, max 6)
extern double   LevelUp = 0.85;           // Level up
extern double   LevelDown = 0.15;           // Level down
extern bool     NoTradeZoneVisible = true;           // Display no trade zone?
extern double   NoTradeZoneUp = 0.65;           // No trade zone up
extern double   NoTradeZoneDown = 0.35;           // No trade zone down
extern color    NoTradeZoneColor = C'255,238,210'; // No trade zone color
extern color    NoTradeZoneTextColor = Black;          // No trade zone text color

//
//
//
//
//

double lag [], fil []; string shortName;

//------------------------------------------------------------------
#define NOTIFY_ON
#ifdef NOTIFY_ON

input string T1 = "== Notifications ==";  // === Notifications ===
input bool   notifications = true;                  // Notifications On?
input bool   desktop_notifications = true;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications

bool IsNewCandle()
{
    static datetime saved_candle_time;
    if(saved_candle_time == 0)
    {
        saved_candle_time = iTime(NULL, 0, 0);
        return false;
    }

    if(iTime(NULL, 0, 0) == saved_candle_time)
    {
        return false;
    }
    else
    {
        saved_candle_time = iTime(NULL, 0, 0);
        return true;
    }
    return false;
}

void notify(string side)
{
    if(!notifications) return;
    if(IsNewCandle()) { Notifications(side); }
}

void Notifications(string side)
{
    string text = "";
    if(side == "buy")  text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    if(side == "sell") text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

    if(desktop_notifications) Alert(text);
    if(push_notifications)    SendNotification(text);
    if(email_notifications)   SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch(lPeriod)
    {
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
#endif
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

// NOTE: oninit
int init()
{
    SetIndexBuffer(0, lag);
    SetIndexBuffer(1, fil);
    SetLevelValue(0, LevelUp);
    SetLevelValue(1, LevelDown);
    shortName = UniqueID + ": (" + DoubleToStr(RsiGamma, 2) + "," + DoubleToStr(RsiSmoothGamma, 2) + ") filter (" + DoubleToStr(FilterGamma, 2) + ")";
    IndicatorShortName(shortName);
    return(0);
}
int deinit() { ObjectsDeleteAll(0, UniqueID + ":"); return(0); }

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
    int counted_bars = IndicatorCounted();
    if(counted_bars < 0) return(-1);
    if(counted_bars > 0) counted_bars--;
    int limit = MathMin(Bars - counted_bars - 1, Bars - 2);

    //
    //
    //
    //
    //

    for(int i = limit; i >= 0; i--)
    {
        lag[i] = LaGuerreRsi(getPrice(RsiPrice, Open, Close, High, Low, i), RsiGamma, RsiSmoothGamma, RsiSmoothSpeed, i);
        fil[i] = LaGuerreFil(lag[i], FilterGamma, FilterSpeed, i);

        if(lag[i + 1] > LevelUp && lag[i] < LevelUp)     { notify("sell"); }
        if(lag[i + 1] < LevelDown && lag[i] > LevelDown) { notify("buy");  }

    }

    //
    //
    //
    //
    //

    if(NoTradeZoneVisible)
    {
        string name = UniqueID + ":zone";
        int    window = WindowFind(shortName);
        if(ObjectFind(name) == -1)
            ObjectCreate(name, OBJ_RECTANGLE, window, 0, 0, 0, 0);
        ObjectSet(name, OBJPROP_TIME1, Time[Bars - 1]);
        ObjectSet(name, OBJPROP_TIME2, Time[0]);
        ObjectSet(name, OBJPROP_PRICE1, NoTradeZoneUp);
        ObjectSet(name, OBJPROP_PRICE2, NoTradeZoneDown);
        ObjectSet(name, OBJPROP_COLOR, NoTradeZoneColor);
        ObjectSet(name, OBJPROP_BACK, true);
        name = UniqueID + ":text";
        if(ObjectFind(name) == -1)
            ObjectCreate(name, OBJ_TEXT, window, 0, 0);
        ObjectSet(name, OBJPROP_TIME1, Time[0] + 30 * Period() * 60);
        ObjectSet(name, OBJPROP_PRICE1, (NoTradeZoneUp + NoTradeZoneDown) / 2.0);
        ObjectSet(name, OBJPROP_COLOR, NoTradeZoneTextColor);
        ObjectSetText(name, "no-trade zone " + DoubleToStr(NoTradeZoneDown, 2) + ":" + DoubleToStr(NoTradeZoneUp, 2), 10, "Courier new");
    }
    return(0);
}




//+------------------------------------------------------------------
//|                                                                  
//+------------------------------------------------------------------
//
//
//
//
//
//

double workHa [][4];
double getPrice(int price, const double& open [], const double& close [], const double& high [], const double& low [], int i, int instanceNo = 0)
{
    if(price >= pr_haclose && price <= pr_hatbiased)
    {
        if(ArrayRange(workHa, 0) != Bars) ArrayResize(workHa, Bars);
        int r = Bars - i - 1;

        //
        //
        //
        //
        //

        double haOpen;
        if(r > 0)
            haOpen = (workHa[r - 1][instanceNo + 2] + workHa[r - 1][instanceNo + 3]) / 2.0;
        else   haOpen = (open[i] + close[i]) / 2;
        double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
        double haHigh = MathMax(high[i], MathMax(haOpen, haClose));
        double haLow = MathMin(low[i], MathMin(haOpen, haClose));

        if(haOpen < haClose) { workHa[r][instanceNo + 0] = haLow;  workHa[r][instanceNo + 1] = haHigh; }
        else                 { workHa[r][instanceNo + 0] = haHigh; workHa[r][instanceNo + 1] = haLow; }
        workHa[r][instanceNo + 2] = haOpen;
        workHa[r][instanceNo + 3] = haClose;
        //
        //
        //
        //
        //

        switch(price)
        {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh + haLow) / 2.0);
            case pr_hamedianb:   return((haOpen + haClose) / 2.0);
            case pr_hatypical:   return((haHigh + haLow + haClose) / 3.0);
            case pr_haweighted:  return((haHigh + haLow + haClose + haClose) / 4.0);
            case pr_haaverage:   return((haHigh + haLow + haClose + haOpen) / 4.0);
            case pr_hatbiased:
                if(haClose > haOpen)
                    return((haHigh + haClose) / 2.0);
                else  return((haLow + haClose) / 2.0);
        }
    }

    //
    //
    //
    //
    //

    switch(price)
    {
        case pr_close:     return(close[i]);
        case pr_open:      return(open[i]);
        case pr_high:      return(high[i]);
        case pr_low:       return(low[i]);
        case pr_median:    return((high[i] + low[i]) / 2.0);
        case pr_medianb:   return((open[i] + close[i]) / 2.0);
        case pr_typical:   return((high[i] + low[i] + close[i]) / 3.0);
        case pr_weighted:  return((high[i] + low[i] + close[i] + close[i]) / 4.0);
        case pr_average:   return((high[i] + low[i] + close[i] + open[i]) / 4.0);
        case pr_tbiased:
            if(close[i] > open[i])
                return((high[i] + close[i]) / 2.0);
            else  return((low[i] + close[i]) / 2.0);
    }
    return(0);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workLagRsi [][15];
double LaGuerreRsi(double price, double gamma, double smooth, double smoothSpeed, int i, int instanceNo = 0)
{
    if(ArrayRange(workLagRsi, 0) != Bars) ArrayResize(workLagRsi, Bars); int r = i; i = Bars - i - 1; instanceNo *= 5;

    //
    //
    //
    //
    //

    workLagRsi[i][instanceNo + 0] = (i > 0) ? (1.0 - gamma) * price + gamma * workLagRsi[i - 1][instanceNo + 0] : price;
    workLagRsi[i][instanceNo + 1] = (i > 0) ? -gamma * workLagRsi[i][instanceNo + 0] + workLagRsi[i - 1][instanceNo + 0] + gamma * workLagRsi[i - 1][instanceNo + 1] : price;
    workLagRsi[i][instanceNo + 2] = (i > 0) ? -gamma * workLagRsi[i][instanceNo + 1] + workLagRsi[i - 1][instanceNo + 1] + gamma * workLagRsi[i - 1][instanceNo + 2] : price;
    workLagRsi[i][instanceNo + 3] = (i > 0) ? -gamma * workLagRsi[i][instanceNo + 2] + workLagRsi[i - 1][instanceNo + 2] + gamma * workLagRsi[i - 1][instanceNo + 3] : price;

    //
    //
    //
    //
    //

    double CU = 0.00;
    double CD = 0.00;
    if(i > 0)
    {
        if(workLagRsi[i][instanceNo + 0] >= workLagRsi[i][instanceNo + 1])
            CU = workLagRsi[i][instanceNo + 0] - workLagRsi[i][instanceNo + 1];
        else	   CD = workLagRsi[i][instanceNo + 1] - workLagRsi[i][instanceNo + 0];
        if(workLagRsi[i][instanceNo + 1] >= workLagRsi[i][instanceNo + 2])
            CU = CU + workLagRsi[i][instanceNo + 1] - workLagRsi[i][instanceNo + 2];
        else	   CD = CD + workLagRsi[i][instanceNo + 2] - workLagRsi[i][instanceNo + 1];
        if(workLagRsi[i][instanceNo + 2] >= workLagRsi[i][instanceNo + 3])
            CU = CU + workLagRsi[i][instanceNo + 2] - workLagRsi[i][instanceNo + 3];
        else	   CD = CD + workLagRsi[i][instanceNo + 3] - workLagRsi[i][instanceNo + 2];
    }
    if(CU + CD != 0)
        workLagRsi[i][instanceNo + 4] = CU / (CU + CD);
    else  workLagRsi[i][instanceNo + 4] = 0;

    //
    //
    //
    //
    //

    return(LaGuerreFil(workLagRsi[i][instanceNo + 4], smooth, (int) smoothSpeed, r, 1));
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workLagFil [][8];
double LaGuerreFil(double price, double gamma, int smoothSpeed, int i, int instanceNo = 0)
{
    if(ArrayRange(workLagFil, 0) != Bars) ArrayResize(workLagFil, Bars); i = Bars - i - 1; instanceNo *= 4;
    if(gamma <= 0) return(price);

    //
    //
    //
    //
    //

    workLagFil[i][instanceNo + 0] = (i > 0) ? (1.0 - gamma) * price + gamma * workLagFil[i - 1][instanceNo + 0] : price;
    workLagFil[i][instanceNo + 1] = (i > 0) ? -gamma * workLagFil[i][instanceNo + 0] + workLagFil[i - 1][instanceNo + 0] + gamma * workLagFil[i - 1][instanceNo + 1] : price;
    workLagFil[i][instanceNo + 2] = (i > 0) ? -gamma * workLagFil[i][instanceNo + 1] + workLagFil[i - 1][instanceNo + 1] + gamma * workLagFil[i - 1][instanceNo + 2] : price;
    workLagFil[i][instanceNo + 3] = (i > 0) ? -gamma * workLagFil[i][instanceNo + 2] + workLagFil[i - 1][instanceNo + 2] + gamma * workLagFil[i - 1][instanceNo + 3] : price;

    //
    //
    //
    //
    //

    double coeffs [] = { 0, 0, 0, 0 };
    smoothSpeed = MathMax(MathMin(smoothSpeed, 6), 0);
    switch(smoothSpeed)
    {
        case 0: coeffs[0] = 1; coeffs[1] = 1; coeffs[2] = 1; coeffs[3] = 1; break;
        case 1: coeffs[0] = 1; coeffs[1] = 1; coeffs[2] = 2; coeffs[3] = 1; break;
        case 2: coeffs[0] = 1; coeffs[1] = 2; coeffs[2] = 2; coeffs[3] = 1; break;
        case 3: coeffs[0] = 2; coeffs[1] = 2; coeffs[2] = 2; coeffs[3] = 1; break;
        case 4: coeffs[0] = 2; coeffs[1] = 3; coeffs[2] = 2; coeffs[3] = 1; break;
        case 5: coeffs[0] = 3; coeffs[1] = 3; coeffs[2] = 2; coeffs[3] = 1; break;
        case 6: coeffs[0] = 4; coeffs[1] = 3; coeffs[2] = 2; coeffs[3] = 1; break;
    }
    double sumc = 0; for(int k = 0; k < 4; k++) sumc += coeffs[k];
    return((coeffs[0] * workLagFil[i][instanceNo + 0] + coeffs[1] * workLagFil[i][instanceNo + 1] + coeffs[2] * workLagFil[i][instanceNo + 2] + coeffs[3] * workLagFil[i][instanceNo + 3]) / sumc);
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