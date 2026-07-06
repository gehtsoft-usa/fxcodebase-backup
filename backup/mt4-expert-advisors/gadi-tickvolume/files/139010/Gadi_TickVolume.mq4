// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70643

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
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 Ivory

int TF;
input int _TF = 0;
input int G_period_80 = 12;
input int G_period_84 = 12;
input int G_period_88 = 7;
int Gi_100 = 1000;
int Gi_120 = 1;
bool Gi_124 = FALSE;
string Gs_136 = "";
datetime G_time_144 = -999999;
string Gs_148 = "TVI change: UP";
string Gs_156 = "TVI change: DOWN";
int Gi_164 = 5;
datetime G_time_168;
string Gs_172;
double G_ibuf_180[];
double G_ibuf_184[];
double G_ibuf_188[];
double G_ibuf_192[];
double G_ibuf_196[];
double G_ibuf_200[];
double G_ibuf_204[];
double Gda_208[];
double Gda_212[];
double Gda_216[];
double Gda_220[];
double Gda_224[];
double Gda_228[];

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   IndicatorDigits(Gi_164);
   IndicatorBuffers(7);
   SetIndexBuffer(0, G_ibuf_180);
   SetIndexBuffer(1, G_ibuf_184);
   SetIndexBuffer(2, G_ibuf_188);
   SetIndexBuffer(3, G_ibuf_192);
   SetIndexBuffer(4, G_ibuf_196);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexStyle(3, DRAW_HISTOGRAM);
   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(5, G_ibuf_200);
   SetIndexBuffer(6, G_ibuf_204);
   ArrayResize(Gda_208, Gi_100);
   ArraySetAsSeries(Gda_208, TRUE);
   ArrayResize(Gda_212, Gi_100);
   ArraySetAsSeries(Gda_212, TRUE);
   ArrayResize(Gda_216, Gi_100);
   ArraySetAsSeries(Gda_216, TRUE);
   ArrayResize(Gda_220, Gi_100);
   ArraySetAsSeries(Gda_220, TRUE);
   ArrayResize(Gda_224, Gi_100);
   ArraySetAsSeries(Gda_224, TRUE);
   ArrayResize(Gda_228, Gi_100);
   ArraySetAsSeries(Gda_228, TRUE);
   SetIndexLabel(0, NULL);
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL);
   SetIndexLabel(3, NULL);
   SetIndexLabel(4, "Gadi_TickVolume");
   G_time_168 = Time[0];
   TF = _TF;
   if (TF == 0) TF = Period();
   Gs_172 = "Gadi_TickVolume_v2.2 (TF = " + TF + " Min.)";
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   ObjectDelete("UpTicks1" + Gs_172);
   ObjectDelete("DownTicks1" + Gs_172);
   ObjectDelete("UpTicks2" + Gs_172);
   ObjectDelete("DownTicks2" + Gs_172);
   ObjectDelete("diff2" + Gs_172);
   ObjectDelete("Trend" + Gs_172);
   Comment("");
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   string Ls_12;
   IndicatorShortName(Gs_172);
   ObjectDelete("UpTicks1" + Gs_172);
   ObjectDelete("DownTicks1" + Gs_172);
   ObjectDelete("UpTicks2" + Gs_172);
   ObjectDelete("DownTicks2" + Gs_172);
   ObjectDelete("Trend" + Gs_172);
   int Li_0 = IndicatorCounted();
   if (Li_0 < 0) return (-1);
   if (Li_0 > 0) Li_0--;
   int Li_4 = MathMin(Gi_100, Bars - Li_0) - 1.0;
   if (Time[0] != G_time_168) f0_0(Gi_100);
   for (int Li_8 = Li_4; Li_8 >= 0; Li_8--) {
      Gda_208[Li_8] = (iVolume(NULL, TF, Li_8) + (iClose(NULL, TF, Li_8) - iOpen(NULL, TF, Li_8)) / Point) / 2.0;
      Gda_212[Li_8] = iVolume(NULL, TF, Li_8) - Gda_208[Li_8];
   }
   for (Li_8 = Li_4; Li_8 >= 0; Li_8--) {
      Gda_216[Li_8] = iMAOnArray(Gda_208, 0, G_period_80, 0, MODE_EMA, Li_8);
      Gda_220[Li_8] = iMAOnArray(Gda_212, 0, G_period_80, 0, MODE_EMA, Li_8);
   }
   for (Li_8 = Li_4; Li_8 >= 0; Li_8--) {
      Gda_224[Li_8] = iMAOnArray(Gda_216, 0, G_period_84, 0, MODE_EMA, Li_8);
      Gda_228[Li_8] = iMAOnArray(Gda_220, 0, G_period_84, 0, MODE_EMA, Li_8);
   }
   for (Li_8 = Li_4; Li_8 >= 0; Li_8--) G_ibuf_200[Li_8] = 100.0 * (Gda_224[Li_8] - Gda_228[Li_8]) / (Gda_224[Li_8] + Gda_228[Li_8]);
   for (Li_8 = Li_4; Li_8 >= 0; Li_8--) G_ibuf_196[Li_8] = iMAOnArray(G_ibuf_200, 0, G_period_88, 0, MODE_EMA, Li_8);
   for (Li_8 = Li_4; Li_8 >= 0; Li_8--) {
      G_ibuf_204[Li_8] = G_ibuf_204[Li_8 + 1];
      if (G_ibuf_196[Li_8] > G_ibuf_196[Li_8 + 1]) G_ibuf_204[Li_8] = 1;
      else
         if (G_ibuf_196[Li_8] < G_ibuf_196[Li_8 + 1]) G_ibuf_204[Li_8] = -1;
      if (G_ibuf_204[Li_8] > 0.0) {
         if (G_ibuf_196[Li_8] >= 0.0) {
            G_ibuf_180[Li_8] = G_ibuf_196[Li_8];
            G_ibuf_184[Li_8] = EMPTY_VALUE;
            continue;
         }
         G_ibuf_188[Li_8] = G_ibuf_196[Li_8];
         G_ibuf_192[Li_8] = EMPTY_VALUE;
      } else {
         if (G_ibuf_204[Li_8] < 0.0) {
            if (G_ibuf_196[Li_8] >= 0.0) {
               G_ibuf_184[Li_8] = G_ibuf_196[Li_8];
               G_ibuf_180[Li_8] = EMPTY_VALUE;
               continue;
            }
            G_ibuf_192[Li_8] = G_ibuf_196[Li_8];
            G_ibuf_188[Li_8] = EMPTY_VALUE;
         }
      }
   }
   if (G_ibuf_204[0] == 1.0) Ls_12 = "UP Trend";
   else Ls_12 = "DOWN Trend";
   IndicatorShortName(Gs_172);
   f0_2();
   string Ls_20 = " Buyers: " + DoubleToStr(Gda_208[0], 0) + "";
   string Ls_28 = "Sellers: " + DoubleToStr(Gda_212[0], 0) + "";
   double diff = Gda_208[0] - Gda_212[0];
   string diffLabel = DoubleToStr(diff, 0);
   ObjectCreate("Trend" + Gs_172, OBJ_LABEL, WindowFind(Gs_172), 0, 0);
   if (G_ibuf_204[0] == 1.0) 
      ObjectSetText("Trend" + Gs_172, StringSubstr(Ls_12, 0), 12, "Tahoma", Green);
   else 
      ObjectSetText("Trend" + Gs_172, StringSubstr(Ls_12, 0), 12, "Tahoma", Red);
   ObjectSet("Trend" + Gs_172, OBJPROP_CORNER, 1);
   ObjectSet("Trend" + Gs_172, OBJPROP_XDISTANCE, 120);
   ObjectSet("Trend" + Gs_172, OBJPROP_YDISTANCE, 6);
   ObjectCreate("UpTicks2" + Gs_172, OBJ_LABEL, WindowFind(Gs_172), 0, 0);
   ObjectSetText("UpTicks2" + Gs_172, StringSubstr(Ls_20, 0), 10, "Tahoma", Green);
   ObjectSet("UpTicks2" + Gs_172, OBJPROP_CORNER, 1);
   ObjectSet("UpTicks2" + Gs_172, OBJPROP_XDISTANCE, 120);
   ObjectSet("UpTicks2", OBJPROP_YDISTANCE, 30);

   ObjectCreate("DownTicks2" + Gs_172, OBJ_LABEL, WindowFind(Gs_172), 0, 0);
   ObjectSetText("DownTicks2" + Gs_172, StringSubstr(Ls_28, 0), 10, "Tahoma", Red);
   ObjectSet("DownTicks2" + Gs_172, OBJPROP_CORNER, 1);
   ObjectSet("DownTicks2" + Gs_172, OBJPROP_XDISTANCE, 120);
   ObjectSet("DownTicks2" + Gs_172, OBJPROP_YDISTANCE, 30);
   
   ObjectCreate("diff2" + Gs_172, OBJ_LABEL, WindowFind(Gs_172), 0, 0);
   ObjectSet("diff2" + Gs_172, OBJPROP_CORNER, 1);
   ObjectSet("diff2" + Gs_172, OBJPROP_XDISTANCE, 120);
   ObjectSet("diff2" + Gs_172, OBJPROP_YDISTANCE, 70);
   ObjectSetInteger(0, "diff2" + Gs_172, OBJPROP_FONTSIZE, 10);
   ObjectSetString(0, "diff2" + Gs_172, OBJPROP_FONT, "Tahoma");
   ObjectSetInteger(0, "diff2" + Gs_172, OBJPROP_COLOR, diff < 0 ? Red : Green);
   ObjectSetString(0, "diff2" + Gs_172, OBJPROP_TEXT, "Diff: " + diffLabel);
   return (0);
}

