// Id: 20471
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65625

//+------------------------------------------------------------------+
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright � 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Blue
#property indicator_color3 Red

extern int ADX_Filter_Length = 14;
extern double ADX_Filter_Value = 4.0;
extern int Length=14;
extern double Fast_Level=5.;
extern double Slow_Level=2.5;
extern int ROC_Length=1;
extern double alertLevel = 2.0;
extern bool alertLevelCross = true;
extern bool alertColorChange = false;
extern bool   alertsOn              = false;
extern int    alertsLevel           = 3;
extern bool   alertsMessage         = true;
extern bool   alertsSound           = false;
extern bool   alertsEmail           = false;
extern bool   alertsNotification    = false;

double Fast[], Moderate[], Slow[], Diff[];

int init()
{
        double temp = iCustom(NULL, 0, "Wilders DMI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Wilders DMI' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("ADX ROC value oscillator");
    IndicatorDigits(Digits);
    SetIndexStyle(0,DRAW_HISTOGRAM);
    SetIndexBuffer(0,Fast);
    SetIndexStyle(1,DRAW_HISTOGRAM);
    SetIndexBuffer(1,Moderate);
    SetIndexStyle(2,DRAW_HISTOGRAM);
    SetIndexBuffer(2,Slow);
    SetIndexStyle(3, DRAW_NONE);
    SetIndexBuffer(3, Diff);
    return(0);
}

int deinit()
{
    return(0);
}

int last_signal = -1;

int start()
{
    if(Bars<=3)
        return(0);
    int ExtCountedBars=IndicatorCounted();
    if (ExtCountedBars<0)
        return(-1);
    int limit=Bars-2;
    if(ExtCountedBars>2)
        limit=Bars-ExtCountedBars-1;
    int pos;
    double ADX0, ADX_ROC;
    double diff, Absdiff;
    pos=limit;
    while(pos>=0)
    {
        double adx_filter = iADX(NULL, 0, ADX_Filter_Length, PRICE_CLOSE, 0, 0);
        Fast[pos]=0.;
        Moderate[pos]=0.;
        Slow[pos]=0.;
        if (adx_filter >= ADX_Filter_Value)
        {
            ADX0=iCustom(NULL, 0, "Wilders DMI", "Current time frame", Length, 2, pos);
            ADX_ROC=iCustom(NULL, 0, "Wilders DMI", "Current time frame", Length, 2, pos+ROC_Length);
            diff=ADX0-ADX_ROC;
            Diff[pos] = diff;
            Absdiff=MathAbs(diff);

            if (Absdiff>=Fast_Level)
            {
                Fast[pos]=diff;
                if (last_signal != 0 && alertColorChange)
                {
                    doAlert("Fast section");
                    last_signal = 0;
                }
            }
            else
            {
                if (Absdiff<=Slow_Level)
                {
                    Slow[pos]=diff;
                    if (last_signal != 1 && alertColorChange)
                    {
                        doAlert("Slow section");
                        last_signal = 1;
                    }
                }
                else
                {
                    Moderate[pos]=diff;
                    if (last_signal != 2 && alertColorChange)
                    {
                        doAlert("Moderate section");
                        last_signal = 2;
                    }
                }
            }
            if (alertLevelCross && Diff[pos] > alertLevel && Diff[pos + 1] <= alertLevel)
            {
                if (last_signal != 3)
                {
                    doAlert("Crossing over " + DoubleToString(alertLevel));
                    last_signal = 3;
                }
            }
            else if (alertLevelCross && Diff[pos] < alertLevel && Diff[pos + 1] >= alertLevel)
            {
                if (last_signal != 4)
                {
                    doAlert("Crossing under " + DoubleToString(alertLevel));
                    last_signal = 4;
                }
            }
        }

        pos--;
    }
    return(0);
}

void doAlert(string message)
{
    static datetime previousTime;

    if (previousTime != Time[0])
    {
        string data = Symbol() + " (" + timeFrameToString(Period()) + "):";
        previousTime = Time[0];
        if (alertsMessage)
            Alert(data + message);
        if (alertsEmail)
            SendMail(data + " Wilders ADX ROC Value Oscillator", message);
        if (alertsSound)
            PlaySound("alert2.wav");
        if (alertsNotification)
            SendNotification(data + message);
    }
}

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
