// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69307

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                         https://AppliedMachineLearning.systems   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 7

input string wmtext1                = "pivot timeframe";
input string wmtext2                = "daily=1, weeky=2, monthly=3";
input int    pivot_timeframe        = 1;
input string mltext1                = "first instance supports main pivot levels";
input string mltext2                = "to add mid pivot levels, load this";
input string mltext3                = "indicator a second time and set below true";
input bool   addMidLevels           = false;
input string bartext                = "set to number of bars to use";
input int    BarsToProcess          = 100;
input string linetext               = "below line/text style is configured";
input bool   showLineText           = true;
input string text_font              = "Arial";
input int    text_size              = 4;
input color  text_color             = Yellow;
input string tstext1                = "text_shift shifts the line text by N spaces";
input int    text_shift             = 40;
input int    line_thickness_main    = 1;
input int    line_thickness_mid     = 1;
input color  line_color_main        = Gold;           // Black
input color  line_color_support1    = Yellow;      // DodgerBlue
input color  line_color_resistance1 = Yellow;       // OrangeRed
input color  line_color_support2    = Yellow;       // RoyalBlue
input color  line_color_resistance2 = Yellow;         // Crimson
input color  line_color_support3    = Yellow;            // Blue
input color  line_color_resistance3 = Yellow;          // Maroon

//---- buffers
double PBuffer[];

//---- global variables
datetime current_time;
double   multiplier;
double   last_high,last_low,last_close;
int      i;
int      line_thickness;
int      pivot_bar;
ENUM_TIMEFRAMES pivot_timeframe_const;
string   pregap = "";
string   timeframe_prefix;
string   timeframe_prefix_text;

