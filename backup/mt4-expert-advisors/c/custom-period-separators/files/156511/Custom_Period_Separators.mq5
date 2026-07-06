// Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=156218#p156218

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

#property version "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
//--- plot Linea1
#property indicator_label1 "Linea1"
#property indicator_type1  DRAW_NONE
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
//--- indicator buffers
double Linea1Buffer[];

input int             Start_Time = 17;        // Start Time _nextTime:
input int             Interval   = 24;        // Interval hs:
input int             uw         = 1;         // Line Width :
input ENUM_LINE_STYLE style      = STYLE_DOT; // Line Style:
input color           uclr       = DimGray;   // Line Color :
input int             barsBack   = 1000;      // Max History:
input bool            ubk        = true;      // Draw In Background :

#define _drawLines
#ifdef _drawLines
class DrawVLines
{
    long              _chart_ID;
    string            _name;
    string            _prefix;
    int               _sub_window;
    int               _x;
    int               _y;
    ENUM_BASE_CORNER  _corner;
    string            _text;
    string            _font;
    int               _font_size;
    color             _clr;
    double            _angle;
    ENUM_ANCHOR_POINT _anchor;
    bool              _back;
    bool              _selection;
    bool              _hidden;
    long              _z_order;
    datetime          _tm;
    int               _width;
    ENUM_LINE_STYLE   _style;

  public:
    DrawVLines() { DefaultValues(); }
    ~DrawVLines() { ; }

    void DefaultValues()
    {
        _prefix = "vline-"; // Prefijo para borrar muchos
        // _name       = _prefix;            // nombre de la etiqueta
        _chart_ID   = 0;             // ID del gráfico
        _sub_window = 0;             // número de subventana
        _x          = 0;             // coordenada por el eje X
        _y          = 0;             // coordenada por el eje Y
        _text       = _name;         // texto
        _font       = "Arial";       // fuente
        _font_size  = 8;             // tamaño de la fuente
        _clr        = clrBlack;      // color
        _angle      = 0;             // inclinación del texto
        _anchor     = ANCHOR_CENTER; // modo de anclaje
        _back       = false;         // al fondo
        _selection  = false;         // seleccionar para mover
        _hidden     = true;          // ocultar en la lista de objetos
        _z_order    = 0;             // prioridad para el clic del ratón;
        _tm == EMPTY_VALUE ? TimeCurrent() : _tm;
        _width = 1;
        _style = STYLE_DOT;
    }

    void SetTime(datetime dt) { _tm = dt; }
    void Width(int w) { _width = w; }
    void Style(ENUM_LINE_STYLE st) { _style = st; }
    void Color(color clr)
    {
        _clr = clr;
        ObjectSetInteger(_chart_ID, _name, OBJPROP_COLOR, _clr);
    }
    void DrawBack(bool bk) { _back = bk; }

    bool Create(string name)
    {
        _name = _prefix + name;

        //--- anulamos el valor del error
        ResetLastError();

        if (!ObjectCreate(_chart_ID, _name, OBJ_VLINE, _sub_window, _tm, 0)) {
            Print(__FUNCTION__, ": ¡Fallo al crear la linea! Código del error = ", GetLastError());
            return (false);
        }

        ObjectSetInteger(_chart_ID, _name, OBJPROP_COLOR, _clr);
        ObjectSetInteger(_chart_ID, _name, OBJPROP_BACK, _back);
        ObjectSetInteger(_chart_ID, _name, OBJPROP_WIDTH, _width);
        ObjectSetInteger(_chart_ID, _name, OBJPROP_STYLE, _style);
        ObjectSetInteger(_chart_ID, _name, OBJPROP_SELECTABLE, _selection);
        ObjectSetInteger(_chart_ID, _name, OBJPROP_SELECTED, _selection);
        ObjectSetInteger(_chart_ID, _name, OBJPROP_HIDDEN, _hidden);
        ObjectSetInteger(_chart_ID, _name, OBJPROP_ZORDER, _z_order);

        return (true);
    }

