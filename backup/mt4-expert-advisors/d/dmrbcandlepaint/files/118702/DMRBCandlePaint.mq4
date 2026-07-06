// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65946

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                   Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon : https://goo.gl/GdXWeN   |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property description "DMRB Candles Paint"
#property version   "1.00"
#property strict
#property indicator_buffers 8

extern bool bDMRB = true; // Activer strategie DMRB
extern color UPclr = clrGreen; // Signal DMRB haussier
extern color DNclr = clrRed; // Signal DMRB baissier
extern color clr1 = clrWhiteSmoke; // Signal DMRB mais potentiel de RR < 2
extern color IDLEclr = clrYellow; // Couleur bougies idle
extern int T = 9; // Tenkan Period
extern int K = 26; // Kijun Period
extern int S = 52; // Senkou Period
extern string  TimePeriod = "D1";
extern bool bPivot = true; // Prise en compte du pivot journalier
enum ENUM_TYPE
{
    Pivot, // Pivot
    Camarilla, // Camarilla
    Woodie, // Woodie
    Fibonacci, // Fibonacci
    Floor, // Floor
    Fibonacci_Retracement // Fibonacci Retracement
};

extern ENUM_TYPE Type = Pivot;
extern int BarWidth = 3;

extern bool     Sound_Alert              = true;
extern bool     Email_Alert              = false;
extern bool     Telegram_Alert           = false;
extern string   Telegram_Key             = "";
extern string   Comment2                 = "- You can get a telegram key by starting a dialog with @profit_robots_bot -";
extern string   Comment3                 = "- Also, you need to install TelegramNotificationsLib.dll and allow use of dll in the indicator parameters window -";

#import "TelegramNotificationsLib.dll"
void AlertTelegram(string key, string text, string instrument, string timeframe);
#import

double UPclrH[], UPclrL[], clr1H[], clr1L[], DNclrH[], DNclrL[], IDLEclrH[], IDLEclrL[];
int timeframe;

int init()
{
    IndicatorShortName("DMRB Candles Paint");
    IndicatorDigits(Digits);
    SetIndexBuffer(0, UPclrH);
    SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, BarWidth, UPclr);
    SetIndexBuffer(1, UPclrL);
    SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, BarWidth, UPclr);
    SetIndexBuffer(2, clr1H);
    SetIndexStyle(2, DRAW_HISTOGRAM, EMPTY, BarWidth, clr1);
    SetIndexBuffer(3, clr1L);
    SetIndexStyle(3, DRAW_HISTOGRAM, EMPTY, BarWidth, clr1);
    SetIndexBuffer(4, DNclrH);
    SetIndexStyle(4, DRAW_HISTOGRAM, EMPTY, BarWidth, DNclr);
    SetIndexBuffer(5, DNclrL);
    SetIndexStyle(5, DRAW_HISTOGRAM, EMPTY, BarWidth, DNclr);
    SetIndexBuffer(6, IDLEclrH);
    SetIndexStyle(6, DRAW_HISTOGRAM, EMPTY, BarWidth, IDLEclr);
    SetIndexBuffer(7, IDLEclrL);
    SetIndexStyle(7, DRAW_HISTOGRAM, EMPTY, BarWidth, IDLEclr);

    if (TimePeriod=="M1" || TimePeriod=="1") timeframe=PERIOD_M1;
    else if (TimePeriod=="M5" || TimePeriod=="5") timeframe=PERIOD_M5;
    else if (TimePeriod=="M15" || TimePeriod=="15") timeframe=PERIOD_M15;
    else if (TimePeriod=="M30" || TimePeriod=="30") timeframe=PERIOD_M30;
    else if (TimePeriod=="H1" || TimePeriod=="60") timeframe=PERIOD_H1;
    else if (TimePeriod=="H4" || TimePeriod=="240") timeframe=PERIOD_H4;
    else if (TimePeriod=="D1" || TimePeriod=="1440") timeframe=PERIOD_D1;
    else if (TimePeriod=="W1" || TimePeriod=="10080") timeframe=PERIOD_W1; 
    else if (TimePeriod=="MN" || TimePeriod=="43200") timeframe=PERIOD_MN1;
    else
    {
        Comment("Wrong TimePeriod. Must be M5, M15, M30, H1, H4, D1, W1 or MN"); 
    }

    return 0;
}

