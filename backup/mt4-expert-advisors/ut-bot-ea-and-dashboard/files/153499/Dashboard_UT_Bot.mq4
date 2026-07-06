// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74390

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

// #property indicator_chart_window
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots 1

ENUM_TIMEFRAMES TF[8] = { PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1 };


#define CONTROL_CUSTOM_INDICATOR_FILE
#ifdef CONTROL_CUSTOM_INDICATOR_FILE

enum enum_candle
{
    curr = -1,  // Current candle
    prev = 0    // Previous closed candle
};
input string Tindi = "== Indicator Setup ==";  // ————————————
input double m = 2;                // Key value:
input double atrPeriods = 14;      // ATR periods:
input bool   h = false;            // Signals From Heinken Ashi Candles
input enum_candle s = curr;             // Show arrows on:
input int    p = 30;               // Arrow position in Points
input int    b = 5000;             // Lookback bars
input string Tindi2 = "== Draw Trade ==";  // ————————————
input bool   drawTradeON = true; // Draw Trade On?
input double userSL = 20; // Pips SL
input double userTP1 = 50; // Pips TP1
input double userTP2 = 75; // Pips TP2
input double userTP3 = 100; // Pips TP3

string file_custom_indicator = "UT_Bot_v2";

class UTBot
{
    string _symbol;

    public:
    UTBot(string sym) :_symbol(sym) { ; }
    ~UTBot(){;}

    double DnSignal(ENUM_TIMEFRAMES tf, int candle)
    {
        return iCustom(_symbol, tf, file_custom_indicator,
            m, atrPeriods, h, s, p, b, Tindi2, drawTradeON, userSL, userTP1, userTP2, userTP3,
            1, candle);
    }

    double UpSignal(ENUM_TIMEFRAMES tf, int candle)
    {
        return iCustom(_symbol, tf, file_custom_indicator,
            m, atrPeriods, h, s, p, b, Tindi2, drawTradeON, userSL, userTP1, userTP2, userTP3,
            0, candle);
    }
};

UTBot* utbots [];

#endif


// #define Ichimoku_
#ifdef Ichimoku_

// #include <FrameWork/Indicators/Ichimoku.mqh>
input string ICustom = "== Ichimoku Setup ==";  // == Ichimoku Setup ==
input int    uTenkan_sen = 9;                       // period of Tenkan-sen line
input int    uKijun_sen = 26;                      // period of Kijun-sen line
input int    uSenkou_span_b = 52;                      // period of Senkou Span B line

class Ichimoku
{
    string          _symbol;         // symbol
    ENUM_TIMEFRAMES _tf;             // timeframe
    int             _tenkan_sen;     // period of Tenkan-sen line
    int             _kijun_sen;      // period of Kijun-sen line
    int             _senkou_span_b;  // period of Senkou Span B line

    public:
    Ichimoku()
    {
        _symbol = _Symbol;
        _tf = Period();
    }
    Ichimoku(string Symbol, int TimeFrame)
    {
        _symbol = Symbol;
        _tf = TimeFrame;
    }
    ~Ichimoku() { ; }

    string symbol()
    {
        return _symbol;
    }

    void set(int inpTenkan_sen, int inpKijun_sen, int inpSenkou_span_b)
    {
        _tenkan_sen = inpTenkan_sen;
        _kijun_sen = inpKijun_sen;
        _senkou_span_b = inpSenkou_span_b;
    }

    double calculate(int shift, int buffer = 0)
    {
        return iIchimoku(_symbol, _tf, _tenkan_sen, _kijun_sen, _senkou_span_b, buffer, shift);
    }

    double calculate(ENUM_TIMEFRAMES tf, int shift, int buffer = 0)
    {
        return iIchimoku(_symbol, tf, _tenkan_sen, _kijun_sen, _senkou_span_b, buffer, shift);
    }