    void Anchor(string anchor)
    {
        if (anchor == "up")
            _anchor = ANCHOR_UPPER;
        else
            _anchor = ANCHOR_LOWER;

        ObjectSetInteger(_chart_ID, _name, OBJPROP_ANCHOR, _anchor);
    }

    bool MoveByCandle(int candle)
    {
        datetime dt = iTime(NULL, 0, candle);
        int      x, y;
        ChartTimePriceToXY(_chart_ID, _sub_window, dt, 0, x, y);

        ResetLastError();

        if (!ObjectSetInteger(_chart_ID, _name, OBJPROP_XDISTANCE, x)) {
            Print(__FUNCTION__, ": ¡Fallo al mover la coordenada X de la etiqueta! Código del error = ", GetLastError());
            return (false);
        }

        return (true);
    }

    bool MoveByPrice(double price)
    {
        int x, y;
        ChartTimePriceToXY(_chart_ID, _sub_window, 0, price, x, y);

        ResetLastError();

        if (!ObjectSetInteger(_chart_ID, _name, OBJPROP_YDISTANCE, y)) {
            Print(__FUNCTION__, ": ¡Fallo al mover la coordenada X de la etiqueta! Código del error = ", GetLastError());
            return (false);
        }

        return (true);
    }

    bool Text(const string text = "Text")
    {
        //--- anulamos el valor del error
        ResetLastError();

        if (!ObjectSetString(_chart_ID, _name, OBJPROP_TEXT, text)) {
            Print(__FUNCTION__, ": ¡Fallo al cambiar el texto! Código del error = ", GetLastError());
            return (false);
        }

        return (true);
    }

    bool Delete()
    {
        //--- anulamos el valor del error
        ResetLastError();
        //--- eliminamos la etiqueta
        if (!ObjectDelete(_chart_ID, _name)) {
            Print(__FUNCTION__, ": ¡Fallo al eliminar la etiqueta de texto! Código del error = ", GetLastError());
            return (false);
        }
        return (true);
    }

    bool DeleteAll()
    {
        ResetLastError();

        if (!ObjectsDeleteAll(_chart_ID, _prefix)) {
            Print(__FUNCTION__, ": ¡Fallo al eliminar la etiqueta de texto! Código del error = ", GetLastError());
            return (false);
        }

        return (true);
    }
};

DrawVLines *lineCreator;
#endif

MqlDateTime dtIni;
int         _nextTime;

double priceMin;

