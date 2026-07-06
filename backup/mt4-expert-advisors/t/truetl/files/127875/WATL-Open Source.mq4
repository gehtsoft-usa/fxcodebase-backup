// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68781

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 DarkGoldenrod
#property indicator_color3 BlueViolet

extern string OpenSourceby = "idealfx";
extern int High_period = 70;
extern int Low_period = 21;
extern int Trigger_Sens = 2;
extern bool ForecastHighTrendLine = TRUE;
extern bool StayLinesAfterDelete = FALSE;
extern string Note0 = "***** Semafor Drawing Adjustment";
extern bool DrawHighPivotSemafor = TRUE;
extern bool DrawLowPivotSemafor = TRUE;
extern bool DrawLowestPivotSemafor = TRUE;
extern string Note1 = "***** High Trend Lines Adjustment";
extern bool HTL_Draw = TRUE;
extern color HTL_ResColor = Red;
extern color HTL_SupColor = Maroon;
extern int HTL_Style = 1;
extern int HTL_Width = 2;
extern double HTL_Ext = 1.5;
extern int HTL_InMemory = 10;
extern int HTL_MinPivotDifferentIgnore = 5;
extern string Note2 = "***** Low Trend Lines Adjustment";
extern bool LTL_Draw = TRUE;
extern color LTL_ResColor = Gold;
extern color LTL_SupColor = Goldenrod;
extern int LTL_Style = 0;
extern int LTL_Width = 0;
extern double LTL_Ext = 1.5;
extern int LTL_InMemory = 30;
extern int LTL_MinPivotDifferentIgnore = 4;
extern string Note3 = "***** High Semafor Adjustment";
extern bool HighPivotTextAlarm = TRUE;
extern string HighPivotSoundAlarm = "alert.wav";
extern int HighPivotSemaforDrawOffset = 28;
extern int HighSemaforSymbol = 142;
extern string Note4 = "***** High Semafor Adjustment";
extern bool LowPivotTextAlarm = FALSE;
extern string LowPivotSoundAlarm = "";
extern int LowPivotSemaforDrawOffset = 18;
extern int LowSemaforSymbol = 141;
extern string Note5 = "***** Lowest Semafor Adjustment";
extern int LowestSemaforSymbol = 115;
extern string Note6 = "***** Forecast Trend Line Adjustment";
extern color FTL_Color = DeepPink;
extern int FTL_Style = 1;
extern int FTL_Width = 2;
extern double FTL_Ext = 1.05;

extern int button_x = 20;
extern int button_y = 30;

double g_ibuf_300[];
double g_ibuf_304[];
double g_ibuf_308[];
string gs_durko_l1_312 = "L1";
string gs_durko_l2_320 = "L2";
int gi_340;
int gi_344;
int gi_348;
int gi_352;
int g_time_356 = 0;
int gi_364 = 0;
double gda_368[][6];
int gi_372 = 0;
int gi_376 = 0;
int gi_380 = -1;
int gi_384;
double gda_388[][6];
int gi_392 = 0;
int gi_396 = 0;
int gi_400 = -1;
int gi_404;
double gda_408[][6];
int gi_412 = 0;
int gi_416 = 0;
int gi_420 = -1;
int gi_424;
int gi_428 = 0;
int gi_432 = 0;
int gi_436 = -1;
string gsa_440[];
string gsa_444[];
color g_color_448;
color g_color_452;
int g_style_456;
int g_width_460;
double gd_464;
int gi_472 = 0;
string gs_476 = "";
int gi_484 = 0;
int gi_488 = 0;
string g_name_492 = "ForecastHighTrendLine";
bool gi_500 = FALSE;
int g_datetime_504 = 0;
double g_price_508 = 0.0;
int gi_528 = 0;
int g_bars_532;

class VisibilityCotroller
{
   string buttonId;
   string visibilityId;
   bool show_data;
   bool recalc;
public:
   void Init(string id, string indicatorName)
   {
      recalc = false;
      visibilityId = indicatorName + "_visibility";
      double val;
      if (GlobalVariableGet(visibilityId, val))
         show_data = val != 0;
         
      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, "WALT", 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);
   }

   bool HandleButtonClicks()
   {
      if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
      {
         ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
         show_data = !show_data;
         GlobalVariableSet(visibilityId, show_data ? 1.0 : 0.0);
         recalc = true;
         return true;
      }
      return false;
   }

   bool IsRecalcNeeded()
   {
      return recalc;
   }

   void ResetRecalc()
   {
      recalc = false;
   }

   bool IsVisible()
   {
      return show_data;
   }

