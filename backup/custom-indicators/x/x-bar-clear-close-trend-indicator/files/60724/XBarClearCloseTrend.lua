-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=36109
-- Id: 9070

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
    indicator:name("XBarClearCloseTrend indicator");
    indicator:description("XBarClearCloseTrend indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr1", "UP color 1", "UP color 1", core.rgb(0, 0, 255));
    indicator.parameters:addColor("UPclr2", "UP color 2", "UP color 2", core.rgb(128, 128, 255));
    indicator.parameters:addColor("UPclr3", "UP color 3", "UP color 3", core.rgb(128, 255, 255));
    indicator.parameters:addColor("DNclr1", "DN color 1", "DN color 1", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr2", "DN color 2", "DN color 2", core.rgb(255, 128, 0));
    indicator.parameters:addColor("DNclr3", "DN color 3", "DN color 3", core.rgb(255, 255, 128));
end

local first;
local source = nil;
local Period;
local trend;
local open=nil;
local close=nil;
local high=nil;
local low=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    trend=instance:addInternalStream(source:first(), 0);
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), source:first())
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), source:first())
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), source:first())
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), source:first())
    instance:createCandleGroup("Candle", "", open, high, low, close);
end

function IsBarUp(bar)
 local i;
 for i=1,Period,1 do
  if source.high[bar-i]>=source.close[bar] then
   return (false);
  end
 end
 return (true);
end

function IsBarDn(bar)
 local i;
 for i=1,Period,1 do
  if source.low[bar-i]<=source.close[bar] then
   return (false);
  end
 end
 return (true);
end

function Update(period, mode)
   if period<source:first()  then
   return;
   end
    open[period]=source.open[period];
    close[period]=source.close[period];
    high[period]=source.high[period];
    low[period]=source.low[period];
    trend[period]=trend[period-1];
	
	
	if period<first  then
   return;
   end
   
   
    if trend[period-1]==1 then
     if IsBarUp(period) then
      open:setColor(period, instance.parameters.UPclr1);
     elseif IsBarDn(period) then
      open:setColor(period, instance.parameters.DNclr1);
     elseif source.close[period]>=source.close[period-1] then
      open:setColor(period, instance.parameters.UPclr2);
      trend[period]=-1;
     else
      open:setColor(period, instance.parameters.UPclr3);
     end
    else
     if IsBarDn(period) then
      open:setColor(period, instance.parameters.DNclr1);
     elseif IsBarUp(period) then
      open:setColor(period, instance.parameters.UPclr1);
      trend[period]=1;
     elseif source.close[period]<=source.close[period-1] then
      open:setColor(period, instance.parameters.DNclr2);
     else
      open:setColor(period, instance.parameters.DNclr3);
     end
    end
 
end

