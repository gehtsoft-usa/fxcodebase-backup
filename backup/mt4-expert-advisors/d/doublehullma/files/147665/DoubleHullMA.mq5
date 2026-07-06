// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72775

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

#include <MovingAverages.mqh>

#property indicator_chart_window
#property indicator_buffers 15
#property indicator_plots 15

#property indicator_color1  clrAqua
#property indicator_color2  clrTomato
#property indicator_color3  clrDodgerBlue
#property indicator_color4  clrMagenta
#property indicator_color5  clrDodgerBlue  // signals
#property indicator_color6  clrMagenta
#property indicator_color7  clrLime  // arrows
#property indicator_color8  clrGold
#property indicator_color9  clrLime  // entrys
#property indicator_color10 clrGold

#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 2  // signals
#property indicator_width6 2
#property indicator_width7 2  // arrows
#property indicator_width8 2
#property indicator_width9 1  // entrys
#property indicator_width10 1

//---- input parameters
//###################################################################
input bool               Show_EntryLevels         = true;
input bool               Set_Only_LimitOrder      = true;
input string             ___Hull_MovingAverage___ = "----------------------------------------------------";
input int                Fast_Period              = 12;
input int                Slow_Period              = 120;
input ENUM_MA_METHOD     method                   = MODE_LWMA;
input ENUM_APPLIED_PRICE price                    = PRICE_CLOSE;
input string             ___ADX___                = "----------------------------------------------------";
input int                ADX_Period               = 12;
input double             ADX_Limit                = 20;
input string             ___ATR___                = "----------------------------------------------------";
input int                ATR_Period               = 14;
input int                ATR_Smoothing            = 35;
input double             OffsetEntry_Factor       = 1.5;
input string             ___Filter___             = "----------------------------------------------------";
input bool               Enable_TrendFilter       = true;
input bool               Enable_ADXFilter         = true;
//###################################################################

//---- buffers
double FastUPtrend[], FastDNtrend[], FastBuffer[];
double SlowUPtrend[], SlowDNtrend[], SlowBuffer[];
double SignalUP[], SignalDN[], SignalUP2[], SignalDN2[];
double entryUP[], entryDN[];
double ADXbuffer[];
double ATRbuffer[], ATRsmooth[];