private:
   void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
   {
      ObjectDelete(0,buttonID);
      ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString(0,buttonID,OBJPROP_FONT,font);
      ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,2);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
   }
};

VisibilityCotroller _visibility;

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int start() {
   _visibility.HandleButtonClicks();
   if (!_visibility.IsVisible())
   {
      g_time_356 = 0;
      Clean();
      return 0;
   }
      
   if (gi_364 == FALSE) {
      if (g_bars_532 != Bars) {
         deinit();
         Sleep(1000);
         g_bars_532 = Bars;
         g_time_356 = 0;
         return (0);
      }
   }
   if (gi_364 == FALSE) {
      gi_364 = TRUE;
   }
   if (g_time_356 == Time[0]) return (0);
   g_time_356 = Time[0];
   
   int l_ind_counted_0 = IndicatorCounted();
   int li_4 = Bars - 2;
   if (l_ind_counted_0 > 2 && !_visibility.IsRecalcNeeded()) 
      li_4 = Bars - l_ind_counted_0 - 1;
   _visibility.ResetRecalc();
   for (int li_8 = li_4; li_8 >= 1; li_8--) 
   {
      NewWave_Manager(li_8, gi_344, gi_340, gda_368, g_ibuf_300, gi_372, gi_376, gi_380, gi_384, DrawHighPivotSemafor, HighPivotSemaforDrawOffset, HighPivotTextAlarm, HighPivotSoundAlarm, 1);
      NewWave_Manager(li_8, gi_352, gi_348, gda_388, g_ibuf_304, gi_392, gi_396, gi_400, gi_404, DrawLowPivotSemafor, LowPivotSemaforDrawOffset, LowPivotTextAlarm, LowPivotSoundAlarm, 0);
      NewWave_Manager(li_8, 2, 5, gda_408, g_ibuf_308, gi_412, gi_416, gi_420, gi_424, DrawLowestPivotSemafor, 3, 0, "", 0);
      if (gi_384 && HTL_Draw) 
      {
         TLMng_Init(HTL_ResColor, HTL_SupColor, HTL_Style, HTL_Width, HTL_Ext, HTL_InMemory, "HTL", HTL_MinPivotDifferentIgnore);
         TLMng_Main(gda_368, gsa_440, gi_384);
      }
      if (gi_404 && LTL_Draw) 
      {
         TLMng_Init(LTL_ResColor, LTL_SupColor, LTL_Style, LTL_Width, LTL_Ext, LTL_InMemory, "LTL", LTL_MinPivotDifferentIgnore);
         TLMng_Main(gda_388, gsa_444, gi_404);
      }
   }
   return (0);
}

void FTLMng_Main(int ai_0, int ai_4, double ad_8, int ai_16) {
   datetime l_time_28;
   if (ObjectFind(g_name_492) > -1) {
      ObjectDelete(g_name_492);
      gi_500 = FALSE;
      g_datetime_504 = FALSE;
      g_price_508 = 0;
   }
   double ld_20 = FTLMng_FindSecondpoint(ai_0, ai_4, ai_16);
   if (ld_20 != 0.0) {
      l_time_28 = Time[ai_0];
      if (FTLMng_DrawFirst(ai_4, ad_8, l_time_28, ld_20) != 0) {
         gi_528 = ai_16;
         FTLMng_ReDraw(ai_0);
         gi_500 = TRUE;
         return;
      }
   }
}

int FTLMng_DrawFirst(int a_datetime_0, double a_price_4, int a_datetime_12, double a_price_16) {
   if (ObjectCreate(g_name_492, OBJ_TREND, 0, a_datetime_0, a_price_4, a_datetime_12, a_price_16)) {
      ObjectSet(g_name_492, OBJPROP_RAY, FALSE);
      ObjectSet(g_name_492, OBJPROP_COLOR, FTL_Color);
      ObjectSet(g_name_492, OBJPROP_STYLE, FTL_Style);
      ObjectSet(g_name_492, OBJPROP_WIDTH, FTL_Width);
      g_datetime_504 = a_datetime_0;
      g_price_508 = a_price_4;
      ObjectsRedraw();
      return (1);
   }
   GetLastError();
   return (0);
}

