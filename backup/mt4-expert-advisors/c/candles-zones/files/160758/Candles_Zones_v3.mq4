//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160663#p160663
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

int endReason = 0;

// #include <"FillRectangle.mqh">
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
    if (id == CHARTEVENT_CHART_CHANGE)
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
  
    void   id(int inpid)               { _id = inpid; }
    int    id(void)                    { return _id; }
    void   Name(string name)           { _name = name; }
    string Name(void)                  { return _name; }
  
    void   X(int inpx)                 { _x = inpx; }
    int    X(void)                     { return _x; }
    void   Y(int inpy)                 { _y = inpy; }
    int    Y(void)                     { return _y; }
    int    X2(void)                    { return _x + _width; }
    void   X2(int x2)                  { _x2 = x2; }
    int    Y2(void)                    { return _y + _high; }
    void   Y2(int inpy2)               { _y2 = inpy2; High(_y -_y2);}
	
    void   High(int high)              { _high = high; }
    int    High(void)                  { return _high; }
    void   Width(int width)            { _width = width; }
    int    Width(void)                 { return _width; }

    void   ColorBack(color colorBack, uchar alpha)   { _colorBack = ColorToARGB(colorBack, alpha); }

    string Text(void)                  { return _text; }
    void   Text(string text)           { _text = text; }
    void   Font(string font)           { _font = font; }
    string Font(void)                  { return _font; }
    uint   TextColor(void)             { return _textColor; }
    void   TextColor(color textColor, uchar alpha)   { _textColor = ColorToARGB(textColor, alpha); }   

	void    priceTop(double inppriceTop)       { _priceTop = inppriceTop; }
	double  priceTop(void)                     { return _priceTop; }
	void    priceBottom(double inppriceBottom) { _priceBottom = inppriceBottom; }
	double  priceBottom(void)                  { return _priceBottom; }
	void    barX(int inpbarX)                  { _barX = inpbarX; }
	int     barX(void)                         { return _barX;    }
	void    barX2(int inpbarX2)                { _barX2 = inpbarX2; }
	int     barX2(void)                        { return _barX2;     }

    void DefaultProperties()
    {
        Name("Rectangle");
        X(100);
        Y(Coordinate(Bid));
        Width(150);
        High(16);
        ColorBack(C'250,70,70', 100);
        Text(_name);
        TextColor(clrWhite, 255);
        canvas.FontSet("Calibri", -90);
    }
    // clang-format on

    void Refresh()
    {
        canvas.Erase(_currentColor);
        canvas.TextOut(_width - 2, 0, _text, _textColor, 2);
        canvas.Update(true);
    }

    bool Create()
    {
        _currentColor = _colorBack;
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
        _high  = _y2 - _y;

        _currentColor = _colorBack;
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
        _high  = _y2 - _y;

        ObjectSetInteger(0, _name, OBJPROP_YDISTANCE, Y());
        ObjectSetInteger(0, _name, OBJPROP_XDISTANCE, X());
        ObjectSetInteger(0, _name, OBJPROP_YSIZE, _high);
        ObjectSetInteger(0, _name, OBJPROP_XSIZE, _width);

        canvas.Resize(_width, _high);
    }
};
CFillRectangle *RBD[];
CFillRectangle *DBR[];
CFillRectangle *HRBD[];
CFillRectangle *HDBR[];

CFillRectangle *RBR[];
CFillRectangle *DBD[];

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "Arrow Up"
#property indicator_type1 DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2 DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];

// clang-format off
// ------------------------------------------------------------------
input int  candles_back  = 50;    // Candles Back:
input bool draw_RBD      = true;  // Draw RBD?
input bool draw_HRBD     = true;  // Draw HRBD?
input bool draw_DBR      = true;  // Draw DBR?
input bool draw_HDBR = true;  // Draw HDBR?

// nuevos
// rally base rally
input bool draw_RBR = true;  // Draw RBR?
// DBD ( Drop Base Drop )
input bool draw_DBD = true;  // Draw DBD?



bool lock_tf = false; // Lock Time Frame:

string T1 = "== Notifications ==";  // ————————————
bool   notifications         = false;                  // Notifications On?
bool   desktop_notifications = false;                  // Desktop MT4 Notifications
bool   email_notifications   = false;                  // Email Notifications
bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";     // ————————————
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color:
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
        if (_currentCandles > _initialCandles)
        {
            _initialCandles = _currentCandles;
            return true;
        }

        return false;
    }
};
CNewCandle newCandle();

