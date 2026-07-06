-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3847

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
    indicator:name("Projection Bands Indicator");
    indicator:description("Projection Bands Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(0, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local BuffUpProjBand=nil;
local BuffDnProjBand=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    BuffUpProjBand = instance:addStream("BuffUp", core.Line, name .. ".UpProjBand", "UpProjBand", instance.parameters.clr, first);
    BuffDnProjBand = instance:addStream("BuffDn", core.Line, name .. ".DnProjBand", "DnProjBand", instance.parameters.clr, first);
    BuffUpProjBand:setWidth(instance.parameters.widthLinReg);
    BuffUpProjBand:setStyle(instance.parameters.styleLinReg);
    BuffDnProjBand:setWidth(instance.parameters.widthLinReg);
    BuffDnProjBand:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
    if (period<first) then
   return;
   end
   
    local SlopeHigh=mathex.lregSlope(source.high,period-Period+1,period);
    local SlopeLow=mathex.lregSlope(source.low,period-Period+1,period);
    local i;
    local UpProjBand=source.high[period];
    local DnProjBand=source.low[period];
    for i=1,Period,1 do
     UpProjBand=math.max(UpProjBand,source.high[period-i]+i*SlopeHigh);
     DnProjBand=math.min(DnProjBand,source.low[period-i]-i*SlopeLow);
    end
    BuffUpProjBand[period]=UpProjBand;
    BuffDnProjBand[period]=DnProjBand;
 
 
end

