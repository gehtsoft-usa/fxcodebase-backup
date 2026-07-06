
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int barn = 1300;
extern int Length = 24;
double G_ibuf_84[];

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   SetIndexEmptyValue(0, 0.0);
   SetIndexBuffer(0, G_ibuf_84);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 164);
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int str2int_0;
   double low_4;
   double high_12;
   double Lda_20[10000][3];
//   string Ls_unused_24;
   /*if (Year() > 2020 || (Year() == 2020 && Month() >= 7 && Day() > 1)) {
      Alert("Your indicator is expired,please email wrt0306@gmail.com");
      return (-1);
   }*/
   int ind_counted_32 = IndicatorCounted();
   if (High[1] > High[0]) Comment("SELL !!");
   else
      if (High[1] < High[0]) Comment("BUY !!");
   int Li_36 = 0;
   int Li_40 = 0;
   int index_44 = 0;
   double high_48 = High[barn];
   double low_56 = Low[barn];
   int Li_64 = barn;
   int Li_68 = barn;
   for (int Li_72 = barn; Li_72 >= 0; Li_72--) {
      low_4 = 10000000;
      high_12 = -100000000;
      for (int Li_76 = Li_72 + Length; Li_76 >= Li_72 + 1; Li_76--) {
         if (Low[Li_76] < low_4) low_4 = Low[Li_76];
         if (High[Li_76] > high_12) high_12 = High[Li_76];
      }
      if (Low[Li_72] < low_4 && High[Li_72] > high_12) {
         Li_40 = 2;
         if (Li_36 == 1) Li_64 = Li_72 + 1;
         if (Li_36 == -1) Li_68 = Li_72 + 1;
      } else {
         if (Low[Li_72] < low_4) Li_40 = -1;
         if (High[Li_72] > high_12) Li_40 = 1;
      }
      if (Li_40 != Li_36 && Li_36 != 0) {
         if (Li_40 == 2) {
            Li_40 = -Li_36;
            high_48 = High[Li_72];
            low_56 = Low[Li_72];
         }
         index_44++;
         if (Li_40 == 1) {
            Lda_20[index_44][1] = Li_68;
            Lda_20[index_44][2] = low_56;
         }
         if (Li_40 == -1) {
            Lda_20[index_44][1] = Li_64;
            Lda_20[index_44][2] = high_48;
         }
         high_48 = High[Li_72];
         low_56 = Low[Li_72];
      }
      if (Li_40 == 1) {
         if (High[Li_72] >= high_48) {
            high_48 = High[Li_72];
            Li_64 = Li_72;
         }
      }
      if (Li_40 == -1) {
         if (Low[Li_72] <= low_56) {
            low_56 = Low[Li_72];
            Li_68 = Li_72;
         }
      }
      Li_36 = Li_40;
   }
   for (Li_76 = 1; Li_76 <= index_44; Li_76++) {
      str2int_0 = StrToInteger(DoubleToStr(Lda_20[Li_76][1], 0));
      G_ibuf_84[str2int_0] = Lda_20[Li_76][2];
   }
   return (0);
}
