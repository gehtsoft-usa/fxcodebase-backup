// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71897

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
#property indicator_plots 4
#property indicator_label1 "Sess Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Sess Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "BD Up"
#property indicator_type3  DRAW_ARROW
#property indicator_color3 clrBlack
#property indicator_style3 STYLE_SOLID
#property indicator_width3 2
#property indicator_label4 "BD Down"
#property indicator_type4  DRAW_ARROW
#property indicator_color4 clrBlack
#property indicator_style4 STYLE_SOLID
#property indicator_width4 2

#property indicator_label7 "side"

//--- indicator buffers
double CrossUpSess[];
double CrossDnSess[];
double CrossUpBD[];
double CrossDnBD[];
double CurrentSess[];
double CurrentBD[];
double CurrentSide[];
int    _fma1, _sma1, _fma2, _sma2;
color  ArrowUpClr            = clrBlue;                // Arrow Up Color:
color  ArrowDnClr            = clrRed;                 // Arrow Down Color:
color  ArrowBDClr            = clrBlack;               // Arrow BD:

// NOTE: Inputs
// ------------------------------------------------------------------
input string TEma                  = "== Set Emas ==";     // Set Emas
input int FastEMA1 = 3;
input int SlowEMA1 = 50;
input int FastEMA2 = 20;
input int SlowEMA2 = 100;
input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications

// NOTE: Objects
// ------------------------------------------------------------------
class CNewCandle
{
 private:
  int             _initialCandles;
  string          _symbol;
  ENUM_TIMEFRAMES _tf;

 public:
  CNewCandle(string symbol, ENUM_TIMEFRAMES tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
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
    if (_currentCandles > _initialCandles) {
      _initialCandles = _currentCandles;
      return true;
    }

    return false;
  }
};
CNewCandle newCandle();

// NOTE: OnInit
// ------------------------------------------------------------------
int OnInit()
{
  SetIndexBuffer(0, CrossUpSess, INDICATOR_DATA);
  PlotIndexSetInteger(0, PLOT_ARROW, 233);
  PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 10);
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, ArrowUpClr);

  SetIndexBuffer(1, CrossDnSess, INDICATOR_DATA);
  PlotIndexSetInteger(1, PLOT_ARROW, 234);
  PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -10);
  PlotIndexSetInteger(1, PLOT_LINE_COLOR, ArrowDnClr);
  
	SetIndexBuffer(2, CrossUpBD, INDICATOR_DATA);
  PlotIndexSetInteger(2, PLOT_ARROW, 233);
  PlotIndexSetInteger(2, PLOT_ARROW_SHIFT, 20);
  PlotIndexSetInteger(2, PLOT_LINE_COLOR, ArrowBDClr);

  SetIndexBuffer(3, CrossDnBD, INDICATOR_DATA);
  PlotIndexSetInteger(3, PLOT_ARROW, 234);
  PlotIndexSetInteger(3, PLOT_ARROW_SHIFT, -20);
  PlotIndexSetInteger(3, PLOT_LINE_COLOR, ArrowBDClr);
  
	SetIndexBuffer(4, CurrentSess, INDICATOR_CALCULATIONS);
  SetIndexBuffer(5, CurrentBD, INDICATOR_CALCULATIONS);
  SetIndexBuffer(6, CurrentSide, INDICATOR_CALCULATIONS);


_fma1 = iMA(NULL, 0, FastEMA1, 0, MODE_EMA, PRICE_CLOSE);
_sma1 = iMA(NULL, 0, SlowEMA1, 0, MODE_EMA, PRICE_CLOSE);
_fma2 = iMA(NULL, 0, FastEMA2, 0, MODE_EMA, PRICE_CLOSE);
_sma2 = iMA(NULL, 0, SlowEMA2, 0, MODE_EMA, PRICE_CLOSE);


  return (INIT_SUCCEEDED);
}