int FTLMng_ReDraw(int ai_0) {
   if (ObjectFind(g_name_492) == -1) return (0);
   double ld_4 = FTLMng_FindSecondpoint(ai_0, g_datetime_504, gi_528);
   if (ld_4 == 0.0) return (0);
   int l_time_12 = Time[ai_0];
   int l_datetime_16 = 0;
   double ld_20 = 0;
   ObjectMove(g_name_492, 1, l_time_12, ld_4);
   if (FTL_Ext > 0.0) {
      TLMng_CountExt(FTL_Ext, g_datetime_504, g_price_508, l_time_12, ld_4, l_datetime_16, ld_20);
      if (l_datetime_16 == 0 || ld_20 == 0.0) return (0);
      ObjectMove(g_name_492, 1, l_datetime_16, ld_20);
   }
   ObjectsRedraw();
   return (0);
}

double FTLMng_FindSecondpoint(int ai_0, int ai_4, int ai_8) {
   if (ai_0 == 0 || ai_4 == 0) return (0);
   int l_shift_12 = iBarShift(NULL, 0, ai_4, FALSE);
   double l_ima_16 = 0;
   if (ai_8 == 1) l_ima_16 = iMA(NULL, 0, 1.1 * l_shift_12, 0, MODE_LWMA, PRICE_HIGH, ai_0);
   if (ai_8 == 2) l_ima_16 = iMA(NULL, 0, 1.1 * l_shift_12, 0, MODE_LWMA, PRICE_LOW, ai_0);
   return (l_ima_16);
}

int TLMng_Main(double &ada_0[][6], string &asa_4[], int &ai_8) {
   int li_16;
   int li_20;
   double ld_24;
   double ld_32;
   int li_40;
   int li_44;
   int l_shift_48;
   int l_shift_52;
   int li_12 = WAMng_WaveCount(ada_0);
   if (li_12 > 0) li_16 = WAMng_WaveType(ada_0, li_12);
   if (li_16 > 0) {
      li_20 = WAMng_LookPrivWaveSameType(ada_0, li_16, li_12);
      if (li_20 > 0) {
         ld_24 = WAMng_GetWavePiv(ada_0, li_12);
         ld_32 = WAMng_GetWavePiv(ada_0, li_20);
         if (ld_24 == 0.0 || ld_32 == 0.0) return (0);
         li_40 = WAMng_GetWavePivBar(ada_0, li_12);
         li_44 = WAMng_GetWavePivBar(ada_0, li_20);
         if (li_40 == 0 || li_44 == 0) return (0);
         if (gi_488 > 0) {
            l_shift_48 = iBarShift(NULL, 0, li_40, FALSE);
            l_shift_52 = iBarShift(NULL, 0, li_44, FALSE);
            if (l_shift_52 - l_shift_48 <= gi_488) return (0);
         }
         if (li_16 == 1) {
            if (ld_24 < ld_32) TLMng_BuidLine(asa_4, li_16, ld_32, li_44, ld_24, li_40);
            else ai_8 = 0;
         } else {
            if (li_16 == 2) {
               if (ld_24 > ld_32) TLMng_BuidLine(asa_4, li_16, ld_32, li_44, ld_24, li_40);
               else ai_8 = 0;
            }
         }
      }
   }
   return (0);
}

void TLMng_Init(int ai_0, int ai_4, int ai_8, int ai_12, double ad_16, int ai_24, string as_28, int ai_36) {
   g_color_448 = ai_0;
   g_color_452 = ai_4;
   if (g_width_460 <= 1) {
      g_style_456 = ai_8;
      g_width_460 = 1;
   } else {
      g_style_456 = 0;
      g_width_460 = ai_12;
   }
   if (ad_16 < 1.0) gd_464 = 1;
   else gd_464 = ad_16;
   gi_472 = ai_24;
   gs_476 = as_28;
   gi_488 = ai_36;
}

