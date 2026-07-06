-- Id: 24166
-- More information about this indicator can be found at:
-- http://fxcodebase.com/

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC |
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
    indicator:name("Volatility Histogram");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("periods", "Periods", "", 10);
    indicator.parameters:addString("mode", "Mode", "", "pips")
    indicator.parameters:addStringAlternative("mode", "Pips", "", "pips");
    indicator.parameters:addStringAlternative("mode", "% of daily", "", "daily");
    
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Volatility_color", "Color of Volatility", "Color of Volatility", core.rgb(255, 0, 0));
end

local source = nil;
local Volatility = nil;
local periods;
local calc_mode;
local D1Source;

function Prepare(nameOnly)   
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 
    if nameOnly then
        return;
    end

    calc_mode = instance.parameters.mode;
    periods = instance.parameters.periods;
    source = instance.source;
    Volatility = instance:addStream("Volatility", core.Bar, name, "Volatility", instance.parameters.Volatility_color, 0);
    Volatility:setPrecision(math.max(2, instance.source:getPrecision()));
    if calc_mode ~= "pips" then
        D1Source = core.host:execute("getSyncHistory", source:instrument(), "D1", source:isBid(), 
            300, 1, 2)
    end
end

function Update(period, mode)
    if period < periods then
        return;
    end
    local min, max = mathex.minmax(source, period - periods, period);
    local dist = (max - min) / source:pipSize();
    if calc_mode == "pips" then
        Volatility[period] = dist;
    elseif D1Source:size() > 0 then
        local index = core.findDate(D1Source, source:date(period), false);
        if index == -1 then
            return;
        end
        local dailyRange = (D1Source.high[index] - D1Source.low[index]) / source:pipSize();
        Volatility[period] = dist / dailyRange * 100;
    end
end

function AsyncOperationFinished(cookie, successful, message, message1, message2)
    if cookie == 1 then
        instance:updateFrom(0);
    end
end
