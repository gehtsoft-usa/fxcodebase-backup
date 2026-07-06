-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41322
-- Id: 9365

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
    indicator:name("Self Adjusting RSI oscillator");
    indicator:description("Self Adjusting RSI oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 12);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 2);
    indicator.parameters:addBoolean("Smooth", "Smooth", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("RSIclr", "RSI color", "RSI color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("RSIwidth", "RSI width", "RSI width", 1, 1, 5);
    indicator.parameters:addInteger("RSIstyle", "RSI style", "RSI style", core.LINE_SOLID);
    indicator.parameters:setFlag("RSIstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("OBclr", "Overbought color", "Overbought color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("OBwidth", "Overbought width", "Overbought width", 1, 1, 5);
    indicator.parameters:addInteger("OBstyle", "Overbought style", "Overbought style", core.LINE_SOLID);
    indicator.parameters:setFlag("OBstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("OSclr", "Oversold color", "Oversold color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("OSwidth", "Oversold width", "Oversold width", 1, 1, 5);
    indicator.parameters:addInteger("OSstyle", "Oversold style", "Oversold style", core.LINE_SOLID);
    indicator.parameters:setFlag("OSstyle", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Deviation;
local Smooth;
local RSI_Ind;
local RSI_MVA;
local StdDev;
local St;
local St_MVA;
local RSI=nil;
local OB=nil;
local OS=nil;
local pipSize;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Deviation=instance.parameters.Deviation;
    Smooth=instance.parameters.Smooth;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Deviation .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	assert(core.indicators:findIndicator("STDDEV") ~= nil, "Please, download and install STDDEV.LUA indicator");    
	
	
    RSI_Ind = core.indicators:create("RSI", source, Period);
    StdDev = core.indicators:create("STDDEV", source, Period);
    if Smooth then
     RSI_MVA = core.indicators:create("MVA", RSI_Ind.DATA, Period);
     St=instance:addInternalStream(first, 0);
     St_MVA = core.indicators:create("MVA", St, Period);
    end 
    RSI = instance:addStream("RSI", core.Line, name .. ".RSI", "RSI", instance.parameters.RSIclr, first);
    RSI:setPrecision(math.max(2, instance.source:getPrecision()));
    RSI:setWidth(instance.parameters.RSIwidth);
    RSI:setStyle(instance.parameters.RSIstyle);
    OB = instance:addStream("Overbought", core.Line, name .. ".Overbought", "Overbought", instance.parameters.OBclr, first);
    OB:setPrecision(math.max(2, instance.source:getPrecision()));
    OB:setWidth(instance.parameters.OBwidth);
    OB:setStyle(instance.parameters.OBstyle);
    OS = instance:addStream("Oversold", core.Line, name .. ".Oversold", "Oversold", instance.parameters.OSclr, first);
    OS:setPrecision(math.max(2, instance.source:getPrecision()));
    OS:setWidth(instance.parameters.OSwidth);
    OS:setStyle(instance.parameters.OSstyle);
    pipSize=source:pipSize();
end

function Update(period, mode)
   if period>first then
    RSI_Ind:update(mode);
    StdDev:update(mode);
    RSI[period]=RSI_Ind.DATA[period];
    local kDev;
    if Smooth then
     RSI_MVA:update(mode);
     St[period]=math.abs(RSI[period]-RSI_MVA.DATA[period]);
     St_MVA:update(mode);
     kDev=Deviation*St_MVA.DATA[period];
    else
     kDev=Deviation*StdDev.DATA[period]/pipSize;
    end
    OB[period]=50+kDev;
    OS[period]=50-kDev;
   end 
end

