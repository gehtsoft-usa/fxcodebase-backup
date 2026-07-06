-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=15874
-- Id: 6331

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
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
    indicator:name("MA with Band indicator");
    indicator:description("MA with Band indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Method", "Method of MA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("Method", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("Method", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("Method", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("Method", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("Method", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("Method", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("Method", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("Method", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("Method", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("Method", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("Method", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("Method", "T3", "", "T3");
    indicator.parameters:addStringAlternative("Method", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("Method", "Median", "", "Median");
    indicator.parameters:addStringAlternative("Method", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("Method", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("Method", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("Method", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("Method", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("Method", "JSmooth", "", "JSmooth");
    indicator.parameters:addInteger("Period", "Period of MA", "", 10);
    indicator.parameters:addInteger("BB_Period", "Period of Bands", "", 15);
    indicator.parameters:addDouble("BB_Deviation", "Deviation of Bands", "", 2);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MAclr", "MA Color", "MA Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("MAwidth", "MA width", "MA width", 1, 1, 5);
    indicator.parameters:addInteger("MAstyle", "MA style", "MA style", core.LINE_SOLID);
    indicator.parameters:setFlag("MAstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("BBclr", "Bands Color", "Bands Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("BBwidth", "BB width", "BB width", 1, 1, 5);
    indicator.parameters:addInteger("BBstyle", "BB style", "BB style", core.LINE_SOLID);
    indicator.parameters:setFlag("BBstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Tclr", "Top cloud color", "Top cloud color", core.rgb(0, 128, 0));
    indicator.parameters:addColor("Bclr", "Bottom cloud color", "Bottom cloud color", core.rgb(128, 0, 0));
    indicator.parameters:addInteger("Transparency", "Transparency", "", 80,0,100);
end

local first;
local source = nil;
local Method;
local Period;
local BB_Period;
local BB_Deviation;
local MA;
local BB;
local MA_Buff=nil;
local U_Buff=nil;
local L_Buff=nil;
local MA_Buff2=nil;

function Prepare(nameOnly)
    source = instance.source;
    Method=instance.parameters.Method;
    Period=instance.parameters.Period;
    BB_Period=instance.parameters.BB_Period;
    BB_Deviation=instance.parameters.BB_Deviation;
   
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.BB_Period .. ", " .. instance.parameters.BB_Deviation .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
    MA = core.indicators:create("AVERAGES", source, Method, Period, false);
    BB = core.indicators:create("BB", MA.DATA, BB_Period, BB_Deviation);
   
    first = math.max(MA.DATA:first(),BB.DATA:first());
    MA_Buff = instance:addStream("MA_Buff", core.Line, name .. ".MA", "MA", instance.parameters.MAclr, first);
    MA_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
    U_Buff = instance:addStream("U_Buff", core.Line, name .. ".Upper", "Upper", instance.parameters.BBclr, first);
    U_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
    L_Buff = instance:addStream("L_Buff", core.Line, name .. ".Lower", "Lower", instance.parameters.BBclr, first);
    L_Buff:setPrecision(math.max(2, instance.source:getPrecision()));
    MA_Buff2=instance:addInternalStream(first, 0);
    MA_Buff:setWidth(instance.parameters.MAwidth);
    MA_Buff:setStyle(instance.parameters.MAstyle);
    U_Buff:setWidth(instance.parameters.BBwidth);
    U_Buff:setStyle(instance.parameters.BBstyle);
    L_Buff:setWidth(instance.parameters.BBwidth);
    L_Buff:setStyle(instance.parameters.BBstyle);
    instance:createChannelGroup("UpperGroup","Upper" , U_Buff, MA_Buff, instance.parameters.Tclr, 100-instance.parameters.Transparency);
    instance:createChannelGroup("LowerGroup","Lower" , L_Buff, MA_Buff2, instance.parameters.Bclr, 100-instance.parameters.Transparency);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    MA:update(mode);
    BB:update(mode);
    MA_Buff[period]=MA.DATA[period];
    MA_Buff2[period]=MA.DATA[period];
    U_Buff[period]=BB.TL[period];
    L_Buff[period]=BB.BL[period];
 
end

