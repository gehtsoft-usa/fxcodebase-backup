-- Id: 3362

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3683

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
    indicator:name("Kaufman volatility indicator");
    indicator:description("Kaufman volatility indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
end

local first;
local source = nil;
local Period;
local DiffPrice;
local KVol=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+2;
    DiffPrice = instance:addInternalStream(first, 0);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    KVol = instance:addStream("KVol", core.Bar, name .. ".KVol", "KVol", instance.parameters.clr, first+Period);
    KVol:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if period>first then
    DiffPrice[period]=math.abs(source.close[period]-source.close[period-1]);
   end
   if period>first+Period then
    KVol[period]=core.avg(DiffPrice,core.rangeTo(period,Period));
   end 
end

