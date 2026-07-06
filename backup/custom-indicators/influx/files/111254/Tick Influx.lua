-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62160

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Tick Influx");
    indicator:description("Tick Influx");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("DurationOfFast", "Fast MA Duration in seconds", "Fast MA Duration in seconds", 60);
    indicator.parameters:addInteger("DurationOfSlow", "Slow MA Duration in seconds", "Slow MA Duration in seconds", 2500);
	indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Color of MACD", "Color of MACD", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local first;
local source = nil;

-- Streams block
local RawFast = nil;
local RawSlow = nil;
local Fast = nil;
local Slow = nil;
local DurationOfFast;
local DurationOfSlow;

local PeriodOfFast;
local PeriodonOfSlow;
local MACD;
local BarSize;
local calculateAvg;

function calculateMVA(source, p, period, result)
	return mathex.avg(source, p, period);
end

function calculateEMA(source, p, period, result)
	local n = period - p;
	if period <= n then
        return source[period];
    else
		local k = 2.0 / (n + 1.0);
        return (1 - k) * result[period - 1] + k * source[period];
    end
end

function calculateSMMA(source, p, period, result)
	local n = period - p;
	if period <= n then
        return mathex.avg(source, p, period);
    else
        return (result[period - 1] * n + source[period]) / (n + 1);
    end
end
 
-- Routine
function Prepare(nameOnly)
    DurationOfFast = instance.parameters.DurationOfFast;
    DurationOfSlow = instance.parameters.DurationOfSlow; 
    source = instance.source;
    first=source:first();

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	 
    if (not (nameOnly)) then
	    local precision = math.max(2, source:getPrecision());
        RawFast= instance:addInternalStream(0, 0);
        RawSlow= instance:addInternalStream(0, 0);
		Fast= instance:addInternalStream(0, 0);
        Slow= instance:addInternalStream(0, 0);
        MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.Color, source:first());
		MACD:setWidth(instance.parameters.Width);
        MACD:setStyle(instance.parameters.Style);
		MACD:setPrecision(precision);
		MACD:setPrecision (source:getPrecision());
		if instance.parameters.Method == "MVA" then
			calculateAvg = calculateMVA;
		elseif instance.parameters.Method == "EMA" then
			calculateAvg = calculateEMA;
		elseif instance.parameters.Method == "SMMA" then
			calculateAvg = calculateSMMA;
		end
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
	if period <= first then
		return;
	end
	
	if period == first+1 then
		local s1, e1, s2, e2;
		s1 = source:date(period-1);
		e1 = source:date(period);	
		BarSize= math.floor((e1 - s1)*86400+0.5); 
	
		PeriodOfFast =BarSize / DurationOfFast  ;
		PeriodOfSlow=BarSize / DurationOfSlow  ;
		
		core.host:execute ("setStatus", "Fast :" .. win32.formatNumber(PeriodOfFast, false, 2)  .. " Slow :" ..win32.formatNumber(PeriodOfSlow, false, 2)  )
		 
		if   DurationOfFast <BarSize then
			error( "The chosen Fast MA Duration must be equal to or bigger than "..BarSize  );
		end
		if   DurationOfSlow <BarSize then 
			error( "The chosen Slow MA Duration must be equal to or bigger than " ..BarSize);
		end
	end
	 
	local P1= core.findDate (source, source:date(period)-PeriodOfFast, false);
	local P2= core.findDate (source, source:date(period)-PeriodOfSlow, false);
	
	if P1==-1 or P2==-1 
	or P1< first+1 or P2< first+1
	or P1>= period
	or P2>= period
    then
		return;
    end

	RawFast[period] = calculateAvg(source, P1, period, RawFast);
	RawSlow[period] = calculateAvg(source, P2, period, RawSlow);

	local FastMA,SlowMA;
	FastMA= mathex.avg(RawFast,P1, period);
	SlowMA=  mathex.avg( RawSlow, P2, period);

	Fast[period]= RawFast[period] + RawFast[period] - FastMA;
	Slow[period]= RawSlow[period] + RawSlow[period] - SlowMA;
	MACD[period]= Fast[period]-Slow[period];
end
 