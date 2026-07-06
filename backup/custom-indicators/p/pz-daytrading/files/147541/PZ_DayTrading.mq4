// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=17&t=72744

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
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 Red
#property indicator_color3 Red

extern string St_Ex = "------- Indicator Settings";
extern bool Verbose = FALSE;
extern int MinRange = 5;
extern int MaxRange = 30;
extern int HighLowFilter = 10;
extern int MaxHistoryBars = 5000;
extern string AN_Ex = "------- Trade Analysis";
extern string AN_Ex2 = ">> Analyzes the performance of signals";
extern bool AnalysisEnabled = TRUE;
extern bool DisplayProfits = TRUE;
extern color AnalysisColor = Purple;
extern color AnalysisLabel = Blue;
extern string Se_Ex3 = "------- Drawing Boxes";
extern color BullRectangle = LightSkyBlue;
extern color BearRectangle = Tomato;
extern string Alerts_ex = "------- Alerts";
extern string AlertCaption = "My Alert";
extern bool DisplayAlerts = FALSE;
extern bool EmailAlerts = FALSE;
extern bool SoundAlerts = FALSE;
extern bool   push_notifications = FALSE;
extern string SoundFile = "alert.wav";
double G_ibuf_188[];
double G_ibuf_192[];
double G_ibuf_196[];
double G_ibuf_200[];
double G_ibuf_204[];
bool Gi_208 = FALSE;
double Gd_212;
double G_close_220 = 0.0;
double G_close_228 = 0.0;
int G_datetime_236 = 0;
int G_datetime_240 = 0;
datetime G_time_244;
bool Gi_248 = TRUE;
double G_high_252;
double G_low_260 = 0.0;
datetime G_time_268;
datetime G_time_272 = 0;
int G_count_276;
int G_count_280;
int Gi_284;
int G_count_288 = 0;
double Gd_292 = 0.0;
int Gi_300 = 0;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   IndicatorBuffers(5);
   G_high_252 = 0;
   G_low_260 = 0;
   G_time_268 = 0;
   G_time_272 = 0;
   G_count_276 = 0;
   G_count_280 = 0;
   Gi_284 = 0;
   G_count_288 = 0;
   G_close_220 = 0;
   G_close_228 = 0;
   G_datetime_236 = 0;
   G_datetime_240 = 0;
   Gd_292 = 0;
   Gi_300 = 0;
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 233);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 234);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, SYMBOL_STOPSIGN);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
   SetIndexBuffer(0, G_ibuf_188);
   SetIndexBuffer(1, G_ibuf_192);
   SetIndexBuffer(2, G_ibuf_196);
   SetIndexBuffer(3, G_ibuf_204);
   SetIndexBuffer(4, G_ibuf_200);
   IndicatorShortName("PZ Day Trading");
   Comment("Copyright © http://www.pointzero-trading.com");
   f0_12();
   return (0);
}

