// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72344

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
#property indicator_buffers 3
#property indicator_color1 Orange
#property indicator_color2 DarkOrange
#property indicator_color3 DarkOrange

extern int Price = 0;
extern int MAPeriod = 20;
extern int MAShift = 0;
extern int MAMethod = 0;
extern int BandsType = 1;
extern int STDPeriod = 20;
extern bool STDUseMAPeriod = TRUE;
extern double STDDevations = 2.0;
extern double ENVDevations = 0.1;
extern int ATRPeriod = 20;
extern bool ATRUseMAPeriod = TRUE;
extern double ATRDevations = 2.0;
extern double NLMADeviation = 0.0;
extern double NLMAPctFilter = 0.0;
double g_ibuf_152[];
double g_ibuf_156[];
double g_ibuf_160[];
double g_ibuf_164[];
int gi_168;
string gs_172;
double gda_180[];
int g_index_184;
int gi_188;
int gi_192;
int gi_196 = 4;
double gd_200;
double gd_208;
double gd_216;
double gd_232;
double gd_240;
double gd_248 = 3.1415926535;
double g_ibuf_256[];
double g_ibuf_260[];

int init() {
   //if (TimeCurrent() > StrToTime("2050.04.20")) {
   //   Alert("New version available! Download it using re-activated link from Plimus");
   //   return;
   //}
   gd_200 = 3.0 * gd_248;
   gi_188 = MAPeriod - 1;
   gi_192 = MAPeriod * gi_196 + gi_188;
   ArrayResize(gda_180, gi_192);
   gd_232 = 0;
   for (g_index_184 = 0; g_index_184 < gi_192 - 1; g_index_184++) {
      if (g_index_184 <= gi_188 - 1) gd_216 = 1.0 * g_index_184 / (gi_188 - 1);
      else gd_216 = (g_index_184 - gi_188 + 1) * (2.0 * gi_196 - 1.0) / (gi_196 * MAPeriod - 1.0) + 1.0;
      gd_208 = MathCos(gd_248 * gd_216);
      gd_240 = 1.0 / (gd_200 * gd_216 + 1.0);
      if (gd_216 <= 0.5) gd_240 = 1;
      gda_180[g_index_184] = gd_240 * gd_208;
      gd_232 += gda_180[g_index_184];
   }
   if (STDUseMAPeriod) STDPeriod = MAPeriod;
   if (ATRUseMAPeriod) ATRPeriod = MAPeriod;
   SetIndexStyle(0, DRAW_LINE);
   SetIndexShift(0, MAShift);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexShift(1, MAShift);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexShift(2, MAShift);
   gi_168 = MAPeriod;
   string ls_unused_0 = "";
   switch (BandsType) {
   case 0: break;
   case 1:
      ls_unused_0 = "STD";
      SetIndexLabel(1, "STD(" + STDPeriod + ") Upper(" + DoubleToStr(STDDevations, 2) + ")");
      SetIndexLabel(2, "STD(" + STDPeriod + ") Lower(" + DoubleToStr(STDDevations, 2) + ")");
      break;
   case 2:
      ls_unused_0 = "ENV";
      SetIndexLabel(1, "ENV(" + MAPeriod + ") Upper(" + DoubleToStr(ENVDevations, 3) + ")");
      SetIndexLabel(2, "ENV(" + MAPeriod + ") Lower(" + DoubleToStr(ENVDevations, 3) + ")");
      break;
   case 3:
      ls_unused_0 = "ATR";
      SetIndexLabel(1, "ATR(" + ATRPeriod + ") Upper(" + DoubleToStr(ATRDevations, 2) + ")");
      SetIndexLabel(2, "ATR(" + ATRPeriod + ") Lower(" + DoubleToStr(ATRDevations, 2) + ")");
   }
   switch (MAMethod) {
   case 1:
      gs_172 = "EMA";
      break;
   case 2:
      gs_172 = "Wilder";
      break;
   case 3:
      gs_172 = "LWMA";
      break;
   case 4:
      gs_172 = "SineWMA";
      break;
   case 5:
      gs_172 = "TriMA";
      break;
   case 6:
      gs_172 = "LSMA";
      break;
   case 7:
      gs_172 = "SMMA";
      break;
   case 8:
      gs_172 = "MMA";
      break;
   case 9:
      gs_172 = "HMA";
      break;
   case 10:
      gs_172 = "ZeroLagEMA";
      break;
   case 11:
      gs_172 = "NonLagMA";
      gi_168 = gi_192;
      break;
   default:
      MAMethod = FALSE;
      gs_172 = "SMA";
   }
   SetIndexLabel(0, gs_172 + "(" + MAPeriod + ")");
   IndicatorBuffers(6);
   SetIndexBuffer(0, g_ibuf_152);
   SetIndexBuffer(1, g_ibuf_160);
   SetIndexBuffer(2, g_ibuf_164);
   SetIndexBuffer(3, g_ibuf_156);
   SetIndexBuffer(4, g_ibuf_256);
   SetIndexBuffer(5, g_ibuf_260);
   SetIndexDrawBegin(0, gi_168);
   SetIndexDrawBegin(1, MathMax(gi_168, MathMax(STDPeriod, ATRPeriod)));
   SetIndexDrawBegin(2, MathMax(gi_168, MathMax(STDPeriod, ATRPeriod)));
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   double ld_32;
   int li_12 = IndicatorCounted();
   int li_unused_16 = 0;
   if (li_12 < 1) for (int li_4 = 1; li_4 <= gi_168; li_4++) g_ibuf_152[Bars - li_4] = iMA(NULL, 0, 1, 0, MODE_SMA, Price, Bars - li_4);
   if (li_12 > 0) li_12--;
   int li_0 = Bars - li_12;
   for (int li_8 = li_0; li_8 >= 0; li_8--) g_ibuf_156[li_8] = iMA(NULL, 0, 1, 0, MODE_SMA, Price, li_8);
   li_unused_16 = MAPeriod;
   for (li_8 = li_0; li_8 >= 0; li_8--) {
      if (li_8 == Bars - MAPeriod) {
         switch (MAMethod) {
         case 1:
            g_ibuf_152[li_8] = SMA(g_ibuf_156, MAPeriod, li_8);
            break;
         case 2:
            g_ibuf_152[li_8] = SMA(g_ibuf_156, MAPeriod, li_8);
            break;
         case 7:
            g_ibuf_152[li_8] = SMA(g_ibuf_156, MAPeriod, li_8);
            break;
         case 10:
            g_ibuf_152[li_8] = SMA(g_ibuf_156, 1, li_8);
         }
      } else {
         if (li_8 < Bars - MAPeriod) {
            switch (MAMethod) {
            case 1:
               g_ibuf_152[li_8] = EMA(g_ibuf_156, g_ibuf_152, MAPeriod, li_8);
               break;
            case 2:
               g_ibuf_152[li_8] = Wilder(g_ibuf_156, g_ibuf_152, MAPeriod, li_8);
               break;
            case 3:
               g_ibuf_152[li_8] = LWMA(g_ibuf_156, MAPeriod, li_8);
               break;
            case 4:
               g_ibuf_152[li_8] = SineWMA(g_ibuf_156, MAPeriod, li_8);
               break;
            case 5:
               g_ibuf_152[li_8] = TriMA(g_ibuf_156, MAPeriod, li_8);
               break;
            case 6:
               g_ibuf_152[li_8] = LSMA(g_ibuf_156, MAPeriod, li_8);
               break;
            case 7:
               g_ibuf_152[li_8] = SMMA(g_ibuf_156, g_ibuf_152, MAPeriod, li_8);
               break;
            case 8:
               g_ibuf_152[li_8] = MMA(g_ibuf_156, MAPeriod, li_8);
               break;
            case 9:
               g_ibuf_152[li_8] = HMA(g_ibuf_156, MAPeriod, li_8);
               break;
            case 10:
               g_ibuf_152[li_8] = ZeroLagEMA(g_ibuf_156, g_ibuf_152, MAPeriod, li_8);
               break;
            case 11:
               NonLagEMA(g_ibuf_156, g_ibuf_152, g_ibuf_256, g_ibuf_260, li_8);
               break;
            default:
               g_ibuf_152[li_8] = SMA(g_ibuf_156, MAPeriod, li_8);
            }
         }
      }
      switch (BandsType) {
      case 0:
         g_ibuf_160[li_8] = EMPTY_VALUE;
         g_ibuf_164[li_8] = EMPTY_VALUE;
         break;
      case 1:
         ld_32 = iBands(NULL, 0, STDPeriod, 1, 0, Price, MODE_UPPER, li_8) - iMA(NULL, 0, STDPeriod, 0, MODE_SMA, Price, li_8);
         g_ibuf_160[li_8] = g_ibuf_152[li_8] + ld_32 * STDDevations;
         g_ibuf_164[li_8] = g_ibuf_152[li_8] - ld_32 * STDDevations;
         break;
      case 2:
         g_ibuf_160[li_8] = g_ibuf_152[li_8] + ENVDevations * g_ibuf_152[li_8] / 100.0;
         g_ibuf_164[li_8] = g_ibuf_152[li_8] - ENVDevations * g_ibuf_152[li_8] / 100.0;
         break;
      case 3:
         ld_32 = iATR(NULL, 0, ATRPeriod, li_8);
         g_ibuf_160[li_8] = g_ibuf_152[li_8] + ld_32 * ATRDevations;
         g_ibuf_164[li_8] = g_ibuf_152[li_8] - ld_32 * ATRDevations;
      }
   }
   return (0);
}

