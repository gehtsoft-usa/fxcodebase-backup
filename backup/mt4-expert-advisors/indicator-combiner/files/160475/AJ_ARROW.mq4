// Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76295
//
// Copyright © 2025, Gehtsoft USA LLC
// Website: http://fxcodebase.com
// PayPal: https://goo.gl/9Rj74e
//
// Developed by: Mario Jemic
// Email: mario.jemic@gmail.com
// Website: https://mario-jemic.com
// Patreon: http://tiny.cc/1ybwxz
// Buy Me a Coffee: http://tiny.cc/bj7vxz
//
// Crypto Donations
// BTC  : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
// SOL  : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
// ETH / BNB / USDT / XRP (ERC20 & BEP20) : 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
//

#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 White
#property indicator_color2 White

extern int SignalGap = 10;
extern bool EnableSoundAlert = TRUE;
int Gi_84 = 24;
double G_ibuf_88[];
double G_ibuf_92[];
int G_bars_96;
int G_count_100;
bool Gi_104;
bool Gi_108 = FALSE;
bool Gi_112 = FALSE;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   SetIndexStyle(0, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexStyle(1, DRAW_ARROW, STYLE_SOLID, 1);
   SetIndexArrow(1, 233);
   SetIndexArrow(0, 234);
   SetIndexBuffer(0, G_ibuf_88);
   SetIndexBuffer(1, G_ibuf_92);
   G_bars_96 = Bars;
   G_count_100 = 0;
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
void deinit() {
   Comment("");
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   string Ls_unused_0;
   int highest_8;
   int lowest_12;
   int Li_16 = IndicatorCounted();
   if (Li_16 < 0) return (-1);
   if (Li_16 > 0) Li_16--;
   int Li_20 = Bars - 1;
   if (Li_16 >= 1) Li_20 = Bars - Li_16 - 1;
   if (Li_20 < 0) Li_20 = 0;
   for (int Li_24 = Li_20; Li_24 >= 0; Li_24--) {
      highest_8 = iHighest(NULL, 0, MODE_HIGH, Gi_84, Li_24 - Gi_84 / 2);
      lowest_12 = iLowest(NULL, 0, MODE_LOW, Gi_84, Li_24 - Gi_84 / 2);
      if (Li_24 == highest_8 && Gi_108 == FALSE) {
         G_ibuf_88[Li_24] = High[highest_8] + SignalGap * Point;
         Gi_108 = TRUE;
         Gi_112 = FALSE;
      }
      if (Li_24 == lowest_12 && Gi_112 == FALSE) {
         G_ibuf_92[Li_24] = Low[lowest_12] - SignalGap * Point;
         Gi_112 = TRUE;
         Gi_108 = FALSE;
      }
   }
   Gi_104 = f0_1();
   if (Gi_104) G_count_100 = 0;
   if (G_count_100 == 0) {
      if (EnableSoundAlert) {
         if (G_ibuf_88[0] != EMPTY_VALUE && G_ibuf_88[0] > 0.0) {
            Alert(TimeToStr(Time[0], TIME_DATE|TIME_MINUTES) + " Alert Down " + Symbol() + " " + f0_0(Period()));
            G_count_100++;
         }
      }
      if (G_ibuf_92[0] != EMPTY_VALUE && G_ibuf_92[0] > 0.0) {
         Alert(TimeToStr(Time[0], TIME_DATE|TIME_MINUTES) + " Alert Up " + Symbol() + " " + f0_0(Period()));
         G_count_100++;
      }
   }
   return (0);
}

// 9B1AEE847CFB597942D106A4135D4FE6
int f0_1() {
   bool Li_ret_0 = FALSE;
   if (G_bars_96 != Bars) {
      Li_ret_0 = TRUE;
      G_bars_96 = Bars;
   }
   return (Li_ret_0);
}

// 945D754CB0DC06D04243FCBA25FC0802
string f0_0(int Ai_0) {
   if (Ai_0 >= 1) return ("M1");
   if (Ai_0 >= 5) return ("M5");
   if (Ai_0 >= 15) return ("M15");
   if (Ai_0 >= 30) return ("M30");
   if (Ai_0 >= 60) return ("H1");
   if (Ai_0 >= 240) return ("H4");
   if (Ai_0 >= 1440) return ("D1");
   if (Ai_0 >= 10080) return ("W1");
   if (Ai_0 >= 43200) return ("MN1");
   return ("");
}
// Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=76295
//
// Copyright © 2025, Gehtsoft USA LLC
// Website: http://fxcodebase.com
// PayPal: https://goo.gl/9Rj74e
//
// Developed by: Mario Jemic
// Email: mario.jemic@gmail.com
// Website: https://mario-jemic.com
// Patreon: http://tiny.cc/1ybwxz
// Buy Me a Coffee: http://tiny.cc/bj7vxz
//
// Crypto Donations
// BTC  : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
// SOL  : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
// ETH / BNB / USDT / XRP (ERC20 & BEP20) : 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7