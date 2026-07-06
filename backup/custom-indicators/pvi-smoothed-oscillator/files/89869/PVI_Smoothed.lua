-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59617
-- Id: 10161

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
    indicator:name("Smoothed Positive Volume Index");
    indicator:description("Smoothed Positive Volume Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("PVI_Period", "Smooth period", "", 5);
    indicator.parameters:addInteger("S_Period", "Signal seriod", "", 15);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("PVIclr", "PVI color", "PVI color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("PVIwidth", "PVI line width", "PVI line width", 1, 1, 5);
    indicator.parameters:addInteger("PVIstyle", "PVI line style", "PVI line style", core.LINE_SOLID);
    indicator.parameters:setFlag("PVIstyle", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Sclr", "Signal line color", "Signal line color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("Swidth", "Signal line width", "Signal line width", 1, 1, 5);
    indicator.parameters:addInteger("Sstyle", "Signal line style", "Signal line style", core.LINE_DASH);
    indicator.parameters:setFlag("Sstyle", core.FLAG_LINE_STYLE);
end

local PVI_Period;
local S_Period;
local first;
local source = nil;
local PVI_St;
local MVA;
local EMA;
local PVI=nil;
local Signal=nil;

function Prepare(nameOnly)
    PVI_Period=instance.parameters.PVI_Period;
    S_Period=instance.parameters.S_Period;
    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    PVI_St=instance:addInternalStream(first, 0);
    MVA=core.indicators:create("MVA", PVI_St, PVI_Period);
    EMA=core.indicators:create("EMA", MVA.DATA, S_Period);
    PVI = instance:addStream("PVI", core.Line, name .. ".Smoothed PVI", "Smoothed PVI", instance.parameters.PVIclr, MVA.DATA:first() );
    PVI:setPrecision(math.max(2, instance.source:getPrecision()));
    PVI:setWidth(instance.parameters.PVIwidth);
    PVI:setStyle(instance.parameters.PVIstyle);
    Signal = instance:addStream("Signal", core.Line, name .. ".Signal", "Signal", instance.parameters.Sclr, EMA.DATA:first());
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));
    Signal:setWidth(instance.parameters.Swidth);
    Signal:setStyle(instance.parameters.Sstyle);
end

function Update(period, mode)
   if (period>first) then
		if source.volume[period]>source.volume[period-1] then
		 PVI_St[period]=PVI_St[period-1]*(1+((source.close[period]-source.close[period-1])/source.close[period-1]));
		else
		 PVI_St[period]=PVI_St[period-1];
		end
   elseif period==first then
    PVI_St[period]=1;
   end 
   
   MVA:update(mode);   
   EMA:update(mode);
   if period > MVA.DATA:first() then
   PVI[period]=MVA.DATA[period];
   end
   if period > EMA.DATA:first() then
   Signal[period]=EMA.DATA[period];
   end
   
end

