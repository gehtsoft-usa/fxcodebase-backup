-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4189

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
    indicator:name("Price export indicator");
    indicator:description("Price export indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addString("File", "File name", "", "");
end

local source = nil;
local handle;

function Prepare(nameOnly)
    source = instance.source;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    handle=io.open(instance.parameters.File,"a+");
end

function Update(period, mode)
   if (period==source:size()-1) then
    local Time=core.dateToTable(core.now());
    local Str=Time.day .. "." .. Time.month .. "." .. Time.year .. " " .. Time.hour .. ":" .. Time.min .. ":" .. Time.sec;
    Str=Str .. " " .. source.close[period] .. '\n';
    handle:write(Str);
    handle:flush(handle);
   end 
end

