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
#property strict

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 RoyalBlue
#property indicator_color2 Red
#property indicator_color3 Yellow

extern int AAB_Price = 0;
extern int AAB_MAPeriod = 40;
extern int AAB_MAShift = 0;
extern int AAB_MAMethod = 1;
extern int AAB_BandsType = 2;
extern int AAB_STDPeriod = 20;
extern bool AAB_STDUseMAPeriod = TRUE;
extern double AAB_STDDevations = 1.5;
extern double AAB_ENVDevations = 0.18;
extern int AAB_ATRPeriod = 20;
extern bool AAB_ATRUseMAPeriod = TRUE;
extern double AAB_ATRDevations = 2.0;
extern double AAB_NLMADeviation = 0.0;
extern double AAB_NLMAPctFilter = 0.0;
extern bool EmailON = TRUE;
extern bool SoundON = TRUE;
extern bool AlertON = TRUE;
extern int AlertRepeat = 3;
extern bool EndLessRepeat = FALSE;
extern string SoundFile = "Alert";
extern int Nbars = -1;
double gd_184 = 1.0;
int gi_unused_192 = 1;
double g_ibuf_196[];
double g_ibuf_200[];
double g_ibuf_204[];
double g_ibuf_208[];
double g_ibuf_212[];
double g_ibuf_216[];
double g_ibuf_220[];
double g_ibuf_224[];
bool gi_unused_228 = FALSE;
bool gi_unused_232 = FALSE;
int gi_236;
int gi_240;
int g_datetime_244;
int g_datetime_248;
int gi_252 = 0;
int gi_256 = 0;

int init() {
   string ls_unused_0;     
   //if (TimeCurrent() > StrToTime("2050.04.20")) {
   //   Alert("New version available! Download it using re-activated link from Plimus");
   //   return;
   //}
   ObjectDelete("B_Bell");
   gi_236 = 0;
   gi_240 = 0;
   IndicatorBuffers(8);
   SetIndexBuffer(0, g_ibuf_196);
   SetIndexBuffer(1, g_ibuf_200);
   SetIndexBuffer(2, g_ibuf_204);
   SetIndexBuffer(3, g_ibuf_208);
   SetIndexBuffer(4, g_ibuf_212);
   SetIndexBuffer(5, g_ibuf_216);
   SetIndexBuffer(6, g_ibuf_220);
   SetIndexBuffer(7, g_ibuf_224);
   SetIndexEmptyValue(0, 0);
   SetIndexEmptyValue(1, 0);
   SetIndexEmptyValue(2, 0);
   SetIndexEmptyValue(3, 0);
   SetIndexEmptyValue(4, 0);
   SetIndexEmptyValue(5, 0);
   SetIndexEmptyValue(6, 0);
   SetIndexEmptyValue(7, 0);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID);
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID);
   SetIndexArrow(2, 159);
   SetIndexLabel(0, "UpTrend Stop");
   SetIndexLabel(1, "DownTrend Stop");
   SetIndexLabel(2, "UpTrend Signal");
   SetIndexLabel(3, "DownTrend Signal");
   return (0);
}

int deinit() {
   ObjectDelete("B_Bell");
   return (0);
}

