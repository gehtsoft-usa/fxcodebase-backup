-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59051
-- Id: 9675

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
    indicator:name("Linear regression ratio oscillator");
    indicator:description("Linear regression ratio oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Period 1", "", 10);
    indicator.parameters:addInteger("Period2", "Period 2", "", 15);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period1;
local Period2;
local LR1, LR2;
local LR_Ratio=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period1=instance.parameters.Period1;
    Period2=instance.parameters.Period2;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Period2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    assert(core.indicators:findIndicator("LINEAR REGRESSION LINE") ~= nil, "Please, download and install LINEAR REGRESSION LINE.LUA indicator");  
	
    LR1 = core.indicators:create("LINEAR REGRESSION LINE", source, Period1);
    LR2 = core.indicators:create("LINEAR REGRESSION LINE", source, Period2);
	
	first = math.max(LR1.DATA:first(),LR2.DATA:first());
    LR_Ratio = instance:addStream("LR_Ratio", core.Line, name .. ".LR_Ratio", "LR_Ratio", instance.parameters.clr, first);
    LR_Ratio:setPrecision(math.max(2, instance.source:getPrecision()));
    LR_Ratio:setWidth(instance.parameters.widthLinReg);
    LR_Ratio:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if period>first then
    LR1:update(mode);
    LR2:update(mode);
    if LR2.DATA[period]>0 then
     LR_Ratio[period] = LR1.DATA[period]/LR2.DATA[period];
    end 
   end 
end

