// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  |
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

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
// #property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots 0



string file_custom_indicator = "2_bands_cross_mtf";

input string TitleTF = "==== PAIRS ====";  // Set yours timeframes
input bool PERIOD_M1_on = true; // PERIOD_M1 On:
input bool PERIOD_M5_on = true; // PERIOD_M5 On:
input bool PERIOD_M15_on = true; // PERIOD_M15 On:
input bool PERIOD_M30_on = true; // PERIOD_M30 On:
input bool PERIOD_H1_on = true; // PERIOD_H1 On:
input bool PERIOD_H4_on = true; // PERIOD_H4 On:
input bool PERIOD_D1_on = true; // PERIOD_D1 On:
input bool PERIOD_W1_on = true; // PERIOD_W1 On:
// ENUM_TIMEFRAMES TF[8] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1};
ENUM_TIMEFRAMES TF[];

// string headers[9] = {" ", "M1","M5","M15","M30","H1","H4","D1","W1"};
string headers[1]={" "};
int myColumns = 1;
void create_Array_TimeFrames()
{
  if(PERIOD_M1_on)  {myColumns++;  ArrayResize(TF, myColumns-1); TF[myColumns-2]=PERIOD_M1;  ArrayResize(headers, myColumns); headers[myColumns-1]="M1"; }
  if(PERIOD_M5_on)  {myColumns++;  ArrayResize(TF, myColumns-1); TF[myColumns-2]=PERIOD_M5;  ArrayResize(headers, myColumns); headers[myColumns-1]="M5"; }
  if(PERIOD_M15_on) {myColumns++;  ArrayResize(TF, myColumns-1); TF[myColumns-2]=PERIOD_M15; ArrayResize(headers, myColumns); headers[myColumns-1]="M15"; }
  if(PERIOD_M30_on) {myColumns++;  ArrayResize(TF, myColumns-1); TF[myColumns-2]=PERIOD_M30; ArrayResize(headers, myColumns); headers[myColumns-1]="M30"; }
  if(PERIOD_H1_on)  {myColumns++;  ArrayResize(TF, myColumns-1); TF[myColumns-2]=PERIOD_H1;  ArrayResize(headers, myColumns); headers[myColumns-1]="H1"; }
  if(PERIOD_H4_on)  {myColumns++;  ArrayResize(TF, myColumns-1); TF[myColumns-2]=PERIOD_H4;  ArrayResize(headers, myColumns); headers[myColumns-1]="H4"; }
  if(PERIOD_D1_on)  {myColumns++;  ArrayResize(TF, myColumns-1); TF[myColumns-2]=PERIOD_D1;  ArrayResize(headers, myColumns); headers[myColumns-1]="D1"; }
  if(PERIOD_W1_on)  {myColumns++;  ArrayResize(TF, myColumns-1); TF[myColumns-2]=PERIOD_W1;  ArrayResize(headers, myColumns); headers[myColumns-1]="W1"; }
  
}


enum enTimeFrames
{
         tf_cu  = 0,                                                 // Current time frame
         tf_m1  = PERIOD_M1,                                         // 1 minute
         tf_m5  = PERIOD_M5,                                         // 5 minutes
         tf_m15 = PERIOD_M15,                                        // 15 minutes
         tf_m30 = PERIOD_M30,                                        // 30 minutes
         tf_h1  = PERIOD_H1,                                         // 1 hour
         tf_h4  = PERIOD_H4,                                         // 4 hours
         tf_d1  = PERIOD_D1,                                         // Daily
         tf_w1  = PERIOD_W1,                                         // Weekly
         tf_mn1 = PERIOD_MN1,                                        // Monthly
         tf_n1  = -1,                                                // First higher time frame
         tf_n2  = -2,                                                // Second higher time frame
         tf_n3  = -3,                                                // Third higher time frame
         tf_cus = 12345678                                           // Custom time frame
      };
input enTimeFrames       inpTimeFrame           = tf_cu;             // Time frame to use
input int                inpTimeFrameCustom     = 0;                 // Custom time frame to use (if custom time frame used)  
input int                B1Period               = 20;                // First band period
input ENUM_APPLIED_PRICE B1Price                = PRICE_CLOSE;       // First band price
input int                B2Period               = 40;                // Second band period
input ENUM_APPLIED_PRICE B2Price                = PRICE_CLOSE;       // Second band price

// ------------------------------------------------------------------
input string TitlePairs = "==== PAIRS ====";  // Set your pairs
input string uSymbols   = "GBPUSD,EURUSD";    // Symbols (add separate by comma ","):
// ------------------------------------------------------------------

string             Iema            = "== Moving Average Setup ==";  // == Moving Average Setup ==
int                ma1Period       = 50;                            // Period
int                ma1Shift        = 0;                             // Ma Shift
ENUM_MA_METHOD     ma1Method       = MODE_EMA;                      // Method
ENUM_APPLIED_PRICE ma1AppliedPrice = PRICE_CLOSE;                   // Applied Price
int                ma2Period       = 10;                            // Period
int                ma2Shift        = 0;                             // Ma Shift
ENUM_MA_METHOD     ma2Method       = MODE_EMA;                      // Method
ENUM_APPLIED_PRICE ma2AppliedPrice = PRICE_CLOSE;                   // Applied Price