int maFast1;
int maFast2;
int maSlow1;
int maSlow2;
int adx;
int atr;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
{
  int iBuff = -1;
  iBuff++;
  SetIndexBuffer(iBuff, FastUPtrend, INDICATOR_DATA);
	PlotIndexSetInteger(iBuff, PLOT_DRAW_TYPE, DRAW_LINE);
	PlotIndexSetDouble(iBuff, PLOT_EMPTY_VALUE, EMPTY_VALUE);

  iBuff++;
  SetIndexBuffer(iBuff, FastDNtrend, INDICATOR_DATA);
	PlotIndexSetInteger(iBuff, PLOT_DRAW_TYPE, DRAW_LINE);
	PlotIndexSetDouble(iBuff, PLOT_EMPTY_VALUE, EMPTY_VALUE);

  iBuff++;
  SetIndexBuffer(iBuff, SlowUPtrend, INDICATOR_DATA);
  PlotIndexSetInteger(iBuff, PLOT_DRAW_TYPE, DRAW_LINE);
	PlotIndexSetDouble(iBuff, PLOT_EMPTY_VALUE, EMPTY_VALUE);

  iBuff++;
  SetIndexBuffer(iBuff, SlowDNtrend, INDICATOR_DATA);
  PlotIndexSetInteger(iBuff, PLOT_DRAW_TYPE, DRAW_LINE);
	PlotIndexSetDouble(iBuff, PLOT_EMPTY_VALUE, EMPTY_VALUE);
  
	
	//--- arrws // Diamantes
  int iArrowUP = 116;
  int iArrowDN = 116;
  
	iBuff++;
  SetIndexBuffer(iBuff, SignalUP,INDICATOR_DATA);
	PlotIndexSetInteger(iBuff, PLOT_DRAW_TYPE, DRAW_ARROW);
	PlotIndexSetInteger(iBuff, PLOT_ARROW, iArrowUP);
	PlotIndexSetInteger(iBuff, PLOT_LINE_COLOR, clrDodgerBlue);

	iBuff++;
  SetIndexBuffer(iBuff, SignalDN, INDICATOR_DATA);
	PlotIndexSetInteger(iBuff, PLOT_DRAW_TYPE, DRAW_ARROW);
	PlotIndexSetInteger(iBuff, PLOT_ARROW, iArrowDN);
	PlotIndexSetInteger(iBuff, PLOT_LINE_COLOR, clrMagenta);

	//--- first signal // Flechas
  int iArrowUP2 = 233;
  int iArrowDN2 = 234;
  
	iBuff++;
  SetIndexBuffer(iBuff, SignalUP2, INDICATOR_DATA);
	PlotIndexSetInteger(iBuff, PLOT_DRAW_TYPE, DRAW_ARROW);
	PlotIndexSetInteger(iBuff, PLOT_ARROW, iArrowUP2);
	PlotIndexSetInteger(iBuff, PLOT_LINE_COLOR, clrLime);
	
	iBuff++;
  SetIndexBuffer(iBuff, SignalDN2, INDICATOR_DATA);
	PlotIndexSetInteger(iBuff, PLOT_DRAW_TYPE, DRAW_ARROW);
	PlotIndexSetInteger(iBuff, PLOT_ARROW, iArrowDN2);
	PlotIndexSetInteger(iBuff, PLOT_LINE_COLOR, clrGold);
  
	//--- entrys
  int iArrowUPentry = 164;  // 59;
  int iArrowDNentry = 164;  // 59;

  iBuff++;
  SetIndexBuffer(iBuff, entryUP);
	PlotIndexSetInteger(iBuff, PLOT_DRAW_TYPE, DRAW_ARROW);
  PlotIndexSetInteger(iBuff, PLOT_ARROW, iArrowUPentry);
	// SetIndexLabel(iBuff, "HullEntry LONG");
  // SetIndexStyle(iBuff, DRAW_ARROW, STYLE_SOLID);
  // SetIndexArrow(iBuff, iArrowUPentry);
  // SetIndexEmptyValue(iBuff, EMPTY_VALUE);
	PlotIndexSetDouble(iBuff, PLOT_EMPTY_VALUE, EMPTY_VALUE);

  // if (Show_EntryLevels == false) SetIndexStyle(iBuff, DRAW_NONE);
  if (Show_EntryLevels == false) PlotIndexSetInteger(iBuff, PLOT_DRAW_TYPE, DRAW_NONE);
  
	iBuff++;
  SetIndexBuffer(iBuff, entryDN);
	PlotIndexSetInteger(iBuff, PLOT_DRAW_TYPE, DRAW_ARROW);
	PlotIndexSetInteger(iBuff, PLOT_ARROW, iArrowDNentry);
  // SetIndexLabel(iBuff, "HullEntry SHORT");
  // SetIndexStyle(iBuff, DRAW_ARROW, STYLE_SOLID);
  // SetIndexArrow(iBuff, iArrowDNentry);
  // SetIndexEmptyValue(iBuff, EMPTY_VALUE);
  PlotIndexSetDouble(iBuff, PLOT_EMPTY_VALUE, EMPTY_VALUE);

	// if (Show_EntryLevels == false) SetIndexStyle(iBuff, DRAW_NONE);
	if (Show_EntryLevels == false) PlotIndexSetInteger(iBuff, PLOT_DRAW_TYPE, DRAW_NONE);
  //--- help
  
	iBuff++;
  SetIndexBuffer(iBuff, FastBuffer);
  // SetIndexLabel(iBuff, "Hull fast (" + (string)Fast_Period + ")");
  // SetIndexStyle(iBuff, DRAW_NONE);
  // SetIndexEmptyValue(iBuff, EMPTY_VALUE);
  PlotIndexSetDouble(iBuff, PLOT_EMPTY_VALUE, EMPTY_VALUE);
	
	iBuff++;
  SetIndexBuffer(iBuff, SlowBuffer);
  // SetIndexLabel(iBuff, "Hull slow (" + (string)Slow_Period + ")");
  // SetIndexStyle(iBuff, DRAW_NONE);
	PlotIndexSetInteger(iBuff, PLOT_DRAW_TYPE, DRAW_NONE);
  // SetIndexEmptyValue(iBuff, EMPTY_VALUE);
	PlotIndexSetDouble(iBuff, PLOT_EMPTY_VALUE, EMPTY_VALUE);
  
	
	//--- more buffers
  // IndicatorBuffers(15);
  
	iBuff++;
  SetIndexBuffer(iBuff, ADXbuffer);
  // SetIndexEmptyValue(iBuff, EMPTY_VALUE);
	PlotIndexSetDouble(iBuff, PLOT_EMPTY_VALUE, EMPTY_VALUE);
  
	iBuff++;
  SetIndexBuffer(iBuff, ATRbuffer);
  // SetIndexEmptyValue(iBuff, EMPTY_VALUE);
  PlotIndexSetDouble(iBuff, PLOT_EMPTY_VALUE, EMPTY_VALUE);
	iBuff++;
  SetIndexBuffer(iBuff, ATRsmooth);
  // SetIndexEmptyValue(iBuff, EMPTY_VALUE);
  PlotIndexSetDouble(iBuff, PLOT_EMPTY_VALUE, EMPTY_VALUE);
  //---
  // IndicatorShortName("smDoubleHull MA(" + (string)Fast_Period + "," + (string)Slow_Period + ")");
  // IndicatorDigits(Digits);
  string short_name = "smDoubleHull MA(" + (string)Fast_Period + "," + (string)Slow_Period + ")";
  IndicatorSetString(INDICATOR_SHORTNAME, short_name);
	IndicatorSetInteger(INDICATOR_DIGITS, Digits());

  // SetIndexDrawBegin(0, Slow_Period + 2);
	PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Slow_Period + 2);
  // SetIndexDrawBegin(1, Slow_Period + 2);
	PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, Slow_Period + 2);
  

