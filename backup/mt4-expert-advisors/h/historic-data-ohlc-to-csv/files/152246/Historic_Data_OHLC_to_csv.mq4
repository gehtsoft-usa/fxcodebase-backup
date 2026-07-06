// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73940

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
#property link "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 1
//--- indicator buffers
int input uCandlesBack = 100;  // Candles Back to Copy:

// ------------------------------------------------------------------
class Log
{
    int    _file;
    string _fileName;
    string _eaName;
    string _symbol;
    int    _candles;
    string _data [][9];

    public:
    Log(string eaName, string symbol, int candles)
    {
        _eaName = eaName;
        _symbol = symbol;
        _candles = candles;
        ArrayResize(_data, candles);
        setFileName();
    }
    ~Log() { ; }

    void setFileName()
    {
        string folder = StringConcatenate("OHLC_", _eaName);
        _fileName = StringConcatenate(folder, "\\" + folder + ".csv");
        Print(__FUNCTION__, " ", "_fileName", " ", _fileName);
    }

    void add(int index, string date, int dayWeek, int dayYear, string time, double open, double high, double low, double close, int spread)
    {
        // Symbol, Date,DayOfWeek,DayOfYear,Time, Open, High, Low, Close, spread

        _data[index][0] = date;
        _data[index][1] = dayWeek;
        _data[index][2] = dayYear;
        _data[index][3] = time;
        _data[index][4] = open;
        _data[index][5] = high;
        _data[index][6] = low;
        _data[index][7] = close;
        _data[index][8] = spread;
    }

    void PrintLog()
    {
        FileDelete(_fileName);
        _file = FileOpen(_fileName, FILE_WRITE | FILE_READ | FILE_CSV, ",");
        FileWrite(_file, "Symbol", "Date", "DayWeek", "DayYear", "Time", "Open", "High", "Low", "Close", "Spread");  // Headers

        // for(int i = 0; i < _candles; i++)
        for(int i = _candles-1; i >= 0; i--)
        {
            FileWrite(_file, _symbol,
                      _data[i][0],
                      _data[i][1],
                      _data[i][2],
                      _data[i][3],
                      _data[i][4],
                      _data[i][5],
                      _data[i][6],
                      _data[i][7],
                      _data[i][8]);
        }
        FileClose(_file);
    }
};
Log* log;


//+------------------------------------------------------------------+
int OnInit()
{
    string name = _Symbol + "_" + GetTimeFrame(Period());
    log = new Log(name, _Symbol, uCandlesBack);

    return (INIT_SUCCEEDED);
}


//+------------------------------------------------------------------+
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
    // NOTE: OnTick

    for(int i = 0; i < uCandlesBack; i++)
    {
        datetime dt = iTime(NULL, 0, i);
        string   dts = TimeToString(dt, TIME_DATE);
        string   tm = TimeToString(dt, TIME_MINUTES);
        int      dayW = TimeDayOfWeek(dt);
        int      dayY = TimeDayOfYear(dt);

        log.add(i, dts, dayW, dayY, tm, open[i], high[i], low[i], close[i], spread[i]);
    }

    log.PrintLog();

    //--- return value of prev_calculated for next call
    return (rates_total);
}

//+------------------------------------------------------------------+
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
//|                                                                    We appreciate your support. |
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