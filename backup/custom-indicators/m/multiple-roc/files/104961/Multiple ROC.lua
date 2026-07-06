-- Id: 15543
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63184

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
    indicator:name("Multiple ROC");
    indicator:description("Multiple ROC");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator); 

    indicator.parameters:addGroup("ROC Calculation");
    indicator.parameters:addInteger("Min", "Min ROC Period","", 1, 1, 1000);
	indicator.parameters:addInteger("Max", "Max ROC Period","", 10, 1, 1000);
	indicator.parameters:addInteger("Step", "Step","", 1, 1, 1000);
	
	indicator.parameters:addGroup("Line Style");
	  indicator.parameters:addColor("color",  "Central Line Color","", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("width", "Central Line Width","", 1, 1, 5);
     indicator.parameters:addInteger("style",  "Central Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);
	
	
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local ROC={};
local Min,Max, Step;
local first;
local source = nil;
local mva = nil;
local color, style, width;

-- Routine
function Prepare(nameOnly)
    color = instance.parameters.color;
	style = instance.parameters.style;
	width = instance.parameters.width;
    Min = instance.parameters.Min;
	Max = instance.parameters.Max;
	Step = instance.parameters.Step;
	
    source = instance.source;
    first = source:first() + Max;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Min .. ", " .. Max.. ", " .. Step.. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
 
	local Count=0;
	
	for i= Min, Max, Step do
	Count=Count+1;
    ROC[Count] = instance:addStream("ROC"..Count, core.Line, name .. Count..". ROC" , Count..". ROC" , color, first)
    ROC[Count]:setPrecision(math.max(2, instance.source:getPrecision()));
    ROC[Count]:setWidth(width);
    ROC[Count]:setStyle(style);
	end

end

-- Indicator calculation routine 
 
function Update(period, mode)
    if period <= first then
	return;
	end
	
	local Count=0;
        
		for i= Min, Max, Step do
		Count=Count+1;
        ROC[Count][period] = (source[period] / source[period - i] - 1) * 100;
		end 
 
 
end



