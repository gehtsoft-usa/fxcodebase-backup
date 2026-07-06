//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76452
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

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots 8

#property indicator_type1  DRAW_LINE
#property indicator_color1 LightSeaGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label1 "RSI 1"
#property  indicator_type2 DRAW_LINE
#property indicator_color2 Navy
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label2 "RSI 2"
#property  indicator_type3 DRAW_LINE
#property indicator_color3 Crimson
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label3 "RSI 3"
#property  indicator_type4 DRAW_LINE
#property indicator_color4 Orange
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_label4 "RSI 4"
#property  indicator_type5 DRAW_LINE
#property indicator_color5 Black
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label5 "RSI 5"
#property  indicator_type6 DRAW_LINE
#property indicator_color6 Green
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label6 "RSI 6"
#property  indicator_type7 DRAW_LINE
#property indicator_color7 Magenta
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label7 "RSI 7"
#property  indicator_type8 DRAW_LINE
#property indicator_color8 DarkGray
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_label8 "RSI 8"


input string TitlePairs = "==== PAIRS ====";             // ————————————
input string uSymbols   = "GBPUSD,EURUSD,USDCHF,USDJPY,USDCAD,AUDUSD,NZDUSD,GBPJPY"; // Symbols (add separate by comma ","):

input int    rsi_period     = 14;                // RSI Period
input string TZ                    = "== Notifications =="; // ————————————
input bool   notifications         = false;                 // Notifications On
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications

double line1[];
double line2[];
double line3[];
double line4[];
double line5[];
double line6[];
double line7[];
double line8[];


int handles[];

// ------------------------------------------------------------------
class SymbolsList
{
    int _current;

  public:
    string _symbols[];

    SymbolsList(string Symbols) { getSymbols(Symbols); }
    ~SymbolsList() { ; }

    void getSymbols(string uSyms)
    {
        string Simbolos[];
        string sep = ",";
        ushort u_sep = StringGetCharacter(sep, 0);
        int k = StringSplit(uSyms, u_sep, Simbolos);

        int target = 8; // cantidad fija deseada
        ArrayResize(_symbols, target);

        for (int i = 0; i < target; i++) {
            if (i < k) {
                _symbols[i] = Simbolos[i];
            } else {
                _symbols[i] = ""; // completar con espacio en blanco
            }
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
        if (_current == end()) {
            _current = end();
        }

        return _current;
    }

    int end() { return ArraySize(_symbols); }

    string currentSymbol() { return _symbols[_current]; }

    int current() { return _current; }

    void printSymbols()
    {
        for (int i = ini(); i < end(); i++) {
            Print(_symbols[i]);
        }
    }

    int qnt() { return ArraySize(_symbols); }

    string at(int index)
    {
        if (index >= 0 && index < ArraySize(_symbols)) {
            return _symbols[index];
        }
        return "";
    }
};
SymbolsList *symbols;

// NOTE: DeInit
void OnDeInit() { 
    delete symbols; 
}

// NOTE: OnInit
int OnInit()
{
    symbols = new SymbolsList(uSymbols);
    ArrayResize(handles, 8);

    for (int i = symbols.ini(); i < symbols.qnt(); i = symbols.next()) {
        if(symbols.currentSymbol() == "") continue;
        handles[i] = iRSI(symbols.currentSymbol(), PERIOD_CURRENT, rsi_period, PRICE_CLOSE);
    }

    SetIndexBuffer(0, line1);    
    SetIndexBuffer(1, line2);
    SetIndexBuffer(2, line3);
    SetIndexBuffer(3, line4);
    SetIndexBuffer(4, line5);
    SetIndexBuffer(5, line6);
    SetIndexBuffer(6, line7);
    SetIndexBuffer(7, line8);

    if(symbols.at(0) == "")  PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
    if(symbols.at(1) == "")  PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
    if(symbols.at(2) == "")  PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
    if(symbols.at(3) == "")  PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
    if(symbols.at(4) == "")  PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_NONE);
    if(symbols.at(5) == "")  PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_NONE);
    if(symbols.at(6) == "")  PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_NONE);
    if(symbols.at(7) == "")  PlotIndexSetInteger(7, PLOT_DRAW_TYPE, DRAW_NONE);

    ShowSymbolListWindow1();
    //---
    return (INIT_SUCCEEDED);
}

// clang-format off
// NOTE: OnCalculate
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
{
    int start;
    if (prev_calculated > 1) start = prev_calculated - 1; else { start = rsi_period + 1; }
    
    for (int i = start; i < rates_total && !IsStopped(); i++) {

            symbols.at(0) != "" ? line1[i] = RSI(0, i) : EMPTY_VALUE;
            symbols.at(1) != "" ? line2[i] = RSI(1, i) : EMPTY_VALUE;
            symbols.at(2) != "" ? line3[i] = RSI(2, i) : EMPTY_VALUE;
            symbols.at(3) != "" ? line4[i] = RSI(3, i) : EMPTY_VALUE;
            symbols.at(4) != "" ? line5[i] = RSI(4, i) : EMPTY_VALUE;
            symbols.at(5) != "" ? line6[i] = RSI(5, i) : EMPTY_VALUE;
            symbols.at(6) != "" ? line7[i] = RSI(6, i) : EMPTY_VALUE;
            symbols.at(7) != "" ? line8[i] = RSI(7, i) : EMPTY_VALUE;

      }
      return (rates_total);
}

double RSI(int h, int candle = 1)
{

    double value[1];
    int    shift = Bars(_Symbol, _Period) - candle;
    // int shift = candle;
    int copy  = CopyBuffer(handles[h], 0, shift, 1, value);

    if (copy > 0) {
        return value[0];
    }
    return -1;
}

// Muestra la lista de símbolos en la ventana 1 (primer sub-ventana del indicador),
// alineada a la derecha del gráfico, cada etiqueta con el nombre del símbolo.
void ShowSymbolListWindow1()
{
    int baseX = 10;
    int baseY = 10;
    int lineHeight = 18;
    int fontSize = 12;
    color cols[8] = {LightSeaGreen, Navy, Crimson, Orange, Black, Green, Magenta, DarkGray};
    int n_cols = ArraySize(cols);

    // borrar etiquetas previas
    for (int i = 0; i < 8; i++) {
        string name = "SYM_LABEL_WIN1_" + IntegerToString(i);
        if (ObjectFind(0, name) != -1) ObjectDelete(0, name);
    }

    // crear/mostrar etiquetas en la ventana 1 (subventana index = 1)
    for (int i = 0; i < symbols.qnt() && i < 8; i++) {
        string sym = symbols.at(i);
        if (StringLen(sym) == 0) {sym = "<vacío>"; continue;}
        string name = "SYM_LABEL_WIN1_" + IntegerToString(i);

        // OBJ_LABEL en subventana 1
        if (!ObjectCreate(0, name, OBJ_LABEL, 1, 0, 0)) {
            Print(__FUNCTION__, " Error creando label: ", name, " code=", GetLastError());
            continue;
        }

        // ubicar a la derecha superior de la subventana
        ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, baseX);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, baseY + i * lineHeight);

        ObjectSetString(0, name, OBJPROP_TEXT, sym);
        ObjectSetInteger(0, name, OBJPROP_COLOR, cols[i % n_cols]);
        ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
        ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, name, OBJPROP_HIDDEN, true); // no guardar con el gráfico
        ObjectSetInteger(0, name, OBJPROP_BACK, true);   // detrás de los objetos del indicador
    }
}
//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76452
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