int first = 0;

// ------------------------------------------------------------------
// NOTE: OnInit
int OnInit()
{
	// clang-format off
    // NOTE: creo el array con las zonas

    //--- indicator buffers mapping
   SetIndexBuffer(0, ArrowUp, INDICATOR_DATA); 
   SetIndexArrow(0, 233);
   SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
   SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
   SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
   SetIndexArrow(1, 234);

    ArrayResize(ArrowUp, iBars(NULL, 0));
    ArrayResize(ArrowDn, Bars);

   if (!ArrowsOn)
   {
      SetIndexStyle(0, DRAW_NONE);
      SetIndexStyle(1, DRAW_NONE);
   }

    if(lock_tf == true && endReason == REASON_CHARTCHANGE)
    {
        endReason = 0;
        return (INIT_SUCCEEDED);
    }

    
    // create_zones();
    // create_RBD_ini();
    // create_HRBD_ini();
    // create_DBR_ini();
    // create_HDBR_ini();        

    // create_RBR_ini();
    // create_DBD_ini();

    return (INIT_SUCCEEDED);
    //---
}

void OnDeinit(const int reason)
{
    endReason = reason;
    if(!lock_tf) cleanZones();
    if(reason == REASON_REMOVE) cleanZones();
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    if(lock_tf == true) return;
    
    for (int i = 0; i < ArraySize(RBD); i++)  { RBD[i].OnEvent(id, lparam, dparam, sparam); }
    for (int i = 0; i < ArraySize(HRBD); i++) { HRBD[i].OnEvent(id, lparam, dparam, sparam); }
    for (int i = 0; i < ArraySize(DBR); i++)  { DBR[i].OnEvent(id, lparam, dparam, sparam);  }
    for (int i = 0; i < ArraySize(HDBR); i++) { HDBR[i].OnEvent(id, lparam, dparam, sparam); }
    for (int i = 0; i < ArraySize(RBR); i++)  { RBR[i].OnEvent(id, lparam, dparam, sparam); }
    for (int i = 0; i < ArraySize(DBD); i++)  { DBD[i].OnEvent(id, lparam, dparam, sparam); }
}

// clang-format on
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    if (lock_tf == true) return (0);

    int i = rates_total - prev_calculated + 1;
    if (i >= rates_total) i = rates_total - 1;
    for (; i > 0; i--) {
        ArrowUp[i] = EMPTY_VALUE;
        ArrowDn[i] = EMPTY_VALUE;
    }

    if (first == 0 || newCandle.IsNewCandle()) {
        cleanZones();
        create_zones();

        create_RBD_ini();
        create_HRBD_ini();
        create_DBR_ini();
        create_HDBR_ini();
        create_RBR_ini();
        create_DBD_ini();
        first = 1;
    }

    return (rates_total);
}

// clang-format off
void create_RBD_ini()
{
	if (draw_RBD){
        for (int i = ArraySize(RBD)-1; i >= 0; i--)
        {
            int    candle_end_week = 0;  // vela en tf actual que es el cierre de la semana
            double op1             = iOpen(NULL, 0, i + 3);
            double cl1             = iClose(NULL, 0, i + 3);
            double op2             = iOpen(NULL, 0, i + 2);
            double cl2             = iClose(NULL, 0, i + 2);
            double op3             = iOpen(NULL, 0, i + 1);
            double cl3             = iClose(NULL, 0, i + 1);

            double price_top, price_bottom;

            if (op1 < cl1 && op2 < cl2 && op3 > cl3 && cl3 < op2)
            {
                double prices[6];
                prices[0] = op1;
                prices[1] = op2;
                prices[2] = op3;
                prices[3] = cl1;
                prices[4] = cl2;
                prices[5] = cl3;

                price_top    = prices[ArrayMaximum(prices)];
                price_bottom = prices[ArrayMinimum(prices)];
                int x1       = i + 3;
                int x2       = candle_end_week;

                // set color:
                color red   = C'250,70,70';
                color green = C'50,250,70';
                color clr   = green;
                RBD[i].ColorBack(clr, 80);

                // create
                RBD[i].Create("RBD " + (string)i, price_top, price_bottom, x1, x2);
                Print(price_top, " i ", i);
                ArrowDn[i] = price_top;
            }
        }
	}
}
void create_HRBD_ini()
{
	if (draw_HRBD){
        for (int i = ArraySize(HRBD)-1; i >= 0; i--)
        {
            int    candle_end_week = 0;  // vela en tf actual que es el cierre de la semana
            double op1             = iOpen(NULL, 0, i + 2);
            double cl1             = iClose(NULL, 0, i + 2);
            double op2             = iOpen(NULL, 0, i + 1);
            double cl2             = iClose(NULL, 0, i + 1);

            double price_top, price_bottom;

            if (op1 < cl1 && op2 > cl2 && cl2 < op1)
            {
                double prices[4];
                prices[0] = op1;
                prices[1] = op2;
                prices[2] = cl1;
                prices[3] = cl2;

                price_top    = prices[ArrayMaximum(prices)];
                price_bottom = prices[ArrayMinimum(prices)];
                int x1       = i + 2;
                int x2       = candle_end_week;

                // set color:
                HRBD[i].ColorBack(clrViolet, 80);
                // create
                HRBD[i].Create("HRBD " + (string)i, price_top, price_bottom, x1, x2);
                ArrowDn[i] = price_top;
            }
        }
    }
}

