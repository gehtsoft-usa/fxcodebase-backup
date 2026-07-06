// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73754

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
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 4

//--- indicator buffers
double ArrowUp[];
double ArrowDn[];
double rsi_line[];
double ma[];

// ------------------------------------------------------------------
input string             Irsi            = "== RSI Setup ==";  // == RSI Setup ==
input int                rsiPeriod       = 14;                 // Period
input ENUM_APPLIED_PRICE rsiAppliedPrice = PRICE_CLOSE;        // Applied Price
input double             rsiLevelUp      = 70;                 // RSI Level Over Bougth
input double             rsiLevelDn      = 30;                 // RSI Level Over Sold
int                rsiCandlesDivergence = 50;            // RSI Candles Divergences
input string             Ima = "== MA Setup ==";  // == MA Setup ==
input int maPeriod = 20; // Periods:
// ------------------------------------------------------------------
input int    periods = 10;
input string T1                    = "== Notifications ==";  // === Notifications ===
input bool   alertOnCross = true;                  // Alerts when lines cross?
input bool   alertOBOn = true;                  // Alerts when over bougth?
input bool   alertOSOn = true;                  // Alerts when over sold?
input bool   notifications         = true;                  // Notifications On?
input bool   desktop_notifications = true;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Lines ==";      // === Set  Lines ===
input bool   LinesOn               = true;                   // Line On?
input color  LineUpClr             = clrGreen;               // Line Up Color:
input color  LineDnClr             = clrRed;                 // Line Down Color:
input string T3                    = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrGreen;               // Arrow Up Color:
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

class RSI
{
   string _symbol;
   int    _tf;
   double _levelUp;
   double _levelDn;

   struct RSIparameters
   {
      int setup0;  //  Period
      int setup1;  //  Applied Price
   };
   RSIparameters _setup;

  public:
   RSI()
   {
      _symbol = Symbol();
      _tf     = Period();
   }

   RSI(string Symbol, int TimeFrame)
   {
      _symbol = Symbol;
      _tf     = TimeFrame;
   }
   ~RSI() { ; }

   void setSetup( int set0, int set1, double LevelUp=70, double LevelDn=30)
   {
      _setup.setup0 = set0;
      _setup.setup1 = set1;
      _levelUp      = LevelUp;
      _levelDn      = LevelDn;
   }

   double calculate(int buffer, int shift)
   {
      return iRSI(_symbol, _tf, _setup.setup0, _setup.setup1, shift);
   }
   
	 double index(int shift)
   {
      return calculate(0, shift);
   }
   double lastValue(int buffer, bool candle = false)
   {
      double value = EMPTY_VALUE;
      int    i     = 0;

      while (value == EMPTY_VALUE || i == 500)
      {
         value = calculate(buffer, i);
         i++;
      }

      if (candle)
      {
         return i;
      }
      return value;
   }
	
	bool isOverBougth(int shift)
	{
		return index(shift)>_levelUp;
    }
	bool isOverSold(int shift)
	{
    return index(shift) < _levelDn;
	}

	bool CrossAbove_LevelUp(int shift)
	{
		if(index(shift)>_levelUp && index(shift+1) <=_levelUp) return true;

		return false;
	}
	bool CrossBelow_LevelUp(int shift)
	{
		if(index(shift)<_levelUp && index(shift+1) >=_levelUp) return true;

		return false;
	}
	
