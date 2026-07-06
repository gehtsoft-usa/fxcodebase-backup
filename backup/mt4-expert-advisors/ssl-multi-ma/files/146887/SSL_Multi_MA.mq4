// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72480

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
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




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
 
#property version "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_label1 "Line Up"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Line Down"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
//--- Arrows
#property indicator_label3 "Arrow Up"
#property indicator_label4 "Arrow Down"
//--- indicator buffers
double LineUp[];
double LineDn[];
double bufMaHighs[];
double bufMaLows[];
double trend[];
double ArrowUp[];
double ArrowDn[];

#define def_MA
#ifdef def_MA

interface iMovingAverages
{
  double index(int shift);
};
enum MA_METHOD {
  Simple,
  Exponential,
  Smoothed,
  Weighted,
  TEMA,
  DEMA,
};
class MaSelector : public iMovingAverages
{
   iMovingAverages* _ma;

  public:
   MaSelector(MA_METHOD method, string symbol, ENUM_TIMEFRAMES tf, int Period, ENUM_APPLIED_PRICE AppliedPrice, double Speed=0)
   {
      switch(method)
      {
         case Simple:      _ma = new SMA_algo     (symbol, tf, Period, AppliedPrice); break;
         case Exponential: _ma = new EMA_algo     (symbol, tf, Period, AppliedPrice); break;
         case Smoothed:    _ma = new Smoothed_algo(symbol, tf, Period, AppliedPrice); break;
         case Weighted:    _ma = new Weighted_algo(symbol, tf, Period, AppliedPrice); break;
         case TEMA:        _ma = new TEMA_algo    (symbol, tf, Period, AppliedPrice); break;
         case DEMA:        _ma = new DEMA_algo    (symbol, tf, Period, AppliedPrice); break;
      }
   }
   ~MaSelector() { ;}

   double index(int shift) { return _ma.index(shift); }   
};
// clang-format on
class SMA_algo : public iMovingAverages
{
  string             _symbol;
  ENUM_TIMEFRAMES    _tf;
  int                _Period;        //  Period
  int                _MaShift;       //  Ma Shift
  ENUM_APPLIED_PRICE _AppliedPrice;  //  Applied Price

 public:
  SMA_algo(string symbol, ENUM_TIMEFRAMES tf, int Period, ENUM_APPLIED_PRICE AppliedPrice)
  {
    _symbol       = symbol;
    _tf           = tf;
    _Period       = Period;
    _MaShift      = 0;
    _AppliedPrice = AppliedPrice;
  }
  ~SMA_algo() { ; }

  double index(int shift)
  {
    return iMA(_symbol, _tf, _Period, _MaShift, MODE_SMA, _AppliedPrice, shift);
  }
};
class EMA_algo : public iMovingAverages
{
  string             _symbol;
  ENUM_TIMEFRAMES    _tf;
  int                _Period;        //  Period
  int                _MaShift;       //  Ma Shift
  ENUM_APPLIED_PRICE _AppliedPrice;  //  Applied Price

 public:
  EMA_algo(string symbol, ENUM_TIMEFRAMES tf, int Period, ENUM_APPLIED_PRICE AppliedPrice)
  {
    _symbol       = symbol;
    _tf           = tf;
    _Period       = Period;
    _MaShift      = 0;
    _AppliedPrice = AppliedPrice;
  }
  ~EMA_algo() { ; }

  double index(int shift)
  {
    return iMA(_symbol, _tf, _Period, _MaShift, MODE_EMA, _AppliedPrice, shift);
  }
};
class Smoothed_algo : public iMovingAverages
{
  string             _symbol;
  ENUM_TIMEFRAMES    _tf;
  int                _Period;        //  Period
  int                _MaShift;       //  Ma Shift
  ENUM_APPLIED_PRICE _AppliedPrice;  //  Applied Price

