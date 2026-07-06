-- More information about this indicator can be found at:
--http://fxcodebase.com/code/viewtopic.php?f=17&t=69765

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                           mario.jemic@gmail.com  |
--|                          https://AppliedMachineLearning.systems  |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                                  Patreon: https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Directional real volume On Balance Volume");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addBoolean("Absolute", "Absolute", "", true);

    indicator.parameters:addColor("V_color", "V Color", "Color", core.colors().Red);
    indicator.parameters:addInteger("V_width", "V Width", "Width", 1, 1, 5);
 
end
local Absolute;
local source, vol, buy_stream, sell_stream, V;
function Prepare(nameOnly)
    source = instance.source;
	
	Absolute= instance.parameters.Absolute;
	
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
    vol = core.indicators:create("DIRECTIONAL_REAL_VOLUME", source);
    buy_stream = vol:getStream(0);
    sell_stream = vol:getStream(1);
    V = instance:addStream("V", core.Bar, "V", "V", instance.parameters.V_color, buy_stream:first(), 0);
    V:setWidth(instance.parameters.V_width);
 

    core.host:execute("setTimer", 100, 1);
end

function Update(period, mode)
    vol:update(mode);
    if buy_stream:hasData(period) and sell_stream:hasData(period) then
        if period == buy_stream:first() then
            V[period] = buy_stream[period] + sell_stream[period];
        elseif period > buy_stream:first() then
            if source.close[period] > source.close[period - 1] then
			
			    if Absolute then
				 V[period] = V[period - 1] + math.abs(buy_stream[period] + sell_stream[period]);
				else
                V[period] = V[period - 1] + buy_stream[period] + sell_stream[period];
				end
            elseif source.close[period] < source.close[period - 1] then
			    if Absolute then
				 V[period] = V[period - 1] -  math.abs(buy_stream[period] + sell_stream[period]);
				else
                V[period] = V[period - 1] - (buy_stream[period] + sell_stream[period]);
				end
            else
                V[period] = V[period - 1];
            end
        end
    end
end

function GetFirstSerial()
    for i = 0, buy_stream:size() - 1 do
        if buy_stream:hasData(i) and buy_stream[i] ~= 0 then
            return buy_stream:serial(i);
        end
    end
    return nil;
end
local last_first;
function AsyncOperationFinished(cookie, success, message)
    if cookie == 100 then
        local first = GetFirstSerial();
        if last_first ~= first then
            instance:updateFrom(0);
            last_first = first;
        end
    end
end


