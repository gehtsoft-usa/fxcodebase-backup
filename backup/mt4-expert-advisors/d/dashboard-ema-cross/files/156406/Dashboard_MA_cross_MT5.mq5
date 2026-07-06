//Available @  https://fxcodebase.com/ 

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
#property strict

// #property indicator_chart_window
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots 1

ENUM_TIMEFRAMES TF[8] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1};

// ------------------------------------------------------------------
input string TitlePairs = "==== PAIRS ===="; // ————————————
input string uSymbols   = "GBPUSD,EURUSD";   // Symbols (add separate by comma ","):
// ------------------------------------------------------------------
input string             Iema1           = "== Moving Averages Setup =="; // == Moving Averages Setup ==
input int                ma1Period       = 10;                            // MA1 Period
input int                ma1Shift        = 0;                             // Ma1 Shift
input ENUM_MA_METHOD     ma1Method       = MODE_EMA;                      // MA1 Method
input ENUM_APPLIED_PRICE ma1AppliedPrice = PRICE_CLOSE;                   // MA1 Applied Price
input string             Iema2           = "== Moving Averages Setup =="; // == Moving Averages Setup ==
input int                ma2Period       = 50;                            // MA2 Period
input int                ma2Shift        = 0;                             // Ma2 Shift
input ENUM_MA_METHOD     ma2Method       = MODE_EMA;                      // MA2 Method
input ENUM_APPLIED_PRICE ma2AppliedPrice = PRICE_CLOSE;                   // MA2 Applied Price

// int  handle_ma1[];
// void setHandle_ma1() { handle_ma1 = iMA(NULL, 0, ma1Period, ma1Shift, ma1Method, ma1AppliedPrice); }

// double MA1(int candle = 1)
// {
//     double value[1];
//     // int    shift = Bars(_Symbol, _Period) - candle;
//     int shift = candle;
//     int copy  = CopyBuffer(handle_ma1, 0, shift, 1, value);

//     if (copy > 0) {
//         return value[0];
//     }
//     return -1;
// }

// int  handle_ma2 = 0;
// void setHandle_ma2() { handle_ma2 = iMA(NULL, 0, ma2Period, ma2Shift, ma2Method, ma2AppliedPrice); }

// double MA2(int candle = 1)
// {
//     double value[1];
//     // int    shift = Bars(_Symbol, _Period) - candle;
//     int shift = candle;
//     int copy  = CopyBuffer(handle_ma2, 0, shift, 1, value);

//     if (copy > 0) {
//         return value[0];
//     }
//     return -1;
// }


// ------------------------------------------------------------------
input string TZ                    = "== Notifications =="; // ————————————
input bool   notifications         = false;                 // Notifications On
input bool   desktop_notifications = false;                 // Desktop MT4 Notifications
input bool   email_notifications   = false;                 // Email Notifications
input bool   push_notifications    = false;                 // Push Mobile Notifications
// ------------------------------------------------------------------

#define FindPattern_
#ifdef FindPattern_

class FinderPattern
{
    string _symbol; // symbol
                    // ENUM_TIMEFRAMES _tf;      // timeframe
    int handlesMA1[8];
    int handlesMA2[8];

  public:
    FinderPattern(string Symbol)
    {
        _symbol = Symbol;
        for (int i = 0; i < ArraySize(handlesMA1); i++) {
            handlesMA1[i] = iMA(Symbol, TF[i], ma1Period, ma1Shift, ma1Method, ma1AppliedPrice);
            handlesMA2[i] = iMA(Symbol, TF[i], ma2Period, ma2Shift, ma2Method, ma2AppliedPrice);
        }
    }
    ~FinderPattern() { ; }

    // busca un patrón de algo y devuelve un codigo de 3 letras que representa:
    // los primeros 2 digitos: vela
    // el ultimo digito: dirección (up = p , dn = q) (por código Ascii)
    string FindPattern(int tf_index)
    {
        string up = "p";
        string dn = "q";
        string candle;

        for (int i = 1; i < 99; i++) {
            if (havePatternUp(i, tf_index)) {
                candle = i < 10 ? "0" + (string)i : (string)i;
                return candle + up;
            }
            if (havePatternDn(i, tf_index)) {
                candle = i < 10 ? "0" + (string)i : (string)i;
                return candle + dn;
            }
        }

        return "00V";
    }

