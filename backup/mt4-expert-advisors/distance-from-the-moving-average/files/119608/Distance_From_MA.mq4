// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=61981
// Id: 13749

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

enum SmoothingMethod
{
    SMA = 0,
    EMA = 1,
    SMMA = 2,
    LWMA = 3,
    VWMA
};

extern int Length1=14;
extern SmoothingMethod Method1=VWMA;
extern bool Smoothing=true;
extern int Length2=14;
extern SmoothingMethod Method2=SMA;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern bool     Sound_Alert              = true;
extern bool     Email_Alert              = false;
extern bool     Telegram_Alert           = false;
extern string   Telegram_Key             = "";
extern string   Comment2                 = "- You can get a telegram key by starting a dialog with @profit_robots_bot -";
extern string   Comment3                 = "- Also, you need to install TelegramNotificationsLib.dll and allow use of dll in the indicator parameters window -";

double Dist[], Smoothed[], vwma_1[], vwma_2[];
#import "TelegramNotificationsLib.dll"
void AlertTelegram(string key, string text, string instrument, string timeframe);
#import


int init()
{
    IndicatorShortName("Distance from MA");
    IndicatorDigits(Digits);
    SetIndexStyle(0,DRAW_LINE);
    SetIndexBuffer(0,Dist);
    if (Smoothing)
    {
        SetIndexStyle(1,DRAW_LINE);
    }
    else
    {
        SetIndexStyle(1,DRAW_NONE);
    } 
    SetIndexBuffer(1,Smoothed);
    
    SetIndexBuffer(2, vwma_1);
    SetIndexStyle(2, DRAW_NONE);
    SetIndexBuffer(3, vwma_2);
    SetIndexStyle(3, DRAW_NONE);

    return(0);
}

int deinit()
{
    return(0);
}

string GetTimeframe()
{
    switch (_Period)
    {
        case PERIOD_M1: return "M1";
        case PERIOD_M5: return "M5";
        case PERIOD_D1: return "D1";
        case PERIOD_H1: return "H1";
        case PERIOD_H4: return "H4";
        case PERIOD_M15: return "M15";
        case PERIOD_M30: return "M30";
        case PERIOD_MN1: return "MN1";
        case PERIOD_W1: return "W1";
    }
    return "M1";
}

void SendNotifications(const int direction)
{
    static datetime _lastDatetime;
    datetime currentTime = iTime(NULL, NULL, 0);
    if (_lastDatetime == currentTime)
        return;

    _lastDatetime = currentTime;
    if (direction == 0)
        return;
        
    string tf = GetTimeframe();
    string alert_Subject;
    string alert_Body;
    switch (direction)
    {
        case 1:
            alert_Subject = "Both lines above 0 on " + _Symbol + "/" + tf;
            alert_Body = "Both lines above 0 on " + _Symbol + "/" + tf;
            break;
        case -1:
            alert_Subject = "Both lines below 0 on " + _Symbol + "/" + tf;
            alert_Body = "Both lines below on " + _Symbol + "/" + tf;
            break;
        case 2:
            alert_Subject = "Exit buy signal on " + _Symbol + "/" + tf;
            alert_Body = "Exit buy signal on " + _Symbol + "/" + tf;
            break;
        case -2:
            alert_Subject = "Exit sell signal on " + _Symbol + "/" + tf;
            alert_Body = "Exit sell signal on " + _Symbol + "/" + tf;
            break;
    }
    
    if (Sound_Alert)
        Alert(alert_Body);
    if (Email_Alert)
        SendMail(alert_Subject, alert_Body);
    if (Telegram_Alert && Telegram_Key != "")
        AlertTelegram(Telegram_Key, alert_Body, _Symbol, tf);
}

int start()
{
    if(Bars<=3) return(0);
    int ExtCountedBars=IndicatorCounted();
    if (ExtCountedBars<0) return(-1);
    int limit=Bars-2;
    if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
    int pos;
    double Pr, MA;
    pos=limit;
    while(pos>=0)
    {
        Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
        if (Method1 != VWMA)
        {
            MA = iMA(NULL, 0, Length1, 0, (int)Method1, Price, pos);
        }
        else
        {
            if (Price == 0)
            {
                vwma_1[pos] = Close[pos] * Volume[pos];
            }
            else if (Price == 1)
            {
                vwma_1[pos] = Open[pos] * Volume[pos];
            }
            else if (Price == 2)
            {
                vwma_1[pos] = High[pos] * Volume[pos];
            }
            else if (Price == 3)
            {
                vwma_1[pos] = Low[pos] * Volume[pos];
            }
            else if (Price == 4)
            {
                vwma_1[pos] = ((High[pos] + Low[pos]) / 2) * Volume[pos];
            }
            else if (Price == 5)
            {
                vwma_1[pos] = ((High[pos] + Low[pos] + Close[pos]) / 3) * Volume[pos];
            }
            else if (Price == 6)
            {
                vwma_1[pos] = ((High[pos] + Low[pos] + 2 * Close[pos]) / 4) * Volume[pos];
            }
            if (limit - pos >= Length1)
            {
                double vma_summ = 0;
                double volume_summ = 0;
                for (int i = 0; i < Length1; ++i)
                {
                    vma_summ += vwma_1[pos + i];
                    volume_summ += Volume[pos + i];
                }
                MA = volume_summ == 0.0 ? EMPTY_VALUE : vma_summ / volume_summ;
            }
            else
            {
                MA = EMPTY_VALUE;
            }
        }

        if (MA != EMPTY_VALUE)
            Dist[pos]=Pr-MA;
        pos--;
    } 
    
    if (Smoothing)
    {
        pos=limit;
        while(pos>=0)
        {
            if (Method2 != VWMA)
            {
                Smoothed[pos]=iMAOnArray(Dist, 0, Length2, 0, (int)Method2, pos);
            }
            else
            {
                vwma_2[pos] = Dist[pos] * Volume[pos];
                if (limit - pos >= Length2)
                {
                    vma_summ = 0;
                    volume_summ = 0;
                    for (i = 0; i < Length2; ++i)
                    {
                        vma_summ += vwma_2[pos + i];
                        volume_summ += Volume[pos + i];
                    }
                    Smoothed[pos] = volume_summ == 0.0 ? EMPTY_VALUE : vma_summ / volume_summ;
                }
                else
                {
                    Smoothed[pos] = EMPTY_VALUE;
                }
            }
            if (pos == 0)
            {
                bool positive_0 = Dist[pos] >= 0;
                bool positive_1 = Dist[pos + 1] >= 0;
                bool s_positive_0 = Smoothed[pos] >= 0;
                bool s_positive_1 = Smoothed[pos + 1] >= 0;
                if (positive_0 == s_positive_0 && positive_1 != s_positive_1)
                {
                    if (positive_0)
                    {
                        SendNotifications(1);
                    }
                    else
                    {
                        SendNotifications(-1);
                    }
                }
            }

            pos--;
        }
    } 
    
    return(0);
}

