//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73990

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 3
#property indicator_label1 "High Overnight"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Low Overnight"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Close Last USA Session"
#property  indicator_type3  DRAW_LINE
#property indicator_color3 clrOrange
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1

//--- indicator buffers
double Hi [];
double Lo [];
double Cl [];


// ------------------------------------------------------------------
input int    periods = 10;
input string T1 = "== Notifications ==";  // ————————————
input bool   notifications = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications = false;                  // Email Notifications
input bool   push_notifications = false;                  // Push Mobile Notifications
input string T2 = "== Set Lines ==";      // ————————————
input bool   LinesOn = true;                   // Lines On?
input color  LineUpClr = clrBlue;                // Line Up Color:
input color  LineDnClr = clrRed;                 // Line Down Color:
input bool   CloseOn = true;                   // Draw Last Close On?
input color  LineClClr = clrOrange;                 // Line Close Color:
// ------------------------------------------------------------------

class CNewCandle
{
    private:
    int    _initialCandles;
    string _symbol;
    int    _tf;

    public:
    CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
    CNewCandle()
    {
        // toma los valores del chart actual
        _initialCandles = iBars(Symbol(), Period());
        _symbol = Symbol();
        _tf = Period();
    }
    ~CNewCandle() { ; }

    bool IsNewCandle()
    {
        int _currentCandles = iBars(_symbol, _tf);
        if(_currentCandles > _initialCandles)
        {
            _initialCandles = _currentCandles;
            return true;
        }

        return false;
    }
};
CNewCandle newCandle();

class SearchExtremes
{
    int iniTime;
    int endTime;

    public:
    SearchExtremes() { ; }
    ~SearchExtremes() { ; }

    double Maximum(datetime iniTm, datetime endTm, string _mode, string symbol = NULL, ENUM_TIMEFRAMES tf = 0)
    {
        int count = BarShift(iniTm) - BarShift(endTm);
        return iHigh(symbol, tf, iHighest(symbol, tf, Mode(_mode), count, BarShift(endTm)));
    }

    // buscar maximo pero recibiendo ini bars y end bars
    double Maximum(int iniBar, int endBar, string _mode, string symbol = NULL, ENUM_TIMEFRAMES tf = 0)
    {
        int pos = iHighest(symbol, tf, Mode(_mode), iniBar, endBar);
        return value(_mode, pos, symbol, tf);
    }

    int MaxPos(int startBar, int count, string _mode, string symbol = NULL, ENUM_TIMEFRAMES tf = 0)
    {
        int pos = iHighest(symbol, tf, Mode(_mode), count, startBar);
        return pos;
    }

    double Maximum(string iniTm, string endTm, string _mode, string symbol = NULL, ENUM_TIMEFRAMES tf = 0)
    {
        int iniBar = BarShift(ConvertTime(iniTm) - 24 * 3600);
        int endBar = BarShift(ConvertTime(endTm));
        return iHigh(symbol, tf, iHighest(symbol, tf, Mode(_mode), iniBar, endBar));
    }



    double Minimum(datetime iniTm, datetime endTm, string _mode, string symbol = NULL, ENUM_TIMEFRAMES tf = 0)
    {
        int count = BarShift(iniTm) - BarShift(endTm);
        return iLow(symbol, tf, iLowest(symbol, tf, Mode(_mode), count, BarShift(endTm)));
    }


    double Minimum(string iniTm, string endTm, string _mode, string symbol = NULL, ENUM_TIMEFRAMES tf = 0)
    {
        int iniBar = BarShift(ConvertTime(iniTm) - 24 * 3600);
        int endBar = BarShift(ConvertTime(endTm));
        // return iLow(symbol, tf, iLowest(symbol, tf, Mode(_mode), iniBar, endBar));

        int pos = iLowest(symbol, tf, Mode(_mode), iniBar, endBar);
        return value(_mode, pos, symbol, tf);
    }

    // Minimo pero entre Bars
    double Minimum(int startBar, int count, string _mode, string symbol = NULL, ENUM_TIMEFRAMES tf = 0)
    {
        int pos = iLowest(symbol, tf, Mode(_mode), count, startBar);
        return value(_mode, pos, symbol, tf);
    }

    int MinPos(int startBar, int count, string _mode, string symbol = NULL, ENUM_TIMEFRAMES tf = 0)
    {
        int pos = iLowest(symbol, tf, Mode(_mode), count, startBar);
        return pos;
    }

    int Mode(string _mode)
    {
        if(_mode == "open") return MODE_OPEN;
        if(_mode == "close") return MODE_CLOSE;
        if(_mode == "low") return MODE_LOW;
        if(_mode == "high") return MODE_HIGH;

        return -1;
    }

    double value(string _mode, int pos, string symbol = NULL, ENUM_TIMEFRAMES tf = 0)
    {
        if(_mode == "open")  return iOpen(symbol, tf, pos);
        if(_mode == "close") return iClose(symbol, tf, pos);
        if(_mode == "low")   return iLow(symbol, tf, pos);
        if(_mode == "high")  return iHigh(symbol, tf, pos);
        return 0;
    }

