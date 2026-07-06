-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23276
-- Id: 7363

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

function Init()
    indicator:name("EHLERS INSTANTANEOUS TREND");
    indicator:description("EHLERS INSTANTANEOUS TREND");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
      indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("alpha", "Alpha", "Alpha", 0.07);
	  indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("iTrend_color", "Color of iTrend", "Color of iTrend", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "DEMA Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);
	indicator.parameters:addColor("Trigger_color", "Color of Trigger", "Color of Trigger", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "DEMA Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local alpha;

local first;
local source = nil;

-- Streams block
local iTrend = nil;
local Trigger=nil;
-- Routine
function Prepare(nameOnly)
    alpha = instance.parameters.alpha;
    source = instance.source;
    first = source:first()+2;

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(alpha) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
        iTrend = instance:addStream("iTrend", core.Line, name, "iTrend", instance.parameters.iTrend_color, first);
		iTrend:setWidth(instance.parameters.width1);
        iTrend:setStyle(instance.parameters.style1);
		Trigger = instance:addStream("Trigger", core.Line, name, "Trigger", instance.parameters.Trigger_color, first);
		Trigger:setWidth(instance.parameters.width2);
        Trigger:setStyle(instance.parameters.style2);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < first or not source:hasData(period) then
	return;
	end
	
	if period < 7 then 
	iTrend[period] = source[period] + 2*source[period-1]+ source[period-2]/4;
	else
	
	iTrend[period] = (alpha- alpha*alpha/4)*source[period] + 0.5* alpha * alpha * source[period-1] -
	(alpha - 0.75 * alpha*alpha) * source[period-2] + 2
	*(1 - alpha) * iTrend[period-1] -(1 - alpha)
	*(1-alpha)*iTrend[period-2];
	
	Trigger[period] = 2*iTrend[period] - iTrend[period-2];
	
	end

	
       
    
end