	bool CrossBelow_LevelDn(int shift)
	{
		if(index(shift)<_levelDn && index(shift+1) >=_levelDn) return true;

		return false;
	}
	bool CrossAbove_LevelDn(int shift)
	{
		if(index(shift)>_levelDn && index(shift+1) <=_levelDn) return true;

		return false;
	}

// clang-format off
	bool UpDivergence(int shift)
	{
		// tomar los valores del rsi por x candles		
		// tomar los dos picos minimos que tengas
    double first_down    = 0;
		double second_down   = 0;
		double market_first  = 0;
		double market_second = 0;
		int i, j;
    
		if(second_down==0)
		for(i=shift; i < shift+rsiCandlesDivergence; i++)
		{
			if(index(i+1) < index(i) && index(i+1) < index(i+2))
			{
				if(second_down==0)           { second_down = index(i+1); break;}
			 	if(index(i+1) < second_down) { second_down = index(i+1); break;}
			 }
		}
	
		if(first_down==0)
		for(j=i; j < shift+rsiCandlesDivergence; j++)
		{
			if(index(j+1) < index(j) && index(j+1) < index(j+2)) 
			{
				if(first_down==0)           { first_down = index(j+1);       }
			 	if(index(j+1) < first_down) { first_down = index(j+1); break;}
			}
		}

		// comparar esos 2 valles minimos, el segundo tiene que ser mayor o igual al primero (no hay nuevo min en el indocador)
		if(first_down==0 || second_down==0 || j==51) return false;
		if(first_down > second_down) return false;
		
		// tomar los valores de cierres del mercado en los puntos de los valles del rsi
		market_second = iClose(NULL, 0, i+1);     // tiene que ser un nuevo minimo
		if(market_second >= iClose(NULL, 0, i+2) || market_second >= iClose(NULL, 0, i)) return false;
	
		market_first  = iClose(NULL, 0, j+1);    // minimo anterior...
		if(market_first >= iClose(NULL, 0, j+2) || market_first >= iClose(NULL, 0, j)) return false;

		// ahora los cierres del mercado tienen que ser el segundo inferior al primero (hay nuevo min en el mercado)
		if(market_first <= market_second) return false;

		return true;
	}

	bool DnDivergence(int shift)
	{
		// tomar los valores del rsi por x candles
		// tomar los dos picos minimos que tengas
		// comparar esos 2 valles minimos, el segundo tiene que ser mayor o igual al primero (no hay nuevo min en el indocador)
		// tomar los valores de cierres del mercado en los puntos de los valles del rsi
		// ahora los cierres del mercado tienen que ser el segundo inferior al primero (hay nuevo min en el mercado)


		// tomar los valores del rsi por x candles		
		// tomar los dos picos minimos que tengas
    double first_down    = 0;
		double second_down   = 0;
		double market_first  = 0;
		double market_second = 0;
		int i, j;
    
		if(second_down==0)
		for(i=shift; i < shift+rsiCandlesDivergence; i++)
		{
			if(index(i+1) > index(i) && index(i+1) > index(i+2))
			{
				if(second_down==0)           { second_down = index(i+1); break;}
			 	if(index(i+1) > second_down) { second_down = index(i+1); break;}
			 }
		}
	
		if(first_down==0)
		for(j=i; j < shift+rsiCandlesDivergence; j++)
		{
			if(index(j+1) > index(j) && index(j+1) > index(j+2)) 
			{
				if(first_down==0)           { first_down = index(j+1);       }
			 	if(index(j+1) > first_down) { first_down = index(j+1); break;}
			}
		}

		// comparar esos 2 valles minimos, el segundo tiene que ser mayor o igual al primero (no hay nuevo min en el indocador)
		if(first_down==0 || second_down==0 || j==51) return false;
		if(first_down < second_down) return false;
		
		// tomar los valores de cierres del mercado en los puntos de los valles del rsi
		market_second = iClose(NULL, 0, i+1);     // tiene que ser un nuevo minimo
		if(market_second <= iClose(NULL, 0, i+2) || market_second <= iClose(NULL, 0, i)) return false;
	
		market_first  = iClose(NULL, 0, j+1);    // minimo anterior...
		if(market_first <= iClose(NULL, 0, j+2) || market_first <= iClose(NULL, 0, j)) return false;

		// ahora los cierres del mercado tienen que ser el segundo inferior al primero (hay nuevo min en el mercado)
		if(market_first >= market_second) return false;

		return true;
	}

};
RSI* rsi;
// ------------------------------------------------------------------
int OnInit()
{
  //--- indicator buffers mapping
  SetIndexBuffer(0, rsi_line, INDICATOR_DATA);
  SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 1, LineUpClr);
  SetIndexLabel(0, "Line Up");

  SetIndexBuffer(1, ma, INDICATOR_DATA);
  SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1, LineDnClr);
  SetIndexLabel(1, "Line Dn");

  if (!LinesOn)
  {
    SetIndexStyle(0, DRAW_NONE);
    SetIndexStyle(1, DRAW_NONE);
  }

  SetIndexBuffer(2, ArrowUp, INDICATOR_DATA);
  SetIndexArrow(2, 233);
  SetIndexStyle(2, DRAW_ARROW, EMPTY, 0, ArrowUpClr);
  SetIndexLabel(2, "Arrow Up");

  SetIndexBuffer(3, ArrowDn, INDICATOR_DATA);
  SetIndexStyle(3, DRAW_ARROW, EMPTY, 0, ArrowDnClr);
  SetIndexArrow(3, 234);
  SetIndexLabel(3, "Arrow Dn");

  SetLevelValue(0, rsiLevelUp);
  SetLevelValue(1, 50);
  SetLevelValue(2, rsiLevelDn);
  SetLevelStyle(STYLE_DOT,1,clrDimGray);

  if (!ArrowsOn)
  {
    SetIndexStyle(2, DRAW_NONE);
    SetIndexStyle(3, DRAW_NONE);
  }

  rsi = new RSI();
  rsi.setSetup(rsiPeriod, rsiAppliedPrice, rsiLevelUp, rsiLevelDn);
  
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
  int start, i;
  if (prev_calculated == 0)
  {
    start = rates_total - periods;
  } else
  {
    start = rates_total - (prev_calculated - 1);
  }

  for (i = start; i >= 0; i--)
  {
      rsi_line[i] = value_rsi(i);
      ma[i] = value_moving_average(i);

    if (haveCrossUp(i+1))
    {
        ArrowUp[i + 1] = fmin(rsi_line[i + 1], ma[i + 1]);
        notify(0);
    }

    if (haveCrossDn(i+1))
    {
        ArrowDn[i + 1] = fmax(rsi_line[i + 1], ma[i + 1]);
        notify(1);
    }

    if (isOverBougth(i + 1))notify(2);
    if (isOverSold(i + 1))notify(3);
  }
  return (rates_total);
}

