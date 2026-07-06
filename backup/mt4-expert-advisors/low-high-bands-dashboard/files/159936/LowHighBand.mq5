//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76113&p=159824#p159824

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
#property indicator_buffers 10
#property indicator_plots   9
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
#property indicator_type4   DRAW_LINE
#property indicator_type5   DRAW_LINE
#property indicator_type6   DRAW_LINE
#property indicator_type7   DRAW_LINE
#property indicator_type8   DRAW_LINE
#property indicator_type9   DRAW_LINE
#property indicator_color1  clrNONE
#property indicator_color2  clrNONE
#property indicator_color3  clrNONE
#property indicator_color4  clrDimGray
#property indicator_color5  clrSilver
#property indicator_color6  clrBlack
#property indicator_color7  clrBlack
#property indicator_color8  clrWhite
#property indicator_color9  clrWhite
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_style3  STYLE_DOT
#property indicator_width4  9
#property indicator_width5  3
#property indicator_width6  3
#property indicator_width7  3
#property indicator_width8  3
#property indicator_width9  3

//--- Input parameters
enum enMaTypes {
   avgSma,    // Simple moving average
   avgEma,    // Exponential moving average
   avgSmma,   // Smoothed MA
   avgLwma    // Linear weighted MA
};

input int       HlPeriod     = 1;           // High low period
input int       AvgPeriod    = 13;          // Average period
input enMaTypes AvgType      = avgSma;      // Average method
input color     colorUp      = clrWhite;    // Color for up
input color     colorDown    = clrBlack;    // Color for down
input color     colorNeutral = clrSilver;   // Color for neutral
input color     colorShadow  = clrDimGray;  // Color for shadow
input int       linesWidth   = 3;           // Lines width

//--- Indicator buffers
double fluBuffer[], flmBuffer[], fldBuffer[];
double shadowBuffer[], avgBuffer[], avgdaBuffer[];
double avgdbBuffer[], avguaBuffer[], avgubBuffer[];
double slopeBuffer[];

//--- Global variables
int    minBars;
double alpha;

