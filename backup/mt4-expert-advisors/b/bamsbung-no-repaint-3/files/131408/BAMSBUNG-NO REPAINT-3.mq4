// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69434

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property indicator_separate_window
#property indicator_levelcolor CLR_NONE
#property indicator_buffers 4
#property indicator_color1 Black
#property indicator_color2 Black
#property indicator_color3 White
#property indicator_color4 Red

#import "BAMSBUNG.dll"
   void fastSingular(double& a0[], int a1, int a2, int a3, double& a4[]);
#import

input string Gs_76 = "Current time frame";
int G_applied_price_84 = PRICE_CLOSE;
int Gi_88 = 10;
int Gi_92 = 2;
int G_period_96 = 20;
int Gi_100 = 500;
int G_period_104 = 2;
int G_ma_method_108 = MODE_LWMA;
int G_period_112 = 7;
int G_ma_method_116 = MODE_LWMA;
int G_period_120 = 10;
int G_ma_method_124 = MODE_LWMA;
double Gd_128 = 98.0;
int Gi_136 = 0;
double Gd_140 = -0.4;
double Gd_148 = 0.0;
double Gd_156 = 0.4;
int Gi_164 = 1;
extern string _ = "alerts settings";
extern bool alertsOn = TRUE;
extern bool alertsOnCurrent = TRUE;
extern bool alertsMessage = FALSE;
extern bool alertsSound = FALSE;
extern bool alertsEmail = FALSE;
extern bool ShowArrows = TRUE;
extern string arrowsIdentifier = "BAMSBUNG arrows";
extern color arrowsUpColor = Lime;
extern color arrowsDnColor = Red;
double G_ibuf_216[];
double G_ibuf_220[];
double G_ibuf_224[];
double G_ibuf_228[];
double G_ibuf_232[];
double G_ibuf_236[];
double G_ibuf_240[];
double G_ibuf_244[];
double Gda_248[];
double Gda_252[];
string Gs_256;
bool Gi_264;
bool Gi_268;
int G_timeframe_272;
double Gd_276;
string Gsa_284[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int Gia_288[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};
string Gs_nothing_292 = "nothing";
datetime G_time_300;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   IndicatorBuffers(8);
   SetIndexBuffer(0, G_ibuf_216);
   SetIndexBuffer(1, G_ibuf_220);
   SetIndexBuffer(2, G_ibuf_224);
   SetIndexBuffer(3, G_ibuf_228);
   SetIndexBuffer(4, G_ibuf_232);
   SetIndexBuffer(5, G_ibuf_236);
   SetIndexBuffer(6, G_ibuf_240);
   SetIndexBuffer(7, G_ibuf_244);
   Gd_128 = MathMax(MathMin(Gd_128, 99.9999999999), 0.0000000001);
   Gd_276 = f0_2((Gd_128 + (100 - Gd_128) / 2.0) / 100.0);
   Gs_256 = WindowExpertName();
   Gi_264 = Gs_76 == "calculateValue";
   if (Gi_264) return (0);
   Gi_268 = Gs_76 == "returnBars";
   if (Gi_268) return (0);
   G_timeframe_272 = f0_7(Gs_76);
   SetLevelValue(0, Gd_156);
   SetLevelValue(1, Gd_148);
   SetLevelValue(2, Gd_140);
   IndicatorShortName(f0_9(G_timeframe_272) + "  BAMSBUNG NO REPAINT ");
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   string Lsa_unused_0[256];
   if ((!Gi_264) && ShowArrows) f0_5();
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int Li_0;
   double ima_4;
   double Ld_12;
   double ima_20;
   double Ld_28;
   double Ld_36;
   int shift_44;
   int datetime_48;
   string Ls_52 = "2030.03.25";
   int str2time_60 = StrToTime(Ls_52);
   if (TimeCurrent() >= str2time_60) {
      Alert("Sory indicator #Bamsbung No Repaint Expired Please contact www.bamsbung.com ");
      return (0);
   }
   int Li_64 = IndicatorCounted();
   if (Li_64 < 0) return (-1);
   if (Li_64 > 0) Li_64--;
   int Li_68 = MathMin(Bars - Li_64, Bars - 1);
   if (Gi_268) {
      G_ibuf_216[0] = Li_68 + 1;
      return (0);
   }
   if (Gi_264 || G_timeframe_272 == Period()) {
      Li_0 = MathMin(Bars - 1, Gi_100);
      for (int Li_72 = Li_68; Li_72 >= 0; Li_72--) {
         ima_4 = iMA(NULL, 0, G_period_96, 0, MODE_SMA, G_applied_price_84, Li_72);
         Ld_12 = 3.0 * iStdDev(NULL, 0, G_period_96, 0, MODE_SMA, G_applied_price_84, Li_72);
         ima_20 = iMA(NULL, 0, 1, 0, MODE_SMA, G_applied_price_84, Li_72);
         G_ibuf_236[Li_72] = (ima_20 - ima_4) / MathMax(Ld_12, 0.000001);
         if (ArraySize(Gda_248) != Li_0) {
            ArrayResize(Gda_248, Li_0);
            ArrayResize(Gda_252, Li_0);
         }
         ArrayCopy(Gda_248, G_ibuf_236, 0, 0, Li_0);
         fastSingular(Gda_248, Li_0, Gi_88, Gi_92, Gda_252);
         ArrayCopy(G_ibuf_232, Gda_252);
      }
      for (Li_72 = Li_68 - 1; Li_72 >= 0; Li_72--) {
         G_ibuf_224[Li_72] = iMAOnArray(G_ibuf_232, 0, G_period_104, 0, G_ma_method_108, Li_72);
         G_ibuf_228[Li_72] = iMAOnArray(G_ibuf_232, 0, G_period_112, 0, G_ma_method_116, Li_72);
         G_ibuf_240[Li_72] = iMAOnArray(G_ibuf_232, 0, G_period_120, 0, G_ma_method_124, Li_72);
         Ld_28 = f0_6(G_ibuf_232, G_period_120, G_ibuf_240[Li_72 + Gi_136], Li_72 + Gi_136);
         Ld_36 = Gd_276 * Ld_28 / MathSqrt(G_period_120);
         G_ibuf_216[Li_72] = G_ibuf_240[Li_72 + Gi_136] + Ld_36;
         G_ibuf_220[Li_72] = G_ibuf_240[Li_72 + Gi_136] - Ld_36;
         G_ibuf_244[Li_72] = G_ibuf_244[Li_72 + 1];
         if (G_ibuf_224[Li_72] > G_ibuf_228[Li_72]) G_ibuf_244[Li_72] = 1;
         if (G_ibuf_224[Li_72] < G_ibuf_228[Li_72]) G_ibuf_244[Li_72] = -1;
         if (!Gi_264) f0_10(Li_72);
      }
      f0_1();
      return (0);
   }
   Li_68 = MathMin(Bars, Gi_100 * G_timeframe_272 / Period());
   for (Li_72 = Li_68; Li_72 >= 0; Li_72--) {
      shift_44 = iBarShift(NULL, G_timeframe_272, Time[Li_72]);
      G_ibuf_216[Li_72] = iCustom(NULL, G_timeframe_272, Gs_256, "calculateValue", G_applied_price_84, Gi_88, Gi_92, G_period_96, Gi_100, G_period_104, G_ma_method_108,
         G_period_112, G_ma_method_116, G_period_120, G_ma_method_124, Gd_128, Gi_136, 0, shift_44);
      G_ibuf_220[Li_72] = iCustom(NULL, G_timeframe_272, Gs_256, "calculateValue", G_applied_price_84, Gi_88, Gi_92, G_period_96, Gi_100, G_period_104, G_ma_method_108,
         G_period_112, G_ma_method_116, G_period_120, G_ma_method_124, Gd_128, Gi_136, 1, shift_44);
      G_ibuf_224[Li_72] = iCustom(NULL, G_timeframe_272, Gs_256, "calculateValue", G_applied_price_84, Gi_88, Gi_92, G_period_96, Gi_100, G_period_104, G_ma_method_108,
         G_period_112, G_ma_method_116, G_period_120, G_ma_method_124, Gd_128, Gi_136, 2, shift_44);
      G_ibuf_228[Li_72] = iCustom(NULL, G_timeframe_272, Gs_256, "calculateValue", G_applied_price_84, Gi_88, Gi_92, G_period_96, Gi_100, G_period_104, G_ma_method_108,
         G_period_112, G_ma_method_116, G_period_120, G_ma_method_124, Gd_128, Gi_136, 3, shift_44);
      G_ibuf_244[Li_72] = iCustom(NULL, G_timeframe_272, Gs_256, "calculateValue", G_applied_price_84, Gi_88, Gi_92, G_period_96, Gi_100, G_period_104, G_ma_method_108,
         G_period_112, G_ma_method_116, G_period_120, G_ma_method_124, Gd_128, Gi_136, 7, shift_44);
      f0_10(Li_72);
      if (!Gi_164 || shift_44 == iBarShift(NULL, G_timeframe_272, Time[Li_72 - 1])) continue;
      datetime_48 = iTime(NULL, G_timeframe_272, shift_44);
      for (int Li_76 = 1; Li_72 + Li_76 < Bars && Time[Li_72 + Li_76] >= datetime_48; Li_76++) {
      }
      for (int Li_80 = 1; Li_80 < Li_76; Li_80++) {
         G_ibuf_216[Li_72 + Li_80] = G_ibuf_216[Li_72] + (G_ibuf_216[Li_72 + Li_76] - G_ibuf_216[Li_72]) * Li_80 / Li_76;
         G_ibuf_220[Li_72 + Li_80] = G_ibuf_220[Li_72] + (G_ibuf_220[Li_72 + Li_76] - G_ibuf_220[Li_72]) * Li_80 / Li_76;
         G_ibuf_224[Li_72 + Li_80] = G_ibuf_224[Li_72] + (G_ibuf_224[Li_72 + Li_76] - G_ibuf_224[Li_72]) * Li_80 / Li_76;
         G_ibuf_228[Li_72 + Li_80] = G_ibuf_228[Li_72] + (G_ibuf_228[Li_72 + Li_76] - G_ibuf_228[Li_72]) * Li_80 / Li_76;
      }
   }
   f0_1();
   return (0);
}

