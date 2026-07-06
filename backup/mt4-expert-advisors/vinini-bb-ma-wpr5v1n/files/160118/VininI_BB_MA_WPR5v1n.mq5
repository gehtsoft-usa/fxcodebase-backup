//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76212

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
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_type1   DRAW_LINE
#property indicator_color1  Aqua
#property indicator_label1  "MA(WPR)"
#property indicator_type2   DRAW_LINE
#property indicator_color2  Green
#property indicator_type3   DRAW_LINE
#property indicator_color3  Yellow
#property indicator_type4   DRAW_LINE
#property indicator_color4  Yellow
#property indicator_level1  0
#property indicator_level2  60
#property indicator_level3  -60
#property indicator_minimum -100
#property indicator_maximum 100

//---- input parameters
input int WPR_Period = 55;
input int MA_Period  = 3;
input int MA_Mode    = MODE_SMA;
input int BB_Period  = 89;
input double BB_Div  = 1.0;
input int Limit      = 1440;

double MA_Buffer[];
double WPRMidle_Buffer[];
double WPRUP_Buffer[];
double WPRDN_Buffer[];
double WPR_Buffer[];

int min_bars;

int OnInit()
{
   if(WPR_Period <= 0 || MA_Period <= 0 || BB_Period <= 0)
      return(INIT_PARAMETERS_INCORRECT);
   
   min_bars = WPR_Period + MA_Period + BB_Period;
   
   SetIndexBuffer(0, MA_Buffer, INDICATOR_DATA);
   SetIndexBuffer(1, WPRMidle_Buffer, INDICATOR_DATA);
   SetIndexBuffer(2, WPRUP_Buffer, INDICATOR_DATA);
   SetIndexBuffer(3, WPRDN_Buffer, INDICATOR_DATA);
   SetIndexBuffer(4, WPR_Buffer, INDICATOR_CALCULATIONS);
   
   IndicatorSetString(INDICATOR_SHORTNAME, "MA_WPR(" + IntegerToString(WPR_Period) + "," + IntegerToString(MA_Period) + ")");
   PlotIndexSetString(0, PLOT_LABEL, "MA(WPR)");
   
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, min_bars);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, min_bars);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, min_bars);
   PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, min_bars);
   
   return(INIT_SUCCEEDED);
}

double CalculateWPR(const int position, const int period, const double &high[], const double &low[], const double &close[])
{
   if(position < period - 1)
      return(0.0);
   
   double highest = high[position];
   double lowest = low[position];
   
   for(int i = position - period + 1; i <= position; i++)
   {
      if(high[i] > highest) highest = high[i];
      if(low[i] < lowest)   lowest = low[i];
   }
   
   if(highest == lowest)
      return(0.0);
   
   double wpr = -100.0 * (highest - close[position]) / (highest - lowest);
   return((wpr + 50.0) * 2.0);
}

double CalculateMAOnArray(const double &array[], const int position, const int period, const int ma_mode)
{
   if(position < period - 1)
      return(0.0);
   
   double sum = 0.0;
   switch(ma_mode)
   {
      case MODE_SMA:
         for(int i = 0; i < period; i++)
            sum += array[position - i];
         return(sum / period);
         
      case MODE_EMA:
      {
         double alpha = 2.0 / (period + 1.0);
         double ema = array[position];
         for(int i = position - 1; i > position - period; i--)
            ema = alpha * array[i] + (1 - alpha) * ema;
         return(ema);
      }
         
      case MODE_SMMA:
      {
         double smma = 0.0;
         for(int i = position - period + 1; i <= position; i++)
            smma += array[i];
         smma /= period;
         return(smma);
      }
         
      case MODE_LWMA:
      {
         double lwma = 0.0;
         double weight = 0.0;
         for(int i = 0; i < period; i++)
         {
            lwma += array[position - i] * (period - i);
            weight += (period - i);
         }
         return(weight > 0 ? lwma / weight : 0.0);
      }
   }
   return(0.0);
}

void CalculateBandsOnArray(const double &array[], const int position, const int period, const double deviations, 
                           double &midle, double &upper, double &lower)
{
   if(position < period - 1)
   {
      midle = 0.0;
      upper = 0.0;
      lower = 0.0;
      return;
   }
   
   double sum = 0.0;
   for(int i = 0; i < period; i++)
      sum += array[position - i];
   midle = sum / period;
   
   double variance = 0.0;
   for(int i = 0; i < period; i++)
   {
      double diff = array[position - i] - midle;
      variance += diff * diff;
   }
   variance /= period;
   double stddev = MathSqrt(variance);
   
   upper = midle + deviations * stddev;
   lower = midle - deviations * stddev;
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
   if(rates_total < min_bars)
      return(0);
      
   int start;
   if(prev_calculated == 0)
   {
      ArrayInitialize(WPR_Buffer, 0.0);
      ArrayInitialize(MA_Buffer, 0.0);
      ArrayInitialize(WPRMidle_Buffer, 0.0);
      ArrayInitialize(WPRUP_Buffer, 0.0);
      ArrayInitialize(WPRDN_Buffer, 0.0);
      
      start = WPR_Period - 1;
      
      if(Limit > 0 && rates_total - start > Limit)
         start = rates_total - Limit;
   }
   else
   {
      start = prev_calculated - 1;
   }
   
   for(int i = start; i < rates_total; i++)
   {
      WPR_Buffer[i] = CalculateWPR(i, WPR_Period, high, low, close);
   }
   
   int ma_start = (prev_calculated == 0) ? (WPR_Period - 1 + MA_Period - 1) : MathMax(start, MA_Period - 1);
   for(int i = ma_start; i < rates_total; i++)
   {
      MA_Buffer[i] = CalculateMAOnArray(WPR_Buffer, i, MA_Period, MA_Mode);
   }
   
   int bb_start = (prev_calculated == 0) ? (WPR_Period - 1 + MA_Period - 1 + BB_Period - 1) : MathMax(start, BB_Period - 1);
   for(int i = bb_start; i < rates_total; i++)
   {
      double midle, upper, lower;
      CalculateBandsOnArray(WPR_Buffer, i, BB_Period, BB_Div, midle, upper, lower);
      WPRMidle_Buffer[i] = midle;
      WPRUP_Buffer[i] = upper;
      WPRDN_Buffer[i] = lower;
   }
   
   return(rates_total);
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76212

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