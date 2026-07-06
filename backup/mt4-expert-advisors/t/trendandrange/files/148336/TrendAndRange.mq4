// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72946

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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


#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 6
#property indicator_label1 "Trend Up"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrYellow
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label2 "Trend Down"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2

#property indicator_label3 "Arrow Up"
#property  indicator_type3  DRAW_ARROW
#property indicator_color3 clrYellow
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Arrow Down"
#property  indicator_type4  DRAW_ARROW
#property indicator_color4 clrRed
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
//--- indicator buffers
double ArrowUp[];
double ArrowDn[];

double upTrend[], downTrend[];
double upRange[], dnRange[];
double side[];

enum TrendType { Flexible, Trailing };
// ------------------------------------------------------------------
input TrendType          type           = Flexible; // Trend Type
input bool               showRange      = true; // Show Range:
input string             Iema           = "== Moving Average Setup ==";  // == Moving Average Setup ==
input int                maPeriod       = 10;                            // Period
int                      maShift        = 0;                             // Ma Shift
input ENUM_MA_METHOD     maMethod       = MODE_EMA;                      // Method
ENUM_APPLIED_PRICE maAppliedHighs = PRICE_HIGH;                   // Applied Price
ENUM_APPLIED_PRICE maAppliedLows = PRICE_LOW;                   // Applied Price
input string             Iatr           = "== ATR Setup ==";  // == ATR Setup ==
input int                atrPeriod             = 50; // ATR Period:
input double             atrMultiplier         = 1; // ATR multiplier:
input string T1                    = "== Notifications ==";  // === Notifications ===
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input string Tlines                = "== Set Lines ==";      // === Set  Lines ===
input bool   LinesOn               = true;                   // Line On?
input color  LineUpClr             = clrYellow;              // Line Up Color:
input color  LineDnClr             = clrRed;                 // Line Down Color:
// ------------------------------------------------------------------
input string Tarrows               = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrYellow;              // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color:

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
   MovingAverage(string Symbol, int TimeFrame,int period, int shift, ENUM_MA_METHOD method, ENUM_APPLIED_PRICE appliedPrice)
   {
      _symbol = Symbol;
      _tf     = TimeFrame;
      setSetup(period, shift, method, appliedPrice);
   }
   ~MovingAverage() { ; }

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
MovingAverage maHighs();
MovingAverage maLows();



// ------------------------------------------------------------------
int OnInit()
{
  //--- indicator buffers mapping
  SetIndexBuffer(0, upTrend, INDICATOR_DATA);
  SetIndexStyle(0, DRAW_LINE, EMPTY, 1, LineUpClr);
  SetIndexBuffer(1, downTrend, INDICATOR_DATA);
  SetIndexStyle(1, DRAW_LINE, EMPTY, 1, LineDnClr);
  // SetIndexArrow(0, 233);
  // SetIndexArrow(1, 234);

  if (!LinesOn)
  {
    SetIndexStyle(0, DRAW_NONE);
    SetIndexStyle(1, DRAW_NONE);
  }
  
	SetIndexBuffer(2, upRange, INDICATOR_DATA); 
  SetIndexStyle(2, DRAW_LINE, EMPTY, 1, Black);
	SetIndexBuffer(3, dnRange, INDICATOR_DATA);
  SetIndexStyle(3, DRAW_LINE, EMPTY, 1, Pink);
  if (!showRange)
	{
  	SetIndexStyle(2, DRAW_NONE);
  	SetIndexStyle(3, DRAW_NONE);
	}

  SetIndexBuffer(4, ArrowUp, INDICATOR_DATA);
	 SetIndexArrow(4, 159);
   SetIndexStyle(4, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
  SetIndexBuffer(5, ArrowDn, INDICATOR_DATA);
   SetIndexStyle(5, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
   SetIndexArrow(5, 159);
   if (!ArrowsOn)
   {
      SetIndexStyle(4, DRAW_NONE);
      SetIndexStyle(5, DRAW_NONE);
   }

	SetIndexBuffer(6, side); 
  SetIndexStyle(6, DRAW_NONE);

  maHighs.setSetup(maPeriod, maShift, maMethod, maAppliedHighs);
  maLows.setSetup(maPeriod, maShift, maMethod, maAppliedLows);

  //---
  return (INIT_SUCCEEDED);
}


// clang-format off
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
  int start, i;
  double atr;
  if (prev_calculated == 0) { start = rates_total - maPeriod; } else { start = rates_total - (prev_calculated - 1); }

  for (i = start; i >= 0; i--)
  {
    atr             = iATR(NULL, 0, atrPeriod, i) * atrMultiplier;
    double maLow    = maLows.index(i);
    double maHigh   = maHighs.index(i);
    double minLow   = maLow - atr;
    double minHigh  = maHigh - atr;
    double plusLow  = maLow + atr;
    double plusHigh = maHigh + atr;

    double _upTrend, _upRange, _downTrend, _dnRange;

    _upTrend   = type == Flexible ? minLow   : close[i + 1] > upTrend[i + 1] ? MathMax(minLow, upTrend[i + 1])  : minLow;
    _upRange   = type == Flexible ? minHigh  : close[i + 1] > upRange[i + 1] ? MathMax(minHigh, upRange[i + 1]) : minHigh;
  	_downTrend = type == Flexible ? plusHigh : close[i + 1] < downTrend[i+1] ? MathMin(plusHigh,downTrend[i+1]) : plusHigh;
    _dnRange   = type == Flexible ? plusLow  : close[i + 1] < dnRange[i + 1] ? MathMin(plusLow, dnRange[i + 1]) : plusLow;

    side[i] = side[i + 1];

    int    up    = 1;
    double refup = showRange ? _dnRange : _downTrend;
    if (close[i] > refup) { side[i] = 1; up = 1; } else if (close[i] < _upTrend) { up = -1; }


    int    dn    = 1;
    double refdn = showRange ? _upRange : _upTrend;
    if (close[i] < refdn) { side[i] = -1; dn = 1; } else if (close[i] > _downTrend) { dn = -1; }


    upTrend[i] = EMPTY_VALUE;
    downTrend[i] = EMPTY_VALUE;
		
		// permite las dos lineas a la vez
		if(showRange)
		{
			if( up == 1  ) { upTrend[i]   = _upTrend;     }
    	if( dn == 1 )  { downTrend[i] = _downTrend;   }
		} else 
		{
			if( side[i] == 1  ) { upTrend[i]   = _upTrend;     }
	    if( side[i] == -1 ) { downTrend[i] = _downTrend;   }
		}

		// set circle
		if( upTrend[i+1]  ==EMPTY_VALUE ) { ArrowUp[i] = upTrend[i];   }
		if( downTrend[i+1]==EMPTY_VALUE ) { ArrowDn[i] = downTrend[i]; }

  }
    return (rates_total);
}

// —————————————————————————————————————————————————————————————————————————————

bool haveSignalUp(int i)
{
  // TODO: signal up

  return true;
}

bool haveSignalDown(int i)
{
  // TODO: signal down

  return true;
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