    // clang-format off
    double UpSignal(int shift) { return calculate(shift, 1); }
    double DnSignal(int shift) { return calculate(shift, 2); }
    double SenkouSpanA(int shift) { return calculate(shift, 3); }
    double SenkouSpanB(int shift) { return calculate(shift, 4); }
    double ChikouSpan(int shift) { return calculate(shift, 5); }

    double UpSignal(ENUM_TIMEFRAMES tf, int shift) { return calculate(tf, shift, 1); }
    double DnSignal(ENUM_TIMEFRAMES tf, int shift) { return calculate(tf, shift, 2); }
    double SenkouSpanA(ENUM_TIMEFRAMES tf, int shift) { return calculate(tf, shift, 3); }
    double SenkouSpanB(ENUM_TIMEFRAMES tf, int shift) { return calculate(tf, shift, 4); }
    double ChikouSpan(ENUM_TIMEFRAMES tf, int shift) { return calculate(tf, shift, 5); }



};

Ichimoku* utbots [];
Ichimoku* ichi;

#endif


input string uSymbols = "GBPUSD,EURUSD";  // Symbols (separate by comma ","):
input string       TZ = "== Notifications ==";      // Notifications
input bool         notifications = false;                      // Notifications On
input bool         desktop_notifications = false;                      // Desktop MT4 Notifications
input bool         email_notifications = false;                      // Email Notifications
input bool         push_notifications = false;                      // Push Mobile Notifications
// ------------------------------------------------------------------

#define GUI_
#ifdef GUI_

// #include "Gui.mqh"
#include <Canvas\Canvas.mqh>

#define SLIDER_MOVE 1
#define FOCUS_ON 2
#define MOVEALL_ON 3
#define PRIORITY_CONTROL 4

enum PriceAnchor {
    Top,
    Bottom,
    Center
};

class CObjectBase
{
    protected:
    CCanvas     canvas;
    int         _id;
    string      _name;
    int         _x;
    int         _x2;
    int         _y;
    int         _y2;
    int         _high;
    int         _width;
    bool        _focus;
    bool        _hide;
    bool        _show;
    uint        _colorBack;
    uint        _colorHover;
    string      _text;
    string      _font;
    uint        _textColor;
    bool        _wasPressed;
    bool        _movable;
    uint        _currentColor;
    double      _price;
    double      _priceY2;
    PriceAnchor _priceAnchor;
    int         _distanceToMouse;

    public:
    CObjectBase() { ; }
    ~CObjectBase()
    {
        canvas.Destroy();
    }

