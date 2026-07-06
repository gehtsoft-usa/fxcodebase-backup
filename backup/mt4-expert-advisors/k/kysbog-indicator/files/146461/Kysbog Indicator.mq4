// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72410

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


#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Red
#property indicator_color3 Lime
#property indicator_color4 Red
#property indicator_color5 DeepSkyBlue
#property indicator_color6 Red

extern int SignalPeriod = 12;
extern int ArrowPeriod = 2;
input int   uRatioTP     = 1; // Ratio TP/SL:
int gi_84 = 1;
int gi_88 = 1;
int gi_92 = 1;
int start = 999;
extern int SL_pips = 100;
double g_ibuf_104[];
double g_ibuf_108[];
double g_ibuf_112[];
double g_ibuf_116[];
double g_ibuf_120[];
double g_ibuf_124[];
extern bool AlertON = TRUE;
extern bool Email = TRUE;
bool gi_136 = FALSE;
bool gi_140 = FALSE;
datetime g_time_144;

void displayAlert(string as_0, double tp, double sl, double price) {
   string ls_32;
   string ls_40;
   string ls_48;
   string ls_56;
   string ls_64;
   if (Time[0] != g_time_144) {
      g_time_144 = Time[0];
      if (price != 0.0) ls_48 = " at price " + DoubleToStr(price, 4);
      else ls_48 = "";
      if (tp != 0.0) ls_40 = ", TakeProfit on " + DoubleToStr(tp, 4);
      else ls_40 = "";
      if (sl != 0.0) ls_32 = ", StopLoss on " + DoubleToStr(sl, 4);
      else ls_32 = "";
      Alert("BUYSELL MAGIC " + as_0 + ls_48 + ls_40 + ls_32 + " ", Symbol(), ", ", Period(), " minute chart");
      ls_56 = "BUYSELL MAGIC - " + as_0 + ls_48;
      ls_64 = "BUYSELL MAGIC " + as_0 + ls_48 + ls_40 + ls_32 + " " + Symbol() + ", " + Period() + " minute chart";
      if (Email) SendMail(ls_56, ls_64);
   }
}

int init() {
   SetIndexBuffer(0, g_ibuf_104);
   SetIndexBuffer(1, g_ibuf_108);
   SetIndexBuffer(2, g_ibuf_112);
   SetIndexBuffer(3, g_ibuf_116);
   SetIndexBuffer(4, g_ibuf_120);
   SetIndexBuffer(5, g_ibuf_124);
   SetIndexStyle(0, DRAW_ARROW, 6, 0);
   SetIndexStyle(1, DRAW_ARROW, 6, 0);
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexStyle(4, DRAW_ZIGZAG, STYLE_DASH, 1);
   SetIndexStyle(5, DRAW_ZIGZAG, STYLE_DASH, 1);
   SetIndexArrow(0, 159);
   SetIndexArrow(1, 159);
   SetIndexArrow(2, 233);
   SetIndexArrow(3, 234);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
   string ls_0 = "BUYSELL MAGIC(" + AlertON + "," + ArrowPeriod + ")";
   IndicatorShortName(ls_0);
   SetIndexLabel(0, "UpTrend Stop");
   SetIndexLabel(1, "DownTrend Stop");
   SetIndexLabel(2, "UpTrend Signal");
   SetIndexLabel(3, "DownTrend Signal");
   SetIndexLabel(4, "UpTrend Line");
   SetIndexLabel(5, "DownTrend Line");
   SetIndexDrawBegin(0, SignalPeriod);
   SetIndexDrawBegin(1, SignalPeriod);
   SetIndexDrawBegin(2, SignalPeriod);
   SetIndexDrawBegin(3, SignalPeriod);
   SetIndexDrawBegin(4, SignalPeriod);
   SetIndexDrawBegin(5, SignalPeriod);
   return (0);
}

