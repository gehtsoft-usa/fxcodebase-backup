-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23002
-- Id: 7286

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
    indicator:name("VQz indicator");
    indicator:description("VQz indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 7);
    indicator.parameters:addString("Method", "Method", "", "MVA");
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
    indicator.parameters:addInteger("Smoothing", "Smoothong", "", 1);
    indicator.parameters:addInteger("Filter", "Filter", "", 5);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
	indicator.parameters:addColor("NOclr", "Neutral Color", "Neutral Color", core.rgb(128, 128,128));
end

local first;
local source = nil;
local Period;
local Method;
local Smoothing;
local Filter;
local Filter_pip;
local VQ;
local MA_H, MA_L, MA_O, MA_C;
local UP=nil;
local DN=nil;
local NO=nil;
function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
    Smoothing=instance.parameters.Smoothing;
    Filter=instance.parameters.Filter;
    Filter_pip=Filter*source:pipSize();
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Method .. ", " .. instance.parameters.Smoothing .. ", " .. instance.parameters.Filter .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");    
	
    
    VQ = instance:addInternalStream(0, 0);
    MA_H = core.indicators:create("AVERAGES", source.high, Method, Period, false);
    MA_L = core.indicators:create("AVERAGES", source.low, Method, Period, false);
    MA_O = core.indicators:create("AVERAGES", source.open, Method, Period, false);
    MA_C = core.indicators:create("AVERAGES", source.close, Method, Period, false);
	
	first =  MA_C.DATA:first()+Smoothing;
    UP = instance:addStream("UP", core.Bar, name .. ".UP", "UP", instance.parameters.UPclr, first);
    UP:setPrecision(math.max(2, instance.source:getPrecision()));
    DN = instance:addStream("DN", core.Bar, name .. ".DN", "DN", instance.parameters.DNclr, first);
    DN:setPrecision(math.max(2, instance.source:getPrecision()));
	NO = instance:addStream("NO", core.Bar, name .. ".NO", "NO", instance.parameters.NOclr, first);
    NO:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)


   	if   period<first then
    return;
    end
   
    local Curr;
    MA_H:update(mode);
    MA_L:update(mode);
    MA_O:update(mode);
    MA_C:update(mode);
	   
    local h=MA_H.DATA[period];
    local l=MA_L.DATA[period];
    local o=MA_O.DATA[period];
    local c=MA_C.DATA[period];
    local c2=MA_C.DATA[period-Smoothing];
    local Max=math.max(h-l,h-c2,c2-l);
    VQ[period]=math.abs(((c-c2)/Max+(c-o)/(h-l))*0.5)*((c-c2+(c-o))*0.5);
    if math.abs(VQ[period])<Filter_pip then
     VQ[period]=VQ[period-1];
    end
    if VQ[period]>0 then
     UP[period]=1;
     DN[period]=0;
	 NO[period]=0;
    elseif VQ[period]<0 then
     UP[period]=0;
     DN[period]=1;
	 NO[period]=0;
	else
     UP[period]=0;
     DN[period]=0;
	 NO[period]=1;	
    end
 
end