// 6ABA3523C7A75AAEA41CC0DEC7953CC5
double f0_6(double Ada_0[], double Ad_4, double Ad_12, int Ai_20, bool Ai_24 = TRUE) {
   double Ld_28 = 0.0;
   for (int count_36 = 0; count_36 < Ad_4; count_36++) Ld_28 += MathPow(Ada_0[Ai_20 + count_36] - Ad_12, 2);
   if (Ai_24) return (MathSqrt(Ld_28 / (Ad_4 - 1.0)));
   return (MathSqrt(Ld_28 / Ad_4));
}

// 78BAA8FAE18F93570467778F2E829047
int f0_7(string As_0) {
   As_0 = f0_8(As_0);
   for (int Li_8 = ArraySize(Gia_288) - 1; Li_8 >= 0; Li_8--)
      if (As_0 == Gsa_284[Li_8] || As_0 == "" + Gia_288[Li_8]) return (MathMax(Gia_288[Li_8], Period()));
   return (Period());
}

// 9B1AEE847CFB597942D106A4135D4FE6
string f0_9(int Ai_0) {
   for (int Li_4 = ArraySize(Gia_288) - 1; Li_4 >= 0; Li_4--)
      if (Ai_0 == Gia_288[Li_4]) return (Gsa_284[Li_4]);
   return ("");
}

