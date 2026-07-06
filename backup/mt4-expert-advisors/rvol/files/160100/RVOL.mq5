// More information about this indicator can be found at:
//https://fxcodebase.com/code/posting.php?mode=reply&f=38&t=72041

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

//Indicator settings
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrGreen
#property indicator_style1  0
#property indicator_width1  2
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrOrange
#property indicator_style2  0
#property indicator_width2  2
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrRed
#property indicator_style3  0
#property indicator_width3  2
#property indicator_type4   DRAW_NONE

//Level of above average (1.25) and below average (0.8) volume (for time of day) - (ratio of 1.0 indicates current volume is the same as average)
#property indicator_level1 1.25 //Above Average Volume Level
#property indicator_level2 0.8  //Below Average Volume Level

//Input Parameters
input int                 InpAveragingDays  =  5;               //Number of Days for Comparison
double volHigh[];
double volMedium[];
double volLow[];
double vol[];
double ExtColorsBuffer[];
int    BarsIn24Hours = 0;
int    AveragingDays;

int OnInit()
{
   SetIndexBuffer(0, volHigh, INDICATOR_DATA);
   SetIndexBuffer(1, volMedium, INDICATOR_DATA);
   SetIndexBuffer(2, volLow, INDICATOR_DATA);
   SetIndexBuffer(3, vol, INDICATOR_CALCULATIONS);
   
   PlotIndexSetString(0, PLOT_LABEL, "High Volume");
   PlotIndexSetString(1, PLOT_LABEL, "Medium Volume");
   PlotIndexSetString(2, PLOT_LABEL, "Low Volume");

   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 100);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, 100);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, 100);

   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   
   if(InpAveragingDays >= 1)
      AveragingDays = InpAveragingDays;
   else 
      AveragingDays = 5;
      
   string short_name = StringFormat("RVOL (Relative Volume) (%d)", AveragingDays);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, 0, clrGray);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, 0, STYLE_DOT);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH, 0, 1);
   IndicatorSetString(INDICATOR_LEVELTEXT, 0, "Above Average Volume");
   
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, 1, clrGray);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, 1, STYLE_DOT);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH, 1, 1);
   IndicatorSetString(INDICATOR_LEVELTEXT, 1, "Below Average Volume");
   
   ArraySetAsSeries(volHigh, true);
   ArraySetAsSeries(volMedium, true);
   ArraySetAsSeries(volLow, true);
   ArraySetAsSeries(vol, true);
   
   return(INIT_SUCCEEDED);
}

int OnCalculate(
   const int rates_total,
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
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);
   ArraySetAsSeries(volume, true);
   ArraySetAsSeries(spread, true);
   
   if(BarsIn24Hours == 0)
   {
     SetBarsIn24Hours();
     Print(__FUNCTION__," ","BarsIn24Hours"," ",BarsIn24Hours);
     if(BarsIn24Hours == 0)
       return(0);
   }
   
   if(rates_total < BarsIn24Hours * AveragingDays)
     return(0);
   
   int startBar;
   if(prev_calculated == 0)
     startBar = rates_total - BarsIn24Hours * AveragingDays - 1;
   else
     startBar = rates_total - prev_calculated;

      CalculateRelVolume(startBar, rates_total, tick_volume);
  
   return(rates_total);
}

void CalculateRelVolume(const int startBar, const int rates_total, const long& volume[])
{
   if(startBar < 0 || startBar >= rates_total)
      return;
      
   if(startBar < rates_total)
      vol[startBar] = (double)volume[startBar];

   for(int i = startBar; i >= 0 && !IsStopped(); i--)
   {
      double curr_volume = (double)volume[i];
      double mean_volume = 0.0;
      int valid_days = 0;
      
      for(int j = 1; j <= AveragingDays; j++)
      {
         int idx = i + (j * BarsIn24Hours);
         if(idx < rates_total)
         {
            mean_volume += (double)volume[idx];
            valid_days++;
         }
      }
      
      if(valid_days > 0)
         mean_volume /= (double)valid_days;
      
      volHigh[i] = EMPTY_VALUE;
      volMedium[i] = EMPTY_VALUE;
      volLow[i] = EMPTY_VALUE;
      
      if(mean_volume > 0)
      {
         vol[i] = curr_volume / mean_volume;
         
         if(vol[i] > 1.25)
            volHigh[i] = vol[i];
         else if(vol[i] > 0.8)
            volMedium[i] = vol[i];
         else
            volLow[i] = vol[i];
      }
      else
      {
         vol[i] = 0.0;
      }
   }
}

int SetBarsIn24Hours()
{
   datetime prevDateTime = iTime(NULL, PERIOD_CURRENT, 0) - (86400 * 7);
   
   int numBarsIn7Days = Bars(NULL, PERIOD_CURRENT, prevDateTime, iTime(NULL, PERIOD_CURRENT, 0));
   
   BarsIn24Hours = numBarsIn7Days / 5; 
      
   return BarsIn24Hours;
}
// More information about this indicator can be found at:
//https://fxcodebase.com/code/posting.php?mode=reply&f=38&t=72041

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
