-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=10149
-- Id: 5322

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
    indicator:name("StdDev OHLC indicator");
    indicator:description("StdDev OHLC indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addString("Method", "Method", "", "OHLC");
    indicator.parameters:addStringAlternative("Method", "OHLC", "", "OHLC");
    indicator.parameters:addStringAlternative("Method", "HL", "", "HL");

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Oclr", "Open Color", "Open Color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("Hclr", "High Color", "High Color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("Lclr", "Low Color", "Low Color", core.rgb(0, 255, 255));
    indicator.parameters:addColor("Cclr", "Close Color", "Close Color", core.rgb(0, 255, 0));
end

local first;
local source = nil;
local Period;
local Method;
local StdDev_O;
local StdDev_H;
local StdDev_L;
local StdDev_C;
local Buff_O=nil;
local Buff_H=nil;
local Buff_L=nil;
local Buff_C=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Method=instance.parameters.Method;
	
	assert(core.indicators:findIndicator("STDDEV") ~= nil, "Please, download and install STDDEV.LUA indicator");    
   
	first = StdDev_C.DATA:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    StdDev_O = core.indicators:create("STDDEV", source.open, Period);
    StdDev_H = core.indicators:create("STDDEV", source.high, Period);
    StdDev_L = core.indicators:create("STDDEV", source.low, Period);
    StdDev_C = core.indicators:create("STDDEV", source.close, Period);
    Buff_O = instance:addStream("Buff_O", core.Bar, name .. ".Open", "Open", instance.parameters.Oclr, first);
    Buff_O:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff_H = instance:addStream("Buff_H", core.Bar, name .. ".High", "High", instance.parameters.Hclr, first);
    Buff_H:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff_L = instance:addStream("Buff_L", core.Bar, name .. ".Low", "Low", instance.parameters.Lclr, first);
    Buff_L:setPrecision(math.max(2, instance.source:getPrecision()));
    Buff_C = instance:addStream("Buff_C", core.Bar, name .. ".Close", "Close", instance.parameters.Cclr, first);
    Buff_C:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    StdDev_O:update(mode);
    StdDev_H:update(mode);
    StdDev_L:update(mode);
    StdDev_C:update(mode);
    local Avg=(StdDev_O.DATA[period]+StdDev_H.DATA[period]+StdDev_L.DATA[period]+StdDev_C.DATA[period])/4;
    local Temp_O=StdDev_O.DATA[period]-Avg;
    local Temp_H=StdDev_H.DATA[period]-Avg;
    local Temp_L=StdDev_L.DATA[period]-Avg;
    local Temp_C=StdDev_C.DATA[period]-Avg;
    if Method=="HL" then
     Temp_O=0;
     Temp_C=0;
    end
    local max=math.max(Temp_O,Temp_H,Temp_L,Temp_C);
    local min=math.min(Temp_O,Temp_H,Temp_L,Temp_C);
    if (Temp_O-max)*(Temp_O-min)~=0 then
     Temp_O=nil;
    end
    if (Temp_H-max)*(Temp_H-min)~=0 then
     Temp_H=nil;
    end
    if (Temp_L-max)*(Temp_L-min)~=0 then
     Temp_L=nil;
    end
    if (Temp_C-max)*(Temp_C-min)~=0 then
     Temp_C=nil;
    end
    Buff_O[period]=Temp_O;
    Buff_H[period]=Temp_H;
    Buff_L[period]=Temp_L;
    Buff_C[period]=Temp_C;
    
end

