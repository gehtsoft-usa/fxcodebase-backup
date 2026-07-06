-- Id: 4610
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6522

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
    indicator:name("PERCENT CHANGE");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	   indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addString("Mode", "The Indicator Mode", "", "N");
    indicator.parameters:addStringAlternative("Mode", "Net Change", "", "N");
    indicator.parameters:addStringAlternative("Mode", "Percent Change", "", "P");
	indicator.parameters:addInteger("PERIOD", "Period", "", 14);
	
	   indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("clr", "Color of the oscillator line", "", core.rgb(255, 0, 0));
end

local source;
local Mode;
local OUT;
local PERIOD;


function Prepare(nameOnly)  
   PERIOD = instance.parameters.PERIOD;
    Mode = instance.parameters.Mode;
	 source = instance.source;
	 
	   
    first = source:first()+PERIOD;

    local name;
    name = profile:id() .. "(" .. source:name() .. "," .. Mode.. "," .. PERIOD .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    OUT = instance:addStream("PERCENT", core.Line, name .. ".PERCENT", "PERCENT", instance.parameters.clr, first);
	OUT:setWidth(instance.parameters.width);
    OUT:setStyle(instance.parameters.style);
	OUT:setPrecision (math.max(2, source:getPrecision ()));
end



function Update(period)
  
    if period < first then
	return;
	end

    if Mode == "P" then
        OUT[period] = (source.close[period] - source.open[period-PERIOD]) / (source.open[period-PERIOD]/ 100);
    else
        OUT[period] = (source.close[period] - source.open[period-PERIOD]) / source:pipSize();
    end
end
