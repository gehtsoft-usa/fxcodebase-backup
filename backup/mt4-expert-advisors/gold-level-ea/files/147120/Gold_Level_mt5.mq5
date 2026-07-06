// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72138

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

// Your donations will allow the service to continue onward.
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

#property indicator_chart_window
#property indicator_buffers 1

#property indicator_color1 Black

//#include <stdlib.mqh>
#import "stdlib.ex5"
string IntegerToHexString(int a0);
#import "Kernel32.dll"
bool GetVolumeInformationA(string a0, string a1, int a2, int& a3[], int a4, int a5, string a6, int a7);
#import

input bool   AlertsOn = true;
bool          gi_80    = false;
bool          gi_84    = false;
input int    drowDays = 1;
input bool   showText = true;
input double order    = 0.1;
string        gs_104;
string        gs_112;
string        gs_120;
string        gs_128;
string        gs_136;
string        gs_144;
string        gs_152;
string        gs_160;
string        gs_168;
string        gs_176;
string        gs_184;
string        gs_192;
string        gs_200;
string        gs_208;
string        gs_216;
int           gi_unused_224;
double        gd_228 = 0.25;
double        gd_236 = 1.40;
double        gd_244 = 2.50;
double        gd_252 = 3.80;
double        gd_260 = 5.40;
double        gd_268 = 7.40;
double        gd_276 = 9.70;
int           gi_284 = 504458;

// string  array_level[]   =  { "N"   ,   "B"   ,  "B1"   ,   "B2"   ,   "B3"    ,  "B4" ,   "B5"   , "B6"   ,   "S"   , "S1"   ,  "S2"  ,  "S3"  , "S4"  , "S5" , "S6"};
//
// string  array_level_[]   =  { "level0"   ,   "level1Up"   ,  "B1"   ,   "B2"   ,   "B3"    ,  "B4" ,   "B5"   , "B6"   ,   "S"   , "S1"   ,  "S2"  ,  "S3"  , "S4"  , "S5" , "S6"};
int OnInit()
{
  gd_228 *= order;
  gd_236 *= order;
  gd_244 *= order;
  gd_252 *= order;
  gd_260 *= order;
  gd_268 *= order;
  gd_276 *= order;
  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
  ObjectsDeleteAll(0,0, OBJ_TREND);
  ObjectsDeleteAll(0,0, OBJ_TEXT);
  ObjectDelete(0,"N");
  ObjectDelete(0,"B");
  ObjectDelete(0,"B1");
  ObjectDelete(0,"B2");
  ObjectDelete(0,"B3");
  ObjectDelete(0,"B4");
  ObjectDelete(0,"B5");
  ObjectDelete(0,"B6");
  ObjectDelete(0,"S");
  ObjectDelete(0,"S1");
  ObjectDelete(0,"S2");
  ObjectDelete(0,"S3");
  ObjectDelete(0,"S4");
  ObjectDelete(0,"S5");
  ObjectDelete(0,"S6");
  ObjectDelete(0,"SP");
}

MqlDateTime dt;
MqlDateTime dt1;

