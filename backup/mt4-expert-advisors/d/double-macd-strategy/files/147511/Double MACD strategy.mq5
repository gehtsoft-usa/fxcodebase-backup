// More information about this indicator can be found at:
// http://fxcodebase.com/ 

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
#property version "1.0"
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_level1 20.0
#property indicator_level2 80.0
#property indicator_level3 50.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT

#property indicator_buffers 6
#property indicator_plots 4

#property indicator_label1 "Arrow Up"
#property  indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property  indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "Line1"
#property  indicator_type3  DRAW_LINE
#property indicator_color3 RoyalBlue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "Line2"
#property  indicator_type4  DRAW_LINE
#property indicator_color4 Yellow
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

// #property indicator_label5 "aux Line1"
// #property  indicator_type5  DRAW_LINE
// #property indicator_color5 RoyalBlue
// #property indicator_style5 STYLE_SOLID
// #property indicator_width5 1
// #property indicator_label6 "auxLine2"
// #property  indicator_type6  DRAW_LINE
// #property indicator_color6 Yellow
// #property indicator_style6 STYLE_SOLID
// #property indicator_width6 1

// NOTE: Inputs
// ------------------------------------------------------------------
input string       macd1_IMACD           = "== MACD 1 Setup ==";   // == MACD 1 Setup ==
input int          macd1_fast_ema_period = 2;                      // fast ema period:
input int          macd1_slow_ema_period = 5;                      // slow ema period:
input int          macd1_signal_period   = 1;                      // signal period:
ENUM_APPLIED_PRICE macd1_applied_price   = PRICE_WEIGHTED;         // applied price:
input string       macd2_IMACD           = "== MACD 2 Setup ==";   // == MACD 2 Setup ==
input int          macd2_fast_ema_period = 5;                      // fast ema period:
input int          macd2_slow_ema_period = 2;                      // slow ema period:
input int          macd2_signal_period   = 1;                      // signal period:
ENUM_APPLIED_PRICE macd2_applied_price   = PRICE_WEIGHTED;         // applied price:
input string       T1                    = "== Notifications ==";  // Notifications
input bool         notifications         = false;                  // Notifications On?
input bool         desktop_notifications = false;                  // Desktop MT4 Notifications
input bool         email_notifications   = false;                  // Email Notifications
input bool         push_notifications    = false;                  // Push Mobile Notifications
input string       T0                    = "== Set Arrows ==";     // Set Arrows
input bool         ArrowsOn              = true;                   // Arrows On?
input color        ArrowUpClr            = clrBlue;                // Arrow Up Color:
input color        ArrowDnClr            = clrRed;                 // Arrow Down Color:
input string       T3                    = "== Set Lines ==";      // === Set  Lines ===
input bool         LinesOn               = true;                   // Line On?
input color        LineUpClr             = RoyalBlue;              // Line Up Color:
input color        LineDnClr             = Yellow;                 // Line Down Color:
// ------------------------------------------------------------------

int Period = 10;  // Indicator Periods

int handle_macd1;
int handle_macd2;

// NOTE: Buffers
//--- indicator buffers
double MACD1[];
double MACD2[];
double ArrowUp[];
double ArrowDn[];
double auxMACD1[];
double auxMACD2[];

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

