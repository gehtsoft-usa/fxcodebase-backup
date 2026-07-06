//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73870

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
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

//--- plot Linea1
#property indicator_label1  "Linea1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- indicator buffers
double   Buffer1 [];

string tx;


struct PatternCode
{
    int candle;
    string direction;
    string symbol;
    string tf;
};
PatternCode patCodes [];


// ------------------------------------------------------------------

input string ICustom = "== Ichimoku Setup ==";  // == Ichimoku Setup ==
input int    uTenkan_sen = 9;                       // period of Tenkan-sen line
input int    uKijun_sen = 26;                      // period of Kijun-sen line
input int    uSenkou_span_b = 52;                      // period of Senkou Span B line
//--- 
input string iTimeFrames = "== TimeFrames Setup ==";  // == TimeFrames Setup ==
input bool M1on = false;  // M1 
input bool M5on = false;  // M5
input bool M15on = false; // M15
input bool M30on = false; // M30
input bool H1on = false;  // H1
input bool H4on = false;  // H4
input bool D1on = false;  // D1
input bool W1on = false;  // W1
input bool MNon = false;  // MN


// ------------------------------------------------------------------
class Ichimoku
{
    string          _symbol;         // symbol
    ENUM_TIMEFRAMES _tf;             // timeframe
    int             _tenkan_sen;     // period of Tenkan-sen line
    int             _kijun_sen;      // period of Kijun-sen line
    int             _senkou_span_b;  // period of Senkou Span B line
    int             _handle;

    public:
    Ichimoku()
    {
        _symbol = _Symbol;
        _tf = Period();
    }
    Ichimoku(string Symbol, ENUM_TIMEFRAMES TimeFrame)
    {
        _symbol = Symbol;
        _tf = TimeFrame;
    }
    ~Ichimoku() { ; }

    void setHandle()
    {
        _handle = iIchimoku(_symbol, _tf, _tenkan_sen, _kijun_sen, _senkou_span_b);
    }
    void set(int inpTenkan_sen, int inpKijun_sen, int inpSenkou_span_b)
    {
        _tenkan_sen = inpTenkan_sen;
        _kijun_sen = inpKijun_sen;
        _senkou_span_b = inpSenkou_span_b;
        setHandle();
    }

    // clang-format off
    double calculate(int shift, int buffer = 0)
    {
        double value[1];
        int copy = CopyBuffer(_handle, buffer, shift, 1, value);
        if(copy > 0) { return value[0]; }
        return -1;
    }

    double Tenkansen(int shift) { return calculate(shift, 0); }
    double Kijunsen(int shift) { return calculate(shift, 1); }
    double SenkouSpanA(int shift) { return calculate(shift, 2); }
    double SenkouSpanB(int shift) { return calculate(shift, 3); }
    double ChikouSpan(int shift) { return calculate(shift, 4); }
};

// ------------------------------------------------------------------
#define symbolList_
#ifdef symbolList_
class SymbolsList
{
    string _symbols [];
    int    _current;

    public:
    SymbolsList() { ; }
    SymbolsList(string uSymbols) { getSymbols(uSymbols); }
    ~SymbolsList() { ; }

    void getSymbols(string uSyms)
    {
        string Simbolos [];
        string sep = ",";
        ushort u_sep;
        u_sep = StringGetCharacter(sep, 0);
        int k = StringSplit(uSyms, u_sep, Simbolos);
        ArrayResize(_symbols, ArrayRange(Simbolos, 0), 0);

        for(int i = 0; i < ArrayRange(Simbolos, 0); i++)
        {
            _symbols[i] = Simbolos[i];
        }
    }

    void getSymbolsFromMarketWatch()
    {
        int    mwSize = SymbolsTotal(true);
        string mvSimbols;

        for(int i = 0; i < mwSize; i++)
        {
            mvSimbols += SymbolName(i, true);
            if(i < mwSize - 1)mvSimbols += ",";
        }

        getSymbols(mvSimbols);
        printSymbols();
    }

    int ini()
    {
        _current = 0;
        return _current;
    }

    int next()
    {
        _current += 1;
        if(_current >= end())
        {
            _current = end();
        }

        return _current;
    }

    int end()
    {
        return ArraySize(_symbols);
    }

    string currentSymbol()
    {
        return _symbols[_current];
    }

    int current()
    {
        return _current;
    }

    void printSymbols()
    {
        for(int i = ini(); i < end(); i++)
        {
            Print(__FUNCTION__, " _symbols ", i, " ", _symbols[i]);
        }
    }

    int qnt()
    {
        return ArraySize(_symbols);
    }

};
#endif
SymbolsList* symbols = new SymbolsList();

// ------------------------------------------------------------------
#define FindPattern_
#ifdef FindPattern_

class FinderPattern
{
    string _symbol;  // symbol
    string signals [];
    SymbolsList* symbols;
    Ichimoku* _ichi;

    public:
    FinderPattern(SymbolsList& List)
    {
        symbols = &List;
    }
    ~FinderPattern()
    {
        delete _ichi;
    }

    string Signal(string sym)
    {
        for(int s = symbols.ini(); s < symbols.end(); s = symbols.next())
        {
            if(symbols.currentSymbol() == sym)
            {
                return signals[s];
            }
        }
        return "";
    }

    string Signal(int s)
    {
        return signals[s];
    }

