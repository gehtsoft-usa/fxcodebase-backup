
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73362

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
#property indicator_plots 3
#property strict
#property indicator_label1 "Line"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID

#property indicator_label2 "Divergence Up"
#property indicator_label3 "Divergence Down"

ENUM_TIMEFRAMES    TimeFrame       = PERIOD_CURRENT; // Time frame
extern double             VfiCoeff        = 0.2;            // Volume flow coefficient
extern int                VfiPeriod       = 130;            // Calculation period
extern ENUM_APPLIED_PRICE VfiPrice        = PRICE_TYPICAL;  // Price to use
extern double             VolumeCoeff     = 2.5;            // Volume coefficient
extern int                PreSmoothPeriod = 3;              // Pre-smoothig period
extern ENUM_MA_METHOD     PreSmoothMethod = MODE_SMA;       // Pre-smoothig method
extern int                SmoothPeriod    = 3;              // Smoothig period

//--- DIVERGENCES:
extern bool   drawIndicatorTrendLines = true;
extern bool   drawPriceTrendLines     = true;
extern color  ArrowUpClr = Crimson;
extern color  ArrowDnClr = MediumSeaGreen;


//---- buffers
double vfi[];
double bullishDivergence[];
double bearishDivergence[];

string indicatorFileName;
bool   returnBars;

static string file_custom_indicator = "VFI.ex4";

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,vfi);
   
	 //---- Divergences
	SetIndexBuffer(1, bullishDivergence);
	SetIndexArrow(1, 233);
  SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
	SetIndexBuffer(2, bearishDivergence);
  SetIndexStyle(2, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
	SetIndexArrow(2, 234);
    

   return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) 
{ 
    ObjectsDeleteAll(0, "VFI_Divergence_#");
    ObjectsDeleteAll(0, "VFI_Divergence_$#");
}


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
  if (prev_calculated == 0) { start = rates_total - VfiPeriod; } else { start = rates_total - (prev_calculated - 1); }


  for (i = 1000; i >= 0; i--)
	{
      vfi[i] = iCustom(NULL, 0, file_custom_indicator, TimeFrame,VfiCoeff,VfiPeriod,VfiPrice,VolumeCoeff,PreSmoothPeriod,PreSmoothMethod,SmoothPeriod, 0, i);
	}

  for (i = 200; i >= 0; i--)
	{
    CatchBullishDivergence(i + 2);
    CatchBearishDivergence(i + 2);
	}

	//---  
	return(rates_total);         
}



// ------------------------------------------------------------------

void CatchBullishDivergence(int shift)
{
  if (IsIndicatorValley(shift) == false) return;

  int currentValley = shift;
  int lastValley    = GetIndicatorLastValley(shift);
  //   static bool turn_alarm = true;
  //----
  if (vfi[currentValley] >= vfi[lastValley] &&
      Low[currentValley] <= Low[lastValley])
  {
    bullishDivergence[currentValley] = vfi[lastValley];
    
		//----
    if (drawPriceTrendLines == true)
      DrawPriceTrendLine(Time[currentValley], Time[lastValley],
                         Low[currentValley],
                         Low[lastValley], ArrowDnClr, STYLE_SOLID);
    //----
    if (drawIndicatorTrendLines == true)
      DrawIndicatorTrendLine(Time[currentValley],
                             Time[lastValley],
                             vfi[currentValley],
                             vfi[lastValley],
                             ArrowDnClr, STYLE_SOLID);
    //----
    // if (displayAlert == true)
    //   DisplayAlert("Bullish divergence on: ",
    //                currentValley);
  }
}

void CatchBearishDivergence(int shift)
{
  if (IsIndicatorPeak(shift) == false)
    return;
  int         currentPeak = shift;
  int         lastPeak    = GetIndicatorLastPeak(shift);
  static bool turn_alarm  = true;
  //----
  if (vfi[currentPeak] <= vfi[lastPeak] &&
      High[currentPeak] >= High[lastPeak])
  {
    bearishDivergence[currentPeak] = vfi[lastPeak];

    if (drawPriceTrendLines == true)
      DrawPriceTrendLine(Time[currentPeak], Time[lastPeak],
                         High[currentPeak],
                         High[lastPeak], ArrowUpClr, STYLE_SOLID);

    if (drawIndicatorTrendLines == true)
      DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak],
                             vfi[currentPeak],
                             vfi[lastPeak], ArrowUpClr, STYLE_SOLID);

    // if (displayAlert == true)
    //   DisplayAlert("Bearish divergence on: ",
    //                currentPeak);
  }
}

bool IsIndicatorPeak(int shift)
{
  return vfi[shift] >= vfi[shift + 1] && vfi[shift] > vfi[shift + 2] && vfi[shift] > vfi[shift - 1];
}

bool IsIndicatorValley(int shift)
{
  return vfi[shift] <= vfi[shift + 1] && vfi[shift] < vfi[shift + 2] && vfi[shift] < vfi[shift - 1];
}

int GetIndicatorLastPeak(int shift)
{
  for (int i = shift + 5; i < Bars; i++)
  {
      for (int j = i; j < Bars; j++)
      {
        if (vfi[j] >= vfi[j + 1] && vfi[j] > vfi[j + 2] &&
            vfi[j] >= vfi[j - 1] && vfi[j] > vfi[j - 2])
          return (j);
      }
  }
  return (-1);
}

int GetIndicatorLastValley(int shift)
{
  for (int i = shift + 5; i < Bars; i++)
  {
      for (int j = i; j < Bars; j++)
      {
        if (vfi[j] <= vfi[j + 1] && vfi[j] < vfi[j + 2] &&
            vfi[j] <= vfi[j - 1] && vfi[j] < vfi[j - 2])
          return (j);
      }
  }
  return (-1);
}


// DRAW LINES
// ------------------------------------------------------------------
void DrawPriceTrendLine(datetime x1, datetime x2, double y1,
                        double y2, color lineColor, double style)
{
  string label = "VFI_Divergence_# " + DoubleToStr(x1, 0) + TimeFrame;
  ObjectDelete(label);
  ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
  ObjectSet(label, OBJPROP_RAY, 0);
  ObjectSet(label, OBJPROP_COLOR, lineColor);
  ObjectSet(label, OBJPROP_STYLE, style);
}
void DrawIndicatorTrendLine(datetime x1, datetime x2, double y1,
                            double y2, color lineColor, double style)
{
  // int indicatorWindow = WindowFind(indicatorName);
  // if (indicatorWindow < 0) return;
  // if (indicatorWindow < 0) return;

  string label = "VFI_Divergence_$# " + DoubleToStr(x1, 0) + TimeFrame;
  ObjectDelete(label);
  ObjectCreate(label, OBJ_TREND, 1, x1, y1, x2, y2, 0, 0);
  ObjectSet(label, OBJPROP_RAY, 0);
  ObjectSet(label, OBJPROP_COLOR, lineColor);
  ObjectSet(label, OBJPROP_STYLE, style);
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