// ------------------------------------------------------------------
// NOTE: oninit
void OnInit()
{
	     SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
  PlotIndexSetInteger(0, PLOT_ARROW, 233);
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, ArrowUpClr);

       SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
  PlotIndexSetInteger(1, PLOT_ARROW, 234);
  PlotIndexSetInteger(1, PLOT_LINE_COLOR, ArrowDnClr);

  if (!ArrowsOn) {
    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
    PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
  }

  SetIndexBuffer(2, MACD1, INDICATOR_DATA);
  PlotIndexSetInteger(2, PLOT_LINE_COLOR, LineUpClr);
  SetIndexBuffer(3, MACD2, INDICATOR_DATA);
  PlotIndexSetInteger(3, PLOT_LINE_COLOR, LineDnClr);
  if (!LinesOn) {
    PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
    PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
  }

  SetIndexBuffer(4, auxMACD1, INDICATOR_CALCULATIONS);
  SetIndexBuffer(5, auxMACD2, INDICATOR_CALCULATIONS);

  handle_macd1 = iMACD(NULL, 0, macd1_fast_ema_period, macd1_slow_ema_period, 10, macd1_applied_price);
  handle_macd2 = iMACD(NULL, 0, macd2_fast_ema_period, macd2_slow_ema_period, 10, macd2_applied_price);

}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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

  int start; if (prev_calculated > 1) start = prev_calculated - 1; else { start = 0; }

  for (int i = start; i < rates_total && !IsStopped(); i++) {
		auxMACD1[i] = calculate(handle_macd1, 0, i); 
    auxMACD2[i] = calculate(handle_macd2, 0, i); 
  }

  double max = 0;
  double min = 0;
  double recorrido;

  for (int j = 1; j < 1000; j++) {
    int shift = iBars(_Symbol, Period()) - j - 1 ;
		max       = auxMACD1[shift] > max ? auxMACD1[shift] : max;
    min       = auxMACD1[shift] < min ? auxMACD1[shift] : min;
		recorrido = max - min;
  }

  int start2; if (prev_calculated > 1) start2 = prev_calculated - 1; else { start2 = 1; }
  
	for (int p = start2; p < rates_total && !IsStopped(); p++) {
    // Standarization:
    if (recorrido > 0) {
      MACD1[p] = (auxMACD1[p] - min) / recorrido * 100;
      MACD2[p] = (auxMACD2[p] - min) / recorrido * 100;
    }
  }

	int start3; if (prev_calculated > 1) start3 = prev_calculated - 1; else { start3 = 1; }
  
	for (int n = start3; n < rates_total && !IsStopped(); n++) {
    
		ArrowUp[n] = EMPTY_VALUE;
    ArrowDn[n] = EMPTY_VALUE;
    
		if (haveSignalUp(n)) {
        ArrowUp[n] = 5;
        if (newCandle.IsNewCandle()) {
            Notifications(0);
       }
    }

    if (haveSignalDown(n)) {
      ArrowDn[n] = 95;
      if (newCandle.IsNewCandle()) {
        Notifications(1);
      }
    }
  }

  return (rates_total);
}
// ------------------------------------------------------------------

bool haveSignalUp(int i){

	if(i-1 < 0) return false;
	
	if(MACD1[i] > MACD2[i] && MACD1[i-1]<MACD2[i-1]&&MACD1[i]>50)return true;
  if(MACD1[i] > 80 && MACD1[i-1]<=80) return true;
	if(MACD2[i] < 80 && MACD2[i-1]>=80) return true; 

	if(MACD1[i] > 20 && MACD1[i-1]<=20) return true; 
	if(MACD2[i] < 20 && MACD2[i-1]>=20) return true; 
  
	return false;
}

bool haveSignalDown(int i)
{
	if(i-1 < 0) return false;
  
	if(MACD1[i] < MACD2[i] && MACD1[i-1] > MACD2[i-1] && MACD1[i]<50) return true;
	if(MACD1[i] < 80 && MACD1[i-1]>=80) return true;
	if(MACD2[i] > 80 && MACD2[i-1]<=80) return true; 
  
	if(MACD1[i] < 20 && MACD1[i-1]>=20) return true; 
	if(MACD2[i] > 20 && MACD2[i-1]<=20) return true; 


  return false;
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


double calculate(int _handle, int buffer, int _shift)
{
		int shift = iBars(_Symbol, Period()) - _shift - 1 ;
    
		double value[1];
    int    copy = CopyBuffer(_handle, buffer, shift, 1, value);
    if (copy > 0) {
      return value[0];
    }
	return -1;
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