void TLMng_BuidLine(string &asa_0[], int ai_4, double ad_8, int a_datetime_16, double ad_20, int a_datetime_28) {
   string ls_48;
   int l_datetime_56;
   double ld_60;
   int l_count_68;
   double ld_72;
   string ls_32 = "";
   if (gs_476 == "") ls_32 = "Def";
   else ls_32 = gs_476;
   string l_name_40 = ls_32 + "_Asys_AutoTL_" + Period() + "_";
   gi_484++;
   if (ai_4 == 2) ls_48 = "Sup";
   else ls_48 = "Res";
   l_name_40 = l_name_40 + ls_48 + " - " + gi_484;
   if (ObjectCreate(l_name_40, OBJ_TREND, 0, a_datetime_16, NormalizeDouble(ad_8, Digits), a_datetime_28, NormalizeDouble(ad_20, Digits))) {
      ObjectSet(l_name_40, OBJPROP_RAY, FALSE);
      if (ls_48 == "Sup") ObjectSet(l_name_40, OBJPROP_COLOR, g_color_452);
      else {
         if (ls_48 == "Res") ObjectSet(l_name_40, OBJPROP_COLOR, g_color_448);
         else ObjectSet(l_name_40, OBJPROP_COLOR, Red);
      }
      ObjectSet(l_name_40, OBJPROP_STYLE, g_style_456);
      ObjectSet(l_name_40, OBJPROP_WIDTH, g_width_460);
      if (gd_464 > 1.0) {
         l_datetime_56 = 0;
         ld_60 = 0;
         TLMng_CountExt(gd_464, a_datetime_16, NormalizeDouble(ad_8, Digits), a_datetime_28, NormalizeDouble(ad_20, Digits), l_datetime_56, ld_60);
         ObjectMove(l_name_40, 1, l_datetime_56, ld_60);
         l_count_68 = 0;
         ld_72 = TLMng_CorrectLine(l_name_40, a_datetime_28, NormalizeDouble(ad_20, Digits));
         while (ld_72 != 0.0) {
            ld_60 += ld_72;
            ObjectMove(l_name_40, 1, l_datetime_56, ld_60);
            ld_72 = TLMng_CorrectLine(l_name_40, a_datetime_28, NormalizeDouble(ad_20, Digits));
            l_count_68++;
            if (l_count_68 > 20) break;
         }
      }
      TLMng_CheckNumTL(asa_0, l_name_40, gi_472);
      ObjectsRedraw();
   }
}

double TLMng_CorrectLine(string a_name_0, int ai_8, double ad_12) {
   if (a_name_0 == "" || ai_8 == 0) return (0);
   GetLastError();
   double ld_20 = ObjectGetValueByShift(a_name_0, iBarShift(NULL, 0, ai_8, TRUE));
   if (GetLastError() > 0/* NO_ERROR */) return (0);
   double ld_28 = ld_20 - ad_12;
   if (IsInChanel(ld_28, 0, 2.0 * Point) == 1) return (0);
   return (-1.0 * ld_28);
}

void TLMng_CheckNumTL(string &asa_0[], string as_4, int ai_12) {
   if (as_4 == "" || ai_12 < 0) return;
   if (ArraySize(asa_0) + 1 > ai_12) {
      if (!ObjectDelete(asa_0[0])) Print("������ �������� ����� - ", asa_0[0], " ��� ������ - ", GetLastError());
      ArrayCopy(asa_0, asa_0, 0, 1);
      asa_0[ArraySize(asa_0) - 1] = as_4;
      return;
   }
   ArrayResize(asa_0, ArraySize(asa_0) + 1);
   asa_0[ArraySize(asa_0) - 1] = as_4;
}

void TLMng_DeleteAllLines() {
   int li_0 = ArrayRange(gsa_440, 0);
   if (li_0 > 0) {
      for (int l_index_4 = 0; l_index_4 <= li_0 - 1; l_index_4++)
         if (ObjectFind(gsa_440[l_index_4]) > -1) ObjectDelete(gsa_440[l_index_4]);
   }
   ArrayResize(gsa_440, 0);
   li_0 = 0;
   li_0 = ArrayRange(gsa_444, 0);
   if (li_0 > 0) 
   {
      for (int l_index_4 = 0; l_index_4 <= li_0 - 1; l_index_4++)
         if (ObjectFind(gsa_444[l_index_4]) > -1) 
            ObjectDelete(gsa_444[l_index_4]);
   }
   ArrayResize(gsa_444, 0);
}

void TLMng_DeleteLinesCurrentTF() {
   string l_name_4;
   string lsa_12[];
   int l_objs_total_0 = ObjectsTotal();
   if (l_objs_total_0 != 0) {
      for (int li_16 = 0; li_16 <= l_objs_total_0 - 1; li_16++) {
         l_name_4 = ObjectName(li_16);
         if (StringFind(l_name_4, StringConcatenate("Asys_AutoTL_", Period())) > -1) {
            ArrayResize(lsa_12, ArraySize(lsa_12) + 1);
            lsa_12[ArraySize(lsa_12) - 1] = l_name_4;
         }
      }
      if (ArraySize(lsa_12) > 0) {
         for (int li_16 = 0; li_16 <= ArraySize(lsa_12) - 1; li_16++)
            if (ObjectFind(lsa_12[li_16]) > -1) 
               ObjectDelete(lsa_12[li_16]);
      }
   }
}

