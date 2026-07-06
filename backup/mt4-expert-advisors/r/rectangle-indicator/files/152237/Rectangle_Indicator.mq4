//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74075

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
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

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

//--- indicator buffers
double ArrowUp [];
double ArrowDn [];

// ------------------------------------------------------------------
input int  candles_back = 20;    // Candles Back:
input color user_color = C'10,25,250';// Color:

int endReason = 0;

// ------------------------------------------------------------------

#include <Canvas\Canvas.mqh>
class CFillRectangle
{
    protected:
    CCanvas canvas;
    int     _id;
    string  _name;
    int     _x;
    int     _x2;
    int     _y;
    int     _y2;
    int     _high;
    int     _width;
    uint    _currentColor;
    uint    _colorBack;
    uint    _colorHover;
    string  _text;
    string  _font;
    uint    _textColor;
    double  _priceTop;
    double  _priceBottom;
    int     _barX;
    int     _barX2;
    bool _projection;
    
    public:
    CFillRectangle() { DefaultProperties(); }
    ~CFillRectangle() { canvas.Destroy(); }
    // clang-format off

  // virtual void OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam) { ; }
    void OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
    {
        // int mousex = lparam;
        // int mousey = dparam;
        // NOTE: CHARTEVENT
        if(id == CHARTEVENT_CHART_CHANGE)
        {
            Resize();
            Refresh();
            return;
        }
    }

    void erase()
    {
        // canvas.Erase(clrNONE);
        canvas.Destroy();
        canvas.Update(true);
    }

    void   id(int inpid) { _id = inpid; }
    int    id(void) { return _id; }
    void   Name(string name) { _name = name; }
    string Name(void) { return _name; }

    void   X(int inpx) { _x = inpx; }
    int    X(void) { return _x; }
    void   Y(int inpy) { _y = inpy; }
    int    Y(void) { return _y; }
    int    X2(void) { return _x + _width; }
    void   X2(int x2) { _x2 = x2; }
    int    Y2(void) { return _y + _high; }
    void   Y2(int inpy2) { _y2 = inpy2; High(_y - _y2); }

    void   High(int high) { _high = high; }
    int    High(void) { return _high; }
    void   Width(int width) { _width = width; }
    int    Width(void) { return _width; }

    void   ColorBack(color colorBack, uchar alpha) { _colorBack = ColorToARGB(colorBack, alpha); }

    string Text(void) { return _text; }
    void   Text(string text) { _text = text; }
    void   Font(string font) { _font = font; }
    string Font(void) { return _font; }
    uint   TextColor(void) { return _textColor; }
    void   TextColor(color textColor, uchar alpha) { _textColor = ColorToARGB(textColor, alpha); }

    void    priceTop(double inppriceTop) { _priceTop = inppriceTop; }
    double  priceTop(void) { return _priceTop; }
    void    priceBottom(double inppriceBottom) { _priceBottom = inppriceBottom; }
    double  priceBottom(void) { return _priceBottom; }
    void    barX(int inpbarX) { _barX = inpbarX; }
    int     barX(void) { return _barX; }
    void    barX2(int inpbarX2) { _barX2 = inpbarX2; }
    int     barX2(void) { return _barX2; }

    // clang-format on
    void DefaultProperties()
    {
        Name("Rectangle");
        X(100);
        Y(Coordinate(Bid));
        Width(150);
        High(16);
        // ColorBack(C'250,70,70', 100);
        Text(_name);
        TextColor(clrWhite, 255);
        canvas.FontSet("Calibri", -90);
        _projection = true;
    }

    void Refresh()
    {
        canvas.Erase(_currentColor);
        canvas.TextOut(_width - 2, 0, _text, _textColor, 2);
        canvas.Update(true);
    }

