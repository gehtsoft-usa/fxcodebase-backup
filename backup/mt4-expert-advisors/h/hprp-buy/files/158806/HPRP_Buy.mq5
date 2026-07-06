//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75766

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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

#property strict

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 clrDeepSkyBlue
#property indicator_width1 2
#property indicator_color2 clrNONE
#property indicator_color3 clrNONE
#property indicator_level1 100000000.0
#property indicator_level2 - 100000000.0

// input int RSI1Price  = 0;
// input int RSI1Length = 2;
// input int RSI2Price  = 0;
// input int RSI2Length = 8;
// input int RSI3Price  = 0;
// input int RSI3Length = 14;

#define Section_RSI
#ifdef Section_RSI

input string trsi        = "== RSI Setup =="; // ————————————————————————
input int    rsi1_period = 2;                 // RSI1 Periods
input int    rsi2_period = 8;                 // RSI2 Periods
input int    rsi3_period = 14;                // RSI3 Periods

int  handle_rsi1 = 0;
void setHandleRSI1() { handle_rsi1 = iRSI(NULL, 0, rsi1_period, PRICE_CLOSE); }

double RSI1(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle;
    // int shift = candle;
    int copy  = CopyBuffer(handle_rsi1, 0, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}

int  handle_rsi2 = 0;
void setHandleRSI2() { handle_rsi2 = iRSI(NULL, 0, rsi2_period, PRICE_CLOSE); }

double RSI2(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle;
    // int shift = candle;
    int copy  = CopyBuffer(handle_rsi2, 0, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}

int  handle_rsi3 = 0;
void setHandleRSI3() { handle_rsi3 = iRSI(NULL, 0, rsi3_period, PRICE_CLOSE); }

double RSI3(int candle = 1)
{
    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle;
    // int shift = candle;
    int copy  = CopyBuffer(handle_rsi3, 0, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}

#endif

// input int Stoch1KPeriod = 11;
// input int Stoch1DPeriod = 3;
// input int Stoch1Slowing = 3;
// input int Stoch2KPeriod = 39;
// input int Stoch2DPeriod = 3;
// input int Stoch2Slowing = 3;
// input int Stoch3KPeriod = 65;
// input int Stoch3DPeriod = 3;
// input int Stoch3Slowing = 3;

#define Section_Stoch
#ifdef Section_Stoch

input string   tstoch          = "== Stoch Setup =="; // ————————————————————————
input int      s1_KPeriod      = 11;                  // stoch 1 KPeriod:
input int      s1_DPeriod      = 3;                   // stoch 1 DPeriod:
input int      s1_Slowing      = 3;                   // stoch 1 Slowing:
ENUM_MA_METHOD s1_method       = MODE_SMA;            // stoch 1 method:
ENUM_STO_PRICE s1_price_field  = STO_LOWHIGH;         // stoch 1 price_field:
int            s1_handle_stoch = 0;                   //
input int      s2_KPeriod      = 39;                  // stoch 2 KPeriod:
input int      s2_DPeriod      = 3;                   // stoch 2 DPeriod:
input int      s2_Slowing      = 3;                   // stoch 2 Slowing:
ENUM_MA_METHOD s2_method       = MODE_SMA;            // stoch 2 method:
ENUM_STO_PRICE s2_price_field  = STO_LOWHIGH;         // stoch 2 price_field:
int            s2_handle_stoch = 0;                   //
input int      s3_KPeriod      = 65;                  // stoch 3 KPeriod:
input int      s3_DPeriod      = 3;                   // stoch 3 DPeriod:
input int      s3_Slowing      = 3;                   // stoch 3 Slowing:
ENUM_MA_METHOD s3_method       = MODE_SMA;            // stoch 3 method:
ENUM_STO_PRICE s3_price_field  = STO_LOWHIGH;         // stoch 3 price_field:
int            s3_handle_stoch = 0;                   //

void stoch1_setHandle() { s1_handle_stoch = iStochastic(NULL, 0, s1_KPeriod, s1_DPeriod, s1_Slowing, s1_method, s1_price_field); }
void stoch2_setHandle() { s2_handle_stoch = iStochastic(NULL, 0, s2_KPeriod, s2_DPeriod, s2_Slowing, s2_method, s2_price_field); }
void stoch3_setHandle() { s3_handle_stoch = iStochastic(NULL, 0, s3_KPeriod, s3_DPeriod, s3_Slowing, s3_method, s3_price_field); }

double stoch_k(int candle = 1, int h = 1)
{

    int handle;
    if (h == 1) { handle = s1_handle_stoch; }
    if (h == 2) { handle = s2_handle_stoch; }
    if (h == 3) { handle = s3_handle_stoch; }

    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle;
    // int shift = candle;
    int copy  = CopyBuffer(handle, 0, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}
double stoch_d(int candle = 1, int h = 1)
{
    int handle;
    if (h == 1) { handle = s1_handle_stoch; }
    if (h == 2) { handle = s2_handle_stoch; }
    if (h == 3) { handle = s3_handle_stoch; }

    double value[1];
    int  shift = Bars(_Symbol, _Period) - candle;
    // int shift = candle;
    int copy  = CopyBuffer(handle, 1, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}

#endif

input double Sensitivity = 2.0;

input bool   AlertsON          = true;
input bool   SoundAlert        = true;
input string SoundFileAtSignal = "signal.wav";
input bool   EmailAlert        = true;
input bool   NotificationAlert = true;

double   G_ibuf_200[];
double   G_ibuf_204[];
double   G_ibuf_208[];
double   Gda_212[][3];
int      G_acc_number_216;
double   rsi1;
double   rsi2;
double   rsi3;
double   stoch1;
double   stoch2;
double   stoch3;
bool     Gi_288;
datetime G_datetime_300;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    SetIndexBuffer(0, G_ibuf_200, INDICATOR_DATA);
    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
    PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, clrDeepSkyBlue);

    SetIndexBuffer(1, G_ibuf_204, INDICATOR_DATA);
    SetIndexBuffer(2, G_ibuf_208, INDICATOR_DATA);

    IndicatorSetString(INDICATOR_SHORTNAME, "HPRP_BUY");
    IndicatorSetInteger(INDICATOR_DIGITS, 4);

    setHandleRSI1();
    setHandleRSI2();
    setHandleRSI3();

    stoch1_setHandle();
    stoch2_setHandle();
    stoch3_setHandle();

    return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start;
    if (prev_calculated > 1)
        start = prev_calculated - 1;
    else {
        start = s3_KPeriod + 1;
    }

    for (int i = start; i < rates_total && !IsStopped(); i++) {
            rsi1 = RSI1(i);
            rsi2 = RSI2(i);
            rsi3 = RSI3(i);

            // stoch1 = iStochastic(NULL, 0, Stoch1KPeriod, Stoch1DPeriod, Stoch1Slowing, MODE_SMA, 0, MODE_MAIN, i + 1);
            // stoch2 = iStochastic(NULL, 0, Stoch2KPeriod, Stoch2DPeriod, Stoch2Slowing, MODE_SMA, 0, MODE_MAIN, i + 1);
            // stoch3 = iStochastic(NULL, 0, Stoch3KPeriod, Stoch3DPeriod, Stoch3Slowing, MODE_SMA, 0, MODE_MAIN, i + 1);
            
            stoch1 = stoch_k(i, 1);
            stoch2 = stoch_k(i, 2);
            stoch3 = stoch_k(i, 3);

            G_ibuf_200[i] = HPRPBuy(rsi1, rsi2, rsi3, stoch1, stoch2, stoch3);
        }

        if (IsNewBar()) {
            if (G_ibuf_200[2] - G_ibuf_200[1] > G_ibuf_200[2] * Sensitivity / 100.0 && AlertsON) {
                Alert("fsHPRP Buy Ahead on ", Symbol(), " ", Period());
                if (SoundAlert) PlaySound(SoundFileAtSignal);
                if (NotificationAlert) SendNotification("fsHPRP Buy Ahead on " + Symbol() + " " + IntegerToString(Period()));
                if (EmailAlert) SendMail("fsHPRP Buy Ahead on " + Symbol(), "fsHPRP Buy Ahead on " + Symbol() + " " + IntegerToString(Period()));
            }
        }

        return (rates_total);
    }

    //+------------------------------------------------------------------+
    //| Check for new bar                                                |
    //+------------------------------------------------------------------+
    bool IsNewBar()
    {
        datetime datetime_0 = iTime(Symbol(), 0, 0);
        if (G_datetime_300 != datetime_0) {
            G_datetime_300 = datetime_0;
            return true;
        }
        return false;
    }

    //+------------------------------------------------------------------+
    //| HPRP Buy Calculation                                             |
    //+------------------------------------------------------------------+
    double HPRPBuy(double a0, double a1, double a2, double a3, double a4, double a5) { return (MathArctan(a0 * a3 * a5)); }
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75766

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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