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

// Input
extern int    Frame    = 2;      // Number of fractals
extern bool   Forward  = true;   // Extend Lines Forward
extern bool   Backward = true;   // Extend Lines Backward
extern color  UP       = Lime;   // Up fractal color
extern color  DOWN     = Red;    // Down fractal color
extern int    Size     = 10;     // Font size for fractal markers
extern int    width    = 1;      // Line width for trend lines
extern int    style    = STYLE_SOLID; // Line style for trend lines
input int MaxBars = 500; // Maximum historical bars to process

double top[], bottom[], shift_top[], shift_bottom[];

int first;

int init()
  {
   SetIndexBuffer(0, top);
   SetIndexBuffer(1, bottom);
   SetIndexBuffer(2, shift_top);
   SetIndexBuffer(3, shift_bottom);

   IndicatorShortName("Every Fractal trend lines ("+Frame+")");

   first = Frame * 2 + 1;

   ObjectsDeleteAll(0, "Fractal_");

   return(0);
  }
  
int deinit()
  {
   ObjectsDeleteAll(0, "Fractal_");
   return(0);
  }

int start()
  {
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars;
   if(Bars < first) return(0);
   
   int start_index = MathMin(Bars - Frame - 1, MaxBars - 1);
   for(int p = start_index; p >= Frame; p--)
     {
      top[p] = 0;
      bottom[p] = 0;
      
      // Detect bullish fractal pattern
      bool isTop = true;
      for(int i=1; i<=Frame; i++)
        if(High[p] < High[p+i] || High[p] < High[p-i]) isTop = false;
      if(isTop)
        {
         top[p] = 1;
         CreateTextObject("Fractal_Up_"+p, Time[p], High[p], "\108", UP, Size, 0);
        }

      // Detect bearish fractal pattern
      bool isBottom = true;
      for(int i=1; i<=Frame; i++)
        if(Low[p] > Low[p+i] || Low[p] > Low[p-i]) isBottom = false;
      if(isBottom)
        {
         bottom[p] = 1;
         CreateTextObject("Fractal_Dn_"+p, Time[p], Low[p], "\108", DOWN, Size, 0);
        }

      // Connect latest two bullish fractals
      if(top[p]==1)
        {
         int prev = -1;
         for(int j=p+1; j<Bars; j++)
           if(top[j]==1) { prev=j; break; }
         if(prev>=0)
         {
          CreateTrendLine("Fractal_TopLine_"+p, Time[prev], High[prev], Time[p], High[p], UP, width, style, Backward, Forward);
         }
        }

      // Connect latest two bearish fractals
      if(bottom[p]==1)
        {
         int prev = -1;
         for(int j=p+1; j<Bars; j++)
           if(bottom[j]==1) { prev=j; break; }
         if(prev>=0)
         {
          CreateTrendLine("Fractal_BottomLine_"+p, Time[prev], Low[prev], Time[p], Low[p], DOWN, width, style, Backward, Forward);
         }
        }
     }
   return(0);
  }

void CreateTextObject(string name,
   datetime t, double price, string text, color clr, int size, int anchor)
  {
   if(ObjectFind(name)<0)
     {
      ObjectCreate(name, OBJ_TEXT, 0, t, price);
      ObjectSetText(name, text, size, "Wingdings", clr);
      ObjectSet(name, OBJPROP_CORNER, 0);
     }
  }
  
void CreateTrendLine(string base_name, datetime t1, double p1, datetime t2, double p2,
                     color clr, int w, int sty, bool backward, bool forward)
  {
   // Remove existing objects (forward, backward, segment)
   if(ObjectFind(base_name+"_fwd")>=0) ObjectDelete(base_name+"_fwd");
   if(ObjectFind(base_name+"_bwd")>=0) ObjectDelete(base_name+"_bwd");
   if(ObjectFind(base_name)>=0)        ObjectDelete(base_name);

   // Forward ray (extends to the right)
   if(forward)
     {
      ObjectCreate(base_name+"_fwd", OBJ_TREND, 0, t1, p1, t2, p2);
      ObjectSet(base_name+"_fwd", OBJPROP_COLOR, clr);
      ObjectSet(base_name+"_fwd", OBJPROP_STYLE, sty);
      ObjectSet(base_name+"_fwd", OBJPROP_WIDTH, w);
      ObjectSet(base_name+"_fwd", OBJPROP_RAY, true);
     }

   // Backward ray (extends to the left)
   if(backward)
     {
      ObjectCreate(base_name+"_bwd", OBJ_TREND, 0, t2, p2, t1, p1);
      ObjectSet(base_name+"_bwd", OBJPROP_COLOR, clr);
      ObjectSet(base_name+"_bwd", OBJPROP_STYLE, sty);
      ObjectSet(base_name+"_bwd", OBJPROP_WIDTH, w);
      ObjectSet(base_name+"_bwd", OBJPROP_RAY, true);
     }

   // If neither forward nor backward is requested, draw a simple segment connecting the two points
   if(!forward && !backward)
     {
      ObjectCreate(base_name, OBJ_TREND, 0, t1, p1, t2, p2);
      ObjectSet(base_name, OBJPROP_COLOR, clr);
      ObjectSet(base_name, OBJPROP_STYLE, sty);
      ObjectSet(base_name, OBJPROP_WIDTH, w);
      ObjectSet(base_name, OBJPROP_RAY, false);
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