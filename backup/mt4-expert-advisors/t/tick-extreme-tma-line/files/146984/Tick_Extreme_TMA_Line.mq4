// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72592

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
// ------------------------------------------------------------------
#property strict
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots 7
//--- plot TMA
#property indicator_label1 "TMA"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrDarkGray
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
//--- plot TMA up
#property indicator_label2 "TMA_Up"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrLimeGreen
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2
//--- plot TMA dn
#property indicator_label3 "TMA_Dn"
#property indicator_type3  DRAW_LINE
#property indicator_color3 clrRed
#property indicator_style3 STYLE_SOLID
#property indicator_width3 2
//--- plot Top
#property indicator_label4 "Top"
#property indicator_type4  DRAW_LINE
#property indicator_color4 clrDarkGray
#property indicator_style4 STYLE_DOT
#property indicator_width4 1
//--- plot Bottom
#property indicator_label5 "Bottom"
#property indicator_type5  DRAW_LINE
#property indicator_color5 clrDarkGray
#property indicator_style5 STYLE_DOT
#property indicator_width5 1
//--- plot Extreme Bottom
#property indicator_label6 "Extreme Top"
#property indicator_type6  DRAW_LINE
#property indicator_color6 clrNavy
#property indicator_style6 STYLE_DASH
#property indicator_width6 1
//--- plot Bottom
#property indicator_label7 "Extreme Bottom"
#property indicator_type7  DRAW_LINE
#property indicator_color7 clrNavy
#property indicator_style7 STYLE_DASH
#property indicator_width7 1
//--- enums
enum ENUM_INPUT_YES_NO {
  INPUT_YES = 1,  // Yes
  INPUT_NO  = 0   // No
};
//--- input parameters
input uint              InpPeriodTMA     = 56;         // TMA period
input uint              InpPeriodATR     = 100;        // ATR period
input double            InpMultiplierATR = 2.0;        // ATR multiplier
input double            InpThreshold     = 0.5;        // Trend threshold
input ENUM_INPUT_YES_NO InpRedraw        = INPUT_YES;  // Redraw
input int               InpPeriodMinMax  = 100;        // Min/Max Period
//--- indicator buffers
double BufferTMA[];
double BufferTMAup[];
double BufferTMAdn[];
double BufferTop[];
double BufferBottom[];
double BufferExtremeTop[];
double BufferExtremeBottom[];
double BufferATR[];
//--- global variables
double multiplier;
double threshold;
int    period_tma;
int    period_extreme;
int    period_atr;
int    period_max;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
  //--- set global variables
  period_tma     = int(InpPeriodTMA < 1 ? 1 : InpPeriodTMA);
  period_atr     = int(InpPeriodATR < 1 ? 1 : InpPeriodATR);
  period_extreme = int(InpPeriodMinMax < 1 ? 1 : InpPeriodMinMax);
  period_max     = fmax(period_atr, period_tma);
  multiplier     = InpMultiplierATR;
  threshold      = InpThreshold;
  //--- indicator buffers mapping
  SetIndexBuffer(0, BufferTMA, INDICATOR_DATA);
  SetIndexBuffer(1, BufferTMAup, INDICATOR_DATA);
  SetIndexBuffer(2, BufferTMAdn, INDICATOR_DATA);
  SetIndexBuffer(3, BufferTop, INDICATOR_DATA);
  SetIndexBuffer(4, BufferBottom, INDICATOR_DATA);
  SetIndexBuffer(5, BufferExtremeTop, INDICATOR_DATA);
  SetIndexBuffer(6, BufferExtremeBottom, INDICATOR_DATA);
  SetIndexBuffer(7, BufferATR, INDICATOR_CALCULATIONS);
  IndicatorSetInteger(INDICATOR_DIGITS, Digits());

  //--- setting buffer arrays as timeseries
  ArraySetAsSeries(BufferTMA, true);
  ArraySetAsSeries(BufferTMAup, true);
  ArraySetAsSeries(BufferTMAdn, true);
  ArraySetAsSeries(BufferTop, true);
  ArraySetAsSeries(BufferBottom, true);
  ArraySetAsSeries(BufferExtremeTop, true);
  ArraySetAsSeries(BufferExtremeBottom, true);
  ArraySetAsSeries(BufferATR, true);
  ResetLastError();

  return (INIT_SUCCEEDED);
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
  ArraySetAsSeries(close, true);

  if (rates_total < fmax(period_max, 4)) return 0;
  int limit = rates_total - prev_calculated;
  if (limit > 1)
  {
    limit = rates_total - period_max - 2;
    ArrayInitialize(BufferTMA, EMPTY_VALUE);
    ArrayInitialize(BufferTMAup, EMPTY_VALUE);
    ArrayInitialize(BufferTMAdn, EMPTY_VALUE);
    ArrayInitialize(BufferTop, EMPTY_VALUE);
    ArrayInitialize(BufferBottom, EMPTY_VALUE);
    ArrayInitialize(BufferExtremeTop, EMPTY_VALUE);
    ArrayInitialize(BufferExtremeBottom, EMPTY_VALUE);
    ArrayInitialize(BufferATR, 0);
  }

  for (int i = limit; i >= 0 && !IsStopped(); i--)
  {
    int  tcount      = period_tma;
    bool period_last = (i == 0 ? true : false);

    while (tcount > 0)
    {
      tcount      = (!period_last ? 0 : tcount - 1);
      double sum  = 0;
      double sumw = (period_tma + 2) * (period_tma + 1) / 2;

      for (int j = 0; j <= period_tma; j++)
      {
        sum += (period_tma - j + 1) * close[i + j];
        if (InpRedraw)
        {
          if (i - j > 0)
          {
            sum += (period_tma - j + 1) * close[i - j];
            sumw += (period_tma - j + 1);
          }
        }
      }
      if (sumw != 0)
      {
        BufferTMA[i] = sum / sumw;
      }
    }
  }

  //--- define colors

  for (int i = limit; i >= 0 && !IsStopped(); i--)
  {
    BufferATR[i]    = iATR(NULL, PERIOD_CURRENT, period_atr, i);
    double slope    = (BufferTMA[i] - BufferTMA[i + 1]) / (0.1 * BufferATR[i]);
    double range    = BufferATR[i] * multiplier;
    BufferTop[i]    = BufferTMA[i] + range;
    BufferBottom[i] = BufferTMA[i] - range;

    if (slope > threshold)
      BufferTMAup[i] = BufferTMA[i];
    else if (slope < -threshold)
      BufferTMAdn[i] = BufferTMA[i];

    // NOTE: Extremes Set
    double tmaValues[];
    ArrayResize(tmaValues, period_extreme);

    // if (i > period_extreme)
      for (int j = period_extreme - 1; j >= 0; j--)
      {
        tmaValues[j] = BufferTMA[i + j];
      }
    int minPos = ArrayMinimum(tmaValues);
    int maxPos = ArrayMaximum(tmaValues);

    BufferExtremeBottom[i] = BufferTMA[i + minPos];
    BufferExtremeTop[i]    = BufferTMA[i + maxPos];

    if (BufferExtremeTop[i] == BufferTMA[i])
    {
      BufferExtremeTop[i] = EMPTY_VALUE;
    }
    if (BufferExtremeBottom[i] == BufferTMA[i])
    {
      BufferExtremeBottom[i] = EMPTY_VALUE;
    }
  }

  //--- return value of prev_calculated for next call
  return (rates_total);
}
//+------------------------------------------------------------------+
