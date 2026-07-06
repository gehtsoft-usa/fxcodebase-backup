-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59578
-- Id: 10069

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
    indicator:name("Dots indicator");
    indicator:description("Dots indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 6);
    indicator.parameters:addString("Method", "Method", "", "EMA");
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

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 3, 1, 5);
end

local first;
local source = nil;
local Period;
local Method;
local MA;
local UpSt, DnSt;
local UP=nil;
local DN=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;

	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Method .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MA = core.indicators:create("AVERAGES", source.close, Method, Period, false);	
	first = MA.DATA:first();
    UpSt=instance:addInternalStream(first, 0);
    DnSt=instance:addInternalStream(first, 0);
    UP = instance:addStream("UP", core.Dot, name .. ".UP", "UP", instance.parameters.UPclr, first);
    DN = instance:addStream("DN", core.Dot, name .. ".DN", "DN", instance.parameters.DNclr, first);
    UP:setWidth(instance.parameters.DotSize);
    DN:setWidth(instance.parameters.DotSize);
end

function Update(period, mode)
   if period>first then
    MA:update(mode);
    UpSt[period]=MA.DATA[period];
    DnSt[period]=MA.DATA[period];
    if MA.DATA[period]>MA.DATA[period-1] and MA.DATA[period-1]>MA.DATA[period-2] then
     DnSt[period]=0;
    end
    if MA.DATA[period]<MA.DATA[period-1] and MA.DATA[period-1]<MA.DATA[period-2] then
     UpSt[period]=0;
    end
    local Range=source.high[period]-source.low[period];
    if UpSt[period-1]==0 and UpSt[period]~=0 then
     UP[period]=source.low[period]-Range/2;
    else
     UP[period]=nil; 
    end
    if DnSt[period-1]==0 and DnSt[period]~=0 then
     DN[period]=source.high[period]+Range/2;
    else
     DN[period]=nil; 
    end
   end 
end

