// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72943

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
#property link      "http://fxcodebase.com"
#property version "1.0"

#property strict
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 4
#property indicator_label1 "Pattern 1"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Pattern 2"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Arrow Up"
 #property indicator_type3  DRAW_ARROW
#property indicator_color3 clrBlue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Arrow Down"
 #property indicator_type4  DRAW_ARROW
#property indicator_color4 clrRed
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];
bool   ini;

//--- indicator buffers
double LineUp[];
double LineDn[];

// ------------------------------------------------------------------
input int    periods               = 100;
string T1                    = "== Notifications ==";  // === Notifications ===
bool   notifications         = false;                  // Notifications On?
bool   desktop_notifications = false;                  // Desktop MT4 Notifications
bool   email_notifications   = false;                  // Email Notifications
bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Lines ==";      // === Set  Lines ===
input bool   LinesOn               = true;                   // Line On?
input color  LineUpClr             = clrBlue;                // Line Pattern1 Color:
input color  LineDnClr             = clrRed;                 // Line Pattern2 Color:
input string T3                    = "== Set Arrows ==";     // ————————————
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color:
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
int OnInit()
{
	ini = true;

  //--- indicator buffers mapping
  SetIndexBuffer(0, LineUp, INDICATOR_DATA);
  SetIndexStyle(0, DRAW_LINE, EMPTY, 1, LineUpClr);
  SetIndexBuffer(1, LineDn, INDICATOR_DATA);
  SetIndexStyle(1, DRAW_LINE, EMPTY, 1, LineDnClr);
  if (!LinesOn)
  {
    SetIndexStyle(0, DRAW_NONE);
    SetIndexStyle(1, DRAW_NONE);
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
  //---
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
	 int nCandle = periods;

  ArrowUp[nCandle + 1] = EMPTY_VALUE;
  ArrowDn[nCandle + 1] = EMPTY_VALUE;

  setCandle(nCandle);

  if (newCandle.IsNewCandle() || ini == true)
  {
    ini = false;

		//--- set time candle
    string candleDate = TimeToString(iTime(NULL, 0, nCandle), TIME_DATE);
    string candleTime = TimeToString(iTime(NULL, 0, nCandle), TIME_MINUTES);
    Comment("Candle " + (string)nCandle + " date: " + candleDate + " time: " + candleTime);
	
	if (haveSignalUp(nCandle))
    {
      ArrowUp[nCandle] = Low[nCandle];
    }
    if (haveSignalDown(nCandle))
    {
      ArrowDn[nCandle] = High[nCandle];
    }
  }


//--- 

  int sum1=0;
  int sum2=0;

  for (int i = periods; i >= 0; i--)
  {
    if (havePattern1(i))
    {
      sum1++;
    }
    LineUp[i] = sum1;

    if (havePattern2(i))
    {
      sum2++;
    }
    LineDn[i] = sum2;

  }
    return (rates_total);
}

// ------------------------------------------------------------------
void setCandle(int shift)
{
  candle1.setCandle(shift);
}

bool haveSignalUp(int i)
{
  // TODO: signal up
  if (candle1.Direction() == "up")
  {
    return true;
  }

  return false;
}

bool haveSignalDown(int i)
{
  // TODO: signal down
  if (candle1.Direction() == "down")
  {
    return true;
  }

  return false;
}


bool havePattern1(int i)
{
  // TODO: signal up
double op0 = iOpen(NULL,0,i);
double op1 = iOpen(NULL,0,i+1);
double cl0 = iClose(NULL,0,i);
double cl1 = iClose(NULL,0,i+1);

if ((op0 > cl0 && op1 < cl1) || (op0 < cl0 && op1 > cl1)) return true;

return false;
}

bool havePattern2(int i)
{
  // TODO: signal down
double op0 = iOpen(NULL,0,i);
double op1 = iOpen(NULL,0,i+1);
double op2 = iOpen(NULL,0,i+2);
double cl0 = iClose(NULL,0,i);
double cl1 = iClose(NULL,0,i+1);
double cl2 = iClose(NULL,0,i+2);

if ((op0 > cl0 && op1 < cl1 && op2 > cl2) || (op0 < cl0 && op1 > cl1 && op2 < cl2)) return true;

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