    // clang-format off
    virtual void OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam) { ; }
    virtual void OnTickEvent();
    void OnDeinitEvent() { canvas.Destroy(); }

    void   id(int inpid) { _id = inpid; }
    int    id(void) { return _id; }
    void   Name(string name) { _name = name; }
    string Name(void) { return _name; }

    void   X(int inpx) { _x = inpx; }
    int    X(void) { return _x; }
    void   Y(int inpy) { _y = inpy; }
    int    Y(void) { return _y; }
    int    X2(void) { return _x + _width; }
    int    Y2(void) { return _y + _high; }
    void   Y2(int inpy2) { _y2 = inpy2; High(_y - _y2); }

    void DistanceToMouse(int inpdistanceToMouse) { _distanceToMouse = inpdistanceToMouse; }
    void setDistanceToMouse(int mousePos) { if(_distanceToMouse == 0) _distanceToMouse = mousePos - Y(); }
    int  DistanceToMouse(void) { return _distanceToMouse; }

    void SetPosByPrice(double price)
    {
        int coorY = Coordinate(price);
        if(Anchor() == Top)    Y(coorY);
        if(Anchor() == Bottom) Y(coorY - High());
        if(Anchor() == Center) Y(coorY - High() / 2);

        ObjectSetInteger(0, _name, OBJPROP_YDISTANCE, Y());

        Refresh();
    }
    // le pasas un precio te retorna la coordernada y
    int Coordinate(double price)
    {
        Price(price);
        datetime tm = TimeCurrent();
        int coorY, coorX;
        ChartTimePriceToXY(0, 0, tm, _price, coorX, coorY);
        return coorY;
    }

    void   High(int high) { _high = high; }
    int    High(void) { return _high; }
    void   Width(int width) { _width = width; }
    int    Width(void) { return _width; }

    void   Focus(bool focus) { _focus = focus; }
    bool   Focus(int x, int y)
    {
        _focus = false;
        if(x > X() && x < X2() && y > Y() && y < Y2())
        {
            _focus = true;
            EventChartCustom(0, FOCUS_ON, 0, y, _name);
        }

        return _focus;
    }

    void   Hide(bool hide) { _hide = hide; }
    bool   Hide(void) { return _hide; }
    void   Show(bool show) { _show = show; }
    bool   Show(void) { return _show; }

    void   ColorBack(color colorBack, int alpha) { _colorBack = ColorToARGB(colorBack, alpha); }
    void   ColorHover(color colorHover, int alpha) { _colorHover = ColorToARGB(colorHover, alpha); }
    void   ChangeColor(void)
    {
        _currentColor = _focus == true ? _colorHover : _colorBack;
        Refresh();
    }

    void Refresh()
    {
        canvas.Erase(_currentColor);
        // canvas.TextOut(2, 0, _text, _textColor, 1);
        canvas.Update(true);
    }

    void   Text(string text) { _text = text; }
    string Text(void) { return _text; }
    void   Font(string font, int size = 9) { _font = font; canvas.FontSet(_font, size * -10); }
    string Font(void) { return _font; }
    void   TextColor(color textColor, int alpha) { _textColor = ColorToARGB(textColor, alpha); }
    uint   TextColor(void) { return _textColor; }

    void  Movable(bool movable) { _movable = movable; }
    bool  Movable(void) { return _movable; }
    void   WasPressed(bool  wasPressed) { _wasPressed = wasPressed; }
    bool   WasPressed(void) { return _wasPressed; }
    void   Move(int y, double limitPrice = 0)
    {
        if(!Movable()) return;

        if(WasPressed())
        {
            // limitar el movimiento
            if(limitPrice == 0)
            {
                limitPrice = Bid;
            }
            // int coorAsk= Coordinate(limitPrice);  
            // int coorBid= Coordinate(Bid);  

            // int coorAsk= Coordinate(Ask);  
            // int coorBid= Coordinate(Bid);  

            // if(Anchor() == Top) 
            // {
            // 	if(y <= coorAsk)
            // 	{ 
            // 		y=coorAsk; 
            // 	}
            // } else 
            // {
            // 	 if(y >= coorBid) 
            // 	 {
            // 		 y=coorBid; 
            // 	 }
            // }

            //--- 

            int coorLimit = Coordinate(limitPrice);

            if(Anchor() == Top)
            {
                if(y <= coorLimit - 5) { y = coorLimit - 5; }
            }
            else
            {
                if(y >= coorLimit - 15) { y = coorLimit - 15; }
            }

            Y(y);
            ObjectSetInteger(0, _name, OBJPROP_YDISTANCE, Y());
            EventChartCustom(0, SLIDER_MOVE, 0, y, _name);
        }
        Refresh();
    }
    void   MoveSlave(int mousePos)
    {
        setDistanceToMouse(mousePos);
        Print(_name, "/ _distanceToMouse: ", _distanceToMouse);

        Y(mousePos - _distanceToMouse);
        ObjectSetInteger(0, _name, OBJPROP_YDISTANCE, Y());
        Refresh();
    }
    void   MoveSpecial(int mousePos, int sparam)
    {
        // ej: el obj esta en 180 , el mouse en 100, dif=-80. 
        // Esta distancia la tiene que mantener, 
        // significa que la nueva posición vá a ser, mouseY+distToMove

        // int distToMove = Y() - mouseY; 
        // Print("_y = ",_y); 
        // Print("distToMove: ", distToMove);
        setDistanceToMouse(mousePos);

        Print("_distanceToMouse: ", _distanceToMouse);

        // Y(mousePos - _distanceToMouse);	
        // ObjectSetInteger(0, _name, OBJPROP_YDISTANCE, Y());		
        EventChartCustom(0, MOVEALL_ON, 0, mousePos, _name);

        // EventChartCustom(0,SLIDER_MOVE,0, y,_name);
        Refresh();
    }

    double PriceTop()
    {
        datetime tm;
        double   pr;
        int      sub;
        if(!ChartXYToTimePrice(0, X(), Y(), sub, tm, pr)) { return -1; }
        return NormalizeDouble(pr, _Digits);
    }
    double PriceBottom()
    {
        datetime tm;
        double   pr;
        int      sub;
        if(!ChartXYToTimePrice(0, X(), Y2(), sub, tm, pr)) { return -1; }
        return NormalizeDouble(pr, _Digits);
    }
    double PriceCenter()
    {
        datetime tm;
        double   pr;
        int      sub;
        int yCenter = (Y() + Y2()) / 2;
        if(!ChartXYToTimePrice(0, X(), yCenter, sub, tm, pr)) { return -1; }
        return NormalizeDouble(pr, _Digits);
    }
    void setPrice()
    {
        if(Anchor() == Top)    _price = PriceTop();
        if(Anchor() == Bottom) _price = PriceBottom();
        if(Anchor() == Center) _price = PriceCenter();
    }
    double Price(void) { setPrice(); return _price; }
    void Price(double price) { _price = price; }

    void   Anchor(PriceAnchor priceAnchor)
    {
        _priceAnchor = priceAnchor;
        // Print("_priceAnchor",_priceAnchor);
        if(_priceAnchor == Top) { ObjectSetInteger(0, _name, OBJPROP_ANCHOR, ANCHOR_UPPER); }
        if(_priceAnchor == Center) { ObjectSetInteger(0, _name, OBJPROP_ANCHOR, ANCHOR_CENTER); }
        if(_priceAnchor == Bottom) { ObjectSetInteger(0, _name, OBJPROP_ANCHOR, ANCHOR_LOWER); }

    }
    PriceAnchor Anchor()
    {
        return _priceAnchor;
    }

    // clang-format on
};

