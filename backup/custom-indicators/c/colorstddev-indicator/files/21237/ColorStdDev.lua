-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10139
-- Id: 5318

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("ColorStdDev indicator");
    indicator:description("ColorStdDev indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 12);
    indicator.parameters:addString("Method", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "TMA", "", "TMA");
    indicator.parameters:addInteger("MaxTrendLevel", "Max trend level", "", 100);
    indicator.parameters:addInteger("MiddleTrendLevel", "Middle trend level", "", 40);
    indicator.parameters:addInteger("FlatLevel", "Flat level", "", 10);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MaxTrendClr", "Max trend Color", "Max trend Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("MiddleTrendClr", "Middle trend Color", "Middle trend Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("FlatClr", "Flat Color", "Flat Color", core.rgb(0, 0, 255));
    indicator.parameters:addColor("NeutralClr", "Neutral Color", "Neutral Color", core.rgb(192, 192, 192));
end

local first;
local source = nil;
local Period;
local Method;
local MaxTrendLevel;
local MiddleTrendLevel;
local FlatLevel;
local StdDev;
local ColorStdDev=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
    MaxTrendLevel=instance.parameters.MaxTrendLevel;
    MiddleTrendLevel=instance.parameters.MiddleTrendLevel;
    FlatLevel=instance.parameters.FlatLevel;
    assert(core.indicators:findIndicator("STDDEV2") ~= nil, "Please, download and install STDDEV2.LUA indicator");    
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    StdDev = core.indicators:create("STDDEV2", source, Period, Method);
	first = StdDev.DATA:first();
    ColorStdDev = instance:addStream("ColorStdDev", core.Bar, name .. ".ColorStdDev", "ColorStdDev", instance.parameters.MaxTrendClr, first);
    ColorStdDev:addLevel(MaxTrendLevel);
    ColorStdDev:addLevel(MiddleTrendLevel);
    ColorStdDev:addLevel(FlatLevel);
	
	ColorStdDev:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    StdDev:update(mode);
    ColorStdDev[period]=StdDev.DATA[period]/source:pipSize();
    if ColorStdDev[period]>MaxTrendLevel then
     ColorStdDev:setColor(period,instance.parameters.MaxTrendClr);
    elseif ColorStdDev[period]>MiddleTrendLevel then
     ColorStdDev:setColor(period,instance.parameters.MiddleTrendClr);
    elseif ColorStdDev[period]>FlatLevel then
     ColorStdDev:setColor(period,instance.parameters.FlatClr);
    else
     ColorStdDev:setColor(period,instance.parameters.NeutralClr);
    end
   
end

