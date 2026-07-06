//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73871

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
 
#property indicator_separate_window

#property indicator_buffers 3
#property indicator_plots 2
#property indicator_type1  DRAW_LINE
#property indicator_color1 LightSeaGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label1 "Up"
#property indicator_type2  DRAW_LINE
#property indicator_color2 Crimson
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label2 "Dn"

//--- indicator buffers
double LineUp[];
double LineDn[];
double Data[];

//--- indicator input
input int Period = 10;  // Indicator Periods

// ------------------------------------------------------------------
void OnInit()
{
  //--- indicator short name
  string short_name = "Line Indicator";
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
  PlotIndexSetString(0, PLOT_LABEL, short_name);
  IndicatorSetInteger(INDICATOR_DIGITS, 2);
  
	//--- Buffers 
	SetIndexBuffer(0, LineUp);
  PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Period);
  SetIndexBuffer(1, LineDn);
  PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, Period);
  SetIndexBuffer(2, Data);
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
  if (prev_calculated > 1) start = prev_calculated - 1; else { start = Period + 1; }

  for(int i = start; i < rates_total && !IsStopped(); i++)
  {
        Data[i] = Data[i - 1];
        LineDn[i] = LineDn[i - 1];
        LineUp[i] = LineUp[i - 1];

        if(low[i] > high[i - 2])
        {
            if(Data[i - 1]>0)
                Data[i] += low[i] - high[i - 2];
            else
                Data[i] = low[i] - high[i - 2];

            LineUp[i]     = Data[i];
            LineUp[i - 1] = Data[i - 1];
            LineDn[i]     = EMPTY_VALUE;

            // if(newCandle.IsNewCandle())
            // {
            //     Notifications(0);
            // }
        }

        if(high[i] < low[i - 2])
        {
            if(Data[i-1]<0)
                Data[i] += high[i] - low[i - 2];
            else
                Data[i] = high[i] - low[i - 2];
                
            LineDn[i] = Data[i];
            LineDn[i - 1] = Data[i - 1];
            LineUp[i] = EMPTY_VALUE;

            // if(newCandle.IsNewCandle())
            // {
            //     Notifications(1);
            // }
        }
  }

  return (rates_total);
}
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