class CButtonFlat : public CObjectBase
{
    public:
    CButtonFlat() { DefaultProperties(); }
    ~CButtonFlat() { ; }

    void OnTickEvent()
    {
        Text("Pr: " + (string) Bid);
        Refresh();
    }
    void OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
    {
        int mousex = lparam;
        int mousey = dparam;

        // NOTE: CHARTEVENT_MOUSE_MOVE
        if(id == CHARTEVENT_MOUSE_MOVE)
        {
            Focus(mousex, mousey);
            ChangeColor();
            // SetPosByPrice(Ask);

            if(sparam == 0)
            {
                WasPressed(false);
            }
            if(sparam == 1 && Focus(mousex, mousey))
            {
                // EventChartCustom(0,PRIORITY_CONTROL,0, mousey, _name);
            }
            // Move(mousey);

            return;
        }

        if(id == CHARTEVENT_OBJECT_CLICK)
        {
            // SetPosByPriceY(1.25240);
            // Print(sparam);
            return;
        }
    }

    void DefaultProperties()
    {
        Name("BtFlat");
        X(0);
        Y(Coordinate(Bid));
        Anchor(Center);
        Width(150);
        High(16);
        ColorBack(C'20,20,20', 255);
        ColorHover(C'33,97,140', 255);
        canvas.FontSet("Calibri", -90);
        Text(_name);
        TextColor(clrWhite, 255);
        Movable(true);
    }

    bool Create()
    {
        _currentColor = _colorBack;

        if(!canvas.CreateBitmapLabel(0, 1, _name, _x, _y, _width, _high, COLOR_FORMAT_ARGB_NORMALIZE))
        {
            return false;
        }
        Refresh();

        return true;
    }

    void RefreshText()
    {
        canvas.Erase(_currentColor);
        canvas.TextOut(Width() / 2, 0, _text, _textColor, 1);
        canvas.Update(true);
    }
};