// ------------------------------------------------------------------
input string TZ                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications

// ------------------------------------------------------------------

class MovingAverage
{
  string _symbol;
  int    _tf;

  struct MovingAverageParameters
  {
    int setup0;  //  Period
    int setup1;  //  Ma Shift
    int setup2;  //  Method
    int setup3;  //  Applied Price
  };
  MovingAverageParameters _setup;

 public:
  MovingAverage()
  {
    _symbol = _Symbol;
    _tf     = Period();
  }
  MovingAverage(string Symbol, int TimeFrame)
  {
    _symbol = Symbol;
    _tf     = TimeFrame;
  }
  MovingAverage(string Symbol, int TimeFrame, int period, int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE appliedPrice)
  {
    _symbol = Symbol;
    _tf     = TimeFrame;
    setSetup(period, shift, method, appliedPrice);
  }
  ~MovingAverage() { ; }

  void Set_Symbol_TF(string Symbol, int TimeFrame = 0)
  {
    _symbol = Symbol;
    _tf     = TimeFrame;
  }

  void setSetup(
      int set0,
      int set1,
      int set2,
      int set3)
  {
    _setup.setup0 = set0;
    _setup.setup1 = set1;
    _setup.setup2 = set2;
    _setup.setup3 = set3;
  }

  double calculate(int buffer, int shift)
  {
    return iMA(_symbol, _tf,
               _setup.setup0,
               _setup.setup1,
               _setup.setup2,
               _setup.setup3,
               shift);
  }

  double index(int shift)
  {
    return calculate(0, shift);
  }
};
MovingAverage* maFast;
MovingAverage* maSlow;


#define FindPattern_
#ifdef FindPattern_

class FinderPattern
{
  string _symbol;  // symbol
                   // ENUM_TIMEFRAMES _tf;      // timeframe

 public:
  FinderPattern(string Symbol)
  {
    _symbol = Symbol;
  }
  ~FinderPattern() { ; }

  // busca un patrón de algo y devuelve un codigo de 3 letras que representa:
  // los primeros 2 digitos: vela
  // el ultimo digito: dirección (up = p , dn = q) (por código Ascii)
  string FindPattern(ENUM_TIMEFRAMES _tf)
  {
    for (int i = 1; i < 99; i++)
    {
      string up = "p";
      string dn = "q";
      string candle;

      if (havePatternUp(i, _tf))
      {
        candle = i < 10 ? "0" + (string)i : (string)i;
        return candle + up;
      }
      if (havePatternDn(i, _tf))
      {
        candle = i < 10 ? "0" + (string)i : (string)i;
        return candle + dn;
      }
    }

    return "00V";
  }

  bool havePatternUp(int i, ENUM_TIMEFRAMES tf)
  {
    // TODO: escribir el patrón alcista
    double indiUp = iCustom(_symbol, tf, file_custom_indicator, inpTimeFrame, inpTimeFrameCustom, B1Period, B1Price, B2Period, B2Price, 0, 0);
    if (indiUp == 1) { return true; }
    

   return false;
  }

  bool havePatternDn(int i, ENUM_TIMEFRAMES tf)
  {
    // TODO: escribir el patrón bajista

    double indiDn = iCustom(_symbol, tf, file_custom_indicator, inpTimeFrame, inpTimeFrameCustom, B1Period, B1Price, B2Period, B2Price, 1, 0);
    
    if (indiDn == 1)
    {
        return true;
    }

    return false;
  }

};

