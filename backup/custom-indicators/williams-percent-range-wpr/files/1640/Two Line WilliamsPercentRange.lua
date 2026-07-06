-- Id: 17727
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
    indicator.parameters:addInteger("N1", "1. Period", "Period", 14);
	indicator.parameters:addInteger("N2", "2. Period", "Period", 28);

	  indicator.parameters:addGroup("Style")
    indicator.parameters:addColor("color1", "1. Williams Percent Range", "Color of Williams Percent Range", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("color2", "2. Williams Percent Range", "Color of Williams Percent Range", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
	indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);

	
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
local N1,N2;
local WPR1,WPR2, Delta;
function Prepare(nameOnly)
    source = instance.source;
    N1=instance.parameters.N1;
	N2=instance.parameters.N2;
    first=source:first()+math.max(N1,N2);
    local name = profile:id() .. "(" .. source:name() .. ", " .. N1.. ", " .. N2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    WPR1 = instance:addStream("WPR1", core.Line, name .. "1.Williams Percent Range", "1.Williams Percent Range", instance.parameters.color1, first);
    WPR1:setPrecision(math.max(2, instance.source:getPrecision()));
	WPR1:setWidth(instance.parameters.width1);
    WPR1:setStyle(instance.parameters.style1);
    WPR1:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	WPR1:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);  
	
	
	WPR2 = instance:addStream("WPR1", core.Line, name .. "2.Williams Percent Range", "2.Williams Percent Range", instance.parameters.color2, first);
    WPR2:setPrecision(math.max(2, instance.source:getPrecision()));
	WPR2:setWidth(instance.parameters.width2);
    WPR2:setStyle(instance.parameters.style2);
	
	
end


function Update(period, mode)
    if (period>=first) then
     local min,max=mathex.minmax(source,period-N1+1, period);
     WPR1[period]=-((max-source.close[period])*100./(max-min));
	 
	 
	 local min,max=mathex.minmax(source,period-N2+1, period);
     WPR2[period]=-((max-source.close[period])*100./(max-min));
    end 
end

