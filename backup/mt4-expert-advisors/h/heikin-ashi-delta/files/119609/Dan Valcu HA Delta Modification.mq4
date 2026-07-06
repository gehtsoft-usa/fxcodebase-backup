// Id: 21566
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=59132
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
//|                                 Patreon : https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property strict
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Green
#property indicator_color2 Gray
#property indicator_color3 Blue
#property indicator_color4 Green
#property indicator_color5 Red
#property indicator_color6 Green
#property indicator_color7 Red

extern int Length = 3; // 1. Smoothing Period
extern int Length2 = 3; // 2. Smoothing Period

double Delta[], Average[], Average2[];
double Up[], Down[];
double UpArr[], DownArr[];

int init()
{
        double temp = iCustom(NULL, 0, "Heiken Ashi", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Heiken Ashi' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Dan Valcu Heikin-Ashi Delta");
    IndicatorDigits(Digits);
    SetIndexStyle(0,DRAW_NONE);
    SetIndexBuffer(0,Delta);
    SetIndexStyle(1,DRAW_LINE);
    SetIndexBuffer(1,Average);
    SetIndexStyle(2, DRAW_LINE);
    SetIndexBuffer(2, Average2);

    SetIndexStyle(3, DRAW_ARROW, 0, 1);
    SetIndexArrow(3, 108);
    SetIndexBuffer(3, Up);
    SetIndexStyle(4, DRAW_ARROW, 0, 1);
    SetIndexArrow(4, 108);
    SetIndexBuffer(4, Down);
    
    SetIndexStyle(5, DRAW_ARROW, 0, 1);
    SetIndexArrow(5, 217);
    SetIndexBuffer(5, UpArr);
    SetIndexStyle(6, DRAW_ARROW, 0, 1);
    SetIndexArrow(6, 218);
    SetIndexBuffer(6, DownArr);
    return(0);
}

int deinit()
{
    return(0);
}

int start()
{
    if(Bars<=12) return(0);
    int ExtCountedBars=IndicatorCounted();
    if (ExtCountedBars<0) return(-1);
    int limit=Bars-12;
    if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
    int pos;
    double HA_Open0, HA_Open1;
    pos=limit;
    while(pos>=0)
    {
        HA_Open0 = iCustom(NULL, 0, "Heiken Ashi", 2, pos);
        HA_Open1 = iCustom(NULL, 0, "Heiken Ashi", 2, pos + 1);
        Delta[pos] = HA_Open0 - HA_Open1;
        pos--;
    } 
    
    pos=MathMin(limit, Bars-Length-12);
    while(pos>=0)
    {
        Average[pos] = iMAOnArray(Delta, 0, Length, 0, MODE_SMA, pos);
        Average2[pos] = iMAOnArray(Average, 0, Length2, 0, MODE_SMA, pos);
        if (Average[pos] > Average2[pos + 1])
        {
            Up[pos] = Average[pos];
        }
        else if (Average[pos] < Average2[pos + 1])
        {
            Down[pos] = Average[pos];
        }
        if (Average2[pos] > 0 && Average2[pos + 1] <= 0)
        {
		    UpArr[pos] = 0;
		}
		else if (Average2[pos] < 0 && Average2[pos + 1] >= 0)
		{
		    DownArr[pos] = 0;
		}
        pos--;
    } 
    
    return(0);
}