    bool havePatternUp(int i, int tf_index)
    {
        // TODO: escribir el patrón alcista
        double ma1_curr = index(handlesMA1[tf_index], 0, i);
        double ma1_prev = index(handlesMA1[tf_index], 0, i+1);
        double ma2_curr = index(handlesMA2[tf_index], 0, i);
        double ma2_prev = index(handlesMA2[tf_index], 0, i+1);
        
        return ma1_curr > ma2_curr && ma1_prev <= ma2_prev;
    }

    bool havePatternDn(int i, int tf_index)
    {
        // TODO: escribir el patrón bajista
        double ma1_curr = index(handlesMA1[tf_index], 0, i);
        double ma1_prev = index(handlesMA1[tf_index], 0, i+1);
        double ma2_curr = index(handlesMA2[tf_index], 0, i);
        double ma2_prev = index(handlesMA2[tf_index], 0, i+1);
        
        return ma1_curr < ma2_curr && ma1_prev >= ma2_prev;
    }

    double index(int handle, int buffer, int shift)
    {
        double value[1];
        int    qnt = CopyBuffer(handle, buffer, shift, 1, value);

        if (qnt > 0) {
            return value[0];
        }
        return -1;
    }
};

#endif FindPattern_
FinderPattern *finders[];

#define GUI_
#ifdef GUI_

// #include "Gui.mqh"
#include <Canvas\Canvas.mqh>

#define SLIDER_MOVE 1
#define FOCUS_ON 2
#define MOVEALL_ON 3
#define PRIORITY_CONTROL 4