// 945D754CB0DC06D04243FCBA25FC0802
string f0_8(string As_0) {
   int Li_8;
   string Ls_ret_12 = As_0;
   for (int Li_20 = StringLen(As_0) - 1; Li_20 >= 0; Li_20--) {
      Li_8 = StringGetChar(Ls_ret_12, Li_20);
      if ((Li_8 > '`' && Li_8 < '{') || (Li_8 > '�' && Li_8 < 256)) Ls_ret_12 = StringSetChar(Ls_ret_12, Li_20, Li_8 - 32);
      else
         if (Li_8 > -33 && Li_8 < 0) Ls_ret_12 = StringSetChar(Ls_ret_12, Li_20, Li_8 + 224);
   }
   return (Ls_ret_12);
}

// 2569208C5E61CB15E209FFE323DB48B7
void f0_1() {
   int Li_0;
   if ((!Gi_264) && alertsOn) {
      if (alertsOnCurrent) Li_0 = 0;
      else Li_0 = 1;
      Li_0 = iBarShift(NULL, 0, iTime(NULL, G_timeframe_272, Li_0));
      if (G_ibuf_244[Li_0] != G_ibuf_244[Li_0 + 1]) {
         if (G_ibuf_244[Li_0] == 1.0) f0_4(Li_0, "Buy Signal) ");
         if (G_ibuf_244[Li_0] == -1.0) f0_4(Li_0, "Sell Signal) ");
      }
   }
}

