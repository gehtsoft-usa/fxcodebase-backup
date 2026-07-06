// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70746

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
#property version   "1.1"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 White
#property indicator_color2 Lime
#property indicator_color3 Tomato
#property indicator_color4 White
#property indicator_color5 Blue
#property indicator_width1 1
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 3
#property indicator_width5 3
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_plots 6
#property indicator_color6 White
#property indicator_width6 2

//---- input parameters
input int eintBandsPeriod = 20;
input double edblBandsDev = 2.0;
input int eintMAMode = MODE_SMA;
input int eintMAPrice = PRICE_CLOSE;
input int eintMAShift = 0;
input int eintBarsBack = 1;
input bool UseSound=true;
input bool AlertSound=true;
input string SoundFileBuy ="alert2.wav";
input string SoundFileSell="email.wav";
input bool SendMailPossible = false;
input int SIGNAL_BAR =  1 ; 
bool SoundBuy  = False;
bool SoundSell = False;


//---- indicator buffers
double gadblMid[];
double gadblUpper[];
double gadblLower[];
double gadblDiv[];
double gadblDiv2[];
//******************************************************************************************************************************************************

// ajout vwap bande

input int N = 20; // Period of Volume Weight Average Price
input int Shift = 0;
input ENUM_APPLIED_PRICE Price_Type = PRICE_CLOSE; // Price Type
input double DeviationBand1 = 1; // Number of StdDevs for the 1st band
input double DeviationBand2 = 2; // Number of StdDevs for the 2nd band
input double DeviationBand3 = 2.5; // Number of StdDevs for the 3rd band
input string note_10 = "";                         //Button
input bool btn_show = true;                       //__ show
input string btn_pressed = "VWAP";                 //__ text
input int btn_offset_x = 10;                       //__ x
input int btn_offset_y = 20;                       //__ y
input int btn_width = 50;                          //__ width
input int btn_height = 20;                         //__ height
input int btn_font_size = 10;                      //__ font size
input color btn_font_clr = clrBlack;               //__ font color
input color btn_bg_color = clrGray;                //__ bg color
input color btn_border_clr = clrWhiteSmoke;        //__ border color

input int button_x = 20;
input int button_y = 30;

//Visibility controller v1.3
class VisibilityCotroller
{
   string buttonId;
   string visibilityId;
   bool show_data;
   bool recalc;
public:
   void Init(string id, string indicatorName, string caption, int x, int y)
   {
      recalc = false;
      visibilityId = indicatorName + "_visibility";
      double val;
      if (GlobalVariableGet(visibilityId, val))
         show_data = val != 0;
         
      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, caption, 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, x);
   }

   void DeInit()
   {
      ObjectDelete(ChartID(), buttonId);
   }

   bool HandleButtonClicks()
   {
      if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
      {
         ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
         show_data = !show_data;
         GlobalVariableSet(visibilityId, show_data ? 1.0 : 0.0);
         recalc = true;
         return true;
      }
      return false;
   }

   bool IsRecalcNeeded()
   {
      return recalc;
   }

   void ResetRecalc()
   {
      recalc = false;
   }

   bool IsVisible()
   {
      return show_data;
   }

private:
   void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
   {
      ObjectDelete(0,buttonID);
      ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString(0,buttonID,OBJPROP_FONT,font);
      ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,2);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
   }
};
VisibilityCotroller visibility;

// Indicator buffers
double ExtMapBuffer1[], UpperDev1[], LowerDev1[], UpperDev2[], LowerDev2[], UpperDev3[], LowerDev3[], ExtStdDevBuffer[];


//+------------------------------------------------------------------+
//| init()                                                           |
//+------------------------------------------------------------------+
int init()
{
   visibility.Init("bbetvwap", "bbetvwap", "Show/Hide", button_x, button_y);
   
    if (N < 1)
   {
   	Alert("Period must be >= 1.");
   	return(INIT_FAILED);
   }
   IndicatorDigits(Digits);

   
   SetIndexBuffer( 0, gadblMid );
   SetIndexStyle( 0, DRAW_LINE );
   SetIndexLabel( 0, "BB-Mid" );
   
   SetIndexBuffer( 1, gadblUpper );
   SetIndexStyle( 1, DRAW_LINE );
   SetIndexLabel( 1, "BB-Upper" );
   
   SetIndexBuffer( 2, gadblLower );
   SetIndexStyle( 2, DRAW_LINE );
   SetIndexLabel( 2, "BB-Lower" );
   
   SetIndexBuffer( 3, gadblDiv );
   SetIndexStyle( 3, DRAW_ARROW );
   SetIndexArrow( 3, 108 ); 
   SetIndexLabel( 3, NULL );
   SetIndexEmptyValue( 3, 0.0 );
   
   SetIndexBuffer( 4, gadblDiv2 );
   SetIndexStyle( 4, DRAW_ARROW );
   SetIndexArrow( 4, 108 ); 
   SetIndexLabel( 4, NULL );
   SetIndexEmptyValue( 4, 0.0 );
   
   SetIndexBuffer(5 , ExtMapBuffer1);
   SetIndexBuffer(6, ExtStdDevBuffer);
   SetIndexLabel( 5, "VWAP" );

   

   IndicatorShortName( "Fiji BB" );
   IndicatorDigits( Digits );
   
   return( 0 );
}

//+------------------------------------------------------------------+
//| deinit()                                                         |
//+------------------------------------------------------------------+
int deinit()
{
   visibility.DeInit();
   return( 0 );
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
   {
      start();
   }
}

