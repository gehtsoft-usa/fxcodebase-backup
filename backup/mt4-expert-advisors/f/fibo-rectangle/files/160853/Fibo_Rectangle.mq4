//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76368
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/
 

// MQL properties
#property copyright "© 2025 Gehtsoft USA LLC"
#property link      "https://fxcodebase.com"
#property version   "1.0"

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
#include <Controls\Button.mqh>

#define Section_Button
#ifdef Section_Button
// Mark: Section_Button

#include <Controls/Button.mqh>
CButton btFibo;
#define BUTTON1_NAME "Fibo"

bool hide = false;

int OnInitButtons()
{

    if (!Create_button(BUTTON1_NAME, 10, 100, 17, 100, btFibo)) return (INIT_FAILED);

    return true;
}

bool Create_button(string name, const int x1, const int y1, const int high, const int width, CButton &bt)
{
    int x2 = x1 + width;
    int y2 = y1 + high;

    bt.Create(0, name, 0, x1, y1, x2, y2);
    bt.Text(name);
    bt.Font("Calibri");
    bt.FontSize(8);

    return true;
}

// NOTE: Events
void OnChartEventButtons(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    if (id == CHARTEVENT_OBJECT_CLICK && sparam == BUTTON1_NAME) {
        // TODO: event del button 1
        ActionBt1();
    }
}

void ActionBt1() { CreateFiboZone("buy"); }

void CreateFiboZone(string Side)
{
    string name = "fibo_" + (string)(int)TimeCurrent();

    int imax = iHighest(NULL, 0, MODE_HIGH, 10, 1);
    int imin = iLowest(NULL, 0, MODE_LOW, 10, 1);

    int shift = Side == "buy" ? imin : imax;

    double priceUp, priceDn;
    priceUp = iHigh(NULL, 0, shift);
    priceDn = iLow(NULL, 0, shift);

    // clang-format off
    color colorRect = Side == "buy" ? C'60,110,60' :  C'100,50,50'; // Color verde para compra, rojo para venta
    // clang-format on

    datetime tiempoIzq = Time[shift];
    datetime tiempoDer = Time[0];

    if (ObjectFind(0, name) != -1) ObjectDelete(0, name);

    ObjectCreate(0, name, OBJ_RECTANGLE, 0, tiempoIzq, priceUp, tiempoDer, priceDn);
    ObjectSetInteger(0, name, OBJPROP_COLOR, colorRect);
    ObjectSetInteger(0, name, OBJPROP_BACK, true);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);
    ObjectSetInteger(0, name, OBJPROP_SELECTED, true);
    ObjectSetString(0, name, OBJPROP_TEXT, "Fibo");
}

void EraseDisabledFiboLevels()
{
    // Borra solo los niveles y etiquetas que estén desactivados por input
    struct FiboLevelInfo
    {
        double value;
        bool   enabled;
    };

    FiboLevelInfo levels[7];
    levels[0].value = 0.0;   levels[0].enabled = Fibo_0;
    levels[1].value = 0.236; levels[1].enabled = Fibo_23_6;
    levels[2].value = 0.382; levels[2].enabled = Fibo_38_2;
    levels[3].value = 0.5;   levels[3].enabled = Fibo_50;
    levels[4].value = 0.618; levels[4].enabled = Fibo_61_8;
    levels[5].value = 0.786; levels[5].enabled = Fibo_78_6;
    levels[6].value = 1.0;   levels[6].enabled = Fibo_100;

    int totalObjs = ObjectsTotal();
    for (int i = totalObjs - 1; i >= 0; i--)
    {
        string objName = ObjectName(0, i);
        for(int l = 0; l < 7; l++)
        {
            if(!levels[l].enabled)
            {
                string levelStr = DoubleToString(levels[l].value, 3);
                if(StringFind(objName, "_Fibo_Line_" + levelStr) > 0 || StringFind(objName, "_Fibo_Line_" + levelStr + "_Label") > 0)
                    ObjectDelete(0, objName);
            }
        }
    }
}

void CleanOrphanFiboLevels()
{
    // Recorre todos los objetos y borra líneas y etiquetas de niveles que no tengan rectángulo asociado
    int totalObjs = ObjectsTotal();
    for(int i = totalObjs - 1; i >= 0; i--)
    {
        string objName = ObjectName(0, i);

        // Solo procesa líneas y etiquetas de niveles
        if(StringFind(objName, "_Fibo_Line_") > 0 || StringFind(objName, "_Fibo_Line_") == 0 || StringFind(objName, "_Fibo_Line_") > -1)
        {
            // Extrae el nombre base del rectángulo (antes de "_Fibo_Line_")
            int pos = StringFind(objName, "_Fibo_Line_");
            string rectName = StringSubstr(objName, 0, pos);

            // Si no existe el rectángulo, borra la línea/etiqueta
            if(ObjectFind(0, rectName) == -1)
                ObjectDelete(0, objName);
        }
        if(StringFind(objName, "_Fibo_Label") > 0 || StringFind(objName, "_Fibo_Label") == 0 || StringFind(objName, "_Fibo_Label") > -1)
        {
            int pos = StringFind(objName, "_Fibo_Label");
            string rectName = StringSubstr(objName, 0, pos);

            if(ObjectFind(0, rectName) == -1)
                ObjectDelete(0, objName);
        }
    }
}

