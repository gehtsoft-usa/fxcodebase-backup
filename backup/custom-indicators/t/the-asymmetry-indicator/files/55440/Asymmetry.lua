-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=32546
-- Id: 8625

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
    indicator:name("Asymmetry oscillator");
    indicator:description("Asymmetry oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local RSI;
local Asymmetry;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    RSI = core.indicators:create("RSI", source, Period);
    first = RSI.DATA:first()+Period;
    Asymmetry = instance:addStream("Asymmetry", core.Line, name .. ".Asymmetry", "Asymmetry", instance.parameters.clr, first);
    Asymmetry:setWidth(instance.parameters.widthLinReg);
    Asymmetry:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)

   RSI:update(mode);
	
   if period<first then
   return;
   end
   
   
    local M = mathex.sum(RSI.DATA, core.rangeTo(period, Period))/(Period+1);
    local D=0;
    local i;
    for i=Period-1, 0, -1 do
     D=D+(RSI.DATA[period-i]-M)*(RSI.DATA[period-i]-M);
    end
    D=D/(Period+1);
    local sD=math.sqrt(D);
    local MD=0;
    for i=Period-1, 0, -1 do
     MD=MD+(RSI.DATA[period-i]-D)*(RSI.DATA[period-i]-D);
    end
    MD=MD/(Period+1);
    Asymmetry[period]=math.abs(MD/(D*sD));
    
end

