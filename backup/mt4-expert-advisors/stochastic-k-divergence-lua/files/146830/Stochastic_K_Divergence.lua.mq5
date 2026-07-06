// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72537

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
#property version "1.0"
#property indicator_separate_window

#property indicator_buffers 5
#property indicator_plots 5
#property indicator_type1  DRAW_ARROW
#property indicator_color1 Red
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label1 "Line"
#property indicator_type2  DRAW_LINE
#property indicator_color2 LightSeaGreen
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label2 "Linek"
#property  indicator_type3 DRAW_ARROW
#property indicator_color3 Red
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property  indicator_type4 DRAW_ARROW
#property indicator_color4 Green
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property  indicator_type5 DRAW_ARROW
#property indicator_color5 Green
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1

#property indicator_minimum 0 
#property indicator_maximum 100 

//--- indicator buffers
double CurrPeack[];
double PrevPeack[];
double CurrValley[];
double PrevValley[];
double lineK[];
int    _handle;

//--- indicator input
input string         IStoch      = "== Stoch Setup ==";  // == Stoch Setup ==
input int            K_Periods   = 5;                    // K-Periods
input int            D_Periods   = 3;                    // D-Periods
input int            slowing     = 3;                    // Smothed period
input ENUM_MA_METHOD ma_method   = MODE_SMA;             // Average Method
input ENUM_STO_PRICE price_field = STO_LOWHIGH;       // Applied price


// ------------------------------------------------------------------
void OnInit()
{
  SetIndexBuffer(0, CurrPeack, INDICATOR_DATA);
	PlotIndexSetInteger(0, PLOT_ARROW, 234);
  SetIndexBuffer(1, lineK, INDICATOR_DATA);
  SetIndexBuffer(2, PrevPeack, INDICATOR_DATA);
	PlotIndexSetInteger(2, PLOT_ARROW, 115);
  SetIndexBuffer(3, CurrValley, INDICATOR_DATA);
	PlotIndexSetInteger(3, PLOT_ARROW, 233);
  SetIndexBuffer(4, PrevValley, INDICATOR_DATA);
	PlotIndexSetInteger(4, PLOT_ARROW, 115);
	// PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0); 
  IndicatorSetInteger(INDICATOR_DIGITS, 2);
  
	//--- indicator short name
  string short_name = "Stoch Divergences";
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);

  //--- STOCH SETUP
  _handle = iStochastic(NULL, 0, K_Periods, D_Periods, slowing, ma_method, price_field);
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

  int start;
  if (prev_calculated > 1)
    start = prev_calculated - 1;
  else {
    start = K_Periods + 1;
  }


//--- 
  for (int i = start; i < rates_total && !IsStopped(); i++) 
	{
		CurrPeack[i] = EMPTY_VALUE;
		PrevPeack[i] = EMPTY_VALUE;
		PrevValley[i] = EMPTY_VALUE;
		CurrValley[i] = EMPTY_VALUE;
		lineK[i] = K(i);

	  if(isPeack(i))
		{
      int prev    = PrevPeack(i);
			double CurrentPeack = K(i - 1);
			double prevPeack = K(prev);
			
			if( CurrentPeack > prevPeack && high[i-1] <= high[prev] )
			{
				CurrPeack[i - 1] = K(i - 1);
				PrevPeack[prev] = K(prev);
        drawLine(CurrentPeack, prevPeack, i - 1, prev, time[i - 1], time[prev]);
      }
		} 
	  
		if(isValley(i))
		{
      int prev    = PrevValley(i);
			double CurrentValley = K(i - 1);
			double prevValley = K(prev);
			
			if( CurrentValley < prevValley && low[i-1] >= low[prev] )
			{
				CurrValley[i - 1] = K(i - 1);
				PrevValley[prev] = K(prev);
        drawLine(CurrentValley, prevValley, i - 1, prev, time[i - 1], time[prev]);
      }
		} 
  }






//--- 
  return (rates_total);
}

bool isPeack(int i)
{
	if( K(i-1) > K(i-2) && K(i-1) > K(i) && K(i-1) > 80)
	{ 
		return true;
	}
	return false;
}

int PrevPeack(int j)
{
	for(int i=j-K_Periods; i >= 0 ;i--)
	{
		if( K(i-1) > K(i-2) && K(i-1) > K(i) )
		{ 
			return i-1;
		}
	}
  return 0;
}

bool isValley(int i)
{
	if( K(i-1) < K(i-2) && K(i-1) < K(i) && K(i-1) < 20)
	{ 
		return true;
	}
	return false;
}

int PrevValley(int j)
{
	for(int i=j-K_Periods; i >= 0 ;i--)
	{
		if( K(i-1) < K(i-2) && K(i-1) < K(i) )
		{ 
			return i-1;
		}
	}
  return 0;
}



// NOTE: DRAW LINES
// ------------------------------------------------------------------
void drawLine(double pr1, double pr2, int currBar, int prevBar, datetime tm1, datetime tm2 )
{
  string name = "div" + (string)currBar;
  color  clr  = pr1 > pr2 ? Red : Green;
  // ObjectCreate(0, name, OBJ_TREND, 1, tm1, pr1, tm2, pr2);	
  ObjectCreate(0, name, OBJ_TREND, 1, tm2, pr2, tm1, pr1);	
	ObjectSetInteger(0, name, OBJPROP_COLOR,clr); 
}



// NOTE: Stoch
//+------------------------------------------------------------------+

double calculate(int buffer, int shift)
{
  double value[1];
  int    copy = CopyBuffer(_handle, buffer, shift, 1, value);
  if (copy > 0) { return value[0]; }
  //---
  return -1;
}

double K(int shift) { return calculate(0, s(shift)); }
double D(int shift) { return calculate(1, s(shift)); }

int bars() {return Bars(NULL, 0);}
int s(int shi){return bars() - shi;}