 public:
  Smoothed_algo(string symbol, ENUM_TIMEFRAMES tf, int Period, ENUM_APPLIED_PRICE AppliedPrice)
  {
    _symbol       = symbol;
    _tf           = tf;
    _Period       = Period;
    _MaShift      = 0;
    _AppliedPrice = AppliedPrice;
  }
  ~Smoothed_algo() { ; }

  double index(int shift)
  {
    return iMA(_symbol, _tf, _Period, _MaShift, MODE_SMMA, _AppliedPrice, shift);
  }
};
class Weighted_algo : public iMovingAverages
{
  string             _symbol;
  ENUM_TIMEFRAMES    _tf;
  int                _Period;        //  Period
  int                _MaShift;       //  Ma Shift
  ENUM_APPLIED_PRICE _AppliedPrice;  //  Applied Price

 public:
  Weighted_algo(string symbol, ENUM_TIMEFRAMES tf, int Period, ENUM_APPLIED_PRICE AppliedPrice)
  {
    _symbol       = symbol;
    _tf           = tf;
    _Period       = Period;
    _MaShift      = 0;
    _AppliedPrice = AppliedPrice;
  }
  ~Weighted_algo() { ; }

  double index(int shift)
  {
    return iMA(_symbol, _tf, _Period, _MaShift, MODE_LWMA, _AppliedPrice, shift);
  }
};
class TEMA_algo : public iMovingAverages
{
  string             _symbol;
  ENUM_TIMEFRAMES    _tf;
  int                _Period;        //  Period
  int                _MaShift;       //  Ma Shift
  ENUM_APPLIED_PRICE _AppliedPrice;  //  Applied Price

 public:
  TEMA_algo(string symbol, ENUM_TIMEFRAMES tf, int Period, ENUM_APPLIED_PRICE AppliedPrice)
  {
    _symbol       = symbol;
    _tf           = tf;
    _Period       = Period;
    _MaShift      = 0;
    _AppliedPrice = AppliedPrice;
  }
  ~TEMA_algo() { ; }

  double index(int shift)
  {
    return iCustom(_symbol, _tf, "TEMA.ex4", _Period, _AppliedPrice, 0, shift);
  }
};
class DEMA_algo : public iMovingAverages
{
  string             _symbol;
  ENUM_TIMEFRAMES    _tf;
  int                _Period;        //  Period
  int                _MaShift;       //  Ma Shift
  ENUM_APPLIED_PRICE _AppliedPrice;  //  Applied Price

 public:
  DEMA_algo(string symbol, ENUM_TIMEFRAMES tf, int Period, ENUM_APPLIED_PRICE AppliedPrice)
  {
    _symbol       = symbol;
    _tf           = tf;
    _Period       = Period;
    _MaShift      = 0;
    _AppliedPrice = AppliedPrice;
  }
  ~DEMA_algo() { ; }

  double index(int shift)
  {
    return iCustom(_symbol, _tf, "DEMA.ex4", _Period, _AppliedPrice, 0, shift);
  }
};

MaSelector*    maHighs;
MaSelector*    maLows;

input string             Iema           = "== Moving Average Setup ==";  // == Moving Average Setup ==
input int                maPeriod       = 10;                            // Period
input      MA_METHOD     maMethod       = Simple;                        // Method
ENUM_APPLIED_PRICE       maAppliedPrice_High = PRICE_HIGH;                    // Applied Price
ENUM_APPLIED_PRICE       maAppliedPrice_Low  = PRICE_LOW;                    // Applied Price
int                      maShift        = 0;                             // Ma Shift

#endif def_MA

enum eLinesMode {
  OneLineMode,
  TwoLineMode,
};

// ------------------------------------------------------------------
input string T2                    = "== Set Lines ==";      // === Set  Lines ===
input bool   LinesOn               = true;                   // Lines On?
input eLinesMode LinesMode         = TwoLineMode;            // One or Two Lines Mode:
input color  LineUpClr             = clrBlue;                // Line Up Color:
input color  LineDnClr             = clrRed;                 // Line Down Color:
input string T3                    = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color:
input string T1                    = "== Notifications ==";  // === Notifications ===
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications

