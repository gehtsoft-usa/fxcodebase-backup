//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76192

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

#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 1
#property indicator_label1  "Fractal Trend Lines"
#property indicator_type1   DRAW_NONE
#property indicator_color1  clrNONE
#property indicator_width1  1

// Input
input int Frame = 2; // Number of fractals
input bool Forward = true; // Extend Lines Forward
input bool Backward = true; // Extend Lines Backward
input color UP = clrLime; // Up fractal color
input color DOWN = clrRed; // Down fractal color
input int Size = 10; // Font size for fractal markers
input int width = 1; // Line width for trend lines
input ENUM_LINE_STYLE style = STYLE_SOLID; // Line style for trend lines
input int MaxBars = 500; // Maximum historical bars to process

double top[], bottom[], shift_top[], shift_bottom[];

int first;

int OnInit()
  {
   SetIndexBuffer(0, top, INDICATOR_DATA);
   SetIndexBuffer(1, bottom, INDICATOR_DATA);
   SetIndexBuffer(2, shift_top, INDICATOR_DATA);
   SetIndexBuffer(3, shift_bottom, INDICATOR_DATA);

   IndicatorSetString(INDICATOR_SHORTNAME, StringFormat("Every Fractal trend lines (%d)", Frame));

   first = Frame * 2 + 1;

   ObjectsDeleteAll(0, "Fractal_*");

   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, "Fractal_*");
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
   if(rates_total < first) return(0);
   
   int start_index = MathMax(Frame, rates_total - MaxBars);
   int limit = rates_total - prev_calculated;
   if(prev_calculated == 0) limit = rates_total - first;

   for(int p = start_index; p < rates_total - Frame; p++)
     {
      top[p]=0;
      bottom[p]=0;

      // Detect bullish fractal pattern
      bool isTop=true;
      for(int i=1;i<=Frame;i++)
        {
         if(high[p] < high[p+i] || high[p] < high[p-i]){ isTop=false; break; }
        }
      if(isTop)
        {
         top[p]=1;
         CreateTextObject(StringFormat("Fractal_Up_%d", p), time[p], high[p], "\108", UP, Size, ANCHOR_CENTER);
        }

      // Detect bearish fractal pattern
      bool isBottom=true;
      for(int i=1;i<=Frame;i++)
        {
         if(low[p] > low[p+i] || low[p] > low[p-i]){ isBottom=false; break; }
        }
      if(isBottom)
        {
         bottom[p]=1;
         CreateTextObject(StringFormat("Fractal_Dn_%d", p), time[p], low[p], "\108", DOWN, Size, ANCHOR_CENTER);
        }

      // Connect bullish fractals with trend lines
      if(top[p]==1)
        {
         int prev=-1;
         for(int j=p-1;j>=0;j--)
           {
            if(top[j]==1){ prev=j; break; }
           }
         if(prev>=0)
           {
            CreateTrendLine(StringFormat("Fractal_TopLine_%d",p),time[prev],high[prev],time[p],high[p],UP,width,style,Backward,Forward);
           }
        }
        
      // Connect bearish fractals with trend lines
      if(bottom[p]==1)
        {
         int prev=-1;
         for(int j=p-1;j>=0;j--)
           {
            if(bottom[j]==1){ prev=j; break; }
           }
         if(prev>=0)
           {
            CreateTrendLine(StringFormat("Fractal_BottomLine_%d",p),time[prev],low[prev],time[p],low[p],DOWN,width,style,Backward,Forward);
           }
        }
     }

   return(rates_total);
  }

void CreateTextObject(string name, datetime time, double price, string text, color clr, int size, int anchor)
  {
   if(ObjectFind(0, name) < 0)
     {
      ObjectCreate(0, name, OBJ_TEXT, 0, time, price);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      ObjectSetString(0, name, OBJPROP_FONT, "Wingdings");
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
     }
  }

void CreateTrendLine(string base_name,
                     datetime time1, double price1,
                     datetime time2, double price2,
                     color clr, int w, ENUM_LINE_STYLE sty,
                     bool backward, bool forward)
  {
   string name_fwd = base_name + "_fwd";
   string name_bwd = base_name + "_bwd";

   // Delete previous objects if they exist
   if(ObjectFind(0, name_fwd) >= 0) ObjectDelete(0, name_fwd);
   if(ObjectFind(0, name_bwd) >= 0) ObjectDelete(0, name_bwd);
   if(ObjectFind(0, base_name) >= 0) ObjectDelete(0, base_name);

   // Forward ray (extends to the right)
   if(forward)
     {
      if(ObjectCreate(0, name_fwd, OBJ_TREND, 0, time1, price1, time2, price2))
        {
         ObjectSetInteger(0, name_fwd, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, name_fwd, OBJPROP_STYLE, sty);
         ObjectSetInteger(0, name_fwd, OBJPROP_WIDTH, w);
         ObjectSetInteger(0, name_fwd, OBJPROP_RAY_RIGHT, true);
         ObjectSetInteger(0, name_fwd, OBJPROP_BACK, false);
        }
     }

   // Backward ray (extends to the left)
   if(backward)
     {
      if(ObjectCreate(0, name_bwd, OBJ_TREND, 0, time2, price2, time1, price1))
        {
         ObjectSetInteger(0, name_bwd, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, name_bwd, OBJPROP_STYLE, sty);
         ObjectSetInteger(0, name_bwd, OBJPROP_WIDTH, w);
         ObjectSetInteger(0, name_bwd, OBJPROP_RAY_RIGHT, true);
         ObjectSetInteger(0, name_bwd, OBJPROP_BACK, false);
        }
     }

   // If neither forward nor backward is requested, draw a simple segment connecting the two points
   if(!forward && !backward)
     {
      if(ObjectCreate(0, base_name, OBJ_TREND, 0, time1, price1, time2, price2))
        {
         ObjectSetInteger(0, base_name, OBJPROP_COLOR, clr);
         ObjectSetInteger(0, base_name, OBJPROP_STYLE, sty);
         ObjectSetInteger(0, base_name, OBJPROP_WIDTH, w);
         ObjectSetInteger(0, base_name, OBJPROP_RAY_LEFT, false);
         ObjectSetInteger(0, base_name, OBJPROP_RAY_RIGHT, false);
         ObjectSetInteger(0, base_name, OBJPROP_BACK, false);
        }
     }
  }
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76192

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