void CalcPivot(const int i, double &p, 
    double &s1, double &s2, double &s3, double &s4,
    double &r1, double &r2, double &r3, double &r4)
{
    double high  = iHigh(NULL, timeframe, i+1);
    double low   = iLow(NULL, timeframe, i+1);
    double open  = iOpen(NULL, timeframe, i+1);
    double close = iClose(NULL, timeframe, i+1);
    switch (Type)
    {
        case Pivot:
            p = (high + low + close ) / 3;
            r1 = (2 * p) - low;
            s1 = (2 * p) - high;
            r2 = p + (high - low);
            s2 = p - (high - low);
            r3 = p + (high - low) * 2;
            s3 = p - (high - low) * 2;
            r4 = p + (high - low) * 3;
            s4 = p - (high - low) * 3;
            break;
        case Camarilla:
            p = close;
            r1 = p + (high - low) * 1.1 / 12;
            s1 = p - (high - low) * 1.1 / 12;
            r2 = p + (high - low) * 1.1 / 6;
            s2 = p - (high - low) * 1.1 / 6;
            r3 = p + (high - low) * 1.1 / 4;
            s3 = p - (high - low) * 1.1 / 4;
            r4 = p + (high - low) * 1.1 / 2;
            s4 = p - (high - low) * 1.1 / 2;
            break;
        case Woodie:
            p = open;
            r1 = p * 2 - low;
            s1 = p * 2 - high;
            r2 = p + (high - low);
            s2 = p - (high - low);
            r3 = high + 2 * (p - low);
            s3 = low - 2 * (high - p);
            r4 = high + (2 * (p - low) + (high - low));
            s4 = low - ((high - low) + 2 * (high - p));
            break;
        case Fibonacci:
            p = (high + low + close ) / 3;
            r1 = p+ 0.382 * (high - low);
            s1 =  p- 0.382 * (high - low);
            r2 =  p+ 0.618 *(high - low);
            s2 = p - 0.618 *(high - low);
            r3 = p+ (high - low);
            s3 =  p- (high - low);
            r4 = p + 1.618 * (high - low);
            s4 = p - 1.618 * (high - low);
            break;
        case Floor:
            p = (high + low + close ) / 3; 
            r1 = p*2+ low;
            s1 =  high;
            r2 =  p + (high - low);
            s2 = p - (high - low);
            r3 = high + (p - low)*2;
            s3 =  low - (high - p)*2;
            r4 = 0;
            s4 = 0;
            break;
        case Fibonacci_Retracement:
            p = (high + low)/2;
            r1 = low + (high - low) * 0.618;
            s1 = low + (high - low) * 0.382;
            r2 = low+(high - low) * 0.764;
            s2 = low+(high - low) * 0.236;
            r3 = low+(high - low) * 1;
            s3 = low+(high - low) * 0;
            r4 = low+(high - low) * 1.618;
            s3 = low+(high - low) * (-0.236);
            break;
    }
}

// Sens de la bougie
// retourne up (haussi�re), down (baissi�re) ou none (doji)
string sensBougie(const int period)
{
    if (Open[period] == Close[period])
    {
        return "none";
    }
    else if (Open[period] < Close[period])
    {
        return "up";
    }
    else if (Open[period] > Close[period])
    {
        return "down";
    }
    return "";
}

// Sens du kumo
// retourne up ou down
string kumoDirection(const int period)
{
    double sa = iIchimoku(_Symbol, _Period, T, K, S, MODE_SENKOUSPANA, period);
    double sb = iIchimoku(_Symbol, _Period, T, K, S, MODE_SENKOUSPANB, period);
    if (sa > sb)
    {
        return "up";
    }
    else if (sa < sb)
    {
        return "down";
    }
    return "";
}

// Prix par rapport au kumo
// retourne up ou down
string prixKumo(const int period)
{
    double sa = iIchimoku(_Symbol, _Period, T, K, S, MODE_SENKOUSPANA, period);
    double sb = iIchimoku(_Symbol, _Period, T, K, S, MODE_SENKOUSPANB, period);
    if (Open[period] > sa && Open[period] > sb && Close[period] > sa && Close[period] > sb)
    {
        return "up";
    }
    else if (Open[period] < sa && Open[period] < sb && Close[period] < sa && Close[period] < sb)
    {
        return "down";
    }
    return "";
}