class Table : CObjectBase
{
    CButtonFlat _rows [][9];
    int         _nRows;
    int         _nColumns;
    int         _shift;

    public:
    Table() { ; }
    ~Table() { ; }
    void OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam) { ; }
    void OnTickEvent();
    void OnDeinitEvent();
    string cellText(int r, int c)
    {
        return _rows[r, c].Text();
    }
    void nRows(int inpnRows) { _nRows = inpnRows + 1; }
    void nColumns(int Columns) { _nColumns = Columns; }
    int  nRows(void) { return _nRows; }
    void ShiftText(int shiftTxt) { _shift = shiftTxt; }

    void Create()
    {
        ArrayResize(_rows, _nRows);
        int y = 30;
        int x = 5;

        for(int i = 0; i < _nRows; i++)
        {
            x = 0;
            _rows[i, 0].Name("row" + i);
            _rows[i, 0].Text("");
            _rows[i, 0].Width(75);
            _rows[i, 0].X(x);
            _rows[i, 0].Y(y);
            _rows[i, 0].Create();

            x += 76;
            for(int j = 1; j < 9; j++)
            {
                _rows[i, j].Name("celda_" + i + "_" + j);
                _rows[i, j].Text("");
                if(i > 0) _rows[i, j].Font("Wingdings 3", 8);
                // if(i>0)_rows[i, j].Font("Arial");
                _rows[i, j].Width(70);
                _rows[i, j].X(x);
                _rows[i, j].Y(y);
                _rows[i, j].Create();
                x += 71;
            }
            y += 17;
        }
    }

    void setHeaders(string& headers [])
    {
        for(int j = 0; j < ArraySize(headers); j++)
        {
            _rows[0, j].Text(headers[j]);
        }
    }

    void setRowNames(string& rowName [])
    {
        for(int j = 0; j < ArraySize(rowName); j++)
        {
            _rows[j + 1, 0].Text(rowName[j]);
        }
    }

    void Refresh()
    {
        for(int i = 0; i < _nRows; i++)
        {
            for(int j = 0; j < 9; j++)
            {
                _rows[i, j].RefreshText();
            }
        }
    }

    void setValues(int rowNumber, string& values [])
    {
        for(int j = 0; j < ArraySize(values); j++)
        {
            // UP format
            if(values[j] == 0)
            {
                _rows[rowNumber + 1, j + 1].Font("Wingdings 3", 8);
                _rows[rowNumber + 1, j + 1].Text("p");
                _rows[rowNumber + 1, j + 1].TextColor(LimeGreen, 255);
            }

            // Down Format
            if(values[j] == 1)
            {
                _rows[rowNumber + 1, j + 1].Font("Wingdings 3", 8);
                _rows[rowNumber + 1, j + 1].Text("q");
                _rows[rowNumber + 1, j + 1].TextColor(Tomato, 255);
            }

            // PullBack Format
            if(values[j] == 2)
            {
                _rows[rowNumber + 1, j + 1].Font("Wingdings");
                _rows[rowNumber + 1, j + 1].Text("n");
                _rows[rowNumber + 1, j + 1].TextColor(C'243,156,18', 255);
            }

            // No Signal Format
            if(values[j] == -1)
            {
                _rows[rowNumber + 1, j + 1].Text("");
            }
            _rows[rowNumber + 1, j + 1].RefreshText();
        }
    }


};

Table table();

#endif GUI_


// ------------------------------------------------------------------
class SymbolsList
{
    int _current;

    public:
    string _symbols [];

    SymbolsList(string Symbols) { getSymbols(Symbols); }
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
        if(_current == end())
        {
            // _current -= 1;
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
            Print(_symbols[i]);
        }
    }

    int qnt()
    {
        return ArraySize(_symbols);
    }
};
SymbolsList* symbols;

