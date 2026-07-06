
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66203
// Id: 

//+------------------------------------------------------------------+
//|                                      Converted by : Mario Jemic  |
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
#property version "1.0"

//+------------------------------------------------+
//|  Indicator drawing parameters                  |
//+------------------------------------------------+
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- five buffers are used for calculation and drawing the indicator
#property indicator_buffers 4
//---- only one plot is used
#property indicator_plots   1
//---- displaying the indicator label
#property indicator_label1  "FiboCandles Open; FiboCandles High; FiboCandles Low; FiboCandles Close"
//+------------------------------------------------+
//|  Declaration of constants                      |
//+------------------------------------------------+
#define RESET  0 // the constant for getting the command for the indicator recalculation back to the terminal
//---- Fibo levels constants
#define LEVEL_1 0.236
#define LEVEL_2 0.382
#define LEVEL_3 0.500
#define LEVEL_4 0.618
#define LEVEL_5 0.762
//+------------------------------------------------+
//|  Enumeration for Fibo levels                   |
//+------------------------------------------------+
enum ENUM_FIBORATIO //Type of constant
  {
   LEVEL_1_ = 1,   //0.236
   LEVEL_2_,       //0.382
   LEVEL_3_,       //0.500
   LEVEL_4_,       //0.618
   LEVEL_5_        //0.762
  };
//+------------------------------------------------+ 
//| Enumeration for the level actuation indication |
//+------------------------------------------------+ 
enum ENUM_ALERT_MODE //Type of constant
  {
   OnlySound,   //only sound
   OnlyAlert    //only alert
  };
//+------------------------------------------------+
//| Indicator input parameters                     |
//+------------------------------------------------+
input int period=10;                        // Indicator period
input ENUM_FIBORATIO fiboLevel=LEVEL_1_;    // Fibo level value
//---- settings for submitted alerts
input uint SignalBar=0;                     // Signal bar index, 0 is a current bar
input ENUM_ALERT_MODE alert_mode=OnlySound; // Actuation indication version
input uint AlertCount=0;                    // Number of submitted alerts
extern int BarWidth = 5;
extern color UP_Color=Teal;
extern color DN_Color=Magenta;
//+------------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double OpenColor1[];
double CloseColor1[];
double OpenColor2[];
double CloseColor2[];
//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//---- declaration of a variable for storing the Fibo level
double level;
//+------------------------------------------------------------------+
//|  Getting a timeframe as a line                                   |
//+------------------------------------------------------------------+
string GetStringTimeframe(int timeframe)
{
    switch (timeframe)
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
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
//--- initialization of global variables 
    min_rates_total=period;

    switch(fiboLevel)
    {
        case 1: level = LEVEL_1; break;
        case 2: level = LEVEL_2; break;
        case 3: level = LEVEL_3; break;
        case 4: level = LEVEL_4; break;
        case 5: level = LEVEL_5; break;
    }

//---- set dynamic arrays as indicator buffers
    SetIndexBuffer(0, OpenColor1, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, BarWidth, UP_Color);
    SetIndexBuffer(1, CloseColor1, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, BarWidth, UP_Color);
    SetIndexBuffer(2, OpenColor2, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_HISTOGRAM, EMPTY, BarWidth, DN_Color);
    SetIndexBuffer(3, CloseColor2, INDICATOR_DATA);
    SetIndexStyle(3, DRAW_HISTOGRAM, EMPTY, BarWidth, DN_Color);

//---- setting the format of accuracy of displaying the indicator
    IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
    string short_name="Fibo Candles 2";
    IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
//---- checking the number of bars to be enough for the calculation
    if(rates_total<min_rates_total) return(RESET);

//---- declarations of local variables 
    int limit,bar,trend;
    double maxHigh,minLow,range;
    static int trend_;
    static uint buycount=0,sellcount=0;

//---- calculation of the 'first' starting index for the bars recalculation loop
    if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
    {
        trend_=0;
        limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
    }
    else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//---- set alerts counters to the initial position   
    if(rates_total!=prev_calculated && AlertCount)
    {
        buycount=AlertCount;
        sellcount=AlertCount;
    }

//---- restore values of the variables
    trend=trend_;

//---- main indicator calculation loop
    for(bar=limit; bar>=0 && !IsStopped(); bar--)
    {
        //---- store values of the variables before running at the current bar
        if(rates_total!=prev_calculated && bar==0) trend_=trend;

        maxHigh=high[ArrayMaximum(high,bar,period)];
        minLow=low[ArrayMinimum(low,bar,period)];
        range=maxHigh-minLow;

        if(open[bar]>close[bar])
        {
            if(!(trend<0 && range*level<close[bar]-minLow)) trend=+1;
            else trend=-1;
        }
        else
        {
            if(!(trend>0 && range*level<maxHigh-close[bar])) trend=-1;
            else trend=+1;
        }

        if(trend==+1)
        {
            OpenColor1[bar] = MathMax(open[bar], close[bar]);
            CloseColor1[bar] = MathMin(open[bar], close[bar]);
            OpenColor2[bar] = EMPTY_VALUE;
            CloseColor2[bar] = EMPTY_VALUE;
        }

        if(trend==-1)
        {
            OpenColor2[bar] = MathMin(open[bar], close[bar]);
            CloseColor2[bar] = MathMax(open[bar], close[bar]);
            OpenColor1[bar] = EMPTY_VALUE;
            CloseColor1[bar] = EMPTY_VALUE;
        }
    }

    if (OpenColor2[SignalBar + 1] == EMPTY_VALUE && OpenColor1[SignalBar] != EMPTY_VALUE && buycount)
    {
        if(alert_mode==OnlyAlert) Alert("FiboCandles: Signal for buying by ",Symbol(),GetStringTimeframe(_Period));
        if(alert_mode==OnlySound) PlaySound("alert.wav");
        buycount--;
    }

    if (OpenColor1[SignalBar + 1] == EMPTY_VALUE && OpenColor2[SignalBar] == EMPTY_VALUE && sellcount)
    {
        if(alert_mode==OnlyAlert) Alert("FiboCandles: Signal for selling by ",Symbol(),GetStringTimeframe(_Period));
        if(alert_mode==OnlySound) PlaySound("alert.wav");
        sellcount--;
    }
//----     
    return(rates_total);
}
//+------------------------------------------------------------------+
