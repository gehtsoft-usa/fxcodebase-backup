//Available @ http://fxcodebase.com

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
 


#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 CLR_NONE
#property indicator_color3 Red
#property indicator_color4 Blue
#property indicator_color5 Blue
#property indicator_color6 Red
#define SIGNAL_BAR 1
extern bool UseSound=true;
extern string SoundFile="Alert.wav";
extern bool SendMailPossible = false;
bool SoundBuy  = True;
bool SoundSell = True;
int gi_76 = 3;
int gi_80 = 8;
int gi_84 = 0;
int gi_88 = 2;
double gd_92;
double gd_100;
double gd_108;
double gd_116 = 0.0;
double gd_124;
double gd_132 = 0.0;
double gd_140;
double gd_148;
int gi_156 = 0;
double gd_unused_160 = 0.0;
int gi_unused_168 = 0;
double g_ibuf_172[];
double g_ibuf_176[];
double g_ibuf_180[];
double g_ibuf_184[];
double g_ibuf_188[];
double g_ibuf_192[];
double g_ibuf_196[];
double g_ibuf_200[];

int init() {
   IndicatorBuffers(8);
   SetIndexBuffer(6, g_ibuf_180);
   SetIndexBuffer(7, g_ibuf_184);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
   SetIndexStyle(0, DRAW_NONE, STYLE_SOLID, 2);
   SetIndexBuffer(0, g_ibuf_172);
   SetIndexStyle(1, DRAW_NONE, STYLE_SOLID, 2);
   SetIndexBuffer(1, g_ibuf_176);
   SetIndexDrawBegin(0, gi_80 + 1);
   SetIndexDrawBegin(1, gi_80 + 1);
   SetIndexDrawBegin(2, gi_80 + 1);
   SetIndexDrawBegin(3, gi_80 + 1);
   SetIndexDrawBegin(4, gi_80 + 1);
   SetIndexDrawBegin(5, gi_80 + 1);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 1);
   SetIndexBuffer(2, g_ibuf_188);
   SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID, 1);
   SetIndexBuffer(3, g_ibuf_192);
   SetIndexStyle(4, DRAW_ARROW, STYLE_DASH, 1);
   SetIndexArrow(4, 233);
   SetIndexBuffer(4, g_ibuf_196);
   SetIndexStyle(5, DRAW_ARROW, STYLE_DASH, 1);
   SetIndexArrow(5, 234);
   SetIndexBuffer(5, g_ibuf_200);
   IndicatorShortName("I2G Entry Signal");
   SetIndexLabel(0, "I2GLine1");
   SetIndexLabel(1, "I2GLine2");
   SetIndexLabel(2, "I2GBar1");
   SetIndexLabel(3, "I2GBar2");
   SetIndexLabel(4, "I2GSig1");
   SetIndexLabel(5, "I2GSig2");
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   int li_0;
   int li_unused_4 = MarketInfo(Symbol(), MODE_DIGITS);
   if (Bars <= gi_80) return (0);
   int l_ind_counted_8 = IndicatorCounted();
   if (l_ind_counted_8 == 0) li_0 = Bars - 1;
   if (l_ind_counted_8 > 0) li_0 = Bars - l_ind_counted_8 - 1;
   for (int li_12 = li_0; li_12 >= 0; li_12--) {
      gd_92 = High[iHighest(NULL, 0, MODE_HIGH, gi_76, li_12)] + gi_84 * Point;
      gd_100 = Low[iLowest(NULL, 0, MODE_LOW, gi_76, li_12)] - gi_84 * Point;
      gd_108 = High[iHighest(NULL, 0, MODE_HIGH, gi_80, li_12)] + gi_88 * Point;
      gd_116 = Low[iLowest(NULL, 0, MODE_LOW, gi_80, li_12)] - gi_88 * Point;
      if (Close[li_12] > g_ibuf_172[li_12 + 1]) gd_124 = gd_100;
      else gd_124 = gd_92;
      if (Close[li_12] > g_ibuf_176[li_12 + 1]) gd_132 = gd_116;
      else gd_132 = gd_108;
      g_ibuf_172[li_12] = gd_124;
      g_ibuf_176[li_12] = gd_132;
      gd_140 = 0.0;
      gd_148 = 0.0;
      if (Close[li_12] < gd_124 && Close[li_12] < gd_132) {
         gd_140 = High[li_12];
         gd_148 = Low[li_12];
      }
      if (Close[li_12] > gd_124 && Close[li_12] > gd_132) {
         gd_140 = Low[li_12];
         gd_148 = High[li_12];
      }
      g_ibuf_188[li_12] = gd_140;
      g_ibuf_192[li_12] = gd_148;
      if (Close[li_12] > gd_132 && Close[li_12] > gd_124 && gi_156 != 1) {
         g_ibuf_196[li_12] = gd_132;
         g_ibuf_200[li_12] = EMPTY_VALUE;
         gi_156 = 1;
      }
      if (Close[li_12] < gd_132 && Close[li_12] < gd_124 && gi_156 != 2) {
         g_ibuf_200[li_12] = gd_132;
         g_ibuf_196[li_12] = EMPTY_VALUE;
         gi_156 = 2;
      }
   }
   //+------------------------------------------------------------------+     
      if (g_ibuf_196[SIGNAL_BAR] != EMPTY_VALUE && g_ibuf_196[SIGNAL_BAR] != 0 && SoundBuy)
         {
         SoundBuy = False;
            if (UseSound) PlaySound (SoundFile);
               Alert("indicators_I2G (", Symbol(), ", ", Period(), ")  -  BUY!!!");
               if (SendMailPossible) SendMail(Symbol()+ " M"+ Period()+ " indicators_I2G  -  BUY!", ""); 
         } 
      if (!SoundBuy && (g_ibuf_196[SIGNAL_BAR] == EMPTY_VALUE || g_ibuf_196[SIGNAL_BAR] == 0)) SoundBuy = True;  
            
  
      if (g_ibuf_200[SIGNAL_BAR] != EMPTY_VALUE && g_ibuf_200[SIGNAL_BAR] != 0 && SoundSell)
         {
         SoundSell = False;
            if (UseSound) PlaySound (SoundFile);
             Alert("indicators_I2G (", Symbol(), ", ", Period(), ")  -  SELL!!!"); 
             if (SendMailPossible) SendMail(Symbol()+ " M"+ Period()+ " indicators_I2G  -  SELL!!!", "");
         } 
      if (!SoundSell && (g_ibuf_200[SIGNAL_BAR] == EMPTY_VALUE || g_ibuf_200[SIGNAL_BAR] == 0)) SoundSell = True;            
                            
//+------------------------------------------------------------------+
   return (0);
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