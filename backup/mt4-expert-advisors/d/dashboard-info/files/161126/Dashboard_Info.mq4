//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76424
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
// #property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots 0

string file_custom_indicator = "";

ENUM_TIMEFRAMES TF[8] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1};

// ------------------------------------------------------------------
input string TitlePairs = "==== PAIRS ====";  // Set your pairs
input string uSymbols   = "GBPUSD,EURUSD,USDJPY,USDCHF";    // Symbols (add separate by comma ","):
// ------------------------------------------------------------------
input string TZ                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
// ------------------------------------------------------------------

input int        VwapPeriod          = 20;          // Volume weighted average period

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
	void OnDeinitEvent(){ canvas.Destroy();}

  void   id(int inpid)               { _id = inpid; }
  int    id(void)                    { return _id; }
  void   Name(string name)           { _name = name; }
  string Name(void)                  { return _name; }
  
  void   X(int inpx)                 { _x = inpx; }
  int    X(void)                     { return _x; }
  void   Y(int inpy)                 { _y = inpy; }
  int    Y(void)                     { return _y; }
  int    X2(void)                    { return _x + _width; }
  int    Y2(void)                    { return _y + _high; }
  void   Y2(int inpy2)               { _y2 = inpy2; High(_y -_y2);}

void DistanceToMouse(int inpdistanceToMouse) { _distanceToMouse = inpdistanceToMouse; }
void setDistanceToMouse(int mousePos) {if(_distanceToMouse==0) _distanceToMouse = mousePos - Y();}
int  DistanceToMouse(void) { return _distanceToMouse; }