int OnInit()
{
   minBars = (int)MathMax(HlPeriod, AvgPeriod) + 1;
   
   //--- Set indicator buffers mapping
   SetIndexBuffer(0, fluBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, flmBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, fldBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, shadowBuffer, INDICATOR_DATA);
   SetIndexBuffer(4, avgBuffer, INDICATOR_DATA);
   SetIndexBuffer(5, avgdaBuffer, INDICATOR_DATA);
   SetIndexBuffer(6, avgdbBuffer, INDICATOR_DATA);
   SetIndexBuffer(7, avguaBuffer, INDICATOR_DATA);
   SetIndexBuffer(8, avgubBuffer, INDICATOR_DATA);
   SetIndexBuffer(9, slopeBuffer, INDICATOR_CALCULATIONS);
   
   //--- Set drawing settings
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(6, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(7, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(8, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   
   //--- Set visual styles
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(7, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(8, PLOT_DRAW_TYPE, DRAW_LINE);
   
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(1, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(2, PLOT_LINE_STYLE, STYLE_DOT);
   
   //--- Set colors
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, colorShadow);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, colorNeutral);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, colorDown);
   PlotIndexSetInteger(6, PLOT_LINE_COLOR, colorDown);
   PlotIndexSetInteger(7, PLOT_LINE_COLOR, colorUp);
   PlotIndexSetInteger(8, PLOT_LINE_COLOR, colorUp);
   
   //--- Set line widths
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, linesWidth+6);
   PlotIndexSetInteger(4, PLOT_LINE_WIDTH, linesWidth);
   PlotIndexSetInteger(5, PLOT_LINE_WIDTH, linesWidth);
   PlotIndexSetInteger(6, PLOT_LINE_WIDTH, linesWidth);
   PlotIndexSetInteger(7, PLOT_LINE_WIDTH, linesWidth);
   PlotIndexSetInteger(8, PLOT_LINE_WIDTH, linesWidth);
   
   //--- Initialize EMA alpha
   alpha = (AvgPeriod <= 1) ? 1.0 : 2.0 / (1.0 + AvgPeriod);
   
   return(INIT_SUCCEEDED);
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
   if(rates_total < minBars) return(0);
   
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(avgBuffer, true);
   ArraySetAsSeries(fluBuffer, true);
   ArraySetAsSeries(flmBuffer, true);
   ArraySetAsSeries(fldBuffer, true);
   ArraySetAsSeries(shadowBuffer, true);
   ArraySetAsSeries(avgdaBuffer, true);
   ArraySetAsSeries(avgdbBuffer, true);
   ArraySetAsSeries(avguaBuffer, true);
   ArraySetAsSeries(avgubBuffer, true);
   ArraySetAsSeries(slopeBuffer, true);
   
   int start;
   if(prev_calculated == 0) {
      start = rates_total - minBars;
      for(int i = 0; i < start; i++) {
         slopeBuffer[i] = 0;
         avgdaBuffer[i] = EMPTY_VALUE;
         avgdbBuffer[i] = EMPTY_VALUE;
         avguaBuffer[i] = EMPTY_VALUE;
         avgubBuffer[i] = EMPTY_VALUE;
      }
   }
   else start = prev_calculated - 1;
   
   //--- Main calculation loop
   for(int i = start; i >= 0; i--)
   {
      int hStart = MathMin(i + HlPeriod - 1, rates_total - 1);
      int lStart = MathMin(i + HlPeriod - 1, rates_total - 1);
      
      fluBuffer[i] = high[ArrayMaximum(high, i, HlPeriod)];
      fldBuffer[i] = low[ArrayMinimum(low, i, HlPeriod)];
      flmBuffer[i] = (fluBuffer[i] + fldBuffer[i]) / 2.0;
      
      avgBuffer[i] = iCustomMA(AvgType, flmBuffer, i, AvgPeriod);
      shadowBuffer[i] = avgBuffer[i];
      
      avgdaBuffer[i] = EMPTY_VALUE;
      avgdbBuffer[i] = EMPTY_VALUE;
      avguaBuffer[i] = EMPTY_VALUE;
      avgubBuffer[i] = EMPTY_VALUE;
      
      if(i < rates_total - 1) {
         slopeBuffer[i] = slopeBuffer[i + 1];
         if(avgBuffer[i] > flmBuffer[i]) slopeBuffer[i] = -1;
         if(avgBuffer[i] < flmBuffer[i]) slopeBuffer[i] = 1;
      }
      
      if(slopeBuffer[i] == -1) {
         if(i < rates_total - 1 && avgdaBuffer[i + 1] != EMPTY_VALUE) {
            avgdaBuffer[i] = avgBuffer[i];
            avgdbBuffer[i] = EMPTY_VALUE;
         }
         else {
            avgdaBuffer[i] = EMPTY_VALUE;
            avgdbBuffer[i] = avgBuffer[i];
         }
      }
      else if(slopeBuffer[i] == 1) {
         if(i < rates_total - 1 && avguaBuffer[i + 1] != EMPTY_VALUE) {
            avguaBuffer[i] = avgBuffer[i];
            avgubBuffer[i] = EMPTY_VALUE;
         }
         else {
            avguaBuffer[i] = EMPTY_VALUE;
            avgubBuffer[i] = avgBuffer[i];
         }
      }
   }
   
   CleanPoints(avgdaBuffer, avgdbBuffer, rates_total);
   CleanPoints(avguaBuffer, avgubBuffer, rates_total);
   
   return(rates_total);
}

double iCustomMA(enMaTypes type, const double &price[], int index, int period)
{
   if(period <= 1) return price[index];
   
   switch(type)
   {
      case avgSma:  return iSMA(price, index, period);
      case avgEma:  return iEMA(price, index, period);
      case avgSmma: return iSMMA(price, index, period);
      case avgLwma: return iLWMA(price, index, period);
      default:      return price[index];
   }
}

double iSMA(const double &price[], int index, int period)
{
   double sum = 0.0;
   for(int i = 0; i < period; i++)
      sum += price[index + i];
   return sum / period;
}

double iEMA(const double &price[], int index, int period)
{
   if(index > 0)
      return price[index] * alpha + iEMA(price, index + 1, period) * (1 - alpha);
   return price[index];
}

double iSMMA(const double &price[], int index, int period)
{
   static double sum[];
   static bool firstRun = true;
   
   if(firstRun) {
      ArrayResize(sum, ArraySize(price));
      ArrayInitialize(sum, 0);
      firstRun = false;
   }
   
   if(index >= ArraySize(price) - period)
      return price[index];
   
   if(index == ArraySize(price) - period)
      sum[index] = iSMA(price, index, period);
   else
      sum[index] = (sum[index + 1] * (period - 1) + price[index]) / period;
      
   return sum[index];
}

double iLWMA(const double &price[], int index, int period)
{
   double sum = 0.0;
   double weight = 0.0;
   for(int i = 0; i < period; i++) {
      sum += price[index + i] * (period - i);
      weight += (period - i);
   }
   return weight > 0 ? sum / weight : price[index];
}

void CleanPoints(double &mainLine[], double &dashLine[], int total)
{
   for(int i = 0; i < total - 3; i++)
   {
      if(mainLine[i] != EMPTY_VALUE && mainLine[i+1] == EMPTY_VALUE && 
         mainLine[i+2] == EMPTY_VALUE && dashLine[i+1] != EMPTY_VALUE)
      {
         dashLine[i+1] = EMPTY_VALUE;
      }
   }
}

//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76113&p=159824#p159824

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