    void FindPatternInAllSymbols(ENUM_TIMEFRAMES tf, int candles = 0)
    {
        if(candles > 99) candles = 99;
        ArrayResize(signals, symbols.qnt());


        for(int s = symbols.ini(); s < symbols.end(); s = symbols.next())
        {
            _symbol = symbols.currentSymbol();
            _ichi = new Ichimoku(_symbol, tf);
            _ichi.set(uTenkan_sen, uKijun_sen, uSenkou_span_b);

            signals[s] = FindPattern(tf, candles);
        }

        delete _ichi;
    }

    string FindPattern(ENUM_TIMEFRAMES tf, int candles = 0)
    {
        for(int i = 0; i < candles; i++)
        {
            if(havePatternUp(i, tf))
            {
                string candle = i < 10 ? "0" + (string) i : (string) i;
                // Print(__FUNCTION__, " ", candle + up + _symbol);
                return candle + "up" + _symbol;
            }

            if(havePatternDn(i, tf))
            {
                string candle = i < 10 ? "0" + (string) i : (string) i;
                // Print(__FUNCTION__, " ", candle + up + _symbol);
                return candle + "dn" + _symbol;
            }
        }

        return "00--";
    }


    bool havePatternUp(int i, ENUM_TIMEFRAMES tf)
    {
        // TODO: escribir el patrón alcista usar _symbol ya que tiene seteado el simbolo actual
        double cl = iClose(_symbol, tf, i);
        double op = iOpen(_symbol, tf, i);
        double ichi = _ichi.SenkouSpanB(i);
        // Print(_symbol, " cl: ", cl, " ichi: ", ichi, " op: ", op);

        return cl > ichi && op <= ichi;
    }

    bool havePatternDn(int i, ENUM_TIMEFRAMES tf)
    {
        // TODO: escribir el patrón bajista usar _symbol ya que tiene seteado el simbolo actual
        double cl = iClose(_symbol, tf, i);
        double op = iOpen(_symbol, tf, i);
        double ichi = _ichi.SenkouSpanB(i);

        // Print(_symbol, " cl: ", cl, " ichi: ", ichi, " op: ", op);

        return cl < ichi && op >= ichi;
    }

};

#endif
FinderPattern finder(symbols);

// ------------------------------------------------------------------
void OnDeinit(const int Reason)
{
    delete symbols;
    Comment("");
}

// ------------------------------------------------------------------
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, Buffer1, INDICATOR_DATA);

    symbols.getSymbolsFromMarketWatch();

    tx = "-------------------------------------"
        + "\n" + "ICHIMOKU SCANNER" + "\n"
        + "-------------------------------------" + "\n";

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
const int prev_calculated,
const datetime& time [],
const double& open [],
const double& high [],
const double& low [],
const double& close [],
const long& tick_volume [],
const long& volume [],
const int& spread [])
{
    //---
    if(M1on)ProcessSignals(PERIOD_M1);
    if(M5on)ProcessSignals(PERIOD_M5);
    if(M15on)ProcessSignals(PERIOD_M15);
    if(M30on)ProcessSignals(PERIOD_M30);
    if(H1on)ProcessSignals(PERIOD_H1);
    if(H4on)ProcessSignals(PERIOD_H4);
    if(D1on)ProcessSignals(PERIOD_D1);
    if(W1on)ProcessSignals(PERIOD_W1);
    if(MNon)ProcessSignals(PERIOD_MN1);

    ShowSignals();

    //--- return value of prev_calculated for next call
    return(rates_total);
}
//+------------------------------------------------------------------+

string GetTimeFrame(int lPeriod)
{
    switch(lPeriod)
    {
        case PERIOD_M1: return  ("M1");
        case PERIOD_M5: return  ("M5");
        case PERIOD_M15: return ("M15");
        case PERIOD_M30: return ("M30");
        case PERIOD_H1: return  ("H1");
        case PERIOD_H4: return  ("H4");
        case PERIOD_D1: return  ("D1");
        case PERIOD_W1: return  ("W1");
        case PERIOD_MN1: return ("MN1");
    }
    return IntegerToString(lPeriod);
}

void ProcessSignals(ENUM_TIMEFRAMES TF)
{
    ArrayResize(patCodes, symbols.qnt());
    finder.FindPatternInAllSymbols(TF, 1);

    for(int s = symbols.ini(); s < symbols.end(); s = symbols.next())
    {

        string dir = StringSubstr(finder.Signal(s), 2, 2);

        patCodes[s].candle = StringToInteger(StringSubstr(finder.Signal(s), 0, 2));
        patCodes[s].direction = dir == "up" ? "BUY" : dir == "dn" ? "SELL" : "--";
        patCodes[s].symbol = StringSubstr(finder.Signal(s), 4, StringLen(finder.Signal(s)));
        patCodes[s].tf = GetTimeFrame(TF);
    }
    AddSignals();
}

void AddSignals()
{
    for(int s = symbols.ini(); s < symbols.end(); s = symbols.next())
    {
        if(patCodes[s].direction != "--")
        {
            string toAdd = patCodes[s].symbol + " " + patCodes[s].tf + " " + patCodes[s].direction;

            if(StringFind(tx, toAdd) == -1)
            {
                Print(toAdd);
                tx += toAdd+ "\n";
            }
        }
    }
}

void ShowSignals()
{
    Comment(tx);
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