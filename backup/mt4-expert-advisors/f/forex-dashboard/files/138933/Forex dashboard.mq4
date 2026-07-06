// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70635

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

#property indicator_chart_window

input int     buy_level         = 90;
input int     sell_level        = 10;
input int     fontsize_small    = 10;
input ENUM_BASE_CORNER whichcorner = CORNER_LEFT_UPPER; // Corner


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   initGraph();
   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(0, OBJ_LABEL);

   return (0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   double ld_336;
   double ld_344;
   double ld_352;
   double ld_360;
   double ld_368;
   double ld_376;
   double ld_384;
   double ld_392;
   double ld_400;
   double ld_408;
   double ld_416;
   double ld_424;
   double ld_432;
   double ld_440;
   double ld_448;
   double ld_456;
   double ld_464;
   double ld_472;
   double ld_480;
   double ld_488;
   double ld_496;
   double ld_504;
   double ld_512;
   double ld_520;
   double ld_528;
   double ld_536;
   double ld_544;
   double ld_552;
   double ld_560;


   double ld_0 = iHigh("AUDJPY", PERIOD_D1, 0) - iLow("AUDJPY", PERIOD_D1, 0);
   double ld_8 = iHigh("AUDNZD", PERIOD_D1, 0) - iLow("AUDNZD", PERIOD_D1, 0);
   double ld_16 = iHigh("AUDUSD", PERIOD_D1, 0) - iLow("AUDUSD", PERIOD_D1, 0);
   double ld_24 = iHigh("AUDEUR", PERIOD_D1, 0) - iLow("AUDEUR", PERIOD_D1, 0);
   double ld_32 = iHigh("GBPAUD", PERIOD_D1, 0) - iLow("GBPAUD", PERIOD_D1, 0);
   double ld_40 = iHigh("AUDCHF", PERIOD_D1, 0) - iLow("AUDCHF", PERIOD_D1, 0);
   double ld_48 = iHigh("AUDCAD", PERIOD_D1, 0) - iLow("AUDCAD", PERIOD_D1, 0);
   double ld_56 = iHigh("CHFJPY", PERIOD_D1, 0) - iLow("CHFJPY", PERIOD_D1, 0);
   double ld_64 = iHigh("NZDCHF", PERIOD_D1, 0) - iLow("NZDCHF", PERIOD_D1, 0);
   double ld_72 = iHigh("USDCHF", PERIOD_D1, 0) - iLow("USDCHF", PERIOD_D1, 0);
   double ld_80 = iHigh("EURCHF", PERIOD_D1, 0) - iLow("EURCHF", PERIOD_D1, 0);
   double ld_88 = iHigh("GBPCHF", PERIOD_D1, 0) - iLow("GBPCHF", PERIOD_D1, 0);
   double ld_96 = iHigh("CADCHF", PERIOD_D1, 0) - iLow("CADCHF", PERIOD_D1, 0);
   double ld_104 = iHigh("CADJPY", PERIOD_D1, 0) - iLow("CADJPY", PERIOD_D1, 0);
   double ld_112 = iHigh("NZDCAD", PERIOD_D1, 0) - iLow("NZDCAD", PERIOD_D1, 0);
   double ld_120 = iHigh("USDCAD", PERIOD_D1, 0) - iLow("USDCAD", PERIOD_D1, 0);
   double ld_128 = iHigh("EURCAD", PERIOD_D1, 0) - iLow("EURCAD", PERIOD_D1, 0);
   double ld_136 = iHigh("GBPCAD", PERIOD_D1, 0) - iLow("GBPCAD", PERIOD_D1, 0);
   double ld_144 = iHigh("EURJPY", PERIOD_D1, 0) - iLow("EURJPY", PERIOD_D1, 0);
   double ld_152 = iHigh("EURNZD", PERIOD_D1, 0) - iLow("EURNZD", PERIOD_D1, 0);
   double ld_160 = iHigh("EURUSD", PERIOD_D1, 0) - iLow("EURUSD", PERIOD_D1, 0);
   double ld_168 = iHigh("EURGBP", PERIOD_D1, 0) - iLow("EURGBP", PERIOD_D1, 0);
   double ld_176 = iHigh("EURAUD", PERIOD_D1, 0) - iLow("EURAUD", PERIOD_D1, 0);
   double ld_184 = iHigh("GBPJPY", PERIOD_D1, 0) - iLow("GBPJPY", PERIOD_D1, 0);
   double ld_192 = iHigh("GBPNZD", PERIOD_D1, 0) - iLow("GBPNZD", PERIOD_D1, 0);
   double ld_200 = iHigh("GBPUSD", PERIOD_D1, 0) - iLow("GBPUSD", PERIOD_D1, 0);
   double ld_208 = iHigh("USDJPY", PERIOD_D1, 0) - iLow("USDJPY", PERIOD_D1, 0);
   double ld_216 = iHigh("NZDJPY", PERIOD_D1, 0) - iLow("NZDJPY", PERIOD_D1, 0);


   if(ld_0 != 0.0)
      ld_336 = 100.0 * ((iClose("AUDJPY", PERIOD_D1, 0) - iLow("AUDJPY", PERIOD_D1, 0)) / ld_0);
   else
      ld_336 = 0;
   if(ld_8 != 0.0)
      ld_344 = 100.0 * ((iClose("AUDNZD", PERIOD_D1, 0) - iLow("AUDNZD", PERIOD_D1, 0)) / ld_8);
   else
      ld_344 = 0;
   if(ld_16 != 0.0)
      ld_352 = 100.0 * ((iClose("AUDUSD", PERIOD_D1, 0) - iLow("AUDUSD", PERIOD_D1, 0)) / ld_16);
   else
      ld_352 = 0;
   if(ld_24 != 0.0)
      ld_360 = 100.0 * ((iClose("AUDEUR", PERIOD_D1, 0) - iLow("AUDEUR", PERIOD_D1, 0)) / ld_24);
   else
      ld_360 = 0;
   if(ld_32 != 0.0)
      ld_368 = 100.0 * ((iClose("GBPAUD", PERIOD_D1, 0) - iLow("GBPAUD", PERIOD_D1, 0)) / ld_32);
   else
      ld_368 = 0;
   if(ld_40 != 0.0)
      ld_376 = 100.0 * ((iClose("AUDCHF", PERIOD_D1, 0) - iLow("AUDCHF", PERIOD_D1, 0)) / ld_40);
   else
      ld_376 = 0;
   if(ld_48 != 0.0)
      ld_384 = 100.0 * ((iClose("AUDCAD", PERIOD_D1, 0) - iLow("AUDCAD", PERIOD_D1, 0)) / ld_48);
   else
      ld_384 = 0;
   if(ld_56 != 0.0)
      ld_392 = 100.0 * ((iClose("CHFJPY", PERIOD_D1, 0) - iLow("CHFJPY", PERIOD_D1, 0)) / ld_56);
   else
      ld_392 = 0;
   if(ld_64 != 0.0)
      ld_400 = 100.0 * ((iClose("NZDCHF", PERIOD_D1, 0) - iLow("NZDCHF", PERIOD_D1, 0)) / ld_64);
   else
      ld_400 = 0;
   if(ld_72 != 0.0)
      ld_408 = 100.0 * ((iClose("USDCHF", PERIOD_D1, 0) - iLow("USDCHF", PERIOD_D1, 0)) / ld_72);
   else
      ld_408 = 0;
   if(ld_80 != 0.0)
      ld_416 = 100.0 * ((iClose("EURCHF", PERIOD_D1, 0) - iLow("EURCHF", PERIOD_D1, 0)) / ld_80);
   else
      ld_416 = 0;
   if(ld_88 != 0.0)
      ld_424 = 100.0 * ((iClose("GBPCHF", PERIOD_D1, 0) - iLow("GBPCHF", PERIOD_D1, 0)) / ld_88);
   else
      ld_424 = 0;
   if(ld_96 != 0.0)
      ld_432 = 100.0 * ((iClose("CADCHF", PERIOD_D1, 0) - iLow("CADCHF", PERIOD_D1, 0)) / ld_96);
   else
      ld_432 = 0;
   if(ld_104 != 0.0)
      ld_440 = 100.0 * ((iClose("CADJPY", PERIOD_D1, 0) - iLow("CADJPY", PERIOD_D1, 0)) / ld_104);
   else
      ld_440 = 0;
   if(ld_112 != 0.0)
      ld_448 = 100.0 * ((iClose("NZDCAD", PERIOD_D1, 0) - iLow("NZDCAD", PERIOD_D1, 0)) / ld_112);
   else
      ld_448 = 0;
   if(ld_120 != 0.0)
      ld_456 = 100.0 * ((iClose("USDCAD", PERIOD_D1, 0) - iLow("USDCAD", PERIOD_D1, 0)) / ld_120);
   else
      ld_456 = 0;
   if(ld_128 != 0.0)
      ld_464 = 100.0 * ((iClose("EURCAD", PERIOD_D1, 0) - iLow("EURCAD", PERIOD_D1, 0)) / ld_128);
   else
      ld_464 = 0;
   if(ld_136 != 0.0)
      ld_472 = 100.0 * ((iClose("GBPCAD", PERIOD_D1, 0) - iLow("GBPCAD", PERIOD_D1, 0)) / ld_136);
   else
      ld_472 = 0;
   if(ld_144 != 0.0)
      ld_480 = 100.0 * ((iClose("EURJPY", PERIOD_D1, 0) - iLow("EURJPY", PERIOD_D1, 0)) / ld_144);
   else
      ld_480 = 0;
   if(ld_152 != 0.0)
      ld_488 = 100.0 * ((iClose("EURNZD", PERIOD_D1, 0) - iLow("EURNZD", PERIOD_D1, 0)) / ld_152);
   else
      ld_488 = 0;
   if(ld_160 != 0.0)
      ld_496 = 100.0 * ((iClose("EURUSD", PERIOD_D1, 0) - iLow("EURUSD", PERIOD_D1, 0)) / ld_160);
   else
      ld_496 = 0;
   if(ld_168 != 0.0)
      ld_504 = 100.0 * ((iClose("EURGBP", PERIOD_D1, 0) - iLow("EURGBP", PERIOD_D1, 0)) / ld_168);
   else
      ld_504 = 0;
   if(ld_176 != 0.0)
      ld_512 = 100.0 * ((iClose("EURAUD", PERIOD_D1, 0) - iLow("EURAUD", PERIOD_D1, 0)) / ld_176);
   else
      ld_512 = 0;
   if(ld_184 != 0.0)
      ld_520 = 100.0 * ((iClose("GBPJPY", PERIOD_D1, 0) - iLow("GBPJPY", PERIOD_D1, 0)) / ld_184);
   else
      ld_520 = 0;
   if(ld_192 != 0.0)
      ld_528 = 100.0 * ((iClose("GBPNZD", PERIOD_D1, 0) - iLow("GBPNZD", PERIOD_D1, 0)) / ld_192);
   else
      ld_528 = 0;
   if(ld_200 != 0.0)
      ld_536 = 100.0 * ((iClose("GBPUSD", PERIOD_D1, 0) - iLow("GBPUSD", PERIOD_D1, 0)) / ld_200);
   else
      ld_536 = 0;
   if(ld_216 != 0.0)
      ld_544 = 100.0 * ((iClose("NZDJPY", PERIOD_D1, 0) - iLow("NZDJPY", PERIOD_D1, 0)) / ld_216);
   else
      ld_544 = 0;
   if(ld_208 != 0.0)
      ld_552 = 100.0 * ((iClose("USDJPY", PERIOD_D1, 0) - iLow("USDJPY", PERIOD_D1, 0)) / ld_208);
   else
      ld_552 = 0;


   double ld_672 = (ld_336 + ld_344 + ld_352 + ld_360 + (100 - ld_368) + ld_376 + ld_384) / 7.0;
   double ld_680 = (ld_392 + (100 - ld_400) + (100 - ld_408) + (100 - ld_416) + (100 - ld_424) + (100 - ld_376) + (100 - ld_432)) / 7.0;
   double ld_688 = (ld_440 + (100 - ld_448) + (100 - ld_456) + (100 - ld_464) + (100 - ld_472) + (100 - ld_384) + (100 - ld_432)) / 7.0;
   double ld_696 = (ld_480 + ld_488 + ld_496 + ld_464 + ld_504 + ld_512 + ld_416) / 7.0;
   double ld_704 = (ld_520 + ld_528 + ld_536 + ld_472 + (100 - ld_504) + ld_368 + ld_424) / 7.0;
   double ld_712 = (100 - ld_336 + (100 - ld_392) + (100 - ld_440) + (100 - ld_480) + (100 - ld_520) + (100 - ld_544) + (100 - ld_552)) / 7.0;
   double ld_720 = (ld_544 + (100 - ld_528) + ld_560 + ld_448 + (100 - ld_488) + (100 - ld_344) + ld_400) / 7.0;
   double ld_728 = (100 - ld_352 + ld_408 + ld_456 + (100 - ld_496) + (100 - ld_536) + ld_552 + (100 - ld_560)) / 7.0;


   paint("AUD", ld_672);
   paint("CHF", ld_680);
   paint("CAD", ld_688);
   paint("EUR", ld_696);
   paint("GBP", ld_704);
   paint("JPY", ld_712);
   paint("NZD", ld_720);
   paint("USD", ld_728);


   return (0);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void objectCreate(string a_name_0, int a_x_8, int a_y_12, string a_text_16 = "-", int a_fontsize_24 = 60, string a_fontname_28 = "Arial", color a_color_36 = -1)
{
   ObjectCreate(a_name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSet(a_name_0, OBJPROP_CORNER, whichcorner);
   ObjectSet(a_name_0, OBJPROP_COLOR, a_color_36);
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_8);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_12);
   ObjectSetText(a_name_0, a_text_16, a_fontsize_24, a_fontname_28, a_color_36);
}

