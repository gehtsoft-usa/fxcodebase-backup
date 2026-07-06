-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12230
-- Id: 5637

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
    indicator:name("MA with gaussian filter");
    indicator:description("MA with gaussian filter");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 12);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP Color", "UP Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN Color", "DN Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("Aclr", "Acceleration Color", "Acceleration Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Dclr", "Deceleration Color", "Deceleration Color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("DotSize", "Dot size", "Dot size", 1, 1, 5);
end

local first;
local source = nil;
local Period;
local GaussMA=nil;
local AD=nil;
local Alpha;
local p1,p2,p3,p4,p5;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+5;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    GaussMA = instance:addStream("GaussMA", core.Line, name .. ".GaussMA", "GaussMA", instance.parameters.UPclr, first);
    GaussMA:setWidth(instance.parameters.widthLinReg);
    GaussMA:setStyle(instance.parameters.styleLinReg);
    AD = instance:addStream("AD", core.Dot, name .. ".A/D", "A/D", instance.parameters.Aclr, first);
    AD:setWidth(instance.parameters.DotSize);
    local w=2*math.pi/Period;
    local beta=(1-math.cos(w))/(math.pow(2,1/3)-1);
    Alpha=-beta+math.sqrt(beta*(beta+2));
    p1=math.pow(Alpha,4);
    p2=4*(1-Alpha);
    p3=6*math.pow(1-Alpha,2);
    p4=4*math.pow(1-Alpha,3);
    p5=math.pow(1-Alpha,4);
end

function Update(period, mode)
   if (period<first ) then
    GaussMA[period]=source[period];
   return;
   end
   
    GaussMA[period]=p1*source[period-1]+p2*GaussMA[period-1]-p3*GaussMA[period-2]+p4*GaussMA[period-3]-p5*GaussMA[period-4];
    if GaussMA[period]>=GaussMA[period-1] then
     GaussMA:setColor(period,instance.parameters.UPclr);
    else
     GaussMA:setColor(period,instance.parameters.DNclr);
    end
    AD[period]=GaussMA[period];
    local s1=GaussMA[period-1]-GaussMA[period];
    local s2=GaussMA[period-2]-GaussMA[period-1];
    if s1<s2 then
     AD:setColor(period,instance.parameters.Aclr);
    else
     AD:setColor(period,instance.parameters.Dclr);
    end
    
end