double SMA(double ada_0[], int ai_4, int ai_8) {
   double ld_12 = 0;
   for (int l_count_20 = 0; l_count_20 < ai_4; l_count_20++) ld_12 += ada_0[l_count_20 + ai_8];
   return (ld_12 / ai_4);
}

double EMA(double ada_0[], double ada_4[], int ai_8, int ai_12) {
   return (ada_4[ai_12 + 1] + 2.0 / (ai_8 + 1) * (ada_0[ai_12] - (ada_4[ai_12 + 1])));
}

double Wilder(double ada_0[], double ada_4[], int ai_8, int ai_12) {
   return (ada_4[ai_12 + 1] + 1.0 / ai_8 * (ada_0[ai_12] - (ada_4[ai_12 + 1])));
}

double LWMA(double ada_0[], int ai_4, int ai_8) {
   double ld_ret_32;
   double ld_12 = 0;
   double ld_20 = 0;
   for (int l_count_28 = 0; l_count_28 < ai_4; l_count_28++) {
      ld_20 += ai_4 - l_count_28;
      ld_12 += (ada_0[ai_8 + l_count_28]) * (ai_4 - l_count_28);
   }
   if (ld_20 > 0.0) ld_ret_32 = ld_12 / ld_20;
   else ld_ret_32 = 0;
   return (ld_ret_32);
}

