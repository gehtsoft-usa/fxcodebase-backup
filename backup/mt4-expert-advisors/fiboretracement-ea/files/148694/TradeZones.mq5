// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=148722

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 MidnightBlue
#property indicator_color2 FireBrick
#property strict

input int   Fib_Period      = 240;
input bool  Show_StartLine  = false;
input bool  Show_EndLine    = false;
input bool  Show_Channel    = false;
input int   Fib_Style       = 5;
input color Fib_Color       = Gold;
input color StartLine_Color = RoyalBlue;
input color EndLine_Color   = FireBrick;
input color BuyZone_Color   = MidnightBlue;
input color SellZone_Color  = FireBrick;

//---- buffers
double WWBuffer1[];
double WWBuffer2[];

double level_array[10]     = {0, 0.236, 0.382, 0.5, 0.618, 0.764, 1, 1.618, 2.618, 4.236};
string leveldesc_array[13] = {"0", "23.6%", "38.2%", "50%", "61.8%", "76.4%", "100%", "161.8%", "261.80%", "423.6%"};

int    level_count;
string level_name;
string StartLine = "Start Line";
string EndLine   = "End Line";

void OnInit()
{

    // SetIndexStyle(0, DRAW_LINE, 1);
    // SetIndexStyle(1, DRAW_LINE, 1);

    // SetIndexLabel(0, "High");
    // SetIndexLabel(1, "Low");

	
  SetIndexBuffer(0, WWBuffer1, INDICATOR_CALCULATIONS);
  SetIndexBuffer(1, WWBuffer2, INDICATOR_CALCULATIONS);
  
	if (Show_Channel) {
	PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE); 
	PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE); 

  }
  // IndicatorDigits(Digits + 2);
  // IndicatorShortName("AutoFib TradeZones");

  datetime tm = iTime(NULL, 0, 0);
  double   hi = iHigh(NULL, 0, 0);
  double   lo = iLow(NULL, 0, 0);

  ObjectCreate(0, "FibLevels", OBJ_FIBO, 0, tm, hi, tm, lo);
  ObjectCreate(0, "BuyZone", OBJ_RECTANGLE, 0, 0, 0, 0);  
	ObjectSetInteger(0, "BuyZone",OBJPROP_FILL,true); 

  ObjectCreate(0, "SellZone", OBJ_RECTANGLE, 0, 0, 0, 0);
	ObjectSetInteger(0, "SellZone",OBJPROP_FILL,true); 

  if (Show_StartLine) {
    if (ObjectFind(0, StartLine) == -1) {
      ObjectCreate(0, StartLine, OBJ_VLINE, 0, iTime(NULL, 0, Fib_Period), iClose(NULL, 0, 0) );
      ObjectSetInteger(0, StartLine, OBJPROP_COLOR, StartLine_Color);
    }
  }
  if (Show_EndLine) 
	{
    if (ObjectFind(0, EndLine) == -1) {
      ObjectCreate(0, EndLine, OBJ_VLINE, 0, iTime(NULL, 0, 0), iClose(NULL, 0, 0) );
      ObjectSetInteger(0, EndLine, OBJPROP_COLOR, EndLine_Color);
    }
  }


  // return (0);
}

void OnDeinit(const int reason)
{
  ObjectDelete(0, "FibLevels");
  ObjectDelete(0, "BuyZone");
  ObjectDelete(0, "SellZone");
}