// Prix par rapport au Pivot journalier
// retourne up (au dessus), down (en dessous) ou non (croise le pp)
string prixPP(const int period)
{
    double pivot_p = 0;
    double pivot_s1 = 0;
    double pivot_s2 = 0;
    double pivot_s3 = 0;
    double pivot_s4 = 0;
    double pivot_r1 = 0;
    double pivot_r2 = 0;
    double pivot_r3 = 0;
    double pivot_r4 = 0;
    int btf_i = iBarShift(NULL, timeframe, iTime(NULL, _Period, period));
    CalcPivot(btf_i, pivot_p, pivot_s1, pivot_s2, pivot_s3, pivot_s4, pivot_r1, pivot_r2, pivot_r3, pivot_r4);
    if (Close[period] > pivot_p && Close[period] > pivot_p)
    {
        return "up";
    }
    else if (Open[period] < pivot_p && Close[period] < pivot_p)
    {
        return "down";
    }
    return "none";
}

// Orientation de la Kijun
// Le calcul simple est bas� sur les 5 derni�res p�riodes
// retourne up, down ou none (plat)
string sensKJ(const int period)
{
    double tl = iIchimoku(_Symbol, _Period, T, K, S, MODE_KIJUNSEN, period);
    double tl_5 = iIchimoku(_Symbol, _Period, T, K, S, MODE_KIJUNSEN, period + 5);
    if (tl > tl_5)
    {
        return "up";
    }
    else if (tl < tl_5)
    {
        return "down";
    }
    return "none";
}

// Position de la Tenkan par rapport � la Kijun
// retourne up, down ou none (plat)
string positionTK(const int period)
{
    double tl = iIchimoku(_Symbol, _Period, T, K, S, MODE_KIJUNSEN, period);
    double sl = iIchimoku(_Symbol, _Period, T, K, S, MODE_TENKANSEN, period);
    if (sl > tl)
    {
        return "up";
    }
    else if (sl < tl)
    {
        return "down";
    }
    return "none";
}

// Position du prix par rapport � la Tenkan
// retourne up ou down
string positionPrixTK(const int period)
{
    double sl = iIchimoku(_Symbol, _Period, T, K, S, MODE_TENKANSEN, period);
    if (Close[period] > sl)
    {
        return "up";
    }
    return "down";
}

// Cassure de la Kijun par le prix
// retourne yes ou none
string cassureKJ(const int period)
{
    double tl = iIchimoku(_Symbol, _Period, T, K, S, MODE_KIJUNSEN, period);
    if ((Close[period] > tl && Open[period] < tl) || (Close[period] < tl && Open[period] > tl))
    {
        return "yes";
    }
    return "none";
}

// Potentiel RR doit �tre sup�rieur � 2
// le calcul est fait entre la taille entre la cloture du signal et le + bas/haut des 5 derni�res bougies jusqu'au prochain pivot
bool rrValable(const int period)
{
    double pivot_p = 0;
    double pivot_s1 = 0;
    double pivot_s2 = 0;
    double pivot_s3 = 0;
    double pivot_s4 = 0;
    double pivot_r1 = 0;
    double pivot_r2 = 0;
    double pivot_r3 = 0;
    double pivot_r4 = 0;
    int btf_i = iBarShift(NULL, timeframe, iTime(NULL, _Period, period));
    CalcPivot(btf_i, pivot_p, pivot_s1, pivot_s2, pivot_s3, pivot_s4, pivot_r1, pivot_r2, pivot_r3, pivot_r4);
    int _digit = (int)MarketInfo(_Symbol, MODE_DIGITS); 
    double pipSize = MarketInfo(_Symbol, MODE_POINT) * (_digit == 3 || _digit == 5 ? 10 : 1);
    if (sensBougie(period) == "up")
    {
        double plusBas = Low[period];
        for (int i = 1; i <= 5; ++i)
        {
            if (Low[period + i] < plusBas)
            {
                plusBas = Low[period + i];
            }
        }
        double tailleRisquePoints = (Close[period] - plusBas) / pipSize;
        // Identification de la position au niveau des Pivots
        if (Close[period] < pivot_r1)
        {
            if (tailleRisquePoints <  ((pivot_r1 - Close[period]) / pipSize) / 2)
            {
                return true;
            }
        }
        else if (Close[period] < pivot_r2)
        {
            if (tailleRisquePoints < ((pivot_r2 - Close[period]) / pipSize) / 2)
            {
                return true;
            }
        }
        else if (Close[period] < pivot_r3)
        {
            if (tailleRisquePoints < ((pivot_r3 - Close[period]) / pipSize) / 2)
            {
                return true;
            }
        }
        else if (Close[period] < pivot_r4)
        {
            if (tailleRisquePoints < ((pivot_r4 - Close[period]) / pipSize) / 2)
            {
                return true;
            }
        }
    }
    else if (sensBougie(period) == "down")
    {
        double plusHaut = High[period];
        for (int i = 1; i <= 5; i++)
        {
            if (High[period + i] > plusHaut)
            {
                plusHaut = High[period + i];
            }
        }
        double tailleRisquePoints = (plusHaut - Close[period]) / pipSize;
        if (Close[period] > pivot_s1)
        {
            if (tailleRisquePoints < ((Close[period] - pivot_s1) / pipSize) / 2)
            {
                return true;
            }
        }
        else if (Close[period] > pivot_s2)
        {
            if (tailleRisquePoints < ((Close[period] - pivot_s2) / pipSize) / 2)
            {
                return true;
            }
        }
        else if (Close[period] > pivot_s3)
        {
            if (tailleRisquePoints < ((Close[period] - pivot_s3) / pipSize) / 2)
            {
                return true;
            }
        }
        else if (Close[period] > pivot_s4)
        {
            if (tailleRisquePoints < ((Close[period] - pivot_s4) / pipSize) / 2)
            {
                return true;
            }
        }
    }
    
    return false;
}

