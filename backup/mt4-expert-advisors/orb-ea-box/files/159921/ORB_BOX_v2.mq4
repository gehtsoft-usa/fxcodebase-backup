//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=159841#p159841

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];

// ------------------------------------------------------------------

input string          torb                  = "== ORB Setup ==";     // ————————————
input string          timeStart             = "08:00";               // Time Start GMT (HH:MM)
input double          offset                = 100;                   // Offset Points:
input int             minOrbSize            = 100;                   // Min Size:
input int             maxOrbSize            = 600;                   // Max Size:
input ENUM_TIMEFRAMES tf_orb                = PERIOD_M15;            // ORB TF:
string                T1                    = "== Notifications =="; // Notifications
bool                  notifications         = false;                 // Notifications On?
bool                  desktop_notifications = false;                 // Desktop MT4 Notifications
bool                  email_notifications   = false;                 // Email Notifications
bool                  push_notifications    = false;                 // Push Mobile Notifications
string                T2                    = "== Set Arrows ==";    // Set Arrows
bool                  ArrowsOn              = true;                  // Arrows On?
color                 ArrowUpClr            = clrBlue;               // Arrow Up Color:
color                 ArrowDnClr            = clrRed;                // Arrow Down Color:

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
        _symbol         = Symbol();
        _tf             = Period();
    }
    ~CNewCandle() { ; }

    bool IsNewCandle()
    {
        int _currentCandles = iBars(_symbol, _tf);
        if (_currentCandles > _initialCandles) {
            _initialCandles = _currentCandles;
            return true;
        }

        return false;
    }
};
CNewCandle newCandle();

// ------------------------------------------------------------------
int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(1, 234);
    //
    return (INIT_SUCCEEDED);
}

// ------------------------------------------------------------------

double buyPrice;
double sellPrice;
bool   signalOn;
bool   set_orb;

MqlDateTime dt;
int         lastDay;
datetime    start_tm;

datetime StartORB()
{
    int hh = (int)StringSubstr(timeStart, 0, 2);
    int mm = (int)StringSubstr(timeStart, 3, 2);

    MqlDateTime _dt;
    TimeGMT(_dt); // Current time GMT
    _dt.hour = hh;
    _dt.min  = mm;
    _dt.sec  = 00;

    return StructToTime(_dt);
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    // clang-format off
    int start, i;
    if (prev_calculated == 0) { start = rates_total - 100; } else { start = rates_total - (prev_calculated - 1); }
    // clang-format on

    for (i = start; i >= 0; i--) {
        // al iniciar un nuevo día reiniciar los prcecio a cero
        TimeGMT(dt); // Current time GMT
        if (dt.day != lastDay) {
            lastDay   = dt.day;
            set_orb   = true;
            buyPrice  = 0;
            sellPrice = 0;
            start_tm  = StartORB();
            Print("line: ", __LINE__, " start_tm: ", start_tm);
            // Print("NEW DAY", lastDay);
        }
        
        // al pasar la barra definida de tiempo, setear orb con max y min del tf propuesto
        if (TimeGMT() >= start_tm && set_orb == true) {
            VLineCreate(0, "ORB_" + time[i], 0, TimeGMT());
            buyPrice  = iHigh(NULL, tf_orb, i + 1) + offset * _Point;
            sellPrice = iLow(NULL, tf_orb, i + 1) - offset * _Point;
            set_orb   = false;
            signalOn  = true;
        }

        // Buscar señal y filtrar el size
        double size = (high[i + 1] - low[i + 1]) / _Point;
        if (signalOn) {
            if (size < maxOrbSize && size > minOrbSize) {

                if (close[i + 1] > buyPrice && buyPrice != 0) {
                    ArrowUp[i+1] = low[i+1];
                    signalOn   = false;
                }

                if (close[i + 1] < sellPrice && sellPrice != 0) {
                    ArrowDn[i+1] = high[i+1];
                    signalOn   = false;
                }
            }
        }
    }

    return (rates_total);
}

// ------------------------------------------------------------------

void Notifications(int type)
{
    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

    text += " ";

    if (!notifications) return;
    if (desktop_notifications) Alert(text);
    if (push_notifications) SendNotification(text);
    if (email_notifications) SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch (lPeriod) {
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

bool VLineCreate(const long            chart_ID   = 0,         // ID del gráfico
                 const string          name       = "VLine",   // nombre de la línea
                 const int             sub_window = 0,         // índice de subventana
                 datetime              time       = 0,         // hora de la línea
                 const color           clr        = clrGray,   // color de la línea
                 const ENUM_LINE_STYLE style      = STYLE_DOT, // estilo de la línea
                 const int             width      = 1,         // grosor de la línea
                 const bool            back       = false,     // al fondo
                 const bool            selection  = false,     // seleccionar para mover
                 const bool            ray        = true,      // continuación de la línea abajo
                 const bool            hidden     = true,      // ocultar en la lista de objetos
                 const long            z_order    = 0)                       // prioridad para el clic del ratón
{
    if (!time) time = TimeCurrent();
    ResetLastError();
    if (!ObjectCreate(chart_ID, name, OBJ_VLINE, sub_window, time, 0)) {
        Print(__FUNCTION__, ": ¡Fallo al crear la línea vertical! Código del error = ", GetLastError());
        return (false);
    }
    ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
    ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
    ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
    ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
    ObjectSetInteger(chart_ID, name, OBJPROP_RAY, ray);
    ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
    ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);

    return (true);
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=159841#p159841

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+