void DrawFiboLevels()
{
    // clang-format off
    EraseDisabledFiboLevels();
    CleanOrphanFiboLevels();

    double levels[7];
    int    count = 0;
    
    if (Fibo_0)    { levels[count++] = 0.0;   }
    if (Fibo_23_6) { levels[count++] = 0.236; }
    if (Fibo_38_2) { levels[count++] = 0.382; }
    if (Fibo_50)   { levels[count++] = 0.5;   }
    if (Fibo_61_8) { levels[count++] = 0.618; }
    if (Fibo_78_6) { levels[count++] = 0.786; }
    if (Fibo_100)  { levels[count++] = 1.0;   }

    int total = ObjectsTotal();
    for (int i = 0; i < total; i++) {
        string objName = ObjectName(0, i);
        if (StringFind(objName, "fibo") == 0 && ObjectGetInteger(0, objName, OBJPROP_TYPE) == OBJ_RECTANGLE) {
            double   priceUp   = ObjectGetDouble(0, objName, OBJPROP_PRICE1);
            double   priceDown = ObjectGetDouble(0, objName, OBJPROP_PRICE2);
            datetime timeLeft  = ObjectGetInteger(0, objName, OBJPROP_TIME1);
            datetime timeRight = ObjectGetInteger(0, objName, OBJPROP_TIME2);

            double priceHigh = MathMax(priceUp, priceDown);
            double priceLow  = MathMin(priceUp, priceDown);

            for (int l = 0; l < count; l++) {
                double fiboPrice = priceLow + (priceHigh - priceLow) * levels[l];
                string lineName  = objName + "_Fibo_Line_" + DoubleToString(levels[l], 3);

                // Borra la línea si ya existe
                if (ObjectFind(0, lineName) != -1) ObjectDelete(0, lineName);

                ObjectCreate(0, lineName, OBJ_TREND, 0, timeLeft, fiboPrice, timeRight, fiboPrice);
                ObjectSetInteger(0, lineName, OBJPROP_COLOR, Black);
                ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 1);
                ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, false);
                ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);

                // Etiqueta de nivel
                string labelName = lineName + "_Label";
                if (ObjectFind(0, labelName) != -1) ObjectDelete(0, labelName);

                ObjectCreate(0, labelName, OBJ_TEXT, 0, timeLeft, fiboPrice);
                ObjectSetText(labelName, DoubleToString(levels[l] * 100, 1) + "%", 8, "Arial", Black);
                ObjectSetInteger(0, labelName, OBJPROP_ANCHOR, ANCHOR_LEFT_LOWER);
                ObjectSetInteger(0, labelName, OBJPROP_SELECTABLE, false);
            }
        }
    }
}

void DeleteAllIndicatorObjects()
{
    int total = ObjectsTotal();
    for(int i = total - 1; i >= 0; i--)
    {
        string objName = ObjectName(0, i);
        // Borra rectángulos, líneas y etiquetas creados por este indicador
        if(StringFind(objName, "fibo_") == 0 ||
           StringFind(objName, "_Fibo_Line_") > 0 ||
           StringFind(objName, "_Fibo_Line_") == 0 ||
           StringFind(objName, "_Fibo_Label") > 0 ||
           StringFind(objName, "_Fibo_Label") == 0)
        {
            ObjectDelete(0, objName);
        }
    }
}

// clang-format on
#endif

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];

// ------------------------------------------------------------------
input string T0        = "== Fibo Levels =="; // ---
input bool   Fibo_0    = false;               // Fibo 0%
input bool   Fibo_23_6 = true;                // Fibo 23.6%
input bool   Fibo_38_2 = true;                // Fibo 38.2%
input bool   Fibo_50   = true;                // Fibo 50%
input bool   Fibo_61_8 = true;                // Fibo 61.8%
input bool   Fibo_78_6 = true;                // Fibo 78.6%
input bool   Fibo_100  = false;               // Fibo 100%

input string T1                    = "== Notifications =="; // Notifications
input bool   notifications         = false;                 // Notifications On?
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";    // Set Arrows
input bool   ArrowsOn              = true;                  // Arrows On?
input color  ArrowUpClr            = clrBlue;               // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                // Arrow Down Color:

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

void OnDeinit(const int reason) { 
    DeleteAllIndicatorObjects();
}

// ------------------------------------------------------------------
int OnInit()
{
    OnInitButtons();

    SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
    SetIndexArrow(0, 233);
    SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
    SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
    SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
    SetIndexArrow(1, 234);
    if (!ArrowsOn) {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }
    //---
    return (INIT_SUCCEEDED);
}

// ------------------------------------------------------------------
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) { OnChartEventButtons(id, lparam, dparam, sparam); }

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    int i = rates_total - prev_calculated + 1;
    if (i >= rates_total) i = rates_total - 1;
    for (; i > 0; i--) {
        if (haveSignalUp(i)) {
            ArrowUp[i] = Low[i];
            if (newCandle.IsNewCandle()) {
                Notifications(0);
            }
        }
        if (haveSignalDown(i)) {
            ArrowDn[i] = High[i];
            if (newCandle.IsNewCandle()) {
                Notifications(1);
            }
        }
    }

    DrawFiboLevels();

    return (rates_total);
}

bool haveSignalUp(int i)
{
    // TODO: signal up

    return false;
}

bool haveSignalDown(int i)
{
    // TODO: signal down

    return false;
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

//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76368
License:     GNU
*/

// ── Author ──────────────────────────────────────────────────────────────────────
/*
Developed by: Mario Jemic
Email:        mario.jemic@gmail.com
Website:      https://mario-jemic.com
*/

// ── Support & Donations ─────────────────────────────────────────────────────────
/*
PayPal:      https://goo.gl/9Rj74e
Patreon:     https://tiny.cc/1ybwxz
BuyMeACoffee:https://tiny.cc/bj7vxz

Crypto:
 BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
 SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
 ETH/BNB/USDT/XRP (ERC20/BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
*/

// ── Copyright ───────────────────────────────────────────────────────────────────
/*
© 2025 Gehtsoft USA LLC — https://fxcodebase.com
*/
/* This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 <https://www.gnu.org/licenses/>.
*/