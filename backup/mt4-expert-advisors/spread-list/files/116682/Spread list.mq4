// Id: 20043
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65492
// Lua version: http://fxcodebase.com/code/viewtopic.php?f=17&t=8525

//+------------------------------------------------------------------+
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property description "Spread List"
#property indicator_chart_window

extern string Comment1 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
extern string Pairs = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";
extern bool ShowSecondColumn = true;
extern bool SecondColumnSpread = true;
extern double Commissions = 0.0;
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

void split(string& arr[], string str, string sym) 
{
  ArrayResize(arr, 0);
  string item;
  int pos, size;
  
  int len = StringLen(str);
  for (int i=0; i < len;) {
    pos = StringFind(str, sym, i);
    if (pos == -1) pos = len;
    
    item = StringSubstr(str, i, pos-i);
    item = StringTrimLeft(item);
    item = StringTrimRight(item);
    
    size = ArraySize(arr);
    ArrayResize(arr, size+1);
    arr[size] = item;
    
    i = pos+1;
  }
}

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
    IndicatorName = GenerateIndicatorName("Spread List");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
    WindowName = IndicatorName;
    split(Sym_arr, Pairs, ",");
    Sym_count = ArraySize(Sym_arr);
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
        
        int mult = SymbolInfoInteger(Sym_arr[i], SYMBOL_DIGITS) % 2 == 1 ? 10 : 1;
        double pipSize = SymbolInfoDouble(Sym_arr[i], SYMBOL_POINT) * mult;
        double spread = SymbolInfoInteger(Sym_arr[i], SYMBOL_SPREAD) / mult + Commissions / pipSize;
        col_1[i] = DoubleToStr(spread, 2);
        col0.AddText(col_1[i]);

        if (ShowSecondColumn)
        {
            double tickvalue = MarketInfo(Sym_arr[i], MODE_TICKVALUE);
            if (Digits == 5 || Digits == 3)
            {
                tickvalue = tickvalue * 10;
            }
            if (SecondColumnSpread)
            {
                col_2[i] = DoubleToStr(tickvalue, 2);
            }
            else
            {
                col_2[i] = DoubleToStr(spread * tickvalue, 2);
            }
            col2.AddText(col_2[i]);
        }
    }
    col1.AddText("Spread");
    col2.AddText(SecondColumnSpread ? "Pip Cost" : "S. Value");
    int col_0_x = x;
    int col_1_x = col_0_x + col0.GetWidth() * 1.1;
    int col_2_x = col_1_x + col1.GetWidth() * 1.1;
    ObjectMakeLabel("col_1", col_1_x, y, "Spread", Labels_Color, 1, WindowNumber, _font, _fontSize);
    if (ShowSecondColumn)
    {
        ObjectMakeLabel("col_2", col_2_x, y, SecondColumnSpread ? "Pip Cost" : "S. Value", Labels_Color, 1, WindowNumber, _font, _fontSize);
    }
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