// 9FDC179C742334D485A77A8B241EC55C
int f0_12() {
   string name_0;
   int objs_total_8 = ObjectsTotal();
   for (int Li_12 = objs_total_8 - 1; Li_12 >= 0; Li_12--) {
      name_0 = ObjectName(Li_12);
      if (StringFind(name_0, "PZDT") != -1) ObjectDelete(name_0);
   }
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   f0_12();
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   double Ld_4;
   double Ld_12;
   double iatr_20;
   double Ld_28;
   double Ld_36;
   double Ld_44;
   double Ld_52;
   double Ld_60;
   double Ld_68;
   double close_76;
   double Ld_84;
   if (!Gi_208) {
      if ((!IsConnected()) && 1) return (1);
      Gi_208 = TRUE;
   }
   if (!Gi_208) return (1);
   int Li_92 = 1;
   int ind_counted_96 = IndicatorCounted();
   if (ind_counted_96 < 0) return (-1);
   int Li_100 = Bars - 1 - ind_counted_96;
   for (int Li_104 = Li_100; Li_104 >= Li_92; Li_104--) {
      if (Li_104 <= MaxHistoryBars) {
         Ld_4 = f0_1(Li_104, HighLowFilter);
         Ld_12 = f0_8(Li_104, HighLowFilter);
         iatr_20 = iATR(Symbol(), 0, 50, Li_104);
         Gd_212 = iatr_20 / 100.0;
         Ld_28 = 8.0 * Gd_212;
         Ld_36 = f0_14(Li_104);
         Ld_44 = f0_2(Li_104);
         Ld_52 = f0_9(Li_104);
         G_ibuf_204[Li_104] = G_ibuf_204[Li_104 + 1];
         G_ibuf_200[Li_104] = EMPTY_VALUE;
         close_76 = Close[Li_104];
         Ld_84 = 1;
         for (int Li_108 = MinRange; Li_108 <= MaxRange; Li_108++) {
            Ld_60 = f0_1(Li_104, Li_108);
            Ld_68 = f0_8(Li_104, Li_108);
            if (f0_16(Li_104, Li_108) && Verbose && G_ibuf_204[Li_104] == 0.0 && Ld_60 >= Ld_4 || High[Li_104] >= Ld_4 || 0) {
               if (!(f0_0(Li_104, Li_108 + 1, BullRectangle, 0, 0))) break;
               G_ibuf_200[Li_104] = 0;
               G_ibuf_204[Li_104] = 0;
               break;
            }
            if (f0_7(Li_104, Li_108) && Verbose && G_ibuf_204[Li_104] == 1.0 && Ld_68 <= Ld_12 || Low[Li_104] <= Ld_4 || 0) {
               if (!(f0_0(Li_104, Li_108 + 1, BearRectangle, 0, 0))) break;
               G_ibuf_200[Li_104] = 1;
               G_ibuf_204[Li_104] = 1;
               break;
            }
            if (f0_16(Li_104, Li_108) && 1 && G_ibuf_204[Li_104] != 0.0 || (G_ibuf_204[Li_104] == 0.0 && G_close_220 > close_76) && Ld_68 <= Ld_12 || Low[Li_104] <= Ld_4 || 0) {
               if (G_ibuf_204[Li_104] == 0.0 && G_close_220 > close_76) Ld_84 = 0;
               else Ld_84 = 1;
               if (!(f0_0(Li_104, Li_108 + 1, BullRectangle, 1, Ld_84))) break;
               f0_5();
               G_close_220 = close_76;
               G_ibuf_200[Li_104] = 0;
               G_ibuf_204[Li_104] = 0;
               break;
            }
            if (f0_7(Li_104, Li_108) && 1 && G_ibuf_204[Li_104] != 1.0 || (G_ibuf_204[Li_104] == 1.0 && G_close_228 < close_76) && Ld_60 >= Ld_4 || High[Li_104] >= Ld_4 || 0) {
               if (G_ibuf_204[Li_104] == 1.0 && G_close_228 < close_76) Ld_84 = 0;
               else Ld_84 = 1;
               if (!(f0_0(Li_104, Li_108 + 1, BearRectangle, 1, Ld_84))) break;
               f0_5();
               G_close_228 = close_76;
               G_ibuf_200[Li_104] = 1;
               G_ibuf_204[Li_104] = 1;
               break;
            }
            if (f0_17(Li_104, Li_108) && 1 && G_ibuf_204[Li_104] != 0.0 || (G_ibuf_204[Li_104] == 0.0 && G_close_220 > close_76) && Ld_68 <= Ld_12 || Low[Li_104] <= Ld_4 || 0) {
               if (G_ibuf_204[Li_104] == 0.0 && G_close_220 > close_76) Ld_84 = 0;
               else Ld_84 = 1;
               if (!(f0_0(Li_104, Li_108 + 1, BullRectangle, 1, Ld_84))) break;
               f0_5();
               G_close_220 = close_76;
               G_ibuf_200[Li_104] = 0;
               G_ibuf_204[Li_104] = 0;
               break;
            }
            if (f0_13(Li_104, Li_108) && 1 && G_ibuf_204[Li_104] != 1.0 || (G_ibuf_204[Li_104] == 1.0 && G_close_228 < close_76) && Ld_60 >= Ld_4 || High[Li_104] >= Ld_4 || 0) {
               if (G_ibuf_204[Li_104] == 1.0 && G_close_228 < close_76) Ld_84 = 0;
               else Ld_84 = 1;
               if (!(f0_0(Li_104, Li_108 + 1, BearRectangle, 1, Ld_84))) break;
               f0_5();
               G_close_228 = close_76;
               G_ibuf_200[Li_104] = 1;
               G_ibuf_204[Li_104] = 1;
               break;
            }
         }
         if (AnalysisEnabled) f0_3(Li_104);
      }
   }
   
	 // NOTE: Alerts
	 if (G_time_244 != Time[0]) 
	 {
      if (G_ibuf_200[1] == 0.0 && Gi_248 == FALSE) 
			{
            string text = "PZ Day Trading" + " (" + AlertCaption + ") [" + Symbol() + "] Bullish Breakout";
            if (DisplayAlerts == TRUE) Alert(text);
            if (EmailAlerts == TRUE) SendMail(AlertCaption, text);
            if (SoundAlerts == TRUE) PlaySound(SoundFile);
            if (push_notifications) SendNotification(text);
      } else 
			{
         if (G_ibuf_200[1] == 1.0 && Gi_248 == FALSE) 
				 {
            text = "PZ Day Trading" + " (" + AlertCaption + ") [" + Symbol() + "] Bearish Breakout";
            if (DisplayAlerts == TRUE) Alert(text);
            if (EmailAlerts == TRUE) SendMail(AlertCaption, text);
            if (SoundAlerts == TRUE) PlaySound(SoundFile);
						if (push_notifications) SendNotification(text);
         }
      }
      G_time_244 = Time[0];
      Gi_248 = FALSE;
   }
   return (0);
}