// Handles:
maFast1 = iMA(NULL, 0, (int)(Fast_Period / 2.0), 0, method, price);
maFast2 = iMA(NULL, 0, Fast_Period, 0, method, price);
maSlow1 = iMA(NULL, 0, (int)(Slow_Period / 2.0), 0, method, price);
maSlow2 = iMA(NULL, 0, Slow_Period, 0, method, price);

adx = iADX(Symbol(), Period(), ADX_Period);
atr = iATR(Symbol(), Period(), ATR_Period);

//  return (0);
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
// int deinit()
// {
//   //
//   // Comment("");
//   return (0);
// }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// NOTE: calculate
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

// clang-format off
double ma_Fast1(int x) { return calculate(maFast1, 0, x); }
double ma_Fast2(int x) { return calculate(maFast2, 0, x); }
double ma_Slow1(int x) { return calculate(maSlow1, 0, x); }
double ma_Slow2(int x) { return calculate(maSlow2, 0, x); }
// clang-format on

// p = periods
// double WMA(int x, int p)
// {

	// return calculate(ma,0,
  // return (iMA(NULL, 0, p, 0, method, price, x));
// }

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
	if (prev_calculated > 1) start = prev_calculated - 1; else { start = Slow_Period; }

  int x = 0;
  int p;
  // int p = MathSqrt(period);

  //-- 1. Fast Hull MA
  //=========================================================
  double vect[], trend[];
  p = (int)MathSqrt((double)Fast_Period);

  ArrayResize(vect, rates_total);
  ArraySetAsSeries(vect, true);
  ArrayResize(trend, rates_total);
  ArraySetAsSeries(trend, true);

  for (x = 0; x < rates_total; x++) 
		vect[x] = 2 * ma_Fast1(x) - ma_Fast2(x);
  
	for (x = 0; x < rates_total; x++)
    FastBuffer[x] = SimpleMA(x, p, vect);

	for (x = start; x < rates_total; x++)
  {

    trend[x] = trend[x-1];
    if (FastBuffer[x] > FastBuffer[x-1]) trend[x] = 1;
    if (FastBuffer[x] < FastBuffer[x-1]) trend[x] = -1;

    if (trend[x] > 0)
    {
      FastUPtrend[x] = FastBuffer[x];
      if (trend[x-1] < 0) FastUPtrend[x-1] = FastBuffer[x-1];
      FastDNtrend[x] = EMPTY_VALUE;
    } else if (trend[x] < 0)
    {
      FastDNtrend[x] = FastBuffer[x];
      if (trend[x-1] > 0) FastDNtrend[x-1] = FastBuffer[x-1];
      FastUPtrend[x] = EMPTY_VALUE;
    }
  }
  //=========================================================

  //-- 2. Slow Hull MA
  //=========================================================
  p = (int)MathSqrt((double)Slow_Period);

	for (x = 0; x < rates_total; x++)
	  vect[x] = 2 * ma_Slow1(x) - ma_Slow2(x);

	for (x = 0; x < rates_total; x++)
		SlowBuffer[x] = SimpleMA(x, p, vect);

	for (x = start; x < rates_total; x++)
	{
    trend[x] = trend[x-1];
    if (SlowBuffer[x] > SlowBuffer[x-1]) trend[x] = 1;
    if (SlowBuffer[x] < SlowBuffer[x-1]) trend[x] = -1;

    if (trend[x] > 0)
    {
      SlowUPtrend[x] = SlowBuffer[x];
      if (trend[x-1] < 0) SlowUPtrend[x-1] = SlowBuffer[x-1];
      SlowDNtrend[x] = EMPTY_VALUE;
    } else if (trend[x] < 0)
    {
      SlowDNtrend[x] = SlowBuffer[x];
      if (trend[x-1] > 0) SlowDNtrend[x-1] = SlowBuffer[x-1];
      SlowUPtrend[x] = EMPTY_VALUE;
    }
  }
  //=========================================================

	// NOTE: ADX, ATR  
	
	//-- 3. ADX, ATR
  //=========================================================
	
	for (x = start; x < rates_total; x++)
  {
    ADXbuffer[x] = calculate(adx, 0, x);
    ATRbuffer[x] = calculate(atr, 0, x);
  }

	for (x = start; x < rates_total; x++)
		ATRsmooth[x] = SimpleMA(x, ATR_Smoothing, ATRbuffer);



