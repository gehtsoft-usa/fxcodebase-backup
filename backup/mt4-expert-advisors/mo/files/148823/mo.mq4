// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73085

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

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property strict
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1


string     Gs_dummy_76;
double     Gd_unused_84;
bool       Gi_92 = TRUE;
string     Gs_dummy_96;
string     Gs_dummy_104;
string     Gs_112;
int        G_bars_120 = 0;
double     BuyBuffer[];
double     SellBuffer[];
double     Gd_132;
double     avSize;
double     sumSize;
double     ma1_1;
double     ma1_2;
double     ma1_0;
double     ma2_1;
double     ma2_2;
double     ma2_0;
double     ma3_1;
double     ma3_2;
double     ma3_0;
double     Gda_unused_228[];
double     Gda_unused_232[];
double     Gda_unused_236[];
input int  maPeriod1       = 5;
int        Gi_244          = -5;
int        G_ma_method_248 = MODE_EMA;
input int  maPeriod2       = 14;
int        Gi_256          = -5;
int        G_ma_method_260 = MODE_EMA;
input int  maPeriod3       = 41;
int        Gi_268          = 0;
int        G_ma_method_272 = MODE_EMA;
input int  SoundAlert      = 1;

int OnInit()
{ 
	HideTestIndicators(false);

  SetIndexBuffer(0, BuyBuffer);
  SetIndexStyle(0, DRAW_ARROW, EMPTY);
  SetIndexArrow(0, 233);
  SetIndexBuffer(1, SellBuffer);
  SetIndexStyle(1, DRAW_ARROW, EMPTY);
  SetIndexArrow(1, 234);
 
  return (INIT_SUCCEEDED);
}

void OnDeInit()
{
  ObjectsDeleteAll();
}