// 50257C26C4E5E915F022247BABD914FE
void f0_5() {
   G_high_252 = 0;
   G_low_260 = 0;
   f0_4();
}

// 3180D254E1C24E987439E4F62708F6A2
void f0_4() {
   int Li_0;
   int Li_4;
   int Li_8;
   int Li_12;
   int Li_16;
   double Ld_20 = G_count_276 + G_count_280;
   if (Ld_20 != 0.0) {
      Li_0 = MathFloor(Ld_20);
      Li_4 = MathCeil(100.0 * (G_count_276 / Ld_20));
      Li_8 = MathFloor(100.0 * (G_count_280 / Ld_20));
      Li_12 = MathCeil(Gi_284 / G_count_288);
      Li_16 = MarketInfo(Symbol(), MODE_SPREAD);
      Comment("Copyright © http://www.pointzero-trading.com \n" + "Winning Trades: " + Li_4 + "% (" + G_count_276 + " of " + Li_0 + ") \n" + "Losing Trades: " + Li_8 + "% (" +
         G_count_280 + " of " + Li_0 + ") \n" + "Average Signal: +" + Li_12 + " pts \n" + "Spread: " + Li_16 + " pts");
   }
}

// 2FC9212C93C86A99B2C376C96453D3A4
void f0_3(int Ai_0) {
   if (High[Ai_0] > G_high_252 || G_high_252 == 0.0) {
      G_high_252 = High[Ai_0];
      G_time_268 = Time[Ai_0];
   }
   if (Low[Ai_0] < G_low_260 || G_low_260 == 0.0) {
      G_low_260 = Low[Ai_0];
      G_time_272 = Time[Ai_0];
   }
}

// A0F6E6535C856D4495BA899376567E48
int f0_13(int Ai_0, int Ai_4) {
   double Ld_8 = MathAbs(High[Ai_0] - Low[Ai_0]);
   if (f0_11(Ai_0) && Close[Ai_0] < f0_8(Ai_0, Ai_4) && f0_6(Ai_0 + Ai_4 + 1)) return (1);
   return (0);
}

// FD4055E1AC0A7D690C66D37B2C70E529
int f0_17(int Ai_0, int Ai_4) {
   double Ld_8 = MathAbs(High[Ai_0] - Low[Ai_0]);
   if (f0_6(Ai_0) && Close[Ai_0] > f0_1(Ai_0, Ai_4) && f0_11(Ai_0 + Ai_4 + 1)) return (1);
   return (0);
}

