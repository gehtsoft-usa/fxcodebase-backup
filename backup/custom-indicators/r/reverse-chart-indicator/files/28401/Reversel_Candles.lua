-- Id: 6124
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=14988

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Reverse candles indicator");
    indicator:description("Reverse candles indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");

end

local first;
local source = nil;

function ReverseSymbol(Name)
 local Pos=string.find(Name,"/");
 if Pos~=nil then
  return string.sub(Name,Pos+1) .. "/" .. string.sub(Name,1,Pos-1);
 else
  return nil;
 end
end

function Prepare(nameOnly)
    source = instance.source;
    first = source:first()+2;
    local ReverseName=ReverseSymbol(source:name());
    local name;
    if ReverseName==nil then
     ReverseName="1/" .. source:name();
     name = profile:id() .. "(1/" .. source:name() .. ")";
    else
     name = profile:id() .. "(" .. ReverseName .. ")";
    end 
    instance:name(name);
    if nameOnly then
        return;
    end
    trend = instance:addInternalStream(first, 0);
    open = instance:addStream("open", core.Line, ReverseName, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, ReverseName, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, ReverseName, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, ReverseName, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup(ReverseName, "", open, high, low, close);
end

function Update(period, mode)
   if (period>first) then
    open[period]=1/source.open[period];
    close[period]=1/source.close[period];
    high[period]=1/source.low[period];
    low[period]=1/source.high[period];
   end 
end

