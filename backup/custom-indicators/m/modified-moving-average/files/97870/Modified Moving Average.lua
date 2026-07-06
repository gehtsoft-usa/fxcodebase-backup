-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61639

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
    indicator:name("Modified Moving Average");
    indicator:description("Modified Moving Average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Length", "Period", "Period", 5);
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MMA_color", "Color of MMA", "Color of MMA", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Length;

local first;
local source = nil;

-- Streams block
local MMA = nil;
local SMA;
-- Routine
function Prepare(nameOnly)
    Length = instance.parameters.Length;
    source = instance.source;
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Length) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	SMA=core.indicators:create("MVA", source, Period);
    first = SMA.DATA:first();

 
        MMA = instance:addStream("MMA", core.Line, name, "MMA", instance.parameters.MMA_color, first);
		MMA:setWidth(instance.parameters.width);
        MMA:setStyle(instance.parameters.style);
    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

    SMA:update(mode);
	
    if period <  first or not  source:hasData(period) then
	return;
	end
	
	local Slope = 0;
     for  value1 = 1 , Length, 1 do
     Factor = 1 + (2 * (value1 - 1));
     Slope = Slope + (source[period-(value1 - 1)] * ((Length - Factor)/2));
     end

        MMA[period] =  SMA.DATA[period] + (6 * Slope) / ((Length + 1) * Length);
     
end

