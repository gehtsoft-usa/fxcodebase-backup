-- Id: 16937
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64046&p=108875#p108875

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Overbought/Oversold Indicator");
    indicator:description("Overbought/Oversold Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    local colour = core.colors();
    indicator.parameters:addGroup("OBOS Calculation");
    indicator.parameters:addInteger("OBOSPeriod", "Period", "", 9);
	
	
	 indicator.parameters:addGroup("Channel Calculation"); 
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("Method", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("Method", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("Method", "VAMA", "", "VAMA");


    indicator.parameters:addInteger("Period", "Period", "", 20);
	
	indicator.parameters:addInteger("DeviationPeriod", "Deviation Period", "", 20);
	indicator.parameters:addDouble("DeviationMultiplier", "Deviation Multiplier", "", 2);

	
	indicator.parameters:addGroup("Candle Style");
    indicator.parameters:addColor("UP_color", "Color of UP", "", colour.Lime);
    indicator.parameters:addColor("DN_color", "Color of DOWN", "", colour.Red);
    indicator.parameters:addColor("OBOS_color", "Color of Overbought/Oversold", "", colour.Blue);
	
	indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("ZL_color", "Zero line color", "", colour.Yellow);
    indicator.parameters:addColor("MID_color", "Mid line color", "", colour.Gray);

    indicator.parameters:addInteger("widthLinReg", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
	

	
	indicator.parameters:addGroup("Channel Style");
	indicator.parameters:addColor("TLC", "Top Line color", "", core.rgb(0, 200, 0));
	indicator.parameters:addColor("BLC", "Bottom Line Color", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("CLC", "Central Line Color", "", core.rgb(0, 0, 200));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local OBOSPeriod;

local first;
local FIRST;

local source = nil;
local AVERAGES, Method, Period;
-- Streams block
local open,low, high, close;
local MA={};
local BUFFER={};
local UP, DOWN;
local Top, Bottom, Central;
local DeviationPeriod, DeviationMultiplier;
-- Routine
function Prepare(nameOnly)
    OBOSPeriod = instance.parameters.OBOSPeriod;
	Method= instance.parameters.Method;
	Period= instance.parameters.Period;
	DeviationPeriod= instance.parameters.DeviationPeriod;
	DeviationMultiplier= instance.parameters.DeviationMultiplier;
    source = instance.source;
    FIRST = source:first();

    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);	

    if (not (nameOnly)) then
		BUFFER[1]= instance:addInternalStream(FIRST, 0);	
		BUFFER[2]= instance:addInternalStream(FIRST, 0);	
		BUFFER[3]= instance:addInternalStream(FIRST, 0);		 
		BUFFER[4]= instance:addInternalStream(FIRST, 0);			   
		BUFFER[5]= instance:addInternalStream(FIRST, 0);				
		BUFFER[6]= instance:addInternalStream(FIRST, 0);		 
		
		UP= instance:addInternalStream(FIRST, 0);
		DOWN= instance:addInternalStream(FIRST, 0);		  
		
		MA[1] = core.indicators:create("EMA", BUFFER[1],  OBOSPeriod);
		MA[2] = core.indicators:create("EMA", BUFFER[5],  OBOSPeriod);
		MA[3] = core.indicators:create("EMA",  BUFFER[6],  OBOSPeriod);
		MA[4] = core.indicators:create("EMA", UP,  OBOSPeriod);
		first = MA[4].DATA:first();
        open=instance:addStream("open", core.Line, name, "open", core.rgb(128, 128, 128), first);
    open:setPrecision(math.max(2, instance.source:getPrecision()));
		high=instance:addStream("high", core.Line, name, "high", core.rgb(128, 128, 128), first);
    high:setPrecision(math.max(2, instance.source:getPrecision()));
		low=instance:addStream("low", core.Line, name, "low", core.rgb(128, 128, 128), first);
    low:setPrecision(math.max(2, instance.source:getPrecision()));
		close=instance:addStream("close", core.Line, name, "close", core.rgb(128, 128, 128), first);
    close:setPrecision(math.max(2, instance.source:getPrecision()));
		instance:createCandleGroup("OBOS", "", open, high, low, close);
        mid=instance:addStream("MID", core.Line, name.."MID", "MID", instance.parameters.MID_color, first);
    mid:setPrecision(math.max(2, instance.source:getPrecision()));

    
        open:addLevel(0, instance.parameters.styleLinReg, instance.parameters.widthLinReg, instance.parameters.ZL_color);
       
 
		
		assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");
		AVERAGES = core.indicators:create("AVERAGES", mid,  Method,Period);
		
		
		Top=instance:addStream("Top", core.Line, name, "Top", instance.parameters.TLC, math.max(AVERAGES.DATA:first(), first +DeviationPeriod));
    Top:setPrecision(math.max(2, instance.source:getPrecision()));
		Bottom=instance:addStream("Bottom", core.Line, name, "Bottom", instance.parameters.BLC, math.max(AVERAGES.DATA:first(), first +DeviationPeriod));
    Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
		Central=instance:addStream("Central", core.Line, name, "Central", instance.parameters.CLC, math.max(AVERAGES.DATA:first(), first +DeviationPeriod));
    Central:setPrecision(math.max(2, instance.source:getPrecision()));
		
		Top:setWidth(instance.parameters.width);
        Top:setStyle(instance.parameters.style);
		Bottom:setWidth(instance.parameters.width);
        Bottom:setStyle(instance.parameters.style);
		Central:setWidth(instance.parameters.width);
        Central:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < FIRST or not source:hasData(period) then
        return;		
    end
	
    
	BUFFER[1][period]=(source.high[period]+source.low[period]+source.close[period]*2)/4;
	
  	
	MA[1]:update(mode);	
	BUFFER[3][period]= MA[1].DATA[period];
	
	if  period <  FIRST + OBOSPeriod  then
	return;
	end
	
	BUFFER[4][period] = mathex.stdev (BUFFER[1], period - OBOSPeriod, period);
	
		
	BUFFER[5][period] =  (BUFFER[1][period]  - BUFFER[3][period]) *100  / BUFFER[4][period];

	MA[2]:update(mode);
	BUFFER[6][period]= MA[2].DATA[period] ;

	MA[3]:update(mode);
	UP[period]=MA[3].DATA[period];

	MA[4]:update(mode);
	DOWN[period] =MA[4].DATA[period];
	
	if period < first then
	return;
	end

	open[period] = DOWN[period];
	close[period] = UP[period];
	high[period] = math.max(open[period], close[period]);
    low[period] = math.min(open[period], close[period]);
	
    if low[period-1] < low[period] and high[period]< high[period-1] then
        open:setColor(period, instance.parameters.OBOS_color);
	else
		if UP[period] > DOWN[period] then 
		open:setColor(period, instance.parameters.UP_color);
		else
		open:setColor(period, instance.parameters.DN_color);
		end
	end
	
	mid[period] = (high[period] + low[period])/2;
	
	
   	AVERAGES:update(mode);	
	
	if period < math.max(AVERAGES.DATA:first(), first + DeviationPeriod) then
	return;
	end
	
	local Deviation= mathex.stdev (mid, period-DeviationPeriod+1, period)*DeviationMultiplier;
	
	Central[period]= AVERAGES.DATA[period];	
	Top[period]= Central[period]+Deviation;
    Bottom[period]= Central[period]-Deviation;
	
end
