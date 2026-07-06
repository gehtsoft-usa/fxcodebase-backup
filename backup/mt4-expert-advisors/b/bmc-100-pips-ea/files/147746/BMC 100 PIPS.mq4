// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72804

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
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 White

#import "user32.dll"
   int GetWindowRect(int a0, int& a1[]);
#import

extern int BPERIOD = 34;
int Gi_80 = 0;
extern int APERIOD = 3;
int G_applied_price_88 = PRICE_CLOSE;
double Gd_92 = 1.6;
bool Gi_100 = TRUE;
int G_width_104 = 2;
int Gi_108 = 999;
bool Gi_112 = FALSE;
extern int aTake_Profit = 88;
extern int aStop_Loss = 48;
extern bool aAlerts = TRUE;
extern bool EmailOn = TRUE;
int Gi_132 = 0;
double G_ibuf_136[];
double G_ibuf_140[];
datetime G_time_144;
string Gs_156;
string Gs_164 = "100pipstodayscalper";
double G_ibuf_172[];
double G_ibuf_176[];
double G_ibuf_180[];
double G_ibuf_184[];
string G_name_188 = "informerR";
string Gs_signall_196 = "signalL";
extern int SignalTextSize = 9;
int Gi_unused_208 = 18;
extern color BuySignalColor = Yellow;
extern color SellSignalColor = Red;
int Gi_220;
string Gs_224;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   IndicatorBuffers(6);
   SetIndexBuffer(0, G_ibuf_172);
   SetIndexBuffer(1, G_ibuf_180);
   SetIndexBuffer(2, G_ibuf_136);
   SetIndexBuffer(3, G_ibuf_140);
   SetIndexBuffer(4, G_ibuf_176);
   SetIndexBuffer(5, G_ibuf_184);
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexArrow(2, 171);
   SetIndexArrow(3, SYMBOL_STOPSIGN);
   if (Gi_100) {
      SetIndexStyle(0, DRAW_NONE, EMPTY, G_width_104 - 1);
      SetIndexStyle(1, DRAW_NONE, EMPTY, G_width_104 - 1);
      SetIndexStyle(4, DRAW_NONE, EMPTY, G_width_104 - 1);
      SetIndexArrow(0, 159);
      SetIndexArrow(1, 159);
      SetIndexArrow(4, 159);
   } else {
      SetIndexStyle(0, DRAW_NONE);
      SetIndexStyle(1, DRAW_NONE);
      SetIndexStyle(4, DRAW_NONE);
   }
   Gi_220 = BPERIOD + MathFloor(MathSqrt(BPERIOD));
   SetIndexDrawBegin(0, Gi_220);
   SetIndexDrawBegin(1, Gi_220);
   SetIndexDrawBegin(4, Gi_220);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS) + 1.0);
   IndicatorShortName("100pipstodayscalper(" + BPERIOD + ")");
   SetIndexLabel(0, "Up");
   SetIndexLabel(1, "Down");
   SetIndexLabel(2, "TP ");
   SetIndexLabel(3, "SL ");
   Gs_224 = Symbol() + " (" + f0_4() + "):  ";
   Gs_156 = "";
   ArrayInitialize(G_ibuf_172, EMPTY_VALUE);
   ArrayInitialize(G_ibuf_180, EMPTY_VALUE);
   ArrayInitialize(G_ibuf_176, EMPTY_VALUE);
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   f0_7();
   ObjectsDeleteAll(0, OBJ_TEXT);
   ObjectsDeleteAll(0, OBJ_LABEL);
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double ima_on_arr_20;
   int Li_unused_28;
   int ind_counted_8 = IndicatorCounted();
   if (ind_counted_8 < 1) {
      ArrayInitialize(G_ibuf_136, EMPTY_VALUE);
      ArrayInitialize(G_ibuf_140, EMPTY_VALUE);
      for (int Li_4 = 0; Li_4 <= Gi_220; Li_4++) G_ibuf_184[Bars - Li_4] = 0;
      for (Li_4 = 0; Li_4 <= BPERIOD; Li_4++) {
         G_ibuf_172[Bars - Li_4] = EMPTY_VALUE;
         G_ibuf_176[Bars - Li_4] = EMPTY_VALUE;
         G_ibuf_180[Bars - Li_4] = EMPTY_VALUE;
      }
   }
   int Li_0 = Bars - ind_counted_8;
   for (Li_4 = 1; Li_4 < Li_0; Li_4++) {
      G_ibuf_184[Li_4] = 2.0 * iMA(NULL, 0, MathFloor(BPERIOD / Gd_92), Gi_80, APERIOD, G_applied_price_88, Li_4) - iMA(NULL, 0, BPERIOD, Gi_80, APERIOD, G_applied_price_88,
         Li_4);
   }
   double ima_on_arr_12 = iMAOnArray(G_ibuf_184, 0, MathFloor(MathSqrt(BPERIOD)), 0, APERIOD, 1);
   for (Li_4 = 2; Li_4 < Li_0 + 1; Li_4++) {
      ima_on_arr_20 = iMAOnArray(G_ibuf_184, 0, MathFloor(MathSqrt(BPERIOD)), 0, APERIOD, Li_4);
      Li_unused_28 = 0;
      if (ima_on_arr_20 > ima_on_arr_12) {
         G_ibuf_180[Li_4 - 1] = ima_on_arr_12 - Gi_132 * Point;
         Li_unused_28 = 1;
      } else {
         if (ima_on_arr_20 < ima_on_arr_12) {
            G_ibuf_172[Li_4 - 1] = ima_on_arr_12 + Gi_132 * Point;
            Li_unused_28 = 2;
         } else {
            G_ibuf_172[Li_4 - 1] = EMPTY_VALUE;
            G_ibuf_176[Li_4 - 1] = ima_on_arr_12;
            G_ibuf_180[Li_4 - 1] = EMPTY_VALUE;
            Li_unused_28 = 3;
         }
      }
      if (ind_counted_8 > 0) {
      }
      ima_on_arr_12 = ima_on_arr_20;
   }
   if (Li_0 > Gi_108) Li_0 = Gi_108;
   for (Li_4 = 2; Li_4 <= Li_0; Li_4++) {
      if (G_ibuf_172[Li_4 - 1] != EMPTY_VALUE) {
         if (G_ibuf_172[Li_4] != EMPTY_VALUE) f0_9(Li_4 - 1, Li_4, 1);
         else {
            f0_9(Li_4 - 1, Li_4, 10);
            f0_2(Li_4, G_ibuf_180[Li_4], 0);
            if (Li_4 == 2) {
               G_ibuf_136[Li_4] = f0_6();
               G_ibuf_140[Li_4] = f0_5();
            } else {
               G_ibuf_136[Li_4] = G_ibuf_180[Li_4] + aTake_Profit * Point;
               G_ibuf_140[Li_4] = G_ibuf_180[Li_4] - aStop_Loss * Point;
            }
         }
      }
      if (G_ibuf_180[Li_4 - 1] != EMPTY_VALUE) {
         if (G_ibuf_180[Li_4] != EMPTY_VALUE) {
            f0_9(Li_4 - 1, Li_4, -1);
            continue;
         }
         f0_9(Li_4 - 1, Li_4, -10);
         f0_2(Li_4, G_ibuf_172[Li_4] + MathAbs(Close[Li_4] - iSAR(NULL, 0, 0.02, 0.2, Li_4)), 1);
         if (Li_4 == 2) {
            G_ibuf_136[Li_4] = f0_8();
            G_ibuf_140[Li_4] = f0_0();
            continue;
         }
         G_ibuf_136[Li_4] = G_ibuf_172[Li_4] - aTake_Profit * Point;
         G_ibuf_140[Li_4] = G_ibuf_172[Li_4] + aStop_Loss * Point;
      }
   }
   if (G_ibuf_180[1] != EMPTY_VALUE) f0_1(1);
   if (G_ibuf_172[1] != EMPTY_VALUE) f0_1(0);
   if (aAlerts) {
      if ((Gi_112 == FALSE && G_ibuf_180[1] != EMPTY_VALUE && G_ibuf_180[2] == EMPTY_VALUE) || (Gi_112 == TRUE && G_ibuf_180[1] != EMPTY_VALUE && G_ibuf_180[2] != EMPTY_VALUE &&
         G_ibuf_180[3] == EMPTY_VALUE)) f0_11("SELL", Close[1], f0_8(), f0_0());
      if ((Gi_112 == FALSE && G_ibuf_172[1] != EMPTY_VALUE && G_ibuf_172[2] == EMPTY_VALUE) || (Gi_112 == TRUE && G_ibuf_172[1] != EMPTY_VALUE && G_ibuf_172[2] != EMPTY_VALUE &&
         G_ibuf_172[3] == EMPTY_VALUE)) f0_11("BUY", Close[1], f0_6(), f0_5());
   }
   return (0);
}