// NOTE: OnCalculate
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
  int i, start;


  start = 1;
  if (prev_calculated > 1) start = prev_calculated - 1;
  for (i = start; i < rates_total && !IsStopped(); i++) 
	{
  	if(i>=2)
		{
			CurrentSess[i - 1] = CurrentSess[i - 2];
  		CurrentBD[i - 1] = CurrentBD[i - 2];
		}
    
		if (haveSignalSessUp(i)) {
      CrossUpSess[i-1] = low[i-1];
      CurrentSess[i-1]   = 0;
      if (newCandle.IsNewCandle()) {
        Notifications(0);
      }
    }

    if (haveSignalSessDown(i)) {
      CrossDnSess[i-1] = high[i-1];
			CurrentSess[i-1]   = 1;
      if (newCandle.IsNewCandle()) {
        Notifications(1);
      }
    }

    if (haveSignalBD_Up(i)) {
      CrossUpBD[i-1] = low[i-1];
      CurrentBD[i-1]   = 0;
      if (newCandle.IsNewCandle()) {
        Notifications(0);
      }
    }
		
		if (haveSignalBD_Down(i)) {
      CrossDnBD[i-1] = high[i-1];
			CurrentBD[i-1]   = 1;
      if (newCandle.IsNewCandle()) {
        Notifications(1);
      }
    }

    if(i>2)CurrentSide[i-1] = CurrentSide[i-2];
    if (CurrentSess[i-1] == 0 && CurrentBD[i-1] == 0) { CurrentSide[i-1] = 0; }
    if (CurrentSess[i-1] == 1 && CurrentBD[i-1] == 1) { CurrentSide[i-1] = 1; }
  
	
	// Print(
  //     "currentSess: ", CurrentSess[i-1], "\n",
  //     "currentBd: ", CurrentBD[i-1], "\n",
  //     "Current Side: ", CurrentSide[i-1]);
	
  }
	


  return (rates_total);
}
//+------------------------------------------------------------------+

bool haveSignalSessUp(int i)
{
  // TODO: signal up

  int shift = iBars(_Symbol, Period()) - i ;
  double fma1_prev = calculate(0, shift+1, _fma1);
  double sma1_prev = calculate(0, shift+1, _sma1);
  double fma1_now = calculate(0, shift, _fma1);
  double sma1_now = calculate(0, shift, _sma1);

if(fma1_prev < sma1_prev &&  fma1_now > sma1_now)
{
	return true;
}

  return false;
}

bool haveSignalSessDown(int i)
{
  // TODO: signal down
	int shift = iBars(_Symbol, Period()) - i;
  double fma1_prev = calculate(0, shift+1, _fma1);
  double sma1_prev = calculate(0, shift+1, _sma1);
  double fma1_now = calculate(0, shift, _fma1);
  double sma1_now = calculate(0, shift, _sma1);

if(fma1_prev >= sma1_prev &&  fma1_now < sma1_now)
{
	return true;
}

  return false;
}

bool haveSignalBD_Up(int i)
{
	int shift = iBars(_Symbol, Period()) - i;
  double fma2_prev = calculate(0, shift+1, _fma2);
  double sma2_prev = calculate(0, shift+1, _sma2);
  double fma2_now = calculate(0, shift, _fma2);
  double sma2_now = calculate(0, shift, _sma2);

if(fma2_prev <= sma2_prev &&  fma2_now > sma2_now)
{
	return true;
}
	
	return false;	
}
bool haveSignalBD_Down(int i)
{
		int shift = iBars(_Symbol, Period()) - i;
  double fma2_prev = calculate(0, shift+1, _fma2);
  double sma2_prev = calculate(0, shift+1, _sma2);
  double fma2_now = calculate(0, shift, _fma2);
  double sma2_now = calculate(0, shift, _sma2);

if(fma2_prev >= sma2_prev && fma2_now < sma2_now)
{
	return true;
}
	return false;
}

double calculate(int buffer, int shift, int handle)
  {
    double value[1];
    int    copy = CopyBuffer(handle, buffer, shift, 1, value);
    if (copy > 0) { return value[0]; }
    //---
    return -1;
  }

void Notifications(int type)
{
  string text = "";
  if (type == 0)
    text += _Symbol + " " + GetTimeFrame(_Period) + " Signal UP ";
  else
    text += _Symbol + " " + GetTimeFrame(_Period) + " Signal DOWN ";

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
  switch (lPeriod) {
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
