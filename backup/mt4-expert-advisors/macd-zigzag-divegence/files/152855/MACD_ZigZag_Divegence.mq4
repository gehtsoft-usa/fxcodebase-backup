//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74229

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
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



#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red

// NOTE: INPUTS zz
input string IZigZag = "== ZigZag Setup ==";  // == ZigZag Setup ==
input int    Depth = 12;                     // Depth
input int    Desviation = 5;                     // Desviation
input int    BackStep = 3;                     // BackStep
// ------------------------------------------------------------------
extern string separator1 = "*** Stochastic Settings ***";
extern int    fastEMA = 12;
extern int    slowEMA = 26;
extern int    signalSMA = 9;

extern string separator2 = "*** Indicator Settings ***";
extern bool   drawIndicatorTrendLines = true;
extern bool   drawPriceTrendLines = true;
extern bool   displayAlert = false;
// extern bool   alert_ON=false;
extern color  ColorBearishTrendLines = SaddleBrown;
extern color  ColorBullishTrendLines = MediumSpringGreen;
extern string separator3 = "*** Timeframe Setting (H1=60,H4=240,1440=D1)***";
extern int    TimeFrame = 15;
//---- buffers
double bullishDivergence [];
double bearishDivergence [];
double macd [];
double signal [];
double zigzag [];
//----
static datetime lastAlertTime;
static string   indicatorName;



class ZigZag
{
    string _symbol;
    int    _tf;
    string _file;

    struct Parameters
    {
        // NOTE: pasar los parametro del archivo .set
        int depth;       // Depth
        int desviation;  // Desviation
        int backStep;    // BackStep
    };
    Parameters _setup;

    struct zzPoint
    {
        double price;
        int    candle;
    };
    zzPoint points [];

    public:
    ZigZag()
    {
        _symbol = _Symbol;
        _tf = Period();
        _file = "ZigZag.ex4";
    }
    ZigZag(string Symbol, int TimeFrame)
    {
        _symbol = Symbol;
        _tf = TimeFrame;
        _file = "ZigZag.ex4";
    }
    ~ZigZag() { ; }

    ZigZag* file(string setfile)
    {
        _file = setfile;
        return &this;
    }

    void setSetup(int set0, int set1, int set2)
    {
        _setup.depth = set0;
        _setup.desviation = set1;
        _setup.backStep = set2;
    }

    double calculate(int shift, int buffer = 0)
    {
        return iCustom(_symbol, _tf, _file, _setup.depth, _setup.desviation, _setup.backStep, buffer, shift);
    }

    double Value(int i, int shift, bool candle = false)
    {
        // return specific point of zz
        int    count = -1;
        double value = 0;
        while(count != shift)
        {
            value = calculate(i);
            i++;
            if(value != EMPTY_VALUE && value > 0) count++;
        }
        if(candle)
        {
            return i - 1;
        }
        return value;
        // return 0;
    }

    void LoadPoints(int qnt, int shift)
    {
        ArrayFree(points);
        ArrayResize(points, 0);
        for(int i = 0; i < qnt + 1; i++)
        {
            double ValueToAdd = Value(shift, i);
            int candle = Value(shift, i, true);
            int    t = ArraySize(points);
            if(ArrayResize(points, t + 1))
            {
                points[t].price = ValueToAdd;
                points[t].candle = candle;
            }
        }
    }

    void PrintPoints()
    {
        for(int i = 0; i < ArraySize(points); i++)
        {
            Print("Array points, value: ", i, " price:", points[i].price);
            Print("Array points, value: ", i, " candle:", points[i].candle);
        }
    }

    // NOTE: out of range

    double price(int i)
    {
        return points[i].price;
    }
    int candle(int i)
    {
        return points[i].candle;
    }


    // ------------------------------------------------------------------
    double lastValue(int buffer, bool candle = false)
    {
        double value = 0;
        int    i = 0;
        while(value == 0 || i == 2000)
        {
            value = calculate(i, buffer);
            i++;
        }

        if(candle)
        {
            return i;
        }
        return value;
    }

    int actualSide()
    {
        int lastBuy = (int) lastValue(0, true);
        int lastSell = (int) lastValue(1, true);
        if(lastBuy < lastSell)
        {
            return 0;  // BUY
        }
        else
        {
            return 1;  // SELL
        }
    }
};
ZigZag* zz;


//+------------------------------------------------------------------+
//| Custom indicator timeframe function                              |
//+------------------------------------------------------------------+