// NOTE: Signals:
  // //-- 4. Signals
  // //=========================================================
  double entryValue = 0;

for (x = start; x < rates_total; x++)
{
	SignalUP[x] = EMPTY_VALUE;
	SignalUP2[x] = EMPTY_VALUE;
  SignalDN[x] = EMPTY_VALUE;
	SignalDN2[x] = EMPTY_VALUE;
  
	if (Enable_TrendFilter == true)
  {
      if (time[x] == D'2019.07.16 08:00')
        int vv = 9;

      //-- 4.1 LONG signal
      if (FastBuffer[x] > FastBuffer[x-1] && SlowBuffer[x] > SlowBuffer[x-1])
      {
        if (Enable_ADXFilter == false)
        {
          SignalUP[x] = SlowBuffer[x];
        } else if (Enable_ADXFilter == true)
        {
          if (ADXbuffer[x] > ADX_Limit)
            SignalUP[x] = SlowBuffer[x];
          else
            SignalUP[x] = EMPTY_VALUE;
        }

        //========================
        //--- arrow, entry long
        if (SignalUP[x] != EMPTY_VALUE && SignalUP[x-1] != EMPTY_VALUE && SignalUP[x - 2] == EMPTY_VALUE && SignalUP2[x - 2] == EMPTY_VALUE)
        {
          SignalUP2[x] = SignalUP[x];
          SignalUP[x]  = EMPTY_VALUE;
          entryValue   = low[x-1] + ATRsmooth[x-1] * OffsetEntry_Factor;
  
	        if (Set_Only_LimitOrder == true)
          {
            if (open[x] < entryValue)
              entryUP[x] = entryValue;
          } else
            entryUP[x] = entryValue;
        }
      } 

      //-- 4.2 SHORT signal
      if (FastBuffer[x] < FastBuffer[x-1] && SlowBuffer[x] < SlowBuffer[x-1])
      {
        if (Enable_ADXFilter == false)
        {
          SignalDN[x] = SlowBuffer[x];
        } else if (Enable_ADXFilter == true)
        {
          if (ADXbuffer[x] > ADX_Limit)
            SignalDN[x] = SlowBuffer[x];
          else
            SignalDN[x] = EMPTY_VALUE;
        }
  
	      //========================
        //--- arrow, entry short
        if (SignalDN[x] != EMPTY_VALUE && SignalDN[x-1] != EMPTY_VALUE && SignalDN[x - 2] == EMPTY_VALUE && SignalDN2[x - 2] == EMPTY_VALUE)
        {
          SignalDN2[x] = SignalDN[x];
          SignalDN[x]  = EMPTY_VALUE;
          entryValue   = high[x-1] - ATRsmooth[x-1] * OffsetEntry_Factor;
  
	        if (Set_Only_LimitOrder == true)
          {
            if (open[x] > entryValue)
              entryDN[x] = entryValue;
          } else
            entryDN[x] = entryValue;
        }
      }
    }
  } 

  return rates_total;
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
