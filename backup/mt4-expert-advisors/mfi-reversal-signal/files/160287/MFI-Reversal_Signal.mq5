//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76251

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
#property indicator_plots 2

input int    ArrowCodeDn          =   233;
input int    ArrowCodeUp          =   234;
input int    LagBar               =     1;
input string NoteLagBar           = "0 = Signal on current ; 1 = Wait for close";

double ArrowsUp[];
double ArrowsDn[];
double trend[];
double body[];

int atr_handle;

int OnInit()
  {
   SetIndexBuffer(0, ArrowsUp);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, ArrowCodeDn);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, clrDeepSkyBlue);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 2);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   SetIndexBuffer(1, ArrowsDn);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_ARROW, ArrowCodeUp);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, clrRed);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   SetIndexBuffer(2, trend);
   SetIndexBuffer(3, body);

   atr_handle = iATR(_Symbol, _Period, 1);
   if(atr_handle == INVALID_HANDLE)
     {
      Print("Cannot create ATR handle");
      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
   IndicatorRelease(atr_handle);
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
   int start = 0;

   for(int pos = start; pos < rates_total; pos++)
     {
      body[pos] = MathAbs(open[pos] - close[pos]);

      if(pos < 3 || pos + 1 >= rates_total || pos + LagBar >= rates_total)
        {
         trend[pos] = 0.0;
         ArrowsUp[pos] = EMPTY_VALUE;
         ArrowsDn[pos] = EMPTY_VALUE;
         continue;
        }

      double atr[1];
      if(CopyBuffer(atr_handle, 0, pos, 1, atr) != 1)
        {
         trend[pos] = 0.0;
         continue;
        }
      double gap = 3.0 * atr[0] / 4.0;

      double body0 = body[pos];
      double body1 = body[pos - 1];
      double body2 = body[pos - 2];
      double body3 = body[pos - 3];

      long vol = tick_volume[pos + LagBar];

      trend[pos] = 0.0;
      if((high[pos - 1] < low[pos + 1]) && (body0 > body1) && (body0 > body2) && (body0 > body3) && (vol > 1))
        {
         trend[pos] = 1.0;
        }
      if((low[pos - 1] > high[pos + 1]) && (body0 > body1) && (body0 > body2) && (body0 > body3) && (vol > 1))
        {
         trend[pos] = -1.0;
        }

      ArrowsUp[pos] = EMPTY_VALUE;
      ArrowsDn[pos] = EMPTY_VALUE;
      if(trend[pos] != trend[pos - 1])
        {
         if(trend[pos] == 1.0)
            ArrowsUp[pos] = low[pos] - gap;
         else if(trend[pos] == -1.0)
            ArrowsDn[pos] = high[pos] + gap;
        }
     }

   return(rates_total);
  }
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76251

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