// ------------------------------------------------------------------

class CCandle
{
   int    _timeFrame;
   string _symbol;
   double _open;
   double _high;
   double _low;
   double _close;
   float  _size;
   string _type;
   string _direction;
   float  _bodySize;
   float  _shadowSup;
   float  _shadowInf;

  public:
   CCandle() { ; }
   CCandle(string sym, int tf) : _symbol(sym), _timeFrame(tf) {}
   ~CCandle() { ; }

   // Getters
   float  Size(void) { return _size; }
   string Type(void) { return _type; }
   double Open(void) { return _open; }
   double High(void) { return _high; }
   double Low(void) { return _low; }
   double Close(void) { return _close; }
   string Direction(void) { return _direction; }
   float  BodySize(void) { return _bodySize; }
   float  ShadowSup(void) { return _shadowSup; }
   float  ShadowInf(void) { return _shadowInf; }

   void setCandle(int shift = 1)
   {
      _open  = iOpen(_symbol, _timeFrame, shift);
      _high  = iHigh(_symbol, _timeFrame, shift);
      _low   = iLow(_symbol, _timeFrame, shift);
      _close = iClose(_symbol, _timeFrame, shift);

      setDirection();
      setSize();
      setBodySize();
      setShadows();
   }
   void setSize()
   {
      _size = 1;
      if (Distance(_high, _low, _symbol) > 0)
      {
         _size = Distance(_high, _low, _symbol);
      }
   }
   void setBodySize()
   {
      _bodySize = 1;
      if (Distance(_open, _close, _symbol) > 0)
      {
         _bodySize = Distance(_open, _close, _symbol);
      }
   }
   void setDirection()
   {
      if (_open < _close)
      {
         _direction = "up";
      }
      if (_open > _close)
      {
         _direction = "down";
      }
      if (_open == _close)
      {
         _direction = "null";
      }
   }
   void PrintCandle()
   {
      Print(__FUNCTION__, " ", "symbol", " ", _symbol);
      Print(__FUNCTION__, " ", "open", " ", _open);
      Print(__FUNCTION__, " ", "high", " ", _high);
      Print(__FUNCTION__, " ", "low", " ", _low);
      Print(__FUNCTION__, " ", "close", " ", _close);
      Print(__FUNCTION__, " ", "_size;", " ", _size);
      Print(__FUNCTION__, " ", "_type;", " ", _type);
      Print(__FUNCTION__, " ", "_direction;", " ", _direction);
      Print(__FUNCTION__, " ", "_bodySize;", " ", _bodySize);
      Print(__FUNCTION__, " ", "_shadowSup;", " ", _shadowSup);
      Print(__FUNCTION__, " ", "_shadowInf;", " ", _shadowInf);
   }
   void setShadows()
   {
      if (Direction() == "up")
      {
         _shadowInf = Distance(_open, _low, _symbol);
         _shadowSup = Distance(_close, _high, _symbol);
      }
      if (Direction() == "down")
      {
         _shadowInf = Distance(_close, _low, _symbol);
         _shadowSup = Distance(_open, _high, _symbol);
      }
      if (Direction() == "null")
      {
         _shadowInf = Distance(_close, _low, _symbol);
         _shadowSup = Distance(_open, _high, _symbol);
      }
   }
   float Distance(double precioA, double precioB, string par)
   {
      double mPoint     = MarketInfo(par, MODE_POINT);
      double dist       = fabs(precioA - precioB);
      double distReturn = 0;
      if (mPoint > 0) distReturn = dist / mPoint;
      return distReturn;
   }
};
CCandle candle1();
CCandle candle2();

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


void OnDeinit()
{
  delete maLows;
  delete maHighs;
}

