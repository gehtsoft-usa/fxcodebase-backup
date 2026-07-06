-- Id: 563
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=898

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Williams Percent Range (WPR)");
    indicator:description("Williams Percent Range (WPR)");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "N", "Period", 14);
     indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("clrWPR", "Color of Williams Percent Range", "Color of Williams Percent Range", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", -20);
    indicator.parameters:addDouble("oversold","Oversold Level","", -80);
	    indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);

end

local first;
local source = nil;
local N;
local WPR;
function Prepare(nameOnly)
    source = instance.source;
    N=instance.parameters.N;
    first=source:first()+N;
    local name = profile:id() .. "(" .. source:name() .. ", " .. N .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    WPR = instance:addStream("WPR", core.Line, name .. ".Williams Percent Range", "Williams Percent Range", instance.parameters.clrWPR, first);
    WPR:setPrecision(math.max(2, instance.source:getPrecision()));
	WPR:setWidth(instance.parameters.width);
    WPR:setStyle(instance.parameters.style);
    WPR:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	WPR:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
end


function Update(period, mode)
    if (period>=first) then
	 local min,max=mathex.minmax(source,period-N+1, period);
     WPR[period]=-((max-source.close[period])*100./(max-min));
    end 
end