void createBar(string id, int x, int y)
{
   for (int i = 1; i <= 51; i++)
   {
      objectCreate(id + i, x, y);
      if (whichcorner >= 2)
      {
         y += 2;
      }
      else
      {
         y -= 2;
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initGraph()
  {
   ObjectsDeleteAll(0, OBJ_LABEL);
   int li_0 = 110;
   int li_4 = 20;
   bool lowerBorder = whichcorner >= 2;
   int txtPos = lowerBorder ? li_0 : li_0 + 85;
   int prPos = lowerBorder ? li_0 - 20 : li_0 + 65;
   createBar("aud_", li_4, li_0);
   objectCreate("audtxt", li_4, txtPos, "AUD", fontsize_small, "Arial Narrow", White);
   objectCreate("audp", li_4, prPos, DoubleToStr(9, 1), fontsize_small, "Arial Narrow", White);
   li_4 += 35;
   createBar("chf_", li_4, li_0);
   objectCreate("chftxt", li_4, txtPos, "CHF", fontsize_small, "Arial Narrow", White);
   objectCreate("chfp", li_4, prPos, DoubleToStr(9, 1), fontsize_small, "Arial Narrow", White);
   li_4 += 35;
   createBar("cad_", li_4, li_0);
   objectCreate("cadtxt", li_4, txtPos, "CAD", fontsize_small, "Arial Narrow", White);
   objectCreate("cadp", li_4, prPos, DoubleToStr(9, 1), fontsize_small, "Arial Narrow", White);
   li_4 += 35;
   createBar("eur_", li_4, li_0);
   objectCreate("eurtxt", li_4, txtPos, "EUR", fontsize_small, "Arial Narrow", White);
   objectCreate("eurp", li_4, prPos, DoubleToStr(9, 1), fontsize_small, "Arial Narrow", White);
   li_4 += 35;
   createBar("gbp_", li_4, li_0);
   objectCreate("gbptxt", li_4, txtPos, "GBP", fontsize_small, "Arial Narrow", White);
   objectCreate("gbpp", li_4, prPos, DoubleToStr(9, 1), fontsize_small, "Arial Narrow", White);
   li_4 += 35;
   createBar("jpy_", li_4, li_0);
   objectCreate("jpytxt", li_4, txtPos, "JPY", fontsize_small, "Arial Narrow", White);
   objectCreate("jpyp", li_4, prPos, DoubleToStr(9, 1), fontsize_small, "Arial Narrow", White);
   li_4 += 35;
   createBar("nzd_", li_4, li_0);
   objectCreate("nzdtxt", li_4, txtPos, "NZD", fontsize_small, "Arial Narrow", White);
   objectCreate("nzdp", li_4, prPos, DoubleToStr(9, 1), fontsize_small, "Arial Narrow", White);
   li_4 += 35;
   createBar("usd_", li_4, li_0);
   objectCreate("usdtxt", li_4, txtPos, "USD", fontsize_small, "Arial Narrow", White);
   objectCreate("usdp", li_4, prPos, DoubleToStr(9, 1), fontsize_small, "Arial Narrow", White);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void paint(string as_0, double ad_8)
{
   string ls_16 = "";
   if(as_0 == "AUD")
      ls_16 = "aud";
   if(as_0 == "CHF")
      ls_16 = "chf";
   if(as_0 == "CAD")
      ls_16 = "cad";
   if(as_0 == "EUR")
      ls_16 = "eur";
   if(as_0 == "GBP")
      ls_16 = "gbp";
   if(as_0 == "JPY")
      ls_16 = "jpy";
   if(as_0 == "NZD")
      ls_16 = "nzd";
   if(as_0 == "USD")
      ls_16 = "usd";


   if(ad_8 > 0.0)
      ObjectSet(ls_16 + "_1", OBJPROP_COLOR, Red);
   if(ad_8 > 2.0)
      ObjectSet(ls_16 + "_2", OBJPROP_COLOR, Red);
   if(ad_8 > 4.0)
      ObjectSet(ls_16 + "_3", OBJPROP_COLOR, Red);
   if(ad_8 > 6.0)
      ObjectSet(ls_16 + "_4", OBJPROP_COLOR, Red);
   if(ad_8 > 8.0)
      ObjectSet(ls_16 + "_5", OBJPROP_COLOR, Red);
   if(ad_8 > 10.0)
      ObjectSet(ls_16 + "_6", OBJPROP_COLOR, Red);
   if(ad_8 > 12.0)
      ObjectSet(ls_16 + "_7", OBJPROP_COLOR, Red);
   if(ad_8 > 14.0)
      ObjectSet(ls_16 + "_8", OBJPROP_COLOR, Red);
   if(ad_8 > 16.0)
      ObjectSet(ls_16 + "_9", OBJPROP_COLOR, Red);
   if(ad_8 > 18.0)
      ObjectSet(ls_16 + "_10", OBJPROP_COLOR, Red);
   if(ad_8 > 20.0)
      ObjectSet(ls_16 + "_11", OBJPROP_COLOR, Orange);
   if(ad_8 > 22.0)
      ObjectSet(ls_16 + "_12", OBJPROP_COLOR, Orange);
   if(ad_8 > 24.0)
      ObjectSet(ls_16 + "_13", OBJPROP_COLOR, Orange);
   if(ad_8 > 26.0)
      ObjectSet(ls_16 + "_14", OBJPROP_COLOR, Orange);
   if(ad_8 > 28.0)
      ObjectSet(ls_16 + "_15", OBJPROP_COLOR, Orange);
   if(ad_8 > 30.0)
      ObjectSet(ls_16 + "_16", OBJPROP_COLOR, Orange);
   if(ad_8 > 31.0)
      ObjectSet(ls_16 + "_17", OBJPROP_COLOR, Orange);
   if(ad_8 > 32.0)
      ObjectSet(ls_16 + "_18", OBJPROP_COLOR, Orange);
   if(ad_8 > 34.0)
      ObjectSet(ls_16 + "_19", OBJPROP_COLOR, Orange);
   if(ad_8 > 36.0)
      ObjectSet(ls_16 + "_20", OBJPROP_COLOR, Orange);
   if(ad_8 > 38.0)
      ObjectSet(ls_16 + "_21", OBJPROP_COLOR, Orange);
   if(ad_8 > 40.0)
      ObjectSet(ls_16 + "_22", OBJPROP_COLOR, Gold);
   if(ad_8 > 42.0)
      ObjectSet(ls_16 + "_23", OBJPROP_COLOR, Gold);
   if(ad_8 > 44.0)
      ObjectSet(ls_16 + "_24", OBJPROP_COLOR, Gold);
   if(ad_8 > 46.0)
      ObjectSet(ls_16 + "_25", OBJPROP_COLOR, Gold);
   if(ad_8 > 48.0)
      ObjectSet(ls_16 + "_26", OBJPROP_COLOR, Gold);
   if(ad_8 > 50.0)
      ObjectSet(ls_16 + "_27", OBJPROP_COLOR, Gold);
   if(ad_8 > 52.0)
      ObjectSet(ls_16 + "_28", OBJPROP_COLOR, Gold);
   if(ad_8 > 54.0)
      ObjectSet(ls_16 + "_29", OBJPROP_COLOR, Gold);
   if(ad_8 > 56.0)
      ObjectSet(ls_16 + "_30", OBJPROP_COLOR, Gold);
   if(ad_8 > 58.0)
      ObjectSet(ls_16 + "_31", OBJPROP_COLOR, Gold);
   if(ad_8 > 60.0)
      ObjectSet(ls_16 + "_32", OBJPROP_COLOR, YellowGreen);
   if(ad_8 > 62.0)
      ObjectSet(ls_16 + "_33", OBJPROP_COLOR, YellowGreen);
   if(ad_8 > 64.0)
      ObjectSet(ls_16 + "_34", OBJPROP_COLOR, YellowGreen);
   if(ad_8 > 66.0)
      ObjectSet(ls_16 + "_35", OBJPROP_COLOR, YellowGreen);
   if(ad_8 > 68.0)
      ObjectSet(ls_16 + "_36", OBJPROP_COLOR, YellowGreen);
   if(ad_8 > 70.0)
      ObjectSet(ls_16 + "_37", OBJPROP_COLOR, YellowGreen);
   if(ad_8 > 72.0)
      ObjectSet(ls_16 + "_38", OBJPROP_COLOR, YellowGreen);
   if(ad_8 > 74.0)
      ObjectSet(ls_16 + "_39", OBJPROP_COLOR, YellowGreen);
   if(ad_8 > 76.0)
      ObjectSet(ls_16 + "_40", OBJPROP_COLOR, YellowGreen);
   if(ad_8 > 78.0)
      ObjectSet(ls_16 + "_41", OBJPROP_COLOR, YellowGreen);
   if(ad_8 > 80.0)
      ObjectSet(ls_16 + "_42", OBJPROP_COLOR, Lime);
   if(ad_8 > 82.0)
      ObjectSet(ls_16 + "_43", OBJPROP_COLOR, Lime);
   if(ad_8 > 84.0)
      ObjectSet(ls_16 + "_44", OBJPROP_COLOR, Lime);
   if(ad_8 > 86.0)
      ObjectSet(ls_16 + "_45", OBJPROP_COLOR, Lime);
   if(ad_8 > 88.0)
      ObjectSet(ls_16 + "_46", OBJPROP_COLOR, Lime);
   if(ad_8 > 90.0)
      ObjectSet(ls_16 + "_47", OBJPROP_COLOR, Lime);
   if(ad_8 > 92.0)
      ObjectSet(ls_16 + "_48", OBJPROP_COLOR, Lime);
   if(ad_8 > 94.0)
      ObjectSet(ls_16 + "_49", OBJPROP_COLOR, Lime);
   if(ad_8 > 96.0)
      ObjectSet(ls_16 + "_50", OBJPROP_COLOR, Lime);
   if(ad_8 > 98.0)
      ObjectSet(ls_16 + "_51", OBJPROP_COLOR, Lime);
   if(ad_8 <= sell_level)
   {
      ObjectSet(ls_16 + "txt", OBJPROP_COLOR, Red);
      ObjectSetText(ls_16 + "p", DoubleToStr(ad_8, 0) + "%", 12, "Arial Narrow", Red);
      return;
   }
   if(ad_8 >= buy_level)
   {
      ObjectSet(ls_16 + "txt", OBJPROP_COLOR, Lime);
      ObjectSetText(ls_16 + "p", DoubleToStr(ad_8, 0) + "%", 12, "Arial Narrow", Lime);
      return;
   }
   ObjectSet(ls_16 + "txt", OBJPROP_COLOR, White);
   ObjectSetText(ls_16 + "p", DoubleToStr(ad_8, 0) + "%", 12, "Arial Narrow", White);
}
//+------------------------------------------------------------------+