    int BarShift(int tm, string symbol = NULL, ENUM_TIMEFRAMES tf = 0)
    {
        return iBarShift(symbol, tf, tm, false);
    }

    // Convierte un time "string" en un time "datetime"
    datetime ConvertTime(string time)
    {
        return StringToTime(time);
    }
};
SearchExtremes search();

// ------------------------------------------------------------------
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, Hi, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_LINE, EMPTY, 1, LineUpClr);
    SetIndexBuffer(1, Lo, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, EMPTY, 1, LineDnClr);
    SetIndexBuffer(2, Cl, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_LINE, EMPTY, 1, LineClClr);
    
    if(!LinesOn)
    {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }
    if(!CloseOn)
    {
        SetIndexStyle(2, DRAW_NONE);
    }
    //---
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}
// ------------------------------------------------------------------

int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time [],
                const double& open [],
                const double& high [],
                const double& low [],
                const double& close [],
                const long& tick_volume [],
                const long& volume [],
                const int& spread [])
{
    int start, i;
    if(prev_calculated == 0) { start = 500; }
    else { start = rates_total - (prev_calculated - 1); }

    for(i = start; i >= 0; i--)
    {

        // Draw High and Low
        // ------------------------------------------------------------------
        if(isNewDay(i))
        {
            Lo[i] = EMPTY_VALUE;
            Hi[i] = EMPTY_VALUE;
        }

        if(time[i] >= startSession(i) && time[i] <= endDay(i))
        {
            double max = search.Maximum(iniDay(i), startSession(i)-1, "high");
            double min = search.Minimum(iniDay(i), startSession(i)-1, "low");

            int j = i;
            while(time[j] > iniDay(i))
            {
                Hi[j] = max;
                Lo[j] = min;
                j++;
            }
        }


        // Draw Last Close
        // ------------------------------------------------------------------
        if(time[i] > endLastSession(i) && time[i] <= startSession(i))
        {
            int j = i;
            while(time[j] >= endLastSession(i))
            {
                Cl[j] = iClose(NULL, 0, iBarShift(NULL, 0, endLastSession(i)));
                j++;
            }
        }


    }
    return (rates_total);
}

// ------------------------------------------------------------------

bool haveSignalUp(int i)
{
    // TODO: signal up
    return isNewDay(i);

    return true;
}

bool haveSignalDown(int i)
{
    // TODO: signal down
    return isNewDay(i);
    return true;
}

bool isNewDay(int i)
{
    MqlDateTime dtCurr, dtPrev;
    TimeToStruct(iTime(NULL, 0, i), dtCurr);
    TimeToStruct(iTime(NULL, 0, i + 1), dtPrev);

    if(dtCurr.day > dtPrev.day) { return true; }

    return false;
}

datetime iniDay(int i)
{
    MqlDateTime dt;
    TimeToStruct(iTime(NULL, 0, i), dt);

    dt.hour = 00;
    dt.min = 00;
    dt.sec = 00;

    return StructToTime(dt);
}

datetime endDay(int i)
{
    MqlDateTime dt;
    TimeToStruct(iTime(NULL, 0, i), dt);

    dt.hour = 23;
    dt.min = 59;
    dt.sec = 59;

    return StructToTime(dt);
}

datetime endSession(int i)
{
    MqlDateTime dt;
    TimeToStruct(iTime(NULL, 0, i), dt);

    dt.hour = 22;
    dt.min = 00;
    dt.sec = 00;

    return StructToTime(dt);
}

datetime endLastSession(int i)
{
    MqlDateTime dt;
    TimeToStruct(iTime(NULL, 0, i), dt);
    dt.day = dt.day - 1;
    dt.hour = 22;
    dt.min = 00;
    dt.sec = 00;

    return StructToTime(dt);
}
datetime startSession(int i)
{
    MqlDateTime dt;
    TimeToStruct(iTime(NULL, 0, i), dt);

    dt.hour = 13;
    dt.min = 00;
    dt.sec = 00;

    return StructToTime(dt);
}


void Notifications(int type)
{
    string text = "";
    if(type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

    text += " ";

    if(!notifications)
        return;
    if(desktop_notifications)
        Alert(text);
    if(push_notifications)
        SendNotification(text);
    if(email_notifications)
        SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch(lPeriod)
    {
        case PERIOD_M1:
            return ("M1");
        case PERIOD_M5:
            return ("M5");
        case PERIOD_M15:
            return ("M15");
        case PERIOD_M30:
            return ("M30");
        case PERIOD_H1:
            return ("H1");
        case PERIOD_H4:
            return ("H4");
        case PERIOD_D1:
            return ("D1");
        case PERIOD_W1:
            return ("W1");
        case PERIOD_MN1:
            return ("MN1");
    }
    return IntegerToString(lPeriod);
}
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+