// NOTE: OnInit
int OnInit()
{

#ifdef CONTROL_CUSTOM_INDICATOR_FILE
    double temp = iCustom(NULL, 0, file_custom_indicator, 0, 0);
    if(GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
    {
        string txt = "THIS EA NEED AN INDICATOR\ninstall the file:\n" + file_custom_indicator + "\ninto the folder:\nMQL4/Indicators.";
        MessageBox(txt, "Important Information", MB_ICONINFORMATION);
        Alert(txt);
        return INIT_FAILED;
    }
#endif


    symbols = new SymbolsList(uSymbols);

    for(int i = symbols.ini(); i < symbols.qnt(); i = symbols.next())
    {
        AddIndicatorInstance(symbols.currentSymbol());
    }

    CreateTable();

    return (INIT_SUCCEEDED);
}

// NOTE: TABLE Create
void CreateTable()
{
    int sym = symbols.qnt();
    table.nRows(sym);
    table.Create();
    string headers[9] = { " ", "M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1" };
    table.setHeaders(headers);
    table.setRowNames(symbols._symbols);
    table.Refresh();
}

// NOTE: deinit
int deinit()
{
    delete symbols;
    deleteInedicatorInstance();

    //---
    return 0;
}

// NOTE: OnCalculate
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
    // clang-format off
    for(int i = 0;i < ArraySize(utbots); i++)
    {
        string values[8];
        for(int j = 0; j < ArraySize(TF); j++)
        {

            int pos = 0;
            int signal = -1;

            while(signal == -1 && !IsStopped())
            {
                double upSignal = utbots[i].UpSignal(TF[j], pos);
                double dnSignal = utbots[i].DnSignal(TF[j], pos);

                if(upSignal != EMPTY_VALUE) { signal = 0; }
                if(dnSignal != EMPTY_VALUE) { signal = 1; }
                pos++;

            } 
            
            values[j] = (string)signal;
        }

        table.setValues(i, values);
    }

    //--- return value of prev_calculated for next call
    return (rates_total);
}
//+------------------------------------------------------------------+

void AddIndicatorInstance(string sym)
{
    int t = ArraySize(utbots);
    if(ArrayResize(utbots, t + 1))
    {
        utbots[t] = new UTBot(sym);
    }
}

void deleteInedicatorInstance()
{
    for(int i = 0; i < ArraySize(utbots); i++)
    {
        delete utbots[i];
    }
}



// NOTE: Notifications
// ------------------------------------------------------------------

void NotifyControl()
{
    for(int r = 1; r < table.nRows(); r++)
    {
        string value = "";
        for(int c = 1; c < 9; c++)
        {
            if(value == "")
            {
                // value = _rows[r, c].Text();
                value = table.cellText(r, c);
                continue;
            }
            // if (c < 8) if (_rows[r, c].Text() == value) continue;
            if(c < 8)
                if(table.cellText(r, c) == value) continue;
            if(c == 8)
            {
                // string sym = _rows[r, c].Text();
                string sym = table.cellText(r, 0);
                if(value == "p") Notifications(0, sym);
                if(value == "q") Notifications(1, sym);
                if(value == "n") Notifications(2, sym);
            }
        }
    }
}

void Notifications(int type, string sym)
{
    if(!notifications) return;

    string text = "";
    if(type == 0) text += sym + "All the TimeFrames in: BUY ";
    if(type == 1) text += sym + "All the TimeFrames in: SELL ";
    if(type == 2) text += sym + "All the TimeFrames in: PullBack ";

    if(desktop_notifications) Alert(text);
    if(push_notifications)    SendNotification(text);
    if(email_notifications)   SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch(lPeriod)
    {
        case PERIOD_M1: return ("M1");
        case PERIOD_M5: return ("M5");
        case PERIOD_M15: return ("M15");
        case PERIOD_M30: return ("M30");
        case PERIOD_H1: return ("H1");
        case PERIOD_H4: return ("H4");
        case PERIOD_D1: return ("D1");
        case PERIOD_W1: return ("W1");
        case PERIOD_MN1: return ("MN1");
    }
    return IntegerToString(lPeriod);
}



//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+