//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76015

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0" 

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 clrLightSeaGreen
#property indicator_color2 clrRed
#property indicator_level1 80
#property indicator_level2 20
#property indicator_maximum 100
#property indicator_minimum 0

//
//
//
//
//

extern int            StoKPeriod       = 14;
extern int            StoDPeriod       = 3;
extern int            StoSlowing       = 3;
extern ENUM_STO_PRICE PriceField       = 0;
extern ENUM_MA_METHOD SignalMode       = MODE_SMA;
extern double         levelOb          = 75;
extern double         levelOs          = 25;
extern bool           alertsOn         = true;
extern bool           alertsOnCurrent  = true;
extern bool           alertsMessage    = true;
extern bool           alertsSound      = true;
extern bool           alertsNotify     = false;
extern bool           alertsEmail      = false;
extern string         soundFile        = "alert2.wav";
extern bool           ShowArrows       = true;
extern string         arrowsIdentifier = "stoch Arrows1";
extern double         arrowsUpperGap   = 0.5;
extern double         arrowsLowerGap   = 0.5;
extern color          arrowsUpColor    = clrLimeGreen;
extern color          arrowsDnColor    = clrRed;
extern int            arrowsUpCode     = 241;
extern int            arrowsDnCode     = 242;

//
//
//
//
//

double sto[];
double sig[];
double trend[];

double filter[];

//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
//
//
//
//
//

int init()
{
    IndicatorBuffers(4);
    SetIndexBuffer(0, sto);
    SetIndexBuffer(1, sig);
    SetIndexBuffer(2, trend);
    SetIndexBuffer(3, filter);
    SetLevelValue(0, levelOs);
    SetLevelValue(1, levelOb);

    IndicatorShortName("Stochastic (" + StoKPeriod + "," + StoDPeriod + "," + StoSlowing + ")");
    return (0);
}
int deinit()
{
    deleteArrows();
    return (0);
}

//+------------------------------------------------------------------
//|
//+------------------------------------------------------------------
//
//
//
//
//

int start()
{
    int counted_bars = IndicatorCounted();
    if (counted_bars < 0) return (-1);
    if (counted_bars > 0) counted_bars--;
    int limit = MathMin(Bars - counted_bars, Bars - 1);

    //
    //
    //
    //
    //

    for (int i = limit; i >= 0; i--) {
        sto[i]   = iStochastic(NULL, 0, StoKPeriod, StoDPeriod, StoSlowing, SignalMode, PriceField, MODE_MAIN, i);
        sig[i]   = iStochastic(NULL, 0, StoKPeriod, StoDPeriod, StoSlowing, SignalMode, PriceField, MODE_SIGNAL, i);
        trend[i] = 0;
        if (sto[i] > levelOb) trend[i] = 1;
        if (sto[i] < levelOs) trend[i] = -1;

        // --- Lógica de filtro usando trend.mq4 ---
        double trendUp = iCustom(NULL, 0, "trend", 1, i); // buffer 0 de trend.mq4
        double trendDn = iCustom(NULL, 0, "trend", 2, i); // buffer 1 de trend.mq4

        filter[i] = 0;
        if (trendUp > 0.0 && trendUp != EMPTY_VALUE)
            filter[i] = 1;
        if(trendDn > 0.0 && trendDn != EMPTY_VALUE)
            filter[i] = -1;

        if (ShowArrows) {
            deleteArrow(Time[i]);
            if (trend[i] != trend[i + 1]) {
                if (filter[i] == -1) {
                    if (trend[i + 1] == 1 && trend[i] != 1) drawArrow(i, arrowsDnColor, arrowsDnCode, true);
                }

                if (filter[i] == 1) {
                    if (trend[i + 1] == -1 && trend[i] != -1) drawArrow(i, arrowsUpColor, arrowsUpCode, false);
                }
            }
        }
    }

    //
    //
    //
    //
    //

    if (alertsOn) {
        if (alertsOnCurrent)
            int whichBar = 0;
        else
            whichBar = 1;
        if (trend[whichBar] != trend[whichBar + 1]) {
            if (trend[whichBar + 1] == 1 && trend[whichBar] != 1) doAlert(whichBar, "sell");
            if (trend[whichBar + 1] == -1 && trend[whichBar] != -1) doAlert(whichBar, "buy");
        }
    }
    return (0);
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
    static string   previousAlert = "nothing";
    static datetime previousTime;
    string          message;

    if (previousAlert != doWhat || previousTime != Time[forBar]) {
        previousAlert = doWhat;
        previousTime  = Time[forBar];

        //
        //
        //
        //
        //

        message = StringConcatenate(Symbol(), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " Stochastic ", doWhat);
        if (alertsMessage) Alert(message);
        if (alertsNotify) SendNotification(message);
        if (alertsEmail) SendMail(StringConcatenate(Symbol(), " Stochastic "), message);
        if (alertsSound) PlaySound(soundFile);
    }
}

//
//
//
//
//

void drawArrow(int i, color theColor, int theCode, bool up)
{
    string name = arrowsIdentifier + ":" + Time[i];
    double gap  = 3.0 * iATR(NULL, 0, 20, i);

    //
    //
    //
    //
    //

    ObjectCreate(name, OBJ_ARROW, 0, Time[i], 0);
    ObjectSet(name, OBJPROP_ARROWCODE, theCode);
    ObjectSet(name, OBJPROP_COLOR, theColor);
    if (up)
        ObjectSet(name, OBJPROP_PRICE1, High[i] + arrowsUpperGap * gap);
    else
        ObjectSet(name, OBJPROP_PRICE1, Low[i] - arrowsLowerGap * gap);
}

//
//
//
//
//

void deleteArrows()
{
    string lookFor       = arrowsIdentifier + ":";
    int    lookForLength = StringLen(lookFor);
    for (int i = ObjectsTotal() - 1; i >= 0; i--) {
        string objectName = ObjectName(i);
        if (StringSubstr(objectName, 0, lookForLength) == lookFor) ObjectDelete(objectName);
    }
}
void deleteArrow(datetime time)
{
    string lookFor = arrowsIdentifier + ":" + time;
    ObjectDelete(lookFor);
}
//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76015

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 