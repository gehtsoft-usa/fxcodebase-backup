-- Id: 3038
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2070&sid=6eb856b7a0e3a5289eb215e2282f8b31

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
    indicator:name("True stochastic");
    indicator:description("True stochastic");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("PeriodK1", "Period K for stochastic 1", "Period K for stochastic 1", 8);
    indicator.parameters:addInteger("PeriodD1", "Period D for stochastic 1", "Period D for stochastic 1", 3);
    indicator.parameters:addInteger("PeriodK2", "Period K for stochastic 2", "Period K for stochastic 2", 16);
    indicator.parameters:addInteger("PeriodD2", "Period D for stochastic 2", "Period D for stochastic 2", 3);
    indicator.parameters:addInteger("PeriodK3", "Period K for stochastic 3", "Period K for stochastic 3", 34);
    indicator.parameters:addInteger("PeriodD3", "Period D for stochastic 3", "Period D for stochastic 3", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr1", "Color of Stochastic 1", "Color of Stochastic 1", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr2", "Color of Stochastic 2", "Color of Stochastic 2", core.rgb(255, 0, 0));
    indicator.parameters:addColor("clr3", "Color of Stochastic 3", "Color of Stochastic 3", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "1. Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "1. Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	
	indicator.parameters:addInteger("width2", "2. Line Width", "", 1, 1, 5);	
    indicator.parameters:addInteger("style2", "2. Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	
	indicator.parameters:addInteger("width3", "3. Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "3. Line Style", "", core.LINE_SOLID);
	indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
end

local first;
local source = nil;
local PeriodK1;
local PeriodD1;
local PeriodK2;
local PeriodD2;
local PeriodK3;
local PeriodD3;
local Stochastic1;
local Stochastic2;
local Stochastic3;
local buff1;
local buff2;
local buff3;

function Prepare(nameOnly)
    source = instance.source;
    PeriodK1=instance.parameters.PeriodK1;
    PeriodD1=instance.parameters.PeriodD1;
    PeriodK2=instance.parameters.PeriodK2;
    PeriodD2=instance.parameters.PeriodD2;
    PeriodK3=instance.parameters.PeriodK3;
    PeriodD3=instance.parameters.PeriodD3;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.PeriodK1 .. ", " .. instance.parameters.PeriodD1 .. ", " .. instance.parameters.PeriodK2 .. ", " .. instance.parameters.PeriodD2 .. ", " .. instance.parameters.PeriodK3 .. ", " .. instance.parameters.PeriodD3 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Stochastic1 = core.indicators:create("STOCHASTIC", source, PeriodK1,PeriodD1,2);
    Stochastic2 = core.indicators:create("STOCHASTIC", source, PeriodK2,PeriodD2,2);
    Stochastic3 = core.indicators:create("STOCHASTIC", source, PeriodK3,PeriodD3,2);
    first = math.max(Stochastic1.DATA:first(),Stochastic2.DATA:first(),Stochastic3.DATA:first())+2;
    buff1 = instance:addStream("Stochastic1", core.Line, name .. ".Stochastic1", "Stochastic1", instance.parameters.clr1, first);
    buff1:setPrecision(math.max(2, instance.source:getPrecision()));
	buff1:setWidth(instance.parameters.width1);
	buff1:setStyle(instance.parameters.style1);
    buff2 = instance:addStream("Stochastic2", core.Line, name .. ".Stochastic2", "Stochastic2", instance.parameters.clr2, first);
    buff2:setPrecision(math.max(2, instance.source:getPrecision()));
	buff2:setWidth(instance.parameters.width2);
	buff2:setStyle(instance.parameters.style2);
    buff3 = instance:addStream("Stochastic3", core.Line, name .. ".Stochastic3", "Stochastic3", instance.parameters.clr3, first);
    buff3:setPrecision(math.max(2, instance.source:getPrecision()));
	buff3:setWidth(instance.parameters.width3);
	buff3:setStyle(instance.parameters.style3);
end

function Update(period, mode)
    Stochastic1:update(mode);
    Stochastic2:update(mode);
    Stochastic3:update(mode);
    if period>first+PeriodK1 then
     buff1[period]=Stochastic1.K[period];
    end 
    if period>first+PeriodK2 then
     buff2[period]=Stochastic2.K[period];
    end
    if period>first+PeriodK3 then 
     buff3[period]=Stochastic3.K[period];
    end 
end

