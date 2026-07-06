// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72988

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
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots 8

#property indicator_label1 "TPB 1"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "TPB 2"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrLimeGreen
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "TPS 1"
#property indicator_type3  DRAW_LINE
#property indicator_color3 clrGreen
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "TPS 2"
#property indicator_type4  DRAW_LINE
#property indicator_color4 clrLimeGreen
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1

#property indicator_label5 "SLB 1"
#property indicator_type5  DRAW_LINE
#property indicator_color5 clrOrange
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_label6 "SLB 2"
#property indicator_type6  DRAW_LINE
#property indicator_color6 clrRed
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_label7 "SLS 1"
#property indicator_type7  DRAW_LINE
#property indicator_color7 clrOrange
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_label8 "SLS 2"
#property indicator_type8  DRAW_LINE
#property indicator_color8 clrRed
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1

//--- indicator buffers
double TPB1[], TPB2[], TPS1[], TPS2[];
double SLB1[], SLB2[], SLS1[], SLS2[];

enum Mode {
  History,        // History
  Last,           // Last Value
  Last_all_chart  // Extend Last Value
};

// NOTE: inputs
// ------------------------------------------------------------------
input string          T0                    = "== ATR setup ==";      // ————————————
input ENUM_TIMEFRAMES uTF                   = PERIOD_D1;              // TimeFrame:
input int             uPeriod               = 14;                     // ATR period:
input int             endCalc               = 100;                    // Candles to Max and Min:
input double          multiplier            = 2;                      // TPBS Multiplier:
input string          Tperiods              = "== Set Mode ==";       // ————————————
input Mode            mode                  = History; // Mode:
input string          T2                    = "== Set Lines ==";      // ————————————
input bool            TPB_On                = true;                   // TPB On?
input bool            TPS_On                = true;                   // TPS On?
input bool            SLB_On                = true;                   // SLB On?
input bool            SLS_On                = true;                   // SLS On?
input color           TPB1_clr              = clrGreen;               // TPB1 color:
input color           TPB2_clr              = clrLimeGreen;           // TPB2 color:
input color           TPS1_clr              = clrGreen;               // TPS1 color:
input color           TPS2_clr              = clrLimeGreen;           // TPS2 color:
input color           SLB1_clr              = clrOrange;              // SLB1 color:
input color           SLB2_clr              = clrRed;                 // SLB2 color:
input color           SLS1_clr              = clrOrange;              // SLS1 color:
input color           SLS2_clr              = clrRed;                 // SLS2 color:
input string          Tstyle                = "== Lines style ==";    // ————————————
input ENUM_LINE_STYLE TPB_style             = STYLE_SOLID;            // TPB style:
input ENUM_LINE_STYLE TPS_style             = STYLE_SOLID;            // TPS style:
input ENUM_LINE_STYLE SLB_style             = STYLE_SOLID;            // SLB style:
input ENUM_LINE_STYLE SLS_style             = STYLE_SOLID;            // SLS style:
input string          Twidth                = "== Lines width ==";    // ————————————
input int             TPB_width             = 1;                      // TPB width:
input int             TPS_width             = 1;                      // TPS width:
input int             SLB_width             = 1;                      // SLB width:
input int             SLS_width             = 1;                      // SLS width:

