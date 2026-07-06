// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=147068

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

#property indicator_buffers 6
#property indicator_plots   1 
#property indicator_label1  "ColorCandles" 
#property indicator_type1   DRAW_COLOR_CANDLES 
#property indicator_color1  RoyalBlue, Crimson
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- indicator buffers
double line[];

//--- búfers indicadores 
double    buf_open[]; 
double    buf_high[]; 
double    buf_low[]; 
double    buf_close[]; 
double    buf_color[];
double    trend[];
//--- indicator input
input int uPeriod = 10;  // Indicator Periods

int emaHigh;
int emaLow;
// ------------------------------------------------------------------
void OnInit()
{
//--- valor vacío 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0); 
  
	//--- indicator buffers mapping 
   SetIndexBuffer(0,buf_open,INDICATOR_DATA); 
   SetIndexBuffer(1,buf_high,INDICATOR_DATA); 
   SetIndexBuffer(2,buf_low,INDICATOR_DATA); 
   SetIndexBuffer(3,buf_close,INDICATOR_DATA); 
   SetIndexBuffer(4,buf_color,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(5,trend,INDICATOR_CALCULATIONS); 

	//--- EMAS
   emaHigh = iMA(NULL, 0, uPeriod, 0, MODE_SMA, PRICE_HIGH);
   emaLow  = iMA(NULL, 0, uPeriod, 0, MODE_SMA, PRICE_LOW);
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
  // clang-format off
	int start;
  if (prev_calculated > 1) start = prev_calculated - 1; else { start = uPeriod + 1; }
	// clang-format on

  for (int i = start; i < rates_total && !IsStopped(); i++) 
	{
    buf_open[i]  = open[i];
    buf_high[i]  = high[i];
    buf_low[i]   = low[i];
    buf_close[i] = close[i];
		
		// NOTE: set color
    trend[i] = trend[i - 1];    
    if (close[i] > calculate(emaHigh, 0, i+1)) trend[i] = 1;
    if (close[i] < calculate(emaLow, 0, i+1)) trend[i] = 0;
    buf_color[i] = trend[i] == 1 ? 0 : 1;
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