bool TextCreate(const long              chart_ID   = 0,             // ID del gráfico
                const string            name       = "Text",        // nombre del objeto
                const int               sub_window = 0,             // número de subventana
                datetime                time       = 0,             // hora del punto de anclaje
                double                  price      = 0,             // precio del punto de anclaje
                const string            text       = "Text",        // el texto
                const string            font       = "Arial",       // fuente
                const int               font_size  = 10,            // tamaño de la fuente
                const color             clr        = clrRed,        // color
                const double            angle      = 0.0,           // inclinación del texto
                const ENUM_ANCHOR_POINT anchor     = ANCHOR_LEFT_LOWER, // modo de anclaje
                const bool              back       = false,         // al fondo
                const bool              selection  = false,         // seleccionar para mover
                const bool              hidden     = true,          // ocultar en la lista de objetos
                const long              z_order    = 0)                             // prioridad para el clic del ratón
{
    //--- anulamos el valor del error
    ResetLastError();
    //--- creamos el objeto "Texto"
    if (!ObjectCreate(chart_ID, name, OBJ_TEXT, sub_window, time, price)) {
        Print(__FUNCTION__, ": ¡Fallo al crear el objeto \"Texto\"! Código del error = ", GetLastError());
        return (false);
    }
    //--- ponemos el texto
    ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
    //--- establecemos la fuente del texto
    ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
    //--- establecemos el tamaño del texto
    ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
    //--- establecemos el ángulo de inclinación del texto
    ObjectSetDouble(chart_ID, name, OBJPROP_ANGLE, angle);
    //--- establecemos el modo de anclaje
    ObjectSetInteger(chart_ID, name, OBJPROP_ANCHOR, anchor);
    //--- establecemos el color
    ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
    //--- mostramos en el primer plano (false) o al fondo (true)
    ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
    //--- activar (true) o desactivar (false) el modo de desplazamiento del texto con ratón
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
    //--- ocultamos (true) o mostramos (false) el nombre del objeto gráfico en la lista de objetos
    ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
    //--- establecemos la prioridad para obtener el evento de cliquear sobre el gráfico
    ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
    //--- ejecución con éxito
    return (true);
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    //--- indicator buffers mapping
    // SetIndexBuffer(0, CTLBuffer, INDICATOR_DATA);
    SetIniTime();
    lineCreator = new DrawVLines();
    lineCreator.Color(uclr);
    lineCreator.Width(uw);
    lineCreator.DrawBack(ubk);

    priceMin = ChartGetDouble(0, CHART_PRICE_MIN, 0) + 100 * _Point;
    //---
    return (INIT_SUCCEEDED);
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{

    if (id == CHARTEVENT_CHART_CHANGE) {
        // priceMin = ChartGetDouble(0, CHART_PRICE_MIN, 0) + 100 * _Point;
        update();
        // ObjectsDeleteAll(0, "tx");
    }
}
// ------------------------------------------------------------------
void OnDeinit(const int reason)
{
    lineCreator.DeleteAll();
    delete lineCreator;
    ObjectsDeleteAll(0, "tx");
}

// ------------------------------------------------------------------
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    if (rates_total < barsBack) return (0);

    int start = barsBack + 1;
    if (prev_calculated > 1) start = prev_calculated - 1;

    for (int i = start; i < rates_total; i++) {
        MqlDateTime tm;
        TimeToStruct(time[i], tm);

        if (tm.hour == _nextTime && tm.min == 0) {
            lineCreator.SetTime(time[i]);
            string name = "vline" + (string)time[i];
            lineCreator.Create(name);

            double op = 0;
            double hi = 0;
            double lo = 0;
            double cl = 0;

            for (int c = 0; c < Interval; c++) {
                int bars = Bars(NULL, 0);
                int sh   = bars - iBarShift(NULL, 0, time[i], true) + c;
                sh       = MathMin(sh, bars - 1);
                op       = NormalizeDouble(open[sh - c], _Digits);
                hi       = NormalizeDouble(MathMax(hi, high[sh]), _Digits);

                double l = low[sh];
                if (lo == 0) {
                    lo = l;
                } else {
                    lo = MathMin(lo, l);
                }
                cl = NormalizeDouble(close[sh], _Digits);

                if (sh == bars - 1) {
                    ObjectDelete(0, "tx_" + name);
                }
            }

            string txt = "O: " + DoubleToString(op, _Digits) + " H: " + DoubleToString(hi, _Digits) + " L: " + DoubleToString(lo, _Digits) + " C: " + DoubleToString(cl, _Digits);
            priceMin   = ChartGetDouble(0, CHART_PRICE_MIN, 0);
            TextCreate(0, "tx_" + name, 0, time[i], priceMin, txt, "Arial", 8, uclr);

            SetNextTime();
        }
    }
    return (rates_total);
}

// ------------------------------------------------------------------
void SetIniTime()
{
    TimeToStruct(iTime(NULL, 0, barsBack), dtIni);

    while (dtIni.hour != Start_Time) {
        dtIni.hour++;
    }

    _nextTime = dtIni.hour;
}

void SetNextTime()
{
    _nextTime += Interval;

    if (_nextTime >= 24) {
        int dif   = _nextTime - 24;
        _nextTime = dif;
    }
}

void update()
{
    int t = ObjectsTotal(0, 0, OBJ_TEXT);
    for (int i = 0; i < t; i++) {
        string   name   = ObjectName(0, i);
        double   price  = ChartGetDouble(0, CHART_PRICE_MIN, 0);
        ObjectSetDouble(0, name, OBJPROP_PRICE, price);
    }
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