void TLMng_DeleteLinesCurrentInd() {
   string l_name_4;
   string lsa_12[];
   int l_objs_total_0 = ObjectsTotal();
   if (l_objs_total_0 != 0) {
      for (int li_16 = 0; li_16 <= l_objs_total_0 - 1; li_16++) {
         l_name_4 = ObjectName(li_16);
         if (StringFind(l_name_4, "Asys_AutoTL") > -1) {
            ArrayResize(lsa_12, ArraySize(lsa_12) + 1);
            lsa_12[ArraySize(lsa_12) - 1] = l_name_4;
         }
      }
      if (ArraySize(lsa_12) > 0) {
         for (int li_16 = 0; li_16 <= ArraySize(lsa_12) - 1; li_16++)
            if (ObjectFind(lsa_12[li_16]) > -1) ObjectDelete(lsa_12[li_16]);
      }
   }
}

void TLMng_CountExt(double ad_0, int ai_8, double ad_12, int ai_20, double ad_24, int &ai_32, double &ad_36) {
   int l_shift_44 = iBarShift(NULL, 0, ai_8, FALSE);
   int l_shift_48 = iBarShift(NULL, 0, ai_20, FALSE);
   int li_52 = l_shift_44 - l_shift_48;
   int li_56 = Double2Int(MathRound(li_52 * ad_0));
   double ld_60 = MathAbs(ad_24 - ad_12);
   if (li_56 == 0) ad_36 = ad_24;
   else {
      if (ad_24 > ad_12) ad_36 = NormalizeDouble(ad_24 + li_56 * ld_60 / li_52, Digits);
      if (ad_24 < ad_12) ad_36 = NormalizeDouble(ad_24 - li_56 * ld_60 / li_52, Digits);
   }
   ai_32 = Time[l_shift_48] + 60 * Period() * li_56;
}

int WAMng_LookPrivWaveSameType(double &ada_0[][6], int ai_4, int ai_8) {
   int li_20;
   if (ai_4 <= 0 || ai_8 == 0) return (0);
   int li_ret_12 = ai_8 - 1;
   bool li_16 = FALSE;
   while (li_16 == FALSE) {
      li_20 = WAMng_WaveType(ada_0, li_ret_12);
      if (li_20 > 0) {
         if (li_20 == ai_4) {
            li_16 = TRUE;
            break;
         }
      }
      li_ret_12--;
      if (li_ret_12 < 0) li_16 = TRUE;
   }
   if (li_ret_12 > 0) return (li_ret_12);
   else return (0);
}

int WAMng_WaveType(double &ada_0[][6], int ai_4) {
   int li_8 = WAMng_WaveCount(ada_0);
   if (ai_4 < 1 || ai_4 > li_8) return (-1);
   return (ada_0[ai_4 - 1][0]);
}

int WAMng_WaveCount(double &ada_0[][6]) {
   return (ArrayRange(ada_0, 0));
}

double WAMng_GetWavePiv(double &ada_0[][6], int ai_4) {
   int li_8 = WAMng_WaveCount(ada_0);
   if (ai_4 < 1 || ai_4 > li_8) return (0);
   return (ada_0[ai_4 - 1][3]);
}

int WAMng_GetWavePivBar(double &ada_0[][6], int ai_4) {
   int li_8 = WAMng_WaveCount(ada_0);
   if (ai_4 < 1 || ai_4 > li_8) return (0);
   return (ada_0[ai_4 - 1][5]);
}