string          T1                    = "== Notifications ==";  // ————————————
bool            notifications         = false;                  // Notifications On?
bool            desktop_notifications = false;                  // Desktop MT4 Notifications
bool            email_notifications   = false;                  // Email Notifications
bool            push_notifications    = false;                  // Push Mobile Notifications
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
int OnInit()
{
  // clang-format off
  //--- indicator buffers mapping
  SetIndexBuffer(0, TPB1, INDICATOR_DATA); SetIndexStyle(0, DRAW_LINE, TPB_style, TPB_width, TPB1_clr);
  SetIndexBuffer(1, TPB2, INDICATOR_DATA); SetIndexStyle(1, DRAW_LINE, TPB_style, TPB_width, TPB2_clr);
  SetIndexBuffer(2, TPS1, INDICATOR_DATA); SetIndexStyle(2, DRAW_LINE, TPS_style, TPS_width, TPS1_clr);
  SetIndexBuffer(3, TPS2, INDICATOR_DATA); SetIndexStyle(3, DRAW_LINE, TPS_style, TPS_width, TPS2_clr);
	SetIndexBuffer(4, SLB1, INDICATOR_DATA); SetIndexStyle(4, DRAW_LINE, SLB_style, SLB_width, SLB1_clr);
  SetIndexBuffer(5, SLB2, INDICATOR_DATA); SetIndexStyle(5, DRAW_LINE, SLB_style, SLB_width, SLB2_clr);
  SetIndexBuffer(6, SLS1, INDICATOR_DATA); SetIndexStyle(6, DRAW_LINE, SLS_style, SLS_width, SLS1_clr);
  SetIndexBuffer(7, SLS2, INDICATOR_DATA); SetIndexStyle(7, DRAW_LINE, SLS_style, SLS_width, SLS2_clr);


if(!TPB_On) 
{
    SetIndexStyle(0, DRAW_NONE);
    SetIndexStyle(1, DRAW_NONE);
}
if(!TPS_On)
{
	SetIndexStyle(2, DRAW_NONE);
	SetIndexStyle(3, DRAW_NONE);
}
if(!SLB_On)
{
	SetIndexStyle(4, DRAW_NONE);
	SetIndexStyle(5, DRAW_NONE);
}
if(!SLS_On)
{
	SetIndexStyle(6, DRAW_NONE);
	SetIndexStyle(7, DRAW_NONE);
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
  int start, i;
  if (prev_calculated == 0)
  {
    // start = rates_total - endCalc-uPeriod;
    start = 1000;
  } else
  {
    start = rates_total - (prev_calculated - 1);
  }

	ENUM_TIMEFRAMES TFsup = uTF;
	if(uTF < Period()) TFsup = Period();
  
	if(mode == History)
	for (i = start; i >= 0; i--)
  {
		TPB1[i] = TPB1[i+1];
		TPB2[i] = TPB2[i+1];
		TPS1[i] = TPS1[i+1];
		TPS2[i] = TPS2[i+1];
		SLB1[i] = SLB1[i+1];
		SLB2[i] = SLB2[i+1];
		SLS1[i] = SLS1[i+1];
		SLS2[i] = SLS2[i+1];

			int i_TFsup = iBarShift(NULL, TFsup, time[i],false);
			TPB1[i] = iLow(NULL, TFsup, i_TFsup)+(minATR(i_TFsup)*multiplier);
			TPB2[i] = iLow(NULL, TFsup, i_TFsup)+(maxATR(i_TFsup)*multiplier);
			SLB1[i] = iLow(NULL, TFsup, i_TFsup)-(minATR(i_TFsup)*multiplier);
			SLB2[i] = iLow(NULL, TFsup, i_TFsup)-(maxATR(i_TFsup)*multiplier);

			TPS1[i] = iHigh(NULL, TFsup, i_TFsup)-(minATR(i_TFsup)*multiplier);
			TPS2[i] = iHigh(NULL, TFsup, i_TFsup)-(maxATR(i_TFsup)*multiplier);
			SLS1[i] = iHigh(NULL, TFsup, i_TFsup)+(minATR(i_TFsup)*multiplier);
			SLS2[i] = iHigh(NULL, TFsup, i_TFsup)+(maxATR(i_TFsup)*multiplier);
  }
	
	if(mode == Last)
	for (i = 0; i < 10; i++)
  {
		if(i > 0)
		{
		TPB1[i] = TPB1[i-1];
		TPB2[i] = TPB2[i-1];
		TPS1[i] = TPS1[i-1];
		TPS2[i] = TPS2[i-1];
		SLB1[i] = SLB1[i-1];
		SLB2[i] = SLB2[i-1];
		SLS1[i] = SLS1[i-1];
		SLS2[i] = SLS2[i-1];
		}
			
			if(i ==0)
			{
			int i_TFsup = iBarShift(NULL, TFsup, time[i],false);
			TPB1[i] = iLow(NULL, TFsup, i_TFsup)+(minATR(i_TFsup)*multiplier);
			TPB2[i] = iLow(NULL, TFsup, i_TFsup)+(maxATR(i_TFsup)*multiplier);
			SLB1[i] = iLow(NULL, TFsup, i_TFsup)-(minATR(i_TFsup)*multiplier);
			SLB2[i] = iLow(NULL, TFsup, i_TFsup)-(maxATR(i_TFsup)*multiplier);

			TPS1[i] = iHigh(NULL, TFsup, i_TFsup)-(minATR(i_TFsup)*multiplier);
			TPS2[i] = iHigh(NULL, TFsup, i_TFsup)-(maxATR(i_TFsup)*multiplier);
			SLS1[i] = iHigh(NULL, TFsup, i_TFsup)+(minATR(i_TFsup)*multiplier);
			SLS2[i] = iHigh(NULL, TFsup, i_TFsup)+(maxATR(i_TFsup)*multiplier);
			}
  }
	
	if(mode == Last_all_chart)
	for (i = 0; i < start; i++)
  {
		if(i > 0)
		{
		TPB1[i] = TPB1[i-1];
		TPB2[i] = TPB2[i-1];
		TPS1[i] = TPS1[i-1];
		TPS2[i] = TPS2[i-1];
		SLB1[i] = SLB1[i-1];
		SLB2[i] = SLB2[i-1];
		SLS1[i] = SLS1[i-1];
		SLS2[i] = SLS2[i-1];
		}

		if(i ==0)
		{	
			int i_TFsup = iBarShift(NULL, TFsup, time[i],false);
			TPB1[i] = iLow(NULL, TFsup, i_TFsup)+(minATR(i_TFsup)*multiplier);
			TPB2[i] = iLow(NULL, TFsup, i_TFsup)+(maxATR(i_TFsup)*multiplier);
			SLB1[i] = iLow(NULL, TFsup, i_TFsup)-(minATR(i_TFsup)*multiplier);
			SLB2[i] = iLow(NULL, TFsup, i_TFsup)-(maxATR(i_TFsup)*multiplier);

			TPS1[i] = iHigh(NULL, TFsup, i_TFsup)-(minATR(i_TFsup)*multiplier);
			TPS2[i] = iHigh(NULL, TFsup, i_TFsup)-(maxATR(i_TFsup)*multiplier);
			SLS1[i] = iHigh(NULL, TFsup, i_TFsup)+(minATR(i_TFsup)*multiplier);
			SLS2[i] = iHigh(NULL, TFsup, i_TFsup)+(maxATR(i_TFsup)*multiplier);
		}
  }





    return (rates_total);
}

// ------------------------------------------------------------------


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

double ATR(int index)
{
	return iATR(NULL, uTF, uPeriod, index);
}
double minATR(int index)
{
	double minAtr=0;
	for(int i=index;i < index+endCalc; i++)
	{
		 if(minAtr == 0 || ATR(i)<minAtr)
		 {
			minAtr = ATR(i);
		 }
	}
	return minAtr;
}
double maxATR(int index)
{
	double maxAtr=0;
	for(int i=index;i < index+endCalc; i++)
	{
		 if(maxAtr == 0 || ATR(i)>maxAtr)
		 {
			maxAtr = ATR(i);
		 }
	}
	return maxAtr;
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