// 001265269AEC7C79F32AB4F9E855729E
void f0_0(int Ai_0) {
   for (int Li_4 = Ai_0 - 1; Li_4 >= 0; Li_4--) {
      Gda_208[Li_4 + 1] = Gda_208[Li_4];
      Gda_212[Li_4 + 1] = Gda_212[Li_4];
      Gda_216[Li_4 + 1] = Gda_216[Li_4];
      Gda_220[Li_4 + 1] = Gda_220[Li_4];
      Gda_224[Li_4 + 1] = Gda_224[Li_4];
      Gda_228[Li_4 + 1] = Gda_228[Li_4];
   }
   G_time_168 = Time[0];
}

// 3E850E0492611BC4EC9CFAEED504BFC8
void f0_2() {
   string Ls_0;
   if (Gi_120 >= 0 && Time[0] > G_time_144) {
      if (G_ibuf_204[Gi_120] == 1.0 && G_ibuf_204[Gi_120 + 1] != 1.0) {
         Ls_0 = Symbol() + "," + f0_1(Period()) + ": " + Gs_148;
         if (Gi_124) Alert(Ls_0);
         if (Gs_136 > "") SendMail(Gs_136, Ls_0);
         G_time_144 = Time[0];
      }
      if (G_ibuf_204[Gi_120] == -1.0 && G_ibuf_204[Gi_120 + 1] != -1.0) {
         Ls_0 = Symbol() + "," + f0_1(Period()) + ": " + Gs_156;
         if (Gi_124) Alert(Ls_0);
         if (Gs_136 > "") SendMail(Gs_136, Ls_0);
         G_time_144 = Time[0];
      }
   }
}

// 1BA399D3D422CBE74D474C4355C7665D
string f0_1(int A_timeframe_0) {
   if (A_timeframe_0 == 0) A_timeframe_0 = Period();
   if (A_timeframe_0 >= PERIOD_MN1) return ("MN");
   if (A_timeframe_0 >= PERIOD_W1) return ("W1");
   if (A_timeframe_0 >= PERIOD_D1) return ("D1");
   if (A_timeframe_0 >= PERIOD_H4) return ("H4");
   if (A_timeframe_0 >= PERIOD_H1) return ("H1");
   if (A_timeframe_0 >= PERIOD_M30) return ("M30");
   if (A_timeframe_0 >= PERIOD_M15) return ("M15");
   if (A_timeframe_0 >= PERIOD_M5) return ("M5");
   if (A_timeframe_0 >= PERIOD_M1) return ("M1");
   return ("");
}