int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
  double open_28;
  int    time_36;
  int    datetime_40;
  double open_44;
  string name_52;
  double price_60;
  string name_68;
  double price_76;
  string name_84;
  double price_92;
  string name_100;
  double price_108;
  string name_116;
  double price_124;
  string name_132;
  double price_140;
  string name_148;
  double price_156;
  string name_164;
  double price_172;
  string name_180;
  double price_188;
  string name_196;
  double price_204;
  string name_212;
  double price_220;
  string name_228;
  double price_236;
  string name_244;
  double price_252;
  string name_260;
  double price_268;
  string name_276;
  string name_284;
  string ls_292;
  // int    li_0 = IndicatorCounted();
  int    li_0 = prev_calculated;

  string ls_4        = "2012.06.10";
  int    str2time_12 = StringToTime(ls_4);
  // if (TimeCurrent() >= str2time_12) { //return (0); //}
  // if (li_0 < 0) return (-1);
  // if (li_0 > 0) li_0--;
  // int li_16    = iBars(NULL, 0) - li_0;
  // int count_20 = 0;
  int count_20 = 0;

  // for (int i = 0; i < li_16; i++) 
	int i, start;

  start = iBars(NULL, 0) - 1;
  if (prev_calculated > 1) start = prev_calculated - 1;

  // for (i = start; i < rates_total && !IsStopped(); i++)
  for (i = start; i > 20 && !IsStopped(); i--)
	{
    TimeToStruct(time[i], dt);    
		TimeToStruct(time[i-1], dt1);

		// TimeDay(time[i])
    // TimeDay mt4: retorna el día del mes
    // if (TimeDay(time[i]) != TimeDay(time[i + 1])) {
    if(dt.day != dt1.day)
		{
      open_28     = open[i];
      time_36     = time[i];
      datetime_40 = time[i] + 86400;
      open_44     = open_28;
      name_52     = "level0" + dt.day;
      ObjectCreate(0,name_52, OBJ_TREND, 0, time_36, open_44, datetime_40, open_44);
      ObjectSetInteger(0, name_52, OBJPROP_COLOR, Yellow);
      ObjectSetInteger(0, name_52, OBJPROP_WIDTH, 0);
      ObjectSetInteger(0, name_52, OBJPROP_BACK, true);
      ObjectSetInteger(0, name_52, OBJPROP_RAY, false);
      ObjectSetInteger(0, name_52, OBJPROP_STYLE, STYLE_DASH);
      price_60 = MathPow(MathSqrt(open_28) + gd_228, 2);
      name_68  = "level1Up" + dt.day;
      ObjectCreate(0,name_68, OBJ_TREND, 0, time_36, price_60, datetime_40, price_60);
      ObjectSetInteger(0, name_68, OBJPROP_COLOR, Green);
      ObjectSetInteger(0, name_68, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, name_68, OBJPROP_BACK, true);
      ObjectSetInteger(0, name_68, OBJPROP_RAY, false);
      price_76 = MathPow(MathSqrt(open_28) - gd_228, 2);
      name_84  = "level1Down" + dt.day;
      ObjectCreate(0,name_84, OBJ_TREND, 0, time_36, price_76, datetime_40, price_76);
      ObjectSetInteger(0, name_84, OBJPROP_COLOR, Green);
      ObjectSetInteger(0, name_84, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, name_84, OBJPROP_BACK, true);
      ObjectSetInteger(0, name_84, OBJPROP_RAY, false);
      price_92 = MathPow(MathSqrt(open_28) + gd_236, 2);
      name_100 = "level2Up" + dt.day;
      ObjectCreate(0,name_100, OBJ_TREND, 0, time_36, price_92, datetime_40, price_92);
      ObjectSetInteger(0, name_100, OBJPROP_COLOR, SkyBlue);
      ObjectSetInteger(0, name_100, OBJPROP_WIDTH, 0);
      ObjectSetInteger(0, name_100, OBJPROP_BACK, true);
      ObjectSetInteger(0, name_100, OBJPROP_RAY, false);
      price_108 = MathPow(MathSqrt(open_28) - gd_236, 2);
      name_116  = "level2Down" + dt.day;
      ObjectCreate(0,name_116, OBJ_TREND, 0, time_36, price_108, datetime_40, price_108);
      ObjectSetInteger(0, name_116, OBJPROP_COLOR, Orange);
      ObjectSetInteger(0, name_116, OBJPROP_WIDTH, 0);
      ObjectSetInteger(0, name_116, OBJPROP_BACK, true);
      ObjectSetInteger(0, name_116, OBJPROP_RAY, false);
      price_124 = MathPow(MathSqrt(open_28) + gd_244, 2);
      name_132  = "level3Up" + dt.day;
      ObjectCreate(0,name_132, OBJ_TREND, 0, time_36, price_124, datetime_40, price_124);
      ObjectSetInteger(0, name_132, OBJPROP_COLOR, SkyBlue);
      ObjectSetInteger(0, name_132, OBJPROP_WIDTH, 0);
      ObjectSetInteger(0, name_132, OBJPROP_BACK, true);
      ObjectSetInteger(0, name_132, OBJPROP_RAY, false);
      price_140 = MathPow(MathSqrt(open_28) - gd_244, 2);
      name_148  = "level3Down" + dt.day;
      ObjectCreate(0,name_148, OBJ_TREND, 0, time_36, price_140, datetime_40, price_140);
      ObjectSetInteger(0, name_148, OBJPROP_COLOR, Orange);
      ObjectSetInteger(0, name_148, OBJPROP_WIDTH, 0);
      ObjectSetInteger(0, name_148, OBJPROP_BACK, true);
      ObjectSetInteger(0, name_148, OBJPROP_RAY, false);
      price_156 = MathPow(MathSqrt(open_28) + gd_252, 2);
      name_164  = "level4Up" + dt.day;
      ObjectCreate(0,name_164, OBJ_TREND, 0, time_36, price_156, datetime_40, price_156);
      ObjectSetInteger(0, name_164, OBJPROP_COLOR, SkyBlue);
      ObjectSetInteger(0, name_164, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, name_164, OBJPROP_BACK, true);
      ObjectSetInteger(0, name_164, OBJPROP_RAY, false);
      price_172 = MathPow(MathSqrt(open_28) - gd_252, 2);
      name_180  = "level4Down" + dt.day;
      ObjectCreate(0,name_180, OBJ_TREND, 0, time_36, price_172, datetime_40, price_172);
      ObjectSetInteger(0, name_180, OBJPROP_COLOR, Orange);
      ObjectSetInteger(0, name_180, OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, name_180, OBJPROP_BACK, true);
      ObjectSetInteger(0, name_180, OBJPROP_RAY, false);
      price_188 = MathPow(MathSqrt(open_28) + gd_260, 2);
      name_196  = "level5Up" + dt.day;
      ObjectCreate(0,name_196, OBJ_TREND, 0, time_36, price_188, datetime_40, price_188);
      ObjectSetInteger(0, name_196, OBJPROP_COLOR, SkyBlue);
      ObjectSetInteger(0, name_196, OBJPROP_WIDTH, 0);
      ObjectSetInteger(0, name_196, OBJPROP_BACK, true);
      ObjectSetInteger(0, name_196, OBJPROP_RAY, false);
      price_204 = MathPow(MathSqrt(open_28) - gd_260, 2);
      name_212  = "level5Down" + dt.day;
      ObjectCreate(0,name_212, OBJ_TREND, 0, time_36, price_204, datetime_40, price_204);
      ObjectSetInteger(0, name_212, OBJPROP_COLOR, Orange);
      ObjectSetInteger(0, name_212, OBJPROP_WIDTH, 0);
      ObjectSetInteger(0, name_212, OBJPROP_BACK, true);
      ObjectSetInteger(0, name_212, OBJPROP_RAY, false);
      price_220 = MathPow(MathSqrt(open_28) + gd_268, 2);
      name_228  = "level6Up" + dt.day;
      ObjectCreate(0,name_228, OBJ_TREND, 0, time_36, price_220, datetime_40, price_220);
      ObjectSetInteger(0, name_228, OBJPROP_COLOR, SkyBlue);
      ObjectSetInteger(0, name_228, OBJPROP_WIDTH, 0);
      ObjectSetInteger(0, name_228, OBJPROP_BACK, true);
      ObjectSetInteger(0, name_228, OBJPROP_RAY, false);
      price_236 = MathPow(MathSqrt(open_28) - gd_268, 2);
      name_244  = "level6Down" + dt.day;
      ObjectCreate(0,name_244, OBJ_TREND, 0, time_36, price_236, datetime_40, price_236);
      ObjectSetInteger(0, name_244, OBJPROP_COLOR, Orange);
      ObjectSetInteger(0, name_244, OBJPROP_WIDTH, 0);
      ObjectSetInteger(0, name_244, OBJPROP_BACK, true);
      ObjectSetInteger(0, name_244, OBJPROP_RAY, false);
      price_252 = MathPow(MathSqrt(open_28) + gd_276, 2);
      name_260  = "level7Up" + dt.day;
      ObjectCreate(0,name_260, OBJ_TREND, 0, time_36, price_252, datetime_40, price_252);
      ObjectSetInteger(0, name_260, OBJPROP_COLOR, SkyBlue);
      ObjectSetInteger(0, name_260, OBJPROP_WIDTH, 3);
      ObjectSetInteger(0, name_260, OBJPROP_BACK, true);
      ObjectSetInteger(0, name_260, OBJPROP_RAY, false);
      price_268 = MathPow(MathSqrt(open_28) - gd_276, 2);
      name_276  = "level7Down" + dt.day;
      ObjectCreate(0,name_276, OBJ_TREND, 0, time_36, price_268, datetime_40, price_268);
      ObjectSetInteger(0, name_276, OBJPROP_COLOR, Orange);
      ObjectSetInteger(0, name_276, OBJPROP_WIDTH, 3);
      ObjectSetInteger(0, name_276, OBJPROP_BACK, true);
      ObjectSetInteger(0, name_276, OBJPROP_RAY, false);
      gs_216        = open_44;
      gs_104        = price_60;
      gs_112        = price_76;
      gs_120        = price_92;
      gs_168        = price_108;
      gs_128        = price_124;
      gs_176        = price_140;
      gs_136        = price_156;
      gs_184        = price_172;
      gs_144        = price_188;
      gs_192        = price_204;
      gs_152        = price_220;
      gs_200        = price_236;
      gs_160        = price_252;
      gs_208        = price_268;
      gi_unused_224 = 2;
      gs_104        = DoubleToString(price_60, Digits());
      gs_112        = DoubleToString(price_76, Digits());
      gs_120        = DoubleToString(price_92, Digits());
      gs_168        = DoubleToString(price_108, Digits());
      gs_128        = DoubleToString(price_124, Digits());
      gs_176        = DoubleToString(price_140, Digits());
      gs_136        = DoubleToString(price_156, Digits());
      gs_184        = DoubleToString(price_172, Digits());
      gs_144        = DoubleToString(price_188, Digits());
      gs_192        = DoubleToString(price_204, Digits());
      gs_152        = DoubleToString(price_220, Digits());
      gs_200        = DoubleToString(price_236, Digits());
      gs_160        = DoubleToString(price_252, Digits());
      gs_208        = DoubleToString(price_268, Digits());
      gs_216        = DoubleToString(open_44, Digits());
      ObjectCreate(0,"N", OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0, "N", OBJPROP_TEXT, "MAHI LEVEL");
      // ObjectSetString(0, "N", OBJPROP_TEXT, "MAHI LEVEL", 10, "Arial Black", White);
      ObjectSetInteger(0, "N", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "N", OBJPROP_XDISTANCE, 1);
      ObjectSetInteger(0, "N", OBJPROP_YDISTANCE, 10);
      ObjectCreate(0,"B", OBJ_LABEL, 0, 0, 0);
      // ObjectSetString(0, "B", OBJPROP_TEXT, "Buy @ " + gs_104, 10, "Arial Black", LimeGreen);
      ObjectSetString(0, "B", OBJPROP_TEXT, "Buy @ " + gs_104);
      ObjectSetInteger(0, "B", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "B", OBJPROP_XDISTANCE, 1);
      ObjectSetInteger(0, "B", OBJPROP_YDISTANCE, 30);
      ObjectCreate(0,"B1", OBJ_LABEL, 0, 0, 0);
      // ObjectSetString(0, "B1",OBJPROP_TEXT,  "T1 @ " + gs_120, 10, "Arial Black", LimeGreen);
      ObjectSetString(0, "B1",OBJPROP_TEXT,  "T1 @ " + gs_120);
      ObjectSetInteger(0, "B1", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "B1", OBJPROP_XDISTANCE, 120);
      ObjectSetInteger(0, "B1", OBJPROP_YDISTANCE, 30);
      ObjectCreate(0,"B2", OBJ_LABEL, 0, 0, 0);
      // ObjectSetString(0, "B2",OBJPROP_TEXT,  "T2 @ " + gs_128, 10, "Arial Black", LimeGreen);
      ObjectSetString(0, "B2",OBJPROP_TEXT,  "T2 @ " + gs_128);
      ObjectSetInteger(0, "B2", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "B2", OBJPROP_XDISTANCE, 220);
      ObjectSetInteger(0, "B2", OBJPROP_YDISTANCE, 30);
      ObjectCreate(0,"B3", OBJ_LABEL, 0, 0, 0);
      // ObjectSetString(0, "B3",OBJPROP_TEXT,  "T3 @ " + gs_136, 10, "Arial Black", LimeGreen);
      ObjectSetString(0, "B3",OBJPROP_TEXT,  "T3 @ " + gs_136);
      ObjectSetInteger(0, "B3", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "B3", OBJPROP_XDISTANCE, 320);
      ObjectSetInteger(0, "B3", OBJPROP_YDISTANCE, 30);
      ObjectCreate(0,"B4", OBJ_LABEL, 0, 0, 0);
      // ObjectSetString(0, "B4",OBJPROP_TEXT,  "T4 @ " + gs_144, 10, "Arial Black", LimeGreen);
      ObjectSetString(0, "B4",OBJPROP_TEXT,  "T4 @ " + gs_144);
      ObjectSetInteger(0, "B4", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "B4", OBJPROP_XDISTANCE, 420);
      ObjectSetInteger(0, "B4", OBJPROP_YDISTANCE, 30);
      ObjectCreate(0,"B5", OBJ_LABEL, 0, 0, 0);
      // ObjectSetString(0, "B5",OBJPROP_TEXT,  "T5 @ " + gs_152, 10, "Arial Black", LimeGreen);
      ObjectSetString(0, "B5",OBJPROP_TEXT,  "T5 @ " + gs_152);
      ObjectSetInteger(0, "B5", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "B5", OBJPROP_XDISTANCE, 520);
      ObjectSetInteger(0, "B5", OBJPROP_YDISTANCE, 30);
      ObjectCreate(0,"B6", OBJ_LABEL, 0, 0, 0);
      // ObjectSetString(0, "B6",OBJPROP_TEXT,  "T6 @ " + gs_160, 10, "Arial Black", LimeGreen);
      ObjectSetString(0, "B6",OBJPROP_TEXT,  "T6 @ " + gs_160);
      ObjectSetInteger(0, "B6", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "B6", OBJPROP_XDISTANCE, 620);
      ObjectSetInteger(0, "B6", OBJPROP_YDISTANCE, 30);
      ObjectCreate(0,"S", OBJ_LABEL, 0, 0, 0);
      // ObjectSetString(0, "S", OBJPROP_TEXT, "Sell @ " + gs_112, 10, "Arial Black", Tomato);
      ObjectSetString(0, "S", OBJPROP_TEXT, "Sell @ " + gs_112);
      ObjectSetInteger(0, "S", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "S", OBJPROP_XDISTANCE, 1);
      ObjectSetInteger(0, "S", OBJPROP_YDISTANCE, 50);
      ObjectCreate(0,"S1", OBJ_LABEL, 0, 0, 0);
      // ObjectSetString(0, "S1",OBJPROP_TEXT,  "T1 @ " + gs_168, 10, "Arial Black", Tomato);
      ObjectSetString(0, "S1",OBJPROP_TEXT,  "T1 @ " + gs_168);
      ObjectSetInteger(0, "S1", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "S1", OBJPROP_XDISTANCE, 120);
      ObjectSetInteger(0, "S1", OBJPROP_YDISTANCE, 50);
      ObjectCreate(0,"S2", OBJ_LABEL, 0, 0, 0);
      // ObjectSetString(0, "S2",OBJPROP_TEXT,  "T2 @ " + gs_176, 10, "Arial Black", Tomato);
      ObjectSetString(0, "S2",OBJPROP_TEXT,  "T2 @ " + gs_176);
      ObjectSetInteger(0, "S2", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "S2", OBJPROP_XDISTANCE, 220);
      ObjectSetInteger(0, "S2", OBJPROP_YDISTANCE, 50);
      ObjectCreate(0,"S3", OBJ_LABEL, 0, 0, 0);
      // ObjectSetString(0, "S3",OBJPROP_TEXT,  "T3 @ " + gs_184, 10, "Arial Black", Tomato);
      ObjectSetString(0, "S3",OBJPROP_TEXT,  "T3 @ " + gs_184);
      ObjectSetInteger(0, "S3", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "S3", OBJPROP_XDISTANCE, 320);
      ObjectSetInteger(0, "S3", OBJPROP_YDISTANCE, 50);
      ObjectCreate(0,"S4", OBJ_LABEL, 0, 0, 0);
      // ObjectSetString(0, "S4",OBJPROP_TEXT,  "T4 @ " + gs_192, 10, "Arial Black", Tomato);
      ObjectSetString(0, "S4",OBJPROP_TEXT,  "T4 @ " + gs_192);
      ObjectSetInteger(0, "S4", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "S4", OBJPROP_XDISTANCE, 420);
      ObjectSetInteger(0, "S4", OBJPROP_YDISTANCE, 50);
      ObjectCreate(0,"S5", OBJ_LABEL, 0, 0, 0);
      // ObjectSetString(0, "S5",OBJPROP_TEXT,  "T5 @ " + gs_200, 10, "Arial Black", Tomato);
      ObjectSetString(0, "S5",OBJPROP_TEXT,  "T5 @ " + gs_200);
      ObjectSetInteger(0, "S5", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "S5", OBJPROP_XDISTANCE, 520);
      ObjectSetInteger(0, "S5", OBJPROP_YDISTANCE, 50);
      ObjectCreate(0,"S6", OBJ_LABEL, 0, 0, 0);
      // ObjectSetString(0, "S6",OBJPROP_TEXT,  "T6 @ " + gs_208, 10, "Arial Black", Tomato);
      ObjectSetString(0, "S6",OBJPROP_TEXT,  "T6 @ " + gs_208);
      ObjectSetInteger(0, "S6", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "S6", OBJPROP_XDISTANCE, 620);
      ObjectSetInteger(0, "S6", OBJPROP_YDISTANCE, 50);
      ObjectCreate(0,"SP", OBJ_LABEL, 0, 0, 0);
      // ObjectSetString(0, "SP",OBJPROP_TEXT,  "Pivot @ " + gs_216, 10, "Arial Black", White);
      ObjectSetString(0, "SP",OBJPROP_TEXT,  "Pivot @ " + gs_216);
      ObjectSetInteger(0, "SP", OBJPROP_CORNER, 0);
      ObjectSetInteger(0, "SP", OBJPROP_XDISTANCE, 1);
      ObjectSetInteger(0, "SP", OBJPROP_YDISTANCE, 70);
      if (showText) 
			{
        name_284 = "level0label" + dt.day;
        ls_292   = "Pivot";
        ObjectCreate(0,name_284, OBJ_TEXT, 0, time_36 + StringLen(ls_292), open_44);
        // ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        name_284 = "level1UpLabel" + dt.day;
        ls_292   = "Buy";
        ObjectCreate(0,name_284, OBJ_TEXT, 0, time_36 + StringLen(ls_292), price_60);
        // ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        name_284 = "level1DownLabel" + dt.day;
        ls_292   = "Sell";
        ObjectCreate(0,name_284, OBJ_TEXT, 0, time_36 + StringLen(ls_292), price_76);
        ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        name_284 = "level2UpLabel" + dt.day;
        ls_292   = "BT1";
        ObjectCreate(0,name_284, OBJ_TEXT, 0, time_36 + StringLen(ls_292), price_92);
        // ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292, 10, "Tahoma", White);
        ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        name_284 = "level2DownLabel" + dt.day;
        ls_292   = "ST1";
        ObjectCreate(0,name_284, OBJ_TEXT, 0, time_36 + StringLen(ls_292), price_108);
        // ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292, 10, "Tahoma", White);
        ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        name_284 = "level3UpLabel" + dt.day;
        ls_292   = "BT2";
        ObjectCreate(0,name_284, OBJ_TEXT, 0, time_36 + StringLen(ls_292), price_124);
        // ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292, 10, "Tahoma", White);
        ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        name_284 = "level3DownLabel" + dt.day;
        ls_292   = "ST2";
        ObjectCreate(0,name_284, OBJ_TEXT, 0, time_36 + StringLen(ls_292), price_140);
        // ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292, 10, "Tahoma", White);
        ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        name_284 = "level4UpLabel" + dt.day;
        ls_292   = "BT3";
        ObjectCreate(0,name_284, OBJ_TEXT, 0, time_36 + StringLen(ls_292), price_156);
        // ObjectSetString(0, name_284, OBJPROP_TEXT, 284, ls_292, 10, "Tahoma", White);
        ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        name_284 = "level4DownLabel" + dt.day;
        ls_292   = "ST3";
        ObjectCreate(0,name_284, OBJ_TEXT, 0, time_36 + StringLen(ls_292), price_172);
        ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        name_284 = "level5UpLabel" + dt.day;
        ls_292   = "BT4";
        ObjectCreate(0,name_284, OBJ_TEXT, 0, time_36 + StringLen(ls_292), price_188);
        ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        name_284 = "level5DownLabel" + dt.day;
        ls_292   = "ST4";
        ObjectCreate(0,name_284, OBJ_TEXT, 0, time_36 + StringLen(ls_292), price_204);
        ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        name_284 = "level6UpLabel" + dt.day;
        ls_292   = "BT5";
        ObjectCreate(0,name_284, OBJ_TEXT, 0, time_36 + StringLen(ls_292), price_220);
        ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        name_284 = "level6DownLabel" + dt.day;
        ls_292   = "ST5";
        ObjectCreate(0,name_284, OBJ_TEXT, 0, time_36 + StringLen(ls_292), price_236);
        ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        name_284 = "level7UpLabel" + dt.day;
        ls_292   = "BT6";
        ObjectCreate(0,name_284, OBJ_TEXT, 0, time_36 + StringLen(ls_292), price_252);
        ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        name_284 = "level7DownLabel" + dt.day;
        ls_292   = "ST6";
        ObjectCreate(0,name_284, OBJ_TEXT, 0, time_36 + StringLen(ls_292), price_268);
        ObjectSetString(0, name_284, OBJPROP_TEXT, ls_292);
        
				if (AlertsOn) {
          if (close[0] > price_60 && gi_80 == false) { gi_80 = true; }
          if (close[0] < price_76 && gi_84 == false) { gi_84 = true; }
        }
      }
      
			count_20++;
    }
    if (count_20 >= drowDays) break;
  }
  return (0);
}