// 58B0897F29A3AD862616D6CBF39536ED
void f0_4(int Ai_0, string As_4) {
   string str_concat_12;
   if (Gs_nothing_292 != As_4 || G_time_300 != Time[Ai_0]) {
      Gs_nothing_292 = As_4;
      G_time_300 = Time[Ai_0];
      str_concat_12 = StringConcatenate(Symbol(), " ", f0_9(G_timeframe_272), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " BAMSBUNG trend changed to ", As_4);
      if (alertsMessage) Alert(str_concat_12);
      if (alertsEmail) SendMail(StringConcatenate(Symbol(), " SBNR8 "), str_concat_12);
      if (alertsSound) PlaySound("alert2.wav");
   }
}

// A9B24A824F70CC1232D1C2BA27039E8D
void f0_10(int Ai_0) {
   if (ShowArrows) {
      f0_11(Time[Ai_0]);
      if (G_ibuf_244[Ai_0] != G_ibuf_244[Ai_0 + 1]) {
         if (G_ibuf_244[Ai_0] == 1.0) f0_3(Ai_0, arrowsUpColor, 150, 0);
         if (G_ibuf_244[Ai_0] == -1.0) f0_3(Ai_0, arrowsDnColor, 153, 1);
      }
   }
}

// 5710F6E623305B2C1458238C9757193B
void f0_3(int Ai_0, color A_color_4, int Ai_8, bool Ai_12) {
   string name_16 = arrowsIdentifier + ":" + Time[Ai_0];
   double Ld_24 = 3.0 * iATR(NULL, 0, 20, Ai_0) / 4.0;
   ObjectCreate(name_16, OBJ_ARROW, 0, Time[Ai_0], 0);
   ObjectSet(name_16, OBJPROP_ARROWCODE, Ai_8);
   ObjectSet(name_16, OBJPROP_COLOR, A_color_4);
   if (Ai_12) {
      ObjectSet(name_16, OBJPROP_PRICE1, High[Ai_0] + Ld_24);
      return;
   }
   ObjectSet(name_16, OBJPROP_PRICE1, Low[Ai_0] - Ld_24);
}

// 689C35E4872BA754D7230B8ADAA28E48
void f0_5() {
   string name_0;
   string Ls_8 = arrowsIdentifier + ":";
   int str_len_16 = StringLen(Ls_8);
   for (int Li_20 = ObjectsTotal() - 1; Li_20 >= 0; Li_20--) {
      name_0 = ObjectName(Li_20);
      if (StringSubstr(name_0, 0, str_len_16) == Ls_8) ObjectDelete(name_0);
   }
}

// D1DDCE31F1A86B3140880F6B1877CBF8
void f0_11(int Ai_0) {
   string name_4 = arrowsIdentifier + ":" + Ai_0;
   ObjectDelete(name_4);
}

// 09CBB5F5CE12C31A043D5C81BF20AA4A
double f0_0(double Ad_0) {
   double Lda_8[] = {2.515517, 0.802853, 0.010328};
   double Lda_12[] = {1.432788, 0.189269, 0.001308};
   return (Ad_0 - ((Lda_8[2] * Ad_0 + Lda_8[1]) * Ad_0 + Lda_8[0]) / (((Lda_12[2] * Ad_0 + Lda_12[1]) * Ad_0 + Lda_12[0]) * Ad_0 + 1.0));
}

// 50257C26C4E5E915F022247BABD914FE
double f0_2(double Ad_0) {
   if (Ad_0 <= 0.0 || Ad_0 >= 1.0) return (0);
   if (Ad_0 < 0.5) return (-f0_0(MathSqrt(-2.0 * MathLog(Ad_0))));
   return (f0_0(MathSqrt(-2.0 * MathLog(1.0 - Ad_0))));
}