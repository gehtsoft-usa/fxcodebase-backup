-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=858

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
    indicator:name("ATR Channel");
    indicator:description("ATR Channel");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P1", "ATR Period", "ATR Period", 10);
	indicator.parameters:addInteger("P2", "ATR Multiplier", "ATR Multiplier", 3);
	indicator.parameters:addInteger("P3", "Channel percentage", "Channel percentage", 40,1,100);
	
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("S1_color", "Color of S1", "Color of S1", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("S2_color", "Color of S2", "Color of S2", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local P1;
local P2;
local P3;

local first;
local source = nil;

-- Streams block
local S1 = nil;
local S2 = nil;

local ATR;

-- Routine
function Prepare(nameOnly)
    P1 = instance.parameters.P1;
	P2 = instance.parameters.P2;
	P3 = instance.parameters.P3;
    
	source = instance.source;

    local name = profile:id() .. "(" .. source:name() .. ", " .. P3 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    ATR = core.indicators:create("ATR", source, P1);
    first = ATR.DATA:first();

    S1 = instance:addStream("Top", core.Line, name .. ".Top", "Top", instance.parameters.S1_color, first);
	S1:setWidth(instance.parameters.width1);
    S1:setStyle(instance.parameters.style1);

    S2 = instance:addStream("Bottom", core.Line, name .. ".Bottom", "Bottom", instance.parameters.S2_color, first);
	S2 :setWidth(instance.parameters.width2);
    S2 :setStyle(instance.parameters.style2);   

	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period >= first and source:hasData(period) then
	
	    ATR:update(mode);
		
		
        S1[period] = source.close[period]+(P2*ATR.DATA[period]*(P3/100));
		S2[period] = source.close[period]-(P2*ATR.DATA[period]*(P3/100));
			
        
    end
end

