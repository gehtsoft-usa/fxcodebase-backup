// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73523

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
#property strict

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

    // clang-format on
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


    void Refresh()
    {
        canvas.Erase(_currentColor);
        canvas.TextOut(_width-2, 0, _text, _textColor,2);
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
CFillRectangle* weeks[];
CFillRectangle* days[];

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];

// ------------------------------------------------------------------
input bool draw_weeks = true; 
input int  weeksBack = 3;     // Weeks Back:
input bool draw_days = false;  // Draw days?
input int  daysBack  = 3;      // Days Back

input string T0                    = "== Break Setup ==";    // ————————————
input int    nCandles              = 2;                      // Maximum candle to break previous:
input string T1                    = "== Notifications ==";  // ————————————
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
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

// ------------------------------------------------------------------
// NOTE: OnInit
int OnInit()
{
    //--- indicator buffers mapping

    // NOTE: creo el array con las zonas
    if (ArrayResize(weeks, weeksBack))
        for (int t = 0; t < ArraySize(weeks); t++)
        {
            weeks[t] = new CFillRectangle();
        }

    if (draw_days)
        if (ArrayResize(days, daysBack))
        {
            for (int t = 0; t < ArraySize(days); t++)
            {
                days[t] = new CFillRectangle();
            }
        }

    //---
    return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    for (int i = 0; i < ArraySize(weeks); i++)
    {
        delete weeks[i];
    }
    for (int i = 0; i < ArraySize(days); i++)
    {
        delete days[i];
    }
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    for (int i = 0; i < ArraySize(weeks); i++)
    {
        weeks[i].OnEvent(id, lparam, dparam, sparam);
    }
    for (int i = 0; i < ArraySize(days); i++)
    {
        days[i].OnEvent(id, lparam, dparam, sparam);
    }
}

// ------------------------------------------------------------------

int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
	  if (draw_weeks)
    for (int i = 0; i < ArraySize(weeks); i++)
    {
        int    candle_end_week = 0;  // vela en tf actual que es el cierre de la semana
        double op              = iOpen(NULL, PERIOD_W1, i);
        double cl              = iClose(NULL, PERIOD_W1, i + 1);
        double y1              = op > cl ? op : cl;
        double y2              = op < cl ? op : cl;
        int    x1              = Shift(i, PERIOD_W1);
        int    x2              = candle_end_week;

        // set color:
        color red   = C'250,70,70';
        color green = C'50,250,70';
        color clr   = op > cl ? green : red;
        weeks[i].ColorBack(clr, 80);
	    	
				// create
		    weeks[i].Create("week " + (string)i, y1, y2, x1, x2);
    }

    if (draw_days)
        for (int i = 0; i < ArraySize(days); i++)
        {
            int    candle_end_week = 0;  // vela en tf actual que es el cierre de la semana
            double op              = iOpen(NULL, PERIOD_D1, i);
            double cl              = iClose(NULL, PERIOD_D1, i + 1);
            double y1              = op > cl ? op : cl;
            double y2              = op < cl ? op : cl;
            int    x1              = Shift(i, PERIOD_D1);
            int    x2              = candle_end_week;

            
						// set color:
            color red   = Crimson;
            color green = RoyalBlue;
            color clr = op > cl ? green : red;
            days[i].ColorBack(clr, 80);
    

		        days[i].Create("day " + (string)i, y1, y2, x1, x2);
        }

    return (rates_total);
}

// necesito el shift en tf actual, que corresponde a op o cl de la vela de determinado tf superior
int Shift(int candleInCurrentTF, ENUM_TIMEFRAMES otherTF)
{
    datetime tm_sup_tf = iTime(NULL, otherTF, candleInCurrentTF);
    int      shift     = iBarShift(NULL, 0, tm_sup_tf, false);
    Print(__FUNCTION__, " shift: ", shift);

    return shift;
}

// ------------------------------------------------------------------
// void setCandles(int i, int shift)
// {
//     candle1.setCandle(i + shift);
//     candle2.setCandle(i);
// }

// bool haveSignalUp(int i)
// {
//     // TODO: signal up

//     //	"Strong Up Trend";
//     // DMI+ / DMI Level CrossOver
//     // ADX > ADX Level
//     // ADM+ > DMI-
//     if (adx.bull(i) == true && adx.PlusDiCrossLevel(i) == true && adx.Main(i) > AdxLevelMain)
//     {
//         return true;
//     }

//     return false;
// }

// bool haveSignalDown(int i)
// {
//     // TODO: signal down

//     // "Strong Down Trend";
//     // DMI- / DMI Level CrossOver
//     // ADX > ADX Level
//     // ADM+ < DMI-
//     if (adx.bear(i) == true && adx.MinusDiCrossLevel(i) == true && adx.Main(i) > AdxLevelMain)
//     {
//         return true;
//     }

//     return false;
// }

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