// A175ED0148C846DCBD15C5151A4F0BAF
double f0_8() {
   return (Bid - aTake_Profit * Point);
}

// 8208878A4EC7F97E49E54D58CA29C1B1
double f0_6() {
   return (Ask + aTake_Profit * Point);
}

// 09F6C199E63778DA51A1332C863719B5
double f0_0() {
   return (Bid + aStop_Loss * Point);
}

// 639A219768B3E002B71140739E24DF1C
double f0_5() {
   return (Ask - aStop_Loss * Point);
}

// 2D323144BD979BFEF42292739B4C879E
int f0_3() {
   return (10000.0 * (BPERIOD * Point));
}

// 8999422E13CFB690048C3B2961EC2F9D
void f0_7() {
   string name_0;
   int str_len_12;
   for (int Li_8 = ObjectsTotal() - 1; Li_8 >= 0; Li_8--) {
      name_0 = ObjectName(Li_8);
      str_len_12 = StringLen(Gs_164);
      if (StringSubstr(name_0, 0, str_len_12) == Gs_164) ObjectDelete(name_0);
   }
}

// D57E9CBE9D7040E8047D5B01FCD8A6F1
void f0_9(int Ai_0, int Ai_4, int Ai_8) {
   double price_20;
   double price_28;
   color color_36;
   if (Ai_8 > 0) {
      price_20 = G_ibuf_172[Ai_0];
      if (Ai_8 == 1) price_28 = G_ibuf_172[Ai_4];
      else price_28 = G_ibuf_180[Ai_4];
      color_36 = Yellow;
   } else {
      price_20 = G_ibuf_180[Ai_0];
      if (Ai_8 == -1) price_28 = G_ibuf_180[Ai_4];
      else price_28 = G_ibuf_172[Ai_4];
      color_36 = Red;
   }
   int time_12 = Time[Ai_0];
   int time_16 = Time[Ai_4];
   if (price_20 == EMPTY_VALUE || price_28 == EMPTY_VALUE) {
      Print("Empty !");
      return;
   }
   string name_40 = Gs_164 + "_segment_" + color_36 + time_12 + "_" + time_16;
   ObjectDelete(name_40);
   ObjectCreate(name_40, OBJ_TREND, 0, time_12, price_20, time_16, price_28, 0, 0);
   ObjectSet(name_40, OBJPROP_WIDTH, G_width_104);
   ObjectSet(name_40, OBJPROP_COLOR, color_36);
   ObjectSet(name_40, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(name_40, OBJPROP_RAY, FALSE);
}

// 25648F908BDC21257A45044512A011C9
void f0_2(int Ai_0, double A_price_4, int Ai_12) {
   string text_16 = "UP";
   color color_24 = BuySignalColor;
   if (Ai_12 == 1) {
      text_16 = "DOWN";
      color_24 = SellSignalColor;
   }
   int time_28 = Time[Ai_0];
   string name_32 = Gs_signall_196 + DoubleToStr(time_28, 0);
   if (ObjectFind(name_32) != -1) ObjectDelete(name_32);
   ObjectCreate(name_32, OBJ_TEXT, 0, time_28, A_price_4);
   ObjectSetText(name_32, text_16, SignalTextSize);
   ObjectSet(name_32, OBJPROP_COLOR, color_24);
}

// 10A3AB1ECBA2B204BC0AA7FDB8382079
void f0_1(int Ai_0) {
   string text_4 = "SCALPING SIGNAL:     (TREND UP)";
   string text_12 = "                 BUY";
   color color_20 = BuySignalColor;
   if (Ai_0 == 1) {
      text_4 = "SCALPING SIGNAL:      (TREND DOWN)";
      text_12 = "                 SELL";
      color_20 = SellSignalColor;
   }
   int x_24 = 50;
   if (IsDllsAllowed()) x_24 = MathMax(f0_10() / 2 - 200, 50);
   if (ObjectFind(G_name_188) != -1 || ObjectCreate(G_name_188, OBJ_LABEL, 0, 0, 0)) {
      ObjectSetText(G_name_188, text_4, SignalTextSize, "Lucida Console", White);
      ObjectSet(G_name_188, OBJPROP_XDISTANCE, x_24);
      ObjectSet(G_name_188, OBJPROP_YDISTANCE, 20);
      ObjectSet(G_name_188, OBJPROP_CORNER, 2);
   }
   string name_28 = G_name_188 + "dir";
   if (ObjectFind(name_28) != -1 || ObjectCreate(name_28, OBJ_LABEL, 0, 0, 0)) {
      ObjectSetText(name_28, text_12, SignalTextSize, "Lucida Console", color_20);
      ObjectSet(name_28, OBJPROP_XDISTANCE, x_24);
      ObjectSet(name_28, OBJPROP_YDISTANCE, 20);
      ObjectSet(name_28, OBJPROP_CORNER, 2);
   }
}

// 4A3943D5FBF2CBD3EF4A02E976FC1018
string f0_4() {
   switch (Period()) {
   case PERIOD_M1:
      return ("M1");
   case PERIOD_M5:
      return ("M5");
   case PERIOD_M15:
      return ("M15");
   case PERIOD_M30:
      return ("M30");
   case PERIOD_H1:
      return ("H1");
   case PERIOD_H4:
      return ("H4");
   case PERIOD_D1:
      return ("D1");
   case PERIOD_W1:
      return ("W1");
   case PERIOD_MN1:
      return ("MN1");
   }
   return ("");
}

// EAC4E9E33F3538045A48AFD1169EE124
void f0_11(string As_0, double Ad_8, double Ad_16, double Ad_24) {
   string Ls_32;
   string Ls_40;
   string Ls_48;
   string Ls_56;
   if (Time[0] != G_time_144) {
      G_time_144 = Time[0];
      if (Gs_156 != As_0) {
         Gs_156 = As_0;
         if (Ad_8 != 0.0) Ls_48 = " @ " + DoubleToStr(Ad_8, 5);
         else Ls_48 = "";
         if (Ad_16 != 0.0) Ls_40 = ", TP   " + DoubleToStr(Ad_16, 5);
         else Ls_40 = "";
         if (Ad_24 != 0.0) Ls_32 = ", SL   " + DoubleToStr(Ad_24, 5);
         else Ls_32 = "";
         Ls_56 = Gs_224 + "100pipstodayscalper " + f0_3() + " " + As_0 + "" + Ls_48 + Ls_40 + Ls_32 + " ";
         Alert(Ls_56, Symbol(), ", ", Period(), "min");
         PlaySound("alert.wav");
         if (EmailOn) SendMail(Gs_224, Ls_56);
      }
   }
}

// DF9521834C17985437FE56016CDBD1BC
int f0_10() {
   int Lia_0[4];
   GetWindowRect(WindowHandle(Symbol(), Period()), Lia_0);
   return (Lia_0[2] - Lia_0[0] - 48);
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