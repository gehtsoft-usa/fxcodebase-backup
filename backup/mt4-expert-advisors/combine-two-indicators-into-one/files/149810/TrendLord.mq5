// Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=149856

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
#property indicator_char
#property indicator_chart_window

#property indicator_buffers 7
#property indicator_plots   3

#property indicator_label3  "ColorCandles" 
#property  indicator_type3   DRAW_COLOR_CANDLES 
#property indicator_color3  Green, Crimson
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property  indicator_type1   DRAW_LINE
#property indicator_color1  clrBlack
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property  indicator_type2   DRAW_LINE
#property indicator_color2  clrRoyalBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- indicator buffers
double line[];

//--- búfers indicadores 
double    buf_open[]; 
double    buf_high[]; 
double    buf_low[]; 
double    buf_close[]; 
double    buf_color[]; 
double    buf_ma[]; 
double    Array1[]; 

//--- indicator input

input int                maPeriod       = 12;                            // Period
ENUM_MA_METHOD     maMethod       = MODE_SMMA;                     // Method
input ENUM_APPLIED_PRICE maAppliedPrice = PRICE_CLOSE;                   // Applied Price

int hma; // handle MA
int SqLength;
// ------------------------------------------------------------------
void OnInit()
{
	SqLength = MathSqrt(maPeriod);
  //--- indicator buffers mapping 
	 SetIndexBuffer(0,buf_ma,INDICATOR_DATA); 
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
	//  PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 1);
	//  PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrBlack);
	 
	 SetIndexBuffer(1,Array1,INDICATOR_DATA); 
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
	//  PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 1);
	//  PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrRed);

   SetIndexBuffer(2,buf_open,INDICATOR_DATA); 
   SetIndexBuffer(3,buf_high,INDICATOR_DATA); 
   SetIndexBuffer(4,buf_low,INDICATOR_DATA); 
   SetIndexBuffer(5,buf_close,INDICATOR_DATA); 
   SetIndexBuffer(6,buf_color,INDICATOR_COLOR_INDEX); 

   

  //--- valor vacío 
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);

  //  hma = iMA(NULL, 0, Length, 0, Mode, Price);
   hma = iMA(NULL, 0, maPeriod, 0, maMethod, maAppliedPrice);
	 
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
  if (prev_calculated > 1) start = prev_calculated - 1; else { start = maPeriod + 1; }
	// clang-format on

  for (int i = start; i < rates_total && !IsStopped(); i++) 
	{
    buf_ma[i] = SmoothedMA(i, maPeriod, buf_ma[i - 1], close);
    Array1[i] = SmoothedMA(i, SqLength, Array1[i - 1], buf_ma);
    
		buf_open[i]  = SmoothedMA(i, maPeriod, buf_ma[i - 1], close);
    buf_high[i]  = buf_open[i];
    buf_low[i]   = SmoothedMA(i, SqLength, Array1[i - 1], buf_ma);
    buf_close[i] = buf_low[i];

    // NOTE: set color
    if (buf_open[i] > buf_close[i]) { buf_color[i] = 0;
    } else { buf_color[i] = 1; }

  }

  return (rates_total);
}

//+------------------------------------------------------------------+

double index(int handle, int buffer, int shift)
  {
		int    bars   = iBars(NULL, 0);
  	int    _shift = bars - shift-1;
    double value[1];
    
		int    copy = CopyBuffer(handle, buffer, _shift, 1, value);
    
		if (copy > 0) { return value[0]; }
    return -1;
  }

//+------------------------------------------------------------------+
//| Smoothed Moving Average                                          |
//+------------------------------------------------------------------+
double SmoothedMA(const int position,const int period,const double prev_value,const double &price[])
  {
   double result=0.0;
//--- check period
   if(period>0 && period<=(position+1))
     {
      if(position==period-1)
        {
         for(int i=0; i<period; i++)
            result+=price[position-i];

         result/=period;
        }

      result=(prev_value*(period-1)+price[position])/period;
     }

   return(result);
  }

//+------------------------------------------------------------------+
//|  Smoothed moving average on price array                          |
//+------------------------------------------------------------------+
int SmoothedMAOnBuffer(const int rates_total,const int prev_calculated,const int begin,const int period,const double& price[],double& buffer[])
  {
//--- check period
   if(period<=1 || period>(rates_total-begin))
      return(0);
//--- save as_series flags
   bool as_series_price=ArrayGetAsSeries(price);
   bool as_series_buffer=ArrayGetAsSeries(buffer);

   ArraySetAsSeries(price,false);
   ArraySetAsSeries(buffer,false);
//--- calculate start position
   int start_position;

   if(prev_calculated==0)  // first calculation or number of bars was changed
     {
      //--- set empty value for first bars
      start_position=period+begin;

      for(int i=0; i<start_position-1; i++)
         buffer[i]=0.0;
      //--- calculate first visible value
      double first_value=0;

      for(int i=begin; i<start_position; i++)
         first_value+=price[i];

      buffer[start_position-1]=first_value/period;
     }
   else
      start_position=prev_calculated-1;
//--- main loop
   for(int i=start_position; i<rates_total; i++)
      buffer[i]=(buffer[i-1]*(period-1)+price[i])/period;
//--- restore as_series flags
   ArraySetAsSeries(price,as_series_price);
   ArraySetAsSeries(buffer,as_series_buffer);
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
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