// D362D41CFF235C066CFB390D52F4EB13
int f0_16(int Ai_0, int Ai_4) {
   double Ld_8 = MathAbs(High[Ai_0] - Low[Ai_0]);
   if (f0_6(Ai_0) && Close[Ai_0] > f0_1(Ai_0, Ai_4) && Open[Ai_0] < Close[Ai_0 + Ai_4 + 1] && Close[Ai_0] > High[Ai_0 + Ai_4 + 1]) return (1);
   return (0);
}

// 6ABA3523C7A75AAEA41CC0DEC7953CC5
int f0_7(int Ai_0, int Ai_4) {
   double Ld_8 = MathAbs(High[Ai_0] - Low[Ai_0]);
   if (f0_11(Ai_0) && Close[Ai_0] < f0_8(Ai_0, Ai_4) && Open[Ai_0] > Close[Ai_0 + Ai_4 + 1] && Close[Ai_0] < Low[Ai_0 + Ai_4 + 1]) return (1);
   return (0);
}

// 81A4CBF7E575109EFB1104EFB9B5DF39
double f0_9(int Ai_0) {
   if (Close[Ai_0] > Open[Ai_0]) return (MathAbs(High[Ai_0] - Close[Ai_0]));
   return (MathAbs(High[Ai_0] - Open[Ai_0]));
}

// 2569208C5E61CB15E209FFE323DB48B7
double f0_2(int Ai_0) {
   if (Close[Ai_0] < Open[Ai_0]) return (MathAbs(Close[Ai_0] - Low[Ai_0]));
   return (MathAbs(Open[Ai_0] - Low[Ai_0]));
}

// 90124A87B1714F1FF8E93A2800BD4144
void f0_10(string A_text_0, int Ai_8, int Ai_12, color A_color_16, int Ai_20) {
   int time_24;
   datetime time_28;
   double price_32;
   string name_40;
   if (DisplayProfits) {
      time_24 = Time[Ai_8];
      time_28 = Time[Ai_8 + 1];
      if (Ai_12 == 0) price_32 = Low[Ai_8] - Gd_212 * Ai_20;
      else price_32 = High[Ai_8] + Gd_212 * Ai_20;
      name_40 = "PZDT" + "-" + A_text_0 + "-" + time_28;
      ObjectCreate(name_40, OBJ_TEXT, 0, time_24, price_32);
      ObjectSetText(name_40, A_text_0, 7, "Tahoma", A_color_16);
      ObjectSet(name_40, OBJPROP_BACK, TRUE);
   }
}

// C326432F8CFFDF18B9C33D8D42CEBC52
void f0_15(string A_name_0, int A_datetime_8, int A_datetime_12, double A_price_16, double A_price_24, color A_color_32, int A_style_36, int A_width_40, int A_bool_44) {
   if (ObjectFind(A_name_0) != -1) ObjectDelete(A_name_0);
   ObjectCreate(A_name_0, OBJ_TREND, 0, A_datetime_8, A_price_16, A_datetime_12, A_price_24);
   ObjectSet(A_name_0, OBJPROP_RAY, A_bool_44);
   ObjectSet(A_name_0, OBJPROP_STYLE, A_style_36);
   ObjectSet(A_name_0, OBJPROP_WIDTH, A_width_40);
   ObjectSet(A_name_0, OBJPROP_COLOR, A_color_32);
   ObjectSet(A_name_0, OBJPROP_BACK, TRUE);
}

