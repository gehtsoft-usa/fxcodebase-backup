//+------------------------------------------------------------------+
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window

#property indicator_buffers	3

#property indicator_color1	clrDodgerBlue
#property indicator_style1	STYLE_SOLID
#property indicator_width1	4

#property indicator_color2	clrRed
#property indicator_style2	STYLE_SOLID
#property indicator_width2	4

#property indicator_color3	clrDarkGray
#property indicator_style3	STYLE_SOLID
#property indicator_width3	4

extern int CCI_Period = 45;
extern int OB_Level   = 150;
extern int OS_Level   = -150;

double CCI_Trigger_Level = 0.0;

double TrendUp[];
double TrendDown[];
double TrendNeutral[];

int BarNumber;
int BarIndex;

int init() {
	SetIndexStyle ( 0, DRAW_HISTOGRAM );
	SetIndexBuffer( 0, TrendUp );
	
	SetIndexStyle ( 1, DRAW_HISTOGRAM );
	SetIndexBuffer( 1, TrendDown );
	
	SetIndexStyle ( 2, DRAW_HISTOGRAM );
	SetIndexBuffer( 2, TrendNeutral );
	
	return(0);
}
 
int deinit() {
	return(0);
}

int start() {
	BarNumber = IndicatorCounted();	// [0 .. Bars]
   
	for( BarIndex = Bars - BarNumber; BarIndex > 0; ) {
		BarIndex--;		// [Bars-1 .. 0]
		processBar();
		BarNumber++;
	}
   
	return(0);
}

void processBar() {
	double	cciNow;
	double	cciPrevious;
	bool	trendUp, trendDn;

	if( BarNumber == 0 ) // BarIndex == Bars-1
		return;

	cciNow		= iCCI( NULL, 0, CCI_Period, PRICE_TYPICAL, BarIndex	);
	cciPrevious	= iCCI( NULL, 0, CCI_Period, PRICE_TYPICAL, BarIndex+1	);
	
	if( cciNow > OB_Level ) // crossed up through the trigger level
		{
		trendUp = true;
		trendDn = false;
		}
	else
	if( cciNow < OS_Level ) // crossed down through the trigger level
		{
		trendUp = false;
		trendDn = true;
		}
	else	// trend did not change
		{
		//trendUp = (TrendUp[BarIndex+1] != 0);
		trendUp = false;
		trendDn = false;
		}

	if( trendUp ) {
		TrendUp[BarIndex] = 1;
		TrendDown[BarIndex] = 0;
		TrendNeutral[BarIndex] = 0;
	}
	else if (trendDn) {
		TrendDown[BarIndex] = 1;
		TrendUp[BarIndex] = 0;
		TrendNeutral[BarIndex] = 0;
	}
	else{
	   TrendDown[BarIndex] = 0;
		TrendUp[BarIndex] = 0;
		TrendNeutral[BarIndex] = 1;
	}
}

