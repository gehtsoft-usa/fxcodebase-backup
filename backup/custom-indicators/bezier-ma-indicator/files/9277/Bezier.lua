-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3809

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
    indicator:name("Bezier indicator");
    indicator:description("Bezier indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 8);
    indicator.parameters:addDouble("Sensitivity", "Sensitivity", "", 0.5, 0, 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Sensitivity;
local Buff=nil;
local Fact={};
local i;
local Coeff={};

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Sensitivity=instance.parameters.Sensitivity;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Sensitivity .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Buff = instance:addStream("Buff", core.Line, name .. ".Buff", "Buff", instance.parameters.clr, first);
    Buff:setWidth(instance.parameters.widthLinReg);
    Buff:setStyle(instance.parameters.styleLinReg);
	
    local F=1;
    Fact[0]=1;
    for i=1,Period,1 do
     F=F*i;
     Fact[i]=F;
    end
    for i=0,Period,1 do
     Coeff[i]=(Fact[Period]/(Fact[i]*Fact[Period-i]))*math.pow(Sensitivity,i)*math.pow(1-Sensitivity,Period-i);
    end
end

function Update(period, mode)
   if (period<first ) then
   return;
   end
   
   
    local Sum=0;
    for i=Period,0,-1 do
     Sum=Sum+source[period-i]*Coeff[i];
    end
    Buff[period]=Sum;
  
end

