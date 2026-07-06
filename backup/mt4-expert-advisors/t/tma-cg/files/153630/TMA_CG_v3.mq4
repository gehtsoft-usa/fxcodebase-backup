//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=152844

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
// #property strict 

//------
#property indicator_chart_window
#property indicator_buffers 8
//------
#property indicator_color1  clrLightSteelBlue  //clrDarkTurquoise
#property indicator_color2  clrDarkOrange  //clrRed
#property indicator_color3  clrDeepSkyBlue  //clrLimeGreen
#property indicator_color4  clrAqua  //clrWhite  //Blue
#property indicator_color5  clrOrange  //Gold  //clrMagenta  //Red
//------
#property indicator_width4  2
#property indicator_width5  2
//------
#property indicator_style1  STYLE_DOT

// NOTE: HULL inputs
// #property indicator_label7  "Hull"
// #property  indicator_type7   DRAW_LINE
// #property indicator_color7  clrMediumSeaGreen
// #property indicator_width7  2
// #property indicator_label8  "Hull - slope up"
// #property  indicator_type8   DRAW_LINE
// #property indicator_color8  clrOrangeRed
// #property indicator_width8  2
// #property indicator_label9  "Hull - slope down"
// #property  indicator_type9   DRAW_LINE
// #property indicator_color9  clrOrangeRed
// #property indicator_width9  2



// double val [], valda [], valdb [], valc [];

//
//
//
//
//


extern string TimeFrame = "Current TimeFrame";
extern int    HalfLength = 24;  //56;
extern ENUM_APPLIED_PRICE Price = PRICE_WEIGHTED;
extern double Deviation = 2.5;
extern bool   Interpolate = false;
extern bool   MA_filter = true;
extern int    MA_Period = 200;
extern ENUM_MA_METHOD MA_Method = 0;
extern ENUM_APPLIED_PRICE MA_Price = 0;
extern int    ARROWBAR = 0,
ArrUP = 233,  //241,
ArrDN = 234;  //242;
extern bool   alertsOn = false;
extern int    SIGNALBAR = 1;
extern bool   alertsOnCurrent = false;
extern bool   alertsOnHighLow = false;
extern bool   alertsMessage = false;
extern bool   alertsSound = false;
extern bool   alertsEmail = false;
extern bool   alertsMobile = false;
extern string soundFile = "alert.wav";

//
//
//
//
//

double tmBuffer [];
double upBuffer [];
double dnBuffer [];
double wuBuffer [];
double wdBuffer [];
double upArrow [];
double dnArrow [];


// NOTE: HULL setup
// ------------------------------------------------------------------
string hullfile = "Hull.ex4";
double hull []; // Hull buffer

input string thull = "== Hull setup =="; // ______________
extern bool               HULL_filter = true;
extern int                inpPeriod = 100;          // Period
extern double             inpDivisor = 2.0;         // Divisor ("speed")
extern ENUM_APPLIED_PRICE inpPrice = PRICE_CLOSE; // Price

int HullTrend(int i)
{
    double hullUp = iCustom(NULL, 0, hullfile, inpPeriod, inpDivisor, inpPrice, 0, i);
    double hullDn = iCustom(NULL, 0, hullfile, inpPeriod, inpDivisor, inpPrice, 1, i);

    if(hullDn == EMPTY_VALUE) return 1;
    return 0;
}
// ------------------------------------------------------------------
//
//
//
//
//