int NewWave_Manager(int ai_0, int ai_4, int ai_8, double &ada_12[][6], double &ada_16[], int &ai_20, int &ai_24, int &ai_28, int &ai_32, bool ai_36, int ai_40, int ai_44, string as_48, int ai_56) {
   int l_str2int_92;
   int l_shift_96;
   int l_shift_100;
   Init_Wave_Manager(ai_20, ai_24, ai_28);
   if (gi_428 == 0) {
      F_F_Zero(ai_4, ai_8, ai_0);
      ai_32 = 0;
      DeInit_Wave_Manager(ai_20, ai_24, ai_28);
      return (0);
   }
   if (ai_56 == 1 && ForecastHighTrendLine == TRUE && gi_500 == TRUE) FTLMng_ReDraw(ai_0);
   if (gi_432 == 0) {
      F_S_Zero(ai_4, ai_8, gi_436, ai_0);
      if (gi_432 == 0) {
         ai_32 = 0;
         DeInit_Wave_Manager(ai_20, ai_24, ai_28);
         return (0);
      }
   }
   Add_Wave(gi_428, gi_432, gi_436, ada_12);
   ai_32 = 1;
   int l_str2int_60 = StrToInteger(DoubleToStr(ada_12[ArrayRange(ada_12, 0) - 1][4], 0));
   datetime l_time_88 = Time[l_str2int_60];
   if (ai_36) {
      l_str2int_92 = l_str2int_60;
      l_shift_96 = iBarShift(NULL, 0, gi_432, FALSE);
      l_shift_100 = iBarShift(NULL, 0, gi_428, FALSE);
      for (int li_104 = l_shift_96 - 1; li_104 > l_str2int_92; li_104++) ada_16[li_104] = 0;
      ada_16[l_str2int_60] = ada_12[ArrayRange(ada_12, 0) - 1][3];
      if (gi_436 == 1) ada_16[l_str2int_60] += ai_40 * Point;
      else
         if (gi_436 == 2) ada_16[l_str2int_60] = ada_16[l_str2int_60] - ai_40 * Point;
      if (ai_0 < 50) {
         if (as_48 != "") PlaySound(as_48);
         if (ai_44 == 1) Alert(PrepareTextAlarm(Time[0], gi_436, ada_12[ArrayRange(ada_12, 0) - 1][3], l_time_88));
      }
   }
   if (ai_56 == 1 && ForecastHighTrendLine == TRUE) FTLMng_Main(ai_0, l_time_88, ada_12[ArrayRange(ada_12, 0) - 1][3], gi_436);
   gi_428 = gi_432;
   if (gi_436 == 1) gi_436 = 2;
   else {
      if (gi_436 == 2) gi_436 = 1;
      else gi_436 = -1;
   }
   gi_432 = 0;
   DeInit_Wave_Manager(ai_20, ai_24, ai_28);
   return (0);
}

void Init_Wave_Manager(int ai_0, int ai_4, int ai_8) {
   gi_428 = ai_0;
   gi_432 = ai_4;
   gi_436 = ai_8;
}

void DeInit_Wave_Manager(int &ai_0, int &ai_4, int &ai_8) {
   ai_0 = gi_428;
   ai_4 = gi_432;
   ai_8 = gi_436;
}

void F_F_Zero(int ai_0, int ai_4, int ai_8) {
   int li_12;
   double ld_16;
   int li_24;
   if (Bars - ai_8 >= ai_4 << 1) {
      li_12 = ChMnr_CurrentWaveType(ai_0, ai_4, ai_8);
      ld_16 = 0;
      li_24 = ai_8;
      gi_428 = 0;
      gi_436 = 0;
      if (li_12 > 0) {
         ld_16 = ChMnr_FindZeroFromShift(ai_0, ai_4, li_24);
         if (ld_16 <= 0.0) return;
      } else {
         li_12 = ChMnr_FirstWaveFromShift(ai_0, ai_4, li_24);
         if (li_12 <= 0) return;
         ld_16 = ChMnr_FindZeroFromShift(ai_0, ai_4, li_24);
         if (ld_16 <= 0.0) return;
      }
      gi_428 = Time[li_24];
      gi_436 = li_12;
   }
}

void F_S_Zero(int ai_0, int ai_4, int ai_8, int ai_12) {
   int li_16 = ChMnr_CurrentWaveType(ai_0, ai_4, ai_12);
   if (gi_428 == 0 || gi_436 <= 0 || ai_8 <= 0) return;
   if (li_16 == 0) {
      gi_432 = 0;
      return;
   }
   if (li_16 == ai_8) {
      gi_432 = 0;
      return;
   }
   if (li_16 != ai_8) gi_432 = Time[ai_12];
}

double ChMnr_FindZeroFromShift(int ai_0, int ai_4, int &ai_8) {
   int l_count_12 = 0;
   double l_time_16 = -99999;
   bool li_24 = FALSE;
   while (li_24 == FALSE) {
      if (ChMnr_IfZero(ai_0, ai_4, ai_8 + l_count_12) == 1) {
         li_24 = TRUE;
         l_time_16 = Time[ai_8 + l_count_12];
         ai_8 += l_count_12;
      }
      l_count_12++;
      if (ai_8 + l_count_12 >= Bars) {
         li_24 = TRUE;
         l_time_16 = -55555;
      }
   }
   return (l_time_16);
}