//+------------------------------------------------------------------+
//| start()                                                          |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars = IndicatorCounted();
   visibility.HandleButtonClicks();

   if (visibility.IsRecalcNeeded())
   {
      if (visibility.IsVisible())
      {
         counted_bars = 0;
      }
      else
      {
         ArrayInitialize(ExtMapBuffer1, EMPTY_VALUE);
         ArrayInitialize(ExtStdDevBuffer, EMPTY_VALUE);
         ArrayInitialize(gadblMid, EMPTY_VALUE);
         ArrayInitialize(gadblUpper, EMPTY_VALUE);
         ArrayInitialize(gadblLower, EMPTY_VALUE);
         ArrayInitialize(gadblDiv, 0);
         ArrayInitialize(gadblDiv2, 0);
      }
      visibility.ResetRecalc();
   }
   if (!visibility.IsVisible())
   {
      return 0;
   }
   
    int bar = Bars - counted_bars + N;
   if (bar >= Bars - N) bar = Bars - N - 1;

	for (int i = 0; i <= bar; i++)
	{
		double sum1 = 0, sum2 = 0;
		for (int ntmp = 0; ntmp <= N; ntmp++)
		{
			switch(Price_Type)
			{
				case PRICE_CLOSE: 	sum1 += Close[i + ntmp] * Volume[i + ntmp]; break;
				case PRICE_OPEN: 		sum1 += Open[i + ntmp] * Volume[i + ntmp]; break;
				case PRICE_HIGH: 		sum1 += High[i + ntmp] * Volume[i + ntmp]; break;
				case PRICE_LOW: 		sum1 += Low[i + ntmp] * Volume[i + ntmp]; break;
				case PRICE_MEDIAN: 	sum1 += (High[i + ntmp] + Low[i + ntmp]) / 2 * Volume[i + ntmp]; break;
				case PRICE_TYPICAL:  sum1 += (High[i + ntmp] + Low[i + ntmp] + Close[i + ntmp]) / 3 * Volume[i + ntmp]; break;
				case PRICE_WEIGHTED: sum1 += (High[i + ntmp] + Low[i + ntmp] + Close[i + ntmp] + Close[i + ntmp]) / 4 * Volume[i + ntmp]; break;
			} 
			sum2 += (double)Volume[i + ntmp];
		}
		if (sum2 != 0) ExtMapBuffer1[i] = sum1 / sum2;
		else ExtMapBuffer1[i] = EMPTY_VALUE;
	
		if (ExtMapBuffer1[i] != EMPTY_VALUE)
		{
			ExtStdDevBuffer[i] = StdDev_Func(i, ExtMapBuffer1, N);
			/*if (DeviationBand1 > 0)
			{
				UpperDev1[i] = ExtMapBuffer1[i] + DeviationBand1 * ExtStdDevBuffer[i];
				LowerDev1[i] = ExtMapBuffer1[i] - DeviationBand1 * ExtStdDevBuffer[i]; 
			}  
			if (DeviationBand2 > 0)
			{
				UpperDev2[i] = ExtMapBuffer1[i] + DeviationBand2 * ExtStdDevBuffer[i];
				LowerDev2[i] = ExtMapBuffer1[i] - DeviationBand2 * ExtStdDevBuffer[i]; 
			} 
			if (DeviationBand3 > 0)
			{            
				UpperDev3[i] = ExtMapBuffer1[i] + DeviationBand3 * ExtStdDevBuffer[i];
				LowerDev3[i] = ExtMapBuffer1[i] - DeviationBand3 * ExtStdDevBuffer[i];            
			} */
		} 
	}
   
   
   //**********************************
   
   
   if (counted_bars < 0) return (-1);
   if (counted_bars > 0) counted_bars--;
   int intLimit = Bars - counted_bars;
        
   int intTrueShift, inx, jnx;
   double dblSum, dblNewRes, dblDeviation, dblCurrMA;

   for( inx = intLimit; inx >= 0; inx-- )
   {
      intTrueShift = inx + eintMAShift;
      dblSum = 0.0;
      dblCurrMA = iMA( Symbol(), Period(), eintBandsPeriod, 0, eintMAMode, eintMAPrice, intTrueShift );
      
      for ( jnx = intTrueShift + eintBandsPeriod - 1; jnx >= intTrueShift; jnx-- )
      {
         dblNewRes = Close[jnx] - dblCurrMA;
         dblSum += ( dblNewRes * dblNewRes );
      }
   
      dblDeviation = edblBandsDev * MathSqrt( dblSum / eintBandsPeriod );
      gadblMid[inx] = dblCurrMA;
      gadblUpper[inx] = dblCurrMA + dblDeviation;
      gadblLower[inx] = dblCurrMA - dblDeviation; 
      gadblDiv[inx] = 0.0;
      gadblDiv2[inx] = 0.0;
      
  
   }
 //+------------------------------------------------------------------+ 
 
   return( 0 );
}

   
double StdDev_Func(const int position, const double &MAprice[], int period)
{
	double StdDev_dTmp = 0, price = 0;
	for (int i = 0; i < period; i++)
	{
		switch(Price_Type)
		{
			case PRICE_CLOSE: 	price = Close[position + i]; break;
			case PRICE_OPEN: 		price = Open[position + i]; break;
			case PRICE_HIGH: 		price = High[position + i]; break;
			case PRICE_LOW: 		price = Low[position + i]; break;
			case PRICE_MEDIAN: 	price = (High[position + i] + Low[position + i]) / 2; break;
			case PRICE_TYPICAL: 	price = (High[position + i] + Low[position + i] + Close[position + i]) / 3; break;
			case PRICE_WEIGHTED: price = (High[position + i] + Low[position + i] + Close[position + i] + Close[position + i]) / 4; break;
		} 
		StdDev_dTmp += MathPow(price - MAprice[position], 2);
	}       
	StdDev_dTmp = MathSqrt(StdDev_dTmp / period);
	return(StdDev_dTmp);
}