// ------------------------------------------------------------------

double value_rsi(int i)
{
    return rsi.index(i);
}

double value_moving_average(int i)
{
  double sum = 0;
  for (int j = i; j < i+maPeriod; j++)
  {
    sum += rsi.index(j);
  }
  return sum / maPeriod;
}

bool ConditionsToLineUp(int i)
{
  return true;
}

bool ConditionsToLineDn(int i)
{
  return true;
}

bool haveCrossUp(int i)
{
    // TODO: signal up
    if (rsi_line[i] > ma[i] && rsi_line[i+1] <= ma[i+1]) return true;
        
    return false;
}

bool haveCrossDn(int i)
{
  // TODO: signal down
  if (rsi_line[i] < ma[i] && rsi_line[i+1] >= ma[i+1]) return true;
        
    return false;
}

bool isOverBougth(int i)
{
    if (rsi_line[i] > rsiLevelUp) return true;
        
    return false;
}
bool isOverSold(int i)
{
    if (rsi_line[i] < rsiLevelDn) return true;
        
    return false;
}

void notify(int type)
{
  if (newCandle.IsNewCandle())
  {
    Notifications(type);
  }
}

void Notifications(int type)
{
  string text = "";
if(alertOnCross){
  if (type == 0) text += _Symbol + " " + GetTimeFrame(_Period) + " RSI Cross UP";
  if (type == 1) text += _Symbol + " " + GetTimeFrame(_Period) + " RSI Cross DN ";
}
if(alertOBOn) if (type == 2) text += _Symbol + " " + GetTimeFrame(_Period) + " RSI Over Bougth ";
if(alertOSOn) if (type == 3) text += _Symbol + " " + GetTimeFrame(_Period) + " RSI Over Sold ";

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