void SetPosByPrice(double price) 
{ 
	int coorY = Coordinate(price);
    if(Anchor() == Top)    Y(coorY);
    if(Anchor() == Bottom) Y(coorY-High());
    if(Anchor() == Center) Y(coorY-High()/2);

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
  
  void   High(int high)              { _high = high; }
  int    High(void)                  { return _high; }
  void   Width(int width)            { _width = width; }
  int    Width(void)                 { return _width; }
  
  void   Focus(bool focus)           { _focus = focus; }
  bool   Focus(int x, int y)                 
	{ 
		_focus = false;
		if (x > X() && x < X2() && y > Y() && y < Y2())
    {
      _focus = true;			
			EventChartCustom(0,FOCUS_ON,0, y, _name);
    } 

		return _focus; 
	}

  void   Hide(bool hide)             { _hide = hide; }
  bool   Hide(void)                  { return _hide; }
  void   Show(bool show)             { _show = show; }
  bool   Show(void)                  { return _show; }
  
  void   ColorBack(color colorBack, int alpha)   { _colorBack = ColorToARGB(colorBack, alpha); }
  void   ColorHover(color colorHover, int alpha) { _colorHover = ColorToARGB(colorHover, alpha); }	
  void   ChangeColor(void) { _currentColor = _focus == true ? _colorHover : _colorBack; Refresh(); }
	
  void Refresh()
  {
		canvas.Erase(_currentColor);		
    canvas.TextOut(Width()/2, 0, _text, _textColor, 1);
    canvas.Update(true);
  }

  void   Text(string text)                     { _text = text;                                  }
  string Text(void)                            { return _text;                                  }
  void   Font(string font, int size=9)         { _font = font; canvas.FontSet(_font, size*-10); }
  string Font(void)                            { return _font;                                  }
  void   TextColor(color textColor, int alpha) { _textColor = ColorToARGB(textColor, alpha);    }   
  uint   TextColor(void)                       { return _textColor;                             }

	void  Movable(bool movable)                { _movable = movable;       }
	bool  Movable(void)                        { return _movable;          }
	void  WasPressed(bool  wasPressed)         { _wasPressed = wasPressed; }
	bool  WasPressed(void)                     { return _wasPressed;       }
	void  Move(int y, double limitPrice=0)
	{
		if(!Movable()) return;
		
		if(WasPressed())
		{
	  	    // limitar el movimiento
			if(limitPrice==0)
			{
				limitPrice = Bid;
			}
			
			int coorLimit= Coordinate(limitPrice);  
			
			if(Anchor() == Top) 
			{
				if(y <= coorLimit-5) { y=coorLimit-5; } 
			} else 
			{
				 if(y >= coorLimit-15) { y=coorLimit-15; }
			}
		
			Y(y);		 
		 ObjectSetInteger(0, _name, OBJPROP_YDISTANCE, Y());		
		 EventChartCustom(0,SLIDER_MOVE,0, y,_name);
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
			EventChartCustom(0, MOVEALL_ON,0, mousePos, _name);

			// EventChartCustom(0,SLIDER_MOVE,0, y,_name);
		Refresh();
	}
  
  double PriceTop()
  {
    datetime tm;
    double   pr;
    int      sub;
    if (!ChartXYToTimePrice(0, X(), Y(), sub, tm, pr)) { return -1; }
    return NormalizeDouble(pr, _Digits);
  }
	
  double PriceBottom()
  {
    datetime tm;
    double   pr;
    int      sub;
    if (!ChartXYToTimePrice(0, X(), Y2(), sub, tm, pr)) { return -1; }
    return NormalizeDouble(pr, _Digits);
  }
  
  double PriceCenter()
  {
    datetime tm;
    double   pr;
    int      sub;
		int yCenter = (Y()+Y2())/2;
    if (!ChartXYToTimePrice(0, X(), yCenter, sub, tm, pr)) { return -1; }
    return NormalizeDouble(pr, _Digits);
  }
  
  void setPrice()
  {
		if(Anchor() == Top)    _price = PriceTop();
		if(Anchor() == Bottom) _price = PriceBottom();
		if(Anchor() == Center) _price = PriceCenter();
  }

  double Price(void) { setPrice(); return _price; }
  void   Price(double price) { _price = price; }

  void   Anchor(PriceAnchor priceAnchor) 
  { 
		_priceAnchor = priceAnchor; 	
		// Print("_priceAnchor",_priceAnchor);
		if(_priceAnchor == Top) { ObjectSetInteger(0,_name,OBJPROP_ANCHOR,ANCHOR_UPPER); }
		if(_priceAnchor == Center) { ObjectSetInteger(0,_name,OBJPROP_ANCHOR,ANCHOR_CENTER); }
		if(_priceAnchor == Bottom) { ObjectSetInteger(0,_name,OBJPROP_ANCHOR,ANCHOR_LOWER); }
	
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
    Text("Pr: " + (string)Bid);
    Refresh();
  }
  void OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
  {
    int mousex = lparam;
    int mousey = dparam;

    // NOTE: CHARTEVENT_MOUSE_MOVE
    if (id == CHARTEVENT_MOUSE_MOVE)
    {
      Focus(mousex, mousey);
      ChangeColor();
      // Print(sparam);
      // SetPosByPrice(Ask);

      if (sparam == 0)
      {
        WasPressed(false);
      }
      if (sparam == 1 && Focus(mousex, mousey))
      {
        // EventChartCustom(0,PRIORITY_CONTROL,0, mousey, _name);
      }
      // Move(mousey);

      return;
    }

    if (id == CHARTEVENT_OBJECT_CLICK)
    {
      // SetPosByPriceY(1.25240);
      Print(sparam);
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

    // NOTE: Create BitmapLabel

    if (!canvas.CreateBitmapLabel(0, 0, _name, _x, _y, _width, _high, COLOR_FORMAT_ARGB_NORMALIZE))
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
  CButtonFlat _rows[][18];
  int         _nRows;
  int         _nColumns;
  int         _shift;

 public:
  Table() { ; }
  ~Table() { ; }

  // NOTE: TABLE ON EVENT
  void OnEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
  {
    if (id == CHARTEVENT_MOUSE_MOVE)
    {
      for (int r = 0; r < _nRows; r++)
      {
        for (int c = 0; c < _nColumns; c++)
        {
          _rows[r, c].OnEvent(id, lparam, dparam, sparam);
        }
      }
    }

    if (id == CHARTEVENT_OBJECT_CLICK)
    {
      for (int i = 0; i < _nRows; i++)
      {
        if (_rows[i, 0].Name() == sparam)
        {
          ChartSetSymbolPeriod(0, _rows[i, 0].Text(), PERIOD_CURRENT);
        }
      }

      // clang-format off
	  for (int r = 1; r < _nRows; r++)
      {
		for (int c = 1; c < _nColumns; c++) {
    	    if(_rows[r, c].Name() == sparam) {
				if(c < 3)  {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_M1  );break;}
				if(c < 5)  {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_M5  );break;}
				if(c < 7)  {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_M15 );break;}
				if(c < 9)  {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_M30 );break;}
				if(c < 11) {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_H1  );break;}
				if(c < 13) {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_H4  );break;}
				if(c < 15) {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_D1  );break;}
				if(c < 17) {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_W1  );break;}
                	}
                }
            }
    	}
    }

  void OnTickEvent();
  void OnDeinitEvent();
  
  string cellText(int r, int c) { return _rows[r, c].Text(); }
  void nRows(int inpnRows)      { _nRows = inpnRows + 1; }
  void nColumns(int Columns)    { _nColumns = Columns; }
  int  nRows(void)              { return _nRows; }
  void ShiftText(int shiftTxt)  { _shift = shiftTxt; }

  void Create()
  {
    ArrayResize(_rows, _nRows);
    nColumns(6);
    int y = 80;
    int x = 10;

    for (int i = 0; i < _nRows; i++)
    {
      x = 0;
      _rows[i, 0].Name("row" + i);
      _rows[i, 0].Text("");
      _rows[i, 0].Width(70);
      _rows[i, 0].X(x);
      _rows[i, 0].Y(y);
	  _rows[i, 0].ColorHover(C'13,71,161', 255); // Azul Marino
      _rows[i, 0].Create();

      x += 71;
      for (int j = 1; j < _nColumns; j++)
      {
        _rows[i, j].Name("celda_" + i + "_" + j);
        _rows[i, j].Text("");
        if (i > 0 ) _rows[i, j].Font("Wingdings 3", 8); // Todo flechas
        
        // if (i > 0 && esPar(j) == false ) _rows[i, j].Font("Wingdings 3", 8);
        // if (i > 0 && esPar(j) == true) _rows[i, j].Font("Calibri", 9);
        // if(i>0)_rows[i, j].Font("Arial"); // todo texto
        
        _rows[i, j].Width(35);
        _rows[i, j].X(x);
        _rows[i, j].Y(y);
        _rows[i, j].Create();
        x += 36;
      }
      y += 17;
    }
  }

  void setHeaders(string& headers[])
  {
    for (int j = 0; j < ArraySize(headers); j++)
    {
      _rows[0, j].Text(headers[j]);
    }
  }

  void setRowNames(string& rowName[])
  {
    for (int j = 0; j < ArraySize(rowName); j++)
    {
      _rows[j + 1, 0].Text(rowName[j]);
    }
  }

  void Refresh()
  {
    for (int i = 0; i < _nRows; i++)
    {
      for (int j = 0; j < 18; j++)
      {
        _rows[i, j].RefreshText();
      }
    }
  }

  void setValues(int rowNumber, string& values[])  {
    for (int j = 0; j < ArraySize(values); j++)
    {
      _rows[rowNumber + 1, j + 1].Text(values[j]);
			
	  // No Signal
      if (values[j] == "V") { _rows[rowNumber + 1, j + 1].TextColor(clrBlack, 255); }
      
	  // UP format      
	  if (values[j] == "p") { _rows[rowNumber + 1, j + 1].TextColor(LimeGreen, 255); }

      // Down Format
      if (values[j] == "q") { _rows[rowNumber + 1, j + 1].TextColor(Crimson, 255); }

		_rows[rowNumber + 1, j + 1].RefreshText();
    }
  }

	string getValue(int row, int column)
	{
		return _rows[row, column].Text();
	}

  

};