int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{

  // Start Line -------------------------------------------
  int BarShift;
  if (Show_StartLine) 
	{
    datetime HLineTime = ObjectGetInteger(0, StartLine, OBJPROP_TIME);

    if (HLineTime >= iTime(NULL, 0, 0)) { BarShift = 0; }
    
		BarShift = iBarShift(NULL, 0, HLineTime);
  
	} else if (!Show_StartLine) { BarShift = 0; }
	
  if (ObjectFind(0, StartLine) == -1) { BarShift = 0; }


  // End Line -------------------------------------------
  int BarShift2;
  if (Show_EndLine) 
	{
    datetime HLine2Time = ObjectGetInteger(0, EndLine, OBJPROP_TIME);

  	// if (HLine2Time >= time[0] ) { BarShift2 = 0; }
  	if (HLine2Time >= iTime(NULL, 0, 0) ) { BarShift2 = 0; }

    BarShift2 = iBarShift(NULL, 0, HLine2Time);
  
	} else if (!Show_EndLine) { BarShift2 = 0; }

  if (ObjectFind(0, EndLine) == -1) { BarShift2 = 0; }
  // if (ObjectFind(0, EndLine) == -1) { BarShift2 = iBars(NULL, 0); }
  
	//----------------------------------------------------------

  double SellZoneHigh, BuyZoneLow;
  
	if (Show_StartLine) 
	{
    // SellZoneHigh = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, BarShift - BarShift2, BarShift2 + 1));
    // BuyZoneLow   = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, BarShift - BarShift2, BarShift2 + 1));
    SellZoneHigh = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, Fib_Period, 1));
    BuyZoneLow   = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, Fib_Period, 1));
  }
  
	if (!Show_StartLine) 
	{
    SellZoneHigh = iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, Fib_Period, 1));		
    BuyZoneLow   = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, Fib_Period, 1));
  }
  
	
	double   PriceRange    = SellZoneHigh - BuyZoneLow;
  double   BuyZoneHigh   = BuyZoneLow + (0.236 * PriceRange);
  double   SellZoneLow   = SellZoneHigh - (0.236 * PriceRange);
  // datetime StartZoneTime = time[Fib_Period];

  datetime StartZoneTime = iTime(NULL, 0, Fib_Period);
	
	// Print(__FUNCTION__," StartZoneTime: ",StartZoneTime);

  // datetime EndZoneTime   = time[0] + time[0];
  datetime EndZoneTime   = iTime(NULL, 0, 0);

  level_count = ArraySize(level_array);

  // int counted_bars = IndicatorCounted();
  
	//--- original:
	// int counted_bars = prev_calculated;
  // int limit, i;

  // if (counted_bars > 0) counted_bars--;
  // limit = iBars(NULL, 0) - counted_bars;

  // for (i = limit - 1; i >= 0; i--) {
  //--- 

	int start;
  int fib_Period = iBars(NULL, 0) - Fib_Period;
  if (prev_calculated > 1) start = prev_calculated - 1; else { start = fib_Period - 1; }

  for (int i = start; i < rates_total && !IsStopped(); i++) 
	{
    WWBuffer1[i] = getPeriodHigh(Fib_Period, i);
    WWBuffer2[i] = getPeriodLow(Fib_Period, i);
		
		// Print(__FUNCTION__,"     WWBuffer1: ",    WWBuffer1[i]);
		// Print(__FUNCTION__,"     WWBuffer2: ",    WWBuffer2[i]);

    if (Show_StartLine) 
		{
      // ObjectSetInteger(0,"FibLevels", OBJPROP_TIME, 1, time[BarShift]);
      // ObjectSetInteger(0,"FibLevels", OBJPROP_TIME, 2, time[BarShift2]);
      
			ObjectSetInteger(0,"FibLevels", OBJPROP_TIME, 0, iTime(NULL, 0, BarShift));
      ObjectSetInteger(0,"FibLevels", OBJPROP_TIME, 1, iTime(NULL, 0, BarShift2));
    }
    
		if (!Show_StartLine) 
		{ ObjectSetInteger(0, "FibLevels", OBJPROP_TIME, 0, StartZoneTime); }
    	ObjectSetInteger(0, "FibLevels", OBJPROP_TIME, 1, iTime(NULL, 0, 0));
    
		// ObjectSetInteger(0, "FibLevels", OBJPROP_TIME, 2, time[0]);
    
		// if (open[Fib_Period] < open[0])  // Up
		
		if ( iOpen(NULL, 0, Fib_Period) < iOpen(NULL, 0, 0) )  // Up
    {
      if (Show_StartLine) 
			{
        ObjectSetDouble(0,"FibLevels", OBJPROP_PRICE,0, SellZoneHigh);
        ObjectSetDouble(0,"FibLevels", OBJPROP_PRICE,1, BuyZoneLow);
      }
      if (!Show_StartLine) 
			{
        ObjectSetDouble(0, "FibLevels", OBJPROP_PRICE,0, getPeriodHigh(Fib_Period, i));
        ObjectSetDouble(0, "FibLevels", OBJPROP_PRICE,1, getPeriodLow(Fib_Period, i));
      }
    
		} else {
      if (Show_StartLine) 
			{
        ObjectSetDouble(0, "FibLevels", OBJPROP_PRICE,0, BuyZoneLow);
        ObjectSetDouble(0, "FibLevels", OBJPROP_PRICE,1, SellZoneHigh);
      }
      if (!Show_StartLine) 
			{
        ObjectSetDouble(0, "FibLevels", OBJPROP_PRICE,0, getPeriodLow(Fib_Period, i));
        ObjectSetDouble(0, "FibLevels", OBJPROP_PRICE,1, getPeriodHigh(Fib_Period, i));
      }
    }

    ObjectSetInteger(0, "FibLevels", OBJPROP_LEVELCOLOR, Fib_Color);
    ObjectSetInteger(0, "FibLevels", OBJPROP_STYLE, Fib_Style);
    ObjectSetInteger(0, "FibLevels", OBJPROP_LEVELS, level_count);
    
		for (int j = 0; j < level_count; j++) {
      // ObjectSet("FibLevels", OBJPROP_FIRSTLEVEL + j, level_array[j]);
      // ObjectSetFiboDescription("FibLevels", j, leveldesc_array[j]);

      ObjectSetDouble(0, "FibLevels", OBJPROP_LEVELVALUE, j, level_array[j]);
      ObjectSetString(0, "FibLevels", OBJPROP_LEVELTEXT, j, leveldesc_array[j]);
    }

    if (Show_StartLine) {
      // ObjectSetInteger(0, "BuyZone", OBJPROP_TIME,2, time[BarShift]);
      // ObjectSetInteger(0, "BuyZone", OBJPROP_TIME,1, time[BarShift2]);
      ObjectSetInteger(0, "BuyZone", OBJPROP_TIME,1, iTime(NULL, 0, BarShift));
      ObjectSetInteger(0, "BuyZone", OBJPROP_TIME,0, iTime(NULL, 0, BarShift2));
    }

    if (!Show_StartLine) { ObjectSetInteger(0, "BuyZone", OBJPROP_TIME, 0, StartZoneTime); }
    ObjectSetInteger(0, "BuyZone", OBJPROP_TIME, 1, EndZoneTime);
    ObjectSetDouble(0, "BuyZone", OBJPROP_PRICE, 0, BuyZoneLow);
    ObjectSetDouble(0, "BuyZone", OBJPROP_PRICE, 1, BuyZoneHigh);
    ObjectSetInteger(0, "BuyZone", OBJPROP_COLOR, BuyZone_Color);

    if (Show_StartLine) 
		{
      // ObjectSetInteger(0, "SellZone", OBJPROP_TIME,2, time[BarShift]);
      // ObjectSetInteger(0, "SellZone", OBJPROP_TIME,1, time[BarShift2]);
      ObjectSetInteger(0, "SellZone", OBJPROP_TIME, 1, iTime(NULL, 0, BarShift)  );
      ObjectSetInteger(0, "SellZone", OBJPROP_TIME, 0, iTime(NULL, 0, BarShift2) );
    }
    
		if (!Show_StartLine) { ObjectSetInteger(0, "SellZone", OBJPROP_TIME, 0, StartZoneTime); }
    ObjectSetInteger(0, "SellZone", OBJPROP_TIME, 1, EndZoneTime);
    ObjectSetDouble(0, "SellZone", OBJPROP_PRICE, 0, SellZoneLow);
    ObjectSetDouble(0, "SellZone", OBJPROP_PRICE, 1, SellZoneHigh);
    ObjectSetInteger(0, "SellZone", OBJPROP_COLOR, SellZone_Color);
  }
  // return (0);
  // return prev_calculated;
  return rates_total;
}