int ChMnr_FirstWaveFromShift(int ai_0, int ai_4, int &ai_8) {
   int l_count_12 = 0;
   int li_ret_16 = -99999;
   int li_20 = 0;
   bool li_24 = FALSE;
   while (li_24 == FALSE) {
      li_20 = ChMnr_CurrentWaveType(ai_0, ai_4, ai_8 + l_count_12);
      if (li_20 > 0) {
         li_ret_16 = li_20;
         li_24 = TRUE;
         ai_8 += l_count_12;
      }
      l_count_12++;
      if (ai_8 + l_count_12 >= Bars) {
         li_24 = TRUE;
         li_ret_16 = -55555;
      }
   }
   return (li_ret_16);
}

int ChMnr_IfZero(int a_period_0, int a_period_4, int ai_8) {
   double ld_12 = NormalizeToDigit(iMA(NULL, 0, a_period_0, 0, MODE_SMA, PRICE_CLOSE, ai_8));
   double ld_20 = NormalizeToDigit(iMA(NULL, 0, a_period_4, 0, MODE_LWMA, PRICE_WEIGHTED, ai_8));
   double ld_28 = ld_12 - ld_20;
   return (IsInChanel(ld_28, 0, Trigger_Sens));
}

int ChMnr_CurrentWaveType(int a_period_0, int a_period_4, int ai_8) {
   double l_ima_12 = iMA(NULL, 0, a_period_0, 0, MODE_SMA, PRICE_CLOSE, ai_8);
   double l_ima_20 = iMA(NULL, 0, a_period_4, 0, MODE_LWMA, PRICE_WEIGHTED, ai_8);
   double ld_28 = l_ima_12 - l_ima_20;
   if (ChMnr_IfZero(a_period_0, a_period_4, ai_8) == 1) return (0);
   if (ld_28 > 0.0) return (1);
   if (ld_28 < 0.0) return (2);
   return (-1);
}

int Add_Wave(int ai_0, int ai_4, int ai_8, double &ada_12[][6]) 
{
   int li_16 = ArrayRange(ada_12, 0);
   li_16++;
   ArrayResize(ada_12, li_16);
   ada_12[li_16 - 1][0] = ai_8;
   ada_12[li_16 - 1][1] = ai_0;
   ada_12[li_16 - 1][2] = ai_4;
   bool li_20 = FALSE;
   if (li_16 - 2 >= 0) li_20 = ada_12[li_16 - 2][5];
   int li_24 = FindPivot(ai_0, ai_4, ai_8, li_20);
   if (li_24 != 0) 
   {
      ada_12[li_16 - 1][4] = iBarShift(NULL, 0, li_24, FALSE);
      ada_12[li_16 - 1][5] = li_24;
      if (ai_8 == 1) 
         ada_12[li_16 - 1][3] = High[iBarShift(NULL, 0, li_24, FALSE)];
      else if (ai_8 == 2) 
         ada_12[li_16 - 1][3] = Low[iBarShift(NULL, 0, li_24, FALSE)];
   }
   return (0);
}

int FindPivot(int ai_0, int ai_4, int ai_8, int ai_12) {
   int l_highest_32;
   int l_lowest_36;
   if (ai_8 < 1 || ai_0 == 0 || ai_4 == 0) return (0);
   int l_shift_16 = iBarShift(NULL, 0, ai_0, TRUE);
   int l_shift_20 = iBarShift(NULL, 0, ai_4, TRUE);
   int l_shift_24 = 0;
   if (ai_12 > 0) l_shift_24 = iBarShift(NULL, 0, ai_12, TRUE);
   if (l_shift_16 == -1 || l_shift_20 == -1) return (0);
   int li_28 = 0;
   if (l_shift_24 > 0) li_28 = l_shift_24 - l_shift_20 + 1;
   else li_28 = l_shift_16 - l_shift_20 + 1;
   if (ai_8 == 1) {
      l_highest_32 = iHighest(NULL, 0, MODE_HIGH, li_28, l_shift_20);
      return (Time[l_highest_32]);
   }
   if (ai_8 == 2) {
      l_lowest_36 = iLowest(NULL, 0, MODE_LOW, li_28, l_shift_20);
      return (Time[l_lowest_36]);
   }
   return (0);
}