bool isSignalUP(const int period)
{
    return sensBougie(period) == "up" && prixKumo(period) == "up" && (!bPivot || prixPP(period) == "up") && sensKJ(period) == "up" && (positionTK(period) == "down" || positionPrixTK(period) == "up") && cassureKJ(period) == "yes";
}

bool isSignalDN(const int period)
{
    return sensBougie(period) == "down" && prixKumo(period) == "down" && (!bPivot || prixPP(period) == "down") && sensKJ(period) == "down" && (positionTK(period) == "up" || positionPrixTK(period) == "down") && cassureKJ(period) == "yes"; 
}

datetime _lastDatetime;
void SendNotifications(const int direction)
{
    datetime currentTime = iTime(_Symbol, _Period, 0);
    if (_lastDatetime == currentTime)
        return;

    _lastDatetime = currentTime;
    if (direction == 0)
        return;
        
    string alert_Subject;
    string alert_Body;
    switch (direction)
    {
        case 1:
            alert_Subject = "Signal DMRB !";
            alert_Body = "Signal DMRB !";
            break;
        case -1:
            alert_Subject = "Signal DMRB !";
            alert_Body = "Signal DMRB !";
            break;
        case 2:
            alert_Subject = "Signal DMRB !";
            alert_Body = "Signal DMRB !";
            break;
        case -2:
            alert_Subject = "Signal DMRB !";
            alert_Body = "Signal DMRB !";
            break;
    }
    
    if (Sound_Alert)
        Alert(alert_Body);
    if (Email_Alert)
        SendMail(alert_Subject, alert_Body);
    if (Telegram_Alert && Telegram_Key != "")
        AlertTelegram(Telegram_Key, alert_Body, _Symbol, "m1");
}

int start()
{
    int limit, counted_bars = IndicatorCounted();
    if (counted_bars < 0)
        return -1;
    if (counted_bars > 0)
        counted_bars--;
    limit = MathMin(Bars - counted_bars, Bars - 1);
    
    for (int period = limit; period >= 0; period--)
    {
        UPclrH[period] = EMPTY_VALUE;
        UPclrL[period] = EMPTY_VALUE;
        clr1H[period] = EMPTY_VALUE;
        clr1L[period] = EMPTY_VALUE;
        DNclrH[period] = EMPTY_VALUE;
        DNclrL[period] = EMPTY_VALUE;
        IDLEclrH[period] = EMPTY_VALUE;
        IDLEclrL[period] = EMPTY_VALUE;
        if (isSignalUP(period))
        {
            if (rrValable(period))
            {
                UPclrH[period] = Close[period];
                UPclrL[period] = Open[period];
                SendNotifications(1);
            }
            else
            {
                clr1H[period] = Close[period];
                clr1L[period] = Open[period];
                SendNotifications(2);
            }
        }
        else if (isSignalDN(period))
        {
            if (rrValable(period))
            {
                DNclrH[period] = Close[period];
                DNclrL[period] = Open[period];
                SendNotifications(-1);
            }
            else
            {
                clr1H[period] = Close[period];
                clr1L[period] = Open[period];
                SendNotifications(2);
            }
        }
        else
        {
            IDLEclrH[period] = Close[period];
            IDLEclrL[period] = Open[period];
        }
    }
    return 0;
}