void create_DBR_ini()
{
	if (draw_DBR) {
        for (int i = ArraySize(DBR)-1; i >= 0; i--)
        {
            int    candle_end_week = 0;  // vela en tf actual que es el cierre de la semana
            double op1             = iOpen(NULL, 0, i + 3);
            double cl1             = iClose(NULL, 0, i + 3);
            double op2             = iOpen(NULL, 0, i + 2);
            double cl2             = iClose(NULL, 0, i + 2);
            double op3             = iOpen(NULL, 0, i + 1);
            double cl3             = iClose(NULL, 0, i + 1);

            double price_top, price_bottom;

            if (op1 > cl1 && op2 > cl2 && op3 < cl3 && cl3 > op2)
            {
                double prices[6];
                prices[0] = op1;
                prices[1] = op2;
                prices[2] = op3;
                prices[3] = cl1;
                prices[4] = cl2;
                prices[5] = cl3;

                price_top    = prices[ArrayMaximum(prices)];
                price_bottom = prices[ArrayMinimum(prices)];
                int x1       = i + 3;
                int x2       = candle_end_week;

                // set color:
                color red   = C'250,70,70';
                color green = C'50,250,70';
                color clr   = red;
                DBR[i].ColorBack(clr, 80);

                // create
                DBR[i].Create("DBR " + (string)i, price_top, price_bottom, x1, x2);
                ArrowUp[i] = price_bottom;
            }
        }
		}
}
void create_HDBR_ini()
{
	if (draw_HDBR)	{		
        for (int i = ArraySize(HDBR)-1; i >= 0; i--)
        {
            int    candle_end_week = 0;  // vela en tf actual que es el cierre de la semana
            double op1             = iOpen(NULL, 0, i + 2);
            double cl1             = iClose(NULL, 0, i + 2);
            double op2             = iOpen(NULL, 0, i + 1);
            double cl2             = iClose(NULL, 0, i + 1);

            double price_top, price_bottom;

            if (op1 > cl1 && op2 < cl2 && cl2 > op1)
            {
                double prices[4];
                prices[0] = op1;
                prices[1] = op2;
                prices[2] = cl1;
                prices[3] = cl2;

                price_top    = prices[ArrayMaximum(prices)];
                price_bottom = prices[ArrayMinimum(prices)];
                int x1       = i + 2;
                int x2       = candle_end_week;

                // set color:
                color clr   = clrBlue;
                HDBR[i].ColorBack(clr, 80);
                // create
                HDBR[i].Create("HDBR " + (string)i, price_top, price_bottom, x1, x2);
                ArrowUp[i] = price_bottom;
            }
        }
		}
}


