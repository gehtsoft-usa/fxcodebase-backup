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
    indicator:name("Timed MACD");
    indicator:description("Timed MACD");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
	
	indicator.parameters:addString("Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price", "WEIGHTED", "", "weighted");	

    indicator.parameters:addInteger("DurationOfFast", "Fast MA Duration in seconds", "Fast MA Duration in seconds", 60);
    indicator.parameters:addInteger("DurationOfSlow", "Slow MA Duration in seconds", "Slow MA Duration in seconds", 2500);
	indicator.parameters:addInteger("DurationOfSignal", "Signal MA Duration in seconds", "Signal MA Duration in seconds", 90);
	indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color", "Color of MACD", "Color of MACD", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Color2", "Color of Signal", "Color of Siganal", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("Width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("Style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("Style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("Color3", "Color of Histogram", "Color of Histogram", core.rgb(0, 0, 255));

 
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
local DurationOfFast;
local DurationOfSlow;
local DurationOfSignal;

local PeriodOfFast;
local PeriodonOfSlow;
local PeriodonOfSignal;
local MACD;
local BarSize;
local Price;
local Signal;
local Histogram;
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
	DurationOfSignal= instance.parameters.DurationOfSignal;
	Price= instance.parameters.Price;
    source = instance.source;
    first=source:first();
	
	local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(), core.now(), 0, 0);
	
    BarSize= math.floor((e1 - s1)*86400+0.5); 
	
	
	PeriodOfFast =BarSize / DurationOfFast  ;
    PeriodOfSlow=BarSize / DurationOfSlow  ;
	PeriodOfSignal=BarSize / DurationOfSignal  ;
	
	core.host:execute ("setStatus", "Fast :" .. win32.formatNumber(PeriodOfFast, false, 2)  .. " Slow :" ..win32.formatNumber(PeriodOfSlow, false, 2) .. " Signal :" ..win32.formatNumber(PeriodOfSignal, false, 2) )
	--core.host:execute ("setStatus", tostring( BarSize)  )
	if   DurationOfFast <BarSize then
	 error( "The chosen Fast MA Duration must be equal to or bigger than "..BarSize  );
	end
	if   DurationOfSlow <BarSize then
     error( "The chosen Slow MA Duration must be equal to or bigger than " ..BarSize);
	 end
	 
	if   DurationOfSignal <BarSize then
     error( "The chosen Slow MA Duration must be equal to or bigger than " ..BarSize);
	 end

	 
    local name = profile:id() .. "(" .. source:name().. ", " .. tostring(Price) .. ", " .. tostring(DurationOfFast) .. ", " .. tostring(DurationOfSlow) .. ", " .. tostring(DurationOfSignal).. ")";
    instance:name(name);
	
	
 
    
    if (not (nameOnly)) then
        RawFast= instance:addInternalStream(0, 0);
        RawSlow= instance:addInternalStream(0, 0); 
		local precision = math.max(2, source:getPrecision());
        MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.Color, source:first());
		MACD:setWidth(instance.parameters.Width);
        MACD:setStyle(instance.parameters.Style);
		MACD:setPrecision(precision);
		
		Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Color2, source:first());
		Signal:setWidth(instance.parameters.Width2);
        Signal:setStyle(instance.parameters.Style2)
		Signal:setPrecision(precision);
		
		Histogram = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.Color3, source:first());
		Histogram:setPrecision(precision);
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
	local P1= core.findDate (source, source:date(period)-PeriodOfFast, false);
	local P2= core.findDate (source, source:date(period)-PeriodOfSlow, false);
	local P3= core.findDate (source, source:date(period)-PeriodOfSignal, false);
	
	if P1==-1 or P2==-1  or P3==-1 
	or P1< first or P2< first  or P3< first
    then
		return;
    end
	
	RawFast[period] = calculateAvg(source[Price], P1, period, RawFast);
	RawSlow[period] = calculateAvg(source[Price], P2, period, RawSlow);

	MACD[period]= RawFast[period]-RawSlow[period];
	Signal[period]= mathex.avg(MACD,P3, period);
	Histogram[period]= MACD[period]-Signal[period];
end
 