// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66416
// Id: 

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property description "Three MA Trend Continuation"
#property strict

#property indicator_chart_window
#property indicator_buffers 8

#property indicator_color1  clrRed
#property indicator_width1  1
#property indicator_color2  clrYellow
#property indicator_width2  2
#property indicator_color3  clrWhite
#property indicator_width3  2

#property indicator_color4  clrLime
#property indicator_width4  2
#property indicator_color5  clrRed
#property indicator_width5  2
#property indicator_color6  clrLime
#property indicator_width6  2
#property indicator_color7  clrRed
#property indicator_width7  2

enum AveragesMethod
{
    SMA = MODE_SMA, // SMA
    EMA = MODE_EMA, // EMA
    SMMA = MODE_SMMA, // SMMA
    LWMA = MODE_LWMA // LWMA
};

extern int      Period1        = 10;
extern AveragesMethod Method1        = EMA;
extern int      Period2        = 15;
extern AveragesMethod Method2        = EMA;
extern int      Period3        = 50;
extern AveragesMethod Method3        = SMA;

extern int      Limit_Bars        = 800;
extern bool     Sound_Alert              = true; // Sound alert
extern bool     Notification_Alert       = false; // Notification alert
extern bool     Email_Alert              = false; // Email alert
extern bool     Play_Sound               = false; // Play sound on alert
extern bool     Telegram_Alert           = false; // External alert
extern string   Telegram_Key             = ""; // External alert key
extern string   Comment2                 = "- You can get a external alert key by starting a dialog with @profit_robots_bot Telegram bot -";
extern string   Comment3                 = "- Also, you need to install TelegramNotificationsLib.dll and allow use of dll in the indicator parameters window -";

// TelegramNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "TelegramNotificationsLib.dll"
void AlertTelegram(string key, string text, string instrument, string timeframe);
#import

double MA1[], MA2[], MA3[];
double Up[], Dn[];
double UpExit[], DnExit[];
double Alert[];

int init()
{
    IndicatorShortName("Three MA Trend Continuation");
    IndicatorBuffers(8);
    
    SetIndexStyle(0,DRAW_LINE);
    SetIndexBuffer(0,MA1);
    SetIndexLabel(0,"MA1");
    SetIndexDrawBegin(0,Limit_Bars);
    
    SetIndexStyle(1,DRAW_LINE);
    SetIndexBuffer(1,MA2);
    SetIndexLabel(1,"MA2");
    SetIndexDrawBegin(1,Limit_Bars);
    
    SetIndexStyle(2,DRAW_LINE);
    SetIndexBuffer(2,MA3);
    SetIndexLabel(2,"MA3");
    SetIndexDrawBegin(2,Limit_Bars);
    
    SetIndexStyle(3,DRAW_ARROW);
    SetIndexBuffer(3,Up);
    SetIndexArrow(3,252);
    SetIndexLabel(3,"Up");
    
    SetIndexStyle(4,DRAW_ARROW);
    SetIndexBuffer(4,Dn);
    SetIndexArrow(4,252);
    SetIndexLabel(4,"Dn");
    
    SetIndexStyle(5,DRAW_ARROW);
    SetIndexBuffer(5,UpExit);
    SetIndexArrow(5,251);
    SetIndexLabel(5,"Up Exit");
    
    SetIndexStyle(6,DRAW_ARROW);
    SetIndexBuffer(6,DnExit);
    SetIndexArrow(6,251);
    SetIndexLabel(6,"Dn Exit");

    SetIndexStyle(7, DRAW_NONE);
    SetIndexBuffer(7, Alert);

    return(0);
}
  
int start()
{
    int i;
    int counted_bars=IndicatorCounted();
    int limit = Bars-counted_bars-1;
    if (Limit_Bars)
        limit = Limit_Bars;
    
    for (i = limit - 1; i >= 0; i--)
    {
        MA1[i] = iMA(NULL,0, Period1,0,ENUM_MA_METHOD(Method1),PRICE_CLOSE,i);
        MA2[i] = iMA(NULL,0, Period2,0,ENUM_MA_METHOD(Method2),PRICE_CLOSE,i);
        MA3[i] = iMA(NULL,0, Period3,0,ENUM_MA_METHOD(Method3),PRICE_CLOSE,i);
        if (Close[i] > MA1[i] && Close[i] > MA2[i] && Close[i] > MA3[i])
            Alert[i] = 2;
        else if (Close[i] < MA1[i] && Close[i] < MA2[i] && Close[i] < MA3[i])
            Alert[i] = -2;
        else if (Close[i] < MA1[i] && Close[i] < MA2[i] && Close[i] > MA3[i])
            Alert[i] = 1;
        else if (Close[i] > MA1[i] && Close[i] > MA2[i] && Close[i] < MA3[i])
            Alert[i] = -1;
        else
            Alert[i] = Alert[i + 1];

        if (Alert[i] != Alert[i + 1])
        {
            int alert = (int)Alert[i];
            switch (alert)
            {
                case 2:
                    Up[i] = MA3[i];
                    break;
                case 1:
                    UpExit[i] = MA3[i];
                    break;
                case -1:
                    DnExit[i] = MA3[i];
                    break;
                case -2:
                    Dn[i] = MA3[i];
                    break;
            }
            if (i == 0)
                SendNotifications(alert);
        }
    }
    return(0);
}

void SendNotifications(const int direction)
{
    static datetime _lastDatetime;
    datetime currentTime = iTime(NULL, NULL, 0);
    if (_lastDatetime == currentTime || direction == 0)
        return;

    _lastDatetime = currentTime;
        
    string tf = GetTimeframe();
    string alert_Subject;
    string alert_Body;
    switch (direction)
    {
        case 1:
            alert_Subject = "Up exit on " + _Symbol + "/" + tf;
            alert_Body = "Up exit on " + _Symbol + "/" + tf;
            break;
        case -1:
            alert_Subject = "Down exit on " + _Symbol + "/" + tf;
            alert_Body = "Down exit on " + _Symbol + "/" + tf;
            break;
        case 2:
            alert_Subject = "Up on " + _Symbol + "/" + tf;
            alert_Body = "Up on " + _Symbol + "/" + tf;
            break;
        case -2:
            alert_Subject = "Down on " + _Symbol + "/" + tf;
            alert_Body = "Down on " + _Symbol + "/" + tf;
            break;
    }
    
    if (Sound_Alert)
        Alert(alert_Body);
    if (Notification_Alert)
        SendNotification(alert_Body);
    if (Email_Alert)
        SendMail(alert_Subject, alert_Body);
    if (Play_Sound)
        PlaySound("alert2.wav");
    if (Telegram_Alert && Telegram_Key != "")
        AlertTelegram(Telegram_Key, alert_Body, _Symbol, tf);
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