int start() {
   int side;
   double UpperBand[25000];
   double LowBand[25000];
   double lda_20[25000];
   double lda_24[25000];
   double ld_28;
   double l_close_36;
   for (int i = start; i > 0; i--) {
      g_ibuf_104[i] = 0;
      g_ibuf_108[i] = 0;
      g_ibuf_112[i] = 0;
      g_ibuf_116[i] = 0;
      g_ibuf_120[i] = EMPTY_VALUE;
      g_ibuf_124[i] = EMPTY_VALUE;
   }
   for (i = start - SignalPeriod - 1; i > 0; i--) {
      
			UpperBand[i] = iBands(NULL, 0, SignalPeriod, ArrowPeriod, 0, PRICE_CLOSE, MODE_UPPER, i);
      LowBand[i] = iBands(NULL, 0, SignalPeriod, ArrowPeriod, 0, PRICE_CLOSE, MODE_LOWER, i);
      
			if (Close[i] > UpperBand[i + 1]) side = 1;
      if (Close[i] < LowBand[i + 1]) side = -1;
      
			if (side > 0 && LowBand[i] < LowBand[i + 1]) LowBand[i] = LowBand[i + 1];
      if (side < 0 && UpperBand[i] > UpperBand[i + 1]) UpperBand[i] = UpperBand[i + 1];
      
			lda_20[i] = UpperBand[i] + (gi_84 - 1) / 2.0 * (UpperBand[i] - LowBand[i]);
      lda_24[i] = LowBand[i] - (gi_84 - 1) / 2.0 * (UpperBand[i] - LowBand[i]);
      if (side > 0 && lda_24[i] < lda_24[i + 1]) lda_24[i] = lda_24[i + 1];
      if (side < 0 && lda_20[i] > lda_20[i + 1]) lda_20[i] = lda_20[i + 1];
      
			if (side > 0) 
			{
         if (gi_88 > 0 && g_ibuf_104[i + 1] == -1.0) 
				 {
            g_ibuf_112[i] = lda_24[i];
            g_ibuf_104[i] = lda_24[i];
            if (gi_92 > 0) g_ibuf_120[i] = lda_24[i];
            if (AlertON == TRUE && i == 1 && !gi_136) {
               ld_28 = Low[1];
               if (Low[2] < ld_28) ld_28 = Low[2];
               if (Low[3] < ld_28) ld_28 = Low[3];
               if (Low[4] < ld_28) ld_28 = Low[4];
               ld_28 -= SL_pips * Point;
               l_close_36 = Close[1];
							 // NOTE: TP Buy calc:
	             double tp = l_close_36 + (SL_pips * Point * uRatioTP);
               displayAlert("Buy signal", tp, ld_28, l_close_36);
               gi_136 = TRUE;
               gi_140 = FALSE;
            }
         } else {
            g_ibuf_104[i] = lda_24[i];
            if (gi_92 > 0) g_ibuf_120[i] = lda_24[i];
            g_ibuf_112[i] = -1;
         }
         if (gi_88 == 2) g_ibuf_104[i] = 0;
         g_ibuf_116[i] = -1;
         g_ibuf_108[i] = -1.0;
         g_ibuf_124[i] = EMPTY_VALUE;
      }
      
			if (side < 0) 
			{
         if (gi_88 > 0 && g_ibuf_108[i + 1] == -1.0) 
				 {
            g_ibuf_116[i] = lda_20[i];
            g_ibuf_108[i] = lda_20[i];
            if (gi_92 > 0) g_ibuf_124[i] = lda_20[i];
            if (AlertON == TRUE && i == 1 && !gi_140) {
               ld_28 = High[1];
               if (High[2] > ld_28) ld_28 = High[2];
               if (High[3] > ld_28) ld_28 = High[3];
               if (High[4] > ld_28) ld_28 = High[4];
               ld_28 += SL_pips * Point;

							 
               l_close_36 = Close[1];
							// NOTE: TP sell calc:
	              tp = l_close_36 - (SL_pips * Point * uRatioTP);

               displayAlert("Sell signal", tp, ld_28, l_close_36);
               gi_140 = TRUE;
               gi_136 = FALSE;
            }
         } else {
            g_ibuf_108[i] = lda_20[i];
            if (gi_92 > 0) g_ibuf_124[i] = lda_20[i];
            g_ibuf_116[i] = -1;
         }
         if (gi_88 == 2) g_ibuf_108[i] = 0;
         g_ibuf_112[i] = -1;
         g_ibuf_104[i] = -1.0;
         g_ibuf_120[i] = EMPTY_VALUE;
      }
   }
   return (0);
}
