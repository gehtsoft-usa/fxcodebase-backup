-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7174
-- Id: 4754

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
    indicator:name("Difference");
    indicator:description("No description");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Method", "Method", "", "High");
    indicator.parameters:addStringAlternative("Method", "High/Low", "", "High");
    indicator.parameters:addStringAlternative("Method", "Open/Close", "", "Close");
	
	  indicator.parameters:addBoolean("Use", "Use MVA Smoothing", "", true); 
	
	indicator.parameters:addInteger("PERIOD", "MVA Period", "", 20, 2, 1000);
     indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Out", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down_color", "Color of Down", "Color of Out", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local PERIOD;
local MVA;
local DATA;
local Method;
local Use;

-- Streams block
local Out = nil;

-- Routine
function Prepare(nameOnly)
    Use = instance.parameters.Use;
    Method = instance.parameters.Method;  
    PERIOD = instance.parameters.PERIOD;
    source = instance.source;
	

    local name = profile:id() .. "(" .. source:name().. ", " .. PERIOD .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	DATA = instance:addInternalStream(0, 0);
	
	 MVA = core.indicators:create("MVA", DATA, PERIOD);
	
    first = MVA.DATA:first();
    Out = instance:addStream("Out", core.Bar, name, "Out", instance.parameters.Up_color, first);
	
	Out:setPrecision(math.max(2, instance.source:getPrecision()));
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
     if Method == "High" then
     DATA[period]= source.high[period] - source.low[period];
	 elseif Method == "Close" then
     DATA[period]= source.close[period] - source.open[period];
	 end

    if period < first or not source:hasData(period) then
	return;
	end
	
	
	
	if Use then
	 MVA:update(mode);
	
     Out[period] =  MVA.DATA[period];
	 else
	 Out[period]= DATA[period];
	 end
	 
	 if  Out[period] > Out[period-1] then
	Out:setColor(period, instance.parameters.Up_color);
	 else
	Out:setColor(period, instance.parameters.Down_color);
	 end
	 
end

