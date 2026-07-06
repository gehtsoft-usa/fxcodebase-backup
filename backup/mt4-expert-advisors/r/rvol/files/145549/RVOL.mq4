// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72041

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
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




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

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

//Input Parmans
input int                 InpAveragingDays  =  5;               //Number of Days for Comparison 
// input ENUM_APPLIED_VOLUME InpVolumeType     =  VOLUME_TICK;     //Volume Type

//Indicator Buffers
double volHigh[];
double volMedium[];
double volLow[];
double vol[];
double ExtColorsBuffer[];
int    BarsIn24Hours = 0;
int    AveragingDays;

void OnInit()
{
   //Set Buffers
   SetIndexBuffer(0,volHigh, INDICATOR_DATA);
   SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 2, clrGreen);
   SetIndexBuffer(1,volMedium, INDICATOR_DATA);
   SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 2, clrOrange);
   SetIndexBuffer(2,volLow, INDICATOR_DATA);
   SetIndexStyle(2, DRAW_HISTOGRAM, EMPTY, 2, clrRed);
   SetIndexBuffer(3,vol);
   SetIndexStyle(3, DRAW_NONE);

   //Define how many bars required to begin drawing 
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 100);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, 100);

   //Set indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   
   //Ensure valid InpAveragingDays
   if(InpAveragingDays >= 1)
      AveragingDays = InpAveragingDays;
   else 
      AveragingDays = 5;
      
   //Set name of indicator
   string short_name = StringFormat("RVOL (Relative Volume) (%d)", AveragingDays);
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   
   //Mean Level
   // IndicatorSetInteger(INDICATOR_LEVELCOLOR, 0, clrGray);
   SetLevelStyle(STYLE_DOT,1,clrGray);
   IndicatorSetString(INDICATOR_LEVELTEXT, 0, "Above Average Volume");   
   // IndicatorSetInteger(INDICATOR_LEVELCOLOR, 1, clrGray);
   IndicatorSetString(INDICATOR_LEVELTEXT, 1, "Below Average Volume");   
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
   
   if(BarsIn24Hours == 0) //Set to 0 by default above
   {
      SetBarsIn24Hours();
		Print(__FUNCTION__," ","BarsIn24Hours"," ",BarsIn24Hours);
      if(BarsIn24Hours == 0) //Bars not yet available in chart for calculation to succeed
         return(0);
   }
   
	//Set starting point for the processing
	int startBar = rates_total - prev_calculated + BarsIn24Hours;

   //Main cycle
      CalculateRelVolume(startBar, rates_total, tick_volume);
   // CalculateRelVolume(startBar, rates_total, volume);

   return(rates_total);
}

void CalculateRelVolume(const int startBar, const int rates_total, const long& volume[])
{

   vol[startBar] = (double)volume[startBar];

   int i = startBar;
   if (i >= rates_total) i = rates_total - 1;
   for (; i > 0 && !IsStopped(); i--)
   {
         double curr_volume = (double)volume[i];
         double mean_volume = 0.0;         
         
			for(int j = 1; j <= AveragingDays; j++) 
			mean_volume += (double)volume[i + (j * BarsIn24Hours)]; 
         
			mean_volume /= (double)AveragingDays;
         
			//N.B. Value of 1.0 represents current vol is equal to average volume, 0.0-1.0 is below average, >1.0 is above average
         if(mean_volume>0)
			vol[i] = curr_volume / mean_volume;            
         if(vol[i] > indicator_level1) volHigh[i] = vol[i];         //If current vol higher than average     
         else if (vol[i] > indicator_level2) volMedium[i] = vol[i];   //If current vol lower than average     
         else volLow[i] = vol[i];
   }
}

int SetBarsIn24Hours()
{
   datetime prevDateTime = iTime(NULL, PERIOD_CURRENT, 0) - (86400 * 7); //Need to base calculation on 7 days so that weekends don't interfere 
   
   int numBarsIn7Days = iBarShift(NULL, PERIOD_CURRENT, prevDateTime, false);
   
   //Num bars in 7 days actually represents 5 trading days. N.B. This Indicator only works for assets that trade 5 days per week. It will not work with 24x7 Crypto for example
   BarsIn24Hours = numBarsIn7Days / 5; 
      
   return BarsIn24Hours;
}