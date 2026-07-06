// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73608

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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




#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Black
#property indicator_color2 Blue
#property indicator_color3 Red

extern int period = 27;
extern int offset = 0;
extern bool EnableAlerts = True;
extern bool EnableArrows = True;
extern color ArrowUP = Blue;
extern color ArrowDOWN = Magenta;

double g_ibuf_80[];
double g_ibuf_84[];
double g_ibuf_88[];
string gs_92 = "";
string gs_xb4_ind_100 = "XB4 ind";
int prevbar;

int init() {
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   IndicatorDigits(Digits + 1);
   SetIndexBuffer(0, g_ibuf_80);
   SetIndexBuffer(1, g_ibuf_84);
   SetIndexBuffer(2, g_ibuf_88);
   IndicatorShortName(gs_xb4_ind_100);
   SetIndexLabel(1, NULL);
   SetIndexLabel(2, NULL);
   prevbar = Bars;
   return (0);
}

int start() {
   
   double ld_0;
   double ld_8;
   double ld_16;
   int li_24 = IndicatorCounted();
   double ld_28 = 0;
   double ld_36 = 0;
   double ld_60 = 0;
   double l_low_76 = 0;
   double l_high_84 = 0;
   creataalltext();
   int li_92 = 16777215;
   if (li_24 > 0) li_24--;
   int li_96 = Bars - li_24;

   for (int li_100 = offset; li_100 < li_96; li_100++) { //First bar 0(+offset) to Last bar
      l_high_84 = High[iHighest(NULL, 0, MODE_HIGH, period, li_100)];
      l_low_76 = Low[iLowest(NULL, 0, MODE_LOW, period, li_100)];
      ld_16 = (High[li_100] + Low[li_100]) / 2.0;
      ld_28 = 0.66 * ((ld_16 - l_low_76) / (l_high_84 - l_low_76) - 0.5) + 0.67 * ld_36;
      ld_28 = MathMin(MathMax(ld_28, -0.999), 0.999);
      g_ibuf_80[li_100] = MathLog((ld_28 + 1.0) / (1 - ld_28)) / 2.0 + ld_60 / 2.0;
      ld_36 = ld_28;
      ld_60 = g_ibuf_80[li_100];
   }
   bool li_104 = TRUE;
   for (li_100 = li_96 - (2 + offset); li_100 >= 0; li_100--) { //Last bar-2(+offset) to First bar
      ld_8 = g_ibuf_80[li_100];
      ld_0 = g_ibuf_80[li_100 + 1];
      if ((ld_8 < 0.0 && ld_0 > 0.0) || ld_8 < 0.0) li_104 = FALSE;
      if ((ld_8 > 0.0 && ld_0 < 0.0) || ld_8 > 0.0) li_104 = TRUE;
      if (!li_104) {
         g_ibuf_88[li_100] = ld_8;
         g_ibuf_84[li_100] = 0.0;
         gs_92 = "SHORT";
         li_92 = 65535;
      } else {
         g_ibuf_84[li_100] = ld_8;
         g_ibuf_88[li_100] = 0.0;
         gs_92 = "LONG";
         li_92 = 65280;
      }
   }

   bool Newbar = False;
   if (prevbar != Bars) Newbar = True; prevbar = Bars;  

   if (Newbar)
   {
      if (g_ibuf_80[3] < 0.0 && g_ibuf_80[1] > 0.0)
      {
         if (EnableAlerts) Alert(Symbol() + " xb4d BUY");
         if (EnableArrows)
         {
            ObjectCreate("xb4d_Buy_" + Time[0], OBJ_ARROW, 0, TimeCurrent(), Bid);
            ObjectSet("xb4d_Buy_" + Time[0], OBJPROP_ARROWCODE, 228);
            ObjectSet("xb4d_Buy_" + Time[0], OBJPROP_COLOR, ArrowUP);
         }
      }
      if (g_ibuf_80[3] > 0.0 && g_ibuf_80[1] < 0.0)
      {
         if (EnableAlerts) Alert(Symbol() + " xb4d SELL");
         if (EnableArrows)
         {
            ObjectCreate("xb4d_Sell_" + Time[0], OBJ_ARROW, 0, TimeCurrent(), Bid);
            ObjectSet("xb4d_Sell_" + Time[0], OBJPROP_ARROWCODE, 230);
            ObjectSet("xb4d_Sell_" + Time[0], OBJPROP_COLOR, ArrowDOWN);
         }      
      }
   }
 
   
   settext("xboxforex_ind", gs_92, 12, li_92, 10, 15);
   return (0);
}

void creataalltext() {
   createtext("xboxforex_ind");
   settext("xboxforex_ind", "", 12, White, 10, 15);
}

void createtext(string a_name_0) {
   ObjectCreate(a_name_0, OBJ_LABEL, WindowFind(gs_xb4_ind_100), 0, 0);
}

void settext(string a_name_0, string a_text_8, int a_fontsize_16, color a_color_20, int a_x_24, int a_y_28) {
   ObjectSet(a_name_0, OBJPROP_XDISTANCE, a_x_24);
   ObjectSet(a_name_0, OBJPROP_YDISTANCE, a_y_28);
   ObjectSetText(a_name_0, a_text_8, a_fontsize_16, "Arial", a_color_20);
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