// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72809

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
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_plots 1
#property indicator_type1  DRAW_COLOR_LINE
#property indicator_color1 Lime, OrangeRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label1 "LineColor"

//--- indicator buffers
double line[];
double lineColor[];

int cci, atr;// handles
//--- indicator input
input int Period = 10;  // Indicator Periods
input int periodsCCI = 50; // Periods CCI:
input int periodsATR = 5;  // Periods ATR:

// ------------------------------------------------------------------
void OnInit()
{
  //--- indicator short name
  string short_name = "3-bars-high-low-MT5";
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  //--- Buffers
  SetIndexBuffer(0, line, INDICATOR_DATA);
  IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Period);

  SetIndexBuffer(1, lineColor, INDICATOR_COLOR_INDEX);
	//---
  cci = iCCI(NULL, 0, periodsCCI, PRICE_CLOSE);
  atr = iATR(NULL, 0, periodsATR);
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
  if (rates_total < Period) return (0);

  int start;
  if (prev_calculated > 1)
    start = prev_calculated - 1;
  else {
    start = Period + 1;
  }

  for (int i = start; i < rates_total && !IsStopped(); i++) {
    
		double     atrValue = calculate(atr, 0, i);
		double     cciValue = calculate(cci, 0, i);
    int        trend     = cciValue > 0 ? 1 : 0;

    line[i] = line[i - 1];

    if (trend == 1) {
      lineColor[i]   = 0;
      
			double current = low[i] - atrValue;      
			if(current > line[i]){ line[i] = low[i] - atrValue;}
    }
		if(trend == 0)
		{
			lineColor[i]=1;
			
			double current = high[i]+atrValue;
      if (current < line[i]) { line[i] = high[i] + atrValue; }
    }
		
  }

  return (rates_total);
}
//+------------------------------------------------------------------+

double calculate(int handle, int buffer, int i)
{
  int shift = Bars(NULL, 0) - i;
  double value[1];
  int    copy = CopyBuffer(handle, buffer, shift, 1, value);
  if (copy > 0) { return value[0]; }
  //---
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