enum PriceAnchor { Top, Bottom, Center };

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
    ~CObjectBase() { canvas.Destroy(); }

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
  void   ChangeColor(void)
	{
			_currentColor = _focus == true ? _colorHover : _colorBack;
			Refresh();
	}
	
	void Refresh()
	{
		canvas.Erase(_currentColor);		
    canvas.TextOut(Width()/2, 0, _text, _textColor, 1);
    canvas.Update(true);
	}

	void   Text(string text)                     { _text = text; }
  string Text(void)                            { return _text; }
  void   Font(string font, int size=9)           { _font = font; canvas.FontSet(_font, size*-10); }
  string Font(void)                            { return _font; }
  void   TextColor(color textColor, int alpha) { _textColor = ColorToARGB(textColor, alpha); }   
  uint   TextColor(void)                       { return _textColor; }

	void  Movable(bool movable)                  { _movable = movable; }
	bool  Movable(void)                          { return _movable; }
	void   WasPressed(bool  wasPressed)          { _wasPressed = wasPressed; }
	bool   WasPressed(void)                      { return _wasPressed; }
	
	double Bid() { return SymbolInfoDouble(NULL, SYMBOL_BID);}
	double Ask() { return SymbolInfoDouble(NULL, SYMBOL_ASK);}

	void   Move(int y, double limitPrice=0)
	{
		if(!Movable()) return;
		
		if(WasPressed())
		{
	  	// limitar el movimiento
			if(limitPrice==0)
			{
				limitPrice = Bid();
			}
			// int coorAsk= Coordinate(limitPrice);  
			// int coorBid= Coordinate(Bid());  
			
			// int coorAsk= Coordinate(Ask());  
			// int coorBid= Coordinate(Bid());  

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
	void Price(double price) { _price = price; }

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
        Text("Pr: " + (string)Bid());
        Refresh();
    }
    void OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
    {
        double mousex = lparam;
        double mousey = dparam;

        // NOTE: CHARTEVENT_MOUSE_MOVE
        if (id == CHARTEVENT_MOUSE_MOVE) {
            Focus(mousex, mousey);
            ChangeColor();
            // Print(sparam);
            // SetPosByPrice(Ask());

            if (sparam == 0) {
                WasPressed(false);
            }
            if (sparam == 1 && Focus(mousex, mousey)) {
                // EventChartCustom(0,PRIORITY_CONTROL,0, mousey, _name);
            }
            // Move(mousey);

            return;
        }

        if (id == CHARTEVENT_OBJECT_CLICK) {
            // SetPosByPriceY(1.25240);
            Print(sparam);
            return;
        }
    }

    void DefaultProperties()
    {
        Name("BtFlat");
        X(0);
        Y(Coordinate(Bid()));
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

        if (!canvas.CreateBitmapLabel(0, 1, _name, _x, _y, _width, _high, COLOR_FORMAT_ARGB_NORMALIZE)) {
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
    void OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
    {
        if (id == CHARTEVENT_MOUSE_MOVE) {
            for (int r = 0; r < _nRows; r++) {
                for (int c = 0; c < _nColumns; c++) {
                    _rows[r, c].OnEvent(id, lparam, dparam, sparam);
                }
            }
        }

        if (id == CHARTEVENT_OBJECT_CLICK) {
            for (int i = 0; i < _nRows; i++) {
                if (_rows[i, 0].Name() == sparam) {
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
    nColumns(17);
    int y = 30;
    int x = 5;

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
        if (i > 0 && esPar(j) == false ) _rows[i, j].Font("Wingdings 3", 8);
        if (i > 0 && esPar(j) == true) _rows[i, j].Font("Calibri", 9);
        // if(i>0)_rows[i, j].Font("Arial");
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
   ENUM_TIMEFRAMES    _tf;

  public:
   CNewCandle(string symbol, ENUM_TIMEFRAMES tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, _tf)) {}
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
CNewCandle newCandleM5(_Symbol, PERIOD_M5);
CNewCandle newCandleM15(_Symbol, PERIOD_M15);
CNewCandle newCandleM30(_Symbol, PERIOD_M30);
CNewCandle newCandleH1(_Symbol, PERIOD_H1);
CNewCandle newCandleH4(_Symbol, PERIOD_H4);
CNewCandle newCandleD1(_Symbol, PERIOD_D1);
CNewCandle newCandleW1(_Symbol, PERIOD_W1);
//+------------------------------------------------------------------+

// NOTE: OnInit
int OnInit()
{
  // int temp = iCustom(NULL, 0, file_custom_indicator);
  // if (GetLastError() == ERR_INDICATOR_CANNOT_CREATE) {
  //   Alert("Please, install the: " + file_custom_indicator + " indicator");
  //   return INIT_FAILED;
  // }

ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1, true);
  
symbols = new SymbolsList(uSymbols);

  for (int i = symbols.ini(); i < symbols.qnt(); i = symbols.next())
  {
    AddFinder(symbols.currentSymbol());
  }

  CreateTable();
  Sleep(1000);

  doActions();

  newCandleM1.IsNewCandle();
  newCandleM5.IsNewCandle();
  newCandleM15.IsNewCandle();
  newCandleM30.IsNewCandle();
  newCandleH1.IsNewCandle();
  newCandleH4.IsNewCandle();
  newCandleD1.IsNewCandle();
  newCandleW1.IsNewCandle();

	//--- 
  return (INIT_SUCCEEDED);
}

// NOTE: TABLE Create
void CreateTable()
{
  int sym = symbols.qnt();
  table.nRows(sym);
  table.Create();
  string headers[17] = {" ", "M1"," ", "M5"," ", "M15"," ", "M30"," ", "H1"," ", "H4"," ", "D1"," ", "W1"," "};
  table.setHeaders(headers);
  table.setRowNames(symbols._symbols);
  table.Refresh();
}

// NOTE: deinit
void OnDeinit(const int reason)
{
	ObjectsDeleteAll(0, "arrow");
  delete symbols;
  deleteFinders();
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
 
	if(newCandleM1.IsNewCandle()) { doActions(); NotifyControl();}
  
	return (rates_total);
}

void doActions()
{
	// clang-format off
	for(int i=0;i < ArraySize(finders) ; i++)
	{
		string candleNumber[8];
		string patternDirection[8];
		string results[16];
	
		for (int j = 0; j < ArraySize(TF); j++) 
		{
			string patCode = finders[i].FindPattern(j);	
			candleNumber[j] = StringSubstr(patCode,0,2);
			patternDirection[j] = StringSubstr(patCode,2,1);
		}
		
		for(int n=0;n < 16;n++)
		{
	 		if( esPar(n)) { int pos = n/2; results[n] = patternDirection[pos]; }
	 		if(!esPar(n)) { int pos = n/2; results[n] = candleNumber[pos]; }
		}
		table.setValues(i,results);
	}
	
	//--- Draw arrow in current timeframe
	int candle=-1; 
	string direction;
	int rowSymbol = -1;
	
	for (int i = 1; i < table.nRows(); i++)
	{
    	rowSymbol = table.getValue(i,0) == Symbol() ? i : -1;
			if(rowSymbol!= -1)break;
	}

	// Print("rowSymbol: ", rowSymbol);
	if(rowSymbol!= -1)
	{
	if(Period() == PERIOD_M1 ) candle = (int)table.getValue(rowSymbol, 2) ;
	if(Period() == PERIOD_M5 ) candle = (int)table.getValue(rowSymbol, 4) ;
	if(Period() == PERIOD_M15) candle = (int)table.getValue(rowSymbol, 6) ;
	if(Period() == PERIOD_M30) candle = (int)table.getValue(rowSymbol, 8) ;
	if(Period() == PERIOD_H1 ) candle = (int)table.getValue(rowSymbol, 10);
	if(Period() == PERIOD_H4 ) candle = (int)table.getValue(rowSymbol, 12);
	if(Period() == PERIOD_D1 ) candle = (int)table.getValue(rowSymbol, 14);
	if(Period() == PERIOD_W1 ) candle = (int)table.getValue(rowSymbol, 16);

	// Print("candle: ", candle);
	if(Period() == PERIOD_M1 ) direction = table.getValue(rowSymbol, 1) ;
	if(Period() == PERIOD_M5 ) direction = table.getValue(rowSymbol, 3) ;
	if(Period() == PERIOD_M15) direction = table.getValue(rowSymbol, 5) ;
	if(Period() == PERIOD_M30) direction = table.getValue(rowSymbol, 7) ;
	if(Period() == PERIOD_H1 ) direction = table.getValue(rowSymbol, 9) ;
	if(Period() == PERIOD_H4 ) direction = table.getValue(rowSymbol, 11);
	if(Period() == PERIOD_D1 ) direction = table.getValue(rowSymbol, 13);
	if(Period() == PERIOD_W1 ) direction = table.getValue(rowSymbol, 15);

	// Print("direction: ", direction);
	// dibujar la flecha  
	color clr;
	int code;
	bool dir;
	if(direction == "p") { clr = LimeGreen; code = 233; dir = true; }
	if(direction == "q") { clr = Crimson; code = 234; dir = false; }

	if(candle > 0) drawArrow(candle, clr, code, dir);
	}
}

void OnChartEvent(const int     id, const long&   lparam, const double& dparam, const string& sparam)
{
  long y_subwindow = ChartGetInteger(0, CHART_WINDOW_YDISTANCE, 1);
  double dparam_modif = dparam - (long)y_subwindow;

}

void AddFinder(string sym)
{
  int t = ArraySize(finders);
  if (ArrayResize(finders, t + 1))
  {
    finders[t] = new FinderPattern(sym);
  }
}

void deleteFinders()
{
  for (int i = 0; i < ArraySize(finders); i++)
  {
    delete finders[i];
  }
}

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

// if(tf == "M1" && newCandleM1.IsNewCandle()==false) return;
if(tf == "M5" && newCandleM5.IsNewCandle()==false) return;
if(tf == "M15"&& newCandleM15.IsNewCandle()==false) return;
if(tf == "M30"&& newCandleM30.IsNewCandle()==false) return;
if(tf == "H1" && newCandleH1.IsNewCandle()==false) return;
if(tf == "H4" && newCandleH4.IsNewCandle()==false) return;
if(tf == "D1" && newCandleD1.IsNewCandle()==false) return;
if(tf == "W1" && newCandleW1.IsNewCandle()==false) return;


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
  //  double gap  = iATR(NULL,0,20,i)/2;
   double gap  = 10 * Point();
   
	 datetime tm = iTime(NULL, 0, i);
   ObjectCreate(0, name,OBJ_ARROW,0, tm,0);
   ObjectSetInteger(0, name,OBJPROP_ARROWCODE,theCode);
   ObjectSetInteger(0, name,OBJPROP_COLOR,theColor);
   ObjectSetInteger(0, name,OBJPROP_WIDTH,1);
         
				 if (up)
               ObjectSetDouble(0, name,OBJPROP_PRICE,iLow(NULL, 0, i) - gap);
         else  ObjectSetDouble(0, name,OBJPROP_PRICE,iHigh(NULL, 0, i) + gap);
}


//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
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