void create_RBR_ini()
{
	if (draw_RBR) {
        for (int i = ArraySize(RBR)-1; i >= 0; i--)
        {
            int    candle_end_week = 0;  // vela en tf actual que es el cierre de la semana
            double op1             = iOpen(NULL, 0, i + 3);
            double cl1             = iClose(NULL, 0, i + 3);
            double op2             = iOpen(NULL, 0, i + 2);
            double cl2             = iClose(NULL, 0, i + 2);
            double op3             = iOpen(NULL, 0, i + 1);
            double cl3             = iClose(NULL, 0, i + 1);

            double price_top, price_bottom;

            if(op1 < cl1
            && op2 > cl2 && cl2>op1
            && op3 < cl3
            && cl3 > op2)
            {
                double prices[6];
                prices[0] = op1;
                prices[1] = op2;
                prices[2] = op3;
                prices[3] = cl1;
                prices[4] = cl2;
                prices[5] = cl3;

                price_top    = prices[ArrayMaximum(prices)];
                price_bottom = prices[ArrayMinimum(prices)];
                int x1       = i + 3;
                int x2       = candle_end_week;

                // set color:
                color red   = C'250,70,70';
                color green = C'50,250,70';
                color clr   = green;
                RBR[i].ColorBack(clr, 80);

                // create
                RBR[i].Create("RBR " + (string)i, price_top, price_bottom, x1, x2);
            }
        }
	}
}

void create_DBD_ini()
{
	if (draw_DBD) {
        for (int i = ArraySize(DBD)-1; i >= 0; i--)
        {
            int    candle_end_week = 0;  // vela en tf actual que es el cierre de la semana
            double op1             = iOpen(NULL, 0, i + 3);
            double cl1             = iClose(NULL, 0, i + 3);
            double op2             = iOpen(NULL, 0, i + 2);
            double cl2             = iClose(NULL, 0, i + 2);
            double op3             = iOpen(NULL, 0, i + 1);
            double cl3             = iClose(NULL, 0, i + 1);

            double price_top, price_bottom;

            if(op1 > cl1
            && op2 < cl2 && cl2 < op1
            && op3 > cl3 && cl3 < op2)
            {
                double prices[6];
                prices[0] = op1;
                prices[1] = op2;
                prices[2] = op3;
                prices[3] = cl1;
                prices[4] = cl2;
                prices[5] = cl3;

                price_top    = prices[ArrayMaximum(prices)];
                price_bottom = prices[ArrayMinimum(prices)];
                int x1       = i + 3;
                int x2       = candle_end_week;

                // set color:
                color red   = C'250,70,70';
                color green = C'50,250,70';
                color clr   = red;
                DBD[i].ColorBack(clr, 80);

                // create
                DBD[i].Create("DBD " + (string)i, price_top, price_bottom, x1, x2);
            }
        }
	}
}

void create_zones()
{
	if (ArrayResize(RBD, candles_back))  for (int t = 0; t < ArraySize(RBD); t++)  RBD[t] = new CFillRectangle();
    if (ArrayResize(HRBD, candles_back)) for (int t = 0; t < ArraySize(HRBD); t++) HRBD[t] = new CFillRectangle();
    if (ArrayResize(DBR, candles_back))  for (int t = 0; t < ArraySize(DBR); t++)  DBR[t] = new CFillRectangle();
    if (ArrayResize(HDBR, candles_back)) for (int t = 0; t < ArraySize(HDBR); t++) HDBR[t] = new CFillRectangle();
    if (ArrayResize(DBD, candles_back))  for (int t = 0; t < ArraySize(DBD); t++)  DBD[t] = new CFillRectangle();
    if (ArrayResize(RBR, candles_back))  for (int t = 0; t < ArraySize(RBR); t++)  RBR[t] = new CFillRectangle();
}

void cleanZones()
{
	for (int i = 0; i < ArraySize(RBD); i++)  { delete RBD[i];  }
    for (int i = 0; i < ArraySize(HRBD); i++) { delete HRBD[i]; }
    for (int i = 0; i < ArraySize(DBR); i++)  { delete DBR[i];  }
    for (int i = 0; i < ArraySize(HDBR); i++) { delete HDBR[i]; }
    for (int i = 0; i < ArraySize(RBR); i++)  { delete RBR[i];  }
    for (int i = 0; i < ArraySize(DBD); i++)  { delete DBD[i];  }
}


void Notifications(int type)
{
    string text = "";
    if (type == 0)
        text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
    else
        text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

    text += " ";

    if (!notifications)
        return;
    if (desktop_notifications)
        Alert(text);
    if (push_notifications)
        SendNotification(text);
    if (email_notifications)
        SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
    switch (lPeriod)
    {
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
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=160663#p160663
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