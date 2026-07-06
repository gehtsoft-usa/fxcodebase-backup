/*
 --------
*/
#property copyright ""
#property link      ""

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
 /*  if (AccountNumber() != 122660) {
      Comment("FORBIDDEN!! :" + AccountNumber() + " You are using the software illegally!");
      return (0);
   }
   Comment("Member:  Gregory S. Kennedy   APPROVED");
 */
   int l_ind_counted_0 = IndicatorCounted();
   int li_4 = 7;
   double ld_8 = 7.0;
   double ld_16 = 0.7;
   int li_24 = 0;
   int li_28 = 0;
   bool li_32 = TRUE;
   double ld_36 = 0;
   double ld_44 = 0;
   double ld_52 = 0;
   int l_index_64 = 0;
   double ld_68 = 0;
   int l_index_76 = 0;
   double ld_80 = 0;
   double ld_unused_88 = 0;
   double ld_96 = 0;
   int li_104 = 0;
   int li_108 = 0;
   double l_iatr_112 = 0;
   double ld_120 = 2;
   double ld_unused_128 = 10;
   double ld_136 = 0;
   double ld_144 = 0;
   double ld_unused_152 = 0;
   double ld_unused_160 = 0;
   double ld_unused_168 = 0;
   double ld_unused_176 = 0;
   double ld_unused_184 = 0;
   double ld_unused_192 = 0;
   double ld_unused_200 = 0;
   double ld_unused_208 = 0;
   double ld_unused_216 = 0;
   double ld_unused_224 = 0;
   double ld_unused_232 = 0;
   double ld_unused_240 = 0;
   double ld_unused_248 = 0;
   double ld_unused_256 = 0;
   double ld_unused_264 = 0;
   double ld_unused_272 = 0;
   double ld_unused_280 = 0;
   double ld_unused_288 = 0;
   double ld_unused_296 = 0;
   double ld_unused_304 = 0;
   double ld_unused_312 = 0;
   double ld_unused_320 = 0;
   double ld_unused_328 = 0;
   if (Bars < NumBars) li_24 = Bars;
   else li_24 = NumBars;
   if (Close[li_24 - 2] > Close[li_24 - 1]) li_32 = TRUE;
   else li_32 = FALSE;
   ld_36 = Close[li_24 - 2];
   for (li_28 = li_24 - 3; li_28 >= 0; li_28--) {
      ld_52 = gd_88 + High[li_28] - Low[li_28];
      if (MathAbs(gd_88 + High[li_28] - (Close[li_28 + 1])) > ld_52) ld_52 = MathAbs(gd_88 + High[li_28] - (Close[li_28 + 1]));
      if (MathAbs(Low[li_28] - (Close[li_28 + 1])) > ld_52) ld_52 = MathAbs(Low[li_28] - (Close[li_28 + 1]));
      if (li_28 == li_24 - 3) for (l_index_76 = 0; li_28 <= li_4 - 1; l_index_76++) lda_60[l_index_76] = ld_52;
      lda_60[l_index_64] = ld_52;
      ld_68 = 0;
      ld_80 = li_4;
      li_108 = l_index_64;
      for (l_index_76 = 0; l_index_76 <= li_4 - 1; l_index_76++) {
         ld_68 += lda_60[li_108] * ld_80;
         ld_80 -= 1.0;
         li_108--;
         if (li_108 == -1) li_108 = li_4 - 1;
      }
      ld_68 = 2.0 * ld_68 / (ld_8 * (ld_8 + 1.0));
      l_index_64++;
      if (l_index_64 == li_4) l_index_64 = 0;
      ld_44 = ld_16 * ld_68;
      if (li_32 && Low[li_28] < ld_36 - ld_44) {
         li_32 = FALSE;
         ld_36 = gd_88 + High[li_28];
      }
      if (!li_32 && gd_88 + High[li_28] > ld_36 + ld_44) {
         li_32 = TRUE;
         ld_36 = Low[li_28];
      }
      if (li_32 && Low[li_28] > ld_36) ld_36 = Low[li_28];
      if (!li_32 && gd_88 + High[li_28] < ld_36) ld_36 = gd_88 + High[li_28];
      l_iatr_112 = iATR(NULL, 0, 10, li_28);
      ld_136 = 0;
      ld_144 = 0;
      if (li_32) {
         if (li_104 != 1) ld_96 = Low[li_28] - l_iatr_112 * ld_120 / 3.0;
         if (li_104 == 1) ld_96 = -1.0;
         if (ld_96 > 0.0) {
            ld_136 = ld_96;
            ld_144 = 0;
         } else {
            ld_136 = 0;
            ld_144 = 0;
         }
         g_ibuf_80[li_28] = ld_136;
         li_104 = 1;
      } else {
         if (li_104 != 2) ld_96 = gd_88 + High[li_28] + l_iatr_112 * ld_120 / 3.0;
         if (li_104 == 2) ld_96 = -1.0;
         if (ld_96 > 0.0) {
            ld_136 = 0;
            ld_144 = ld_96;
         } else {
            ld_136 = 0;
            ld_144 = 0;
         }
         g_ibuf_84[li_28] = ld_144;
         li_104 = 2;
      }
   }
   return (0);
}