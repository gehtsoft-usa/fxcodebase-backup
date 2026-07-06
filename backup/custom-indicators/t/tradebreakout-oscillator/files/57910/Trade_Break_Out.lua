-- Id: 8891

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=34070

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
    indicator:name("TradeBreakOut oscillator");
    indicator:description("TradeBreakOut oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 50);
    indicator.parameters:addString("PriceType", "Price type", "", "High/Low");
    indicator.parameters:addStringAlternative("PriceType", "High/Low", "", "High/Low");
    indicator.parameters:addStringAlternative("PriceType", "Close", "", "Close");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Uclr", "Upper line color", "Upper line color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Uwidth", "Upper line width", "Upper line width", 1, 1, 5);
    indicator.parameters:addInteger("Ustyle", "Upper line style", "Upper line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Ustyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Lclr", "Lower line color", "Lower line color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("Lwidth", "Lower line width", "Lower line width", 1, 1, 5);
    indicator.parameters:addInteger("Lstyle", "Lower line style", "Lower line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Lstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local PriceType;
local Upper=nil;
local Lower=nil;	
local HStream, LStream;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    PriceType=instance.parameters.PriceType;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.PriceType .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    Upper = instance:addStream("Upper", core.Line, name .. ".Upper", "Upper", instance.parameters.Uclr, first);
    Upper:setPrecision(math.max(2, instance.source:getPrecision()));
    Upper:setWidth(instance.parameters.Uwidth);
    Upper:setStyle(instance.parameters.Ustyle);
    Lower = instance:addStream("Lower", core.Line, name .. ".Lower", "Lower", instance.parameters.Lclr, first);
    Lower:setPrecision(math.max(2, instance.source:getPrecision()));
    Lower:setWidth(instance.parameters.Lwidth);
    Lower:setStyle(instance.parameters.Lstyle);
    if PriceType=="High/Low" then
     HStream=source.high;
     LStream=source.low;
    else
     HStream=source.close;
     LStream=source.close;
    end
end

function Update(period, mode)
   if period>first then
    local H=mathex.max(HStream, period-Period+1, period);
    local L=mathex.min(LStream, period-Period+1, period);
    Upper[period]=(LStream[period]-L)/L;
    Lower[period]=(HStream[period]-H)/H;
   end 
end

