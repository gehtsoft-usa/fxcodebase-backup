// More information about this indicator can be found at:
// http://www.fxcodebase.com/code/viewtopic.php?f=38&t=65682

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

#property indicator_chart_window
#property indicator_buffers 10
#property indicator_color1 Green
#property indicator_color2 Yellow
#property indicator_color3 Green
#property indicator_color4 Yellow

extern int Length=9;
extern int MaxBars=100;
extern color UP_Color=Green;
extern color DN_Color=Red;
extern color OB_Color=Blue;
extern int BarWidth = 5;
extern bool Sound_Alert = true;
extern bool Email_Alert = false;

double Buff5[], Buff6[], Up[], Dn[];
double BarH[], BarL[], BarN[], CandleH[], CandleL[], CandleN[];

int init()
  {
   IndicatorShortName("Overbought/Oversold Indicator");
   IndicatorDigits(Digits);
    SetIndexBuffer(0, BarH);
    SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, BarWidth, UP_Color);
    SetIndexBuffer(1, CandleH);
    SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, BarWidth, UP_Color);
    SetIndexBuffer(2, BarL);
    SetIndexStyle(2, DRAW_HISTOGRAM, EMPTY, BarWidth, DN_Color);
    SetIndexBuffer(3, CandleL);
    SetIndexStyle(3, DRAW_HISTOGRAM, EMPTY, BarWidth, DN_Color);
    SetIndexBuffer(4, BarN);
    SetIndexStyle(4, DRAW_HISTOGRAM, EMPTY, BarWidth, OB_Color);
    SetIndexBuffer(5, CandleN);
    SetIndexStyle(5, DRAW_HISTOGRAM, EMPTY, BarWidth, OB_Color);
   SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(6,Up);
   SetIndexStyle(7,DRAW_NONE);
   SetIndexBuffer(7,Dn);
   SetIndexStyle(8,DRAW_NONE);
   SetIndexBuffer(8,Buff5);
   SetIndexStyle(9,DRAW_NONE);
   SetIndexBuffer(9,Buff6);   
    
    return(0);
}

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 limit=MathMax(limit, MaxBars);
 pos=limit;
 double Buff1, Buff3, Buff4;
 while(pos>=0)
 {
  Buff1=(High[pos]+Low[pos]+Close[pos]+Close[pos])/4;
  Buff3=iMA(NULL, 0, Length, 0, MODE_EMA, PRICE_WEIGHTED, pos);
  Buff4=iStdDev(NULL, 0, Length, 0, MODE_EMA, PRICE_WEIGHTED, pos);
  if (Buff4!=0) 
  {
   Buff5[pos]=(Buff1-Buff3)*100/Buff4; 
  } 
  pos--;
 } 
 pos=limit;
 while(pos>=0)
 {
  Buff6[pos]=iMAOnArray(Buff5, 0, Length, 0, MODE_EMA, pos);
  pos--;
 }
 pos=limit;
 while(pos>=0)
 {
  Up[pos]=iMAOnArray(Buff6, 0, Length, 0, MODE_EMA, pos);
  pos--;
 }
 pos=limit - 1;
 
    while(pos>=0)
    {
        Dn[pos]=iMAOnArray(Up, 0, Length, 0, MODE_EMA, pos);
        if (Up[pos + 1] < Up[pos] && Dn[pos + 1] < Dn[pos])
        {
            BarH[pos] = Close[pos];
            CandleH[pos] = Open[pos];
            BarL[pos] = EMPTY_VALUE;
            CandleL[pos] = EMPTY_VALUE;
            BarN[pos] = EMPTY_VALUE;
            CandleN[pos] = EMPTY_VALUE;
            SendNotifications(1, pos == 0);
        }
        else if (Up[pos + 1] > Up[pos] && Dn[pos + 1] > Dn[pos])
        {
            BarL[pos] = Close[pos];
            CandleL[pos] = Open[pos];
            BarH[pos] = EMPTY_VALUE;
            CandleH[pos] = EMPTY_VALUE;
            BarN[pos] = EMPTY_VALUE;
            CandleN[pos] = EMPTY_VALUE;
            SendNotifications(-1, pos == 0);
        }
        else
        {
            BarL[pos] = EMPTY_VALUE;
            CandleL[pos] = EMPTY_VALUE;
            BarH[pos] = EMPTY_VALUE;
            CandleH[pos] = EMPTY_VALUE;
            BarN[pos] = Close[pos];
            CandleN[pos] = Open[pos];
            SendNotifications(0, pos == 0);
        }
        
        pos--;
    }

    return(0);
}


void SendNotifications(const int direction, const bool last)
{
    static int lastDirection = 0;
    if (lastDirection == direction)
        return;
    lastDirection = direction;
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
    string alert_Subject = "OBOS on " + Symbol() + "/" + tf;
    string alert_Body = "OBOS on " + Symbol() + "/" + tf + ": " + (direction == 1 ? "Overbought" : "Oversold");
    
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