Table table();

#endif GUI_


// Punto Pivote (PP) = (Máximo + Mínimo + Cierre) / 3.
double Pivot(string symbol)
{
  double high = iHigh(symbol, PERIOD_D1, 1);
  double low  = iLow(symbol, PERIOD_D1, 1);
  double close= iClose(symbol, PERIOD_D1, 1);
  double pp = (high + low + close) / 3.0;
  return NormalizeDouble(pp, _Digits);  
}

double VWAP(string sym)
{
  return iCustom(sym,PERIOD_D1,"VWAP",VwapPeriod,0,0);
}

bool Pattern1(string symbol, string direccion)
{
   double open = iOpen(symbol,PERIOD_D1,0);
   if(direccion == "up") return (open > Pivot(symbol));
   if(direccion == "dn") return (open < Pivot(symbol));
   
   return false;
  }
  
  bool Pattern2(string symbol, string direccion)
  {
    double vwap = VWAP(symbol);
    double open = iOpen(symbol,PERIOD_D1,0);
    
    if(direccion == "up") return (vwap > open);
    if(direccion == "dn") return (vwap < open);
    
    return false;
  }
  bool Pattern3(string symbol, string direccion)
  {
    double vwap = VWAP(symbol);
    double pivot =  Pivot(symbol);

    if(direccion == "up") return (vwap > pivot);
    if(direccion == "dn") return (vwap < pivot);
    
    return false;
}
bool Pattern4(string symbol, string direccion)
{
    double sma5 = iMA(symbol, PERIOD_D1, 5, 0, MODE_SMA, PRICE_CLOSE, 0);
    double price = iMA(symbol, PERIOD_D1, 1, 0, MODE_SMA, PRICE_CLOSE, 0);

    if(direccion == "up") return (price > sma5);
    if(direccion == "dn") return (price < sma5);
    
    return false;
}
bool Pattern5(string symbol, string direccion)
{
    double sma5_0 = iMA(symbol, PERIOD_D1, 5, 0, MODE_SMA, PRICE_CLOSE, 0);
    double sma5_1 = iMA(symbol, PERIOD_D1, 5, 0, MODE_SMA, PRICE_CLOSE, 1);

    if(direccion == "up") return (sma5_0 > sma5_1);
    if(direccion == "dn") return (sma5_0 < sma5_1);
    
    return false;
}



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
    ushort u_sep;
    u_sep = StringGetCharacter(sep, 0);
    int k = StringSplit(uSyms, u_sep, Simbolos);
    ArrayResize(_symbols, ArrayRange(Simbolos, 0), 0);

    for (int i = 0; i < ArrayRange(Simbolos, 0); i++)
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
    if (_current == end())
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
    for (int i = ini(); i < end(); i++)
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
      _symbol    = Symbol();
      _tf        = Period();
   }
   ~CNewCandle(){;}

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
CNewCandle newCandleM1(_Symbol, PERIOD_M1);
//+------------------------------------------------------------------+

