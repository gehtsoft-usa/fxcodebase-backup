-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10401

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
    indicator:name("Fibo Candles indicator");
    indicator:description("Fibo Candles indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);
    indicator.parameters:addString("FiboLevel", "Fibo level", "Fibo level", "0.236");
    indicator.parameters:addStringAlternative("FiboLevel", "0.236", "", "0.236");
    indicator.parameters:addStringAlternative("FiboLevel", "0.382", "", "0.382");
    indicator.parameters:addStringAlternative("FiboLevel", "0.500", "", "0.500");
    indicator.parameters:addStringAlternative("FiboLevel", "0.618", "", "0.618");
    indicator.parameters:addStringAlternative("FiboLevel", "0.762", "", "0.762");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local Period;
local FiboLevel;
local trend;

function Prepare(nameOnly)   
    source = instance.source;
    Period=instance.parameters.Period;
    FiboLevel=tonumber(instance.parameters.FiboLevel);
    first = source:first()+Period;
    trend = instance:addInternalStream(first, 0);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.FiboLevel .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("CCI color candle", "", open, high, low, close);
end

function Update(period, mode)
   if (period>first) then
    open[period]=source.open[period];
    close[period]=source.close[period];
    high[period]=source.high[period];
    low[period]=source.low[period];
    
    local MaxHigh=mathex.max(source.high,core.rangeTo(period,Period));
    local MinLow=mathex.min(source.low,core.rangeTo(period,Period));
    local range=MaxHigh-MinLow;
    trend[period]=trend[period-1];
    if source.open[period]>source.close[period] then
     if range*FiboLevel>=source.close[period]-MinLow then
      trend[period]=1; 
     end
    else
     if range*FiboLevel>=MaxHigh-source.close[period] then
      trend[period]=-1;
     end
    end
    
    if trend[period]==1 then
     open:setColor(period,instance.parameters.DNclr)
    elseif trend[period]==-1 then
     open:setColor(period,instance.parameters.UPclr)
    end
   elseif period==first then
    trend[period]=0; 
   end 
end

