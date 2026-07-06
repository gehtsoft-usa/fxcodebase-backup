-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59373
-- Id: 9873

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
    indicator:name("Heiken Ashi Accumulation/Distribution");
    indicator:description("Heiken Ashi Accumulation/Distribution");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method", "Method", "CI");
    indicator.parameters:addStringAlternative("Method", "Classic", "", "CS");
    indicator.parameters:addStringAlternative("Method", "Classic Incremental", "", "CI");
    indicator.parameters:addStringAlternative("Method", "Trade Station", "", "TS");
    indicator.parameters:addGroup("Style");    
    indicator.parameters:addColor("clrAD", "Color of AD", "Color of AD", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local AD, HA;
local Method;
function Prepare(nameOnly)
    source = instance.source;
	
	
	if instance.parameters.Method == "CS" then
        Method = 1;
    elseif instance.parameters.Method == "CI" then
        Method = 2;
    elseif instance.parameters.Method == "TS" then
        Method = 3;
    else
        Method = 2;
    end


     assert(source:supportsVolume(), "The source must have volume");
	
    first=HA.DATA:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	HA = core.indicators:create("HA",source);
    AD = instance:addStream("AD", core.Line, name .. ".AD", "AD", instance.parameters.clrAD, first);
    AD:setPrecision(math.max(2, instance.source:getPrecision()));
	AD:setWidth(instance.parameters.width);
    AD:setStyle(instance.parameters.style);
end


function Update(period, mode)

    HA:update(mode);
	
    if (period<first) then
	return;    
    end 
	
	   if Method == 1 or Method == 2 then
            -- classic
            if HA.high[period] - HA.low[period] == 0 then
                AD[period] = 0;
            else
                AD[period] = ((HA.close[period] - HA.low[period]) - (HA.high[period] - HA.close[period])) / (HA.high[period] - HA.low[period]) * source.volume[period];
            end
        else
            -- TS (method == 3)
            AD[period] = (HA.cclose[period] - HA.open[period]) / (HA.high[period] - HA.low[period]) * source.volume[period];
        end

        if period >= first + 1 and Method == 2 or Method == 3 then
            AD[period] = AD[period] + AD[period - 1];
        end
end

