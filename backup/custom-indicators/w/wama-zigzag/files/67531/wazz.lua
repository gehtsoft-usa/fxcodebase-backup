-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=41304
-- Id: 9340

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
    indicator:name("Wazz indicator");
    indicator:description("Wazz indicator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 15);
    indicator.parameters:addBoolean("UseDoubleSmooth", "Use double smooth", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local UseDoubleSmooth;
local EMA;
local SecondEMA;
local Buff;
local Period4, Period8, Period12;
local Wama;
local HL_Buff;
local WazzUP=nil;
local WazzDN=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    UseDoubleSmooth=instance.parameters.UseDoubleSmooth;
    Period4=math.floor(Period/4);
    Period8=math.floor(Period/8);
    Period12=math.floor(Period/12);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    
    Buff=instance:addInternalStream(0, 0);
    Wama=instance:addInternalStream(0, 0);
    HL_Buff=instance:addInternalStream(0, 0);
    EMA = core.indicators:create("EMA", source, Period);
    SecondEMA = core.indicators:create("EMA", Buff, Period4);
	
	if UseDoubleSmooth then
	first = SecondEMA.DATA:first();
	else
	first = EMA.DATA:first();
	end
    WazzUP = instance:addStream("UP", core.Line, name .. ".UP", "UP", instance.parameters.UPclr, first);
    WazzUP:setWidth(instance.parameters.widthLinReg);
    WazzUP:setStyle(instance.parameters.styleLinReg);
    WazzDN = instance:addStream("DN", core.Line, name .. ".DN", "DN", instance.parameters.DNclr, first);
    WazzDN:setWidth(instance.parameters.widthLinReg);
    WazzDN:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if period>first then
    EMA:update(mode);
    local vel=EMA.DATA[period]-EMA.DATA[period-Period4];
    local acc=EMA.DATA[period]-2*EMA.DATA[period-Period4]+EMA.DATA[period-Period8];
    local aaa=EMA.DATA[period]-3*EMA.DATA[period-Period4]+3*EMA.DATA[period-Period8]-EMA.DATA[period-Period12];
	
	if UseDoubleSmooth and period<first+Period4 then
	return;
	end
	
	
    if UseDoubleSmooth then
     Buff[period]=EMA.DATA[period]+vel+acc/2+aaa/6;
     SecondEMA:update(mode);
     Wama[period]=SecondEMA.DATA[period];
    else
     Wama[period]=EMA.DATA[period]+vel+acc/2+aaa/6;
    end
    HL_Buff[period]=HL_Buff[period-1];
    if Wama[period]>Wama[period-1] then
     if HL_Buff[period-1]==nil or HL_Buff[period-1]<=0 then
      HL_Buff[period]=period;
     end
    elseif Wama[period]<Wama[period-1] then
     if HL_Buff[period-1]==nil or HL_Buff[period-1]>=0 then
      HL_Buff[period]=-period;
     end
    end
    if HL_Buff[period]~=HL_Buff[period-1] and HL_Buff[period-1]~=nil then
     local prevPeriod=math.abs(HL_Buff[period-1]);
     if source[period]>=source[prevPeriod] then
      core.drawLine(WazzUP,core.range(prevPeriod,period),source[prevPeriod],prevPeriod,source[period],period);
     else
      core.drawLine(WazzDN,core.range(prevPeriod,period),source[prevPeriod],prevPeriod,source[period],period);
     end
    end
   elseif period>first then
    HL_Buff[period]=nil;
   end 
end