string IndicatorName;
string IndicatorObjPrefix;
string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}
int OnInit(void)
{
   IndicatorName = GenerateIndicatorName("Indi DP");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   if(StringFind(Symbol(),"JPY",0)<0)  multiplier = 10000;
   if(StringFind(Symbol(),"JPY",0)>=0) multiplier = 100;

   if(addMidLevels == true) line_thickness = line_thickness_mid;
   else line_thickness = line_thickness_main;
   
   if( pivot_timeframe == 1) pivot_timeframe_const = PERIOD_D1;
   if( pivot_timeframe == 2) pivot_timeframe_const = PERIOD_W1;
   if( pivot_timeframe == 3) pivot_timeframe_const = PERIOD_MN1;
   
   if(pivot_timeframe == 1) timeframe_prefix = "Daily";
   if(pivot_timeframe == 2) timeframe_prefix = "Weekly ";
   if(pivot_timeframe == 3) timeframe_prefix = "Monthly ";

   pregap="";   
   for(i=0; i<text_shift;i++) 
      pregap = pregap + " ";
   if(addMidLevels == true) 
      timeframe_prefix = timeframe_prefix + "Mid ";
   timeframe_prefix_text = pregap + timeframe_prefix;
   timeframe_prefix = IndicatorObjPrefix;

   SetIndexBuffer(0, PBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, line_color_main);
   PlotIndexSetString(0, PLOT_LABEL, timeframe_prefix + "Pivot");

   ObjectCreate(0, IndicatorObjPrefix + "Pivot",OBJ_TEXT,0,0,0);
   if(showLineText == true)
   {
      ObjectSetString(0, IndicatorObjPrefix + "Pivot", OBJPROP_TEXT, timeframe_prefix_text + "Pivot");
      ObjectSetString(0, IndicatorObjPrefix + "Pivot", OBJPROP_FONT, text_font);
      ObjectSetInteger(0, IndicatorObjPrefix + "Pivot", OBJPROP_FONTSIZE, text_size);
      ObjectSetInteger(0, IndicatorObjPrefix + "Pivot", OBJPROP_COLOR, text_color);
   }
   
   ObjectCreate(0, IndicatorObjPrefix + "Pivot ext", OBJ_TREND,0, 0,0,0,0);
   ObjectSetInteger(0, IndicatorObjPrefix + "Pivot ext", OBJPROP_COLOR, line_color_main);
   ObjectSetInteger(0, IndicatorObjPrefix + "Pivot ext", OBJPROP_STYLE, STYLE_DOT);

   return INIT_SUCCEEDED;//INIT_FAILED
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

int TimeDayOfWeek(datetime dt)
{
   MqlDateTime time;
   TimeToStruct(dt, time);
   return time.day_of_week;
}

int OnCalculate(const int rates_total,       // size of input time series
                const int prev_calculated,   // number of handled bars at the previous call
                const datetime& time[],      // Time array
                const double& open[],        // Open array
                const double& high[],        // High array
                const double& low[],         // Low array
                const double& close[],       // Close array
                const long& tick_volume[],   // Tick Volume array
                const long& volume[],        // Real Volume array
                const int& spread[]          // Spread array
)
{
   if(pivot_timeframe == 1) if(Period()>PERIOD_D1) return(-1);
   if(pivot_timeframe == 2) if(Period()>PERIOD_W1) return(-1);
   if(pivot_timeframe == 3) if(Period()>PERIOD_MN1) return(-1);

   for (int i = prev_calculated; i < rates_total; ++i)
   {
      // looking for the current time   
      datetime current_time = time[i];
      // and seach the corresponding bar in the pivot timeframe
      int pivot_bar = iBarShift(NULL, pivot_timeframe_const, current_time);
      // non GMT2/3 brokers may have an additional Sunday-day-candle. In this case, the Pivots for Monday need to based on the Friday-day-candle.
      if(TimeDayOfWeek(iTime(NULL,pivot_timeframe_const,pivot_bar)) == 1)
      {
         // we are on a Monday. Is the previous day a Sunday? Then we need to jump back to Friday
         if(TimeDayOfWeek(iTime(NULL,pivot_timeframe_const,pivot_bar+1)) == 0)
         {
            pivot_bar++;
         }
      }
      
      // read the values of that previous week/month
      double last_low=iLow(NULL, pivot_timeframe_const, pivot_bar+1);
      double last_high=iHigh(NULL, pivot_timeframe_const, pivot_bar+1);
      double last_close=iClose(NULL, pivot_timeframe_const, pivot_bar+1);
      
      // calculate main pivot and S/R lines		    
      double P=(last_high+last_low+last_close)/3;
      double R1=(2*P)-last_low;
      double S1=(2*P)-last_high;
      double R2=P+(last_high-last_low);
      double S2=P-(last_high-last_low);
      double R3=(2*P)+(last_high-(2*last_low));
      double S3=(2*P)-((2*last_high)-last_low);
      
      // calculate mid S/R lines		    
      double MS3 = S3 + ((S2-S3) / 2);
      double MS2 = S2 + ((S1-S2) / 2);
      double MS1 = S1 + ((P-S1) / 2);
      double MR1 = P + ((R1-P) / 2);
      double MR2 = R1 + ((R2-R1) / 2);
      double MR3 = R2 + ((R3-R2) / 2);
      
      // copy either main or mid values to the temp display variables
      if (addMidLevels == false)
      {
         PBuffer[i]=P;
      }
      else
      {
         PBuffer[i]=0;
      }
   }
   pregap = "";   
   for(i=0; i<text_shift;i++) pregap = pregap + " ";
   timeframe_prefix_text = pregap + timeframe_prefix;

   if(showLineText == true)
   {
      ObjectMove(0, timeframe_prefix + "Pivot",0,time[rates_total - 1], PBuffer[rates_total - 1]);
      ObjectSetString(0, timeframe_prefix + "Pivot", OBJPROP_TEXT, "                                              DAILY PIVOT");
   }
   
   ObjectMove(0, timeframe_prefix + "Pivot ext", 0, time[rates_total - 2], PBuffer[rates_total - 1]);
   ObjectMove(0, timeframe_prefix + "Pivot ext", 1, time[rates_total - 1], PBuffer[rates_total - 1]);

   return rates_total;
}