// ------------------------------------------------------------------
// NOTE: Oninit
int OnInit()
{
   //--- indicator buffers mapping
   SetIndexBuffer(0, LineUp, INDICATOR_DATA);
   SetIndexStyle(0, DRAW_LINE, EMPTY, 1, LineUpClr);
   SetIndexBuffer(1, LineDn, INDICATOR_DATA);
   SetIndexStyle(1, DRAW_LINE, EMPTY, 1, LineDnClr);
	
	// lineas de datos de smahighs smalows
   SetIndexBuffer(4, bufMaHighs, INDICATOR_DATA);
   SetIndexStyle(4, DRAW_NONE, EMPTY, 1, Green);
   SetIndexBuffer(5, bufMaLows, INDICATOR_DATA);
   SetIndexStyle(5, DRAW_NONE, EMPTY, 1, Orange);
   
	if (!LinesOn)
   {
      SetIndexStyle(0, DRAW_NONE);
      SetIndexStyle(1, DRAW_NONE);
      SetIndexStyle(4, DRAW_NONE);
      SetIndexStyle(5, DRAW_NONE);
      SetIndexStyle(6, DRAW_NONE);
   }
	

   SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
   SetIndexArrow(2, 233);
   SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
   SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
   SetIndexStyle(3, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
   SetIndexArrow(3, 234);
   if (!ArrowsOn)
   {
      SetIndexStyle(2, DRAW_NONE);
      SetIndexStyle(3, DRAW_NONE);
   }

   
	SetIndexBuffer(6, trend);
   SetIndexStyle(6, DRAW_NONE);
   //---

   maHighs = new MaSelector(maMethod, _Symbol, 0, maPeriod, maAppliedPrice_High);
   maLows = new MaSelector(maMethod, _Symbol, 0, maPeriod, maAppliedPrice_Low);

   return (INIT_SUCCEEDED);
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

   // clang-format off
	 int i = rates_total - maPeriod;
   if (prev_calculated > 0) i = rates_total - prev_calculated + maPeriod + 1;
   
	 for (; i > 0; i--)
   {
			bufMaHighs[i] = maHighs.index(i);
			bufMaLows[i]  = maLows.index(i);

      trend[i] = trend[i + 1];

      if (close[i + 1] > bufMaHighs[i + 1]) { trend[i] = 1; }
      if (close[i + 1] < bufMaLows[i + 1]) { trend[i] = -1; }

if(LinesMode==TwoLineMode)
{
			if (trend[i] < 0) { LineDn[i] = bufMaHighs[i]; } else { LineDn[i] = bufMaLows[i]; }
			if (trend[i] < 0) { LineUp[i] = bufMaLows[i]; } else { LineUp[i] = bufMaHighs[i]; }

} else 
{
			if (trend[i] < 0) { LineDn[i] = bufMaHighs[i]; } else { LineDn[i] = EMPTY_VALUE; }
			if (trend[i] > 0) { LineUp[i] = bufMaLows[i]; } else { LineUp[i] = EMPTY_VALUE; }
			
			// conections:
			if(trend[i]==1 && trend[i + 1]==-1) { LineDn[i] = bufMaLows[i]; }
			if(trend[i]== -1 && trend[i + 1]==1) { LineUp[i] = bufMaHighs[i]; }
}

      //   crossOvers:
      if (trend[i + 1] == -1 && trend[i] == 1) { ArrowUp[i] = Low[i];  if(newCandle.IsNewCandle())Notifications(0); }
      if (trend[i + 1] == 1 && trend[i] == -1) { ArrowDn[i] = High[i]; if(newCandle.IsNewCandle())Notifications(1); }
  
  // ------------------------------------------------------------------
  
   }

   return (rates_total);
}
// clang-format on
// ------------------------------------------------------------------
void setCandles(int i, int shift)
{
   candle1.setCandle(i + shift);
   candle2.setCandle(i);
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
