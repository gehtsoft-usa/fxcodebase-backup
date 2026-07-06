-- Id: 2635
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2950

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+
function Init()
    indicator:name("McGinley Dynamic");
    indicator:description("McGinley Dynamic");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Frame", "Period", "", 9, 2, 2000);
	indicator.parameters:addInteger("Smoothing", "Smoothing", "", 125, 1, 2000);
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Style", " ", core.LINE_SOLID);
    indicator.parameters:addColor("MCGD_color", "Line Color", "", core.rgb(255, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;
local Smoothing;

local first;
local source = nil;

-- Streams block
local MCGD = nil;
local EMA;

-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.Frame;
	Smoothing= instance.parameters.Smoothing;
    source = instance.source;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	EMA = core.indicators:create("EMA", source, Frame);
	
	 first = EMA.DATA:first();
    MCGD = instance:addStream("MCGD", core.Line, name, "MCGD", instance.parameters.MCGD_color, first);
	MCGD:setWidth(instance.parameters.width);
	MCGD:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	
	   EMA:update(mode); 	    	   
	  
        MCGD[period] = EMA.DATA[period-1] +(source[period]- EMA.DATA[period-1]) /(source[period] / EMA.DATA[period-1]*Smoothing);
    
end