string f0_0(string as_0)
{
  int    lia_8[1]  = {0};
  string ls_ret_12 = "";
  if (GetVolumeInformationA(as_0 + ":\\", "                ", 15, lia_8, 0, 0, "                ", 15)) {
    
		ls_ret_12 = IntegerToHexString(lia_8[0]);
    string st1 = StringSubstr(ls_ret_12, 0, 4);
    string st2 = StringSubstr(ls_ret_12, 4);
    StringConcatenate(ls_ret_12, st1, "-", st2);
  }
  return (ls_ret_12);
}



//+------------------------------------------------------------------+
//|Copyright 2022, Carlos Valloggia
//|https://www.thetradingrobots.com
//+------------------------------------------------------------------+
// #property copyright "Copyright 2022. Carlos Valloggia"
// #property link "https://www.mql5.com/en/users/cvalloggia"
// #property version "1.00"
// #property indicator_chart_window
// #property indicator_buffers 1
// #property indicator_plots 1
// //--- plot Linea1
// #property indicator_label1 "Linea1"
// #property indicator_type1  DRAW_LINE
// #property indicator_color1 clrRed
// #property indicator_style1 STYLE_SOLID
// #property indicator_width1 1
// //--- indicator buffers
// double Linea1Buffer[];
// //+------------------------------------------------------------------+
// //| Custom indicator initialization function                         |
// //+------------------------------------------------------------------+
// int OnInit()
// {
//   //--- indicator buffers mapping
//   SetIndexBuffer(0, CTLBuffer, INDICATOR_DATA);

//   //---
//   return (INIT_SUCCEEDED);
// }
// //+------------------------------------------------------------------+
// //| Custom indicator iteration function                              |
// //+------------------------------------------------------------------+
// int OnCalculate(const int       rates_total,
//                 const int       prev_calculated,
//                 const datetime& time[],
//                 const double&   open[],
//                 const double&   high[],
//                 const double&   low[],
//                 const double&   close[],
//                 const long&     tick_volume[],
//                 const long&     volume[],
//                 const int&      spread[])
// {
//   //---
//   //--- return value of prev_calculated for next call
//   return (rates_total);
// }
// //+------------------------------------------------------------------+