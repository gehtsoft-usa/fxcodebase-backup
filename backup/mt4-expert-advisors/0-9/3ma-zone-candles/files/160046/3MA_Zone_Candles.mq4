//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76190

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1  clrRed
#property indicator_color2  clrOrange
#property indicator_color3  clrBlue
#property indicator_color4  clrGreen
#property indicator_width1  1

// Input parameters
extern int      Period1 = 10;           // MA1 period
extern string   Method1 = "SMA";        // MA1 method: SMA, EMA, LWMA
extern int      Period2 = 20;           // MA2 period
extern string   Method2 = "SMA";        // MA2 method: SMA, EMA, LWMA
extern int      Period3 = 30;           // MA3 period
extern string   Method3 = "SMA";        // MA3 method: SMA, EMA, LWMA
extern color    Color1 = clrRed;        // Below all MAs
extern color    Color2 = clrOrange;     // Between MA1 & MA2
extern color    Color3 = clrBlue;       // Between MA2 & MA3
extern color    Color4 = clrGreen;      // Above all MAs
extern double   CandleWidth = 5;        // Candle body width

// Buffers
double ColorBuffer[];
double ma1[];
double ma2[];
double ma3[];

int GetMaMode(string method) {
   if(method=="SMA") return MODE_SMA;
   if(method=="EMA") return MODE_EMA;
   if(method=="LWMA") return MODE_LWMA;
   return MODE_SMA;
}

int init() {
   SetIndexBuffer(0, ColorBuffer);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexLabel(0, "CandleColor");
   IndicatorShortName("3 MA Zone Candles");
   return(0);
}

int deinit() {
   for(int i=ObjectsTotal()-1; i>=0; i--) {
      string name = ObjectName(i);
      if(StringFind(name, "3MAZoneBody_") == 0) ObjectDelete(name);
      if(StringFind(name, "3MAZoneWickUp_") == 0) ObjectDelete(name);
      if(StringFind(name, "3MAZoneWickDown_") == 0) ObjectDelete(name);
   }
   return(0);
}

int start() {
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars - 1;
   if(limit < 0) limit = 0;

   int mode1 = GetMaMode(Method1);
   int mode2 = GetMaMode(Method2);
   int mode3 = GetMaMode(Method3);

   if(ArraySize(ma1) != Bars) ArrayResize(ma1, Bars);
   if(ArraySize(ma2) != Bars) ArrayResize(ma2, Bars);
   if(ArraySize(ma3) != Bars) ArrayResize(ma3, Bars);

   ArraySetAsSeries(ma1, true);
   ArraySetAsSeries(ma2, true);
   ArraySetAsSeries(ma3, true);
   ArraySetAsSeries(ColorBuffer, true);

   for(int i=limit; i>=0; i--) {
      ma1[i] = iMA(NULL, 0, Period1, 0, mode1, PRICE_CLOSE, i);
      ma2[i] = iMA(NULL, 0, Period2, 0, mode2, PRICE_CLOSE, i);
      ma3[i] = iMA(NULL, 0, Period3, 0, mode3, PRICE_CLOSE, i);
   }

   for(int j=limit; j>=0; j--) {
      double closePrice = Close[j];
      double a0 = ma1[j], a1 = ma2[j], a2 = ma3[j];
      double tmp;
      // Sort ascending
      if(a0 > a1) { tmp = a0; a0 = a1; a1 = tmp; }
      if(a1 > a2) { tmp = a1; a1 = a2; a2 = tmp; }
      if(a0 > a1) { tmp = a0; a0 = a1; a1 = tmp; }
      int clrIdx;
      if(closePrice < a0) clrIdx = 0;
      else if(closePrice < a1) clrIdx = 1;
      else if(closePrice < a2) clrIdx = 2;
      else clrIdx = 3;
      color candleColor;
      if(clrIdx == 0) candleColor = Color1;
      else if(clrIdx == 1) candleColor = Color2;
      else if(clrIdx == 2) candleColor = Color3;
      else candleColor = Color4;
      ColorBuffer[j] = candleColor;
      // Calculate positions
      datetime time_open = Time[j];
      datetime time_close = (j == 0) ? time_open + PeriodSeconds(_Period) : Time[j-1];
      int bar_width_sec = (int)(time_close - time_open);
      datetime mid_time = time_open + bar_width_sec / 2;
      int half_width_sec = (int)(bar_width_sec * CandleWidth / 2);
      datetime left = mid_time - half_width_sec;
      datetime right = mid_time + half_width_sec;
      double body_top = MathMax(Open[j], Close[j]);
      double body_bottom = MathMin(Open[j], Close[j]);

      DrawCandle(Time[j], body_top, body_bottom, High[j], Low[j], mid_time, CandleWidth, candleColor);
   }
   return(0);
}

void DrawCandle(datetime open_time, double body_top, double body_bottom, double high, double low, datetime mid_time, double candleWidth, color candleColor)
{
   string uid = IntegerToString(open_time);
   // Draw candle body
   string body_name = "3MAZoneBody_" + uid;
   ObjectDelete(body_name); // Delete old object if exists
   ObjectCreate(body_name, OBJ_TREND, 0, mid_time, body_bottom, mid_time, body_top);
   ObjectSet(body_name, OBJPROP_COLOR, candleColor);
   ObjectSet(body_name, OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet(body_name, OBJPROP_RAY, false);
   ObjectSet(body_name, OBJPROP_BACK, false);
   ObjectSet(body_name, OBJPROP_WIDTH, candleWidth);
   // Draw upper wick
   if(high > body_top) {
      string wick_up_name = "3MAZoneWickUp_" + uid;
      ObjectDelete(wick_up_name);
      ObjectCreate(wick_up_name, OBJ_TREND, 0, mid_time, body_top, mid_time, high);
      ObjectSet(wick_up_name, OBJPROP_COLOR, candleColor);
      ObjectSet(wick_up_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(wick_up_name, OBJPROP_RAY, false);
      ObjectSet(wick_up_name, OBJPROP_BACK, false);
      ObjectSet(wick_up_name, OBJPROP_WIDTH, 1);
   }
   // Draw lower wick
   if(low < body_bottom) {
      string wick_down_name = "3MAZoneWickDown_" + uid;
      ObjectDelete(wick_down_name);
      ObjectCreate(wick_down_name, OBJ_TREND, 0, mid_time, body_bottom, mid_time, low);
      ObjectSet(wick_down_name, OBJPROP_COLOR, candleColor);
      ObjectSet(wick_down_name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSet(wick_down_name, OBJPROP_RAY, false);
      ObjectSet(wick_down_name, OBJPROP_BACK, false);
      ObjectSet(wick_down_name, OBJPROP_WIDTH, 1);
   }
}
 
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76190

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+