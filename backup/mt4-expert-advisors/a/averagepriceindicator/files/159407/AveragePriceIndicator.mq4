//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75981

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4

// Mark: buffers
double ArrowUp[];
double ArrowDn[];
double LineEntryPrice[];
double LineSL[];
double LineTP[];

// ------------------------------------------------------------------
input string          T0                    = "== Risk Reguard Setup =="; // ===  Risk Reguard Setup ===
input double          sl_value              = 1000;                       // SL value in Money
input double          tp_value              = 1000;                       // TP value in Money
input string          T1                    = "== Notifications ==";      // === Notifications ===
input bool            notifications         = false;                      // Notifications On?
input bool            desktop_notifications = false;                      // Desktop MT4 Notifications
input bool            email_notifications   = false;                      // Email Notifications
input bool            push_notifications    = false;                      // Push Mobile Notifications
input string          T2                    = "== Set Lines ==";          // === Set  Lines ===
input color           EntryClr              = clrBlue;                    // Line Entry Price Color:
input color           LineSLClr             = clrRed;                     // Line SL Color:
input color           LineTPClr             = clrGreen;                   // Line TP Color:
input ENUM_LINE_STYLE LineStyle             = STYLE_DOT;                  // Line Style
input int             LineWidth             = 1;                          // Line Width
input int             FontSize              = 10;                         // Font Size for Text:

// ------------------------------------------------------------------

// Mark: Oninit
int OnInit()
{
    SetIndexBuffer(0, LineEntryPrice, INDICATOR_DATA);
    SetIndexStyle(0, DRAW_LINE, LineStyle, LineWidth, EntryClr);
    SetIndexLabel(0, "Entry Price");

    SetIndexBuffer(1, LineSL, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_LINE, LineStyle, LineWidth, LineSLClr);
    SetIndexLabel(1, "SL");

    SetIndexBuffer(2, LineTP, INDICATOR_DATA);
    SetIndexStyle(2, DRAW_LINE, LineStyle, LineWidth, LineTPClr);
    SetIndexLabel(2, "TP");

    return (INIT_SUCCEEDED);
}

// Mark: ontick
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{

    double avPrice = GetAverageOpenPrice();
    double slPrice = GetPriceForMoneyLevels("sl", sl_value);
    double tpPrice = GetPriceForMoneyLevels("tp", tp_value);

    for (int i = 100; i >= 0; i--) {
        LineEntryPrice[i] = EMPTY_VALUE;
        LineSL[i]         = EMPTY_VALUE;
        LineTP[i]         = EMPTY_VALUE;
    }

    for (int i = 20; i >= 0; i--) {
        LineEntryPrice[i] = avPrice;
        LineSL[i]         = slPrice;
        LineTP[i]         = tpPrice;
    }

    string txEntry = "Entry Price";
    DrawText(avPrice, txEntry, EntryClr);

    string txSL = "Risk: " + " " + DoubleToString(sl_value, 2) + " USD";
    DrawText(slPrice, txSL, LineSLClr);

    string txTP = "Profit" + " " + DoubleToString(tp_value, 2) + " USD";
    DrawText(tpPrice, txTP, LineTPClr);

    return (rates_total);
}

void DrawText(double price, string tx, color cl)
{
    string name = "tx" + tx;
    ObjectDelete(0, name);       // Delete the object if it exists
    datetime tm = TimeCurrent(); // 1 minute in the future
    ObjectCreate(0, name, OBJ_TEXT, 0, tm, price);
    ObjectSetText(name, " " + tx, FontSize, "Calibri", cl);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT);
}

double GetAverageOpenPrice()
{
    double totalLots  = 0;
    double totalPrice = 0;
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && (OrderType() == OP_BUY || OrderType() == OP_SELL)) {
                totalLots += OrderLots();
                totalPrice += OrderOpenPrice() * OrderLots();
            }
        }
    }
    if (totalLots > 0)
        return NormalizeDouble(totalPrice / totalLots, MarketInfo(Symbol(), MODE_DIGITS));
    else
        return 0;
}

double GetPriceForMoneyLevels(string type, double money)
{

    double totalLots      = 0;
    double totalOpenPrice = 0;
    int    buyCount = 0, sellCount = 0;

    // Sumar lotes y precios de compra y venta
    for (int i = OrdersTotal() - 1; i >= 0; i--) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol()) {
                if (OrderType() == OP_BUY) {
                    totalLots += OrderLots();
                    totalOpenPrice += OrderOpenPrice() * OrderLots();
                    buyCount++;
                } else if (OrderType() == OP_SELL) {
                    totalLots -= OrderLots();
                    totalOpenPrice += OrderOpenPrice() * OrderLots();
                    sellCount++;
                }
            }
        }
    }

    if (MathAbs(totalLots) < 0.00001) // No hay órdenes o posiciones netas
        return 0;

    double avgOpenPrice = GetAverageOpenPrice();
    double tickValue    = MarketInfo(Symbol(), MODE_TICKVALUE);
    double point        = MarketInfo(Symbol(), MODE_POINT);
    double lots         = MathAbs(totalLots);
    Print("line: ", __LINE__, " : ", lots);
    double slPrice, tpPrice, Distance = 0;

    if (totalLots > 0) {
        Distance = money / (lots * tickValue / point);
        Print("line: ", __LINE__, " Distance: ", Distance);
        slPrice = avgOpenPrice - Distance;
        tpPrice = avgOpenPrice + Distance;
        Print("line: ", __LINE__, " slPrice: ", slPrice);

    } else {
        Distance = money / (lots * tickValue / point);
        slPrice  = avgOpenPrice + Distance;
        tpPrice  = avgOpenPrice - Distance;
    }

    if (type == "tp") {
        return NormalizeDouble(tpPrice, MarketInfo(Symbol(), MODE_DIGITS));
    }
    if (type == "sl") {
        return NormalizeDouble(slPrice, MarketInfo(Symbol(), MODE_DIGITS));
    }
    return 0;
}

// Mark: OnDeinit
void OnDeinit(const int reason)
{
    // Remove the text object when the indicator is removed
    string prefix = "tx";
    ObjectsDeleteAll(0, prefix);
}

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

bool IsNewCandle()
{
    static datetime last;
    datetime        current = iTime(NULL, 0, 1);
    if (last != current) {
        last = current;
        return true;
    }
    return false;
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75981

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 
