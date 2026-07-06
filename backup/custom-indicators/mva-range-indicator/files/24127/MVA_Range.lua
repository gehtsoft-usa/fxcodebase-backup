-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=12169
-- Id: 5611

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
    indicator:name("MVA with range indicator");
    indicator:description("MVA with range indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 10,1,1000);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MVA_Clr", "MVA Color", "MVA Color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Cloud_Clr", "Cloud Color", "Cloud Color", core.rgb(128, 255, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local source = nil;
local Period;
local MVA=nil;
local U_MVA=nil;
local L_MVA=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    first = source:first()+ Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    MVA = instance:addStream("MVA", core.Line, name .. ".MVA", "MVA", instance.parameters.MVA_Clr, first);
    MVA:setWidth(instance.parameters.widthLinReg);
    MVA:setStyle(instance.parameters.styleLinReg);
    U_MVA = instance:addInternalStream(0, 0);
    L_MVA = instance:addInternalStream(0, 0);
    instance:createChannelGroup("MVA_Range", "MVA_Range", U_MVA, L_MVA, instance.parameters.Cloud_Clr, 100 - instance.parameters.Transparency);
end

function Update(period, mode)
   if (period<first) then
   return;
   end
   
    local Sum=0;
    if Period>1 then
     Sum=core.sum(source.close,core.rangeTo(period-1,Period-1));
    end 
    MVA[period]=(Sum+source.close[period])/Period;
    U_MVA[period]=(Sum+source.high[period])/Period;
    L_MVA[period]=(Sum+source.low[period])/Period;
  
end

