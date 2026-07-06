-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6718

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
    indicator:name("Parabolic moving average indicator with bands");
    indicator:description("Parabolic moving average indicator with bands");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 20);
    indicator.parameters:addDouble("Deviation", "Deviation", "", 1);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clr", "Color", "Color", core.rgb(255, 255, 0));
    indicator.parameters:addColor("clrB", "Band Color", "Band Color", core.rgb(128, 128, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Deviation;
local ParMA=nil;
local UP_Band=nil;
local DN_Band=nil;
local sum_x=0;
local sum_x2=0;
local sum_x3=0;
local sum_x4=0;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Deviation=instance.parameters.Deviation;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Deviation .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    ParMA = instance:addStream("ParMA", core.Line, name .. ".ParMA", "ParMA", instance.parameters.clr, first);
    UP_Band = instance:addStream("UP_Band", core.Line, name .. ".UP_Band", "UP_Band", instance.parameters.clrB, first+Period);
    DN_Band = instance:addStream("DN_Band", core.Line, name .. ".DN_Band", "DN_Band", instance.parameters.clrB, first+Period);
    ParMA:setWidth(instance.parameters.widthLinReg);
    ParMA:setStyle(instance.parameters.styleLinReg);
    UP_Band:setWidth(instance.parameters.widthLinReg);
    UP_Band:setStyle(instance.parameters.styleLinReg);
    DN_Band:setWidth(instance.parameters.widthLinReg);
    DN_Band:setStyle(instance.parameters.styleLinReg);
    local i;
    local var_tmp;
    for i=1,Period,1 do
     var_tmp=i;
     sum_x=sum_x+var_tmp;
     var_tmp=var_tmp*i;
     sum_x2=sum_x2+var_tmp;
     var_tmp=var_tmp*i;
     sum_x3=sum_x3+var_tmp;
     var_tmp=var_tmp*i;
     sum_x4=sum_x4+var_tmp;
    end
end

function Update(period, mode)
   if (period<first) then
   return;
   end
    local sum_y=0;
    local sum_xy=0;
    local sum_x2y=0;
    local i;
    local var_tmp;
    for i=1,Period,1 do
     var_tmp=source[period-Period+i];
     sum_y=sum_y+var_tmp;
     sum_xy=sum_xy+i*var_tmp;
     sum_x2y=sum_x2y+i*i*var_tmp;
    end
    local A=Period;
    local B=sum_x;
    local C=sum_x2;
    local F=sum_x3;
    local M=sum_x4;
    local P=sum_y;
    local R=sum_xy;
    local S=sum_x2y;
    local D=B;
    local E=C;
    local K=C;
    local L=F;
    local Q=D/A;
    E=E-Q*B;
    F=F-Q*C;
    R=R-Q*P;
    Q=K/A;
    L=L-Q*B;
    M=M-Q*C;
    S=S-Q*P;
    Q=L/E;
    local B2=(S-R*Q)/(M-F*Q);
    local B1=(R-F*B2)/E;
    local B0=(P-B*B1-C*B2)/A;
    local val=B0+(B1+B2*A)*A;
    ParMA[period]=val;
	
   if (period<first+Period) then
   return;
   end
   
    local StDev=mathex.stdev(ParMA,period-Period+1, period);
    UP_Band[period]=val+StDev*Deviation;
    DN_Band[period]=val-StDev*Deviation;
  
end

