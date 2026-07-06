-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41309
-- Id: 9351

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
    indicator:name("GRF leading edge moving indicator");
    indicator:description("GRF leading edge moving indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 12);
    indicator.parameters:addInteger("LookAhead", "Look ahead", "", 0);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local LookAhead;
local GeoAvg;
local LEMov=nil;
local a00, a01, a11;
local det0;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    LookAhead=instance.parameters.LookAhead;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.LookAhead .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    GeoAvg = instance:addInternalStream(0, 0);
    LEMov = instance:addStream("LEMov", core.Line, name .. ".LEMov", "LEMov", instance.parameters.clr, first+Period);
    LEMov:setWidth(instance.parameters.widthLinReg);
    LEMov:setStyle(instance.parameters.styleLinReg);
    a00=Period*(Period-1)*(2*Period-1)/6;
    a01=Period*(Period-1)/2;
    a11=Period;
    det0=a00*a11-a01*a01;
end

function Update(period, mode)
   if period>first then
    GeoAvg[period]=math.pow(source.high[period]*source.low[period]*source.close[period]*source.close[period], 0.25);
    if period>first+Period then
     local c0, c1 = 0, 0;
     local i;
     for i=0, Period-1, 1 do
      c0=c0+i*GeoAvg[period-i];
      c1=c1+GeoAvg[period-i];
     end
     local Alpha=(c0*a11-c1*a01)/det0;
     local Beta=(a00*c1-a01*c0)/det0;
     LEMov[period]=Beta-Alpha*LookAhead;     
    end
   end 
end