string GetTimeFrameStr()
{
    string TimeFrameStr2;
    switch(TimeFrame)
    {
        case 1: TimeFrameStr2 = "M1"; break;
        case 5: TimeFrameStr2 = "M5"; break;
        case 15: TimeFrameStr2 = "M15"; break;
        case 30: TimeFrameStr2 = "M30"; break;
        case 60: TimeFrameStr2 = "H1"; break;
        case 240: TimeFrameStr2 = "H4"; break;
        case 1440: TimeFrameStr2 = "D1"; break;
        case 10080: TimeFrameStr2 = "W1"; break;
        case 43200: TimeFrameStr2 = "MN1"; break;
    }
    return (TimeFrameStr2);
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    zz = new ZigZag(Symbol(), Period());
    zz.setSetup(Depth, Desviation, BackStep);
    // Print(zz.Value(0, 0));

    //---- indicators
    SetIndexStyle(0, DRAW_ARROW);
    SetIndexStyle(1, DRAW_ARROW);
    SetIndexStyle(2, DRAW_LINE);
    SetIndexStyle(3, DRAW_LINE);
    //----
    
    SetIndexBuffer(0, bullishDivergence);
    SetIndexBuffer(1, bearishDivergence);
    SetIndexBuffer(2, macd);
    SetIndexBuffer(3, signal);
    //----
    // Show regular timeframe string (HCY)
    if(TimeFrame == 0)
    {
        TimeFrame = Period();
    }
    indicatorName = Symbol() + " (" + GetTimeFrameStr() + "):  MACD_Divergence(" + fastEMA + ", " +
        slowEMA + ", " + signalSMA + ")";
    SetIndexDrawBegin(3, signalSMA);
    IndicatorDigits(Digits + 2);
    IndicatorShortName(indicatorName);

    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    for(int i = ObjectsTotal() - 1; i >= 0; i--)
    {
        string label = ObjectName(i);
        if(StringSubstr(label, 0, 25) != "MACD_DivergenceLine")
            continue;
        ObjectDelete(label);
    }
    delete zz;

    //    ObjectsDeleteAll();
    //    ObjectDelete(label);
    // return (0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
    int start, i;
    if(prev_calculated == 0)
    {
        // start = rates_total - periods;
        start = 500;
    }
    else { start = rates_total - (prev_calculated - 1); }

// NOTE: calcu
    for(i = start; i >= 0; i--)
    {

        CalculateMACD(i);
        // zigzag[i] = zz.Value(i,0);
        zz.LoadPoints(2, i);
        // zz.PrintPoints();


        CatchBullishDivergence(i + 2);
        CatchBearishDivergence(i + 2);
      //----
    }
    return (rates_total);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


void CalculateIndicator(int countedBars)
{
    // for(int i = Bars - countedBars; i >= 0; i--)
    // for(int i = 100; i >= 0; i--)
    // {
    //     CalculateMACD(i);
    //     // zigzag[i] = zz.Value(i,0);
    //     zz.LoadPoints(2, i);
    //     zz.PrintPoints();


        // CatchBullishDivergence(i + 2);
        // CatchBearishDivergence(i + 2);
// }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateMACD(int i)
{
    macd[i] = iMACD(NULL, 0, fastEMA, slowEMA, signalSMA, PRICE_CLOSE, MODE_MAIN, i);
    signal[i] = iMACD(NULL, 0, fastEMA, slowEMA, signalSMA, PRICE_CLOSE, MODE_SIGNAL, i);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBullishDivergence(int shift)
{
    // if(IsIndicatorTrough(shift) == false) return;

    int currentTrough = shift;
    // int lastTrough = GetIndicatorLastTrough(shift);
    int lastTrough = shift;


    /*
      Bullish divergence:
      macd actual >  macd anterior
      zz actual < zz anterior

     buscar los ultimos dos puntos del zz
     si baja, controlar el macd para esas velas (no me importan los Trough)
    */

    // zz.LoadPoints(2, shift);
    // Print(zz.Value(shift, 0));
    // zz.PrintPoints();
    if(zz.price(0) >= zz.price(1)) return;

        currentTrough = zz.candle(0);
        lastTrough = zz.candle(1);

    //   static bool turn_alarm = true;
    //----
    // if(macd[currentTrough] >= macd[lastTrough] &&
    //     Low[currentTrough] <= Low[lastTrough])

    if(macd[currentTrough] >= macd[lastTrough])
    {
        bullishDivergence[currentTrough] = macd[currentTrough];

        //----
        if(drawPriceTrendLines == true)
            DrawPriceTrendLine(Time[currentTrough], Time[lastTrough],
                               Low[currentTrough],
                               Low[lastTrough], ColorBullishTrendLines, STYLE_SOLID);
        //----
        if(drawIndicatorTrendLines == true)
            DrawIndicatorTrendLine(Time[currentTrough],
                                   Time[lastTrough],
                                   macd[currentTrough],
                                   macd[lastTrough],
                                   ColorBullishTrendLines, STYLE_SOLID);
        //----
        if(displayAlert == true)
            DisplayAlert("Bullish divergence on: ", currentTrough);
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBearishDivergence(int shift)
{
    // if(IsIndicatorPeak(shift) == false) return;

    int         currentPeak = shift;
    // int         lastPeak = GetIndicatorLastPeak(shift);
    int         lastPeak = shift;
    // static bool turn_alarm = true;
    //----


    // zz.PrintPoints();
    if(zz.price(0) <= zz.price(1)) return;

    currentPeak = zz.candle(0);
    lastPeak = zz.candle(1);


    // if(macd[currentPeak] <= macd[lastPeak] && High[currentPeak] >= High[lastPeak])

    if(macd[currentPeak] <= macd[lastPeak])
    {
        bearishDivergence[currentPeak] = macd[currentPeak];

        if(drawPriceTrendLines == true)
            DrawPriceTrendLine(Time[currentPeak], Time[lastPeak],
                               High[currentPeak],
                               High[lastPeak], ColorBearishTrendLines, STYLE_SOLID);

        if(drawIndicatorTrendLines == true)
            DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak],
                                   macd[currentPeak],
                                   macd[lastPeak], ColorBearishTrendLines, STYLE_SOLID);

        if(displayAlert == true)
            DisplayAlert("Bearish divergence on: ",
                         currentPeak);
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorPeak(int shift)
{
    return true;

    if(macd[shift] >= macd[shift + 1] && macd[shift] > macd[shift + 2] &&
      macd[shift] > macd[shift - 1])
        return (true);
    else
        return (false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorTrough(int shift)
{
    return true;

    if(macd[shift] <= macd[shift + 1] && macd[shift] < macd[shift + 2] &&
      macd[shift] < macd[shift - 1])
        return (true);
    else
        return (false);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastPeak(int shift)
{
    for(int i = shift + 5; i < Bars; i++)
    {
        if(signal[i] >= signal[i + 1] && signal[i] >= signal[i + 2] &&
            signal[i] >= signal[i - 1] && signal[i] >= signal[i - 2])
        {
            for(int j = i; j < Bars; j++)
            {
                if(macd[j] >= macd[j + 1] && macd[j] > macd[j + 2] &&
                    macd[j] >= macd[j - 1] && macd[j] > macd[j - 2])
                    return (j);
            }
        }
    }
    return (-1);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastTrough(int shift)
{
    for(int i = shift + 5; i < Bars; i++)
    {
        if(signal[i] <= signal[i + 1] && signal[i] <= signal[i + 2] &&
            signal[i] <= signal[i - 1] && signal[i] <= signal[i - 2])
        {
            for(int j = i; j < Bars; j++)
            {
                if(macd[j] <= macd[j + 1] && macd[j] < macd[j + 2] &&
                    macd[j] <= macd[j - 1] && macd[j] < macd[j - 2])
                    return (j);
            }
        }
    }
    return (-1);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayAlert(string message, int shift)
{
    if(shift <= 2 && Time[shift] != lastAlertTime)
    {
        lastAlertTime = Time[shift];
        Alert(message, Symbol(), " , ", /*Period()==*/TimeFrame, " minutes chart");
    }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceTrendLine(datetime x1, datetime x2, double y1,
                        double y2, color lineColor, double style)
{
    string label = "MACD_DivergenceLine_v1.0# " + DoubleToStr(x1, 0) + TimeFrame;
    ObjectDelete(label);
    ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
    ObjectSet(label, OBJPROP_RAY, 0);
    ObjectSet(label, OBJPROP_COLOR, lineColor);
    ObjectSet(label, OBJPROP_STYLE, style);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawIndicatorTrendLine(datetime x1, datetime x2, double y1,
                            double y2, color lineColor, double style)
{
    int indicatorWindow = WindowFind(indicatorName);
    if(indicatorWindow < 0)
        return;
    string label = "MACD_DivergenceLine_v1.0$# " + DoubleToStr(x1, 0) + TimeFrame;
    ObjectDelete(label);
    ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2,
                 0, 0);
    ObjectSet(label, OBJPROP_RAY, 0);
    ObjectSet(label, OBJPROP_COLOR, lineColor);
    ObjectSet(label, OBJPROP_STYLE, style);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//| USDT Donations                                                                                 |
//+------------------------------------------------+-----------------------------------------------+
//| Network                                        |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//| ERC20 (ETH Ethereum)                           |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//| TRC20 (Tron)                                   |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//| BEP20 (BSC BNB Smart Chain)                    |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| Matic Polygon                                  |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//| SOL Solana                                     |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//| ARBITRUM Arbitrum One                          |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+