// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69871

// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property	copyright		"Copyright © 2020, Gehtsoft USA LLC"
#property	link				"http://fxcodebase.com"
#property	version			"1.00"
#property	strict
#property	indicator_separate_window

#property	indicator_buffers	1
#property	indicator_plots		1

enum	ENUM_LINE_WIDTH
{
	Width_1 = 1,	//1
	Width_2 = 2,	//2
	Width_3 = 3,	//3
	Width_4 = 4,	//4
	Width_5 = 5		//5
};

//--- input parameters
input	int							Length = 20;
input	ENUM_LINE_STYLE	LineStyle = STYLE_SOLID;
input	ENUM_LINE_WIDTH	LineWidth = Width_1;
input	color						LineColor = clrRed;

//--- buffers
double	Out[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int	OnInit()
{
	//--- indicator buffers mapping
	IndicatorSetInteger(INDICATOR_DIGITS, Digits());
	
	//PlotIndexSetInteger(0, PLOT_SHIFT, 0);
	//PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, 0);
	SetIndexBuffer(0, Out);
	PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
	PlotIndexSetInteger(0, PLOT_LINE_STYLE, LineStyle);
	PlotIndexSetInteger(0, PLOT_LINE_WIDTH, LineWidth);
	PlotIndexSetInteger(0, PLOT_LINE_COLOR, LineColor);
	PlotIndexSetString(0, PLOT_LABEL, "Out");
	
	//---
	return	(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int	OnCalculate(const	int				rates_total,
								const	int				prev_calculated,
								const	datetime	&time[],
								const	double		&open[],
								const	double		&high[],
								const	double		&low[],
								const	double		&close[],
								const	long			&tick_volume[],
								const	long			&volume[],
								const	int				&spread[])
{
	//---
	int	limit = MathMax(Length - 1, prev_calculated - 1);
	
	for (int i = limit; i < rates_total; i++)
	{
		double	Sx = 0;
		double	Sy = 0;
		double	Sxx = 0;
		double	Sxy = 0;
		double	Syy = 0;
		
		for (int cnt = 0; cnt < Length; cnt++)
		{
			double	X = close[i - cnt];
			double	Y = -cnt;
			
			Sx	+= X;
			Sy	+= Y;
			Sxx	+= X * X;
			Sxy	+= X * Y;
			Syy	+= Y * Y;
		}
		
		double	Nom = Length * Sxy - Sx * Sy;
		double	Denom = MathSqrt(Length * Sxx - Sx * Sx) * (Length * Syy - Sy * Sy);
		
		if (Denom == 0 || !MathIsValidNumber(Denom))
		{
			Out[i]	= 0;
		}
		else
		{
			Out[i]	= Nom / Denom;
		}
	}
	
	//--- return value of prev_calculated for next call
	return	(rates_total);
}
//+------------------------------------------------------------------+
