-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41305
-- Id: 9343

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
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
    indicator:name("Brain trend color candle indicator");
    indicator:description("Brain trend color candle indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 7);
    indicator.parameters:addDouble("K", "K", "", 0.7);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local K;
local river;
local TR;
local Emaxtra;
local open=nil;
local close=nil;
local high=nil;
local low=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    K=instance.parameters.K;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.K .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    TR = instance:addInternalStream(first, 0);
    Emaxtra = instance:addInternalStream(first, 0);
    river = instance:addInternalStream(first, 0);
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("BrainTrend", "", open, high, low, close);
end

function Update(period, mode)
   if period>first then
    open[period]=source.open[period];
    close[period]=source.close[period];
    high[period]=source.high[period];
    low[period]=source.low[period];
    TR[period]=source.high[period]-source.low[period];
    if period>first+Period then
     local i;
     local ATR=0;
     for i=0, Period-1, 1 do
      ATR=ATR+TR[period-i]*(Period-i);
     end
     ATR=2*ATR/(Period*(Period+1));
     local widcha=K*ATR;
     Emaxtra[period]=Emaxtra[period-1];
     river[period]=river[period-1];
     if river[period]==1 then
      if source.low[period]<Emaxtra[period]-widcha then
       river[period]=0;
       Emaxtra[period]=source.high[period];
      elseif source.low[period]>Emaxtra[period] then
       Emaxtra[period]=source.low[period];
      end
     else
      if source.high[period]>Emaxtra[period]+widcha then
       river[period]=1;
       Emaxtra[period]=source.low[period];
      elseif source.high[period]<Emaxtra[period] then
       Emaxtra[period]=source.high[period];
      end     
     end 
     if river[period]==1 then
      open:setColor(period, instance.parameters.UPclr);
     else
      open:setColor(period, instance.parameters.DNclr);
     end
    end 
   end 
end

