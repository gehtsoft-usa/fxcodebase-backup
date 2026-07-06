//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76201

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 clrLimeGreen
#property indicator_color2 clrOrangeRed
#property indicator_color3 clrOrangeRed
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT; // Time frame to use
extern int             atrPeriod       = 10;             // Atr period
extern double          atrMultiplier   = 3.0;            // Atr multoplier
extern bool            alertsOn        = true;           // Turn alerts on?
extern bool            alertWhenTouch  = true;           // Alert when the price touches the SuperTrend line?
extern bool            alertsOnCurrent = false;          // Alerts on current (still opened) bar?
extern bool            alertsMessage   = true;           // Alerts should display a message?
extern bool            alertsSound     = false;          // Alerts should play a sound?
extern bool            alertsEmail     = false;          // Alerts should send an email?
extern bool            alertsNotify    = false;          // Alerts should send notification?
extern bool            Interpolate     = true;           // Interpolate in multi time frame mode?

double Trend[], TrendDa[], TrendDb[], Up[], Dn[], Direction[], count[];

string indicatorFileName;
#define _mtfCall(_buff, _ind)                                                                                                                                                                          \
    iCustom(NULL, TimeFrame, indicatorFileName, PERIOD_CURRENT, atrPeriod, atrMultiplier, alertsOn, alertsOnCurrent, alertsMessage, alertsSound, alertsEmail, alertsNotify, _buff, _ind)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
    IndicatorBuffers(7);
    SetIndexBuffer(0, Trend);
    SetIndexBuffer(1, TrendDa);
    SetIndexBuffer(2, TrendDb);
    SetIndexBuffer(3, Up);
    SetIndexBuffer(4, Dn);
    SetIndexBuffer(5, Direction);
    SetIndexBuffer(6, count);

    indicatorFileName = WindowExpertName();
    TimeFrame         = fmax(TimeFrame, _Period);

    IndicatorShortName(timeFrameToString(TimeFrame) + " SuperTrend");
    return (0);
}
int deinit() { return (0); }

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
    int i, counted_bars = IndicatorCounted();
    if (counted_bars < 0) return (-1);
    if (counted_bars > 0) counted_bars--;
    int limit = fmin(Bars - counted_bars, Bars - 1);
    count[0]  = limit;
    if (TimeFrame != _Period) {
        limit = (int)fmax(limit, fmin(Bars - 1, _mtfCall(6, 0) * TimeFrame / _Period));
        if (Direction[limit] == -1) CleanPoint(limit, TrendDa, TrendDb);
        for (i = limit; i >= 0 && !_StopFlag; i--) {
            int y        = iBarShift(NULL, TimeFrame, Time[i]);
            Trend[i]     = _mtfCall(0, y);
            TrendDa[i]   = EMPTY_VALUE;
            TrendDb[i]   = EMPTY_VALUE;
            Direction[i] = _mtfCall(5, y);

            //
            //
            //
            //
            //

            if (!Interpolate || (i > 0 && y == iBarShift(NULL, TimeFrame, Time[i - 1]))) continue;
#define _interpolate(buff) buff[i + k] = buff[i] + (buff[i + n] - buff[i]) * k / n
            int      n, k;
            datetime time = iTime(NULL, TimeFrame, y);
            for (n = 1; (i + n) < Bars && Time[i + n] >= time; n++)
                continue;
            for (k = 1; k < n && (i + n) < Bars && (i + k) < Bars; k++)
                _interpolate(Trend);
        }
        for (i = limit; i >= 0; i--)
            if (Direction[i] == -1) PlotPoint(i, TrendDa, TrendDb, Trend);
        return (0);
    }

    //
    //
    //
    //
    //

    if (Direction[limit] == -1) CleanPoint(limit, TrendDa, TrendDb);
    for (i = limit; i >= 0; i--) {
        double atr    = iATR(NULL, 0, atrPeriod, i);
        double cprice = Close[i];
        double mprice = iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_MEDIAN, i);
        Up[i]         = mprice + atrMultiplier * atr;
        Dn[i]         = mprice - atrMultiplier * atr;

        //
        //
        //
        //
        //

        TrendDa[i]   = EMPTY_VALUE;
        TrendDb[i]   = EMPTY_VALUE;
        Direction[i] = (i < Bars - 1) ? (cprice > Up[i + 1]) ? 1 : (cprice < Dn[i + 1]) ? -1 : Direction[i + 1] : 0;
        if (Direction[i] > 0) {
            Dn[i]    = MathMax(Dn[i], Dn[i + 1]);
            Trend[i] = Dn[i];
        } else {
            Up[i]    = MathMin(Up[i], Up[i + 1]);
            Trend[i] = Up[i];
        }
        if (Direction[i] == -1) PlotPoint(i, TrendDa, TrendDb, Trend);
    }
    manageAlerts();
    return (0);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int    iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

string timeFrameToString(int tf)
{
    for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
        if (tf == iTfTable[i]) return (sTfTable[i]);
    return ("");
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i, double &first[], double &second[])
{
    if (i >= Bars - 3) return;
    if ((second[i] != EMPTY_VALUE) && (second[i + 1] != EMPTY_VALUE))
        second[i + 1] = EMPTY_VALUE;
    else if ((first[i] != EMPTY_VALUE) && (first[i + 1] != EMPTY_VALUE) && (first[i + 2] == EMPTY_VALUE))
        first[i + 1] = EMPTY_VALUE;
}

void PlotPoint(int i, double &first[], double &second[], double &from[])
{
    if (i >= Bars - 2) return;
    if (first[i + 1] == EMPTY_VALUE)
        if (first[i + 2] == EMPTY_VALUE) {
            first[i]     = from[i];
            first[i + 1] = from[i + 1];
            second[i]    = EMPTY_VALUE;
        } else {
            second[i]     = from[i];
            second[i + 1] = from[i + 1];
            first[i]      = EMPTY_VALUE;
        }
    else {
        first[i]  = from[i];
        second[i] = EMPTY_VALUE;
    }
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
    if (alertsOn) {
        int whichBar = 1;
        if (alertsOnCurrent) whichBar = 0;
        if (Direction[whichBar] != Direction[whichBar + 1]) {
            if (Direction[whichBar] == 1) doAlert("sloping up");
            if (Direction[whichBar] == -1) doAlert("sloping down");
        }
    }
    if(alertWhenTouch)
    {
        if (Close[1] > Trend[1] && Close[0] <= Trend[0]) {
               doAlert("touched up");
         } else if (Close[1] < Trend[1] && Close[0] >= Trend[0]) {
               doAlert("touched down");
         }                     


    }
}

//
//
//
//
//

void doAlert(string doWhat)
{
    static string   previousAlert = "nothing";
    static datetime previousTime;
    string          message;

    if (previousAlert != doWhat || previousTime != Time[0]) {
        previousAlert = doWhat;
        previousTime  = Time[0];

        //
        //
        //
        //
        //

        message = StringConcatenate(Symbol(), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " - ", timeFrameToString(TimeFrame) + " SuperTrend ", doWhat);
        if (alertsMessage) Alert(message);
        if (alertsNotify) SendNotification(message);
        if (alertsEmail) SendMail(Symbol() + " SuperTrend", message);
        if (alertsSound) PlaySound("alert2.wav");
    }
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76201

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+