double getPeriodHigh(int period, int pos)
{
  // double buffer = 0;
	return iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, Fib_Period, 0));

	// for (int i = pos; i < pos + period; i++) 
	// {
  //   double hi = iHigh(NULL,0, iBars(NULL, 0)- i);
  //   double op = iOpen(NULL, 0, iBars(NULL, 0)- i);
  //   double cl = iClose(NULL, 0, iBars(NULL, 0)- i);

  //   if (hi > buffer) { buffer = hi; } 
	// 	else {
  //     if (op > cl)  
  //     {
  //       if (op > buffer) { buffer = op; }
  //     }
  //   }
  // }
  // return (buffer);
}

double getPeriodLow(int period, int pos)
{
  // int    i;
  // double buffer = 100000;

  // buffer = iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, period, pos));
  return iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, Fib_Period, 0));

  // for (i = pos; i < pos + period; i++) 
	// {
	// 	Print(__FUNCTION__," i: ",i);
		
  //   int j = iBars(NULL, 0) - i;
    
	// 	double op = iOpen(NULL, 0, j);
	// 	Print(__FUNCTION__," op: ",op);
	// 	double lo = iLow(NULL,0, j);
	// 	Print(__FUNCTION__," lo: ",lo);
  //   double cl = iClose(NULL, 0, j);
	// 	Print(__FUNCTION__," cl: ",cl);
    
	// 	if (lo < buffer) { buffer = lo; } 
    
	// 	if (op > cl && cl < buffer) { buffer = cl; }
		
	// 	if (cl < op && op < buffer){ buffer = op; }
    
  // }
  // return (buffer);
}



//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

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