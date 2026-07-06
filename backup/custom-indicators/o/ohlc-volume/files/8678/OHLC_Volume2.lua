-- Id: 3293
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+

function Init()
    indicator:name("OHLC Volume indicator");
    indicator:description("OHLC Volume indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color UP", "Color UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color DN", "Color DN", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local BuffUP=nil;
local BuffDN=nil;

function Prepare()
    source = instance.source;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
    BuffUP = instance:addStream("BuffUP", core.Bar, name .. ".UP volume", "UP volume", instance.parameters.clrUP, first);
    BuffUP:setPrecision(math.max(2, instance.source:getPrecision()));
    BuffDN = instance:addStream("BuffDN", core.Bar, name .. ".DN volume", "DN volume", instance.parameters.clrDN, first);
    BuffDN:setPrecision(math.max(2, instance.source:getPrecision()));
end

function Update(period, mode)
   if (period>first) then
    local UPcoeff=source.high[period]-source.open[period];
    local DNcoeff=source.close[period]-source.low[period];
    local VUP=source.volume[period]*UPcoeff/(UPcoeff+DNcoeff);
    local VDN=source.volume[period]*DNcoeff/(UPcoeff+DNcoeff);
    if VUP>VDN then
     BuffUP[period]=VUP-VDN;
     BuffDN[period]=nil;
    else
     BuffDN[period]=VUP-VDN;
     BuffUP[period]=nil;
    end
   end 
end

