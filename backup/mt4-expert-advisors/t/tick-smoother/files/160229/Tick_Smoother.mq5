//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76237

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

#property strict

#property indicator_separate_window

#property indicator_buffers 3
#property indicator_plots 3
#property indicator_label1 "Tick"
#property indicator_type1  DRAW_LINE
#property indicator_color1 Lime
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Fast MA"
#property indicator_type2  DRAW_LINE
#property indicator_color2 DodgerBlue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Slow MA"
#property indicator_type3  DRAW_LINE
#property indicator_color3 Tomato
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

// NOTE: Inputs
// ------------------------------------------------------------------
input int fastma_period = 5;  // Fast MA Period
input int slowma_period = 14; // Slow MA Period

int ma_mode = 0; // MA Mode: 0-SMA,1-EMA,2-Wilder(SMMA),3-LWMA

string T1                    = "== Notifications =="; // Notifications
bool   notifications         = false;                 // Notifications On?
bool   desktop_notifications = false;                 // Desktop MT4 Notifications
bool   email_notifications   = false;                 // Email Notifications
bool   push_notifications    = false;                 // Push Mobile Notifications

// NOTE: Buffers
//--- indicator buffers
double Ticks[];
double Fast[];
double Slow[];

int tickCounter  = 0;   // Tick counter
int prev_counter = 0;   // Previous tick counter
int MaxTicks     = 200; // Max number of ticks to store
// ------------------------------------------------------------------
void OnInit()
{
    //--- indicator short name
    string short_name = "Line Indicator";
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    PlotIndexSetString(0, PLOT_LABEL, short_name);
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

    SetIndexBuffer(0, Ticks);
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, slowma_period);
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);

    SetIndexBuffer(1, Fast);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, slowma_period);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);

    SetIndexBuffer(2, Slow, INDICATOR_DATA);
    PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, slowma_period);
    PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);

    ArrayInitialize(Ticks, EMPTY_VALUE);
    ArrayInitialize(Fast, EMPTY_VALUE);
    ArrayInitialize(Slow, EMPTY_VALUE);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{

    if (prev_calculated == 0)
        for (int i = 1; i < rates_total - 1 && !IsStopped(); i++) {
            Ticks[i] = 0;
            Fast[i]  = 0;
            Slow[i]  = 0;
            return (rates_total);
        }

    int i = rates_total - 1;
    tickCounter++;

    double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    Ticks[i]   = Bid;

    double Sum = 0;
    for (int j = i; j > i-fastma_period; j--)
    {
        Sum += Ticks[j];
    }
    Fast[i] = Sum / fastma_period;
    
    Sum = 0;
    for (int j = i; j > i-slowma_period; j--)
    {
        Sum += Ticks[j];
    }
    Slow[i] = Sum / slowma_period;


    // cuando entra un nuevo tick tengo que correr todos los valores del array una posicion
    for (int pos = i - MaxTicks; pos < i; pos++) {
        Ticks[pos] = Ticks[pos + 1];
        Fast[pos]  = Fast[pos + 1];
        Slow[pos]  = Slow[pos + 1];
    }


    return (rates_total);
}
// ------------------------------------------------------------------

double TickEMA(double &array[], double &prev[], int per)
{
    double alpha = 2.0 / (per + 1);
    return (alpha * array[0] + (1 - alpha) * prev[0]);
}

double TickLWMA(double &array[], int per)
{
    double Sum    = 0;
    double Weight = 0;
    for (int i = 0; i < per; i++) {
        Sum += array[i] * (i + 1);
        Weight += (i + 1);
    }
    return (Sum / Weight);
}

double TickSMA(double &array[], int per, int i = 0 )
{
    double Sum = 0;
    for (int j = i; j < i-per; j--)
        Sum += array[j];
    return (Sum / per);
}

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
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76237

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
