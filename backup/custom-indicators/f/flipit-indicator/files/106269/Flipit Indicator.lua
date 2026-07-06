
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63478

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



function Init()
    indicator:name("Flipit Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);
 

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Line Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("width", "Indicator Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Indicator Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
 
end


local first;
local Period;
local source;
local Up, Down;
 
function Prepare(nameOnly) 
    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Period=instance.parameters.Period;
	source = instance.source; 
	first=source:first()+Period;
    local name;
    name = profile:id() .. "(" .. instance.source:name() .. "," .. Period .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end

    out = instance:addStream("out", core.Line, name, "out", Up, first);
    out:setWidth(instance.parameters.width);
    out:setStyle(instance.parameters.style);
 
end

 

function Update(period)
 
	
    if period < first then
	return;
	end
	 
	 local Top=mathex.avg(source.high, period-Period+1, period);
	 local Bottom=mathex.avg(source.low, period-Period+1, period);
	 out[period]=(Top+Bottom)/2;
	 
	 if out[period]>= source.close[period] then
	 out:setColor(period, Up);
	 else
	 out:setColor(period, Down);
	 end

end 