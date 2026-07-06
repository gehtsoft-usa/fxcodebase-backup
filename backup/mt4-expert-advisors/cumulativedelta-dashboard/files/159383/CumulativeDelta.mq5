// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&p=157297#p157297


// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 17
#property indicator_plots 13

input bool showCumulative = true;
input color dnColor = clrCrimson;
input color upColor = clrGreen;
input bool showCorr = false;
input int corrPeriod = 20;

double closed[], opened[], highed[], lowed[];

static double Up_Body_Green[];
static double Dn_Body_Red[];
static double EqBodyBuffer[];
static double Bg_Body_Black[];
static double Up_Wick_Green[];
static double Dn_Wick_Red[];
static double EqShadowBuffer[];
static double Bg_Wick_Black[];
static double Dn_Body_Green[];
static double Up_Body_Red[];
static double Dn_Wick_Green[];
static double Up_Wick_Red[];
static double correlation[];

double Curr_Bid;
double Prev_Bid;
double Curr_Ask;
double Prev_Ask;
long Curr_Vol;
long Prev_Vol;
datetime timestamp;
int handle = 0;
bool firstTick = true;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit(void)
  {
// 0
   SetIndexBuffer(0, Up_Body_Green, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, upColor);
// 1
   SetIndexBuffer(1, Dn_Body_Red, INDICATOR_DATA);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, dnColor);