double SineWMA(double ada_0[], int ai_4, int ai_8) {
   double ld_ret_48;
   double ld_12 = 3.1415926535;
   double ld_20 = 0;
   double ld_28 = 0;
   double ld_36 = ld_12 / 2.0 / ai_4;
   for (int l_count_44 = 0; l_count_44 < ai_4; l_count_44++) {
      ld_28 += MathSin(ld_12 / 2.0 - ld_36 * l_count_44);
      ld_20 += (ada_0[ai_8 + l_count_44]) * MathSin(ld_12 / 2.0 - ld_36 * l_count_44);
   }
   if (ld_28 > 0.0) ld_ret_48 = ld_20 / ld_28;
   else ld_ret_48 = 0;
   return (ld_ret_48);
}

double TriMA(double ada_0[], int ai_4, int ai_8) {
   double lda_12[];
   int li_16 = MathCeil((ai_4 + 1) / 2.0);
   ArrayResize(lda_12, li_16);
   for (int l_index_20 = 0; l_index_20 < li_16; l_index_20++) lda_12[l_index_20] = SMA(ada_0, li_16, ai_8 + l_index_20);
   double ld_24 = SMA(lda_12, li_16, 0);
   return (ld_24);
}

double LSMA(double ada_0[], int ai_4, int ai_8) {
   double ld_12 = 0;
   for (int li_20 = ai_4; li_20 >= 1; li_20--) ld_12 += (li_20 - (ai_4 + 1) / 3.0) * (ada_0[ai_4 - li_20 + ai_8]);
   double ld_ret_24 = 6.0 * ld_12 / (ai_4 * (ai_4 + 1));
   return (ld_ret_24);
}