string IndicatorFileName;
bool   calculatingTma = false;
bool   returningBars = false;
int    timeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
    timeFrame = stringToTimeFrame(TimeFrame);
    HalfLength = MathMax(HalfLength, 1);
    IndicatorBuffers(8);
    SetIndexBuffer(0, tmBuffer);
    SetIndexDrawBegin(0, HalfLength);
    SetIndexStyle(0, DRAW_LINE);

    SetIndexBuffer(1, upBuffer);
    SetIndexDrawBegin(1, HalfLength);
    SetIndexStyle(1, DRAW_LINE);

    SetIndexBuffer(2, dnBuffer);
    SetIndexDrawBegin(2, HalfLength);
    SetIndexStyle(2, DRAW_LINE);

    SetIndexBuffer(3, upArrow);
    SetIndexStyle(3, DRAW_ARROW);
    SetIndexArrow(3, ArrUP);

    SetIndexBuffer(4, dnArrow);
    SetIndexStyle(4, DRAW_ARROW);
    SetIndexArrow(4, ArrDN);

    SetIndexLabel(0, stringToTimeFrame(TimeFrame) + ": TMA+CG NRP [" + (string) HalfLength + "]");
    SetIndexLabel(1, stringToTimeFrame(TimeFrame) + ": Band UPPER");
    SetIndexLabel(2, stringToTimeFrame(TimeFrame) + ": Band LOWER");
    SetIndexLabel(3, stringToTimeFrame(TimeFrame) + ": ArrowUP");
    SetIndexLabel(4, stringToTimeFrame(TimeFrame) + ": ArrowDN");
    IndicatorShortName(stringToTimeFrame(TimeFrame) + ": TMA+CG NRP [" + (string) HalfLength + "]");

    SetIndexBuffer(5, wuBuffer);
    SetIndexStyle(5, DRAW_NONE);

    SetIndexBuffer(6, wdBuffer);
    SetIndexStyle(6, DRAW_NONE);

    // NOTE: HULL oninit
    SetIndexBuffer(7, hull, INDICATOR_DATA);
    SetIndexLabel(7, "Hull Trend");
    SetIndexStyle(7, DRAW_NONE);
    SetIndexStyle(7, DRAW_LINE);
    // SetIndexBuffer(7, val, INDICATOR_DATA);
    // SetIndexBuffer(8, valda, INDICATOR_DATA);
    // SetIndexBuffer(9, valdb, INDICATOR_DATA);
    // SetIndexBuffer(10, valc);
    // iHull.init(inpPeriod, inpDivisor);

    //--- 
    if(TimeFrame == "calculateTma")
    {
        calculatingTma = true;
        return (INIT_SUCCEEDED);
    }
    if(TimeFrame == "returnBars")
    {
        returningBars = true;
        return (INIT_SUCCEEDED);
    }
    IndicatorFileName = WindowExpertName();
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time [],
                const double& open [],
                const double& high [],
                const double& low [],
                const double& close [],
                const long& tick_volume [],
                const long& volume [],
                const int& spread [])
{
    int counted_bars = IndicatorCounted();
    int i, limit;
    if(counted_bars < 0) return(-1);
    if(counted_bars > 0) counted_bars--;

    limit = MathMin(Bars - 1, Bars - counted_bars + HalfLength);

    if(returningBars)
    {
        tmBuffer[0] = limit;
        return(0);
    }
    if(calculatingTma)
    {
        calculateTma(limit);
        return(0);
    }

    if(timeFrame > _Period)
        limit = MathMax(limit, MathMin(Bars - 1, iCustom(NULL, timeFrame, IndicatorFileName, "returnBars", 0, 0) * timeFrame / _Period));

    //
    //
    //
    //
    //

    for(i = limit; i >= 0; i--)
    {
        int      shift1 = iBarShift(NULL, timeFrame, Time[i]);
        datetime time1 = iTime(NULL, timeFrame, shift1);
        //
        //
        //
        //
        //
        tmBuffer[i] = iCustom(NULL, timeFrame, IndicatorFileName, "calculateTma", HalfLength, Price, Deviation, 0, shift1);
        upBuffer[i] = iCustom(NULL, timeFrame, IndicatorFileName, "calculateTma", HalfLength, Price, Deviation, 1, shift1);
        dnBuffer[i] = iCustom(NULL, timeFrame, IndicatorFileName, "calculateTma", HalfLength, Price, Deviation, 2, shift1);


        upArrow[i] = EMPTY_VALUE;
        dnArrow[i] = EMPTY_VALUE;
        double ma = iMA(Symbol(), timeFrame, MA_Period, 0, MA_Method, MA_Price, i);

        hull[i] = HullTrend(i);


        if((ma < Close[i] && MA_filter == true) || !MA_filter)
            if((HULL_filter == true && hull[i] == 1) || !HULL_filter)
            {
                if(Low[i + 1 + ARROWBAR] < dnBuffer[i + 1 + ARROWBAR] && Close[i + 1 + ARROWBAR] < Open[i + 1 + ARROWBAR] && Close[i + ARROWBAR] > Open[i + ARROWBAR])
                    upArrow[i] = Low[i] - iATR(NULL, 0, 5, i) / 2;
            }
        if((ma > Close[i] && MA_filter == true) || !MA_filter)
            if((HULL_filter == true && hull[i] == 0) || !HULL_filter)
            {
                if(High[i + 1 + ARROWBAR] > upBuffer[i + 1 + ARROWBAR] && Close[i + 1 + ARROWBAR] > Open[i + 1 + ARROWBAR] && Close[i + ARROWBAR] < Open[i + ARROWBAR])
                    dnArrow[i] = High[i] + iATR(NULL, 0, 5, i) / 2;
            }
        if(timeFrame <= _Period || shift1 == iBarShift(NULL, timeFrame, Time[i - 1])) continue;

        if(!Interpolate) continue;

        //
        //
        //
        //
        //

        int n;
        for(n = 1; i + n < Bars && Time[i + n] >= time1; n++)
            continue;
        double factor = 1.0 / n;
        for(int k = 1; k < n; k++)
        {
            tmBuffer[i + k] = k * factor * tmBuffer[i + n] + (1.0 - k * factor) * tmBuffer[i];
            upBuffer[i + k] = k * factor * upBuffer[i + n] + (1.0 - k * factor) * upBuffer[i];
            dnBuffer[i + k] = k * factor * dnBuffer[i + n] + (1.0 - k * factor) * dnBuffer[i];
        }
    }
    //
    //
    //
    //
    //
    if(alertsOn)
    {
        //if (alertsOnCurrent)
        //      int forBar = 0;
        //else      forBar = 1;
        if(alertsOnHighLow)
        {
            if((Low[SIGNALBAR]  < dnBuffer[SIGNALBAR] && Low[SIGNALBAR + 1]  > dnBuffer[SIGNALBAR + 1]) || upArrow[SIGNALBAR] != EMPTY_VALUE)
                doAlert("LOW пробил Нижнюю Полосу  =  BUY");  //penetrated lower bar");
            if((High[SIGNALBAR] > upBuffer[SIGNALBAR] && High[SIGNALBAR + 1] < upBuffer[SIGNALBAR + 1]) || dnArrow[SIGNALBAR] != EMPTY_VALUE)
                doAlert("HIGH пробил Верхнюю Полосу  =  SELL");  //penetrated upper bar");
        }
        else
        {
            if(Close[SIGNALBAR] < dnBuffer[SIGNALBAR] && Close[SIGNALBAR + 1] > dnBuffer[SIGNALBAR + 1])
                doAlert("CLOSE ниже Нижней Полосы  =  BUY");  //penetrated lower bar");
            if(Close[SIGNALBAR] > upBuffer[SIGNALBAR] && Close[SIGNALBAR + 1] < upBuffer[SIGNALBAR + 1])
                doAlert("CLOSE выше Верхней Полосы  =  SELL");  //penetrated upper bar");
        }
    }
    //    return(0);
    return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateTma(int limit)
{
    int i, j, k;
    double FullLength = 2.0 * HalfLength + 1.0;

    for(i = limit; i >= 0; i--)
    {
        double sum = (HalfLength + 1) * iMA(NULL, 0, 1, 0, MODE_SMA, Price, i);
        double sumw = (HalfLength + 1);
        for(j = 1, k = HalfLength; j <= HalfLength; j++, k--)
        {
            sum += k * iMA(NULL, 0, 1, 0, MODE_SMA, Price, i + j);
            sumw += k;
            //if (j<=i)
            //{
            //   sum  += k*iMA(NULL,0,1,0,MODE_SMA,Price,i-j);
            //   sumw += k;
            //}
        }
        tmBuffer[i] = sum / sumw;
        //
        //
        //
        //
        //
        double diff = iMA(NULL, 0, 1, 0, MODE_SMA, Price, i) - tmBuffer[i];
        if(i > (Bars - HalfLength - 1))
            continue;
        if(i == (Bars - HalfLength - 1))
        {
            upBuffer[i] = tmBuffer[i];
            dnBuffer[i] = tmBuffer[i];
            if(diff >= 0)
            {
                wuBuffer[i] = MathPow(diff, 2);
                wdBuffer[i] = 0;
            }
            else
            {
                wdBuffer[i] = MathPow(diff, 2);
                wuBuffer[i] = 0;
            }
            continue;
        }
        //
        //
        //
        //
        //
        if(diff >= 0)
        {
            wuBuffer[i] = (wuBuffer[i + 1] * (FullLength - 1) + MathPow(diff, 2)) / FullLength;
            wdBuffer[i] = wdBuffer[i + 1] * (FullLength - 1) / FullLength;
        }
        else
        {
            wdBuffer[i] = (wdBuffer[i + 1] * (FullLength - 1) + MathPow(diff, 2)) / FullLength;
            wuBuffer[i] = wuBuffer[i + 1] * (FullLength - 1) / FullLength;
        }
        upBuffer[i] = tmBuffer[i] + Deviation * MathSqrt(wuBuffer[i]);
        dnBuffer[i] = tmBuffer[i] - Deviation * MathSqrt(wdBuffer[i]);
    }
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(string doWhat)
{
    static string   previousAlert = "";
    static datetime previousTime;
    string message;
    //
    //
    //
    //
    //
    if(previousAlert != doWhat || previousTime != Time[0])
    {
        previousAlert = doWhat;
        previousTime = Time[0];
        message = StringConcatenate(_Symbol, " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " TMA+CG:  ", doWhat);
        if(alertsMessage)
            Alert(message);
        if(alertsEmail)
            SendMail(StringConcatenate(_Symbol, " TMA+CG "), message);
        if(alertsMobile)
            SendNotification(_Symbol + " TMA+CG " + message);
        if(alertsSound)
            PlaySound(soundFile);  //"alert2.wav");
    }
}

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int stringToTimeFrame(string tfs)
{
    for(int l = StringLen(tfs) - 1; l >= 0; l--)
    {
        int charr = StringGetChar(tfs, l);
        if((charr > 96 && charr < 123) || (charr > 223 && charr < 256))
            tfs = StringSetChar(tfs, 1, charr - 32);
        else
            if(charr > -33 && charr < 0)
                tfs = StringSetChar(tfs, 1, charr + 224);
    }
    int tf = 0;
    if(tfs == "M1" || tfs == "1")
        tf = PERIOD_M1;
    if(tfs == "M5" || tfs == "5")
        tf = PERIOD_M5;
    if(tfs == "M15" || tfs == "15")
        tf = PERIOD_M15;
    if(tfs == "M30" || tfs == "30")
        tf = PERIOD_M30;
    if(tfs == "H1" || tfs == "60")
        tf = PERIOD_H1;
    if(tfs == "H4" || tfs == "240")
        tf = PERIOD_H4;
    if(tfs == "D1" || tfs == "1440")
        tf = PERIOD_D1;
    if(tfs == "W1" || tfs == "10080")
        tf = PERIOD_W1;
    if(tfs == "MN" || tfs == "43200")
        tf = PERIOD_MN1;
    if(tf == 0 || tf < _Period)
        tf = _Period;
    return(tf);
}
//+------------------------------------------------------------------+

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