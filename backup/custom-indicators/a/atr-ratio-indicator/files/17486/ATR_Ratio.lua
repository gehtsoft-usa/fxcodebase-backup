-- Id: 4925
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7884

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
    indicator:name("ATR ratio");
    indicator:description("ATR ratio");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("ShortPeriod", "ShortPeriod", "", 7);
    indicator.parameters:addInteger("LongPeriod", "LongPeriod", "", 49);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local ShortPeriod;
local LongPeriod;
local Short_ATR;
local Long_ATR;
local ATR_Ratio=nil;

function Prepare(nameOnly)
    source = instance.source;
    ShortPeriod=instance.parameters.ShortPeriod;
    LongPeriod=instance.parameters.LongPeriod;
    
	
	first = math.max(Short_ATR.DATA:first(), Long_ATR.DATA:first());
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.ShortPeriod .. ", " .. instance.parameters.LongPeriod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Short_ATR = core.indicators:create("ATR", source, ShortPeriod);
    Long_ATR = core.indicators:create("ATR", source, LongPeriod);
    ATR_Ratio = instance:addStream("ATR_Ratio", core.Line, name .. ".ATR_Ratio", "ATR_Ratio", instance.parameters.clr, first);
    ATR_Ratio:setWidth(instance.parameters.widthLinReg);
    ATR_Ratio:setStyle(instance.parameters.styleLinReg);
	
	ATR_Ratio:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    Short_ATR:update(mode);
    Long_ATR:update(mode);
	
    if Long_ATR.DATA[period]~=0 then   
     ATR_Ratio[period]=Short_ATR.DATA[period]/Long_ATR.DATA[period];
    end 

end