#endif FindPattern_
FinderPattern* finders[];

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
  void   Font(string font, int size=9)         { _font = font; canvas.FontSet(_font, size*-10); }
  string Font(void)                            { return _font; }
  void   TextColor(color textColor, int alpha) { _textColor = ColorToARGB(textColor, alpha); }   
  uint   TextColor(void)                       { return _textColor; }

	void  Movable(bool movable)                  { _movable = movable; }
	bool  Movable(void)                          { return _movable; }
	void   WasPressed(bool  wasPressed)          { _wasPressed = wasPressed; }
	bool   WasPressed(void)                      { return _wasPressed; }
	void   Move(int y, double limitPrice=0)
	{
		if(!Movable()) return;
		
		if(WasPressed())
		{
	  	// limitar el movimiento
			if(limitPrice==0)
			{
				limitPrice = Bid;
			}
			// int coorAsk= Coordinate(limitPrice);  
			// int coorBid= Coordinate(Bid);  
			
			// int coorAsk= Coordinate(Ask);  
			// int coorBid= Coordinate(Bid);  

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
			// Print(_name, "/ _distanceToMouse: ", _distanceToMouse);

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

			// Print("_distanceToMouse: ", _distanceToMouse);

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
  CButtonFlat _rows[][10];
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
          // ChartSetSymbolPeriod(0, _rows[i, 0].Text(), PERIOD_CURRENT);
        }
      }

      // clang-format off
			// for (int r = 1; r < _nRows; r++)
      // {
				// for (int c = 1; c < _nColumns; c++) {
	        // if(_rows[r, c].Name() == sparam) {
						// if(c == 1)  {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_M1  );break;}
						// if(c == 2)  {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_M5  );break;}
						// if(c == 3)  {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_M15 );break;}
						// if(c == 4)  {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_M30 );break;}
						// if(c == 5) {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_H1  );break;}
						// if(c == 6) {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_H4  );break;}
						// if(c == 7) {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_D1  );break;}
						// if(c == 8) {ChartSetSymbolPeriod(0,_rows[r, 0].Text(),PERIOD_W1  );break;}
	       	// }
        // }
      // }
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
    nColumns(myColumns);
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
        if (i > 0)_rows[i, j].Font("Wingdings 3", 8);
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
      for (int j = 0; j < myColumns; j++)
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

  double temp = iCustom(NULL, 0, file_custom_indicator, 0, 0);
  if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
  {
    Alert("Please, install the: " + file_custom_indicator + " indicator, in folder MQL4/Indicators");
    return INIT_FAILED;
  }
  create_Array_TimeFrames();
  ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1, true);
  
	// NOTE: Emas ini	
	// maSlow = new MovingAverage();
    // maSlow.setSetup(ma1Period, ma1Shift, ma1Method, ma1AppliedPrice);
    // maFast = new MovingAverage();
    // maFast.setSetup(ma2Period, ma2Shift, ma2Method, ma2AppliedPrice);

	symbols = new SymbolsList(uSymbols);

  for (int i = symbols.ini(); i < symbols.qnt(); i = symbols.next())
  {
    AddFinder(symbols.currentSymbol());
  }

  CreateTable();

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
//   string headers[17] = {" ", "M1"," ", "M5"," ", "M15"," ", "M30"," ", "H1"," ", "H4"," ", "D1"," ", "W1"," "};
  
  // tienen que ser los que realmente se eligieron
  // string headers[9] = {" ", "M1","M5","M15","M30","H1","H4","D1","W1"};
  
  table.setHeaders(headers);
  table.setRowNames(symbols._symbols);
  table.Refresh();
}

// NOTE: deinit
void OnDeinit(const int Reason)
{
	ObjectsDeleteAll(0, "arrow");
  delete symbols;
  deleteFinders();
	delete maSlow;
	delete maFast;
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
 
	 doActions(); 
	 NotifyControl();
  
	return (rates_total);
}

void doActions()
{
	// clang-format off
	for(int i=0; i < ArraySize(finders); i++)
	{
		string patternDirection[]; ArrayResize(patternDirection, ArraySize(TF));
		string results[]; ArrayResize(results, ArraySize(TF));
	
		for (int j = 0; j < ArraySize(TF); j++) 
		{
			string patCode = finders[i].FindPattern(TF[j]);	
			patternDirection[j] = StringSubstr(patCode,2,1);
		}
		
		for(int n = 0; n < ArraySize(TF) ; n++)
		{
	 		int pos = n; results[n] = patternDirection[pos];
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

	// Print("candle: ", candle);
	if(Period() == PERIOD_M1 ) direction = table.getValue(rowSymbol, 1) ;
	if(Period() == PERIOD_M5 ) direction = table.getValue(rowSymbol, 2) ;
	if(Period() == PERIOD_M15) direction = table.getValue(rowSymbol, 3) ;
	if(Period() == PERIOD_M30) direction = table.getValue(rowSymbol, 4) ;
	if(Period() == PERIOD_H1 ) direction = table.getValue(rowSymbol, 5) ;
	if(Period() == PERIOD_H4 ) direction = table.getValue(rowSymbol, 6);
	if(Period() == PERIOD_D1 ) direction = table.getValue(rowSymbol, 7);
	if(Period() == PERIOD_W1 ) direction = table.getValue(rowSymbol, 8);

	// Print("direction: ", direction);
	// dibujar la flecha  
	color clr;
	int code;
	bool dir;
	if(direction == "p") { clr = LimeGreen; code = 233; dir = true; }
	if(direction == "q") { clr = Crimson; code = 234; dir = false; }

	// drawArrow(candle, clr, code, dir);
	}
}

void OnChartEvent(const int     id, const long&   lparam, const double& dparam, const string& sparam)
{
  double y_subwindow = ChartGetInteger(0, CHART_WINDOW_YDISTANCE, 1);
  double dparam_modif = dparam - (long)y_subwindow;

  table.OnEvent(id, lparam, dparam_modif, sparam);

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
    
		for (int c = 1; c <=  ArraySize(TF)-1; c++)
    {
			  value = table.cellText(r, c);
        string sym = table.cellText(r, 0);
        if (value == "p" && StringToInteger(table.cellText(r, c+1))==1) Notifications(0, sym, table.cellText(0, c));
        if (value == "q" && StringToInteger(table.cellText(r, c+1))==1) Notifications(1, sym, table.cellText(0, c));
    }
  }
}

// clang-format off
void Notifications(int type, string sym, string tf)
{
  if (!notifications) return;

if(tf == "M1" && newCandleM1.IsNewCandle()==false) return;
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



// ------------------------------------------------------------------

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