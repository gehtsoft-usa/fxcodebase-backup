// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=60402


//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Yellow

extern int Length=14;
extern int Center=50;
extern int Price=5;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  
extern int Overbought = 80;
extern int Oversold = 20;
extern bool Sound_Alert = true;
extern bool Email_Alert = false;

double MFI[];
double Pos[], Neg[], Pr[];

int init()
{
 IndicatorShortName("Money flow index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MFI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Pos);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Neg);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Pr);
 SetLevelValue(0, Center);
 SetLevelValue(1, 0);
 SetLevelValue(2, 20);
 SetLevelValue(3, 80);
 SetLevelValue(4, 100);
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
    if(Bars<=3) return(0);
    int ExtCountedBars=IndicatorCounted();
    if (ExtCountedBars<0) return(-1);
    int limit=Bars-2;
    if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
    int pos;
    pos=limit;
    while(pos>=0)
    {
        Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
        pos--;
    } 
    
    pos=limit;
    while(pos>=0)
    {
        Pos[pos]=0;
        Neg[pos]=0;
        if (Pr[pos]>Pr[pos+1])
        {
            Pos[pos]=Pr[pos]*Volume[pos]*Point;
        }
        else
        {
            if (Pr[pos]<Pr[pos+1])
            {
                Neg[pos]=Pr[pos]*Volume[pos]*Point;
            }
        }
        pos--;
    }  
    
    double MA_Pos, MA_Neg;
    double r;
    pos=limit;
    while(pos>=0)
    {
        MA_Pos=iMAOnArray(Pos, 0, Length, 0, MODE_SMA, pos);
        MA_Neg=iMAOnArray(Neg, 0, Length, 0, MODE_SMA, pos);
        if (MA_Neg!=0.)
        {
            r=MA_Pos/MA_Neg;
        }
        else
        {
            r=0.;
        }
        MFI[pos]=100.-(100./(1.+r));
        if (MFI[pos] > Overbought && MFI[pos + 1] <= Overbought)
        {
            SendNotifications(1, pos == 0);
        }
        else if (MFI[pos] < Oversold && MFI[pos + 1] >= Oversold)
        {
            SendNotifications(-1, pos == 0);
        }
        pos--;
    }
    
    return(0);
}

void SendNotifications(const int direction, const bool last)
{
    if (!last)
        return;
    static datetime _lastDatetime;
    datetime currentTime = Time[0];
    if (_lastDatetime == currentTime)
        return;

    _lastDatetime = currentTime;
    if (direction == 0)
        return;

    string tf = GetTimeframe();
    string alert_Subject = "MFI on " + Symbol() + "/" + tf;
    string alert_Body = "MFI on " + Symbol() + "/" + tf + ": " + direction == 1 ? "Overbought" : "Oversold";
    
    if (Sound_Alert)
        Alert(alert_Body);
    if (Email_Alert)
        SendMail(alert_Subject, alert_Body);
}

string GetTimeframe()
{
    switch (Period())
    {
        case PERIOD_M1:
            return "M1";
        case PERIOD_M5:
            return "M5";
        case PERIOD_D1:
            return "D1";
        case PERIOD_H1:
            return "H1";
        case PERIOD_H4:
            return "H4";
        case PERIOD_M15:
            return "M15";
        case PERIOD_M30:
            return "M30";
        case PERIOD_MN1:
            return "MN1";
        case PERIOD_W1:
            return "W1";
    }
    return "M1";
}

