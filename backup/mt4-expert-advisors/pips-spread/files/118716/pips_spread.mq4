// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                   Paypal: https://goo.gl/9Rj74e  |
//|                    Patreon : https://www.patreon.com/mariojemic  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property description "Pips + spread"
#property indicator_chart_window

extern double RiskPercentage = 1.0;
extern double Stop = 0.3;
extern color Labels_Color = clrWhite;

string   WindowName;
int      WindowNumber;
string Sym_arr[]; // Pairs symbols
string col_0[];
string col_1[];
string col_2[];
int    Sym_count; // Number of symbols

string _font = "Arial";
int _fontSize = 12;

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}


int init()
{
    WindowName = "Pips + spread";
    IndicatorName = GenerateIndicatorName(WindowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   WindowName = IndicatorName;
    ArrayResize(Sym_arr, 1);
    Sym_arr[0] = _Symbol;

    Sym_count = 1;
    ArrayResize(col_0, Sym_count);
    ArrayResize(col_1, Sym_count);
    ArrayResize(col_2, Sym_count);

    return(0);
}

int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    return(0);
}

class TextMaxSizeCalculator
{
    int _width;
    int _height;
public:
    TextMaxSizeCalculator()
    {
        _width = 0;
        _height = 0;
    }

    void AddText(const string text)
    {
        int width;
        int height;
        TextGetSize(text, width, height);
        if (_width < width)
        {
            _width = width;
        }
        if (_height < height)
        {
            _height = height;
        }
    }

    int GetWidth()
    {
        return _width;
    }
    int GetHeight()
    {
        return _height;
    }
};

double CalcValue(const string symbol)
{
    int mult = SymbolInfoInteger(symbol, SYMBOL_DIGITS) % 2 == 1 ? 10 : 1;
    double spread = SymbolInfoInteger(symbol, SYMBOL_SPREAD) / mult;
    double pipSize = SymbolInfoDouble(symbol, SYMBOL_POINT) * mult;
    double close = iClose(symbol, _Period, 0);
    double open = iOpen(symbol, _Period, 0);
    double high = iHigh(symbol, _Period, 0);
    double low = iLow(symbol, _Period, 0);
    if (close < open)
    {
        return (high - close) / pipSize + spread;
    }
    return (close - low) / pipSize + spread;
}

int start()
{
    WindowNumber = 0;

    int y = 50;
    int x = 50;
    TextMaxSizeCalculator col0;
    TextMaxSizeCalculator col1;
    TextMaxSizeCalculator col2;
    for (int i = 0; i < Sym_count; i++)
    {
        int current_y = y + (i + 1) * 20;
        col_0[i] = Sym_arr[i];
        col0.AddText(col_0[i]);
        
        double pipsSpread = CalcValue(Sym_arr[i]);
        col_1[i] = DoubleToStr(pipsSpread, 2);
        col1.AddText(col_1[i]);

        double tickvalue = MarketInfo(Sym_arr[i], MODE_TICKVALUE);
        if (Digits == 5 || Digits == 3)
        {
            tickvalue = tickvalue * 10;
        }
        double riskMoney = AccountEquity() * RiskPercentage / 100;
        double riskPerLot = (pipsSpread + Stop) * tickvalue;
        double minlot = MarketInfo(Symbol(), MODE_MINLOT);
        double lots = riskMoney / riskPerLot;
        double lots_rounded = ((int)(lots / minlot)) * minlot;
        col_2[i] = DoubleToStr(lots, 2);
        col2.AddText(col_2[i]);
    }
    col0.AddText("Symbol");
    col1.AddText("Pips+Spread");
    col2.AddText("Lot");

    int col_0_x = x;
    int col_1_x = col_0_x + col0.GetWidth() * 1.1;
    int col_2_x = col_1_x + col1.GetWidth() * 1.1;
    ObjectMakeLabel("col_0", col_0_x, y, "Symbol", Labels_Color, 1, WindowNumber, _font, _fontSize);
    ObjectMakeLabel("col_1", col_1_x, y, "Pips+Spread", Labels_Color, 1, WindowNumber, _font, _fontSize);
    ObjectMakeLabel("col_2", col_2_x, y, "Lot", Labels_Color, 1, WindowNumber, _font, _fontSize);
    int h = col0.GetHeight() * 1.1;
    for (i = 0; i < Sym_count; i++)
    {
        ObjectMakeLabel("col_0_" + i, col_0_x, y + (i + 1) * h, col_0[i], Labels_Color, 1, WindowNumber, _font, _fontSize);
        ObjectMakeLabel("col_1_" + i, col_1_x, y + (i + 1) * h, col_1[i], Labels_Color, 1, WindowNumber, _font, _fontSize);
        ObjectMakeLabel("col_2_" + i, col_2_x, y + (i + 1) * h, col_2[i], Labels_Color, 1, WindowNumber, _font, _fontSize);
    }
    return(0);
}

void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 ){   
    ObjectDelete(IndicatorObjPrefix + nm);
    ObjectCreate(IndicatorObjPrefix +  nm, OBJ_LABEL, Window, 0, 0 );
    ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_CORNER, LabelCorner );
    ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_XDISTANCE, xoff );
    ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_YDISTANCE, yoff );
    ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_BACK, false );
    ObjectSetText(IndicatorObjPrefix +  nm, LabelTexto, FSize, Font, LabelColor );
    return;
}