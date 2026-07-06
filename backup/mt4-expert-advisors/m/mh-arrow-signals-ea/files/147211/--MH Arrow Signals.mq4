// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72657


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
//|                                                                       https://mario-jemic.com/ |
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
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

extern int NumBars = 500;
double g_ibuf_80[];
double g_ibuf_84[];
double gd_88;

int init() {
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexBuffer(0, g_ibuf_80);
   SetIndexArrow(0, 233);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexBuffer(1, g_ibuf_84);
   SetIndexArrow(1, 234);
   gd_88 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   double lda_60[100];
   int l_ind_counted_0 = IndicatorCounted();
   int li_4 = 7;
   double ld_8 = 7.0;
   double ld_16 = 0.7;
   int li_24 = 0;
   int i = 0;
   bool li_32 = TRUE;
   double ld_36 = 0;
   double ld_44 = 0;
   double ld_52 = 0;
   int l_index_64 = 0;
   double ld_68 = 0;
   int l_index_76 = 0;
   double ld_80 = 0;
   double ld_96 = 0;
   int li_104 = 0;
   int li_108 = 0;
   double l_iatr_112 = 0;
   double ld_120 = 2;
   double ld_136 = 0;
   double ld_144 = 0;
   if (Bars < NumBars) 
      li_24 = Bars;
   else 
      li_24 = NumBars;
   if (Close[li_24 - 2] > Close[li_24 - 1]) 
      li_32 = TRUE;
   else 
      li_32 = FALSE;
   ld_36 = Close[li_24 - 2];
   for (i = MathMax(1, li_24 - 3); i >= 1; i--) 
   {
      ld_52 = gd_88 + High[i] - Low[i];
      if (MathAbs(gd_88 + High[i] - (Close[i + 1])) > ld_52) 
         ld_52 = MathAbs(gd_88 + High[i] - (Close[i + 1]));
      if (MathAbs(Low[i] - (Close[i + 1])) > ld_52) 
         ld_52 = MathAbs(Low[i] - (Close[i + 1]));
      if (i == li_24 - 3) 
      {
         for (l_index_76 = 0; i <= li_4 - 1; l_index_76++) 
            lda_60[l_index_76] = ld_52;
      }
      lda_60[l_index_64] = ld_52;
      ld_68 = 0;
      ld_80 = li_4;
      li_108 = l_index_64;
      for (l_index_76 = 0; l_index_76 <= li_4 - 1; l_index_76++) 
      {
         ld_68 += lda_60[li_108] * ld_80;
         ld_80 -= 1.0;
         li_108--;
         if (li_108 == -1) 
            li_108 = li_4 - 1;
      }
      ld_68 = 2.0 * ld_68 / (ld_8 * (ld_8 + 1.0));
      l_index_64++;
      if (l_index_64 == li_4) 
         l_index_64 = 0;
      ld_44 = ld_16 * ld_68;
      if (li_32 && Low[i] < ld_36 - ld_44) 
      {
         li_32 = FALSE;
         ld_36 = gd_88 + High[i];
      }
      if (!li_32 && gd_88 + High[i] > ld_36 + ld_44) 
      {
         li_32 = TRUE;
         ld_36 = Low[i];
      }
      if (li_32 && Low[i] > ld_36) 
         ld_36 = Low[i];
      if (!li_32 && gd_88 + High[i] < ld_36) 
         ld_36 = gd_88 + High[i];
      l_iatr_112 = iATR(NULL, 0, 10, i);
      ld_136 = 0;
      ld_144 = 0;
      if (li_32) 
      {
         if (li_104 != 1) 
            ld_96 = Low[i] - l_iatr_112 * ld_120 / 3.0;
         if (li_104 == 1) 
            ld_96 = -1.0;
         if (ld_96 > 0.0) 
         {
            ld_136 = ld_96;
            ld_144 = 0;
         } 
         else 
         {
            ld_136 = 0;
            ld_144 = 0;
         }
         g_ibuf_80[i] = ld_136;
         li_104 = 1;
      }
      else 
      {
         if (li_104 != 2) 
            ld_96 = gd_88 + High[i] + l_iatr_112 * ld_120 / 3.0;
         if (li_104 == 2) 
            ld_96 = -1.0;
         if (ld_96 > 0.0) 
         {
            ld_136 = 0;
            ld_144 = ld_96;
         } 
         else 
         {
            ld_136 = 0;
            ld_144 = 0;
         }
         g_ibuf_84[i] = ld_144;
         li_104 = 2;
      }
   }
   return (0);
}