void f0_0()
{
  int    Lia_unused_184[12][1000];
  double Lda_unused_188[12][1000];
  int    Lia_unused_192[1000];
  double Lda_unused_196[1000];
  bool   Lba_unused_204[12];

  HideTestIndicators(true);

  double icci_0         = iCCI(Symbol(), PERIOD_M1, 80, PRICE_CLOSE, 0);
  double iwpr_8         = iWPR(Symbol(), PERIOD_M1, 14, 0);
  double iforce_16      = iForce(Symbol(), PERIOD_M5, 13, MODE_SMA, PRICE_CLOSE, 0);
  double ibands_24      = iBands(Symbol(), PERIOD_M5, 20, 2, 0, PRICE_WEIGHTED, MODE_UPPER, 1);
  double ibands_32      = iBands(Symbol(), PERIOD_M5, 20, 2, 0, PRICE_WEIGHTED, MODE_BASE, 1);
  double ima_40         = iMA(NULL, 0, 24, 0, MODE_SMMA, PRICE_CLOSE, 0);
  double ima_48         = iMA(NULL, 0, 100, 0, MODE_SMMA, PRICE_CLOSE, 0);
  double ima_56         = iMA(NULL, 0, 72, 0, MODE_SMMA, PRICE_CLOSE, 0);
  double ima_64         = iMA(NULL, 0, 365, 0, MODE_SMMA, PRICE_CLOSE, 0);
  double istochastic_72 = iStochastic(NULL, 0, 10, 5, 5, MODE_EMA, 0, MODE_MAIN, 0);
  double imomentum_80   = iMomentum(NULL, 0, 100, PRICE_OPEN, 0);
  double ibands_88      = iBands(Symbol(), PERIOD_M5, 20, 2, 0, PRICE_WEIGHTED, MODE_LOWER, 1);
  double ima_96         = iMA(Symbol(), PERIOD_M5, 1, 0, MODE_EMA, PRICE_HIGH, 0);
  double ima_104        = iMA(Symbol(), PERIOD_M5, 1, 0, MODE_EMA, PRICE_MEDIAN, 0);
  double iadx_112       = iADX(NULL, 0, 7, PRICE_CLOSE, MODE_MAIN, 0);
  double imomentum_120  = iMomentum(NULL, 0, 100, PRICE_OPEN, 0);
  double ima_128        = iMA(Symbol(), PERIOD_M5, 1, 0, MODE_EMA, PRICE_LOW, 0);
  double ibands_136     = iBands(Symbol(), PERIOD_M5, 20, 2, 0, PRICE_WEIGHTED, MODE_UPPER, 0);

  HideTestIndicators(false);

  string Ls_unused_144      = "Signal Alert";
  string Sell_txt           = "Short Alert";
  string Buy_txt            = "Long Alert";
  int    Li_unused_172      = -1;
  int    Li_unused_176      = 1;
  int    Li_unused_180      = 0;
  int    Lia_unused_200[12] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  int    Li_unused_220      = 80;
  int    Li_unused_224      = 20;
  if (istochastic_72 >= 75.0)
    Gs_112 = "HIGH RISK";
  else
  {
    if (istochastic_72 <= 25.0)
      Gs_112 = "HIGH RISK";
    else if (istochastic_72 < 75.0 && istochastic_72 > 25.0)
      Gs_112 = "LOW RISK";
  }
  string Ls_248        = "";
  int    Li_unused_256 = 1;
  if (Digits < 4)
    Gd_unused_84 = 0.01;
  else
    Gd_unused_84 = 0.0001;

  if (G_bars_120 != Bars) G_bars_120 = Bars;

  double iatr_260 = iATR(Symbol(), Period(), 5, 1);
  double Ld_268   = 1.45 / Period() * MathRound(iatr_260 * MathPow(7, Digits));
  double Ld_276   = 2.0 * Ld_268;
  Ls_248          = Ls_248 + "\n" + "\n" + "";
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
  int i;
  if (Gi_92) f0_0();
  // int prev_calc = IndicatorCounted();
  int prev_calc = prev_calculated;
  // if (prev_calc < 0) return (-1);
  if (prev_calc > 0) prev_calc--;
  
	int Li_0 = Bars - prev_calc;
  
	for (int pos = 0; pos <= 100; pos++)
  {
    i       = pos;
    avSize  = 0;
    sumSize = 0;
    
		for (i = pos; i <= pos + 9; i++) sumSize += MathAbs(high[i] - low[i]);
    
		avSize = sumSize / 10.0;
    
		ma1_1  = iMA(NULL, 0, maPeriod1, Gi_244, G_ma_method_248, PRICE_CLOSE, pos + 1);
    ma1_2  = iMA(NULL, 0, maPeriod1, Gi_244, G_ma_method_248, PRICE_CLOSE, pos + 2);
    ma1_0  = iMA(NULL, 0, maPeriod1, Gi_244, G_ma_method_248, PRICE_CLOSE, pos - 1);
    ma2_1  = iMA(NULL, 0, maPeriod2, Gi_256, G_ma_method_260, PRICE_CLOSE, pos + 1);
    ma2_2  = iMA(NULL, 0, maPeriod2, Gi_256, G_ma_method_260, PRICE_CLOSE, pos + 2);
    ma2_0  = iMA(NULL, 0, maPeriod2, Gi_256, G_ma_method_260, PRICE_CLOSE, pos - 1);
    ma3_1  = iMA(NULL, 0, maPeriod3, Gi_268, G_ma_method_272, PRICE_CLOSE, pos + 1);
    ma3_2  = iMA(NULL, 0, maPeriod3, Gi_268, G_ma_method_272, PRICE_CLOSE, pos + 2);
    ma3_0  = iMA(NULL, 0, maPeriod3, Gi_268, G_ma_method_272, PRICE_CLOSE, pos - 1);

    if ((ma1_1 > ma3_1 && ma1_2 <= ma3_2 && ma1_0 > ma3_0 && ma2_1 > ma3_1) || (ma1_1 > ma3_1 && ma2_1 > ma3_1 && ma2_2 <= ma3_2 && ma2_0 > ma3_0))
    {
      BuyBuffer[pos] = low[pos] - avSize / 2.0;
    }

    if ((ma1_1 < ma3_1 && ma1_2 >= ma3_2 && ma1_0 < ma3_0 && ma2_1 < ma3_1) || (ma1_1 < ma3_1 && ma2_1 < ma3_1 && ma2_2 >= ma3_2 && ma2_0 < ma3_0))
    {
      SellBuffer[pos] = high[pos] + avSize / 2.0;
    }
  }
  if (BuyBuffer[0] > 2000.0 && SellBuffer[0] > 2000.0) Gd_132 = 0;


// notifications:
// ------------------------------------------------------------------
  if (BuyBuffer[0] == low[0] - avSize / 2.0 && Gd_132 != Time[0] && SoundAlert != 0)
  {
    Gd_132 = Time[0];
    Alert(Symbol(), " Price Cross Up @  Hour ", Hour(), "  Minute ", Minute());
  }
  if (SellBuffer[0] == high[0] + avSize / 2.0 && Gd_132 != Time[0] && SoundAlert != 0)
  {
    Gd_132 = Time[0];
    Alert(Symbol(), " Price Cross Down @  Hour ", Hour(), "  Minute ", Minute());
  }
  
	return (rates_total);
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