// NOTE: OnInit
int OnInit()
{
  ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1, true);
	symbols = new SymbolsList(uSymbols);
  CreateTable();
	doActions();

  newCandleM1.IsNewCandle();
  
  return (INIT_SUCCEEDED);
}

// NOTE: TABLE Create
void CreateTable()
{
  int sym = symbols.qnt();
  table.nRows(sym);
  table.Create();
  string headers[6] = {" ", "1","2", "3","4","5"};
  table.setHeaders(headers);
  table.setRowNames(symbols._symbols);
  table.Refresh();
}

// NOTE: deinit
void OnDeinit(const int Reason)
{
	ObjectsDeleteAll(0, "arrow");
  delete symbols;
}

// NOTE: OnCalculate
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
 
 if(newCandleM1.IsNewCandle())
 {
	
	// Print(__FUNCTION__,"calculando... ");
	 doActions(); 
	//  NotifyControl();
	}
  
	return (rates_total);
}

void doActions()
{
	// clang-format off
  for (int sym = symbols.ini(); sym < symbols.qnt(); sym = symbols.next()) // cada sym es un renglón de la tabla
  {
        // juntás los 5 resultados en un array por symbolo
        string results[5]; // resultados por symbolo (p => patrón alcista , q => patrón bajista)
        results[0] = Pattern1(symbols.currentSymbol(), "up") ? "p" : Pattern1(symbols.currentSymbol(), "dn") ? "q" : "V";
        results[1] = Pattern2(symbols.currentSymbol(), "up") ? "p" : Pattern2(symbols.currentSymbol(), "dn") ? "q" : "V";
        results[2] = Pattern3(symbols.currentSymbol(), "up") ? "p" : Pattern3(symbols.currentSymbol(), "dn") ? "q" : "V";
        results[3] = Pattern4(symbols.currentSymbol(), "up") ? "p" : Pattern4(symbols.currentSymbol(), "dn") ? "q" : "V";
        results[4] = Pattern5(symbols.currentSymbol(), "up") ? "p" : Pattern5(symbols.currentSymbol(), "dn") ? "q" : "V";

        table.setValues(sym,results);
  }      
}

