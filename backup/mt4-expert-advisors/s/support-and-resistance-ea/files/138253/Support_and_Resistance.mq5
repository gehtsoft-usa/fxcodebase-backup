// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70534

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property description "Blue and red support and resistance levels displayed directly on the chart."
#property description "Based on MT4 indicator by Barry Stander."

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_color1  Red
#property indicator_type1   DRAW_ARROW
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_color2  Blue
#property indicator_type2   DRAW_ARROW
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//---- buffers
double Resistance[];
double Support[];

void OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, "Support and Resistance");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   PlotIndexSetInteger(0, PLOT_ARROW, 119);
   PlotIndexSetInteger(1, PLOT_ARROW, 119);

   SetIndexBuffer(0, Resistance);
   PlotIndexSetString(0, PLOT_LABEL, "Resistance");

   SetIndexBuffer(1, Support);
   PlotIndexSetString(1, PLOT_LABEL, "Support");

   ArraySetAsSeries(Resistance, true);
   ArraySetAsSeries(Support, true);
}

//+------------------------------------------------------------------+
//| Custom Support and Resistance                                    |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &High[],
                const double &Low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   ArraySetAsSeries(High, true);
   ArraySetAsSeries(Low, true);

   //Get the values of the Fractals indicator before entering the cycle
   double FractalUpperBuffer[];
   double FractalLowerBuffer[];
   int myFractal = iFractals(NULL, 0);
   CopyBuffer(myFractal, 0, 0, rates_total, FractalUpperBuffer);
   CopyBuffer(myFractal, 1, 0, rates_total, FractalLowerBuffer);
	ArraySetAsSeries(FractalUpperBuffer, true);
	ArraySetAsSeries(FractalLowerBuffer, true);
	
   for (int i = rates_total - 2; i >= 0; i--)
   {
		if (FractalUpperBuffer[i] != EMPTY_VALUE) Resistance[i] = High[i];
    	else Resistance[i] = Resistance[i + 1];
  
 		if (FractalLowerBuffer[i] != EMPTY_VALUE) Support[i] = Low[i];
      else Support[i] = Support[i + 1];
   }   

	return(rates_total);
}

//+------------------------------------------------------------------+