int OnCalculate(const int rates_total,
const int prev_calculated,
const datetime &time[],
const double &open[],
const double &high[],
const double &low[],
const double &close[],
const long &tick_volume[],
const long &volume[],
const int &spread[])
{ 
	 double l_icustom_12;
   double l_icustom_20;
   int li_0 = Bars - IndicatorCounted();
   li_0 = MathMin(Bars - MathMax(AAB_MAPeriod, MathMax(AAB_STDPeriod, AAB_ATRPeriod)) - 10.0, li_0);
   if (Nbars > 0) {
      SetIndexDrawBegin(0, Bars - Nbars);
      SetIndexDrawBegin(1, Bars - Nbars);
      SetIndexDrawBegin(2, Bars - Nbars);
      SetIndexDrawBegin(3, Bars - Nbars);
      SetIndexDrawBegin(4, Bars - Nbars);
      SetIndexDrawBegin(5, Bars - Nbars);
   }
   for (int li_8 = li_0 - 1; li_8 >= 0; li_8--) {
      l_icustom_12 = iCustom(NULL, 0, "#Pallada_AllAveragesBands", AAB_Price, AAB_MAPeriod, AAB_MAShift, AAB_MAMethod, AAB_BandsType, AAB_STDPeriod, AAB_STDUseMAPeriod, AAB_STDDevations, AAB_ENVDevations, AAB_ATRPeriod, AAB_ATRUseMAPeriod, AAB_ATRDevations, AAB_NLMADeviation, AAB_NLMAPctFilter, 1, li_8);
      l_icustom_20 = iCustom(NULL, 0, "#Pallada_AllAveragesBands", AAB_Price, AAB_MAPeriod, AAB_MAShift, AAB_MAMethod, AAB_BandsType, AAB_STDPeriod, AAB_STDUseMAPeriod, AAB_STDDevations, AAB_ENVDevations, AAB_ATRPeriod, AAB_ATRUseMAPeriod, AAB_ATRDevations, AAB_NLMADeviation, AAB_NLMAPctFilter, 2, li_8);
			
      g_ibuf_196[li_8] = 0;
      g_ibuf_200[li_8] = 0;
      g_ibuf_204[li_8] = 0;
      g_ibuf_208[li_8] = g_ibuf_208[li_8 + 1];
      g_ibuf_220[li_8] = l_icustom_12;
      g_ibuf_224[li_8] = l_icustom_20;
      if (Close[li_8] > g_ibuf_220[li_8 + 1]) g_ibuf_208[li_8] = 1;
      if (Close[li_8] < g_ibuf_224[li_8 + 1]) g_ibuf_208[li_8] = -1;
      if (g_ibuf_208[li_8] > 0.0 && g_ibuf_224[li_8] < g_ibuf_224[li_8 + 1]) g_ibuf_224[li_8] = g_ibuf_224[li_8 + 1];
      if (g_ibuf_208[li_8] < 0.0 && g_ibuf_220[li_8] > g_ibuf_220[li_8 + 1]) g_ibuf_220[li_8] = g_ibuf_220[li_8 + 1];
      g_ibuf_212[li_8] = g_ibuf_220[li_8] + (gd_184 - 1.0) / 2.0 * (g_ibuf_220[li_8] - g_ibuf_224[li_8]);
      g_ibuf_216[li_8] = g_ibuf_224[li_8] - (gd_184 - 1.0) / 2.0 * (g_ibuf_220[li_8] - g_ibuf_224[li_8]);
      if (g_ibuf_208[li_8] > 0.0 && g_ibuf_216[li_8] < g_ibuf_216[li_8 + 1]) g_ibuf_216[li_8] = g_ibuf_216[li_8 + 1];
      if (g_ibuf_208[li_8] < 0.0 && g_ibuf_212[li_8] > g_ibuf_212[li_8 + 1]) g_ibuf_212[li_8] = g_ibuf_212[li_8 + 1];
      if (g_ibuf_208[li_8] > 0.0) {
         g_ibuf_196[li_8] = g_ibuf_216[li_8];
         g_ibuf_200[li_8] = 0;
      }
      if (g_ibuf_208[li_8] < 0.0) {
         g_ibuf_200[li_8] = g_ibuf_212[li_8];
         g_ibuf_196[li_8] = 0;
      }
      g_ibuf_204[li_8] = 0;
      if (g_ibuf_200[li_8] != 0.0 && g_ibuf_200[li_8 + 1] == 0.0) g_ibuf_204[li_8] = g_ibuf_200[li_8];
      if (g_ibuf_196[li_8] != 0.0 && g_ibuf_196[li_8 + 1] == 0.0) g_ibuf_204[li_8] = g_ibuf_196[li_8];
   }
   int li_28 = 1;
   if (g_ibuf_196[li_28] != 0.0 && g_ibuf_196[li_28 + 1] == 0.0) {
      if (Time[0] != gi_252) {
         gi_252 = Time[0];
         if (EmailON) SendMail("B_Sig(" + Symbol() + " " + fTimeFrameName(Period()) + ")", "Bands going Up");
         if (SoundON || AlertON) {
            fObjLabel("B_Bell", 100, 100, StringSetChar("", 0, '%'), 3, Red, 16, 0, "Wingdings", FALSE);
            if (EndLessRepeat) gi_236 = 1;
            else gi_236 = AlertRepeat;
            g_datetime_244 = 0;
            gi_240 = 0;
         }
      }
   }
   if (g_ibuf_200[li_28] != 0.0 && g_ibuf_200[li_28 + 1] == 0.0) {
      if (Time[0] != gi_256) {
         gi_256 = Time[0];
         if (EmailON) SendMail("B_Sig(" + Symbol() + " " + fTimeFrameName(Period()) + ")", "Bands going Down");
         if (SoundON || AlertON) {
            fObjLabel("B_Bell", 100, 100, StringSetChar("", 0, '%'), 3, Red, 16, 0, "Wingdings", FALSE);
            if (EndLessRepeat) gi_240 = 1;
            else gi_240 = AlertRepeat;
            g_datetime_248 = 0;
            gi_236 = 0;
         }
      }
   }
   if (ObjectFind("B_Bell") == 0) {
      if (gi_236 > 0) {
         if (TimeLocal() > g_datetime_244 + 1) {
            if (!EndLessRepeat) gi_236--;
            g_datetime_244 = TimeLocal();
            if (AlertON) Alert("B_Sig(" + Symbol() + " " + fTimeFrameName(Period()) + "): Bands going UP");
            if (SoundON) {
               Print("B_Sig(" + Symbol() + " " + fTimeFrameName(Period()) + "): Bands going UP");
               PlaySound(SoundFile);
            }
         }
      }
      if (gi_240 > 0) {
         if (TimeLocal() > g_datetime_248 + 1) {
            if (!EndLessRepeat) gi_240--;
            g_datetime_248 = TimeLocal();
            if (AlertON) Alert("B_Sig(" + Symbol() + " " + fTimeFrameName(Period()) + "): Bands going DOWN");
            if (SoundON) {
               Print("B_Sig(" + Symbol() + " " + fTimeFrameName(Period()) + "): Bands going DOWN");
               PlaySound(SoundFile);
            }
         }
      }
   }
   if (gi_240 <= 0 && gi_236 <= 0) ObjectDelete("B_Bell");

		1wreturn(rates_total);
}

string fTimeFrameName(int ai_0) {
   int l_timeframe_4;
   if (ai_0 == 0) l_timeframe_4 = Period();
   else l_timeframe_4 = ai_0;
   switch (l_timeframe_4) {
   case 0:
      return ("0");
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
   return ("Wrong TimeFrame");
}

void fObjLabel(string a_name_0, int a_x_8, int a_y_12, string a_text_16, int a_corner_24 = 0, color a_color_28 = 255, int a_fontsize_32 = 8, int a_window_36 = 0, string a_fontname_40 = "Arial", bool a_bool_48 = FALSE) {
   if (ObjectFind(a_name_0) != a_window_36) ObjectCreate(a_name_0, OBJ_LABEL, a_window_36, 0, 0);
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_8);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_12);
   ObjectSetText(a_name_0, a_text_16, a_fontsize_32, a_fontname_40, a_color_28);
   ObjectSet(a_name_0, OBJPROP_BACK, a_bool_48);
   ObjectSet(a_name_0, OBJPROP_CORNER, a_corner_24);
}