void OnChartEvent(const int     id, const long&   lparam, const double& dparam, const string& sparam)
{
  double y_subwindow = ChartGetInteger(0, CHART_WINDOW_YDISTANCE, 1);
  double dparam_modif = dparam - (long)y_subwindow;

  table.OnEvent(id, lparam, dparam_modif, sparam);

}

// void AddFinder(string sym)
// {
//   int t = ArraySize(finders);
//   if (ArrayResize(finders, t + 1))
//   {
//     finders[t] = new FinderPattern(sym);
//   }
// }

// void deleteFinders()
// {
//   for (int i = 0; i < ArraySize(finders); i++)
//   {
//     delete finders[i];
//   }
// }

void NotifyControl()
{
  for (int r = 1; r < table.nRows(); r++)
  {
    string value = "";
    
		for (int c = 1; c <= 16; c++)
    {
			  value = table.cellText(r, c);

        string sym = table.cellText(r, 0);
        if (value == "p" && table.cellText(r, c+1)=="01") Notifications(0, sym, table.cellText(0, c));
        if (value == "q" && table.cellText(r, c+1)=="01") Notifications(1, sym, table.cellText(0, c));
    }
  }
}

// clang-format off
void Notifications(int type, string sym, string tf)
{
  if (!notifications) return;

  if(tf == "M1" && newCandleM1.IsNewCandle()==false) return;
  // if(tf == "M5" && newCandleM5.IsNewCandle()==false) return;
  // if(tf == "M15"&& newCandleM15.IsNewCandle()==false) return;
  // if(tf == "M30"&& newCandleM30.IsNewCandle()==false) return;
  // if(tf == "H1" && newCandleH1.IsNewCandle()==false) return;
  // if(tf == "H4" && newCandleH4.IsNewCandle()==false) return;
  // if(tf == "D1" && newCandleD1.IsNewCandle()==false) return;
  // if(tf == "W1" && newCandleW1.IsNewCandle()==false) return;


	string text = "";
	  if (type == 0) text += sym + " " + tf + " BUY ";
	  if (type == 1) text += sym + " " + tf + " SELL ";


	if (desktop_notifications) Alert(text);
  if (push_notifications) SendNotification(text);
  if (email_notifications) SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
  switch (lPeriod)
  {
    case PERIOD_M1: return  ("M1");
    case PERIOD_M5: return  ("M5");
    case PERIOD_M15: return ("M15");
    case PERIOD_M30: return ("M30");
    case PERIOD_H1: return  ("H1");
    case PERIOD_H4: return  ("H4");
    case PERIOD_D1: return  ("D1");
    case PERIOD_W1: return  ("W1");
    case PERIOD_MN1: return ("MN1");
  }
  return IntegerToString(lPeriod);
}

bool esPar(int n)
{
	double resto = n % 2;
	if(resto ==0)return true;

	return false;
}

void drawArrow(int i,color theColor,int theCode,bool up)
{
	 ObjectsDeleteAll(0, "arrow");
 
   string name = "arrow"+i;
   double gap  = iATR(NULL,0,20,i)/2;
   
   ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
   ObjectSet(name,OBJPROP_ARROWCODE,theCode);
   ObjectSet(name,OBJPROP_COLOR,theColor);
   ObjectSet(name,OBJPROP_WIDTH,1);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,Low[i] - gap);
         else  ObjectSet(name,OBJPROP_PRICE1,High[i] + gap);
}





//── Project ─────────────────────────────────────────────────────────────────────
/*
Name:        
Version:     
Date:        
Repository:  Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76424
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