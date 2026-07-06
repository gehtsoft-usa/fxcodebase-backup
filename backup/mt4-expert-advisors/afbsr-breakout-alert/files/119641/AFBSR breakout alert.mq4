// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66213
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

string IndicatorName = "Advanced Fractal Based Support/Resistance lines breakout alert";
//2. Implement int GetDirection(
//3. place your parameters here

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_label1 "BUY"
#property indicator_label2 "SELL"

enum AllowSide
{
    Both, // Both
    Buy, // Buy
    Sell // Sell
};

extern int Frame = 5; // Number of fractals (Odd)
extern bool ShowLine = false; // Show Lines
extern AllowSide ALLOWEDSIDE = Both; //Allowed side
extern bool ON1 = true; //Show AFBSR Break Alert
extern bool     Sound_Alert              = true;
extern bool     Email_Alert              = false;
extern bool     Telegram_Alert           = false;
extern string   Telegram_Key             = "";
extern string   Comment2                 = "- You can get a telegram key by starting a dialog with @profit_robots_bot -";
extern string   Comment3                 = "- Also, you need to install TelegramNotificationsLib.dll and allow use of dll in the indicator parameters window -";
extern string Label1 = "AFBSR Break"; // Label

double buy[], sell[], R[], S[];
#import "TelegramNotificationsLib.dll"
void AlertTelegram(string key, string text, string instrument, string timeframe);
#import

int count;

int init()
{
    IndicatorShortName(IndicatorName);
    IndicatorDigits(Digits);
    SetIndexStyle(0, DRAW_ARROW, 0, 2);
    SetIndexArrow(0, 217);
    SetIndexBuffer(0, buy);
    SetIndexStyle(1, DRAW_ARROW, 0, 2);
    SetIndexArrow(1, 218);
    SetIndexBuffer(1, sell);

    SetIndexBuffer(2, R);
    SetIndexStyle(2, ShowLine ? DRAW_LINE : DRAW_NONE, 0, 2);
    SetIndexBuffer(3, S);
    SetIndexStyle(3, ShowLine ? DRAW_LINE : DRAW_NONE, 0, 2);

    int hof = Frame;
    for (int i = 1; i <= Frame; ++i)
    {
        if (hof > 1)
        {
            hof = hof - 2;
            count = count + 1;
        }
        else
        {
            count = count - 1;
            break;
        }
    }
    
    return(0);
}

int deinit()
{
    return(0);
}

int GetDirection(const int pos)
{
    if (!ON1)
    {
        return 0;
    }
    if (Close[pos] > R[pos] && Close[pos + 1] <= R[pos + 1] && R[pos] == R[pos + 1] && ALLOWEDSIDE != Sell)
    {
        return 1;
    }
    else if (Close[pos] < S[pos] && Close[pos + 1] >= S[pos + 1] && S[pos] == S[pos + 1] && ALLOWEDSIDE != Buy)
    {
        return -1;
    }
    return 0;
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
            alert_Subject = Label1 + "Cross Over on " + _Symbol + "/" + tf;
            alert_Body = Label1 + "Cross Over on " + _Symbol + "/" + tf;
            break;
        case -1:
            alert_Subject = Label1 + "Cross Under on " + _Symbol + "/" + tf;
            alert_Body = Label1 + "Cross Under on " + _Symbol + "/" + tf;
            break;
    }
    
    if (Sound_Alert)
        Alert(alert_Body);
    if (Email_Alert)
        SendMail(alert_Subject, alert_Body);
    if (Telegram_Alert && Telegram_Key != "")
        AlertTelegram(Telegram_Key, alert_Body, _Symbol, tf);
}

bool IsLowest(const int pos)
{
    int x = pos + count * 2;
    double curr = Low[pos + count];
    for (int i = x; i >= pos; --i)
    {
        if (curr > Low[i])
        {
            return false;
        }
    }
    return true;
}

bool IsHighest(const int pos)
{
    int x = pos + count * 2;
    double curr = High[pos + count];
    for (int i = x; i >= pos; --i)
    {
        if (curr < High[i])
        {
            return false;
        }
    }
    return true;
}

int start()
{
    if (Bars <= 1) return(0);
    int ExtCountedBars = IndicatorCounted();
    if (ExtCountedBars < 0) return(-1);
    int limit = Bars - 1;
    if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;

    int pos = limit - count * 2;
    while (pos >= 0)
    {
        double curr = High[pos + count];
        if (IsHighest(pos))
        {
            R[pos + 2] = curr;
            R[pos + 1] = curr;
            R[pos] = curr;
        }
        else if (R[pos + 1] != EMPTY_VALUE)
        {
            R[pos] = R[pos + 1];
        }

        curr = Low[pos + count];
        if (IsLowest(pos))
        {
            S[pos + 2] = curr;
            S[pos + 1] = curr;
            S[pos] = curr;
        }
        else if (S[pos + 1] != EMPTY_VALUE)
        {
            S[pos] = S[pos + 1];
        }

        int direction = GetDirection(pos);
        switch (direction)
        {
            case 1:
                buy[pos] = Low[pos];
                sell[pos] = EMPTY_VALUE;
                break;
            case -1:
                buy[pos] = EMPTY_VALUE;
                sell[pos] = High[pos];
                break;
        }
        if (pos == 0)
            SendNotifications(direction);
        pos--;
    } 
    return(0);
}
