-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6397
-- Id: 5976

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
    indicator:name("Historical Volatility ratio oscillator");
    indicator:description("Historical Volatility ratio oscillator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Period1", "", 11, 2, 1000);
    indicator.parameters:addString("Method1", "Method1", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method1", "High-Low", "", "High-Low");
    indicator.parameters:addDouble("decline1", "decline1", "", 0.94, 0, 1);
    indicator.parameters:addInteger("Period2", "Period2", "", 21, 2, 1000);
    indicator.parameters:addString("Method2", "Method2", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method2", "High-Low", "", "High-Low");
    indicator.parameters:addDouble("decline2", "decline2", "", 0.94, 0, 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period1;
local Method1;
local decline1;
local Period2;
local Method2;
local decline2;
local HV1=nil;
local HV2=nil;
local HV_Ratio=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period1=instance.parameters.Period1;
    Method1=instance.parameters.Method1;
    decline1=instance.parameters.decline1;
    Period2=instance.parameters.Period2;
    Method2=instance.parameters.Method2;
    decline2=instance.parameters.decline2;
    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Method1 .. ", " .. instance.parameters.decline1 .. ", " .. instance.parameters.Period2 .. ", " .. instance.parameters.Method2 .. ", " .. instance.parameters.decline2 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("HISTORICAL_VOLATILITY") ~= nil, "Please, download and install HISTORICAL_VOLATILITY.LUA indicator");   
    HV1 = core.indicators:create("HISTORICAL_VOLATILITY", source, Period1, Method1, decline1);
    HV2 = core.indicators:create("HISTORICAL_VOLATILITY", source, Period2, Method2, decline2);
	
	first = math.max(HV1.DATA:first(),HV2.DATA:first());
	
    HV_Ratio = instance:addStream("HV_Ratio", core.Line, name .. ".HV_Ratio", "HV_Ratio", instance.parameters.clr, first);
    HV_Ratio:setPrecision(math.max(2, instance.source:getPrecision()));
    HV_Ratio:setWidth(instance.parameters.widthLinReg);
    HV_Ratio:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period>first) then
    HV1:update(mode);
    HV2:update(mode);
    if HV2.DATA[period]~=0 then
     HV_Ratio[period]=HV1.DATA[period]/HV2.DATA[period];
    end 
   end 
end