    bool Create()
    {
        _currentColor = _colorBack;
        if(_projection) _width = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0) - _x;
        canvas.CreateBitmapLabel(_name, _x, _y, _width, _high, COLOR_FORMAT_ARGB_NORMALIZE);
        Refresh();
        return true;
    }

    bool Create(string name, double price_top, double price_bottom, int candle_x, int candle_x2)
    {
        Name(name);
        Text(_name);

        priceTop(price_top);
        priceBottom(price_bottom);
        barX(candle_x);
        barX2(candle_x2);

        Y(Coordinate(price_top));
        Y2(Coordinate(price_bottom));
        X(Coordinate(candle_x));
        X2(Coordinate(candle_x2));
        _width = _x2 - _x;
        _high = _y2 - _y;

        _currentColor = _colorBack;
        if(_projection) _width = ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0) - _x;
        canvas.CreateBitmapLabel(_name, _x, _y, _width, _high, COLOR_FORMAT_ARGB_NORMALIZE);
        Refresh();
        return true;
    }

    // le pasas un precio y te devulve la coordenada
    int Coordinate(double price)
    {
        datetime tm = TimeCurrent();
        int      coorY, coorX;
        ChartTimePriceToXY(0, 0, tm, price, coorX, coorY);
        return coorY;
    }

    // le pasas una vela (shift) y te devulve la coordenada
    int Coordinate(int barShift)
    {
        datetime tm = iTime(NULL, 0, barShift);
        int      coorY, coorX;
        ChartTimePriceToXY(0, 0, tm, 1, coorX, coorY);
        return coorX;
    }

    // reajusta las coordenadas cuando se cambian precios o velas
    void Resize()
    {
        Y(Coordinate(_priceTop));
        Y2(Coordinate(_priceBottom));
        X(Coordinate(_barX));
        X2(Coordinate(_barX2));
        _width = _x2 - _x;
        _high = _y2 - _y;

        ObjectSetInteger(0, _name, OBJPROP_YDISTANCE, Y());
        ObjectSetInteger(0, _name, OBJPROP_XDISTANCE, X());
        ObjectSetInteger(0, _name, OBJPROP_YSIZE, _high);
        ObjectSetInteger(0, _name, OBJPROP_XSIZE, _width);

        canvas.Resize(_width, _high);
    }
};
CFillRectangle* ZONE;

class SearchExtremes
{
    int iniTime;
    int endTime;

    public:
    SearchExtremes() { ; }
    ~SearchExtremes() { ; }

    double Maximum(datetime iniTm, datetime endTm, string _mode, string symbol = NULL, ENUM_TIMEFRAMES tf = 0)
    {
        return iHigh(symbol, tf, iHighest(symbol, tf, Mode(_mode), BarShift(iniTm), BarShift(endTm)));
    }

    // buscar maximo pero recibiendo ini bars y end bars
    double Maximum(int iniBar, int endBar, string _mode, string symbol = NULL, ENUM_TIMEFRAMES tf = 0)
    {
        int pos = iHighest(symbol, tf, Mode(_mode), endBar, iniBar);
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
        if (_mode == "open") return MODE_OPEN;
        if (_mode == "close") return MODE_CLOSE;
        if (_mode == "low") return MODE_LOW;
        if (_mode == "high") return MODE_HIGH;

        return -1;
    }

    double value(string _mode, int pos, string symbol = NULL, ENUM_TIMEFRAMES tf = 0)
    {
        if (_mode == "open")  return iOpen(symbol, tf, pos);
        if (_mode == "close") return iClose(symbol, tf, pos);
        if (_mode == "low")   return iLow(symbol, tf, pos);
        if (_mode == "high")  return iHigh(symbol, tf, pos);
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
    ZONE = new CFillRectangle();
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
    endReason = reason;
    delete ZONE;
}
// ------------------------------------------------------------------
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
    double max = search.Maximum(0, candles_back, "high");
    double min = search.Minimum(0, candles_back, "low");
    int x1     = candles_back;
    int x2     = 0;
    
    ZONE.Create("ZONE ", max, min, x1, x2);
    ZONE.ColorBack(user_color, 80);

    //--- return value of prev_calculated for next call
    return(rates_total);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |   
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                                                    15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |  
//|Ethereum                                           0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D   |  
//|USDT addres  ERC-20 (Ethereum) address)            0x258C74Caac21c9535A0969F169FE0271d3cE56A0   | 
//+------------------------------------------------------------------------------------------------+