// 184916985BFD167AE4E08C739AF60F52
bool f0_0(int Ai_0, int Ai_4, color A_color_8, bool Ai_12 = TRUE, bool Ai_16 = TRUE) {
   string Ls_20;
   int Li_28;
   int shift_32;
   int shift_36;
   int shift_40;
   int time_44 = Time[Ai_0];
   int time_48 = Time[Ai_0 + Ai_4 - 1];
   string name_52 = "PZDT" + "Rect-" + Ai_4 + time_48;
   if ((A_color_8 == BullRectangle && time_48 <= G_datetime_240) || time_48 > time_44) return (FALSE);
   if ((A_color_8 == BearRectangle && time_48 <= G_datetime_236) || time_48 > time_44) return (FALSE);
   if (AnalysisEnabled && Ai_16 && Gi_300 > 0 && Gd_292 > 0.0) {
      Ls_20 = name_52 + "-res";
      Li_28 = 0;
      shift_32 = iBarShift(Symbol(), 0, Gi_300, TRUE);
      shift_36 = iBarShift(Symbol(), 0, G_time_268, TRUE);
      shift_40 = iBarShift(Symbol(), 0, G_time_272, TRUE);
      if (G_ibuf_204[Ai_0] == 0.0) {
         if (G_high_252 > High[shift_32]) {
            Li_28 = MathAbs(G_high_252 - Gd_292) / Point;
            f0_15(Ls_20, Gi_300, G_time_268, Gd_292, G_high_252, AnalysisColor, STYLE_DOT, 1, FALSE);
            f0_10("+" + Li_28, shift_36, 1, AnalysisLabel, 25);
            Gi_284 += Li_28;
            G_count_276++;
         } else {
            G_ibuf_196[shift_32] = High[shift_32];
            G_count_280++;
         }
      } else {
         if (G_low_260 < Low[shift_32]) {
            Li_28 = MathAbs(Gd_292 - G_low_260) / Point;
            f0_15(Ls_20, Gi_300, G_time_272, Gd_292, G_low_260, AnalysisColor, STYLE_DOT, 1, FALSE);
            f0_10("+" + Li_28, shift_40, 0, AnalysisLabel, 5);
            Gi_284 += Li_28;
            G_count_276++;
         } else {
            G_ibuf_196[shift_32] = Low[shift_32];
            G_count_280++;
         }
      }
   }
   if (AnalysisEnabled && Ai_12) {
      Gi_300 = time_44;
      Gd_292 = Close[Ai_0];
   }
   int Li_60 = Ai_0 + Ai_4;
   double ihigh_64 = iHigh(Symbol(), Period(), iHighest(Symbol(), Period(), MODE_HIGH, Ai_4 - 1, Ai_0 + 1));
   double ilow_72 = iLow(Symbol(), Period(), iLowest(Symbol(), Period(), MODE_LOW, Ai_4 - 1, Ai_0 + 1));
   ObjectCreate(name_52, OBJ_RECTANGLE, 0, time_44, ilow_72, time_48, ihigh_64);
   ObjectSet(name_52, OBJPROP_COLOR, A_color_8);
   ObjectSet(name_52, OBJPROP_BACK, FALSE);
   if (A_color_8 == BullRectangle) {
      G_ibuf_188[Ai_0] = ilow_72;
      G_datetime_240 = time_48;
   } else {
      G_ibuf_192[Ai_0] = ihigh_64;
      G_datetime_236 = time_48;
   }
   G_count_288++;
   return (TRUE);
}

// C23BD2D05F1A927B2825264A247F4626
double f0_14(int Ai_0) {
   if (Close[Ai_0] < Open[Ai_0]) return (MathAbs(Close[Ai_0] - Open[Ai_0]));
   return (MathAbs(Open[Ai_0] - Close[Ai_0]));
}

// 528FD8B404F8774AC78741021D00D737
int f0_6(int Ai_0) {
   if (Close[Ai_0] > Open[Ai_0]) return (1);
   return (0);
}

// 9ED55815FB278759298B6BAF50BEC3C8
int f0_11(int Ai_0) {
   if (Close[Ai_0] < Open[Ai_0]) return (1);
   return (0);
}

// 2230DA82D7FAFF3EA8CD4CFC92DE64E8
double f0_1(int Ai_0, int Ai_4) {
   return (iHigh(Symbol(), Period(), iHighest(Symbol(), Period(), MODE_HIGH, Ai_4, Ai_0 + 1)));
}

// 78BAA8FAE18F93570467778F2E829047
double f0_8(int Ai_0, int Ai_4) {
   return (iLow(Symbol(), Period(), iLowest(Symbol(), Period(), MODE_LOW, Ai_4, Ai_0 + 1)));
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
