-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6305

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Power weighted moving average");
    indicator:description("Power weighted moving average");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 1000);
    indicator.parameters:addDouble("Power", "Power", "", 2);
    indicator.parameters:addBoolean("ColorMode", "ColorMode", "", true);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("MainClr", "Main color", "Main color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPclr", "UP color", "UP color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr", "DN color", "DN color", core.rgb(0, 0, 255));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local first;
local source = nil;
local Period;
local Power;
local ColorMode;
local PWMA=nil;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
    Power=instance.parameters.Power;
    ColorMode=instance.parameters.ColorMode;
    first = source:first()+Period;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ", " .. instance.parameters.Power .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    PWMA = instance:addStream("PWMA", core.Line, name .. ".PWMA", "PWMA", instance.parameters.MainClr, first);
    PWMA:setWidth(instance.parameters.widthLinReg);
    PWMA:setStyle(instance.parameters.styleLinReg);
end

function Update(period, mode)
   if (period<first ) then
   return;
   end
    local i;
    local Sum1=0;
    local Sum2=0;
    for i=0,Period-1,1 do
     Sum1=Sum1+source[period-i]*math.pow(Period-i,Power);
     Sum2=Sum2+math.pow(Period-i,Power);
    end
    PWMA[period]=Sum1/Sum2;
	
    if ColorMode then
     if PWMA[period]>PWMA[period-1] then
      PWMA:setColor(period,instance.parameters.UPclr);
     elseif PWMA[period]<PWMA[period-1] then
      PWMA:setColor(period,instance.parameters.DNclr);
     end
    end 
 
end

