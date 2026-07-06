-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62160

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Tick Timed MACD");
    indicator:description("Tick Timed MACD");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation"); 

    indicator.parameters:addInteger("DurationOfFast", "Fast MA Duration in seconds", "Fast MA Duration in seconds", 60);
    indicator.parameters:addInteger("DurationOfSlow", "Slow MA Duration in seconds", "Slow MA Duration in seconds", 2500);
	indicator.parameters:addInteger("DurationOfSignal", "Signal MA Duration in seconds", "Signal MA Duration in seconds", 90);
	indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
	
	
    indicator.parameters:addGroup("Selector");	
    indicator.parameters:addBoolean("MACD", "Show MACD Line", "", true);	
    indicator.parameters:addBoolean("Signal", "Show Signal Line", "", true);	
    indicator.parameters:addBoolean("Histogram", "Show Histogram Bars", "", true);
	
	
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
local Signal;
local Histogram;
local calculateAvg;
local Second =(1/86400);
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
    DurationOfFast = instance.parameters.DurationOfFast*Second;
    DurationOfSlow = instance.parameters.DurationOfSlow*Second; 
	DurationOfSignal= instance.parameters.DurationOfSignal*Second;
    source = instance.source;
    first=source:first();
	
	local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    
    if ( nameOnly)  then
	return;
	end
        RawFast= instance:addInternalStream(0, 0);
        RawSlow= instance:addInternalStream(0, 0); 
		local precision = math.max(2, source:getPrecision());
		
		if instance.parameters.MACD then
        MACD = instance:addStream("MACD", core.Line, name .. ".MACD", "MACD", instance.parameters.Color, source:first());
		MACD:setWidth(instance.parameters.Width);
        MACD:setStyle(instance.parameters.Style);
		MACD:setPrecision(precision);
 		else
        MACD= instance:addInternalStream(0, 0); 		
		end		
		
		if instance.parameters.Signal then
		Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Color2, source:first());
		Signal:setWidth(instance.parameters.Width2);
        Signal:setStyle(instance.parameters.Style2)
		Signal:setPrecision(precision);
 		else
        Signal= instance:addInternalStream(0, 0); 		
		end		
		
		if instance.parameters.Histogram then
		Histogram = instance:addStream("Histogram", core.Bar, name .. ".Histogram", "Histogram", instance.parameters.Color3, source:first());
		Histogram:setPrecision(precision);
 		else
        Histogram= instance:addInternalStream(0, 0); 		
		end
		
		if instance.parameters.Method == "MVA" then
			calculateAvg = calculateMVA;
		elseif instance.parameters.Method == "EMA" then
			calculateAvg = calculateEMA;
		elseif instance.parameters.Method == "SMMA" then
			calculateAvg = calculateSMMA;
		end
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
  	if period <= first then
		return;
	end
 
	
		local P1= core.findDate (source, source:date(period)-DurationOfFast, false);
		local P2= core.findDate (source, source:date(period)-DurationOfSlow, false);
		local P3= core.findDate (source, source:date(period)-DurationOfSignal, false);
		
		if P1==-1 or P2==-1 or P3==-1 
		or P1< first or P2< first or P3< first
		then
			return;
		end
		
		RawFast[period] = calculateAvg(source, P1, period, RawFast);
		RawSlow[period] = calculateAvg(source, P2, period, RawSlow);
 
		MACD[period]= RawFast[period]-RawSlow[period];
		Signal[period]= mathex.avg(MACD,P3, period);
		Histogram[period]= MACD[period]-Signal[period];
	 
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+