// 2
   SetIndexBuffer(2, EqBodyBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(2, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, White);
// 3
   SetIndexBuffer(3, Bg_Body_Black, INDICATOR_DATA);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(3, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, 0);
// 4
   SetIndexBuffer(4, Up_Wick_Green, INDICATOR_DATA);
   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(4, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(4, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, upColor);
// 5
   SetIndexBuffer(5, Dn_Wick_Red, INDICATOR_DATA);
   PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(5, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(5, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, dnColor);
// 6
   SetIndexBuffer(6, EqShadowBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(6, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(6, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(6, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(6, PLOT_LINE_COLOR, White);
// 7
   SetIndexBuffer(7, Bg_Wick_Black, INDICATOR_DATA);
   PlotIndexSetDouble(7, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(7, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(7, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(7, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(7, PLOT_LINE_COLOR, 0);
// 8
   SetIndexBuffer(8, Dn_Body_Green, INDICATOR_DATA);
   PlotIndexSetDouble(8, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(8, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(8, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(8, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(8, PLOT_LINE_COLOR, upColor);
// 9
   SetIndexBuffer(9, Up_Body_Red, INDICATOR_DATA);
   PlotIndexSetDouble(9, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(9, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(9, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(9, PLOT_LINE_WIDTH, 3);
   PlotIndexSetInteger(9, PLOT_LINE_COLOR, dnColor);
// 10
   SetIndexBuffer(10, Dn_Wick_Green, INDICATOR_DATA);
   PlotIndexSetDouble(10, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(10, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(10, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(10, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(10, PLOT_LINE_COLOR, upColor);
// 11
   SetIndexBuffer(11, Up_Wick_Red, INDICATOR_DATA);
   PlotIndexSetDouble(11, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(11, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(11, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(11, PLOT_LINE_WIDTH, 1);
   PlotIndexSetInteger(11, PLOT_LINE_COLOR, dnColor);
// 12
   SetIndexBuffer(12, correlation, INDICATOR_DATA);
   PlotIndexSetDouble(12, PLOT_EMPTY_VALUE, 0);
   PlotIndexSetInteger(12, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(12, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(12, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(12, PLOT_LINE_COLOR, Yellow);
//
   SetIndexBuffer(13, closed, INDICATOR_CALCULATIONS);
   PlotIndexSetDouble(13, PLOT_EMPTY_VALUE, 0);
   SetIndexBuffer(14, opened, INDICATOR_CALCULATIONS);
   PlotIndexSetDouble(14, PLOT_EMPTY_VALUE, 0);
   SetIndexBuffer(15, highed, INDICATOR_CALCULATIONS);
   PlotIndexSetDouble(15, PLOT_EMPTY_VALUE, 0);
   SetIndexBuffer(16, lowed, INDICATOR_CALCULATIONS);
   PlotIndexSetDouble(16, PLOT_EMPTY_VALUE, 0);
//
   int load = iBars(Symbol(), 0); // force load bars in history
//
    ArraySetAsSeries(Up_Body_Green, true);
   ArraySetAsSeries(Dn_Body_Red, true);
   ArraySetAsSeries(EqBodyBuffer, true);
   ArraySetAsSeries(Bg_Body_Black, true);
   ArraySetAsSeries(Up_Wick_Green, true);
   ArraySetAsSeries(Dn_Wick_Red, true);
   ArraySetAsSeries(EqShadowBuffer, true);
   ArraySetAsSeries(Bg_Wick_Black, true);
   ArraySetAsSeries(Dn_Body_Green, true);
   ArraySetAsSeries(Up_Body_Red, true);
   ArraySetAsSeries(Dn_Wick_Green, true);
   ArraySetAsSeries(Up_Wick_Red, true);
   ArraySetAsSeries(correlation, true);
   ArraySetAsSeries(closed, true);
   ArraySetAsSeries(opened, true);
   ArraySetAsSeries(highed, true);
   ArraySetAsSeries(lowed, true);
   /* closed[1] = 0;
    opened[1] = 0;
    highed[1] = 0;
    lowed[1] = 0;
    closed[0] = 0;
    opened[0] = 0;
    highed[0] = 0;
    lowed[0] = 0;*/
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(handle == 1)
     {
      FileClose(handle);
     }
  }
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   Prev_Bid = Curr_Bid;
   Curr_Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   Prev_Ask = Curr_Ask;
   Curr_Ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   Prev_Vol = Curr_Vol;
   Curr_Vol = iVolume(Symbol(), 0, 0);
//
   if(iTime(Symbol(), Period(), 0) != timestamp && firstTick == false && showCumulative == true)
     {
      closed[0] = closed[1];
      opened[0] = closed[1];
      highed[0] = closed[1];
      lowed[0] = closed[1];
      Prev_Vol = iVolume(Symbol(), 0, 0);
      timestamp = iTime(Symbol(), Period(), 0);
     }
   if(iTime(Symbol(), Period(), 0) != timestamp && firstTick == false && showCumulative == false)
     {
      closed[0] = 0;
      opened[0] = 0;
      highed[0] = 0;
      lowed[0] = 0;
      Prev_Vol = iVolume(Symbol(), 0, 0);
      timestamp = iTime(Symbol(), Period(), 0);
     }
//
   if(firstTick == true)
      initialize(); //function that will open appropriate files, read from them, and set basic global tick values to initial values
   updateTickValues(); // Function to update values based upon incoming tick and volume values
   printBar(0); // function to print our a bar using the histogram function for the current global tick values
   if(showCorr == true)
      calcCorr(); // function to calculate Pearson's correlation coefficient
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initialize()
  {
   Prev_Vol = iVolume(NULL, 0, 0);
   Curr_Vol = iVolume(NULL, 0, 0);
   firstTick = false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void printBar(int pos)
  {
   if(closed[pos] > 0 && opened[pos] >= 0 && lowed[pos] >= 0 && highed[pos] > 0)
     {
      if(closed[pos] > opened[pos])
        {
         Up_Body_Green[pos] = closed[pos];
         Bg_Body_Black[pos] = opened[pos];
         Up_Wick_Green[pos] = highed[pos];
         Bg_Wick_Black[pos] = lowed[pos];
         Up_Wick_Red[pos] = 0;
         Up_Body_Red[pos] = 0;
         Dn_Wick_Red[pos] = 0;
         Dn_Body_Red[pos] = 0;
        }
      if(closed[pos] < opened[pos])
        {
         Dn_Body_Red[pos] = opened[pos];
         Bg_Body_Black[pos] = closed[pos];
         Dn_Wick_Red[pos] = highed[pos];
         Bg_Wick_Black[pos] = lowed[pos];
         Up_Wick_Green[pos] = 0;
         Up_Body_Green[pos] = 0;
         Dn_Wick_Green[pos] = 0;
         Dn_Body_Green[pos] = 0;
        }
     }
   if(closed[pos] >= 0 && opened[pos] >= 0 && lowed[pos] < 0 && highed[pos] > 0)
     {
      if(closed[pos] > opened[pos])
        {
         Up_Body_Green[pos] = closed[pos];
         Bg_Body_Black[pos] = opened[pos];
         Up_Wick_Green[pos] = highed[pos];
         Dn_Wick_Green[pos] = lowed[pos];
         Up_Wick_Red[pos] = 0;
         Up_Body_Red[pos] = 0;
         Dn_Wick_Red[pos] = 0;
         Dn_Body_Red[pos] = 0;
        }
      if(closed[pos] < opened[pos])
        {
         Up_Body_Red[pos] = opened[pos];
         Bg_Body_Black[pos] = closed[pos];
         Up_Wick_Red[pos] = highed[pos];
         Dn_Wick_Red[pos] = lowed[pos];
         Up_Wick_Green[pos] = 0;
         Up_Body_Green[pos] = 0;
         Dn_Wick_Green[pos] = 0;
         Dn_Body_Green[pos] = 0;
        }
     }
   if(closed[pos] > 0 && opened[pos] < 0)
     {
      if(closed[pos] > opened[pos])
        {
         Up_Body_Green[pos] = closed[pos];
         Up_Wick_Green[pos] = highed[pos];
         Dn_Body_Green[pos] = opened[pos];
         Dn_Wick_Green[pos] = lowed[pos];
         Up_Wick_Red[pos] = 0;
         Up_Body_Red[pos] = 0;
         Dn_Wick_Red[pos] = 0;
         Dn_Body_Red[pos] = 0;
         Bg_Body_Black[pos] = 0;
         Bg_Wick_Black[pos] = 0;
        }
     }
   if(closed[pos] < 0 && opened[pos] <= 0 && lowed[pos] < 0 && highed[pos] <= 0)
     {
      if(closed[pos] > opened[pos])
        {
         Up_Body_Green[pos] = opened[pos];
         Bg_Body_Black[pos] = closed[pos];
         Up_Wick_Green[pos] = lowed[pos];
         Bg_Wick_Black[pos] = highed[pos];
         Up_Wick_Red[pos] = 0;
         Up_Body_Red[pos] = 0;
         Dn_Wick_Red[pos] = 0;
         Dn_Body_Red[pos] = 0;
        }
      if(closed[pos] < opened[pos])
        {
         Dn_Body_Red[pos] = closed[pos];
         Bg_Body_Black[pos] = opened[pos];
         Dn_Wick_Red[pos] = lowed[pos];
         Bg_Wick_Black[pos] = highed[pos];
         Up_Wick_Green[pos] = 0;
         Up_Body_Green[pos] = 0;
         Dn_Wick_Green[pos] = 0;
         Dn_Body_Green[pos] = 0;
        }
     }
   if(closed[pos] <= 0 && opened[pos] <= 0 && lowed[pos] < 0 && highed[pos] > 0)
     {
      if(closed[pos] > opened[pos])
        {
         Up_Body_Green[pos] = opened[pos];
         Bg_Body_Black[pos] = closed[pos];
         Up_Wick_Green[pos] = highed[pos];
         Dn_Wick_Green[pos] = lowed[pos];
         Up_Wick_Red[pos] = 0;
         Up_Body_Red[pos] = 0;
         Dn_Wick_Red[pos] = 0;
         Dn_Body_Red[pos] = 0;
        }
      if(closed[pos] < opened[pos])
        {
         Dn_Body_Red[pos] = closed[pos];
         Bg_Body_Black[pos] = opened[pos];
         Up_Wick_Red[pos] = highed[pos];
         Dn_Wick_Red[pos] = lowed[pos];
         Up_Wick_Green[pos] = 0;
         Up_Body_Green[pos] = 0;
         Dn_Wick_Green[pos] = 0;
         Dn_Body_Green[pos] = 0;
        }
     }
   if(closed[pos] < 0 && opened[pos] > 0)
     {
      Dn_Body_Red[pos] = closed[pos];
      Up_Wick_Red[pos] = highed[pos];
      Up_Body_Red[pos] = opened[pos];
      Dn_Wick_Red[pos] = lowed[pos];
      Up_Wick_Green[pos] = 0;
      Up_Body_Green[pos] = 0;
      Dn_Wick_Green[pos] = 0;
      Dn_Body_Green[pos] = 0;
      Bg_Body_Black[pos] = 0;
      Bg_Wick_Black[pos] = 0;
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void updateTickValues()
  {
   if(Curr_Ask > Prev_Ask)
     {
      closed[0] = closed[0] + (Curr_Vol - Prev_Vol);
      if(closed[0] > highed[0])
        {
         highed[0] = closed[0];
        }
      if(closed[0] < lowed[0])
        {
         lowed[0] = closed[0];
        }
     }
   if(Curr_Bid < Prev_Bid)
     {
      closed[0] = closed[0] - (Curr_Vol - Prev_Vol);
      if(closed[0] > highed[0])
        {
         highed[0] = closed[0];
        }
      if(closed[0] < lowed[0])
        {
         lowed[0] = closed[0];
        }
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calcCorr()
  {
   int rates_total = Bars(Symbol(), Period());
   int minBars = corrPeriod;
   int limit = MathMin(rates_total - 1 - minBars, rates_total - 1);
   for(int i = limit; i >= 0 && !IsStopped(); --i)
     {
      double A = 0, B = 0, C = 0;
      double sumY = 0, meanY = 0;
      double sumX = 0, meanX = 0;
      // Sum for meanY
      for(int p = i + corrPeriod; p >= i; p--)
        {
         double close = iClose(Symbol(), Period(), p);
         double open  = iOpen(Symbol(), Period(), p);
         sumY += (close - open);
        }
      meanY = sumY / corrPeriod;
      // Sum for meanX
      for(int r = i + corrPeriod; r >= i; r--)
        {
         double closed2 = iClose(Symbol(), Period(), r);
         double opened2 = iOpen(Symbol(), Period(), r);
         sumX += (closed2 - opened2);
        }
      meanX = sumX / corrPeriod;
      // A, B, C calculation
      for(int q = i + corrPeriod; q >= i; q--)
        {
         double closed3 = iClose(Symbol(), Period(), q);
         double opened3 = iOpen(Symbol(), Period(), q);
         double close3  = iClose(Symbol(), Period(), q);
         double open3  = iOpen(Symbol(), Period(), q);
         A += (closed3 - opened3 - meanX) * (close3 - open3 - meanY);
         B += MathPow(closed3 - opened3 - meanX, 2);
         C += MathPow(close3 - open3 - meanY, 2);
        }
      if(A != 0 && B != 0 && C != 0)
        {
         correlation[i] = 100.0 * A / (MathSqrt(B) * MathSqrt(C));
        }
      else
        {
         correlation[i] = 0; // vagy EMPTY_VALUE
        }
     }
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&p=157297#p157297

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 