//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74818

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window

#property indicator_color1 Green
#property indicator_color2 Yellow
#property indicator_color3 Purple
#property indicator_color4 Brown
#property indicator_color5 Blue

#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID

int line_width = 2;

#define PERIODS_NUMBER 5
#define INDICATOR_NAME "Fractal Support Resistance"
#define SUPPORT "support"
#define RESISTANCE "resistance"
#define BAR_TO_START_SCAN_FROM 2

int timeframes[PERIODS_NUMBER] = {PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1};
int styles[PERIODS_NUMBER] = {indicator_style1, indicator_style2, indicator_style3, indicator_style4, indicator_style5};
color colors[PERIODS_NUMBER] = {indicator_color1, indicator_color2, indicator_color3, indicator_color4, indicator_color5};

int init() {
	IndicatorShortName(INDICATOR_NAME);
	return(0);
}

int deinit() {
	string object_types[2] = {SUPPORT, RESISTANCE};
	
	for(int timeframe_index = 0; timeframe_index < ArraySize(timeframes); timeframe_index++)
		for(int object_type_index = 0; object_type_index < ArraySize(object_types); object_type_index++)
			ObjectDelete(getTrendLineName(object_types[object_type_index], timeframes[timeframe_index]));
			
	return(0);
}

int start() {
	for(int timeframe_index = 0; timeframe_index < ArraySize(timeframes); timeframe_index++) {
		if(Period() <= timeframes[timeframe_index]) {
			drawResistance(getUpperFractalBar(timeframes[timeframe_index], BAR_TO_START_SCAN_FROM), timeframe_index);
			drawSupport(getLowerFractalBar(timeframes[timeframe_index], BAR_TO_START_SCAN_FROM), timeframe_index);
		}
	}
	return(0);
}

int getUpperFractalBar(int timeframe, int starting_bar) {
	for(int bar = starting_bar; bar < Bars; bar++)
		if(isUpperFractal(timeframe, bar)) return(bar);
	return (-1);
}

bool isUpperFractal(int timeframe, int bar) {
	for(int offset = -2; offset <= 2; offset++)
		if( (offset != 0) && (iHigh(Symbol(), timeframe, bar + offset) > iHigh(Symbol(), timeframe, bar)) ) return(false);
	return (true);
}

int getLowerFractalBar(int timeframe, int starting_bar) {
	for(int bar = starting_bar; bar < Bars; bar++)
		if(isLowerFractal(timeframe, bar)) return(bar);
	return (-1);
}

bool isLowerFractal(int timeframe, int bar) {
	for(int offset = -2; offset <= 2; offset++)
		if( (offset != 0) && (iLow(Symbol(), timeframe, bar + offset) < iLow(Symbol(), timeframe, bar)) ) return(false);
	return (true);
}

void drawResistance(int bar_index, int timeframe_index) {
	if(bar_index > 0) drawTrendLine(getTrendLineName(RESISTANCE, timeframes[timeframe_index]), iHigh(Symbol(), timeframes[timeframe_index], bar_index), colors[timeframe_index], styles[timeframe_index]);
}

void drawSupport(int bar_index, int timeframe_index) {
	if(bar_index > 0) drawTrendLine(getTrendLineName(SUPPORT, timeframes[timeframe_index]), iLow(Symbol(), timeframes[timeframe_index], bar_index), colors[timeframe_index], styles[timeframe_index]);
}

void drawTrendLine(string object_name, double price, color line_color, int line_style) {
	ObjectDelete(object_name);
	ObjectCreate(object_name, OBJ_HLINE, 0, Time[0], price, Time[Bars - 1], price);
	ObjectSet(object_name, OBJPROP_COLOR, line_color);
	ObjectSet(object_name, OBJPROP_STYLE, line_style);
	ObjectSet(object_name, OBJPROP_WIDTH, line_width);
}

string getTrendLineName(string object_type, int timeframe) {
	return(object_type + getTimeframeName(timeframe));
}

string getTimeframeName(int timeframe) {
	static int timeframe_periods[] = {PERIOD_M1, PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1};
	static string timeframe_names[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN1"};
	
	for(int i = 0; i < ArraySize(timeframe_periods); i++)
		if(timeframe == timeframe_periods[i]) return (timeframe_names[i]);

	return("Unknown");
}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 