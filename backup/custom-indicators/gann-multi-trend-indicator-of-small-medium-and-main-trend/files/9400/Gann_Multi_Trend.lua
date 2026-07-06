-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3845

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
    indicator:name("Gann multi trend indicator");
    indicator:description("Gann multi trend indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period1", "Period1", "", 1);
    indicator.parameters:addInteger("Period2", "Period2", "", 2);
    indicator.parameters:addInteger("Period3", "Period3", "", 3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Color UP", "Color UP", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clrDN", "Color DN", "Color DN", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg1", "Line width 1", "Line width 1", 1, 1, 5);
    indicator.parameters:addInteger("widthLinReg2", "Line width 2", "Line width 2", 2, 1, 5);
    indicator.parameters:addInteger("widthLinReg3", "Line width 3", "Line width 3", 3, 1, 5);
end

local first;
local source = nil;
local Period1;
local Period2;
local Period3;
local BuffUP1=nil;
local BuffUP2=nil;
local BuffUP3=nil;
local BuffDN1=nil;
local BuffDN2=nil;
local BuffDN3=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period1=instance.parameters.Period1;
    Period2=instance.parameters.Period2;
    Period3=instance.parameters.Period3;
    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period1 .. ", " .. instance.parameters.Period2 .. ", " .. instance.parameters.Period3 .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    BuffUP1 = instance:addStream("BuffUP1", core.Line, name .. ".UP1", "UP1", instance.parameters.clrUP, first+2*Period1);
    BuffUP2 = instance:addStream("BuffUP2", core.Line, name .. ".UP2", "UP2", instance.parameters.clrUP, first+2*Period1);
    BuffUP3 = instance:addStream("BuffUP3", core.Line, name .. ".UP3", "UP3", instance.parameters.clrUP, first+2*Period2);
    BuffDN1 = instance:addStream("BuffDN1", core.Line, name .. ".DN1", "DN1", instance.parameters.clrDN, first+2*Period2);
    BuffDN2 = instance:addStream("BuffDN2", core.Line, name .. ".DN2", "DN2", instance.parameters.clrDN, first+2*Period3);
    BuffDN3 = instance:addStream("BuffDN3", core.Line, name .. ".DN3", "DN3", instance.parameters.clrDN, first+2*Period3);
    BuffUP1:setWidth(instance.parameters.widthLinReg1);
    BuffUP2:setWidth(instance.parameters.widthLinReg2);
    BuffUP3:setWidth(instance.parameters.widthLinReg3);
    BuffDN1:setWidth(instance.parameters.widthLinReg1);
    BuffDN2:setWidth(instance.parameters.widthLinReg2);
    BuffDN3:setWidth(instance.parameters.widthLinReg3);
end

function Update(period, mode)
   local B_UP1,B_DN1,B_UP,B_DN;
   if (period>first+2*Period1) then
    B_UP1,B_DN1,B_UP,B_DN=SetBufferData(period,Period1,BuffUP1[period-1],BuffDN1[period-1]);
    BuffUP1[period-1]=B_UP1;
    BuffDN1[period-1]=B_DN1;
    BuffUP1[period]=B_UP;
    BuffDN1[period]=B_DN;
   end 
   if (period>first+2*Period2) then
    B_UP1,B_DN1,B_UP,B_DN=SetBufferData(period,Period2,BuffUP2[period-1],BuffDN2[period-1]);
    BuffUP2[period-1]=B_UP1;
    BuffDN2[period-1]=B_DN1;
    BuffUP2[period]=B_UP;
    BuffDN2[period]=B_DN;
   end 
   if (period>first+2*Period3) then
    B_UP1,B_DN1,B_UP,B_DN=SetBufferData(period,Period3,BuffUP3[period-1],BuffDN3[period-1]);
    BuffUP3[period-1]=B_UP1;
    BuffDN3[period-1]=B_DN1;
    BuffUP3[period]=B_UP;
    BuffDN3[period]=B_DN;
   end 
end

function SetBufferData(Period,Bars,B_UP,B_DN)
 local B_UP_=B_UP;
 local B_DN_=B_DN;
 if B_UP_==0 then
  B_UP_=nil;
 end
 if B_DN_==0 then
  B_DN_=nil;
 end
 
 
 local Max=core.max(source.high,core.rangeTo(Period-Bars,Bars));
 local Min=core.min(source.low,core.rangeTo(Period-Bars,Bars));
 
 if source.high[Period]>Max and source.low[Period]>Min then
  return source.high[Period-1],B_DN_,source.high[Period],nil;
 elseif source.low[Period]<Min and source.high[Period]<Max then
  return B_UP_,source.low[Period-1],nil,source.low[Period];
 elseif source.low[Period]>Min and source.high[Period]<Max then
  return B_UP_,B_DN_,B_UP_,B_DN_;
 else 
  return B_UP_,B_DN_,source.high[Period],source.low[Period];
 end
 return nil,nil,nil,nil;
end