double SMMA(double ada_0[], double ada_4[], int ai_8, int ai_12) {
   double ld_16 = 0;
   for (int l_count_24 = 0; l_count_24 < ai_8; l_count_24++) ld_16 += ada_0[l_count_24 + ai_12 + 1];
   double ld_ret_28 = (ld_16 - (ada_4[ai_12 + 1]) + ada_0[ai_12]) / ai_8;
   return (ld_ret_28);
}

double MMA(double ada_0[], int ai_4, int ai_8) {
   double ld_24;
   double ld_12 = 0;
   for (int li_20 = 1; li_20 <= ai_4; li_20++) {
      ld_24 = (li_20 - 1) << 1 + 1;
      ld_12 += (ada_0[ai_8 + li_20 - 1]) * ((ai_4 - ld_24) / 2.0);
   }
   double ld_32 = SMA(ada_0, ai_4, ai_8);
   double ld_ret_40 = ld_32 + 6.0 * ld_12 / ((ai_4 + 1) * ai_4);
   return (ld_ret_40);
}

double HMA(double ada_0[], int ai_4, int ai_8) {
   double lda_12[];
   int li_16 = MathSqrt(ai_4);
   ArrayResize(lda_12, li_16);
   for (int l_index_20 = 0; l_index_20 < li_16; l_index_20++) lda_12[l_index_20] = 2.0 * LWMA(ada_0, ai_4 / 2, ai_8 + l_index_20) - LWMA(ada_0, ai_4, ai_8 + l_index_20);
   double ld_24 = LWMA(lda_12, li_16, 0);
   return (ld_24);
}

double ZeroLagEMA(double ada_0[], double ada_4[], int ai_8, int ai_12) {
   double ld_16 = 2.0 / (ai_8 + 1);
   int li_24 = (ai_8 - 1) / 2.0;
   return (ld_16 * (2.0 * ada_0[ai_12] - (ada_0[ai_12 + li_24])) + (1 - ld_16) * (ada_4[ai_12 + 1]));
}

double NonLagEMA(double ada_0[], double &ada_4[], double &ada_8[], double &ada_12[], int ai_16) {
   double ld_28;
   double ld_36;
   double ld_44;
   double ld_52;
   double ld_60;
   double ld_20 = 0;
   for (g_index_184 = 0; g_index_184 <= gi_192 - 1; g_index_184++) {
      ld_28 = ada_0[g_index_184 + ai_16];
      ld_20 += gda_180[g_index_184] * ld_28;
   }
   if (gd_232 > 0.0) ada_4[ai_16] = (NLMADeviation / 100.0 + 1.0) * ld_20 / gd_232;
   if (NLMAPctFilter > 0.0) {
      ada_8[ai_16] = MathAbs(ada_4[ai_16] - (ada_4[ai_16 + 1]));
      ld_36 = 0;
      for (g_index_184 = 0; g_index_184 <= MAPeriod - 1; g_index_184++) ld_36 += ada_8[ai_16 + g_index_184];
      ada_12[ai_16] = ld_36 / MAPeriod;
      ld_44 = 0;
      for (g_index_184 = 0; g_index_184 <= MAPeriod - 1; g_index_184++) ld_44 += MathPow(ada_8[ai_16 + g_index_184] - (ada_12[ai_16 + g_index_184]), 2);
      ld_52 = MathSqrt(ld_44 / MAPeriod);
      ld_60 = NLMAPctFilter * ld_52;
      if (MathAbs(ada_4[ai_16] - (ada_4[ai_16 + 1])) < ld_60) ada_4[ai_16] = ada_4[ai_16 + 1];
   }
   return (0.0);
}