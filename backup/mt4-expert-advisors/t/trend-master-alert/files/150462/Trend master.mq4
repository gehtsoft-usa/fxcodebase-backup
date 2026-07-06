// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73616

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  |
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
 
#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

extern int RISK = 2;
extern int CountBars = 2800;

double g_ibuf_84[];
double g_ibuf_88[];

int init() {
   IndicatorBuffers(2);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 234);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 233);
   SetIndexBuffer(0, g_ibuf_84);
   SetIndexBuffer(1, g_ibuf_88);
   return (0);
}

int start() {
   int li_12;
   double ld_52;
   double ld_60;
   double ld_68;
   double ld_76;
   double ld_84;
   double ld_92;
   double ld_100;
   double lda_108[1000];
   if (CountBars >= 1000) CountBars = 950;
   SetIndexDrawBegin(0, Bars - CountBars + 11 + 1);
   SetIndexDrawBegin(1, Bars - CountBars + 11 + 1);
   int l_ind_counted_8 = IndicatorCounted();
   int li_20 = RISK << 1 + 3;
   double ld_36 = RISK + 67;
   double ld_44 = 33 - RISK;
   int l_period_24 = li_20;
   if (Bars <= 12) return (0);
   if (l_ind_counted_8 < 12) {
      for (int li_0 = 1; li_0 <= 0; li_0++) g_ibuf_84[CountBars - li_0] = 0.0;
      for (li_0 = 1; li_0 <= 0; li_0++) g_ibuf_88[CountBars - li_0] = 0.0;
   }
   for (int li_4 = CountBars - 11 - 1; li_4 >= 0; li_4--) {
      li_12 = li_4;
      ld_76 = 0.0;
      ld_84 = 0.0;
      for (li_12 = li_4; li_12 <= li_4 + 9; li_12++) ld_84 += MathAbs(High[li_12] - Low[li_12]);
      ld_76 = ld_84 / 10.0;
      li_12 = li_4;
      ld_68 = 0;
      while (li_12 < li_4 + 9 && ld_68 < 1.0) {
         if (MathAbs(Open[li_12] - (Close[li_12 + 1])) >= 2.0 * ld_76) ld_68 += 1.0;
         li_12++;
      }
      if (ld_68 >= 1.0) ld_92 = li_12;
      else ld_92 = -1;
      li_12 = li_4;
      ld_68 = 0;
      while (li_12 < li_4 + 6 && ld_68 < 1.0) {
         if (MathAbs(Close[li_12 + 3] - Close[li_12]) >= 4.6 * ld_76) ld_68 += 1.0;
         li_12++;
      }
      if (ld_68 >= 1.0) ld_100 = li_12;
      else ld_100 = -1;
      if (ld_92 > -1.0) l_period_24 = 3;
      else l_period_24 = li_20;
      if (ld_100 > -1.0) l_period_24 = 4;
      else l_period_24 = li_20;
      ld_52 = 100 - MathAbs(iWPR(NULL, 0, l_period_24, li_4));
      lda_108[li_4] = ld_52;
      g_ibuf_84[li_4] = 0;
      g_ibuf_88[li_4] = 0;
      ld_60 = 0;
      if (ld_52 < ld_44) {
         for (int li_16 = 1; lda_108[li_4 + li_16] >= ld_44 && lda_108[li_4 + li_16] <= ld_36; li_16++) {
         }
         if (lda_108[li_4 + li_16] > ld_36) {
            ld_60 = High[li_4] + ld_76 / 2.0;
            g_ibuf_84[li_4] = ld_60;
         }
      }
      if (ld_52 > ld_36) {
         for (li_16 = 1; lda_108[li_4 + li_16] >= ld_44 && lda_108[li_4 + li_16] <= ld_36; li_16++) {
         }
         if (lda_108[li_4 + li_16] < ld_44) {
            ld_60 = Low[li_4] - ld_76 / 2.0;
            g_ibuf_88[li_4] = ld_60;
         }
      }
   }
   return (0);
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