int init() {
   IndicatorName = GenerateIndicatorName("WALT");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   g_bars_532 = Bars;
   gi_364 = FALSE;
   TLMng_DeleteLinesCurrentTF();
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, HighSemaforSymbol);
   SetIndexBuffer(0, g_ibuf_300);
   SetIndexEmptyValue(0, 0.0);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, LowSemaforSymbol);
   SetIndexBuffer(1, g_ibuf_304);
   SetIndexEmptyValue(1, 0.0);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, LowestSemaforSymbol);
   SetIndexBuffer(2, g_ibuf_308);
   SetIndexEmptyValue(2, 0.0);
   if (High_period == 0 && Low_period == 0) {
      Alert("High_period � Low_period ����� 0. �����-�� ��� ��� ������ ���� ������ 0");
      deinit();
      return (0);
   }
   gi_340 = High_period;
   gi_344 = Double2Int(MathRound(High_period / 7));
   gi_348 = Low_period;
   gi_352 = Double2Int(MathRound(Low_period / 5));
   if (Trigger_Sens <= 0) {
      Trigger_Sens = 2;
      Alert("<Trigger_Sens> cannot have zero or less value. Now it is adjusted by default");
   }
   _visibility.Init(IndicatorObjPrefix + "CloseButton", IndicatorName);
   return (0);
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (_visibility.HandleButtonClicks())
      start();
}

void Clean()
{
   if (StayLinesAfterDelete == FALSE) 
      TLMng_DeleteAllLines();
   ObjectDelete(g_name_492);
   ArrayResize(gsa_440, 0);
   ArrayResize(gsa_444, 0);
   ArrayResize(gda_368, 0);
   ArrayResize(gda_388, 0);
   ArrayResize(gda_408, 0);
   ArrayInitialize(g_ibuf_300, 0.0);
   ArrayInitialize(g_ibuf_304, 0.0);
   ArrayInitialize(g_ibuf_308, 0.0);
   ObjectDelete(gs_durko_l1_312);
   ObjectDelete(gs_durko_l2_320);
   if (StayLinesAfterDelete == FALSE) 
      TLMng_DeleteLinesCurrentInd();
}

int deinit() 
{
   Clean();
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return (0);
}

int Double2Int(double ad_0) {
   return (StrToInteger(DoubleToStr(ad_0, 0)));
}

int IsInChanel(double ad_0, double ad_8, double ad_16) {
   double ld_24 = ad_8 + ad_16;
   double ld_32 = ad_8 - ad_16;
   if (ad_0 <= ld_24 && ad_0 >= ld_32) return (1);
   else return (0);
}

double NormalizeToDigit(double ad_0) {
   double ld_ret_8 = ad_0;
   for (int li_16 = 1; li_16 <= Digits; li_16++) ld_ret_8 = 10.0 * ld_ret_8;
   return (ld_ret_8);
}

string PrepareTextAlarm(int ai_0, int ai_4, double ad_8, int ai_16) {
   string ls_ret_20 = "";
   ls_ret_20 = ls_ret_20 + TimeToStr(ai_0, TIME_DATE) + " " + TimeToStr(ai_0, TIME_MINUTES) + " : ";
   if (ai_4 == 1) ls_ret_20 = ls_ret_20 + "The top maximum is generated : ";
   if (ai_4 == 2) ls_ret_20 = ls_ret_20 + "The bottom minimum is generated : ";
   ls_ret_20 = ls_ret_20 + TimeToStr(ai_16, TIME_DATE) + " " + TimeToStr(ai_16, TIME_MINUTES) + " Price Value: ";
   ls_ret_20 = ls_ret_20 + DoubleToStr(ad_8, Digits);
   return (ls_ret_20);
}

void CreateLab(string as_0) 
{
   if (as_0 == gs_durko_l1_312) {
      ObjectCreate(gs_durko_l1_312, OBJ_LABEL, 0, Time[1], High[1]);
      ObjectSet(gs_durko_l1_312, OBJPROP_CORNER, 0);
      ObjectSet(gs_durko_l1_312, OBJPROP_XDISTANCE, 225);
      ObjectSet(gs_durko_l1_312, OBJPROP_YDISTANCE, 8);
      ObjectSetText(gs_durko_l1_312, "Waves Auto Trend Indicator", 10, "Arial", SaddleBrown);
   }
}