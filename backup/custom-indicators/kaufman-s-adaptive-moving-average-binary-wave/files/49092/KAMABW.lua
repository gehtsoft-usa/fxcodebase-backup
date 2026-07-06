-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27977
-- Id: 8232

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Kaufman�s Adaptive Moving Average Binary Wave");
    indicator:description("Kaufman�s Adaptive Moving Average Binary Wave");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
     indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Period", "Period", "Period", 20);
    indicator.parameters:addDouble("FilterPercent", "Filter Percent", "Filter Percent", 10);
	indicator.parameters:addGroup("Style");	

    indicator.parameters:addColor("KAMABW_color", "Color of KAMABW", "Color of KAMABW", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local FilterPercent;

local first;
local source = nil;
local diff;
-- Streams block
local KAMABW = nil;
local ama;
local  amaLow,amaHigh,Raw;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    FilterPercent = instance.parameters.FilterPercent;
    source = instance.source;
    first = source:first() +1;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(FilterPercent) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
	
		diff= instance:addInternalStream(0, 0);
		ama= instance:addInternalStream(0, 0);
		amaLow= instance:addInternalStream(0, 0);
		amaHigh= instance:addInternalStream(0, 0);
		Raw= instance:addInternalStream(0, 0);
        KAMABW = instance:addStream("KAMABW", core.Line, name, "KAMABW", instance.parameters.KAMABW_color, first+Period+1 +Period);
    KAMABW:setPrecision(math.max(2, instance.source:getPrecision()));
		KAMABW:setWidth(instance.parameters.width);
        KAMABW:setStyle(instance.parameters.style);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    
    

    if period < first   then
	return;
	end
	
	
	diff[period] = math.abs(source[period] - source[period-1]);
	
	if period < first+Period   then
	return;
	end
	
	local signal = math.abs(source[period] - source[period-Period]);
	local noise = mathex.sum (diff,period-Period+1, period);
    local efRatio = signal / noise;
    local fastSC = 0.6022;
    local slowSC = 0.0645;
	local smooth = math.pow (efRatio * fastSC + slowSC, 2);
	
 -- ama[period] = compoundValue(period, "visible data" = ama[1] + smooth * (price - ama[1]), "historical data" = price);
 
 
    if period < first+Period+1   then
	return;
	end
	
   ama[period]=  ama[period-1] + smooth * (source[period] - ama[period-1]);   
   Raw[period]= ama[period] - ama[period-1]
   
    if period < first+Period+1 +Period  then
	return;
	end
  
local filter = FilterPercent/100 * mathex.stdev( Raw, period-Period+1, period);

	 if ama[period] < ama[period-1] then
	amaLow[period] =  ama[period]
	else 
	amaLow[period]= amaLow[period-1];
	end

	  if ama[period] > ama[period-1] then
	  amaHigh[period] =ama[period]
	  else
	  amaHigh[period]= amaHigh[period-1];
	  end


if ama[period] - amaLow[period] > filter then
 KAMABW[period]=1;
elseif amaHigh[period] - ama[period] > filter then
 KAMABW[period]=-1; 
else
  KAMABW[period]=0;
end

 
end

